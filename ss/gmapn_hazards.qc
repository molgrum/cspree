/*
	gmapn_hazards.qc

	Copyright (C) 2009 Andreas Nilsson

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
		Boston, MA	02111-1307, USA

*/

/**
 * @file gmapn_hazards.qc
 * @author Andreas Nilsson
 * @brief Projectiles and tracelines from weapons, traps and monsters.
 *
 * Hazards are seperated into functions and calls gmapn_impact or gmapn_explosion
 * for damage calculations. Invoking a hazard spawns the object (grenade, spike, etc)
 * and sets a touch method for missiles or a traceline for hitscans.
 */

#ifdef HAVE_PORTALS
void traceline_portal(vector start, vector end, float flags, entity ignore)
{
	traceline(start, end, flags, ignore);

	float portals = 4;
	while (trace_ent.solid == SOLID_PORTAL)
	{
		if (vlen(trace_endpos - start) > 64)	//if the trace travelled a decent length, allow the trace to hit the original ent. allowing you to shoot yourself in the back.
			ignore = world;

		//don't walk through too many portals
		if (portals-- == 0)
			return;

		//if our weapon hit a portal, transform the origins according to said zone
		portal wz = (portal)trace_ent;
		start = wz.origin_transform(trace_endpos);
		end = wz.origin_transform(end);
		traceline(start, end, FALSE|MOVE_LAGGED, ignore);
	}
};
#else
#define traceline_portal traceline
#endif

void SpawnBlood(vector org, vector vel, float count)
{
	particle (org, vel*0.1, 73, count*2);
};
void SpawnMeatSpray(vector org, vector vel)
{
	  entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';

// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);
};

/**
 * @brief Short distance with 64 units forward, either hit blood or clink.
 *
 */
void hazard_axehit(vector org, vector dir)
{
	float  damage;
	float  f;
	float  push;

	makevectors(self.v_angle);
	traceline(org, org + v_forward*64, FALSE|MOVE_LAGGED, self);

	if (trace_fraction != 1.0)
	{
		if (trace_ent.takedamage == DAMAGE_NOT)
		{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_GUNSHOT);
			WriteByte(MSG_MULTICAST, 3);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(trace_endpos, MULTICAST_PHS);
			gmapn_sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM, 0);
		}
		else
		{
			SpawnBlood(org, trace_plane_normal, 20);

			trace_ent.deathtype = DT_AXE;
			damage = getkey(axe_damage);

			if (trace_ent.classname == "player" && trace_ent.maxspeed == 0)
				push = getkey(axe_push_frozen);
			else
				push = getkey(axe_push);

			if (gmapn_serverstate == gmapn_serverstate_playing)
			{
				// Save stats during match

				f = gmapn_impact(trace_ent, self, damage, push);
				self.stats_hit[W_AXE] += f;
			}
			else
			{
				// Ignore stats during prewar

				gmapn_impact(trace_ent, self, damage, push);
			}

			gmapn_sound(self, CHAN_WEAPON, "player/axhit1.wav", 1, ATTN_NORM, 0);
		}
	}
};

/**
 * @brief Individual bullet firing.
 *
 * Sets the .dmg field in the entity that is hit, if any. This is used for calculating
 * damage for each entity that is hit and apply all at once.
 */
