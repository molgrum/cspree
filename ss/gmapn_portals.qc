/*
    gmapn_hazards.qc

    Copyright (C) 2017 David Walton

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to:

        Free Software Foundation, Inc.
        59 Temple Place - Suite 330
        Boston, MA  02111-1307, USA

*/
#ifdef HAVE_PORTALS

.string portalsurf;	//set world.portalsurf to "ptl_" so that surfaces called ptl_foo, and ONLY surfaces with that pattern, will accept portals


//shared with player entity
class portal
{
	portal targ;
	vector pos;
	vector n;
	vector s;
	vector t;

	float surfnum;

	//transform the point in terms of the source surface.
	//then transform into worldspace according to the axis of the target.
	nonvirtual vector(vector v) direction_transform =
	{
		//FIXME: this should include .angles stuff
		vector tmp, r;
		tmp_x = v * n;
		tmp_y = v * s;
		tmp_z = v * t;

		r = '0 0 0';
		if (!targ)
		{
			r+= tmp_z * this.t;
			r-= tmp_y * this.s;
			r-= tmp_x * this.n;
		}
		else
		{
			r+= tmp_z * targ.t;
			r-= tmp_y * targ.s;
			r-= tmp_x * targ.n;
		}
		return r;
	};
	nonvirtual vector(vector p) origin_transform =
	{
		if (!targ)
		{
			return this.pos - direction_transform(pos - p);
		}
		return targ.pos - direction_transform(pos - p);
	};

	//need to generate forward/right/up vectors
	//return value is the new view origin.
	//trace_end_pos needs to contain the pvs origin.
	//
	virtual vector(vector o_o, vector angles) camera_transform =
	{
		vector n_o;

		n_o = origin_transform(o_o);
		v_forward = direction_transform(v_forward);
		v_right = direction_transform(v_right);
		v_up = direction_transform(v_up);

		//trace from the center of the target to the view, to set trace_endpos for the pvs origin
		if (targ)
			traceline(targ.pos, n_o, TRUE, this);
		else
			trace_endpos = this.pos;
		return n_o;
	};

	//called at spawn or when the modelindex is received from the server. just updates the surface info
	nonvirtual void() portalupdated =
	{
		//the displayed surface must be in a known position. we're not going to compensate for the model here, because I'm too lazy.
		makevectors(self.angles);
		n = v_forward;
		s = -v_right;
		t = v_up;
		pos = origin;

		//expand the size of the object along the plane, and set up a portal region.
		movetype = MOVETYPE_NONE;
		solid = targ?SOLID_PORTAL:SOLID_BSP;
		skin = CONTENT_SOLID;

		precache_model("progs/b_portal.bsp");	//bsp, but not a map. HAH! TAKE THAT!
		setmodel(this, "progs/b_portal.bsp");

		//determine size of major axis
		float sz = max(size_x,size_y,size_z);
		impulse = sz;	//let the engine know how wide the portal should be
		
		//make sure the abs size contains the entire portal.
		sz = sqrt(sz*sz*2);
		mins -= sz*'1 1 1';
		maxs += sz*'1 1 1';
		setsize(this, mins, maxs);

		if (cnt & 1)
			colormod = '1 0 0';
		else
			colormod = '0 0 1';
		if (targ)
		{
			if (!view2)
			{
				view2 = spawn();
				view2.skin = CONTENT_SOLID;
			}
			view2.tag_entity = self;
			view2.tag_index = -1;		//set view2 as a camera
			view2.origin = targ.origin;
			view2.angles = targ.angles;

			makevectors(targ.angles);
			view2.angles = vectoangles(-v_forward, v_up);
			view2.angles_x *= -1;
		}
		else
		{
			colormod_y = 1;
			if (view2)
			{
				remove(view2);
				view2 = 0;
			}
		}
	};


	//spawned with owner, origin, angles set.
	void() portal =
	{
		local portal exit;
		angles_x *= -1;	//we're using bsps here, and vectoangles gets stuff wrong.

		//can't use .owner for our owner... it lets them walk through us. declare a vendeta instead.
		enemy = owner;
		owner = world;

//		enemy.portalnum = !enemy.portalnum;	//portals alternate
//		portalnum = enemy.portalnum;

		classname = "portal";
		exit = find(world, ::classname, "portal");
		while(exit)
		{
			if (exit != this && exit.enemy == enemy)
			{
				if (exit.cnt == cnt)
				{
					if (exit.targ)
						exit.targ = world;
					if (exit.view2)
						remove(exit.view2);
					remove(exit);	//FIXME: should have some sort of time delay, and to kick things from out of it.
				}
				else if ((exit.cnt & ~1) == (cnt & ~1))
					targ = exit;
			}
			exit = find(exit, ::classname, "portal");
		}
		portalupdated();

		if (targ)
		{
//			if (targ.targ)
//				targ.targ.targ = world;
			targ.targ = this;
			targ.skin = skin;
			targ.portalupdated();
		}
//		setorigin(this, origin);
	};
};

