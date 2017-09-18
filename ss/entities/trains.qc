/*
	trains.qc

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

void train_reset()
{
	self.target = self.killtarget; // reset target to original route
	self.velocity = '0 0 0';
	train_init();
};

// Called when the train arrives at a route
void train_route()
{
	// Delay until moving to the next route, self.wait is -1 for the
	// final destination
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		gmapn_sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM, 0);
	}
	else
	{
		self.nextthink = self.ltime + 0.1;
	}

	self.think = train_move;
};

// Called to move the train to the next route
void train_move()
{
	entity eroute;

	// Set the next route
	eroute = find(world, targetname, self.target);

	if (!eroute.target)
	{
		objerror("train without a goal\n");
		return;
	}

	self.target = eroute.target;

	// Check for delay parameters on every route
	if (eroute.wait)
	{
		self.wait = eroute.wait;
	}
	else
	{
		self.wait = 0;
	}

	gmapn_sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM, 0);
	calcmove(eroute.origin - self.mins, self.speed, train_route);
};

void train_use()
{
	if (self.nextthink > self.ltime + self.wait)
	{
		// Already triggered, do nothing

		return;
	}

	train_move();
};

void train_init()
{
	entity pos;

	// Set train position to the first target

	pos = find(world, targetname, self.target);
	setorigin(self, pos.origin - self.mins);

	// Move the train immediately if it's not triggered
	if (!self.targetname)
	{
		self.nextthink = self.ltime + 0.1;
		self.think = train_move;
	}
};

void train_blocked()
{
	if (time > self.attack_finished)
	{
		other.deathtype = DT_SQUISH;
		gmapn_impact(other, self, self.dmg, 1.0);
		self.attack_finished = time + 0.5;
	}
};

//======================================================================
// func_train
//
//
//
//======================================================================
void func_train()
{
	if (!self.target)
	{
		objerror("No target specified in func_train\n");
	}

	gmapn_id_angles_sucks();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setorigin(self, self.origin);
	setmodel(self, self.model);

	if (self.sounds == 0)
	{
		self.noise = "misc/null.wav";
		precache_sound(self.noise);
		self.noise1 = "misc/null.wav";
		precache_sound(self.noise1);
	}
	else if (self.sounds == 1)
	{
		self.noise = "plats/train2.wav";
		precache_sound(self.noise);
		self.noise1 = "plats/train1.wav";
		precache_sound(self.noise1);
	}

	if (!self.dmg)
	{
		self.dmg = 2;
	}
	if (!self.speed)
	{
		self.speed = 100;
	}

	self.nextthink = self.ltime + 0.1;
	self.think = train_init;
	self.blocked = train_blocked;
	self.use = train_use;
	self.killtarget = self.target;
};

void misc_teleporttrain()
{
	if (!coop)
	{
		remove(self);
		return;
	}
	self.model = "progs/teleport.mdl";
	precache_model(self.model);
	func_train();
	self.solid = SOLID_NOT;
	self.avelocity = '100 200 300';
};
