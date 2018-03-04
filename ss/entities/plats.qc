/*
	plats.qc

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

void plat_reset()
{
	self.nextthink = -1;
	self.velocity = '0 0 0';
	if (self.targetname)
	{
		setorigin(self, self.pos1);
		self.state = STATE_TOP;
	}
	else
	{
		setorigin(self, self.pos2);
		self.state = STATE_BOTTOM;
	}
	gmapn_sound(self, CHAN_NO_PHS_ADD+CHAN_VOICE, self.noise1, 1, ATTN_NORM, 0);
};

//======================================================================
// plat_go_up
//
// This is called when something is triggered that should make the lift
// go up, like a player touching the middle of a normal lift or a button
// is pushed that is linked to a special lift.
//======================================================================
void plat_go_up()
{
	// Is true for either one of three cases. Either the lift is at
	// the top position and will delay one second from the local
	// time, or the lift is at the bottom and ready for takeoff.
	// It's also possible that the lift is on it's way down and is
	// blocked.
	if (self.state == STATE_TOP)
	{
		// Delay the return to bottom position
		self.nextthink = self.ltime + self.wait;
	}
	else if (self.state == STATE_BOTTOM || self.state == STATE_DOWN)
	{
		// Set speed, delay and state. Play a moving sound and
		// when the delay is over call plat_done
		calcmove(self.pos1, self.speed, plat_done);
		self.state = STATE_UP;
		gmapn_sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM, 0);
	}
};

//======================================================================
// plat_go_down
//
// This is called using the inverted logic of plat_go_up
//======================================================================
void plat_go_down()
{
	// Using the same logic as in plat_go_up, it's easily figured
	// out what these cases are for.
	if (self.state == STATE_BOTTOM)
	{
		// Delay return to top position
		self.nextthink = self.ltime + self.wait;
	}
	else if (self.state == STATE_TOP || self.state == STATE_UP)
	{
		// Set speed, delay and play sound.
		calcmove(self.pos2, self.speed, plat_done);
		self.state = STATE_DOWN;
		gmapn_sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM, 0);
	}
};

//======================================================================
// plat_trigger_touch
//
// Used only by normal plats without special triggers (buttons etc).
// This is called as soon as a player touches the spawned trigger field
// by this lift and will basically run a few checks before calling
// plat_go_up for a more technical algorithm.
//======================================================================
void plat_trigger_touch()
{
	// Only living players can use lifts.
	if (other.classname != "player" || other.deadflag != DEAD_NO)
	{
		return;
	}

	// Since this is a trigger entity, point self to the real lift
	// instead (which is stored in self.owner).
	if (self.owner)
	{
		self = self.owner;
	}

	// Send a signal that the player wants the lift to go up or
	// delay at the top position. This signal can only be sent if
	// the lift is at either top or bottom positions.
	if (self.state == STATE_BOTTOM || self.state == STATE_TOP)
	{
		plat_go_up();
	}
};

//======================================================================
// plat_trigger_spawn
//
// Set up the trigger field for normal lifts. The player can touch these
// in order to send signals to the lift that makes it move up or delay
// it at their top position.
//======================================================================
void plat_trigger_spawn()
{
	entity trigger;
	vector tmin, tmax;

	// middle trigger
	trigger = spawn();
	trigger.touch = plat_trigger_touch;
	trigger.owner = self;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;

	// The trigger size is calculated with 25 units offset from the
	// plat borders, making it trigger when touching the center of
	// the plat. It also triggers 8 units above the plat.
	tmax = self.maxs + '-25 -25 8';
	tmin = self.mins + '25 25 0';
	tmin_z = self.maxs_z - self.height + 8;

	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;

	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}

	setsize(trigger, tmin, tmax);
};

//======================================================================
// plat_done
//
// Called when a lift has reached their ending point. Makes them stop,
// play a stop sound and if necessary thinks a returning function to be
// called.
//======================================================================
void plat_done()
{
	// It stops!
	self.velocity_z = 0;

	// Play sounds with unmotivated additive channels.
	gmapn_sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM, 0);

	// Reached the top, it's possible that this is only a temporary
	// point for the lift.
	if (self.state == STATE_UP)
	{
		// The lift has reached the top
		self.state = STATE_TOP;

		// If this is a touch lift, so set the delay for moving
		// down
		self.think = plat_go_down;
		self.nextthink = self.ltime + self.wait;
	}
	else if (self.state == STATE_DOWN)
	{
		// The lift has reached the bottom
		self.state = STATE_BOTTOM;
	}
};

//======================================================================
// plat_crush
//
// Well you know, this is Quake so we have to be cruel to our stupid
// players who might be in the way of this holy lift. This function
// makes damage to the player and changes direction.
//======================================================================
void plat_crush()
{
	gmapn_impact(other, self, self.dmg, 0);

	// If moving up, go down. If moving down, go up
	if (self.state == STATE_UP)
	{
		plat_go_down();
	}
	else if (self.state == STATE_DOWN)
	{
		plat_go_up();
	}
};

void func_plat()
{
	// ???
	self.angles = '0 0 0';

	//
	self.solid = SOLID_BSP;

	// can block, crush and push
	self.movetype = MOVETYPE_PUSH;

	// set origin
	setorigin(self, self.origin);

	// set model
	setmodel(self, self.model);

	// set size(?)
	setsize(self, self.mins, self.maxs);

	// Default medieval sounds
	if (self.sounds == 0)
	{
		self.sounds = 2;
	}

	// Base sounds
	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}

	// Medieval sounds
	if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	// If the map author hasn't specified a height, make it
	// 8 pixels under the total vertical size
	if (!self.height)
	{
		self.height = self.size_z - 8;
	}

	if (!self.dmg)
	{
		self.dmg = 1;
	}

	// Default lift speed is 150
	if (!self.speed)
	{
		self.speed = 150;
	}

	// Make use of an already defined field. Plat delay is always 3
	// in standard qw.
	if (!self.wait)
	{
		self.wait = 3;
	}

	if (getkey(game_fastlifts) != 0)
	{
		// Multiply the lift speed as a feature
		self.speed = 2 * self.speed;

		// Divide the lift delay as a feature
		self.wait = self.wait / 2;
	}

	// Position 1 is the top position
	self.pos1 = self.origin;

	// Position 2 is the bottom position
	self.pos2 = self.origin;
	self.pos2_z = self.origin_z - self.height;

	// spawn a special touch trigger field to use the lift
	plat_trigger_spawn();

	// No targetname means no trigger is supposed to lower
	// this elevator
	if (!self.targetname)
	{

		// set it to the lower position
		setorigin(self, self.pos2);

		// and the state flag as well
		self.state = STATE_BOTTOM;

		// This plat will move upwards
		self.movedir = '0 0 1';
	}
	else
	{
		// This lift will have another entity as trigger so it
		// will keep its upper position and won't have a touch
		// trigger field

		// This plat will move downwards
		self.movedir = '0 0 -1';

		// set state flag to upper position, position is already
		// fixed
		self.state = STATE_TOP;

		// someone uses the trigger entity (buttons etc)
		self.use = plat_go_down;
	}

	// something is in the way for the lift to proceed
	self.blocked = plat_crush;
};