struct
{
	entity victim;
	float damage;
} bullethits[20];
int numbullethits;
void hazard_bullet(vector org, vector dir)
{
	/* float  damage; */
	/* float  f; */
	/* float  push; */

	dir = normalize(dir);
	traceline_portal(org, org + dir*2048, FALSE|MOVE_LAGGED, self);
	if (trace_fraction >= 1.0)
	{
		return;
	}

	// Hit!

	// FIXME: need to make this logic apply before the bullets make damage, triggers change to DAMAGE_NOT after the first bullet hit which causes the rest of the bullets to make gunshots instead of blood

	if (trace_ent.takedamage == DAMAGE_NOT)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, 2); // have to use 2 visible shots per bullet or clients think it's a nail hit
									 // i think spike said it: qw is weird
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		multicast(trace_endpos, MULTICAST_PHS);
	}
	else
	{
		float dmg = getkey(bullet_damage);
		for (int i = 0; i < numbullethits; i++)
		{
			if (bullethits[i].victim == trace_ent)
			{
				bullethits[i].damage += dmg;
				return;
			}
		}
		bullethits[numbullethits].victim = trace_ent;
		bullethits[numbullethits].damage = dmg;
		numbullethits++;
	}
	/* else if (trace_ent.takedamage) */
	/* { */
	/*	damage = getkey(bullet_damage); */
	/*	push = getkey(bullet_push); */

	/*	if (gmapn_serverstate == gmapn_serverstate_playing && self.weapon == IT_SHOTGUN) */
	/*	{ */
	/*		trace_ent.deathtype = DT_BULLET; */
	/*		f = gmapn_impact(trace_ent, self, damage, push); */
	/*		self.stats_hit[W_SG] += f; */
	/*	} */
	/*	else if (gmapn_serverstate == gmapn_serverstate_playing && self.weapon == IT_SUPER_SHOTGUN) */
	/*	{ */
	/*		trace_ent.deathtype = DT_SUPER_BULLET; */
	/*		f = gmapn_impact(trace_ent, self, damage, push); */
	/*		self.stats_hit[W_SSG] += f; */
	/*	} */
	/*	else */
	/*	{ */
	/*		trace_ent.deathtype = DT_BULLET; */
	/*		gmapn_impact(trace_ent, self, damage, push); */
	/*	} */
	/* } */
};

float shotgun_pattern[] =
{
	-1, 2,
	1, 2,
	2, 1,
	2, -1,
	1, -2,
	-1, -2,
	-2, -1,
	-2, 1
};

float supershotgun_pattern[] =
{
	// Inner pattern
	-1, 3,
	1, 3,
	3, 1,
	3, -1,
	1, -3,
	-1, -3,
	-3, -1,
	-3, 1,
	// Outer pattern
	-2, 5,
	2, 5,
	4, 4,
	5, 2,
	5, -2,
	4, -4,
	2, -5,
	-2, -5,
	-4, -4,
	-5, -2,
	-5, 2,
	-4, 4
};

/**
 * @brief Fires a pattern of bullets depending on type of weapon.
 *
 * Hardcoded patterns are used and all bullets individually fills up an entity
 * list which removes duplicates afterwards and applies the .dmg to every entity.
 */
void hazard_bullets(vector org, vector dir, string type)
{
	// FIXME: implement original quake bullet spread here
	float f, g, push, spread;

	push = getkey(bullet_push);
	if (type == "shotgun") {
		spread = getkey(shotgun_spread);
		numbullethits = 0;
		for (f = 0; f < shotgun_pattern.length/2; f++) {
			hazard_bullet(org, dir + v_right*shotgun_pattern[f*2]*spread + v_up*shotgun_pattern[f*2+1]*spread);
		}
		while (numbullethits --> 0)
		{
			g = gmapn_impact(bullethits[numbullethits].victim, self, bullethits[numbullethits].damage, push);
			if (gmapn_serverstate == gmapn_serverstate_playing)
			{
				self.stats_hit[W_SG] += g;
			}
		}
		/* dmg += hazard_bullet(org, dir + v_right*-1*spread + v_up*2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*1*spread	 + v_up*2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*2*spread	 + v_up*1*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*2*spread	 + v_up*-1*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*1*spread	 + v_up*-2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-1*spread + v_up*-2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-2*spread + v_up*-1*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-2*spread + v_up*1*spread); */
	}
	else if (type == "supershotgun") {
		spread = getkey(shotgun2_spread);
		numbullethits = 0;
		for (f = 0; f < supershotgun_pattern.length/2; f++) {
			hazard_bullet(org, dir + v_right*supershotgun_pattern[f*2]*spread + v_up*supershotgun_pattern[f*2+1]*spread);
		}
		while (numbullethits --> 0)
		{
			g = gmapn_impact(bullethits[numbullethits].victim, self, bullethits[numbullethits].damage, push);
			if (gmapn_serverstate == gmapn_serverstate_playing) {
				self.stats_hit[W_SSG] += g;
			}
		}
		/* // Inner pattern */
		/* dmg += hazard_bullet(org, dir + v_right*-1*spread + v_up*3*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*1*spread + v_up*3*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*3*spread + v_up*1*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*3*spread + v_up*-1*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*1*spread + v_up*-3*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-1*spread + v_up*-3*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-3*spread + v_up*-1*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-3*spread + v_up*1*spread); */

		/* // Outer pattern */
		/* dmg += hazard_bullet(org, dir + v_right*-2*spread + v_up*5*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*2*spread + v_up*5*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*4*spread + v_up*4*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*5*spread + v_up*2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*5*spread + v_up*-2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*4*spread + v_up*-4*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*2*spread + v_up*-5*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-2*spread + v_up*-5*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-4*spread + v_up*-4*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-5*spread + v_up*-2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-5*spread + v_up*2*spread); */
		/* dmg += hazard_bullet(org, dir + v_right*-4*spread + v_up*4*spread); */
	}

};

