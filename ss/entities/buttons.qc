/*
	buttons.qc

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

void button_reset()
{
	self.frame = 0;
	self.health = self.max_health;
	self.state = STATE_RELEASED;
	self.velocity = '0 0 0';

	if (self.max_health > 0)
	{
		self.takedamage = DAMAGE_TRIGGER;
	}

	setorigin(self, self.pos1);
};

void button_wait()
{
	self.frame = 1;			// use alternate textures
	self.nextthink = self.ltime + self.wait;
	self.state = STATE_PUSHED;
	self.think = button_release;

	if (self.max_health > 0)
	{
		self.takedamage = DAMAGE_NOT;
	}

	usetargets();
};

//======================================================================
// button_release
//
// Release the button, when done call button_done
//======================================================================
void button_release()
{
	self.state = STATE_RELEASING;

	calcmove(self.pos1, self.speed, button_reset);
};

//======================================================================
// button_press
//
// Press the button, when done call button_wait
//======================================================================
void button_push()
{
	if (self.state == STATE_PUSHED || self.state == STATE_PUSHING)
	{
		return;
	}

	calcmove(self.pos2, self.speed, button_wait);
	self.state = STATE_PUSHING;
	gmapn_sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM, 0);
};

//======================================================================
// button_touch
//
// Just make sure that only players can push buttons.
//======================================================================
void button_touch()
{
	if (other.classname != "player")
	{
		return;
	}

	activator = other;

	button_push();
};

//======================================================================
// func_button
//
// Initialize the button entity.
//======================================================================
void func_button()
{
	gmapn_id_angles_sucks();

	if (self.sounds == 0)
	{
		precache_sound("buttons/airbut1.wav");
		self.noise = "buttons/airbut1.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound("buttons/switch21.wav");
		self.noise = "buttons/switch21.wav";
	}
	if (self.sounds == 2)
	{
		// Used for countdown
		//precache_sound("buttons/switch02.wav");
		self.noise = "buttons/switch02.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound("buttons/switch04.wav");
		self.noise = "buttons/switch04.wav";
	}
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin(self, self.origin);
	setmodel(self, self.model);

	// If the button has health it's shootable, if not then the
	// players need to touch it.
	if (self.health)
	{
		self.max_health = self.health;
		self.takedamage = DAMAGE_TRIGGER;
		self.use = button_push;
	}
	else
	{
		self.max_health = 0;
		self.touch = button_touch;
	}

	// Default values
	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_RELEASED;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
};