#define crossproduct(x,y)	[ x[1] * y[2] - x[2] * y[1], x[2] * y[0] - x[0] * y[2], x[0] * y[1] - x[1] * y[0] ]
static vector v_origin;
//given a triangle, determine the orientation of the texture coords
static float(vector xyz1, vector st1, vector xyz2, vector st2, vector xyz3, vector st3) guesscoordsfrompoints =
{
	//first guess at texture directions
	float m;
	vector dir1 = xyz2 - xyz1;
	vector std1 = st2 - st1;
	vector dir2 = xyz3 - xyz1;
	vector std2 = st3 - st1;
	vector xdir, ydir;

//print(sprintf("%v %v %v\n", xyz1, xyz2, xyz3));

	//rescale the st directions to length 1
	m = vlen(std1);
	if (!m)
		return FALSE;
	m = 1/m;
	dir1 *= m;
	std1 *= m;
	m = std1 * std2;	//perpendicularify
	std2 = std2 - (std1 * m);
	dir2 = dir2 - (dir1 * m);
	m = vlen(std2);
	if (!m)
		return FALSE;
	m = 1/m;
	dir2 *= m;
	std2 *= m;

	//determine the vectors
	v_forward = normalize(crossproduct(dir1, dir2));
	xdir = std1[1] * dir2 - std2[1] * dir1;
	ydir = std1[0] * dir2 - std2[0] * dir1,
	//flatten the directions with respect to the normal.
	xdir -= v_forward * (xdir * v_forward);
	ydir -= v_forward * (ydir * v_forward);

	xyz1 = (xyz1+xyz2+xyz3) * (1/3.0);
	st1 = (st1+st2+st3) * (1/3.0);
	if (crossproduct(ydir, xdir) * v_forward < 0)
	{
		ydir *= -1;
		st1[0] *= -1;
	}
	xdir *= -1;

	v_right = normalize(xdir);
	v_up = normalize(ydir);

	//average the coords to try to find the middle, so flooring is more reliable.
	v_origin = xyz1 - v_forward * 0.125;
	v_origin -= xdir * (st1[0] - floor(st1[0]));
	v_origin -= ydir * (st1[1] - floor(st1[1]));
	return TRUE;
};

//find a triangle that isn't degenerate (ie: one that does not have all 3 points in a single line)
static vector(entity ent, float surf) guesscoordsfromsurface =
{
	float point, points = getsurfacenumpoints(ent, surf);
	vector xyz1, xyz2, xyz3;
	vector st1, st2, st3;
	xyz1 = getsurfacepointattribute(ent, surf, 0, 0);
	st1 = getsurfacepointattribute(ent, surf, 0, 4);
	xyz2 = getsurfacepointattribute(ent, surf, 1, 0);
	st2 = getsurfacepointattribute(ent, surf, 1, 4);
	for (point = 2; point < points; point++)
	{
		xyz3 = getsurfacepointattribute(ent, surf, point, 0);
		st3 = getsurfacepointattribute(ent, surf, point, 4);
		if (guesscoordsfrompoints(xyz1, st1, xyz2, st2, xyz3, st3))
			break;
		xyz2 = xyz3;
		st2 = st3;
	}
	return v_origin;
};