void hazard_coilgun(vector org, vector dir)
{
	float  damage;
	float  f;
	float  push;

	dir = normalize(dir);
	traceline_portal(org, org + dir*2048, FALSE|MOVE_LAGGED, self);
	if (trace_fraction >= 1.0)
	{
		return;
	}

	// Hit!

	if (trace_ent.takedamage == DAMAGE_NOT)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, 2); // 2 to not show nail shot
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		multicast(trace_endpos, MULTICAST_PHS);
	}
	else if (trace_ent.takedamage)
	{
		damage = 100000000;
		push = 0;

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			trace_ent.deathtype = DT_COILGUN;
			f = gmapn_impact(trace_ent, self, damage, push);
			self.stats_hit[W_CG] += f>0;
		}
		else
		{

			gmapn_impact(trace_ent, self, damage, push);
		}
	}
};
/*
void hazard_spike_touch()
{
	entity attacker;
	float  damage;
	float  f;
	float  push;

	attacker = self.owner;

	if (other == attacker)
	{
		return;
	}

	if (other.takedamage == DAMAGE_NOT)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_SPIKE);
		WriteCoord(MSG_MULTICAST, self.origin_x);
		WriteCoord(MSG_MULTICAST, self.origin_y);
		WriteCoord(MSG_MULTICAST, self.origin_z);
		multicast(self.origin, MULTICAST_PHS);
	}
	else if (other.takedamage)
	{
		other.deathtype = DT_NAIL;
		damage = getkey(spike_damage);
		push = getkey(spike_push);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			// Save stats during match

			f = gmapn_impact(other, self, damage, push);
			attacker.stats_hit[W_NG] += f;
		}
		else
		{
			// Ignore stats during prewar

			gmapn_impact(other, self, damage, push);
		}
	}

	remove(self);
};

void hazard_spike(vector org, vector dir, float vel)
{
	newmis = spawn(); // Create a spike entity
	newmis.angles = vectoangles(dir);
	newmis.classname = "spike";
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.touch = hazard_spike_touch;
	newmis.velocity = dir * vel;

	if (self.items & IT_QUAD == IT_QUAD)
	{
		newmis.effects = newmis.effects | EF_BLUE;
		newmis.items = newmis.items | IT_QUAD;
	}

	setorigin(newmis, org);
	setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	if (!(self.flags & FL_MONSTER))
	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	// Only write this if a client fired the spike

	if (self.flags & FL_CLIENT)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SMALLKICK);
	}
};

void hazard_spike2_touch()
{
	entity attacker;
	float  damage;
	float  f;
	float  push;

	attacker = self.owner;

	if (other == attacker)
	{
		return;
	}

	if (other.takedamage == DAMAGE_NOT)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_SUPERSPIKE);
		WriteCoord(MSG_MULTICAST, self.origin_x);
		WriteCoord(MSG_MULTICAST, self.origin_y);
		WriteCoord(MSG_MULTICAST, self.origin_z);
		multicast(self.origin, MULTICAST_PHS);
	}
	else
	{
		other.deathtype = DT_SUPER_NAIL;
		damage = getkey(spike2_damage);
		push = getkey(spike2_push);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			// Save stats during match

			f = gmapn_impact(other, self, damage, push);
			attacker.stats_hit[W_SNG] += f;
		}
		else
		{
			// Ignore stats during prewar

			gmapn_impact(other, self, damage, push);
		}
	}

	remove(self);
};

void hazard_spike2(vector org, vector dir, float vel)
{
	newmis = spawn(); // Create a spike entity
	newmis.angles = vectoangles(dir);
	newmis.classname = "superspike";
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.touch = hazard_spike2_touch;
	newmis.velocity = dir * vel;

	if (self.items & IT_QUAD == IT_QUAD)
	{
		newmis.effects = newmis.effects | EF_BLUE;
		newmis.items = newmis.items | IT_QUAD;
	}

	setorigin(newmis, org);
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

	// Only write this if a client fired the spike

	if (self.flags & FL_CLIENT)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SMALLKICK);
	}
};
*/
void hazard_grenade_explode()
{
	entity attacker;
	float  damage;
	float  f;
	float  push;

	attacker = self.owner;

	// Explosion

	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord(MSG_MULTICAST, self.origin_x);
	WriteCoord(MSG_MULTICAST, self.origin_y);
	WriteCoord(MSG_MULTICAST, self.origin_z);
	multicast(self.origin, MULTICAST_PHS);

	damage = getkey(grenade_damage);
	push = getkey(grenade_push);

	if (deathmatch == 4)
	{
		damage /= 2;
		push *= 2;
	}

	if (other != world)
	{
		// The grenade hit something, it gets impact damage instead

		other.deathtype = DT_GRENADE;

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			// Save stats during match

			f = gmapn_impact(other, self, damage, push);
			attacker.stats_hit[W_GL] += f;
		}
		else
		{
			// Ignore stats during prewar

			gmapn_impact(other, self, damage, push);
		}
	}

	// Explosion damage on everything besides what the grenade might have hit

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		// Save stats during match

		f = gmapn_explosion(self, damage, push, other, DT_GRENADE);
		attacker.stats_hit[W_GL] += f;
	}
	else
	{
		// Ignore stats during prewar

		gmapn_explosion(self, damage, push, other, DT_GRENADE);
	}

	remove(self);
};

