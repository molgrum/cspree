/*
	doors.qc

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

void door_reset()
{
	self.velocity = '0 0 0';
	if (0 && self.spawnflags & DOOR_START_OPEN)
	{
		if (self.state == STATE_CLOSED && self == self.owner)
			openportal(self, TRUE);
		setorigin(self, self.pos2);
		self.state = STATE_OPENED;
	}
	else
	{
		if (self.state != STATE_CLOSED && self == self.owner)
			openportal(self, FALSE);
		setorigin(self, self.pos1);
		self.state = STATE_CLOSED;
	}
};

//======================================================================
// DOOR_CLOSE
//
//
//======================================================================
void door_close()
{
	if (self.state == STATE_OPENED || self.state == STATE_OPENING)
	{
		calcmove(self.pos1, self.speed, door_done);
		self.state = STATE_CLOSING;
		gmapn_sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM, 0);
	}
};

//======================================================================
// DOOR_OPEN
//
// Doors open for either one of three cases. Either the door is at
// the opened position and will delay one second from the local
// time, or the door is at the closed position and ready for opening.
// It's also possible that the door is on its way to close and is
// blocked.
//======================================================================
void door_open()
{
	// Someone keeps the door open by triggering it

	if (self.state == STATE_OPENED)
	{
		// Delay the return to bottom position
		self.nextthink = self.ltime + self.wait;
		return;
	}

	// Door is closed or closing, open it

	if (self.state == STATE_CLOSED || self.state == STATE_CLOSING)
	{
		//open the q3 areaportal now that its opening.
		if (self.state == STATE_CLOSED && self == self.owner)
			openportal(self, TRUE);

		calcmove(self.pos2, self.speed, door_done);
		self.state = STATE_OPENING;
		gmapn_sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM, 0);

		usetargets();
	}
};

//======================================================================
// DOOR_CRUSH
//
// Called when a player blocks the door, determined from self.blocked.
// Causes damage and toggles the opening/closing state.
//======================================================================
void door_crush()
{
	if (time > self.attack_finished)
	{
		other.deathtype = DT_SQUISH;
		gmapn_impact(other, self, self.dmg, 1.0);
		self.attack_finished = time + 0.5;
	}

	if (self.state == STATE_OPENING)
	{
		door_close();
	}
	else if (self.state == STATE_CLOSING)
	{
		door_open();
	}
};

#define SOUND_RELIABLE		1
//======================================================================
// DOOR_DONE
//
//
//======================================================================
void door_done()
{
	if (self.state == STATE_OPENING)
	{
		if (!(self.spawnflags & DOOR_TOGGLE))
		{
			self.nextthink = self.ltime + self.wait;
			self.think = door_close;
		}
		self.state = STATE_OPENED;
	}
	else if (self.state == STATE_CLOSING)
	{
		//if (!(self.spawnflags & DOOR_TOGGLE) && !(self.spawnflags & DOOR_START_OPEN))
		//{
		//	self.nextthink = self.ltime + self.wait;
		//	self.think = door_open;
		//}
		self.state = STATE_CLOSED;

		if (self.max_health)
		{
			self.takedamage = DAMAGE_TRIGGER;
			self.health = self.max_health;
		}

		//close the q3 areaportal too
		if (self == self.owner)
			openportal(self, FALSE);
	}

	gmapn_sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM, 0);
};

//======================================================================
// DOOR_USE
//
//
//======================================================================
void door_use()
{
	entity starte;

	starte = self;
	if ((self.spawnflags & DOOR_TOGGLE) && (self.state == STATE_OPENED || self.state == STATE_OPENING))
	{
		do
		{
			door_close();
			self = self.enemy;
		} while (self != starte);
	}
	else
	{
		do
		{
			self.takedamage = DAMAGE_NO;

			door_open();
			self = self.enemy;
		} while (self != starte);
	}
};

void door_trigger_touch()
{
	if (other.health <= 0)
	{
		return;
	}

	if (time < self.attack_finished)
	{
		return;
	}

	self.attack_finished = time + 1;

	activator = other;
	self = self.owner;

	door_use();
};

void door_touch()
{
	if (other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
		return;

	if (self.items)
	{
		if (((coop?global_items:other.items) & self.items) == self.items)
		{
			if (coop)
			{
				for(entity e = world; (e = find(e, classname, "player")); )
					e.items &~= self.items;
				global_items -= self.items;
			}
			else
				other.items -= self.items;
			self.items = 0;

			self.attack_finished = time + 1;

			activator = other;
			self = self.owner;

			door_use();
		}
	}
};

entity spawn_field(vector fmins, vector fmaxs)
{
	entity	trigger;
	local	vector	t1, t2;

	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return (trigger);
};

//======================================================================
// DOOR_LINK
//
// Set up a door chain for all seperate door groups. Link so that
// self.owner links to the master door and self.enemy links to the next
// door in the group, sorted according to what entity is encountered
// first. The master door is set simply as the first entity that calls
// this function.
//======================================================================
/*
void door_link()
{
	if (self.spawnflags & DOOR_DONT_LINK)
	{
		return; // Don't want to link
	}

	if (self.owner)
	{
		return; // Already linked
	}
};
*/


















