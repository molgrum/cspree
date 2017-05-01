//matchless modes persist over map changes until enough people 'break'.
float gmapn_ismatchless(float m)
{
	switch(m)
	{
	case GM_FFA:			return TRUE;
	case GM_KING:			return TRUE;
	case GM_DA:			return TRUE;
	case GM_COOP:			return TRUE;
	case GM_DUEL:			return FALSE;
	case GM_HEADHUNTER:		return FALSE;
	case GM_TDEATHMATCH:		return FALSE;
	case GM_2ON2:			return FALSE;
	case GM_LASTMANSTANDING:	return FALSE;
	case GM_FREEZETAG:		return FALSE;
	case GM_DOMINATION:		return FALSE;
	case GM_ROVER:			return FALSE;
	case GM_CTF:			return FALSE;
	case GM_1FCTF:			return FALSE;
	case GM_HIDENSEEK:		return FALSE;

	default:			return FALSE;
	}
};

float gmapn_gamemodeneedsteam(float m)
{
	switch(m)
	{
	default:
	case GM_FFA:			return FALSE;
	case GM_KING:			return FALSE;	//teams are used, but players don't select them. teamplay is enabled after the first frag.
	case GM_DA:			return FALSE;
	case GM_COOP:			return FALSE;
	case GM_HEADHUNTER:		return FALSE;
	case GM_DUEL:			return FALSE;
	case GM_TDEATHMATCH:		return TRUE;
	case GM_2ON2:			return TRUE;
	case GM_LASTMANSTANDING:	return TRUE;
	case GM_FREEZETAG:		return TRUE;
	case GM_DOMINATION:		return TRUE;
	case GM_ROVER:			return FALSE;	//is a team game, but teams are random.
	case GM_CTF:			return TRUE;
	case GM_1FCTF:			return TRUE;
	case GM_HIDENSEEK:		return TRUE;
	}
};

string gmapn_gamemodetostring(float m)
{
	switch(m)
	{
	default:
	case GM_FFA:			return "ffa";
	case GM_KING:			return "king";
	case GM_DA:			return "darena";
	case GM_COOP:			return "coop";
	case GM_HEADHUNTER:		return "headhunt";
	case GM_DUEL:			return "duel";
	case GM_TDEATHMATCH:		return "tdm";
	case GM_2ON2:			return "2on2";
	case GM_LASTMANSTANDING:	return "lms";
	case GM_FREEZETAG:		return "freeze";
	case GM_DOMINATION:		return "dom";
	case GM_ROVER:			return "rover";
	case GM_CTF:			return "ctf";
	case GM_1FCTF:			return "1fctf";
	case GM_HIDENSEEK:			return "hide";
	}
};
string gmapn_gamemodefullname(float m)
{
	switch(m)
	{
	default:
	case GM_FFA:			return _("Free-For-All");
	case GM_KING:			return _("Kill The King");
	case GM_DA:			return _("Duel Arena");
	case GM_COOP:			return _("Co-Operative");
	case GM_HEADHUNTER:		return _("Head Hunters");
	case GM_DUEL:			return _("Duel");
	case GM_TDEATHMATCH:		return _("Team Deathmatch");
	case GM_2ON2:			return _("2-on-2");
	case GM_LASTMANSTANDING:	return _("Last Man Standing");
	case GM_FREEZETAG:		return _("Freezetag");
	case GM_DOMINATION:		return _("Domination");
	case GM_ROVER:			return _("Rover");
	case GM_CTF:			return _("Capture The Flag");
	case GM_1FCTF:			return _("One-Flag CTF");
	case GM_HIDENSEEK:		return _("Hide & Seek");
	}
};