void hazard_grenade_touch()
{
	if (other == self.owner)
	{
		return;			// don't explode on owner
	}

	if (other.takedamage == DAMAGE_BLEED)
	{
		hazard_grenade_explode();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
};

void hazard_grenade(vector org, vector dir, float vel)
{
	makevectors(self.v_angle);
	newmis = spawn();
	setmodel(newmis, "progs/grenade.mdl");

	newmis.angles = vectoangles(dir);
	newmis.classname = "grenade";
	newmis.flags = FL_LAGGEDMOVE;
	newmis.nextthink = time + 2.5;
	newmis.owner = self;
	newmis.think = hazard_grenade_explode;
	newmis.touch = hazard_grenade_touch;
	newmis.velocity = v_forward * vel;

	// FIXME: this was for ODE physics
	//newmis.mass = 10;
	//newmis.movetype = MOVETYPE_PHYSICS;
	//newmis.solid = SOLID_PHYSICS_SPHERE;
	//setsize(newmis, '-4 -4 -4', '4 4 4');

	// ...and this is for default physics
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);

	if (self.items & IT_QUAD == IT_QUAD)
	{
		newmis.effects = newmis.effects | EF_BLUE;
		newmis.items = newmis.items | IT_QUAD;
	}

	// Selectable grenade aim type
	if (getkey(grenade_aim_new) == 0)
	{
		setorigin(newmis, org - '0 0 8');
		newmis.velocity = newmis.velocity + v_up*200;
	}
	else
	{
		setorigin(newmis, org);
		newmis.velocity_z = newmis.velocity_z + 200;
	}

	// Add a small random kickoff to the grenade
	if (getkey(grenade_aim_norandom) == 0)
	{
		newmis.velocity = newmis.velocity + v_right*crandom()*10;
		newmis.velocity = newmis.velocity + v_up*crandom()*10;
	}

	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_SMALLKICK);
	gmapn_sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM, 0);
};
/*
void hazard_rocket_touch()
{
	entity attacker;
	float  damage;
	float  f;
	float  push;

	attacker = self.owner;

	// Explosion
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord(MSG_MULTICAST, self.origin_x);
	WriteCoord(MSG_MULTICAST, self.origin_y);
	WriteCoord(MSG_MULTICAST, self.origin_z);
	multicast(self.origin, MULTICAST_PHS);

	damage = getkey(rocket_damage);
	push = getkey(rocket_push);

	if (other != world)
	{
		// The rocket hit something, it gets impact damage instead
		other.deathtype = DT_ROCKET;

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			// Save stats during match

			f = gmapn_impact(other, self, damage, push);
			attacker.stats_hit[W_RL] += f;
		}
		else
		{
			// Ignore stats during prewar
			gmapn_impact(other, self, damage, push);
		}
	}

	// Rocket explosions damage more than the impact in original QW

	damage += 10;

	// Explosion damage on everything besides what the rocket might have hit

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		// Save stats during match

		f = gmapn_explosion(self, damage, push, other, DT_ROCKET);
		attacker.stats_hit[W_RL] += f;
	}
	else
	{
		// Ignore stats during prewar
		gmapn_explosion(self, damage, push, other, DT_ROCKET);
	}

	remove(self);
};

void hazard_rocket(vector org, vector dir, float vel)
{
	newmis = spawn();
	newmis.angles = vectoangles(dir);
	newmis.classname = "rocket";
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.touch = hazard_rocket_touch;
	newmis.velocity = dir * vel;

	if (self.items & IT_QUAD == IT_QUAD)
	{
		newmis.effects = newmis.effects | EF_BLUE;
		newmis.items = newmis.items | IT_QUAD;
	}

	setorigin(newmis, self.origin + '0 0 16');
	setmodel(newmis, "progs/missile.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
};
*/

