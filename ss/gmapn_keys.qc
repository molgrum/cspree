/*
    gmapn_keys.qc

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

string NULL = __NULL__;
#define GAMEVARS	\
	GVS(info_hostname,		"Unnamed GMAPN Server",	NULL)\
	GVS(info_city,			"",	NULL)\
	GVS(info_state,			"",	NULL)\
	GVS(info_country,		"",	NULL)\
	GVS(allowedmodes,		"",	"list of allowed modes. blank for any")\
	GVF(allowbots,			0,	"If set, users are able to enable bots.")\
	GVF(game_lockrules,		0,	"If set, users are not allowed to change the rules.")\
	GVS(game_mode,			"duel",	"The set of scoring rules to utilise.")\
	GVF(game_loadout,		0,	NULL)\
	GVF(game_clientlimit,		12,	NULL)\
	GVF(game_botskill,		0,	NULL)\
	GVF(game_record,		1,	"Record an mvd, if enabled.")\
	GVF(game_itemtimers,		1,	"Displays timers at item locations that display how long until the item respawns.")\
	GVF(game_rounds,		5,	NULL)\
	GVS(maprotation,		"",	"Optional list of maps to rotate on the server, space separated.")\
	GVF(minplayers,			0,	NULL)\
	GVF(maxplayers,			12,	NULL)\
	GVF(minteamsize,		0,	NULL)\
	GVF(maxteamsize,		4,	NULL)\
	GVF(armor_accumulate,		0,	"Allows you to continue collecting armour, with the amount stacking")\
	GVF(armor1_absorb,		0.30,	NULL)\
	GVF(armor1_amount,		100,	NULL)\
	GVF(armor2_absorb,		0.6,	NULL)\
	GVF(armor2_amount,		150,	NULL)\
	GVF(armor3_absorb,		0.8,	NULL)\
	GVF(armor3_amount,		200,	NULL)\
	GVF(axe_new,			0,	"Use more predictable axe attack timings")\
	GVF(axe_damage,			20,	NULL)\
	GVF(axe_push,			1.0,	NULL)\
	GVF(axe_push_frozen,		3.0,	"Pushback multiplier for axe hits against frozen targets. Applies in freezetag or when the player is staring at mod menus.")\
	GVF(axe_reload,			0.5,	NULL)\
	GVF(bullet_damage,		3.0,	NULL)\
	GVF(bullet_push,		1.0,	NULL)\
	GVF(bullet_spread,		1,	NULL)\
	GVF(entities_rotatefix,		1,	NULL)\
	GVF(prewar_countdown,		10,	NULL)\
	GVF(forcestart_countdown,	30,	NULL)\
	GVF(powerups_enabled,		1,	NULL)\
	GVF(hook_enabled,		0,	NULL)\
	GVF(overtime,			3,	NULL)\
	GVF(game_gibthreshhold,		-40,	NULL)\
	GVF(game_cpmajump,		0,	NULL)\
	GVF(game_fairpacks,		0,	"0 = drops current weapon\n1 = drops last fired weapon\n2 = drops current weapon only if firing.")\
	GVF(game_fastlifts,		0,	NULL)\
	GVF(game_fastswitch,		1,	"NYI")\
	GVF(game_nailrecoil,		0,	"0 = Original nailgun recoil (N/A)\n1 = Use recoil for nailguns")\
	GVF(game_newwalk,		0,	NULL)\
	GVF(game_visiblepacks,		0,	NULL)\
	GVF(game_selfdamage,		1,	"fraction of damage done when hurting yourself")\
	GVF(game_teamdamage,		1,	"fraction of damage done to team members")\
	GVF(game_teamdamage_reflect,	0,	"fraction of damage done reflected to the attacker when hurting team members")\
	GVF(game_exittele,		0,	"1 = exit teleports to info_player_start")\
	GVF(grenade_aim_new,		0,	"0 = Old grenade aim best for old pitch limits)\n1 = New aim better for new pitch limits")\
	GVF(grenade_aim_norandom,	1,	"0 = Add random sideways velocity to the grenade)\n1 = Don't add random velocities to the aim")\
	GVF(grenade_damage,		120,	NULL)\
	GVF(grenade_push,		1.0,	NULL)\
	GVF(grenade_reload,		0.6,	NULL)\
	GVF(grenade_velocity,		600,	NULL)\
	GVF(laser_damage,		15,	NULL)\
	GVF(laser_push,			1.0,	NULL)\
	GVF(lightning_damage,		30,	NULL)\
	GVF(lightning_push,		1.0,	NULL)\
	GVF(lightning_reload,		0.2,	NULL)\
	GVF(respawn_ammo,		30,	NULL)\
	GVF(respawn_armor,		20,	NULL)\
	GVF(respawn_health,		20,	NULL)\
	GVF(respawn_mega,		20,	NULL)\
	GVF(respawn_pent,		300,	"Default to 300 seconds (5 minutes)")\
	GVF(respawn_quad,		60,	"Default to 60 seconds (1 minute)")\
	GVF(respawn_ring,		300,	"Default to 300 seconds (5 minutes)")\
	GVF(respawn_suit,		60,	"Default to 60 seconds (1 minute)")\
	GVF(respawn_weapon_dmm1,	30,	NULL)\
	GVF(respawn_weapon_dmm2,	5,	NULL)\
	GVF(rocket_damage,		110,	NULL)\
	GVF(rocket_push,		1.0,	NULL)\
	GVF(rocket_reload,		0.8,	NULL)\
	GVF(rocket_velocity,		1000,	NULL)\
	GVF(coilgun_reload,		0.7,	NULL)\
	GVF(shotgun_reload,		0.5,	NULL)\
	GVF(shotgun_spread,		0.005,	NULL)\
	GVF(shotgun2_reload,		0.7,	NULL)\
	GVF(shotgun2_spread,		0.015,	NULL)\
	GVF(spawn_drop,			0,	"0 = Original position of spawns\n1 = Drop the spawn to floor")\
	GVF(spawn_mode,			0,	"0 = Random spawns (normal qw)\n1 = Far enemy spawns (spawn the furthest from enemies)\n2 = Self select spawns (select spawn yourself)\n3 = weighted spawn chances")\
	GVF(spawn_telefrag,		1,	"0 = Avoid telefrags by waiting a few seconds until spawning\n1 = Telefrag merciless (original QW)")\
	GVF(spike_damage,		9,	NULL)\
	GVF(spike_push,			1.0,	NULL)\
	GVF(spike_reload,		0.2,	NULL)\
	GVF(spike_velocity,		1000,	NULL)\
	GVF(spike2_damage,		18,	NULL)\
	GVF(spike2_push,		1.0,	NULL)\
	GVF(spike2_reload,		0.2,	NULL)\
	GVF(spike2_velocity,		1000,	NULL)\
	GVF(teleport_angles,		0,	"0 = Angles are set after spawn angles (original)\n1 = Only yaw angles are set after spawn angles\n2 = Yaw angle is set after velocity direction")\
	GVF(teleport_entities,		0,	"0 = Only teleport players (orgiginal)\n1 = Teleport all entities touching the teleporter")\
	GVF(teleport_velocity,		0,	"0 = Set a constant velocity of 300 when you teleport\n1 = Preserve all velocity, merging x and y velocity\ninto one forward velocity and preserving z velocity\nas it is. If z velocity < 0 it is set to 0.")\
	GVF(runtests,				0,	"Run a simulation of bots playing on the server.")\
	GVF(rail,			0,	"Specifies whether the railgun is enabled or not. Converted to lightning gun otherwise.")\
	GVF(rail_damage,		110,	NULL)\
	GVF(rail_push,			1.0,	NULL)\
	GVF(rail_reload,		0.8,	NULL)\
	GVF(ctf_returntime,		20,	"Length of time until the flag is returned after being dropped.")\
	GVF(ctf_returnscore,		0,	"Points rewarded for returning your own flag.")\
	GVF(ctf_grabscore,		0,	"Points rewarded for grabbing an enemy flag.")\
	GVF(ctf_capturescore,		10,	"Points rewarded for capturing an enemy flag.")\
	GVF(headhunters_maxheads,	5,	"Maximum number of heads a player can carry at any time.")\
	GVF(freezetag_thawtime,		3,	"how long it takes to thaw people")\
	GVF(freezetag_thawinplace,	0,	"if 1, they respawn where they are, rather than respawning normally")\
	GVF(domination_capturetime,	5,	"time to capture a point")\
	GVF(domination_pointinterval,	5,	"1 point per")\
	GVF(domination_cap,		15,	"# points for being the first to start capturing a point")\
	GVF(domination_capassist,	10,	"# points for assisting a capture")\
	GVF(domination_defense,		10,	"# points for defending")


#define GVF(n,v,d) var float autocvar_g_##n = v;
#define GVS(n,v,d) var string autocvar_g_##n = v;

GAMEVARS

#undef GVF
#undef GVS

void setkey(string key, string val)
{
	cvar_set(strcat("g_", key), val);
};
#define getkey(n) autocvar_g_##n

float getkey_parseconfig(string cfgname)
{
	float f = fopen(cfgname, FILE_READ);
	string line;
	if (f >= 0)
	{
		while ((line = fgets(f)))
		{
			float argc = tokenize(line);
			if (!argc)
				continue;
			string cmd = argv(0);
			string val = argv(1);
			if (cmd == "set")
			{
				cmd = val;
				val = argv(2);
			}
			
			if (cvar_type(cmd))
				cvar_set(cmd, val);
			else if (cvar_type(strcat("g_", cmd)))
				cvar_set(strcat("g_", cmd), val);
			else 
				print("var ", cmd, " does not exist\n", cmd);
		}
		fclose(f);
		return TRUE;
	}
	return FALSE;
};

void getkey_writeconfig(string cfgname)
{
	float f = fopen(cfgname, FILE_WRITE);
	if (f < 0)
		return;

#define GVF(n,v,d) fputs(f, sprintf("set g_%s\t\"%g\"\t%s\n", #n, v, (d?strcat("//", strreplace("\n", ", ", d)):"")));
#define GVS(n,v,d) fputs(f, sprintf("set g_%s\t\"%s\"\t%s\n", #n, v, (d?strcat("//", strreplace("\n", ", ", d)):"")));
	GAMEVARS
#undef GVF
#undef GVS
	fputs(f, sprintf("timelimit 10 \n"));
	fclose(f);
};

void getkey_reset()
{
	//determine the current mode name
	string modename = gmapn_gamemodetostring(gmapn_gamemode);

	//global defaults
	getkey_parseconfig("configs/rules/default.cfg");

	//dmm overrides
	getkey_parseconfig(sprintf("configs/rules/dmm%g.cfg", deathmatch));

	//mode-specific overrides
	if (!getkey_parseconfig(sprintf("configs/rules/%s.cfg", modename)))
		dprint(sprintf("could not read configs/rules/%s.cfg\n", modename));
	
	//map-specific overrides
	getkey_parseconfig(sprintf("configs/maps/%s.cfg", mapname));
	//map-mode-specific settings...
	getkey_parseconfig(sprintf("configs/maps/%s/%s.cfg", modename, mapname));

	gmapn_update_defaults_mod();
	gmapn_update_defaults_srv();
};

/*
float ConsoleCmd(string s)
{
	tokenize(s);
	if (argv(0) == "writeconfig")
		getkey_writeconfig("configs/example_reset.cfg");
	return TRUE;
};
*/