float gmapn_gamemodefromstring(string m)
{
	if (m == "0")
		return 0;	//whichever that is
	else if (m == "ffa")
		return GM_FFA;
	else if (m == "deathmatch" || m == "tdm" || m == "4on4")
		return GM_TDEATHMATCH;
	else if (m == "2on2")
		return GM_2ON2;
	else if (m == "darena")
		return GM_DA;
	else if (m == "coop")
		return GM_COOP;
	else if (m == "duel")
		return GM_DUEL;
	else if (m == "king")
		return GM_KING;
	else if (m == "lastmanstanding" || m == "lms")
		return GM_LASTMANSTANDING;
	else if (m == "freezetag" || m == "ft" || m == "freeze")
		return GM_FREEZETAG;
	else if (m == "headhunter" || m == "hh" || m == "headhunt")
		return GM_HEADHUNTER;
	else if (m == "domination" || m == "dom")
		return GM_DOMINATION;
	else if (m == "rover")
		return GM_ROVER;
	else if (m == "ctf")
		return GM_CTF;
	else if (m == "1fctf")
		return GM_1FCTF;
	else if (m == "hide")
		return GM_HIDENSEEK;
	else
	{
		float r = stof(m);
		if (r == 0)
			return -1;
		return r;
	}
};

#ifndef CSQC

float gmapn_gamemode_rounds(float m)
{
	if (m == GM_DA)
		return getkey(game_rounds);
	if (m == GM_LASTMANSTANDING || m == GM_FREEZETAG || m == GM_ROVER)
		return getkey(game_rounds);
	if (m == GM_HIDENSEEK)
		return getkey(game_rounds);
	return 1;	//most game types don't do rounds.
};


float gmapn_gamemode_allowed(float mode)
{
	float modes = tokenize(getkey(allowedmodes));
	
	if (!modes)	//if none listed, anything goes.
	{
		if (mode == GM_1FCTF)
			return FALSE; //NYI
		return TRUE;
	}
		
	while (modes --> 0)
	{
		if (mode == gmapn_gamemodefromstring(argv(modes)))
			return TRUE;
	}
	return FALSE;
}

string gmapn_nextmap()
{
	float maps = tokenize(getkey(maprotation));
	string nextmaprotate = argv(0);

	if (!maps)
		return __NULL__;

	for (int i = 0; i < maps - 1; i++)
	{
		if (mapname == argv(i))
		{
			nextmaprotate = argv(i + 1);
		}
	}

	return nextmaprotate;
}

void gmapn_updatemaxclients()
{
	float lim = getkey(game_clientlimit);
	float max;
	//enforce maxclients primarily so that extra players can't join mid-game and ruin it.
	if (cvar("teamplay"))
		max = getkey(maxteamsize) * 2;
	else
		max = getkey(maxplayers);
	cvar_set("maxclients", ftos(min(lim,max)));
	cvar_set("maxspectators", ftos(lim - max));
};

void gmapn_apply_gamemode(float newmode)
{
	setkey("game_mode", gmapn_gamemodetostring(newmode));
	gmapn_gamemode = newmode;
	switch(gmapn_gamemode)
	{
	case GM_FFA:
	case GM_KING:	//initially off, at least.
	case GM_DA:
	case GM_HEADHUNTER:
	case GM_DUEL:
		cvar_set("deathmatch", "3");
		cvar_set("teamplay", "0");
		cvar_set("timelimit", "10");
		setkey("maxplayers", "2");
		break;
	case GM_2ON2:
		cvar_set("deathmatch", "3");
		cvar_set("teamplay", "1");
		cvar_set("timelimit", "10");
		setkey("maxplayers", "4");
		break;
	case GM_HIDENSEEK:
		cvar_set("deathmatch", "6");
		cvar_set("teamplay", "1");
		cvar_set("timelimit", "2");
		setkey("maxplayers", "8");
		break;
	default:	//other game modes are team games
		cvar_set("deathmatch", "1");
		cvar_set("teamplay", "1");
		cvar_set("timelimit", "20");
		setkey("maxplayers", "8");
		break;
	}

	getkey_reset();
	gmapn_powerups_setitems();
	gmapn_updatemaxclients();
};