/**
 * @brief LG and e1m7 lightning hazards.
 *
 */
void hazard_lightning(vector org, vector dir)
{
	float  damage;
	float  f;
	float  push;
	float portals = 3;
	float isshambler = self.classname == "monster_shambler";


	if (isshambler)
	{
		damage = 10;
	}
	else
	{
		damage = getkey(lightning_damage);
		push = getkey(lightning_push);
	}

	traceline(org, dir, FALSE|MOVE_LAGGED, self);

	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, isshambler?TE_LIGHTNING1:TE_LIGHTNING2);
	WriteEntity(MSG_MULTICAST, self);
	WriteCoord(MSG_MULTICAST, org_x);
	WriteCoord(MSG_MULTICAST, org_y);
	WriteCoord(MSG_MULTICAST, org_z);
	WriteCoord(MSG_MULTICAST, trace_endpos_x);
	WriteCoord(MSG_MULTICAST, trace_endpos_y);
	WriteCoord(MSG_MULTICAST, trace_endpos_z);
	multicast(org, MULTICAST_PHS);

#ifdef HAVE_PORTALS
	while (trace_ent.solid == SOLID_PORTAL)
	{
		//don't walk through too many portals
		if (portals-- == 0)
			return;

		//if our weapon hit a portal, transform the origins according to said zone
		portal wz = (portal)trace_ent;
		org = wz.origin_transform(trace_endpos);
		dir = wz.origin_transform(dir);
		traceline(org, dir, FALSE, self);

		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, isshambler?TE_LIGHTNING1:TE_LIGHTNING2);
		WriteEntity(MSG_MULTICAST, world);
		WriteCoord(MSG_MULTICAST, org_x);
		WriteCoord(MSG_MULTICAST, org_y);
		WriteCoord(MSG_MULTICAST, org_z);
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		multicast(org, MULTICAST_PHS);
	}
#endif

	if (trace_ent.takedamage)
	{
		if (trace_ent.takedamage == DAMAGE_BLEED)
		{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_LIGHTNINGBLOOD);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(trace_endpos, MULTICAST_PHS);
			trace_ent.deathtype = DT_BOLT;

			if (gmapn_serverstate == gmapn_serverstate_playing)
			{
				// Save stats during match

				f = gmapn_impact(trace_ent, self, damage, push);
				self.stats_hit[W_LG] += f;
			}
			else
			{
				// Ignore stats during prewar

				gmapn_impact(trace_ent, self, damage, push);
			}
		}
		else
		{
			gmapn_impact(trace_ent, self, damage, push);
		}

		// QW standard behaviour, this is to emulate the bug where you typically stand on the hatch
		// on dm6 and fire LG, it causes the hatch to move upwards slightly

		if (autocvar(g_buggylightning, 1, "Replicate the old floating pushers bug"))
		if (trace_ent == self.groundentity && trace_ent.movetype == MOVETYPE_PUSH && trace_ent.nextthink && trace_ent.think == calcmove_done)
		{
			trace_ent.velocity_z += 400;
		}
	}

	if (time > self.beam_finished)
	{
		gmapn_sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM, 0);
		self.beam_finished = time + 0.6;
	}
};

