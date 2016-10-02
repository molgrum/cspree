/*
    gmapn_subs.qc

    Copyright (C) 1996-1997  Id Software, Inc.
    Copyright (C) 2009       Andreas Nilsson

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

void self_destruct()
{
	remove(self);
};

// Called when the timer entity runs out, remove it as it's now unneeded
void usetargets_delay()
{
	usetargets();
	remove(self);
};

void usetargets()
{
	entity stemp, otemp, targ, etimer;

	// Delay the function if self.delay is set
	if (self.delay > 0)
	{
		// FIXME: go through the .use-functions and make sure all the needed
		// variables are set here

		// Timer entity used to fork here
		etimer = spawn();

		etimer.enemy = activator;
		etimer.killtarget = self.killtarget;
		etimer.message = self.message;
		etimer.target = self.target;
		etimer.use = self.use;

		etimer.nextthink = time + self.delay;
		etimer.think = usetargets_delay;

		return;
	}
	
	if (self.killtarget)
	{
		targ = find(world, targetname, self.killtarget);
		while (targ)
		{
			remove(targ);
			targ = find(targ, targetname, self.target);
		}
		
		//FIXME: WTF! but this matches vanilla!
		return;
	}
	
	// Call use function on target
	targ = find(world, targetname, self.target);
	while (targ)
	{
		stemp = self;
		otemp = other;
		self = targ;
		other = stemp;

		if (self.use)
		{
			self.use();
		}

		self = stemp;
		other = otemp;

		targ = find(targ, targetname, self.target);
	}
};

void calcmove_done()
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	if (self.think1)
	{
		self.think1();
	}
};

void calcmove(vector goalpos, float vel, void() move_done)
{
	float  traveltime;
	vector dir;

	// Current position equals target position
	if (self.origin != goalpos)
	{
		dir = goalpos - self.origin;
		traveltime = vlen(dir) / vel;
		self.velocity = normalize(dir) * vel;
	}
	else
	{
		// Need some time to think, not an actual travel time
		traveltime = 0.1;
		
		// Nowhere to go, no speed to get
		self.velocity = '0 0 0';
	}
	self.finaldest = goalpos;
	self.nextthink = self.ltime + traveltime;
	self.think = calcmove_done;
	self.think1 = move_done;

};

void gmapn_id_angles_sucks()
{
	if (self.angles == '0 -1 0')
	{
		// This really means angles pointing 90 degrees upwards
		// Lame standard being followed
		self.angles = '-90 0 0';
	}
	else if (self.angles == '0 -2 0')
	{
		// Same thing, but pointing 90 degrees downward
		self.angles = '90 0 0';
	}
	makevectors(self.angles);
	self.movedir = v_forward;
	
	// Since angles are used to calculate a moving direction, this
	// field is not used to rotate the entity. Void it.
	self.angles = '0 0 0';
};

float crandom()
{
	return random() - 0.5;
};

void gmapn_dropspawn()
{
	self.solid = SOLID_BBOX;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.origin = self.origin + '0 0 24';
	
	if (!droptofloor())
	{
		self.origin = self.origin + '0 0 -24';
	}
	
	self.solid = SOLID_TRIGGER;
	setorigin(self, self.origin);
	setsize(self, '0 0 0', '0 0 0');
};

float entities_touching(entity e1, entity e2)
{
	// Check that the entities is out of range from touching each
	// other, otherwise they are.
	
	if (e1.mins_x > e2.maxs_x)
	{
		return FALSE;
	}
	if (e1.mins_y > e2.maxs_y)
	{
		return FALSE;
	}
	if (e1.mins_z > e2.maxs_z)
	{
		return FALSE;
	}
	if (e1.maxs_x < e2.mins_x)
	{
		return FALSE;
	}
	if (e1.maxs_y < e2.mins_y)
	{
		return FALSE;
	}
	if (e1.maxs_z < e2.mins_z)
	{
		return FALSE;
	}
	
	return TRUE;
};

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float candamage(entity targ, entity inflictor)
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH || targ.movetype == MOVETYPE_NOCLIP)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};

void killed(entity targ, entity attacker)
{
	entity oself;

	oself = self;
	self = targ;

	if (self.health < -99)
		self.health = -99;				// don't let sbar look bad if a player dies

	self.death_finished = time + 3.0;	// FIXME: set this to standard time
	self.enemy = attacker;

	// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
	}

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		client_obituary(self, attacker);
	}

	self.takedamage = DAMAGE_NOT;
	self.touch = 0;
	self.effects = 0;

	self = oself;

	if (attacker != world && attacker.teamname != targ.teamname)
	{
		// Only count enemies killed

		attacker.stats_kills++;
	}

	targ.stats_deaths++;
};

// Use the following three functions to do damage

void gmapn_kill(entity victim, entity attacker)
{
	// Kill this victim immediately if it's not pented, /kill bypasses this check

	victim.armorvalue = 0;
	victim.health = -100;
	gmapn_death(victim, attacker);
};

float gmapn_impact(entity victim, entity inflictor, float damage, float push)
{
	entity stemp;
	entity attacker;
	float  amrdmg;
	float  hthdmg;
	float  pentmod;
	float  quadmod;
	float  reflect;
	vector vel;
	vector dir;

	if (victim.takedamage == DAMAGE_NOT)
	{
		return 0;					// No damage
	}

	if (victim.takedamage == DAMAGE_EXPLODE)
	{
		victim.takedamage = DAMAGE_NOT;
		damage += gmapn_explosion(victim, 160, 1, world, DT_EXPLOSION);

		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_EXPLOSION);
		WriteCoord(MSG_MULTICAST, victim.origin_x + 16);
		WriteCoord(MSG_MULTICAST, victim.origin_y + 16);
		WriteCoord(MSG_MULTICAST, victim.origin_z + 32);
		multicast(victim.origin, MULTICAST_PHS);

		remove(victim);

		return damage;				// Explosion boxes takes full damage
	}

	if (inflictor.owner != world)
	{
		attacker = inflictor.owner;
	}
	else
	{
		attacker = inflictor;
	}

	if (victim.takedamage == DAMAGE_TRIGGER)
	{
		gmapn_blood(inflictor);		// Standard QW

		activator = attacker;

		stemp = self;
		self = victim;
		self.use();
		self = stemp;
		
		return damage;				// Triggers takes full damage
	}

	if (inflictor.items & IT_QUAD)
	{
		// Inflicting object is quaded
		quadmod = 4;
	}
	else
	{
		quadmod = 1;
	}
	
	if (inflictor.items2 & IT2_RUNE_STRENGTH)
	{
		quadmod *= 2;
		if (time > inflictor.runetime)
		{
			sound(inflictor, CHAN_BODY, "rune/rune2.wav", 1, ATTN_NORM);
			inflictor.runetime = time + 1;
		}
	}
	if (victim.items2 & IT2_RUNE_RESISTANCE)
	{
		quadmod *= 0.5;	//should affect armour too		
		if (time > victim.runetime)
		{
			sound(victim, CHAN_BODY, "rune/rune1.wav", 1, ATTN_NORM);
			victim.runetime = time + 1;
		}
	}

	if (deathmatch == DMM_MIDAIR)
		push *= 1.5;

	// Invoke velocity pushback, but only on players, because its too weird on monsters, and too buggy on doors.

	if (inflictor != world && victim.classname == "player")
	{
		dir = victim.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		vel = 8 * dir * damage * quadmod * push;
		victim.velocity = victim.velocity + vel;
	}
	
	if (victim.takedamage == DAMAGE_INVINCIBLE)
		return 0;	//frozen players can be pushed around, but you can't otherwise hurt them.

	if (deathmatch == DMM_MIDAIR)
	{
		if (victim.flags & FL_ONGROUND)
			return 0;
		
	}

	// Pent check

	pentmod = 1;

	if (victim.items & IT_PENT)
	{
		sound(victim, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
		pentmod = 0;
	}
	else if (victim.items & IT_SUIT)	//FIXME: make more effective only against RL+LG
		pentmod = 0.5;
	else if (victim != attacker && inflictor != world)
	{
		// Another player is hit

		gmapn_blood(inflictor);
	}

	if (gmapn_serverstate != gmapn_serverstate_playing)
	{
		return damage;
	}

	// Damage armor

	amrdmg = ceil(victim.armortype * damage * quadmod);
	if (victim.deathtype == DT_TEAMREFLECT)
		amrdmg = 0;
	if (amrdmg >= victim.armorvalue)
	{
		amrdmg = victim.armorvalue;
		victim.armortype = 0;
		victim.items = victim.items - (victim.items &
				   (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	victim.armorvalue = victim.armorvalue - amrdmg;

	// Damage health
	hthdmg = pentmod * ceil(damage * quadmod - amrdmg);
	
	if (victim.deathtype == DT_TELEFRAG || victim.deathtype == DT_TELEFRAG_PENT || victim.deathtype == DT_TELEFRAG_PENT_BOTH || victim.deathtype == DT_TEAMREFLECT)
	{}	//telefrag always does full damage, even to team members.
	else if (victim == attacker)
		hthdmg *= getkey(game_selfdamage);	//multiplier to reduce damage to yourself.
	else if (teamplay && victim.classname == "player" && attacker.classname == "player" && (coop||victim.teamname == attacker.teamname))
	{	//you can destroy a teammate's armour, but any health damage will be inflicted upon you instead (and ignores your armour).
		reflect = hthdmg * getkey(game_teamdamage_reflect);
		hthdmg = hthdmg * getkey(game_teamdamage);
	}

	victim.health = victim.health - hthdmg;

	// FIXME: maybe should check DMM_INSTAGIB || DMM_MIDAIR
	if (deathmatch > 4 && inflictor != world && (hthdmg || amrdmg))
	{	//instagib and midair
		float midairheight = victim.origin_z - attacker.origin_z;
		if (!(deathmatch == DMM_MIDAIR && midairheight < 190))
		{
			victim.health = -100;
		}
	}

	// Display a red damage tint

	if (victim.flags & FL_CLIENT)
	{
		victim.dmg_inflictor = attacker;
		victim.dmg_save = victim.dmg_save + amrdmg;
		victim.dmg_take = victim.dmg_take + hthdmg;
	}

	if (victim.health < 1)
	{
		// Death sequence
		gmapn_death(victim, attacker);
	}
	else if (victim != attacker)
	{
		// Pain sequence
		stemp = self;
		self = victim;
		if (victim.flags & FL_MONSTER)	//monsters get pissy at anything that attacks them
		{
			if (attacker.takedamage && attacker != victim && attacker != victim.enemy)	//only get mad at if it makes sense.
			{
				if (attacker.classname != victim.classname || victim.classname == "monster_army")	//and don't attack your friends. unless you're an idiot.
				{
					if (!victim.oldenemy || victim.enemy.classname == "player")
						victim.oldenemy = victim.enemy;
					victim.enemy = attacker;
					FoundTarget ();
				}
			}
		}
		if (self.th_pain)
			self.th_pain(attacker, damage);
		else if ((self.flags & FL_CLIENT) && deathmatch != 4)
			player_pain();
		self = stemp;
	}
	
	if (reflect)
	{
		attacker.deathtype = DT_TEAMREFLECT;
		gmapn_impact(attacker, victim, reflect, push);
	}


	return damage;
};

float gmapn_explosion(entity inflictor, float damage, float push, entity ignore, float dtflag)
{
	float  points;
	float  totaldamage;
	entity victim;
	vector org;

	totaldamage = 0;
	victim = findradius(inflictor.origin, damage + 40);

	while (victim)
	{
		if (victim != ignore && victim.takedamage)
		{
			org = victim.origin + (victim.mins + victim.maxs) * 0.5;
			points = 0.5 * vlen(inflictor.origin - org);
			if (points < 0)
			{
				points = 0;
			}
			points = rint(damage - points);

			if (points > 0)
			{
				if (candamage(victim, inflictor))
				{
					victim.deathtype = dtflag;

					if (victim == inflictor.owner)
					{
						// Don't log damage to self and reduce the damage

						gmapn_impact(victim, inflictor, points * 0.5, push);
					}
					else
					{
						totaldamage += gmapn_impact(victim, inflictor, points, push);
					}
				}
			}
		}
		victim = victim.chain;
	}

	return totaldamage;
};

void gmapn_death(entity victim, entity attacker)
{
	entity stemp;
	
	killed(victim, attacker);
	stemp = self;
	self = victim;
	
	if (victim.flags & FL_MONSTER)
	{
		victim.flags &= ~(FL_FLY | FL_SWIM);
		activator = attacker;
		usetargets();
	}
	
	if (self.th_die)
		self.th_die();
	else
		player_death();
	self = stemp;
};

void gmapn_blood(entity inflictor)
{
	if (inflictor.weapon == IT_LIGHTNING_GUN || inflictor.weapon == IT_RAILGUN)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_LIGHTNINGBLOOD);
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		multicast(trace_endpos, MULTICAST_PHS);
	}
	else if (inflictor.weapon == IT_SHOTGUN || inflictor.weapon == IT_SUPER_SHOTGUN)
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_BLOOD);
		WriteByte(MSG_MULTICAST, 1);
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		multicast(trace_endpos, MULTICAST_PHS);
	}
	else
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_BLOOD);
		WriteByte(MSG_MULTICAST, 1);
		WriteCoord(MSG_MULTICAST, inflictor.origin_x);
		WriteCoord(MSG_MULTICAST, inflictor.origin_y);
		WriteCoord(MSG_MULTICAST, inflictor.origin_z);
		multicast(inflictor.origin, MULTICAST_PHS);
	}
};

void gmapn_centerprint_clear()
{
	centerprint(self.owner, "\n");
	remove(self);
};

void gmapn_centerprint(entity client, string msg, float duration)
{
	entity printer;

	printer = spawn();
	printer.nextthink = time + duration;
	printer.owner = client;
	printer.think = gmapn_centerprint_clear;

	centerprint(client, msg);
};

void item_drop()
{
	self.movetype = MOVETYPE_TOSS;
	
	self.origin_z = self.origin_z + 6;
	if (!droptofloor())
	{
		dprint(self.classname);
		dprint(" fell out at ");
		dprintln(vtos(self.origin + '0 0 -6'));
	}
	else
	{
		// Safely dropped down, don't fall down more than this
		self.flags = self.flags | FL_ONGROUND;
	}
};

void remove_wall()
{
	entity e;

	e = find(world, targetname, self.killtarget);
	while (e)
	{
		remove(e);
		e = find(world, targetname, self.killtarget);
	}
};

entity is_occupied(vector spot)
{
	entity p, list, oldself, fake_player;
	
	vector tmin;
	vector pmin;
	
	fake_player = spawn();
	setsize(fake_player, VEC_HULL_MIN, VEC_HULL_MAX);
	
	tmin = spot + fake_player.mins;

	oldself = self;
	list = spawn();
	self = list;
	
	p = find(world, classname, "player");
	while (p)
	{
		if (p != oldself && p.netname != "" && p.health > 0)
		{
			pmin = p.origin + p.mins;

			if (pmin_x + p.size_x > tmin_x && pmin_x < tmin_x + fake_player.size_x
			 && pmin_y + p.size_y > tmin_y && pmin_y < tmin_y + fake_player.size_y
			 && pmin_z + p.size_z > tmin_z && pmin_z < tmin_z + fake_player.size_z)
			{
				// Occupied by p
				self.enemy = p;
				self = p;
			}
		}
		p = find(p, classname, "player");
	}
	
	self = oldself;
	remove(fake_player);
	
	return list;
};

