/*
	globals.qc

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
//						 Q U A K E	 V A R I A B L E S						 //
///////////////////////////////////////////////////////////////////////////////

void()	func_null = {};
string	string_null;		// null string, nothing should be held here
entity	activator;			// the entity that activated a trigger or brush
float	framecount;

//
// cvars locked in as appropriate
//

float	teamplay;
float	timelimit;
//float	fraglimit;
float	deathmatch;
float	coop;
float	skill;	//mostly so monsters can spam stuff on nightmare.

string	nextmap;	//for coop.

float global_items;	//for coop. contains silver/gold keys, so disconnecting players won't destroy shared items



///////////////////////////////////////////////////////////////////////////////
//						 G M A P N	 V A R I A B L E S						 //
///////////////////////////////////////////////////////////////////////////////

float gmapn_qsg_has_fte_isbackbuffered;
float gmapn_qsg_has_fte_solid_ladder;
float gmapn_qsg_has_dp_qc_fs_search;
float gmapn_qsg_has_dp_sv_playerphysics;
float gmapn_qsg_has_fte_sql;
float gmapn_qsg_has_zq_vwep;
float gmapn_qsg_has_ext_csqc;

float gmapn_rpickup_maxpredefinedteams = 4;

float gmapn_serverstate;
   float gmapn_serverstate_prewar = 0;
   float gmapn_serverstate_countdown = 1;
   float gmapn_serverstate_playing = 2;
   float gmapn_serverstate_intermission = 3;
   float gmapn_serverstate_forcestart = 4;
   float gmapn_serverstate_breather = 5;
   float gmapn_serverstate_lockready = 6;

float gmapn_recording;

float gmapn_gametype_ffa = 0;
float gmapn_gametype_1on1 = 1;
float gmapn_gametype_2on2 = 2;
float gmapn_gametype_3on3 = 3;
float gmapn_gametype_4on4 = 4;

float gmapn_roundnum;

float gmapn_gamemode;

int gmapn_coop_respawntokens;
entity gmapn_secondchancer; // for duel arena's "second chance"
entity gmapn_monarchofthemound;
//The current king-of-the-hill. only this player's kills/deaths reward frags (and killers of the king become the new king)
entity gmapn_gamemaster;	//this is the player that is currently in charge of the game rules.

string gmapn_team_red;
string gmapn_team_blue;

string gmapn_team_hiders;  // For use with Hide & Seek
string gmapn_team_seekers; // ^^^^^^^^^^^^^^^^^^^^^^^^
float gmapn_flag_found;
entity gmapn_flag_carrier;

var float gmapn_matchstarttimems;	//global stat that marks the time that the match started at, for more reliable client-side gameclocks.

float  vote_in_progress; // 0 = no voting, ok to start a vote, else don't
entity evoter;			  // set a think function that executes if a vote passes

string gmapn_demoname;

/*
var float default_game_loadout = 0;
var float default_game_botskill = 0;
var float default_game_rounds = 5;
var float default_minplayers = 0;
var float default_maxplayers = 12;
var float default_powerups_enabled = 1;
var float default_deathmatch = 3;
var float default_timelimit = 10;
var float default_antilag = 1;
var float default_minping = 0;
*/
// FIXME: Remaining unused declarations

/*
float	movedist;
entity	damage_attacker;		// set by T_Damage
entity	damage_inflictor;
var float		rj						=		1;

//
// quakeed fields
//

.float			light_lev;				// not used by game, but parsed by light util
.float			style;

//
// monster ai
//

.void()			th_stand;
.void()			th_walk;
.void()			th_run;
.void()			th_missile;
.void()			th_melee;
.void(entity attacker, float damage)			th_pain;
.void()			th_die;

.float	search_time;
.float	attack_state;

.float			air_finished;	// when time > air_finished, start drowning
.float			bubble_count;	// keeps track of the number of bubbles

*/