float(entity e, vector org, vector dir, float maxe, vector n) getsurfaceextent =
{
	float far = 0;
	float ext;
	float base = org * dir;
	float dist = org * n;
	float okay = TRUE;
	vector point;

	while (far < maxe)
	{
		float surf = getsurfacenearpoint(e, org + (dir * (far+1)));
		if (getsurfacenormal(trace_ent, surf) != n)
			break;	//wrong plane normal
		if (world.portalsurf != "")
		{
			local string tex = getsurfacetexture(e, surf);
			if (strncasecmp(tex, world.portalsurf, strlen(world.portalsurf)))
				break;	//wrong surface texture
		}
		point = getsurfaceclippedpoint(e, surf, org + (dir*maxe));
		ext = (dir * point) - base;
		if (fabs((point * n) - dist) > 5)
			break;	//wrong plane dist
		if (ext > far)
			far = ext;	//there's valid surface info up until this point
		else
			break;	//we didn't get anywhere further, so stop trying to find new surfaces.
	}
	return far;
};
static float(entity ent, vector point) GetPortalCenter =
{
	local float surf = getsurfacenearpoint(ent, point);

	guesscoordsfromsurface(ent, surf);
	//v_* now refer to the surface's texture vectors

	vector n = getsurfacenormal(ent, surf);

	//figure out where to budge it in order to get it to fit on the wall vertically
	//note: this fails when the center top is invalid
	//this logic is shit.
	float l, r, e;
	float h;
	float d = getsurfaceextent(ent, point, v_up*-1, 128, n);
	float u = getsurfaceextent(ent, point, v_up, 128, n);
	if (u+d < 128)
	{
		print(sprintf("vertical fizzle (%g+%g<128)\n", u,d));
		return FALSE;	//fizzle
	}
	if (d < 64)
		point += (64-d)*v_up;
	if (u < 64)
		point -= (64-u)*v_up;

	//now try and move it sideways
	l = 128;
	r = 128;
	for(h = -64+4; h < 64; h += 8)
	{
		e = getsurfaceextent(ent, point + h*v_up, v_right*-1, l, n);
		if (l > e)
			l = e;
		e = getsurfaceextent(ent, point + h*v_up, v_right, r, n);
		if (r > e)
			r = e;
		if (r+l < 128)
		{
			print(sprintf("horizontal fizzle (%g+%g<128 at %g ('%v' '%v')\n", r,l, h, v_up, v_right));
			return FALSE;	//fizzle
		}
	}
	if (l < 64)
		point += (64-l)*v_right;
	if (r < 64)
		point -= (64-r)*v_right;
	trace_endpos = point;
	return TRUE;
};
/*
static void(entity e, float surfnum) DrawSurfacePoly =
{
	float point, points = getsurfacenumpoints(e, surfnum);
	R_BeginPolygon("fill_trans");
	//assume simple poly/triangle fan...
	for (point = 0; point < points; point++)
	{
		R_PolygonVertex(	getsurfacepointattribute(e, surfnum, point, 0),
					getsurfacepointattribute(e, surfnum, point, 4),
					'1 1 1', 0.1);
	}
	R_EndPolygon();
};
void() SV_AddDebugPolygons =
{
	local vector point;
	local entity player = nextent(world);
	makevectors(player.v_angle);
	traceline(player.origin+player.view_ofs, player.origin+player.view_ofs + v_forward*2000, TRUE, player);
	if (trace_fraction == 1)
		return;	//urk

	if (!GetPortalCenter(trace_ent, trace_endpos))
		return;
	point = trace_endpos + trace_plane_normal*1;

//print(sprintf("%v %v %v %v\n", point, v_forward, v_right, v_up));

	R_BeginPolygon("fill_trans");
	R_PolygonVertex(point - v_right*64 - v_up*64, '0 0', '1 0 0', 0.5);
	R_PolygonVertex(point + v_right*64 - v_up*64, '1 0', '1 0 0', 0.5);
	R_PolygonVertex(point + v_right*64 + v_up*64, '1 1', '1 0 0', 0.5);
	R_PolygonVertex(point - v_right*64 + v_up*64, '0 1', '1 0 0', 0.5);
	R_EndPolygon();

	R_BeginPolygon("fill_trans");
	R_PolygonVertex(point - v_right*64 - v_up*64, '0 0', '0 1 0', 0.5);
	R_PolygonVertex(point - v_right*64 + v_up*64, '1 0', '0 1 0', 0.5);
	R_PolygonVertex(point + v_right*64 + v_up*64, '1 1', '0 1 0', 0.5);
	R_PolygonVertex(point + v_right*64 - v_up*64, '0 1', '0 1 0', 0.5);
	R_EndPolygon();
};
*/

