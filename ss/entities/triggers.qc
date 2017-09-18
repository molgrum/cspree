/*
	triggers.qc

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
		Boston, MA	02111-1307, USA

*/

void trigger_reset()
{
	self.cnt = self.count;
	self.solid = SOLID_TRIGGER;
};

//======================================================================
// trap_spikeshooter
//
//
//
//======================================================================
//void spikeshooter_reload()
//{
//	self.use = spikeshooter_use;
//};

void spikeshooter_use()
{
	if (self.attack_finished > time)
		return;

	if (self.spawnflags & TRAP_LASER)
	{
		hazard_laser(self.origin, self.movedir, 500);
	}
	else if (self.spawnflags & TRAP_SUPERSPIKE)
	{
		hazard_missile(self.origin, self.movedir, 500, "superspike");
	}
	else
	{
		hazard_missile(self.origin, self.movedir, 500, "spike");
	}

	if (self.wait == 0)
	{
		self.wait = 1.0;
	}

	self.attack_finished = time + self.wait;
	//self.think = spikeshooter_reload;
	//self.nextthink = time + self.wait;
	//self.use = func_null;
};

void trap_spikeshooter()
{
	gmapn_id_angles_sucks();

	// When triggered
	self.use = spikeshooter_use;

	if (self.spawnflags & TRAP_LASER)
	{
		precache_model2("progs/laser.mdl");
		precache_sound2("enforcer/enfire.wav");
		precache_sound2("enforcer/enfstop.wav");
	}
};

void changelevel_touch()
{
	if (deathmatch)
		return;
	if (other.deadflag || other.classname != "player" || gmapn_serverstate != gmapn_serverstate_playing)
		return;
	nextmap = self.map;
	gmapn_game_end();
};

//======================================================================
// trigger_changelevel
//
//
//
//======================================================================
void trigger_changelevel()
{
	if (getkey(game_exittele) == 0)
	{
		self.solid = SOLID_TRIGGER;
		setmodel(self, self.model);
		self.model = "";

		self.touch = changelevel_touch;
	}
	else
	{
		self.classname = "trigger_teleport";
		self.target = "start";
		trigger_teleport();
	}
};

//======================================================================
// trigger_multiple
//
//
//
//======================================================================
void trigger_multiple_reset()
{
	self.attack_finished = 0;
};

void trigger_multiple_use()
{
	if (self.attack_finished > time)
		return;	//still waiting for the timer to fire. don't fire again. can't toggle stuff otherwise.

	if (self.wait < 0)
		self.attack_finished = time + 99999999999;
	else
		self.attack_finished = time + self.wait;

	usetargets();
};

void trigger_multiple_touch()
{
	if (other.classname != "player")
	{
		return;
	}

	activator = other;
	trigger_multiple_use();
};

void trigger_multiple()
{
	self.movetype = MOVETYPE_NONE;
	self.use = trigger_multiple_use;

	if (self.health)
	{
		self.max_health = self.health;
		self.solid = SOLID_BBOX;
		self.takedamage = DAMAGE_TRIGGER;
	}
	else
	{
		self.solid = SOLID_TRIGGER;
		self.takedamage = DAMAGE_NOT;
		self.touch = trigger_multiple_touch;
	}

	setmodel(self, self.model);
	self.model = "";
};

//======================================================================
// trigger_once
//
//
//
//======================================================================
void trigger_once_use()
{
	self.takedamage = DAMAGE_NOT;

	usetargets();
};

void trigger_once_touch()
{
	if (other.classname != "player")
	{
		return;
	}

	self.solid = SOLID_NOT;

	trigger_once_use();
};

void trigger_once()
{
	self.movetype = MOVETYPE_NONE;
	self.use = trigger_once_use;

	if (self.health)
	{
		self.max_health = self.health;
		self.solid = SOLID_BBOX;
		self.takedamage = DAMAGE_TRIGGER;
	}
	else
	{
		self.solid = SOLID_TRIGGER;
		self.takedamage = DAMAGE_NOT;
		self.touch = trigger_once_touch;
	}

/*	// Removal of platform where items rest
	if (self.killtarget)
	{
		self.nextthink = time + 0.4;
		self.think = remove_wall;
	}
*/
	setmodel(self, self.model);
	self.model = "";
};

//======================================================================
// trigger_onlyregistered
//
//
//
//======================================================================
void trigger_onlyregistered_touch()
{
	if (other.classname != "player")
	{
		return;
	}

	self.solid = SOLID_NOT;

	usetargets();
};

void trigger_onlyregistered()
{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.touch = trigger_onlyregistered_touch;

	setmodel(self, self.model);
	self.model = "";
};

//======================================================================
// trigger_secret
//
//
//
//======================================================================
void trigger_secret_touch()
{
	if (other.classname != "player")
	{
		return;
	}

	self.solid = SOLID_NOT;
	WriteByte(MSG_ALL, SVC_FOUNDSECRET);
	found_secrets++;

	centerprint(other, self.message);
	gmapn_sound(other, CHAN_VOICE, self.noise, 1, ATTN_NORM, 0);
};

void trigger_secret()
{
	if (deathmatch != 0)
	{
		remove(self);
		return;
	}

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.touch = trigger_secret_touch;

	setmodel(self, self.model);
	self.model = "";

	if (!self.message)
	{
		self.message = "You found a secret area!";
	}

	if (!self.sounds)
	{
		self.sounds = 1;
	}

	if (self.sounds == 1)
	{
		self.noise = "misc/secret.wav";
		precache_sound(self.noise);
	}
	else if (self.sounds == 2)
	{
		self.noise = "misc/talk.wav";
		precache_sound(self.noise);
	}
	else
	{
		objerror("Invalid sound setting");
	}

	total_secrets++;
};

//======================================================================
// trigger_counter
//
// .count is the number of
//
//======================================================================
void trigger_counter_use()
{
	string str;

	self.cnt-=1;

	if (self.cnt < 0)
	{
		return;
	}

	if (self.cnt > 0)
	{
		if (!(self.spawnflags & COUNTER_SILENT))
		{
			str = ftos(self.cnt);
			str = strcat(str, " more to go...");
			gmapn_centerprint(activator, str, 1.0);
		}

		return;
	}

	if (self.cnt == 0)
	{
		if (!(self.spawnflags & COUNTER_SILENT))
		{
			gmapn_centerprint(activator, "Sequence complete!", 1.0);
		}

		self.cnt = -1;
		usetargets();
	}

};

void trigger_counter()
{
	if (!self.count)
	{
		self.count = 2;
	}

	self.cnt = self.count;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.use = trigger_counter_use;
};
