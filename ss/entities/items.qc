/*
	items.qc

	Copyright (C) 1996-1997	 Id Software, Inc.
	Copyright (C) 2009		 Andreas Nilsson

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

void item_respawn()
{
	// Reset the model to the same as before
	self.model = self.mdl;

	// Able to trigger this again now when it is visible
	self.solid = SOLID_TRIGGER;

	// Play respawn sound
	gmapn_sound(self, CHAN_VOICE, "items/itembk2.wav", 1, self.attenuation, 0);
};

void item_respawn_all()
{
	entity e, stemp;
	string str;

	stemp = self;

	str = "item_armor1";

	while (str != string_null)
	{
		e = find(world, classname, str);
		while (e)
		{
			self = e;
			if (self.model == string_null)
			{
				item_respawn();
				self.nextthink = 0;
			}
			self = stemp;
			e = find(e, classname, str);
		}
		if (str == "item_armor1")
		{
			str = "item_armor2";
		}
		else if (str == "item_armor2")
		{
			str = "item_armorInv";
		}
		else if (str == "item_armorInv")
		{
			if (getkey(powerups_enabled) == 0)
			{
				// Powerups disabled, then skip their respawn steps
				str = "item_cells";
			}
			else
			{
				str = "item_artifact_envirosuit";
			}
		}
		else if (str == "item_artifact_envirosuit")
		{
			str = "item_artifact_invisibility";
		}
		else if (str == "item_artifact_invisibility")
		{
			str = "item_artifact_invulnerability";
		}
		else if (str == "item_artifact_invulnerability")
		{
			str = "item_artifact_super_damage";
		}
		else if (str == "item_artifact_super_damage")
		{
			str = "item_cells";
		}
		else if (str == "item_cells")
		{
			str = "item_health";
		}
		else if (str == "item_health")
		{
			str = "item_rockets";
		}
		else if (str == "item_rockets")
		{
			str = "item_shells";
		}
		else if (str == "item_shells")
		{
			str = "item_spikes";
		}
		else if (str == "item_spikes")
		{
			str = "item_weapon";
		}
		else if (str == "item_weapon")
		{
			str = "weapon_grenadelauncher";
		}
		else if (str == "weapon_grenadelauncher")
		{
			str = "weapon_lightning";
		}
		else if (str == "weapon_lightning")
		{
			str = "weapon_nailgun";
		}
		else if (str == "weapon_nailgun")
		{
			str = "weapon_rocketlauncher";
		}
		else if (str == "weapon_rocketlauncher")
		{
			str = "weapon_supernailgun";
		}
		else if (str == "weapon_supernailgun")
		{
			str = "weapon_supershotgun";
		}
		else if (str == "weapon_supershotgun")
		{
			str = string_null;
		}
	}

};

void item_pickup(float respawn_time, string tint)
{
	string str;
	string w;
	string a;

	if (gmapn_serverstate != gmapn_serverstate_playing)
		return;

	if (coop)	//FIXME: is this condition correct?
	{
		usetargets();
		respawn_time = -1;

		if (self.weapon)
		{	//if its a weapon, give it to everyone, in the interests of fairness and less annoyance.
			for (entity e = world; (e = find(e, classname, "player")); )
				e.items |= self.items;
			global_items |= self.items;	//so its given to respawners too.
		}
	}

	if (deathmatch != 3 || !self.weapon)
	{
		// Hide the item by setting the model to nothing
		self.model = string_null;

		// Don't trigger again while not visible
		self.solid = SOLID_NOT;

		// Set respawn delay function
		if (respawn_time > 0)
		{
			// Respawn time
			self.nextthink = time + respawn_time;

			// Then call this function
			self.think = item_respawn;
		}

		if (respawn_time >= 0 && getkey(game_itemtimers) && tint != "")
		{	//note: megahealth sends a timer of 0. the client interprets this special value as infinity.
			//args are: timeout,x,y,z,radius=32,rgb=202020,name="",ent=0(unk)

			stuffcmdflags(other, STUFFCMD_BROADCAST, sprintf("//it %g %g %g %g 32 %s\n", respawn_time, rint((self.absmin_x + self.absmax_x)*0.5), rint((self.absmin_y + self.absmax_y)*0.5), rint(self.origin_z + self.mins_z), tint));
		}
	}

	// Print pickup message
	if (self.health)
	{
		sprint(other, PRINT_LOW, "You received ");
		str = ftos(self.health);
		sprint(other, PRINT_LOW, str);
		sprint(other, PRINT_LOW, " ");
		sprint(other, PRINT_LOW, self.netname);
	}
	else
	{
		sprint(other, PRINT_LOW, "You got");
		if (self.netname)
			w = strcat(" the ", self.netname);
	}
	if (self.ammo_shells)
		a = strcat(a, a?", ":" ", ftos(self.ammo_shells), " shells");
	if (self.ammo_nails)
		a = strcat(a, a?", ":" ", ftos(self.ammo_nails), " nails");
	if (self.ammo_rockets)
		a = strcat(a, a?", ":" ", ftos(self.ammo_rockets), " rockets");
	if (self.ammo_cells)
		a = strcat(a, a?", ":" ", ftos(self.ammo_cells), " cells");
	if (self.ammo_heads)
		a = strcat(a, a?", ":" ", ftos(self.ammo_heads), " heads");
	if (w && a)
		a = strcat(" with", a);
	sprint(other, PRINT_LOW, w, a, "\n");

	if (self.ammo_heads)	//we currently have no other way to display this.
	{
		sprint(other, PRINT_MEDIUM, "You now have ", ftos(other.ammo_heads), " heads\n");
		showpic("hc", sprintf("gfx/num_%g", bound(0, other.ammo_heads, 9)), 0, 0, 0, other);
	}

	// Add any items held by us to the player items
	other.items = other.items | self.items;

	// Add effects that items may hold
	other.effects = other.effects | self.effects;

	// Display bonus flash
	stuffcmd(other, "bf\n");

	gmapn_sound(other, self.channel, self.noise, 1, self.attenuation, 0);

	// A negative respawn time causes the item to never spawn again
	if (respawn_time < 0)
	{
		remove(self);
	}
};

void setitem(float nodrop = FALSE)
{
	vector localcenter;
	vector offset;

	// This is an item
	self.flags = FL_ITEM;

	// Backup model string for making items invisible (pickups, toggles)
	self.mdl = self.model;

	// Can be touched and walked through
	self.solid = SOLID_TRIGGER;

	// Placeholder movetype until its safe
	self.movetype = MOVETYPE_NONE;

	// No speed
	self.velocity = '0 0 0';

	// Precache since it is now needed
	precache_model(self.model);

	// Precache since it is now needed
	precache_sound(self.noise);

	// Set the model
	setmodel(self, self.model);

	// Size calculation

	//
	// Code by LordHavoc
	//
	if (getkey(entities_rotatefix) != 0 && self.angles != '0 0 0')
	{
		// Rotate touchfield

		makevectors(self.angles);
		localcenter = (self.minsize + self.maxsize) * 0.5;
		offset = localcenter_x * v_forward -
			 localcenter_y * v_right +
			 localcenter_z * v_up -
			 localcenter;

		self.maxsize = self.maxsize + offset;
		self.minsize = self.minsize + offset;
	}

	setsize(self, self.minsize, self.maxsize);

	if (!nodrop)
	{
		// Items wait 200 ms before calling droptofloor
		self.nextthink = self.ltime + 0.2;
		self.think = item_drop;
	}
};







//======================================================================
// sigils
//
//
//
//======================================================================
void item_sigil()
{
	if (self.spawnflags & SV_EPISODE4)
		self.model = "progs/end4.mdl";
	else if (self.spawnflags & SV_EPISODE3)
		self.model = "progs/end3.mdl";
	else if (self.spawnflags & SV_EPISODE2)
		self.model = "progs/end2.mdl";
	else// if (self.spawnflags & SV_EPISODE1)
		self.model = "progs/end1.mdl";

	self.noise = "misc/runekey.wav";
	self.netname = "rune!";	//because, like, awesome man!

	self.touch = (void())
	{
		if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
			return;
		if (coop)
			centerprint (other, "You got the rune!");
		serverflags |= self.spawnflags & (SV_EPISODE1|SV_EPISODE2|SV_EPISODE3|SV_EPISODE4);
		for (entity p = world; (p = find(p, classname, "player")); )
		{	//and items2 is used INSTEAD of serverflags if its defined. *sigh*
			p.items2 |= (serverflags & (SV_EPISODE1|SV_EPISODE2|SV_EPISODE3|SV_EPISODE4)) * 32;
		}
		item_pickup(-1, "0x202020");
	};
	setitem();
};
