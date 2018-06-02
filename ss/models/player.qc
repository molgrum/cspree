/*
	player.qc

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

// FIXME: implement muzzleflashes

// Running with axe
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

// Running with gun
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

// Standing with gun
$frame stand1 stand2 stand3 stand4 stand5

// Standing with axe
$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12

// Pain with axe
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

// Pain with gun
$frame pain1 pain2 pain3 pain4 pain5 pain6

// Death with axe
$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

// Death type A
$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

// Death type B
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

// Death type C
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

// Death type D
$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

// Death type E
$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

// Nailgun attack
$frame nailatt1 nailatt2

// Lightning gun attack
$frame light1 light2

// Rocket/grenade launcher attack
$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

// Shotgun attack
$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

// Axe attack type A
$frame axatta1 axatta2 axatta3 axatta4 axatta5 axatta6

// Axe attack type B
$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

// Axe attack type C
$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

// Axe attack type D
$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6

float() client_bestweapon;
float() client_stopattacking;
void() player_run;

void player_setweapon()
{
	string vwep;

	self.weapon = self.newweapon;

	if (deathmatch < 6)
		self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));

	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		vwep = "progs/w_axe.mdl";
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
		self.weaponmodel = "progs/v_shot.mdl";
		vwep = "progs/w_shot.mdl";
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
		self.weaponmodel = "progs/v_shot2.mdl";
		vwep = "progs/w_shot2.mdl";
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
		self.weaponmodel = "progs/v_nail.mdl";
		vwep = "progs/w_nail.mdl";
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
		self.weaponmodel = "progs/v_nail2.mdl";
		vwep = "progs/w_nail2.mdl";
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
		self.weaponmodel = "progs/v_rock.mdl";
		vwep = "progs/w_rock.mdl";
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
		self.weaponmodel = "progs/v_rock2.mdl";
		vwep = "progs/w_rock2.mdl";
	}
	else if (self.weapon == IT_LIGHTNING_GUN)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
		self.weaponmodel = "progs/v_light.mdl";
		vwep = "progs/w_light.mdl";
	}
	else if (self.weapon == IT_RAILGUN)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
		self.weaponmodel = "progs/v_coil.mdl";
		vwep = "progs/w_coil.mdl";
	}
	else if (self.weapon == IT_PORTALGUN || self.weapon == IT_PORTALGUN_ALT)
	{
		if (self.weapon == IT_PORTALGUN)
			self.currentammo = 111;
		else
			self.currentammo = 222;
		self.weaponmodel = "";
		vwep = "-";
	}
	else if (self.weapon == IT_HOOK)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_star.mdl";
		vwep = "progs/w_star.mdl";
	}
	else if (self.weapon == IT_COILGUN)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_coil.mdl";
		vwep = "progs/w_coil.mdl";
	}
	else
	{
		// No recognized weapon
		if (self.weapon != 0)
			dprintln(sprintf("unrecognized self.weapon: %s", ftos(self.weapon)));
		self.currentammo = 0;
		self.weaponmodel = "";
		vwep = "-";
	}

	self.weaponframe = 0;

	if (gmapn_qsg_has_zq_vwep)
		self.vw_index = precache_vwep_model(vwep);
};

float hasted_reload(float base)
{
	if (self.items2 & IT2_RUNE_HASTE)
	{
		if (time > self.runetime)
		{
			gmapn_sound(self, CHAN_BODY, "rune/rune3.wav", 1, ATTN_NORM, 0);
			self.runetime = time + 1;
		}

		base /= 2;				//double attack speed
		return ceil(base*10)/10;	//rounded up to nearest 10th of a second, to try to keep things smoother.
	}
	return base;
};

//======================================================================
// player_stand
//
//
//
//======================================================================
void() player_stand = [$axstnd1, player_stand]
{
	// With game_newwalk, the running animation plays when the player sends a movement command
	// Otherwise it plays when the player has a velocity
	if (getkey(game_newwalk) != 0 && gmapn_qsg_has_dp_sv_playerphysics == TRUE && self.movement != '0 0 0'
	   || getkey(game_newwalk) == 0 && self.velocity_x != 0 && self.velocity_y != 0)
	{
		self.walkframe = 0;
		player_run();
		return;
	}

	// Not running a firing animation, set the weapon model since it's ok to switch now
	player_setweapon();

	// Special animation for axe and gun respectively
	if (self.weapon == IT_AXE)
	{
		// 12 frames are maximum
		if (self.walkframe >= 12)
		{
			self.walkframe = 0;
		}
		self.frame = $axstnd1 + self.walkframe;
	}
	else
	{
		// 5 frames are maximum
		if (self.walkframe >= 5)
		{
			self.walkframe = 0;
		}
		self.frame = $stand1 + self.walkframe;
	}

	// Increase one frame
	self.walkframe++;
};

//======================================================================
// player_run
//
//
//
//======================================================================
void() player_run = [$rockrun1, player_run]
{
	// With game_newwalk, the standing animation plays when the player does not send a movement command
	// Otherwise it plays when the player has no velocity

	if (getkey(game_newwalk) != 0 && gmapn_qsg_has_dp_sv_playerphysics == TRUE && self.movement == '0 0 0'
	   || getkey(game_newwalk) == 0 && self.velocity_x == 0 && self.velocity_y == 0)
	{
		self.walkframe = 0;
		player_stand();
		return;
	}

	// Not running a firing animation, set the weapon model since it's ok to switch now
	player_setweapon();

	// Animation

	if (self.walkframe >= 6)
	{
		self.walkframe = 0;
	}

	if (self.weapon == IT_AXE)
	{
		self.frame = $axrun1 + self.walkframe;
	}
	else
	{
		self.frame = $rockrun1 + self.walkframe;
	}

	self.walkframe++;
};

void player_dead()
{
	if (gmapn_qsg_has_zq_vwep)
		self.vw_index = precache_vwep_model("-");
	self.deadflag = DEAD_DEAD;	// Animation is done
};

// Normal QC sets the DEAD_RESPAWNABLE parameter after the animation is done, which
// leads to random minimum respawn times. Here the death animations will always set
// the parameter after 900 ms.

void() player_axdeth1 = [$axdeth1, player_axdeth2]	{};
void() player_axdeth2 = [$axdeth2, player_axdeth3]	{};
void() player_axdeth3 = [$axdeth3, player_axdeth4]	{};
void() player_axdeth4 = [$axdeth4, player_axdeth5]	{};
void() player_axdeth5 = [$axdeth5, player_axdeth6]	{};
void() player_axdeth6 = [$axdeth6, player_axdeth7]	{};
void() player_axdeth7 = [$axdeth7, player_axdeth8]	{};
void() player_axdeth8 = [$axdeth8, player_axdeth9]	{};
void() player_axdeth9 = [$axdeth9, func_null]		{player_dead();};

void() player_deatha1 = [$deatha1, player_deatha2]	{};
void() player_deatha2 = [$deatha2, player_deatha3]	{};
void() player_deatha3 = [$deatha3, player_deatha4]	{};
void() player_deatha4 = [$deatha4, player_deatha5]	{};
void() player_deatha5 = [$deatha5, player_deatha6]	{};
void() player_deatha6 = [$deatha6, player_deatha7]	{};
void() player_deatha7 = [$deatha7, player_deatha8]	{};
void() player_deatha8 = [$deatha8, player_deatha9]	{};
void() player_deatha9 = [$deatha9, player_deatha10]	{player_dead();};
void() player_deatha10 = [$deatha10, player_deatha11]	{};
void() player_deatha11 = [$deatha11, func_null]		{};

void() player_deathb1 = [$deathb1, player_deathb2]	{};
void() player_deathb2 = [$deathb2, player_deathb3]	{};
void() player_deathb3 = [$deathb3, player_deathb4]	{};
void() player_deathb4 = [$deathb4, player_deathb5]	{};
void() player_deathb5 = [$deathb5, player_deathb6]	{};
void() player_deathb6 = [$deathb6, player_deathb7]	{};
void() player_deathb7 = [$deathb7, player_deathb8]	{};
void() player_deathb8 = [$deathb8, player_deathb9]	{};
void() player_deathb9 = [$deathb9, func_null]		{player_dead();};

void() player_deathc1 = [$deathc1, player_deathc2]	{};
void() player_deathc2 = [$deathc2, player_deathc3]	{};
void() player_deathc3 = [$deathc3, player_deathc4]	{};
void() player_deathc4 = [$deathc4, player_deathc5]	{};
void() player_deathc5 = [$deathc5, player_deathc6]	{};
void() player_deathc6 = [$deathc6, player_deathc7]	{};
void() player_deathc7 = [$deathc7, player_deathc8]	{};
void() player_deathc8 = [$deathc8, player_deathc9]	{};
void() player_deathc9 = [$deathc9, player_deathc10]	{player_dead();};
void() player_deathc10 = [$deathc10, player_deathc11]	{};
void() player_deathc11 = [$deathc11, player_deathc12]	{};
void() player_deathc12 = [$deathc12, player_deathc13]	{};
void() player_deathc13 = [$deathc13, player_deathc14]	{};
void() player_deathc14 = [$deathc14, player_deathc15]	{};
void() player_deathc15 = [$deathc15, func_null]		{};

void() player_deathd1 = [$deathd1, player_deathd2]	{};
void() player_deathd2 = [$deathd2, player_deathd3]	{};
void() player_deathd3 = [$deathd3, player_deathd4]	{};
void() player_deathd4 = [$deathd4, player_deathd5]	{};
void() player_deathd5 = [$deathd5, player_deathd6]	{};
void() player_deathd6 = [$deathd6, player_deathd7]	{};
void() player_deathd7 = [$deathd7, player_deathd8]	{};
void() player_deathd8 = [$deathd8, player_deathd9]	{};
void() player_deathd9 = [$deathd9, func_null]		{player_dead();};

void() player_deathe1 = [$deathe1, player_deathe2]	{};
void() player_deathe2 = [$deathe2, player_deathe3]	{};
void() player_deathe3 = [$deathe3, player_deathe4]	{};
void() player_deathe4 = [$deathe4, player_deathe5]	{};
void() player_deathe5 = [$deathe5, player_deathe6]	{};
void() player_deathe6 = [$deathe6, player_deathe7]	{};
void() player_deathe7 = [$deathe7, player_deathe8]	{};
void() player_deathe8 = [$deathe8, player_deathe9]	{};
void() player_deathe9 = [$deathe9, func_null]		{player_dead();};

void player_frozen_touch()
{
	if (other.thawplayer)
		return;	//player is busy.
	if (other.deadflag)
		return;	//corpses shouldn't thaw each other.
	if (other.classname == "player")
	{
		if (other.teamname == self.teamname)
		{
			centerprint(other, "Thawing ", self.netname);
			centerprint(self, other.netname, " takes pity on you");
			other.thawplayer = self;
			other.thawtime = time + getkey(freezetag_thawtime);
		}
	}
};
void() player_frozen_think = [++$axstnd1..$axstnd12]
{
};

void player_headhunter_touch()
{
	if (other.classname == "player" && !other.deadflag)
	{
		if (other.ammo_heads >= getkey(headhunters_maxheads))
			return;
		other.ammo_heads+=1;
		showpic("hc", sprintf("gfx/num_%g", bound(0, other.ammo_heads, 9)), 0, 0, 0, other);
		gmapn_sound(self, CHAN_ITEM, "demon/dland2.wav", 1, ATTN_NORM, 0);
		stuffcmd(other, "bf\n");
		if (other.netname == self.netname)
			centerprint(other, "You got your own head");
		else
			centerprint(other, "You got ", self.netname, "'s head");

		if (self.classname == "player")
		{
			centerprint(self, "You were collected by ", other.netname);
			self.touch = 0;
			self.solid = SOLID_NOT;
			setmodel(self, "");
			setsize(self, '0 0 0', '0 0 0');

			self.view2 = other;	//it'd be cool if we could reliably spectate the person that collected us, but meh, this will have to do
		}
		else
			remove(self);
	}
};
void player_headhunter_respawned()
{
	if (self.touch == player_headhunter_touch)
	{
		entity thehead = spawn();
		thehead.movetype = self.movetype;
		thehead.solid = self.solid;
		thehead.velocity = self.velocity;
		thehead.avelocity = self.avelocity;
		thehead.flags = self.flags & FL_ONGROUND;
		thehead.touch = self.touch;
		thehead.angles = self.angles;
		setmodel(thehead, self.model);
		setsize(thehead, self.mins, self.maxs);
		setorigin(thehead, self.origin);
		thehead.nextthink = time + 60;
		thehead.think = self_destruct;
		thehead.colormap = self.colormap;
		thehead.netname = strcat(self.netname);

		self.touch = 0;
	}
};

void player_ammo_decrease(float ammotype, float amount)
{
	if (deathmatch == 4 || gmapn_serverstate != gmapn_serverstate_playing)
		return;

	if (ammotype & IT_SHELLS)
		self.ammo_shells -= amount;
	if (ammotype & IT_NAILS)
		self.ammo_nails -= amount;
	if (ammotype & IT_ROCKETS)
		self.ammo_rockets -= amount;
	if (ammotype & IT_CELLS)
		self.ammo_cells -= amount;
}

void(string gibname, float dm) ThrowGib;
vector(float dm) VelocityForDamage;
void player_gibbed()
{
	self.movetype = MOVETYPE_BOUNCE;
	self.flags -= self.flags&FL_ONGROUND;
	self.solid = SOLID_TRIGGER;
	if (gmapn_gamemode == GM_HEADHUNTER)
		self.touch = player_headhunter_touch;
	setmodel(self, "progs/h_player.mdl");
	self.view_ofs = '0 0 8';
	self.origin_z += self.mins_z;
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = VelocityForDamage(self.health);
	self.avelocity = randomv('600 600 600');
	//FIXME: use a different model in headhunters, because most qw clients have client-side gib filters enabled by default.

	ThrowGib("progs/gib1.mdl", self.health);
	ThrowGib("progs/gib2.mdl", self.health);
	ThrowGib("progs/gib3.mdl", self.health);
};

void player_death()
{
	float rnd;

	if (gmapn_gamemode == GM_CTF || gmapn_gamemode == GM_1FCTF)
		ctf_player_died();

	if (gmapn_gamemode == GM_FREEZETAG)
	{
		if (self.deathtype == DT_TELEFRAG || self.deathtype == DT_TELEFRAG_PENT || self.deathtype == DT_TELEFRAG_PENT_BOTH)
		{
			//don't do weird stuff. that would result in players inside players.
			self.takedamage = DAMAGE_INVINCIBLE;
		}
		else
		{
			//in freezetag, dead players remain solid and don't play their death animation.
			//(they can't respawn normally - that's handled somewhere else)
			self.deadflag = DEAD_DEAD;
			self.maxspeed = 0;
			self.health = 1000;
			self.armorvalue = 1000;
			self.takedamage = DAMAGE_INVINCIBLE;
			self.touch = player_frozen_touch;
			self.think = func_null;	//make sure use of nextthink doesn't break things
			self.weaponmodel = 0;
			//self.colormap = 1024;	//so they end up color 0 0, white, some dp feature.
			self.skin = 100;	//attempt to use global skins
			self.vw_index = 0;

			gmapn_sound(self, CHAN_VOICE, "player/frozen1.wav", 1, ATTN_NONE, 0);
			stuffcmd(self, "bf 0 0.5 1 0.6 0.5\n");	//flash the screen with a blue tint, so people realise that they actually just died.
			centerprint(self, "FROZEN!");
			return;
		}
	}

	// Dying, can't move or be hit while dying

	self.deadflag = DEAD_DYING;
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_NOT;

	if (gmapn_qsg_has_zq_vwep)
		self.vw_index = precache_vwep_model("-");

	// Setup the minimum waiting time until respawn

	self.nextthink = time + 0.9;
	self.think = player_dead;

	if (self.deathtype == DT_TELEFRAG || self.deathtype == DT_TELEFRAG_PENT || self.deathtype == DT_TELEFRAG_PENT_BOTH)
	{
		// Telefrag
		gmapn_sound(self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE, 0);

		player_gibbed();
	}
	else if (self.health < getkey(game_gibthreshhold) || gmapn_gamemode == GM_HEADHUNTER)
	{	//headhunter always gibs, so that heads can be collected.
		rnd = floor(random() * 2);
		if (rnd < 1)
			gmapn_sound(self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE, 0);
		else
			gmapn_sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE, 0);

		player_gibbed();
	}
	else if (self.weapon == IT_AXE)
	{
		// Death with axe has its own death animation

		gmapn_sound(self, CHAN_VOICE, "player/death1.wav", 1, ATTN_NONE, 0);
		player_axdeth1();
	}
	else
	{
		// Random between 5 types of death with gun

		rnd = floor(random() * 5);

		if (rnd < 1)
		{
			gmapn_sound(self, CHAN_VOICE, "player/death1.wav", 1, ATTN_NONE, 0);
			player_deatha1();
		}
		else if (rnd < 2)
		{
			gmapn_sound(self, CHAN_VOICE, "player/death2.wav", 1, ATTN_NONE, 0);
			player_deathb1();
		}
		else if (rnd < 3)
		{
			gmapn_sound(self, CHAN_VOICE, "player/death3.wav", 1, ATTN_NONE, 0);
			player_deathc1();
		}
		else if (rnd < 4)
		{
			gmapn_sound(self, CHAN_VOICE, "player/death4.wav", 1, ATTN_NONE, 0);
			player_deathd1();
		}
		else// if (rnd < 5)
		{
			gmapn_sound(self, CHAN_VOICE, "player/death5.wav", 1, ATTN_NONE, 0);
			player_deathe1();
		}
	}

	// Throw backpack instantly when dying
	client_pack_throw();
};

void() player_axpain1 = [$axpain1, player_axpain2] {};
void() player_axpain2 = [$axpain2, player_axpain3] {};
void() player_axpain3 = [$axpain3, player_axpain4] {};
void() player_axpain4 = [$axpain4, player_axpain5] {};
void() player_axpain5 = [$axpain5, player_axpain6] {};
void() player_axpain6 = [$axpain6, player_axpain6] {player_run();};

void() player_pain1 = [$pain1, player_pain2] {};
void() player_pain2 = [$pain2, player_pain3] {};
void() player_pain3 = [$pain3, player_pain4] {};
void() player_pain4 = [$pain4, player_pain5] {};
void() player_pain5 = [$pain5, player_pain6] {};
void() player_pain6 = [$pain6, player_pain6] {player_run();};

void player_pain()
{
	float  r;

	if (time < self.pain_finished)
	{
		return;
	}

	if (self.weaponframe > 0)
		return; // do not jam weapon animations

	if (self.weapon == IT_AXE)
	{
		player_axpain1();
	}
	else
	{
		player_pain1();
	}

	// Check the deathtype to determine hurt sound

	if (self.deathtype == DT_WATER)
	{
		// Water hurt
		r = random()*2;
		if (r < 1)
		{
			gmapn_sound(self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM, 0);
		}
		else
		{
			gmapn_sound(self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM, 0);
		}
	}
	else if (self.deathtype == DT_SLIME || self.deathtype == DT_LAVA)
	{
		// Slime/lava hurt
		r = random()*2;
		if (r < 1)
		{
			gmapn_sound(self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM, 0);
		}
		else
		{
			gmapn_sound(self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM, 0);
		}
	}
	else
	{
		// Normal hurt
		r = random()*6;
		if (r < 1)
		{
			gmapn_sound(self, CHAN_VOICE, "player/pain1.wav", 1, ATTN_NORM, 0);
		}
		else if (r < 2)
		{
			gmapn_sound(self, CHAN_VOICE, "player/pain2.wav", 1, ATTN_NORM, 0);
		}
		else if (r < 3)
		{
			gmapn_sound(self, CHAN_VOICE, "player/pain3.wav", 1, ATTN_NORM, 0);
		}
		else if (r < 4)
		{
			gmapn_sound(self, CHAN_VOICE, "player/pain4.wav", 1, ATTN_NORM, 0);
		}
		else if (r < 5)
		{
			gmapn_sound(self, CHAN_VOICE, "player/pain5.wav", 1, ATTN_NORM, 0);
		}
		else
		{
			gmapn_sound(self, CHAN_VOICE, "player/pain6.wav", 1, ATTN_NORM, 0);
		}
	}

	self.pain_finished = time + 0.6;		// FIXME: set this to standard behaviour
};

void player_axe()
{
	float vel;
	vector dir;

	makevectors(self.v_angle);

	vel = 2000;//getkey(axe_missile_velocity);
	dir = aim(self, vel);
	hazard_axehit(self.origin + '0 0 16', dir);

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		self.stats_total[W_AXE] += getkey(axe_damage);
	}
};

void() player_axea1 = [$axatta1, player_axea2] {self.weaponframe = 1;};
void() player_axea2 = [$axatta2, player_axea3] {self.weaponframe = 2;};
void() player_axea3 = [$axatta3, player_axea4] {self.weaponframe = 3;player_axe();};
void() player_axea4 = [$axatta4, player_run] {self.weaponframe = 4;};

void() player_axeb1 = [$axattb1, player_axeb2] {self.weaponframe = 5;};
void() player_axeb2 = [$axattb2, player_axeb3] {self.weaponframe = 6;};
void() player_axeb3 = [$axattb3, player_axeb4] {self.weaponframe = 7;player_axe();};
void() player_axeb4 = [$axattb4, player_run] {self.weaponframe = 8;};

void() player_axec1 = [$axattc1, player_axec2] {self.weaponframe = 1;};
void() player_axec2 = [$axattc2, player_axec3] {self.weaponframe = 2;};
void() player_axec3 = [$axattc3, player_axec4] {self.weaponframe = 3;player_axe();};
void() player_axec4 = [$axattc4, player_run] {self.weaponframe = 4;};

void() player_axed1 = [$axattd1, player_axed2] {self.weaponframe = 5;};
void() player_axed2 = [$axattd2, player_axed3] {self.weaponframe = 6;};
void() player_axed3 = [$axattd3, player_axed4] {self.weaponframe = 7;player_axe();};
void() player_axed4 = [$axattd4, player_run] {self.weaponframe = 8;};

void() player_shot1 = [$shotatt1, player_shot2]
{
	float  spread;
	vector org, dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	// If no ammo, choose another weapon
	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	makevectors(self.v_angle);

	self.weaponframe = 1;
	msg_entity = self;
	dir = aim(self, 100000);

	org = self.origin + v_forward*10 + '0 0 16';
	//org_z = self.absmin_z + self.size_z*0.7;

	if (self.weapon == IT_COILGUN)
	{
		// The instagib coilgun
		self.attack_finished = time + hasted_reload(getkey(coilgun_reload));

		hazard_coilgun(org, dir);

		gmapn_sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM, 0);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_CG] += 8 * getkey(bullet_damage);
		}
	}
	else if (self.ammo_shells < 2 || self.weapon == IT_SHOTGUN)
	{
		// Shotgun

		player_ammo_decrease(IT_SHELLS, 1);
		self.attack_finished = time + hasted_reload(getkey(shotgun_reload));

		spread = getkey(shotgun_spread);
		hazard_bullets(org, dir, "shotgun");

		gmapn_sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM, 0);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_SG] += 8 * getkey(bullet_damage);
		}
	}
	else
	{
		// Super shotgun

		player_ammo_decrease(IT_SHELLS, 2);
		self.attack_finished = time + hasted_reload(getkey(shotgun2_reload));

		spread = getkey(shotgun2_spread);
		hazard_bullets(org, dir, "supershotgun");

		gmapn_sound(self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM, 0);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_SSG] += 20 * getkey(bullet_damage);
		}
	}

	self.currentammo = self.ammo_shells;
};
void() player_shot2 = [$shotatt2, player_shot3] {self.weaponframe = 2;};
void() player_shot3 = [$shotatt3, player_shot4] {self.weaponframe = 3;};
void() player_shot4 = [$shotatt4, player_shot5] {self.weaponframe = 4;};
void() player_shot5 = [$shotatt5, player_shot6] {self.weaponframe = 5;};
void() player_shot6 = [$shotatt6, player_run] {self.weaponframe = 6;};

void() player_spike1 = [$nailatt1, player_spike2]
{
	float spd;
	vector dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	makevectors(self.v_angle);

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
	{
		self.weaponframe = 1;
	}
	if (self.ammo_nails < 2 || self.weapon == IT_NAILGUN)
	{
		// Nailgun

		if (getkey(game_nailrecoil) == 1)
		{
			self.velocity = self.velocity - v_forward * 48; // recoil
		}

		player_ammo_decrease(IT_NAILS, 1);
		self.attack_finished = time + hasted_reload(getkey(spike_reload));
		spd = getkey(spike_velocity);
		dir = aim(self, spd);
		hazard_missile(self.origin + '0 0 16' + v_right*4, dir, spd, "spike");

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_NG] += getkey(spike_damage);
		}
	}
	else
	{
		// Super nailgun

		if (getkey(game_nailrecoil) == 1)
		{
			self.velocity = self.velocity - v_forward * 64; // recoil
		}

		player_ammo_decrease(IT_NAILS, 2);
		self.attack_finished = time + hasted_reload(getkey(spike2_reload));
		spd = getkey(spike2_velocity);
		dir = aim(self, spd);
		hazard_missile(self.origin + '0 0 16', dir, spd, "superspike");

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_SNG] += getkey(spike2_damage);
		}
	}

	self.currentammo = self.ammo_nails;
};

void() player_spike2 = [$nailatt2, player_spike1]
{
	float spd;
	vector dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	makevectors(self.v_angle);

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
	{
		self.weaponframe = 1;
	}
	if (self.ammo_nails < 2 || self.weapon == IT_NAILGUN)
	{
		// Nailgun
		if (getkey(game_nailrecoil) == 1)
		{
			self.velocity = self.velocity - v_forward * 48; // recoil
		}

		player_ammo_decrease(IT_NAILS, 1);
		self.attack_finished = time + hasted_reload(getkey(spike_reload));
		spd = getkey(spike_velocity);
		dir = aim(self, spd);
		hazard_missile(self.origin + '0 0 16' + v_right*(-4), dir, spd, "spike");

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_NG] += getkey(spike_damage);
		}
	}
	else
	{
		// Super nailgun

		if (getkey(game_nailrecoil) == 1)
		{
			self.velocity = self.velocity - v_forward * 64; // recoil
		}

		player_ammo_decrease(IT_NAILS, 2);
		self.attack_finished = time + hasted_reload(getkey(spike2_reload));
		spd = getkey(spike2_velocity);
		dir = aim(self, spd);
		hazard_missile(self.origin + '0 0 16', dir, spd, "superspike");

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_SNG] += getkey(spike2_damage);
		}
	}

	self.currentammo = self.ammo_nails;
};

void() player_grenade1 = [$rockatt1, player_grenade2]
{
	float spd;
	vector dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	player_ammo_decrease(IT_ROCKETS, 1);

	spd = getkey(grenade_velocity);
	dir = aim(self, spd);

	self.attack_finished = time + hasted_reload(getkey(grenade_reload));

	self.weaponframe = 1;
	hazard_grenade(self.origin + '0 0 8', dir, spd);

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		self.stats_total[W_GL] += getkey(grenade_damage);
	}

	self.currentammo = self.ammo_rockets;
};
void() player_grenade2 = [$rockatt2, player_grenade3] {self.weaponframe = 2;};
void() player_grenade3 = [$rockatt3, player_grenade4] {self.weaponframe = 3;};
void() player_grenade4 = [$rockatt4, player_grenade5] {self.weaponframe = 4;};
void() player_grenade5 = [$rockatt5, player_grenade6] {self.weaponframe = 5;};
void() player_grenade6 = [$rockatt6, player_run]	  {self.weaponframe = 6;};

void() player_rocket1 = [$rockatt1, player_rocket2]
{
	float spd;
	vector dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	player_ammo_decrease(IT_ROCKETS, 1);

	spd = getkey(rocket_velocity);
	dir = aim(self, spd);

	self.attack_finished = time + hasted_reload(getkey(rocket_reload));

	self.weaponframe = 1;
	hazard_missile(self.origin + '0 0 16', dir, spd, "rocket");

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		self.stats_total[W_RL] += getkey(rocket_damage);
	}

	self.currentammo = self.ammo_rockets;
};
void() player_rocket2 = [$rockatt2, player_rocket3] {self.weaponframe = 2;};
void() player_rocket3 = [$rockatt3, player_rocket4] {self.weaponframe = 3;};
void() player_rocket4 = [$rockatt4, player_rocket5] {self.weaponframe = 4;};
void() player_rocket5 = [$rockatt5, player_rocket6] {self.weaponframe = 5;};
void() player_rocket6 = [$rockatt6, player_run]		{self.weaponframe = 6;};

void() player_railgun1 = [$rockatt1, player_railgun2]
{
	float spd;
	vector dir;

	if (client_stopattacking() || self.ammo_cells < 10 || !(self.items & IT_RAILGUN))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	player_ammo_decrease(IT_CELLS, 10);

	spd = 10000;
	dir = aim(self, spd);

	self.attack_finished = time + hasted_reload(getkey(rail_reload));

	self.weaponframe = 1;
	hazard_railgun(self.origin + '0 0 16', self.origin + dir*spd);

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		self.stats_total[W_RG] += getkey(rail_damage);
	}

	self.currentammo = self.ammo_cells;
};
void() player_railgun2 = [$rockatt2, player_railgun3] {self.weaponframe = 2;};
void() player_railgun3 = [$rockatt3, player_railgun4] {self.weaponframe = 3;};
void() player_railgun4 = [$rockatt4, player_railgun5] {self.weaponframe = 4;};
void() player_railgun5 = [$rockatt5, player_railgun6] {self.weaponframe = 5;};
void() player_railgun6 = [$rockatt6, player_run]	  {self.weaponframe = 6;};

#ifdef HAVE_PORTALS
void() player_portal1 = [$rockatt1, player_rocket2]
{
	vector dir;

	if (client_stopattacking())// || !(self.items & IT_PORTALGUN))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	dir = aim(self, 1000);

	self.attack_finished = time + 0.6;

	self.weaponframe = 1;

	if (self.weapon == IT_PORTALGUN)
	{
		if (spawnaportal(self.origin + '0 0 16', dir, self, 0))
			client_setweapon(IT_PORTALGUN_ALT);
	}
	else
	{
		if (spawnaportal(self.origin + '0 0 16', dir, self, 1))
			client_setweapon(IT_PORTALGUN);
	}

};
#endif

void() player_lightning1 = [$light1, player_lightning2]
{
	vector org, dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	makevectors(self.v_angle);

	if (self.waterlevel >= 2)
	{
		// Discharge

		hazard_discharge();
	}
	else
	{
		player_ammo_decrease(IT_CELLS, 1);

		self.attack_finished = time + hasted_reload(getkey(lightning_reload));

		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe == 5)
		{
			self.weaponframe = 1;
		}
		org = self.origin + '0 0 16';
		dir = org + v_forward * (getkey(lightning_shortreach) ? 600 : 1000); // increased LG reach
		hazard_lightning(org, dir);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_LG] += getkey(lightning_damage);
		}
	}

	self.currentammo = self.ammo_cells;
};

void() player_lightning2 = [$light2, player_lightning1]
{
	vector org, dir;

	if (client_stopattacking())
	{
		player_setweapon();
		player_run();
		return;
	}

	if (!client_weaponokay(self.weapon))
	{
		client_setweapon(client_bestweapon());
		player_setweapon();
		player_run();
		return;
	}

	makevectors(self.v_angle);

	if (self.waterlevel >= 2)
	{
		// Discharge

		hazard_discharge();
	}
	else
	{
		player_ammo_decrease(IT_CELLS, 1);

		self.attack_finished = time + hasted_reload(getkey(lightning_reload));

		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe == 5)
		{
			self.weaponframe = 1;
		}
		org = self.origin + '0 0 16';
		dir = org + v_forward * 600;
		hazard_lightning(org, dir);

		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			self.stats_total[W_LG] += getkey(lightning_damage);
		}
	}

	self.currentammo = self.ammo_cells;
};