void door_link()
{
	entity	t, starte;
	vector	cmins, cmaxs;

	if (self.enemy)
	{
		return;			// already linked by another door
	}
	if (self.spawnflags & DOOR_DONT_LINK)
	{
		self.owner = self.enemy = self;
		return;			// don't want to link this door
	}

	cmins = self.mins;
	cmaxs = self.maxs;

	starte = self;
	t = self;

	do
	{
		self.owner = starte;					// master door

		if (self.health)
			starte.health = self.health;
		if (self.targetname)
			starte.targetname = self.targetname;
		if (self.message != "")
			starte.message = self.message;

		t = find (t, classname, self.classname);
		if (!t)
		{
			self.enemy = starte;			// make the chain a loop

			// shootable, fired, or key doors just needed the owner/enemy links,
			// they don't spawn a field

			self = self.owner;

			if (self.health)
				return;
			if (self.targetname)
				return;
			if (self.items)
				return;

			self.owner.trigger_field = spawn_field(cmins, cmaxs);

			return;
		}

		if (entities_touching(self,t))
		{
			if (t.enemy)
				objerror ("cross connected doors");

			self.enemy = t;
			self = t;

			if (t.mins_x < cmins_x)
				cmins_x = t.mins_x;
			if (t.mins_y < cmins_y)
				cmins_y = t.mins_y;
			if (t.mins_z < cmins_z)
				cmins_z = t.mins_z;
			if (t.maxs_x > cmaxs_x)
				cmaxs_x = t.maxs_x;
			if (t.maxs_y > cmaxs_y)
				cmaxs_y = t.maxs_y;
			if (t.maxs_z > cmaxs_z)
				cmaxs_z = t.maxs_z;
		}
	} while (1 );
};
/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// func_door
//
//
//======================================================================
void func_door()
{
	gmapn_id_angles_sucks();

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin(self, self.origin);
	setmodel(self, self.model);

	self.max_health = self.health;
	if (self.health > 0)
		self.takedamage = DAMAGE_TRIGGER;

	// Door movement sounds
	if (self.sounds == 0)
	{
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	else if (self.sounds == 1)
	{
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	else if (self.sounds == 2)
	{
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	else if (self.sounds == 3)
	{
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	else if (self.sounds == 4)
	{
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}

	// Key sounds
	if (world.worldtype == 0)
	{
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else if (world.worldtype == 1)
	{
		self.noise3 = "doors/runetry.wav";
		self.noise4 = "doors/runeuse.wav";
	}
	else if (world.worldtype == 2)
	{
		self.noise3 = "doors/basetry.wav";
		self.noise4 = "doors/baseuse.wav";
	}
	else
	{
		dprintln("No worldtype set!");
	}

	precache_sound(self.noise1);
	precache_sound(self.noise2);
	precache_sound(self.noise3);
	precache_sound(self.noise4);

	// Fall back on default settings
	if (!self.dmg)
	{
		self.dmg = 2;
	}
	if (!self.lip)
	{
		self.lip = 8;
	}
	if (!self.speed)
	{
		self.speed = 100;
	}
	if (!self.wait)
	{
		self.wait = 3;
	}

	if (self.spawnflags & DOOR_SILVER_KEY)
	{
		// Silver key required, add it to door items
		self.items = IT_KEY1;
	}

	if (self.spawnflags & DOOR_GOLD_KEY)
	{
		// Gold key required, add it to door items
		self.items = IT_KEY2;
	}

	// Set open/closed positions
	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) -
			self.lip);
	self.state = STATE_CLOSED;

	if (self.spawnflags & DOOR_START_OPEN)
	{	//start_open merely swaps the positions.
		//swapping states over has implications with triggers that do NOT match vanilla
		setorigin(self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}

	// If a key is required, the door stays open when opened
	if (self.items & (IT_KEY1|IT_KEY2))
	{
		self.wait = -1;
		self.touch = door_touch;
	}

	self.blocked = door_crush;
	self.use = door_use;

	// Delay door_link so that all doors are spawned first
	self.nextthink = self.ltime + 0.1;
	self.think = door_link;
};

/*
 * secret doors
 */

void door_secret_reset()
{
	self.nextthink = -1;
	self.velocity = '0 0 0';
	setorigin(self, self.oldorigin);
	self.state = STATE_CLOSED;

	if (!self.targetname || self.spawnflags & SECRET_SHOOTABLE)
	{
		self.takedamage = DAMAGE_TRIGGER;
	}

	// Make a lodging sound
	gmapn_sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM, 0);
};

void door_secret_open()
{
	if (self.state != STATE_CLOSED)
	{
		// The door is not done moving so do nothing

		return;
	}

	self.state = STATE_OPENING;
	self.takedamage = DAMAGE_NOT;		// Do not trigger while moving

	usetargets();

	gmapn_sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM, 0);

	// And after the first sound, this is supposed to play
	gmapn_sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM, 0);

	// Move to first position
	calcmove(self.pos1, self.speed, door_secret_pos1);
};

void door_secret_pos1()
{
	// Make a lodging sound
	gmapn_sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM, 0);

	// Delay next move
	self.nextthink = self.ltime + 1;
	self.think = door_secret_pos1_move;
};