void hazard_railgun(vector org, vector dir)
{
	float  damage;
	float  f;
	float  push;
	float portals = 3;

	traceline(org, dir, TRUE, self);

	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_LIGHTNING2);
	WriteShort(MSG_MULTICAST, -num_for_edict(self));
	WriteCoord(MSG_MULTICAST, org_x);
	WriteCoord(MSG_MULTICAST, org_y);
	WriteCoord(MSG_MULTICAST, org_z);
	WriteCoord(MSG_MULTICAST, trace_endpos_x);
	WriteCoord(MSG_MULTICAST, trace_endpos_y);
	WriteCoord(MSG_MULTICAST, trace_endpos_z);
	multicast(org, MULTICAST_PHS);

#if 0//def HAVE_PORTALS
	while (trace_ent.solid == SOLID_PORTAL)
	{
		//don't walk through too many portals
		if (portals-- == 0)
			return;

		//if our weapon hit a portal, transform the origins according to said zone
		func_warpzone wz = (func_warpzone)trace_ent;
		org = wz.origin_transform(trace_endpos);
		traceline(org, wz.origin_transform(dir), FALSE, self);

		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_LIGHTNING2);
		WriteEntity(MSG_MULTICAST, world);
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		WriteCoord(MSG_MULTICAST, org_x);
		WriteCoord(MSG_MULTICAST, org_y);
		WriteCoord(MSG_MULTICAST, org_z);
		multicast(org, MULTICAST_PHS);
	}
#endif

	damage = getkey(rail_damage);
	push = getkey(rail_push);

	traceline(org,	trace_endpos, MOVE_ENTCHAIN|MOVE_LAGGED, self);
	for (; trace_ent; trace_ent = trace_ent.chain)
	{
		if (trace_ent.takedamage)
		{
			if (trace_ent.takedamage == DAMAGE_BLEED)
			{
				trace_ent.deathtype = DT_RAILGUN;

				if (gmapn_serverstate == gmapn_serverstate_playing)
				{
					// Save stats during match

					f = gmapn_impact(trace_ent, self, damage, push);
					self.stats_hit[W_RG] += f;
				}
				else
				{
					// Ignore stats during prewar

					gmapn_impact(trace_ent, self, damage, push);
				}
			}
			else
			{
				gmapn_impact(trace_ent, self, damage, push);
			}
		}
	}

	if (time > self.beam_finished)
	{
		gmapn_sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM, 0);
		self.beam_finished = time + 0.6;
	}
};

void hazard_laser_touch()
{
	entity attacker;
	float  damage;
	float  push;

	attacker = self.owner;

	if (other == attacker)
	{
		return;
	}

	if (other.takedamage == DAMAGE_NOT)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_LIGHTNINGBLOOD);
		WriteCoord(MSG_MULTICAST, self.origin_x);
		WriteCoord(MSG_MULTICAST, self.origin_y);
		WriteCoord(MSG_MULTICAST, self.origin_z);
		multicast(self.origin, MULTICAST_PHS);
	}
	else if (other.takedamage)
	{
		other.deathtype = DT_LASER;
		damage = getkey(laser_damage);
		push = getkey(laser_push);

		gmapn_impact(other, self, damage, push);
	}

	gmapn_sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC, 0);

	remove(self);
};

void hazard_laser(vector org, vector dir, float vel)
{
	newmis = spawn();
	newmis.angles = vectoangles(dir);
	newmis.classname = "laser";
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.touch = hazard_laser_touch;
	newmis.velocity = dir * vel;

	setorigin(newmis, org);
	setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);

	gmapn_sound(newmis, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM, 0);
};

