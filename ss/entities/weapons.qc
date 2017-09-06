/*
	weapons.qc

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

void weapon_touch()
{
	float w_switch = stof(infokey(other, "w_switch"));

	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		return;				// Only live players can pickup weapons and only in a game
	}

	if ((other.items & self.items) == self.items)
	{
		return;				// Already have the weapon so don't pickup
	}

	// Add ammo from the weapon
	ammo_add();

	entity oself = self;
	float w = self.weapon;
	self = other;
	//float bestwep = client_bestweapon();
	float bestwep = self.weapon; // why do a bestweapon check here?
	self = oself;

	if (deathmatch == 2)
	{
		item_pickup(getkey(respawn_weapon_dmm2), "0x302030");	 // Hide and wait for respawn
	}
	else
	{
		item_pickup(getkey(respawn_weapon_dmm1), "0x302030");	 // Hide and wait for respawn
	}

	self = other;
	switchweapon(bestwep, w, w_switch);
	self = oself;
};

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// weapon_supershotgun
//
//
//
//======================================================================
void weapon_supershotgun()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_shot.mdl";		// Two-piped shotgun
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Super Shotgun";			// Name of the object
	self.weapon = IT_SUPER_SHOTGUN;			// Type of weapon
	self.items = IT_SUPER_SHOTGUN;			// Items stored
	self.ammo_shells = 10;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};

//======================================================================
// weapon_nailgun
//
//
//
//======================================================================
void weapon_nailgun()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_nail.mdl";		// Two-piped nailgun
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Nailgun";			// Name of the object
	self.weapon = IT_NAILGUN;			// Type of weapon
	self.items = IT_NAILGUN;			// Items stored
	self.ammo_nails = 30;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};

//======================================================================
// weapon_supernailgun
//
//
//
//======================================================================
void weapon_supernailgun()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_nail2.mdl";		// Four-piped nailgun
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Super Nailgun";			// Name of the object
	self.weapon = IT_SUPER_NAILGUN;			// Type of weapon
	self.items = IT_SUPER_NAILGUN;			// Items stored
	self.ammo_nails = 30;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};

//======================================================================
// weapon_grenadelauncher
//
//
//
//======================================================================
void weapon_grenadelauncher()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_rock.mdl";		// Grenade launcher
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Grenade Launcher";		// Name of the object
	self.weapon = IT_GRENADE_LAUNCHER;		// Type of weapon
	self.items = IT_GRENADE_LAUNCHER;		// Items stored
	self.ammo_rockets = 5;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};

//======================================================================
// weapon_rocketlauncher
//
//
//
//======================================================================
void weapon_rocketlauncher()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_rock2.mdl";		// Rocket launcher
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Rocket Launcher";		// Name of the object
	self.weapon = IT_ROCKET_LAUNCHER;		// Type of weapon
	self.items = IT_ROCKET_LAUNCHER;		// Items stored
	self.ammo_rockets = 5;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};

//======================================================================
// weapon_lightning
//
//
//
//======================================================================
void weapon_lightning()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_light.mdl";		// Lightning gun
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Lightning Gun";			// Name of the object
	self.weapon = IT_LIGHTNING_GUN;			// Type of weapon
	self.items = IT_LIGHTNING_GUN; // Items stored
	self.ammo_cells = 15;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};

//======================================================================
// weapon_railgun
//
//
//
//======================================================================
void weapon_railgun()
{
	self.channel = CHAN_ITEM;
	self.attenuation = ATTN_NORM;
	self.model = "progs/g_railgun.mdl";		// Lightning gun
	self.noise = "weapons/pkup.wav";		// Weapon picked up
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.netname = "Rail Gun";			// Name of the object
	self.weapon = IT_RAILGUN;			// Type of weapon
	self.items = IT_RAILGUN;			// Items stored
	self.ammo_cells = 15;				// Ammo stored
	self.touch = weapon_touch;			// Function to call if touched
	self.modelflags = MF_ROTATE;

	setitem();
};