void door_secret_pos1_move()
{
	// Make a moving sound
	gmapn_sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM, 0);

	if (self.state == STATE_OPENING)
	{
		// Move to second position
		calcmove(self.pos2, self.speed, door_secret_pos2);
	}
	else
	{
		// Move to start position
		calcmove(self.oldorigin, self.speed, door_secret_done);
	}
};

void door_secret_pos2()
{
	// Make a lodging sound
	gmapn_sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM, 0);

	self.state = STATE_OPENED;
	// Stay open if this spawnflag is set
	if (!(self.spawnflags & SECRET_STAY_OPEN))
	{
		// Delay next move
		self.nextthink = self.ltime + self.wait;
		self.think = door_secret_close;
	}
};

void door_secret_close()
{
	// Make a moving sound
	gmapn_sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM, 0);

	self.state = STATE_CLOSING;
	// Move to first position
	calcmove(self.pos1, self.speed, door_secret_pos1);
};

void door_secret_done()
{
	// Make a lodging sound
	gmapn_sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM, 0);

	self.state = STATE_CLOSED;
	self.takedamage = DAMAGE_TRIGGER;	// Can trigger from damage again now
};

//======================================================================
// func_door_secret
//
//
//======================================================================
void func_door_secret()
{
	// convertangles converts .angles to call makevectors properly and
	// then voids it so the door appears normally

	gmapn_id_angles_sucks();

	if (!self.targetname || self.spawnflags & SECRET_SHOOTABLE)
	{
		self.takedamage = DAMAGE_TRIGGER;
	}

	if (self.sounds == 0)
	{
		self.sounds = 3;
	}
	if (self.sounds == 1)
	{
		precache_sound("doors/latch2.wav");
		precache_sound("doors/winch2.wav");
		precache_sound("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound("doors/airdoor1.wav");
		precache_sound("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound("doors/basesec1.wav");
		precache_sound("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}

	// Fall back on default settings
	if (!self.dmg)
	{
		self.dmg = 2;
	}
	if (!self.speed)
	{
		self.speed = 50;
	}
	if (!self.wait)
	{
		self.wait = 5;
	}

	self.solid = SOLID_BSP;
	self.state = STATE_CLOSED;
	self.movetype = MOVETYPE_PUSH;
	self.use = door_secret_open;
	setorigin(self, self.origin);
	setmodel(self, self.model);

	// Vectors from convertangles point towards where the door's final position is

	if (self.spawnflags & SECRET_FIRST_DOWN)
	{
		self.t_width = fabs(v_up * self.size);
		self.pos1 = self.origin - (v_up * self.t_width);
	}
	else if (self.spawnflags & SECRET_FIRST_LEFT)
	{
		self.t_width = fabs(v_right * self.size);
		self.pos1 = self.origin - (v_right * self.t_width);
	}
	else
	{
		self.t_width = fabs(v_right * self.size);
		self.pos1 = self.origin + (v_right * self.t_width);
	}

	// Final position is where vectors point forward

	self.t_length = fabs(v_forward * self.size);
	self.pos2 = self.pos1 + (v_forward * self.t_length);
};
