/*
    armor.qc

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

// Armor pickup
void armor_touch()
{
	string tint;
	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
	{
		// Only players can pickup armor and only in a game
		return;
	}

	if (other.deadflag != DEAD_NO)
	{
		// Need to be alive in order to pickup armor
		return;
	}

	if (getkey(armor_accumulate))
	{
		float add = self.armortype * self.armorvalue;
		if (other.armorvalue >= 250 && other.armorvalue >= self.armorvalue)
			return;	//don't pointlessly go over 250.
		other.armorvalue += add;
		if (other.armorvalue < self.armorvalue)
			other.armorvalue = self.armorvalue;
		if (other.armorvalue >= 250)
			other.armorvalue = 250;
		if (other.armortype < self.armortype)
		{
			other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
			other.armortype = self.armortype;
		}
	}
	else if (other.armortype * other.armorvalue >= self.armortype * self.armorvalue)
	{
		// Current armor is better, so don't pickup
		return;
	}
	else
	{
		other.armortype = self.armortype;
		other.armorvalue = self.armorvalue;
		
		// Remove all armors from the player before adding this one
		other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}

	if (self.classname == "item_armor1")
	{
		other.stats_took[TK_GA]++;
		tint = "0x103010";
	}
	else if (self.classname == "item_armor2")
	{
		other.stats_took[TK_YA]++;
		tint = "0x303010";
	}
	else if (self.classname == "item_armorInv")
	{
		other.stats_took[TK_RA]++;
		tint = "0x301010";
	}
	else
	{
		tint = "";
		error("Unrecognized classname\n");
	}

	item_pickup(getkey(respawn_armor), tint);			// Hide and wait for respawn

	//clean up armour accumulation
	if (other.items & IT_ARMOR3)
		other.items &~= IT_ARMOR1|IT_ARMOR2;
	else if (other.items & IT_ARMOR2)
		other.items &~= IT_ARMOR1;
};

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// item_armor1
//
// This is the green armor. It gives 100 armor and absorbs 0.3 of any
// damage given.
//
//======================================================================
void item_armor1()
{
	self.armortype = getkey(armor1_absorb); // Set the absorbation rate
	self.armorvalue = getkey(armor1_amount); // Set the amount of armor
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.items = IT_ARMOR1;				// Items stored
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.model = "progs/armor.mdl";			// Armor
	self.netname = "green armor";			// Name of the object
	self.noise = "items/armor1.wav";		// Armor picked up
	self.skin = 0;					// Green armor skin
	//self.time_respawn = stof(getkey("respawn_armor"));				// Armor respawn time
	self.touch = armor_touch;			// Function to call if touched

	setitem();
};

//======================================================================
// item_armor2
//
// This is the yellow armor. It gives 150 armor and absorbs 0.6 of any
// damage given.
//
//======================================================================
void item_armor2()
{
	self.armortype = getkey(armor2_absorb); // Set the absorbation rate
	self.armorvalue = getkey(armor2_amount); // Set the amount of armor
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.items = IT_ARMOR2;				// Items stored
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.model = "progs/armor.mdl";			// Armor
	self.netname = "yellow armor";			// Name of the object
	self.noise = "items/armor1.wav";		// Armor picked up
	self.skin = 1;					// Yellow armor skin
	//self.time_respawn = stof(getkey("respawn_armor"));				// Armor respawn time
	self.touch = armor_touch;			// Function to call if touched

	setitem();
};

//======================================================================
// item_armorInv
//
// This is the red armor. It gives 200 armor and absorbs 0.8 of any
// damage given.
//
//======================================================================
void item_armorInv()
{
	self.armortype = getkey(armor3_absorb); // Set the absorbation rate
	self.armorvalue = getkey(armor3_amount); // Set the amount of armor
	self.attenuation = ATTN_NORM;
	self.channel = CHAN_ITEM;
	self.items = IT_ARMOR3;				// Items stored
	self.maxsize = '16 16 52';
	self.minsize = '-16 -16 0';
	self.model = "progs/armor.mdl";			// Armor
	self.netname = "red armor";			// Name of the object
	self.noise = "items/armor1.wav";		// Armor picked up
	self.skin = 2;					// Red armor skin
	//self.time_respawn = stof(getkey("respawn_armor"));				// Armor respawn time
	self.touch = armor_touch;			// Function to call if touched

	setitem();
};

