/*
    keys.qc

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
        Boston, MA  02111-1307, USA

*/
void key_touch()
{
	if (!coop || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		return;				// Only players can pickup ammo and only in a game
	}
	
	if (other.items & self.items)
		return;

	if (coop)
	{
		//keys have infinite uses in coop. and if they don't, maps will just have to use killtargets. that's a standard quake thing.
		//we'll add a little respawn timer to it, just because we can.
		global_items |= self.items;

		for(entity e = world; (e = find(e, classname, "player")); )
			e.items |= self.items;
	}
	else
		other.items |= self.items;

	item_pickup(5, "0x202020");
};

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// item_key1
//
//
//
//======================================================================
void item_key1()
{
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.maxsize = '16 16 32';
	self.minsize = '-16 -16 -24';
	self.time_respawn = 0;				// Special respawn
	self.items = IT_KEY1;				// Items stored
	self.touch = key_touch;				// Function to call if touched

	if (world.worldtype == 0)
	{
		// Medieval worldtype
		self.model = "progs/w_s_key.mdl";	// Silver medieval key
		self.noise = "misc/medkey.wav";		// Medieval key picked up
		self.netname = "silver key";		// Name of the object
	}
	else if (world.worldtype == 1)
	{
		// Rune worldtype
		self.model = "progs/m_s_key.mdl";	// Silver rune key
		self.noise = "misc/runekey.wav";	// Rune key picked up
		self.netname = "silver runekey";	// Name of the object
	}
	else if (world.worldtype == 2)
	{
		// Base worldtype
		self.model = "progs/b_s_key.mdl";	// Silver base key
		self.noise = "misc/basekey.wav";	// Base key picked up
		self.netname = "silver keycard";	// Name of the object
	}

	setitem();
};

//======================================================================
// item_key2
//
//
//
//======================================================================
void item_key2()
{
	self.time_respawn = 0;				// Special respawn
	self.items = IT_KEY2;				// Items stored
	self.maxsize = '16 16 32';
	self.minsize = '-16 -16 -24';
	self.touch = key_touch;			// Function to call if touched

	if (world.worldtype == 0)
	{
		// Medieval worldtype
		self.model = "progs/w_g_key.mdl";	// Gold medieval key
		self.noise = "misc/medkey.wav";		// Medieval key picked up
		self.netname = "gold key";		// Name of the object
	}
	else if (world.worldtype == 1)
	{
		// Rune worldtype
		self.model = "progs/m_g_key.mdl";	// Gold rune key
		self.noise = "misc/runekey.wav";	// Rune key picked up
		self.netname = "gold runekey";		// Name of the object
	}
	else if (world.worldtype == 2)
	{
		// Base worldtype
		self.model = "progs/b_g_key.mdl";	// Gold base key
		self.noise = "misc/basekey.wav";	// Base key picked up
		self.netname = "gold keycard";		// Name of the object
	}

	setitem();
};