void gmapn_evaluategamemaster()
{
	entity o = gmapn_gamemaster;
	
	gmapn_gamemaster = world;
	if (gmapn_serverstate < gmapn_serverstate_playing)
	{
		//first look for VIPs.
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (clienttype(e) == CLIENTTYPE_BOT)
				continue;	//bots don't count...
			if (stof(infokey(e, "*VIP")))
			{
				if (!gmapn_gamemaster || e.connectedtime < gmapn_gamemaster.connectedtime)
					gmapn_gamemaster = e;
			}
		}
		
		//have another look when there were no VIPs.
		if (!gmapn_gamemaster && !getkey(game_lockrules))
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (clienttype(e) == CLIENTTYPE_BOT)
				continue;	//bots don't count...
			if (!gmapn_gamemaster || e.connectedtime < gmapn_gamemaster.connectedtime)
				gmapn_gamemaster = e;
		}
	}
	
	if (gmapn_gamemaster != world && gmapn_gamemaster != o)
	{
		bprint(PRINT_HIGH, gmapn_gamemaster.netname, " is now the rule maker\n");
	}
};
float gmapn_isgamemaster(entity e)
{
	if (stof(infokey(e, "*VIP")))
		return TRUE;
	if (e == gmapn_gamemaster)
		return TRUE;
	if (getkey(game_lockrules) < 0)
		return 2;	//anyone can change the rules
	return FALSE;
};

static entity findliveteamplayer(entity last, string theteam)
{
	while ((last = find(last, classname, "player")))
	{
		if (last.deadflag)
			continue;
		if (last.teamname == theteam)
			return last;	//this one will do
	}
	return world;	//no more
}
void gmapn_checklastplayer(string theteam)
{
	if (!teamplay)
		return;
	entity player = findliveteamplayer(world, theteam);
	if (!player)
		return;	//err, that WAS the last player!
	if (findliveteamplayer(player, theteam))
		return;	//there's another player, no worries

	// FIXME: nonexistent sound file
	//stuffcmd(player, "play \"announcer/lastman.wav\"\n");
	centerprint(player, "You're the last man alive!");
};

