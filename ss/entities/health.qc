/*
    health.qc

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

void megahealth_deplete()
{
	other = self.owner;				// Set the object in focus, our pickuper

	if (self.health > 0 && other.health > other.max_health)
	{
		// We have health left to deplete and our owner has megahealth left
		other.health = other.health - 1;	// Decrease one step on the owner
		self.health = self.health - 1;		// Decrease one step on our local health
		self.nextthink = time + 1;			// Call again next second
		self.think = megahealth_deplete;	// Call this function
		return;
	}

	// Now when mega is depleted, we can set the respawn time
	self.nextthink = time + getkey(respawn_mega);
	self.think = item_respawn;

	if (getkey(game_itemtimers))
		stuffcmdflags(other, STUFFCMD_BROADCAST, sprintf("//it %g %g %g %g 32 0x400000\n", self.nextthink-time, rint((self.absmin_x + self.absmax_x)*0.5), rint((self.absmin_y + self.absmax_y)*0.5), rint(self.origin_z + self.mins_z)));

	// Also reset the health stored
	self.health = self.max_health;
};

void megahealth_touch()
{
	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		return;				// Only players can pickup health and only in a game
	}

	// FIXME: Special mega respawn is default, should be optional
	self.owner = other;			// Who picked us up
	self.nextthink = time + 5;		// Start to deplete in 5 seconds
	self.think = megahealth_deplete;	// Check for depletion in this function

	other.health = other.health + self.health;

	if (other.health > other.max_megahealth)
	{
		// The boost has exceeded our limitation, fix this now

		// Here we will decrease the tracking-health so we don't deplete more than given
		self.health = self.health - (other.health - other.max_megahealth);

		// Now set the health to our limitation
		other.health = other.max_megahealth;
	}

	other.stats_took[TK_MH]++;

	item_pickup(0, "0x400000");			// Hide, mega has special respawn
};

void health_touch()
{
	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		return;				// Only players can pickup health and only in a game
	}

	if (other.health >= other.max_health)
	{
		return;				// Already at full health
	}

	other.health = other.health + self.health;

	if (other.health > other.max_health)
	{
		// Health has exceeded the maximum, fix it
		other.health = other.max_health;
	}

	item_pickup(getkey(respawn_health), "0x200000");			// Hide and wait for respawn
};

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// item_health
//
//
//
//======================================================================
void item_health()
{
	float  HEALTH_BROKEN = 1;
	float  HEALTH_MEGA = 2;

	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.maxsize = '32 32 52';
	self.minsize = '0 0 0';
	self.netname = "health";			// Name of the object
	//self.time_respawn = stof(getkey("respawn_health"));				// Health respawn time

	if (self.spawnflags & HEALTH_MEGA)
	{
		self.model = "maps/b_bh100.bsp";	// Mega healthbox
		self.noise = "items/r_item2.wav";	// Mega health picked up
		self.time_respawn = 0;			// Mega health special respawn
		self.netname = "megahealth";		// Name of the object
		self.max_health = 100;			// Health stored at respawn
		self.health = 100;			// Health stored while picked up
		self.touch = megahealth_touch;		// Function to call if touched
	}
	else if (self.spawnflags & HEALTH_BROKEN)
	{
		self.model = "maps/b_bh10.bsp";		// Broken healthbox
		self.noise = "items/r_item1.wav";	// Broken health picked up
		if (!self.health)
			self.health = 15;			// Amount of health stored
		self.touch = health_touch;		// Function to call if touched
	}
	else
	{
		self.model = "maps/b_bh25.bsp";		// Regular healthbox
		self.noise = "items/health1.wav";	// Good health picked up
		if (!self.health)
			self.health = 25;			// Amount of health stored
		self.touch = health_touch;		// Function to call if touched
	}

	setitem();
};