void hazard_discharge()
{
	float  damage;
	float  push;

	if (time < self.beam_finished)
	{
		return;
	}

	self.deathtype = DT_DISCHARGE;
	damage = self.ammo_cells * getkey(lightning_damage);
	push = getkey(lightning_push);

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		self.ammo_cells = 0;
	}

	gmapn_explosion(self, damage, push, world, self.deathtype);

	gmapn_sound(self, CHAN_WEAPON, "misc/power.wav", 1, ATTN_NORM, 0);
	self.beam_finished = time + 0.6;
};

void hazard_missile_touch()
{
	entity attacker;
	float  damage;
	float  f;
	float  push;

	attacker = self.owner;

	if (other == attacker)
	{
		return;
	}

	if (other.takedamage == DAMAGE_NOT || self.classname == "rocket")
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		if (self.classname == "spike") {
			WriteByte(MSG_MULTICAST, TE_SPIKE);
		}
		else if (self.classname == "superspike") {
			WriteByte(MSG_MULTICAST, TE_SUPERSPIKE);
		}
		else if (self.classname == "wizspike") {
			WriteByte(MSG_MULTICAST, TE_WIZSPIKE);
		}
		else if (self.classname == "knightspike") {
			WriteByte(MSG_MULTICAST, TE_KNIGHTSPIKE);
		}
		else if (self.classname == "rocket") {
			WriteByte(MSG_MULTICAST, TE_EXPLOSION);
		}
		WriteCoord(MSG_MULTICAST, self.origin_x);
		WriteCoord(MSG_MULTICAST, self.origin_y);
		WriteCoord(MSG_MULTICAST, self.origin_z);
		multicast(self.origin, MULTICAST_PHS);
	}

	if (self.classname == "spike") {
		if (other != world) {
			other.deathtype = DT_NAIL;
		}
		damage = getkey(spike_damage);
		push = getkey(spike_push);
	}
	else if (self.classname == "superspike") {
		if (other != world) {
			other.deathtype = DT_SUPER_NAIL;
		}
		damage = getkey(spike2_damage);
		push = getkey(spike2_push);
	}
	else if (self.classname == "rocket") {
		if (other != world) {
			other.deathtype = DT_ROCKET;
		}
		damage = getkey(rocket_damage);
		push = getkey(rocket_push);
	}
	else if (self.classname == "wizspike") {
		if (other != world) {
			other.deathtype = DT_MONSTER;
		}
		damage = 9;
		push = 1;
	}
	else if (self.classname == "knightspike") {
		if (other != world) {
			other.deathtype = DT_MONSTER;
		}
		damage = 9;
		push = 1;
	}
	else {
		// unknown missile type, use some default values
		other.deathtype = DT_NULL;
		damage = 0;
		push = 0;
	}

	f = gmapn_impact(other, self, damage, push);

	if (self.classname == "rocket") {
		//damage += 10; // modifier for original QW behaviour
		f += gmapn_explosion(self, damage, push, other, DT_ROCKET);
	}

	if (other != world && gmapn_serverstate == gmapn_serverstate_playing)
	{
		// Save stats during match

		attacker.stats_hit[W_SNG] += f;
	}

	remove(self);

}

/**
 * @brief Unified function for NG, SNG and RL.
 */
void hazard_missile(vector org, vector dir, float vel, string type)
{
	newmis = spawn(); // Create a spike entity
	newmis.angles = vectoangles(dir);
	newmis.classname = type;
	newmis.flags = FL_LAGGEDMOVE;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.touch = hazard_missile_touch;
	newmis.velocity = dir * vel;

	if (self.items & IT_QUAD == IT_QUAD)
	{
		newmis.effects = newmis.effects | EF_BLUE;
		newmis.items = newmis.items | IT_QUAD;
	}

	setorigin(newmis, org);

	if (newmis.classname == "spike") {
		setmodel(newmis, "progs/spike.mdl");
		gmapn_sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM, 0);
	}
	else if (newmis.classname == "superspike") {
		setmodel(newmis, "progs/s_spike.mdl");
		gmapn_sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM, 0);
	}
	else if (newmis.classname == "rocket") {
		setmodel(newmis, "progs/missile.mdl");
		gmapn_sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM, 0);
	}

	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);

	// Only write this if a client fired the spike

	if (self.flags & FL_CLIENT)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SMALLKICK);
	}
};