void(entity killer, entity victim, float delta) gmapn_scorefrags = 
{
	if (gmapn_gamemode == GM_ROVER)
	{	//victims are moved over to the killer's team
		bprint(PRINT_HIGH, victim.netname, " was killed by ", killer.netname, "\n");
		victim.teamname = killer.teamname;
		forceinfokey(victim, "team", victim.teamname);
		forceinfokey(victim, "topcolor", infokey(killer, "topcolor"));
		forceinfokey(victim, "bottomcolor", infokey(killer, "bottomcolor"));
	}
	if (gmapn_gamemode == GM_KING)
	{
		if (!gmapn_monarchofthemound || (victim == gmapn_monarchofthemound && killer != gmapn_monarchofthemound))
		{
			if (gmapn_monarchofthemound)
			{
				gmapn_setteamandcolour(gmapn_monarchofthemound, "pleb", 3, 3);
			}
			else
				cvar_set("teamplay", "1");	//now that we actually have different teams, we need to enable teamplay so that skin forcing works.
			gmapn_monarchofthemound = killer;
			bprint(PRINT_HIGH, gmapn_monarchofthemound.netname, " is now the king!\n");
			gmapn_setteamandcolour(gmapn_monarchofthemound, "king", 13, 13);
		}
		//only the king is allowed to get points from killing.
		if (killer != gmapn_monarchofthemound)
			return;
	}
	if (gmapn_gamemode == GM_DOMINATION)
	{
		//extra points if the killer is near a control point.
		for (entity e = world; (e = find(e, classname, "info_controlpoint")); )
		{
			if (vlen(e.origin - killer.origin) < 256)
			{
				if (e.teamname == killer.teamname)
				{
					// FIXME: nonexistent sound file
					//stuffcmd(killer, "play \"announcer/defence.wav\"\n");
					centerprint(killer, "Defended!");
					delta += getkey(domination_defense);
					break;
				}
			}
		}
	}
	if (gmapn_gamemode == GM_CTF)
	{
		//extra points if the killer is near a control point.
		for (entity e = world; (e = find(e, classname, "info_controlpoint")); )
		{
			if (vlen(e.origin - killer.origin) < 256)
			{
				if (e.teamname == killer.teamname)
				{
					// FIXME: nonexistent sound file
					//stuffcmd(killer, "play \"announcer/defence.wav\"\n");
					centerprint(killer, "Defended!");
					delta += getkey(domination_defense);
					break;
				}
			}
		}
	}
	if (gmapn_gamemode == GM_HEADHUNTER)
		return;	//headhunter only awards frags when you capture the heads.
/*	if (gmapn_gamemode == GM_HIDENSEEK)
	{
		if (victim.teamname == gmapn_team_hiders && victim.found == FALSE && killer != world && killer != victim)
		{
			self.found = TRUE;
			client_setsemispectator(self);
		}

		return; //only award frags if all hidden players are killed
		}*/
	if (gmapn_gamemode == GM_LASTMANSTANDING || gmapn_gamemode == GM_FREEZETAG)
	{
		gmapn_checklastplayer(victim.teamname);
		return;	//LMS awards points only if you are the last player alive. FT is basically LMS+respawns
	}
	killer.frags += delta;
	if (teamplay)
		gmapn_game_score_teampoint(killer.teamname, delta);
};
void(entity victim, float delta) gmapn_suicidefrags = 
{
	if (gmapn_gamemode == GM_LASTMANSTANDING || gmapn_gamemode == GM_FREEZETAG)
	{
		gmapn_checklastplayer(victim.teamname);
		return;	//LMS doesn't care too much about idiots
	}
	victim.frags += delta;
	if (teamplay)
		gmapn_game_score_teampoint(victim.teamname, delta);
};
void(entity killer, entity victim, float delta) gmapn_teamkillfrags = 
{
	if (gmapn_gamemode == GM_LASTMANSTANDING || gmapn_gamemode == GM_FREEZETAG)
	{
		gmapn_checklastplayer(victim.teamname);
		return;	//should probably disable team damage.
	}
	killer.frags += delta;
	if (teamplay)
		gmapn_game_score_teampoint(killer.teamname, delta);
};



