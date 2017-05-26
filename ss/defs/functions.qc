/*
    functions.qc

    Copyright (C) 2007 Mark Olsen
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

///////////////////////////////////////////////////////////////////////////////
//                       G M A P N   F U N C T I O N S                       //
///////////////////////////////////////////////////////////////////////////////

/*
 * client.qc
 */

void(entity targ, entity attacker) client_obituary;
void() client_pack_throw;
void(float sameplace) client_spawn;
void() respawn_living;
float() client_weaponokay;
void(entity player) client_setsemispectator;
void(entity player) client_clearsemispectator;
void(float flag) client_setweapon;

/*
 * gmapn_aliasstuffer.qc
 */

void(entity player) gmapn_aliasstuffer_start;

/*
 * gmapn_anticheat.qc
 */

.float angles_previous;
void() gmapn_detect_fast_angles;

/*
 * gmapn_config.qc
 */

void() gmapn_config_load;
void(string cfg) gmapn_config_exec;

/*
 * gmapn_countdown.qc
 */

float gmapn_countdown_style_prewar = 0;
float gmapn_countdown_style_game = 1;
float gmapn_countdown_style_round = 2;
float gmapn_countdown_style_forcestart = 3;

void(float length, void() triggerfunc, float countdownstyle) gmapn_countdown_start;
void() gmapn_countdown_stop;
void() gmapn_countdown_think;

/*
 * gmapn_disconnected.qc
 */

void(entity disconnected_player) gmapn_disconnected_player;
float(entity reconnected_player) gmapn_reconnected_player;

/*
 * gmapn_game.qc
 */

float() game_is_tied;
void(float countdowntime) gmapn_game_beginpregamecountdown;
void() gmapn_game_endpregamecountdown;
void() gmapn_game_end;
void() gmapn_game_start;
void() gmapn_round_restart;
void() gmapn_round_end;

/*
 * gmapn_help.qc
 */
void() gmapn_print_tipoftheday;

/*
 * gmapn_init.qc
 */

void() gmapn_detectserver;
void() gmapn_init;
void() gmapn_init_entities;
void() gmapn_update_defaults_mod;
void() gmapn_update_defaults_srv;
void() gmapn_init_test;
void() gmapn_readconfig;

/*
 * gmapn_latency.qc
 */

void() gmapn_latency_check_init;
void() gmapn_latency_check_loop;
/*
 * gmapn_lightstyle.qc
 */

void() gmapn_lightstyle_reset;
void(float intensity, float duration) gmapn_lightstyle_fade_start;
void() gmapn_lightstyle_fade_stop;

/*
 * gmapn_mapvote.qc
 */

void() gmapn_mapvote_countvotes;
string() gmapn_mapvote_getvote;
void() gmapn_mapvote_removevote;
void(string mapstr) gmapn_mapvote_addvote;

/*
 * gmapn_misc.qc
 */

void(string classnamestr) gmapn_reset_entities;
void(entity source, vector destination) gmapn_telefrag_check;

/*
 * gmapn_powerups.qc
 */

void() gmapn_powerups_disable;
void() gmapn_powerups_enable;
void() gmapn_powerups_toggle;
void() gmapn_powerups_setitems;

/*
 * gmapn_menu.qc
*/

float() gmapn_display_rules;

/*
 * gmapn_votefuncs.qc
 */
void() gmapn_newrulemaker;
void() gmapn_kick;
void() gmapn_ban;
void() gmapn_mute;

/*
 * gmapn_rules.qc
*/
float(float m) gmapn_ismatchless;
float(string m) gmapn_gamemodefromstring;
string(float m) gmapn_gamemodetostring;
string(float m) gmapn_gamemodefullname;
float(float m) gmapn_gamemode_rounds;
void() gmapn_rules_cliententered;
void() gmapn_rules_handleconnect;
void() gmapn_evaluategamemaster;
void(entity killer, entity victim, float delta) gmapn_scorefrags;
void(entity victim, float delta) gmapn_suicidefrags;
void(entity killer, entity victim, float delta) gmapn_teamkillfrags;
string() gmapn_nextmap;

void() domination_startup;
void() headhunter_startup;
void() ctf_player_died;	//player died/disconnected. chucks the flag away.
void(float flagstate) ctf_enableflags;

/*
 * gmapn_qsg.qc
 */

void(entity player, string team, float topcolour, float mottomcolour) gmapn_setteamandcolour;

/*
 * gmapn_reset.qc
 */

void() gmapn_reset_starttimer;
void() gmapn_reset_stoptimer;

/*
 * gmapn_rpickup.qc
 */

void() gmapn_rpickup_countvotes;

/*
 * gmapn_sql.qc
 */

void() gmapn_sql_init;
void() gmapn_sql_welcome;
void() gmapn_sql_logmatch;

/*
 * gmapn_stats.qc
 */
float gmapn_game_stats_printline(float hit, float total, string prefix);
void gmapn_game_stats();

/*
 * gmapn_subs.qc
 */

void(vector tdest, float tspeed, void() func) calcmove;
void() gmapn_id_angles_sucks;
float(entity targ, entity inflictor) candamage;
void(entity inflictor, entity victim, float damage) gmapn_blood;
void(entity targ, entity attacker) gmapn_death;
void() gmapn_dropspawn;
float(entity inflictor, float damage, float push, entity ignore, float dtflag) gmapn_explosion;
float(entity victim, entity inflictor, float damage, float push) gmapn_impact;
void(entity victim, entity attacker) gmapn_kill;
void() self_destruct;
void() usetargets;

/*
 * gmapn_usercmd.qc
 */

void(string nick) cmd_rulemaker;
float(float argc) gmapn_handle_usercmd;

/*
 * gmapn_vote.qc
 */
void() gmapn_vote_reset;
float() gmapn_vote_init;
void(entity player, float votevalue) gmapn_vote;
void() gmapn_vote_countvotes;
float(entity e) gmapn_vote_check;

/*
 * entities/buttons.qc
 */

void() button_release;
void() button_reset;

/*
 * entities/doors.qc
 */

void() door_done;
void() door_reset;
void() door_secret_pos1;
void() door_secret_pos1_move;
void() door_secret_pos2;
void() door_secret_close;
void() door_secret_done;

/*
 * entities/plats.qc
 */

void() plat_done;
void() plat_reset;

/*
 * entities/teleports.qc
 */

void() trigger_teleport;

/*
 * entities/trains.qc
 */

void() train_init;
void() train_move;

/*
 * entities/triggers.qc
 */

void() spikeshooter_use;

/*
 * models/player.qc
 */

void() player_death;
void() player_pain;

/*
 * monsters/ai.qc
 */
void() FoundTarget;

/*
 * helpers.
 */
#define redify(s) strconv(0,2,2,s)
#define alternate(s) strconv(0,5 + ((time*4)&1), 5 + ((time*4)&1),s)
#define flash(s) strconv(0,1 + ((time*4)&1), 1 + ((time*4)&1),s)
#define goldnmbr(s) strconv(0,3,3,s)
#define lowrcase(s) strconv(1,0,0,s)
#define brackets(s) sprintf("%s%s%s", chr2str(0x90), s, chr2str(0x91))
#define disconnected(s) sprintf("%s %s", chr2str(0x87), s)

#define URL_MAPLIST(url, mode, dmm) strcat(url, "maplist?mode=", gmapn_gamemodetostring(mode), "&dmm=", ftos(dmm))

#define SUB_Remove self_destruct