var float autocvar_portal_pushfromsurface = 1.0;	//distance the portal is pushed from the surface that it is spawned on. 0 in an ideal world, but this can result in z-fighting.
float(vector source, vector dir, entity own, float id) spawnaportal =
{
	float fizzle = FALSE;
//FIXME: scan for center of texture. avoid placing portals where the underlaying surface is invalid.
	traceline(source, source+dir*2000, TRUE, self);

	if (trace_ent.solid == SOLID_PORTAL)
		fizzle = TRUE;

	vector portalpoint = trace_endpos;
	vector up;
	if (own.gravitydir*own.gravitydir > 0.1)
		up = own.gravitydir*-1;
	else
		up = '0 0 1';

	if (!fizzle)
		if (!GetPortalCenter(trace_ent, trace_endpos))
			fizzle = TRUE;

	trailparticles(particleeffectnum(sprintf("portal.tr_portalgun_%g", (id&1)+1)), self, source, trace_endpos);
	if (fizzle)
	{
		fizzle = TRUE;
		pointparticles(particleeffectnum(sprintf("portal.te_portalfizzle_%g", (id&1)+1)), trace_endpos, trace_plane_normal);
		return FALSE;
	}
	else
	{
		portalpoint = trace_endpos + trace_plane_normal*autocvar_portal_pushfromsurface;
		portal p = spawn(portal, cnt:id, owner:own, origin:portalpoint, angles:vectoangles(trace_plane_normal, up));
		pointparticles(particleeffectnum(sprintf("portal.te_portalspawn_%g", (id&1)+1)), p.origin, trace_plane_normal);

		local entity e;
		for (e = world; (e = nextent(e)); )
		{
			if (e.flags & (FL_MONSTER|FL_ITEM))
			{
				e.flags |= FL_PARTIALGROUND;	//make monsters be prepared to take bad steps
#ifndef PORTALS_NOITEMDROP
				e.flags &= ~FL_ONGROUND;		//allow items to plummet
#endif
			}
		}
	}
	return TRUE;
};

#if 0
/*QUAKED misc_portalspawn (.5 .5 .5) (-8 -8 -8) (8 8 8)
when activated, spawns a portal on behalf of the activator.
impulse: specifies the activator's portal number. typically 0 or 1. other values are allowed if you want extra portals, but will not be player-specific.
*/
void() misc_portalspawn_use =
{
	entity own;
	self.v_angle = self.angles;
	self.v_angle_x *= -1;
	makevectors(self.v_angle);

	if (self.impulse <= 1)
		own = activator;
	else
		own = world;	//generic portals are not owned by anyone specific

	spawnaportal(self.origin, v_forward, own, self.impulse);
};
void() misc_portalspawn =
{
	self.use = misc_portalspawn_use;

	InitTrigger ();
};


/*QUAKED trigger_portaldespawn (.5 .5 .5) ?
when activated, de-spawns portal(s) owned by the activator.
impulse: if -1, despawns all portals owned by the player. if 0 or 1, despawns a specific player portal. other values despawn global portals (ie: ones spawned via misc_portalspawn).
targetname: if set, used instead of touched.
*/
void() misc_portaldespawn_use =
{
	float foundone = FALSE;
	entity own;
	portal port;
	if (self.impulse <= 1)
	{
		own = activator;
		if (own.classname != "player")
			return;
	}
	else
		own = world;	//generic portals are not owned by anyone specific

	port = (portal)find(world, classname, "portal");
	while(port)
	{
		if (port.enemy == own && (port.portalnum == self.impulse || self.impulse == -1))
		{
			if (port.targ)
				port.targ = 0;
			remove(port);
			foundone = TRUE;
		}
		port = (portal)find(port, classname, "portal");
	}

	if (foundone && own)
		centerprint(own, self.message);
}
void() misc_portaldespawn_touch =
{
	activator = other;
	misc_portaldespawn_use();
};
void() trigger_portaldespawn =
{
	if (self.targetname)
		self.use = misc_portaldespawn_use;
	else
		self.touch = misc_portaldespawn_touch;
	InitTrigger ();
};
#endif

#endif



//for q3 compat
void() spawnfunc_misc_portal_camera = {self.nextthink = time + 2; self.think = SUB_Remove;};	//the target
void() linkportalsurface =
{
	if (self.target != "")
	{
		//q3 portals are built into the world, so we need to set ourselves up as some special portal surface entity
		self.skin = CONTENT_SOLID;
		self.tag_entity = world;	//portals on world can use the nearest on-world ent.
		self.tag_index = -1;
		setsize(self, '0 0 0', '0 0 0');
	}
		
	if (self.target != "")
	{	//portals need to define their target entity
		entity c = spawn();
		entity t = find(world, targetname, self.target);
		
		c.origin = t.origin;
		c.skin = CONTENT_SOLID;
		c.tag_entity = self;
		c.tag_index = -1;
		c.angles = t.angles;
		setsize(self, '0 0 0', '0 0 0');
	}
};
void() spawnfunc_misc_portal_surface = {self.nextthink = time + 0.1; self.think = linkportalsurface;};	//placed within 64qu of the actual surface geometry. shows the targetted camera (or mirror if no target)