//domination!
void controlpoint_reset()
{
	self.model = 0;
	self.effects = 0;
	self.teamname = 0;	//this is the name of the team that owns the controlpoint
	self.colormod = '0 0 0';
	
	self.pflags = 0;
	self.light_lev = 0;
	self.color = '0 0 0';
};
static void controlpoint_touch()
{
	if (other.classname != "player" || other.deadflag || gmapn_serverstate != gmapn_serverstate_playing)
		return;
	if (other.thawplayer)	//player is already busy
		return;
	if (other.teamname == self.teamname)	//the guy's team already owns the point.
		return;
	other.thawplayer = self;
	other.thawtime = time + getkey(domination_capturetime);
};
static void controlpoint_think()
{
	entity p;
	for (p = world; (p = find(p, classname, "player")); )
	{
		if (p.teamname == self.teamname)
			p.frags += 1;
	}

	self.nextthink = time + getkey(domination_pointinterval);
};
/*QUAKEED stuff*/
void info_controlpoint()
{
	if (!self.mdl)
	{
		self.mdl = "progs/v_spike.mdl";	//vore-ball
		self.avelocity = '300 300 300';
		self.scale = 3;
	}
	precache_model(self.mdl);
	
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;	//not active yet.
	self.touch = controlpoint_touch;
	self.think = controlpoint_think;
	
	//drop it to the floor, then make it big.
	//biased towards mins_z so that the control points are a little more visible relative to any items that may be at the same spot
	setsize(self, '-16 -16 -56', '16 16 0');
	droptofloor();
	setsize(self, '-128 -128 -56', '128 128 0');
};
//spawns a control point from an existing map entity, in the case of none provided by the map
float domination_legacycontrolpoints(string existing)
{
	float points = 0;
		
	entity e;
	for (e = world; (e = find(e, classname, existing)); )
	{
		self = spawn();
		self.origin = e.origin + [0,0,e.mins_z + 56];
		self.classname = "info_controlpoint";
		info_controlpoint();
		points += 1;
	}
	return points;
};
void domination_startup()
{
	float points = 0;
	for (self = world; (self = find(self, classname, "info_controlpoint")); )
		points += 1;

	if (!points)
	{
		if (points < 3)
			points += domination_legacycontrolpoints("item_sigil");
		if (points < 3)
			points += domination_legacycontrolpoints("item_key1");
		if (points < 3)
			points += domination_legacycontrolpoints("item_key2");
		if (points < 3)
			points += domination_legacycontrolpoints("weapon_rocketlauncher");
		if (points < 3)
			points += domination_legacycontrolpoints("weapon_lightning");
		if (points < 3)
			points += domination_legacycontrolpoints("weapon_grenadelauncher");
		if (points < 3)
			points += domination_legacycontrolpoints("item_armorInv");
		if (points < 3)
			points += domination_legacycontrolpoints("item_armor2");
		if (points < 3)
			points += domination_legacycontrolpoints("item_armor1");
		if (!points)
			points += domination_legacycontrolpoints("info_player_start");
		if (!points)
			points += domination_legacycontrolpoints("info_player_deathmatch");
	}

	for (self = world; (self = find(self, classname, "info_controlpoint")); )
	{
		self.solid = SOLID_TRIGGER;
		setmodel(self, self.mdl);
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
		self.effects = EF_NODEPTHTEST|EF_FULLBRIGHT;
	}
};

static void headhunter_altar_touch()
{
	if (other.classname != "player" || other.deadflag || gmapn_serverstate != gmapn_serverstate_playing)
		return;
	if (other.ammo_heads)
	{
		bprint(PRINT_MEDIUM, other.netname, " recovers ", ftos(other.ammo_heads), " heads.\n");
		centerprint(other, "The gods thank you for your contribution of\n", redify(ftos(other.ammo_heads)), " heads");

		//give them 3 seconds of pent for each head
		other.effects = EF_RED;
		other.items |= IT_PENT;
		if (other.pent_finished < time)
			other.pent_finished = time;
		other.pent_finished += 3.0*other.ammo_heads;

		//and frags, and stuff
		other.frags += other.ammo_heads;
		other.ammo_heads = 0;
	}
};
/*QUAKEED stuff*/
void info_altar()
{
	if (!self.mdl)
	{
		self.mdl = "progs/v_spike.mdl";	//vore-ball
		self.avelocity = '300 300 300';
		self.scale = 3;
		self.effects = EF_FULLBRIGHT;
	}
	precache_model(self.mdl);
	
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;	//not active yet.
	self.touch = headhunter_altar_touch;
	
	//drop it to the floor, then make it big.
	//biased towards mins_z so that the control points are a little more visible relative to any items that may be at the same spot
	setsize(self, '-16 -16 -56', '16 16 0');
	droptofloor();
	setsize(self, '-128 -128 -56', '128 128 0');
};
//spawns a control point from an existing map entity, in the case of none provided by the map
float headhunter_legacyaltar(string existing)
{
	float points = 0;
		
	entity e = find(world, classname, existing);
	if (e)
	{
		self = spawn();
		self.origin = e.origin + [0,0,e.mins_z + 56];
		self.classname = "info_altar";
		self.effects = EF_RED;
		info_altar();
		points += 1;
	}
	return points;
};
void headhunter_startup()
{
	float points = 0;
	for (self = world; (self = find(self, classname, "info_altar")); )
		points += 1;

	if (!points)
	{
		if (!points)
			points += headhunter_legacyaltar("item_sigil");
		if (!points)
			points += headhunter_legacyaltar("item_key1");
		if (!points)
			points += headhunter_legacyaltar("item_key2");
		if (!points)
			points += headhunter_legacyaltar("weapon_rocketlauncher");
		if (!points)
			points += headhunter_legacyaltar("weapon_lightning");
		if (!points)
			points += headhunter_legacyaltar("weapon_grenadelauncher");
		if (!points)
			points += headhunter_legacyaltar("item_armorInv");
		if (!points)
			points += headhunter_legacyaltar("item_armor2");
		if (!points)
			points += headhunter_legacyaltar("item_armor1");
		if (!points)
			points += headhunter_legacyaltar("info_player_start");
		if (!points)
			points += headhunter_legacyaltar("info_player_deathmatch");
	}

	for (self = world; (self = find(self, classname, "info_altar")); )
	{
		self.solid = SOLID_TRIGGER;
		setmodel(self, self.mdl);
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	}
};

