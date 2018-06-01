/*
	fields.qc

	Copyright (C) 1996-1997	 Id Software, Inc.
	Copyright (C) 2007		 Mark Olsen
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

///////////////////////////////////////////////////////////////////////////////
//							Q U A K E	F I E L D S							 //
///////////////////////////////////////////////////////////////////////////////

noref .float  light_lev;
noref .string wad;

//
// world fields (FIXME: make globals)
//
.string map;
.float	worldtype;			// 0=medieval 1=metal 2=base
.float	style;
.float	count;				// for counting triggers
.string killtarget;
.entity oldenemy;			// mad at this player before taking damage
.float	speed;

//
// player only fields
//

.string userteam;		// the user's original team infokey, so we can restore it when the game ends etc.
.string	teamname;		// save some infokeys
.float	attack_finished;	// Reload interval
.float	beam_finished;		// LG charge interval
.float	damage_finished;	// Content damage interval
.float	death_finished;		// Respawn interval
.float	jump_finished;		// CPMA jumping
.float	pain_finished;		// Pain sound interval
.float	swim_finished;		// Swim sound interval

.float	voided;
.float	painframe;			// Used to animate player_pain
.float	walkframe;			// Used to animate player_run
.float	fly_sound;
.float	show_hostile;		// set to time+0.2 whenever a client fires a
							// weapon or takes damage.	Used to alert
							// monsters that otherwise would let the player go

.float	fallspeed;			// Player fall speed from previous frame
.float	deathtype;			// keeps track of how the player died
.float	newweapon;			// weapon selected to change to after firing current

//
// Additional client attributes
//

.float	ammo_heads;	//ish
.float	max_ammo_shells;
.float	max_ammo_nails;
.float	max_ammo_rockets;
.float	max_ammo_cells;
.float	max_megahealth;
.float	ring_time;
.float	pent_time;
.float	suit_time;
.float	quad_time;
.float	ring_finished;
.float	pent_finished;
.float	suit_finished;
.float	quad_finished;
.float	teaminfo_update;	//timer for teaminfo resends
.float	topcolor, bottomcolor;	// for saving color info on disconnects

//
// items
//

.string mdl;				// Temporary variable to store models while invisible
.float	time_respawn;		// Time until respawn (items)
.vector maxsize;
.vector minsize;
.vector mangle;				// angle at start

.vector oldorigin;				// only used by secret door

//
// doors, etc
//

.float	wait;					// time from firing to restarting
.float	delay;					// time from activation to firing
.float	t_length;
.float	t_width;
.entity trigger_field;	// door's trigger entity
.string noise4;

//
// monsters
//

.float	pausetime;
.entity movetarget;

//
// doors
//

.float	dmg;					// damage done by door when hit

//
// misc
//

.float	cnt;					// misc flag

//
// subs
//

.void() think1;
.vector finaldest;

//
// plats / doors / buttons
//

.float	lip;
.float	state;
.vector pos1;			  // top and bottom positions
.vector pos2;
.float	height;

//
// sounds
//

.float	attenuation;
.float	channel;

///////////////////////////////////////////////////////////////////////////////
//							G M A P N	F I E L D S							 //
///////////////////////////////////////////////////////////////////////////////

.float	latency;
.float	ready;
.float rulesel;	//main option on the menu
.float subsel;  // misc options
.float mapsel;  // map list
.float viewingrules;	//timer when the menu should next be resent
.float	vote_rpickup;

.float csqcactive;	//our csprogs is running on this client. yay.
.float movetime;	//the time until the menu remains mostly hidden.
.float menutime;	//for hiding the menu completely

// String field to hold whatever
.string str;

.float	vote;
enum
{
	VOTE_NULL,	  // no vote yet
	VOTE_ABSTAIN, // don't care
	VOTE_YES,	  // sounds good
	VOTE_NO,	  // no thanks
	VOTE_TOTAL	  // for reference
};

// Selected spawn with spawn_mode 2
.entity my_spawn;

// Last axe animation (used for sequential axe attacks instead of random)
.float	axe_attack;

// Used by fairpacks
.float	lastweap;

enum
{
	TK_QUAD,
	TK_PENT,
	TK_RING,
	TK_SUIT,
	TK_RA,
	TK_YA,
	TK_GA,
	TK_MH
};
string tknames[] = {"quad", "pent", "ring", "suit", "ra", "ya", "ga", "mh"};
.float stats_took[tknames.length];

// Weapon statistics
enum
{
	W_AXE,
	W_SG,
	W_SSG,
	W_NG,
	W_SNG,
	W_GL,
	W_RL,
	W_LG,
	W_RG,
	W_CG
};

string wnames[] = {"axe", "sg", "ssg", "ng", "sng", "gl", "rl", "lg", "rg", "cg"};

.float stats_hit[wnames.length];
.float stats_total[wnames.length];
.float stats_sent[wnames.length];	//used as a cache to avoid spamming them (//wps foo is resent if it doesn't match the total)

// Efficiency
.float	stats_kills;	  // Number of enemies killed
.float	stats_deaths;	  // Number of times this player died

.float	stats_life_kills;
.float	stats_life_deaths;

// Midair
enum
{
	M_MIDAIR,
	M_SILVER,
	M_GOLD,
	M_DIAMOND
};

string mnames[] = {"midair", "silver", "gold", "diamond"};
.float stats_midair[mnames.length];

.float	is_fully_connected;

.float	connectedtime;	  // the time the player connected. may be negative if they joined on the previous map.
.float	challengertime;	  // the player with the lowest value here will be selected for the next duel challenger.
.float	matchtime;		  // the time of the match start

.entity thawplayer;	//the player that we're currently trying to thaw, or the control point that we're trying to capture.
.float	thawtime;	//the timestamp that the thawed player will thaw at.

.float found;		// boolean for hide & seek

.float runetime;	//next time for rune sounds (or regen effects)

// Movement vector for players
.vector movement;

//.float  jointtype;	  // ODE extension
//.float  mass;			  // ODE extension

.void(entity attacker, float damage) th_pain;
.void() th_die;
