/*
    teleports.qc

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

void teleport_sound()
{
	string sound_value;
	float r;

	// Randomize a sound value
	r = random() * 5;
	if (r < 1)
	{
		// First type of teleport sound
		sound_value = "misc/r_tele1.wav";
	}
	else if (r < 2)
	{
		// Second type of teleport sound
		sound_value = "misc/r_tele2.wav";
	}
	else if (r < 3)
	{
		// Third type of teleport sound
		sound_value = "misc/r_tele3.wav";
	}
	else if (r < 4)
	{
		// Third type of teleport sound
		sound_value = "misc/r_tele4.wav";
	}
	else if (r < 5)
	{
		// Third type of teleport sound
		sound_value = "misc/r_tele5.wav";
	}
	else
		sound_value = "";

	// Play the sound
	sound(self, CHAN_VOICE, sound_value, 1, ATTN_NORM);

	// Remove the entity, it's unneeded now
	remove(self);
};

void teleport_effect(vector org)
{
	entity sound_entity;

	sound_entity = spawn();
	sound_entity.origin = org;

	// Play a teleporting sound on the next sound entity think
	sound_entity.nextthink = time + 0.2; // FIXME: why does this need a delay?
	sound_entity.think = teleport_sound;

	// Create teleport sparks
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_TELEPORT);
	WriteCoord(MSG_MULTICAST, org_x);
	WriteCoord(MSG_MULTICAST, org_y);
	WriteCoord(MSG_MULTICAST, org_z);
	multicast(org, MULTICAST_PHS);
};

void teleport_touch()
{
	entity destination;
	float  vel;
	vector arg;

	if (other.classname == "player" || (other.health > 0 && other.flags & FL_MONSTER))
	{	//monsters and players can always be teleported.
	}
	else if (getkey(teleport_entities) != 0)
	{
		// allow player-created entities to teleport as well, but nothing else
		if (other.classname != "player" && other.classname != "backpack" && other.classname != "rocket" && other.classname != "grenade"
		&& other.classname != "spike" && other.classname != "superspike" && other.classname != "axe")
		{
			return;
		}
	}
	else
	{
		//no extra ents may teleport.
		return;
	}

	usetargets();

	// Find the targetname
	destination = find(world, targetname, self.target);

	// Only preserve upwards velocity (simulating a standard rampjump)
	if (other.velocity_z < 0)
	{
		other.velocity_z = 0;
	}

	// New algorithm experiment
	// Save velocity argument - self angles
	// Save velocity absolute value
	// Move to next position, set new angles
	// Add velocity argument and absolute to new velocity
	vel = vlen(other.velocity);
	
	// Minimum 300 speed
	if (vel < 300)
	{
		vel = 300;
	}
	
	// Make teleporting effect at the entering spot
	teleport_effect(other.origin);
	
	// Move the teleporting object to the destination
	setorigin(other, destination.origin);
	
	// Telefrag check for players
	if (other.classname == "player")
	{
		gmapn_telefrag_check(other, destination.origin);
	}

	// Make teleporting effect at the exiting spot
	teleport_effect(other.origin);

	if (getkey(teleport_angles) == 1)
	{
		// Preserve pitch angle
		other.angles_x = other.v_angle_x;
		other.angles_y = destination.angles_y;
	}
	else if (getkey(teleport_angles) == 2)
	{
		// Special angle preserving algorithm
		arg = vectoangles(other.velocity);
		arg_x = 0;
		arg_y = other.v_angle_y - arg_y;
		other.angles = '1 0 0' * other.v_angle_x + destination.angles + arg;
	}
	else
	{
		// Default angles set to teleporter angles
		other.angles = destination.angles;
	}

	other.fixangle = TRUE;

	makevectors(destination.angles);

	if (getkey(teleport_velocity) == 0)
	{
		// Don't preserve velocity (original qw)
		other.velocity = v_forward * 300;
	}
	else
	{
		// Preserve z velocity
		other.velocity_x = 0;
		other.velocity_y = 0;

		// Add forward velocity
		other.velocity = other.velocity + v_forward * vel;
	}

	// FIXME: what does this do?
	//other.teleport_time = time + 0.7;

	// Make teleporting effect at the destination spot
	teleport_effect(other.origin + v_forward*32);
};

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// trigger_teleport
//
//
//
//======================================================================
void trigger_teleport()
{
	self.solid = SOLID_TRIGGER;		// Can be touched and walked through
	self.movetype = MOVETYPE_NONE;
	setmodel(self, self.model);		// set size and link into world
	self.model = "";
	self.touch = teleport_touch;
	
	if (self.targetname)
	{
		self.solid = SOLID_NOT;
		setorigin(self, self.origin);
		self.use = (void())
		{
			self.solid = SOLID_TRIGGER;
			setorigin(self, self.origin);
			force_retouch = 2;	//horrible, but meh
			self.nextthink = time + 0.2;
			self.think = (void())
			{
				self.solid = SOLID_NOT;
				setorigin(self, self.origin);
			};
		};
	}
};