void gmapn_rules_autojointeam()
{
	if (self.teamname == "red")
		gmapn_setteamandcolour(self, "red", 4, 4);
	else if (self.teamname == "blue")
		gmapn_setteamandcolour(self, "blue", 13, 13);
	else
	{
		//count existing players
		float red = 0, blue = 0;
		for(entity e = world; (e = find(e, classname, "player")); )
		{
			if (e.teamname == "red")
				red += 1;
			else if (e.teamname == "blue")
				blue += 1;
		}

		//try not to favour either team
		if (red == blue)
		{
			if (random() < 0.5)
				red += 1;
			else
				blue += 1;
		}
		
		//and put them on the smaller team
		if (red < blue)
			gmapn_setteamandcolour(self, "red", 4, 4);
		else
			gmapn_setteamandcolour(self, "blue", 13, 13);
	}
};

void gmapn_rules_cliententered()
{
	if (clienttype(self) == CLIENTTYPE_BOT)
		self.ready = TRUE; // bots are always ready on join

	client_spawn(FALSE);
}

//new client just joined the server
void gmapn_rules_handleconnect()
{
	// 0 = join instantly as a player
	// 1 = join as a spectator
	// 2 = join as a player spectator
	float dospec = 0;
	float totalplayers;
	entity p;

	//in case they're a VIP really
	gmapn_evaluategamemaster();

	if (gmapn_serverstate != gmapn_serverstate_playing)
		return;

	totalplayers = -1; // subtract the client that is about to join
	p = find(world, classname, "player");
	while (p)
	{
		totalplayers++;
		p = find(p, classname, "player");
	}
	switch(gmapn_gamemode)
	{
	case GM_KING:	//joining players become plebs
		gmapn_setteamandcolour(self, "pleb", 3, 3);
		break;
	case GM_ROVER:	//don't need to bother with teams. that'll be handled when spec-players are pulled in for the new round.
		dospec = 1;
		break;
	case GM_DA:	//new players should be spectators rather than instantly a challenger. because it would be unfair
		dospec = 1;
		break;
	case GM_DUEL:	//standard game modes allows players to join a running game if it needs player
	case GM_2ON2:
	case GM_TDEATHMATCH:
		if (totalplayers >= getkey(maxplayers))
			dospec = 1; // all player slots full
		break;
	case GM_HIDENSEEK:
	case GM_DOMINATION:
	case GM_CTF:
	case GM_FREEZETAG:
	case GM_LASTMANSTANDING:
		dospec = 1;
		gmapn_rules_autojointeam();
		break;
	}

	if (dospec != 0 && clienttype(self) != CLIENTTYPE_BOT)
	{
		if (dospec == 1)
			client_setspectator(self);
		else
			forceinfokey(self, "*spectator", "3");

		sprint(self, PRINT_HIGH, "Game is already in progress\n");
	}
	else
	{
		// delay for a bit so the sound plays
		self.nextthink = time + 0.01;
		self.think = gmapn_rules_cliententered;
	}
};

#endif
