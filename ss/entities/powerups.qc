/*
    powerups.qc

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

void powerup_touch()
{
	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		return;					// Only players can pickup powerups and only in a game
	}

	if (self.items == IT_RING)
	{
		setmodel(other, "progs/eyes.mdl");	// Switch to invisible model instantly
		other.ring_finished = time + 30;
		other.stats_took[TK_RING]++;
		item_pickup(getkey(respawn_ring), "0x303030");
	}
	else if (self.items == IT_PENT)
	{
		other.pent_finished = time + 30;
		other.stats_took[TK_PENT]++;
		item_pickup(getkey(respawn_pent), "0x500000");
	}
	else if (self.items == IT_SUIT)
	{
		other.suit_finished = time + 30;
		other.stats_took[TK_SUIT]++;
		item_pickup(getkey(respawn_suit), "0x005000");
	}
	else if (self.items == IT_QUAD)
	{
		other.quad_finished = time + 30;
		other.stats_took[TK_QUAD]++;
		item_pickup(getkey(respawn_quad), "0x101050");
	}

};

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// item_artifact_invisibility
//
//
//
//======================================================================
void item_artifact_invisibility()
{
	self.channel = CHAN_AUTO;
	self.attenuation = ATTN_NONE;
	self.maxsize = '16 16 32';
	self.minsize = '-16 -16 -24';
	self.model = "progs/invisibl.mdl";		// Golden ring
	self.time_respawn = 60 * 5;			// Ring respawn time
	self.noise = "items/inv1.wav";			// Ring picked up
	self.netname = "Ring of Shadows";		// Name of the object
	self.items = IT_RING;				// Type of item
	self.touch = powerup_touch;			// Function to call if touched

	setitem();
};

//======================================================================
// item_artifact_invulnerability
//
//
//
//======================================================================
void item_artifact_invulnerability()
{
	self.channel = CHAN_AUTO;
	self.attenuation = ATTN_NONE;
	self.maxsize = '16 16 32';
	self.minsize = '-16 -16 -24';
	self.model = "progs/invulner.mdl";		// Red pentagram
	self.time_respawn = 60 * 5;			// Pent respawn time
	self.noise = "items/protect.wav";		// Pent picked up
	self.netname = "Pentagram of Protection";	// Name of the object
	self.items = IT_PENT;				// Type of item
	self.effects = self.effects | EF_RED;		// Glow effect
	self.touch = powerup_touch;			// Function to call if touched

	setitem();
};

//======================================================================
// item_artifact_envirosuit
//
//
//
//======================================================================
void item_artifact_envirosuit()
{
	self.channel = CHAN_AUTO;
	self.attenuation = ATTN_NONE;
	self.maxsize = '16 16 32';
	self.minsize = '-16 -16 -24';
	self.model = "progs/suit.mdl";			// Environmental suit
	self.noise = "items/suit.wav";			// Suit picked up
	self.time_respawn = 60;				// Powerup respawn time
	self.netname = "Biosuit";			// Name of the object
	self.items = IT_SUIT;				// Type of item
	self.effects = self.effects | EF_GREEN;		// Glow effect
	self.touch = powerup_touch;			// Function to call if touched

	setitem();
};

//======================================================================
// item_artifact_super_damage
//
//
//
//======================================================================
void item_artifact_super_damage()
{
	self.channel = CHAN_AUTO;
	self.attenuation = ATTN_NONE;
	self.maxsize = '16 16 32';
	self.minsize = '-16 -16 -24';
	self.model = "progs/quaddama.mdl";		// Blue Q
	self.time_respawn = 60;				// Quad respawn time
	self.noise = "items/damage.wav";		// Quad picked up
	self.netname = "Quad Damage";			// Name of the object
	self.items = IT_QUAD;				// Type of item
	self.effects = self.effects | EF_BLUE;		// Glow effect
	self.touch = powerup_touch;			// Function to call if touched

	setitem();
};
