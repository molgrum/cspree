/*
    ammo.qc

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

float ammo_add()
{
	float flag;			// To report if we have added any ammo or not

	flag = FALSE;				// No ammo added yet

	if (self.ammo_shells && other.ammo_shells < other.max_ammo_shells)
	{
		// Add shells
		other.ammo_shells = other.ammo_shells + self.ammo_shells;
		if (other.ammo_shells > other.max_ammo_shells)
		{
			// Ammo has exceeded the maximum, fix it
			other.ammo_shells = other.max_ammo_shells;
		}
		flag = TRUE;			// Ammo has been added
	}

	if (self.ammo_nails && other.ammo_nails < other.max_ammo_nails)
	{
		// Add shells
		other.ammo_nails = other.ammo_nails + self.ammo_nails;
		if (other.ammo_nails > other.max_ammo_nails)
		{
			// Ammo has exceeded the maximum, fix it
			other.ammo_nails = other.max_ammo_nails;
		}
		flag = TRUE;			// Ammo has been added
	}

	if (self.ammo_rockets && other.ammo_rockets < other.max_ammo_rockets)
	{
		// Add shells
		other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
		if (other.ammo_rockets > other.max_ammo_rockets)
		{
			// Ammo has exceeded the maximum, fix it
			other.ammo_rockets = other.max_ammo_rockets;
		}
		flag = TRUE;			// Ammo has been added
	}

	if (self.ammo_cells && other.ammo_cells < other.max_ammo_cells)
	{
		// Add shells
		other.ammo_cells = other.ammo_cells + self.ammo_cells;
		if (other.ammo_cells > other.max_ammo_cells)
		{
			// Ammo has exceeded the maximum, fix it
			other.ammo_cells = other.max_ammo_cells;
		}
		flag = TRUE;			// Ammo has been added
	}
	
	if (self.ammo_heads)
	{
		float maxheads = getkey(headhunters_maxheads);
		if (other.ammo_heads < maxheads)
		{
			// Add shells
			other.ammo_heads = other.ammo_heads + self.ammo_heads;
			if (other.ammo_heads > maxheads)
			{
				// Ammo has exceeded the maximum, fix it
				other.ammo_heads = maxheads;
			}
			flag = TRUE;			// Ammo has been added
		}
	}


	return flag;				// Return if we succeeded in adding ammo
};

void ammo_touch()
{
	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		return;				// Only players can pickup ammo and only in a game
	}

	if (ammo_add())
	{
		// Only pick up the ammo if the maximum isn't already hit
		item_pickup(getkey(respawn_ammo), "0x202005");
	}
};

/*
========================================================================

    Functions called from C

========================================================================
*/

//======================================================================
// item_shells
//
// Called from an ammobox. Spawnflags can hold either 0 or 1 which
// represents small or large ammobox.
//======================================================================
void item_shells()
{
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.maxsize = '32 32 52';
	self.minsize = '0 0 0';
	self.noise = "weapons/lock4.wav";		// Ammo picked up
	//self.takedamage = DAMAGE_EXPLODE;
	//self.time_respawn = stof(getkey("respawn_ammo"));				// Ammo respawn time
	self.touch = ammo_touch;			// Function to call if touched

	if (self.spawnflags & ITEM_AMMO_BIG)
	{
		self.ammo_shells = 40;
		self.model = "maps/b_shell1.bsp";	// Big shellbox
	}
	else
	{
		self.ammo_shells = 20;
		self.model = "maps/b_shell0.bsp";	// Small shellbox
	}

	// Common stuff set for items
	setitem();
};

//======================================================================
// item_spikes
//
// Called from an ammobox. Spawnflags can hold either 0 or 1 which
// represents small or large ammobox.
//======================================================================
void item_spikes()
{
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.maxsize = '32 32 52';
	self.minsize = '0 0 0';
	self.noise = "weapons/lock4.wav";		// Ammo picked up
	//self.time_respawn = stof(getkey("respawn_ammo"));				// Ammo respawn time
	self.touch = ammo_touch;			// Function to call if touched

	if (self.spawnflags & ITEM_AMMO_BIG)
	{
		self.ammo_nails = 50;
		self.model = "maps/b_nail1.bsp";	// Big nailbox
	}
	else
	{
		self.ammo_nails = 25;
		self.model = "maps/b_nail0.bsp";	// Small nailbox
	}

	// Common stuff set for items
	setitem();
};

//======================================================================
// item_rockets
//
// Called from an ammobox. Spawnflags can hold either 0 or 1 which
// represents small or large ammobox.
//======================================================================
void item_rockets()
{
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.maxsize = '32 32 52';
	self.minsize = '0 0 0';
	self.noise = "weapons/lock4.wav";		// Ammo picked up
	//self.time_respawn = stof(getkey("respawn_ammo"));				// Ammo respawn time
	self.touch = ammo_touch;			// Function to call if touched

	if (self.spawnflags & ITEM_AMMO_BIG)
	{
		self.ammo_rockets = 10;
		self.model = "maps/b_rock1.bsp";	// Big rocketbox
	}
	else
	{
		self.ammo_rockets = 5;
		self.model = "maps/b_rock0.bsp";	// Small rocketbox
	}

	// Common stuff set for items
	setitem();
};

//======================================================================
// item_cells
//
// Called from an ammobox. Spawnflags can hold either 0 or 1 which
// represents small or large ammobox.
//======================================================================
void item_cells()
{
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.maxsize = '32 32 52';
	self.minsize = '0 0 0';
	self.noise = "weapons/lock4.wav";		// Ammo picked up
	//self.time_respawn = stof(getkey("respawn_ammo"));				// Ammo respawn time
	self.touch = ammo_touch;			// Function to call if touched

	if (self.spawnflags & ITEM_AMMO_BIG)
	{
		self.ammo_cells = 12;
		self.model = "maps/b_batt1.bsp";	// Big cellbox
	}
	else
	{
		self.ammo_cells = 6;
		self.model = "maps/b_batt0.bsp";	// Small cellbox
	}

	// Common stuff set for items
	setitem();
};

//======================================================================
// item_weapon
//
// Can be shells, nails or rockets. This is like calling item_shells,
// item_spikes or item_rockets except that this has different
// spawnflags.
// This function just converts spawnflags and calls the appropriate
// function.
//
//======================================================================
void item_weapon()
{
	if (self.spawnflags & ITEM_WEAPON_SHELLS)
	{
		if (self.spawnflags & ITEM_WEAPON_BIG)
		{
			self.spawnflags = 1;	// Big box in the next function
			item_shells();		// Call shells function
		}
		else
		{
			self.spawnflags = 0;	// Small box in the next function
			item_shells();		// Call shells function
		}
	}
	if (self.spawnflags & ITEM_WEAPON_ROCKETS)
	{
		if (self.spawnflags & ITEM_WEAPON_BIG)
		{
			self.spawnflags = 1;	// Big box in the next function
			item_rockets();		// Call rockets function
		}
		else
		{
			self.spawnflags = 0;	// Small box in the next function
			item_rockets();		// Call rockets function
		}
	}
	if (self.spawnflags & ITEM_WEAPON_NAILS)
	{
		if (self.spawnflags & ITEM_WEAPON_BIG)
		{
			self.spawnflags = 1;	// Big box in the next function
			item_spikes();		// Call nails function
		}
		else
		{
			self.spawnflags = 0;	// Small box in the next function
			item_spikes();		// Call nails function
		}
	}
};

