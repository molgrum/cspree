#define MAPLIMIT 11

#define MENU_TITLE 0
#define MENU_VALUE 1
#define MENU_LEFT 2
#define MENU_RIGHT 3
#define MENU_ISNONADMIN 4
#define MENU_CLIENTCMD 5

#define KEY_NONE 0
#define KEY_UP 1
#define KEY_DOWN 2
#define KEY_RIGHT 4
#define KEY_LEFT 8
#define KEY_JUMP 16

#define SUBSEL_MAIN 0
#define SUBSEL_MAPS 1
#define SUBSEL_MOD 2
#define SUBSEL_SERVER 3

string gmapn_menu_matchlist(float keys);
.float matchfirst;
.float matchlistquery;
.float matchstatsquery;

.float oldmkeys;
.float viewingrules;	//timer when it should next be resent
.float subsel; // current submenu or main menu
.float rulesel;	//main option on the menu
.float mapsel;	//map or election
.float modsel;  //mod submenu
.float srvsel;  //advanced submenu
.float maps[MAPLIMIT]; // list of maps displayed
string gmapn_menuarg;

.float csqcactive;	//our csprogs is running on this client. yay.
.float movetime;	//the time until the menu remains mostly hidden.
.float menutime;	//for hiding the menu completely

entity gmapn_gamemaster;	//this is the player who is currently nominated to be the leader.
entity gmapn_monarchofthemound;

void() cmd_ready;
void() cmd_break;

static entity findreadyteamplayer(entity last, string theteam)
{
	while ((last = find(last, classname, "player")))
	{
		if (!last.ready)
			continue;
		if (last.teamname == theteam)
			return last;	//this one will do
	}
	return world;	//no more
}

static string menu_readyteam(float op)
{
	if (self.rulesel == -1)	//ready menu does not apply if game_lockmode is set.
		return 0;
	if (op == MENU_TITLE)
		return "Ready";
	if (op == MENU_VALUE)
	{
		if (self.ready)
			return "You are ready!";
		if (gmapn_gamemodeneedsteam(gmapn_gamemode))
		{
			string t = self.teamname;
			if (t != "red" && t != "blue")
				return "Please pick a team";
		}
		return "NOT ready";
	}
	if (op == MENU_LEFT)
	{
		if (gmapn_gamemodeneedsteam(gmapn_gamemode))
		{
			if (self.ready && self.teamname != "red")
				cmd_break();
			else
			{
				gmapn_setteamandcolour(self, "red", 4, 4);
				cmd_ready();
			}
		}
		else if (self.ready)
			cmd_break();
	}
	else if (op == MENU_RIGHT)
	{
		if (gmapn_gamemodeneedsteam(gmapn_gamemode))
		{
			if (self.ready && self.teamname != "blue")
				cmd_break();
			else
			{
				gmapn_setteamandcolour(self, "blue", 13, 13);
				cmd_ready();
			}
		}
		else if (!self.ready)
			cmd_ready();
	}
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	return 0;
};

/*
static string menu_ready(float op)
{
	if (self.rulesel == -1)	//ready menu does not apply if game_lockmode is set.
		return 0;
	if (op == MENU_TITLE)	
		return "Ready";
	if (op == MENU_VALUE)
	{
		if (self.ready)
			return "You are ready!";
		if (gmapn_gamemodeneedsteam())
		{
			string t = self.teamname;
			if (t != "red" && t != "blue")
				return "Please pick a team";
		}
		return "NOT ready";
	}
	if (op == MENU_LEFT)
		cmd_break();
	else if (op == MENU_RIGHT)
		cmd_ready();
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	else if (op == MENU_CLIENTCMD)
	{
		if (stof(gmapn_menuarg))
			cmd_ready();
		else
			cmd_break();
	}
	return 0;
};

static string menu_team(float op)
{
	if (!cvar("teamplay"))
		return 0;
	if (op == MENU_TITLE)
		return "Team";
	if (op == MENU_VALUE)
	{
		string t = self.teamname;
		if (t == "")
			return "<NO TEAM>";
		else if (((time*4) & 1) && t != "red" && t != "blue")
			return redify(t);
		return t;
	}
	if (op == MENU_LEFT && !self.ready)
		gmapn_setteamandcolour(self, "red", 4);
	else if (op == MENU_RIGHT && !self.ready)
		gmapn_setteamandcolour(self, "blue", 13);
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	else if (op == MENU_CLIENTCMD)
	{
		if (gmapn_menuarg == "red")
			gmapn_setteamandcolour(self, "red", 4);
		else if (gmapn_menuarg == "blue")
			gmapn_setteamandcolour(self, "blue", 13);
	}
	return 0;
};
*/

static void menu_mapvote_randomize()
{
	float mappoolsize, rnd;

	for (mappoolsize = 0; infokey(world, strcat("gmapn_map", ftos(mappoolsize))) != ""; mappoolsize++) { }

	for (float i = 0; i < MAPLIMIT; i++)
	{
		rnd = floor(random() * mappoolsize);
		self.maps[i] = rnd;
	}
};

static string menu_mapvote(float op)

{
	if (op == MENU_TITLE)
		return "Map Vote";
	else if (op == MENU_VALUE)
	{
		string myvote = gmapn_mapvote_getvote();
		if (myvote)
			return myvote;
		else
			return "Abstain";
	}
	else if (op == MENU_LEFT)
		gmapn_mapvote_removevote();
	else if (op == MENU_RIGHT)
	{
		menu_mapvote_randomize();
		self.subsel = SUBSEL_MAPS;
	}
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	return 0;
};

static string menu_time(float op)
{
	float val = cvar("timelimit");

	if (op == MENU_TITLE)
		return "Timelimit";
	else if (op == MENU_VALUE)
	{
		if (val)
			return sprintf("%g mins", val);
		else
			return "No Limit";
	}
	else if (op == MENU_LEFT)
		cvar_set("timelimit", ftos(max(3, val-((val>=15)?5:1))));
	else if (op == MENU_RIGHT)
		cvar_set("timelimit", ftos(min(30, val+((val>=10)?5:1))));
	else if (op == MENU_CLIENTCMD)
		cvar_set("timelimit", ftos(bound(3, stof(gmapn_menuarg), 30)));
	return 0;
};

static string menu_gamemode(float op)
{
	if (op == MENU_TITLE)
		return "Game Type";
	else if (op == MENU_VALUE)
	{
		return gmapn_gamemodefullname(gmapn_gamemode);
	}
	else if (op == MENU_LEFT)
	{
		float mode = gmapn_gamemode;
		while (--mode >= 0)
		{
			if (gmapn_gamemode_allowed(mode))
			{
				gmapn_apply_gamemode(mode);
				break;
			}
		}
	}
	else if (op == MENU_RIGHT)
	{
		mode = gmapn_gamemode;
		while (++mode < GM_MODES)
		{
			if (gmapn_gamemode_allowed(mode))
			{
				gmapn_apply_gamemode(mode);
				break;
			}
		}
	}
	else if (op == MENU_CLIENTCMD)
	{
		float nmode = gmapn_gamemodefromstring(gmapn_menuarg);
		if (nmode >= 0)
			gmapn_apply_gamemode(nmode);
	}
	return 0;
};

static string menu_gameskill(float op)
{
	float val;
	
	if (gmapn_gamemode != GM_COOP)
		return 0;

	if (op == MENU_TITLE)
		return "Game Skill";
	else if (op == MENU_VALUE)
	{
		switch(cvar("skill"))
		{
		case 0:		return "Easy";
		default:
		case 1:		return "Normal";
		case 2:		return "Hard";
		case 3:		return "Nightmare";
		}
	}
	else if (op == MENU_LEFT)
	{
		val = max(0, cvar("skill")-1);
		cvar_set("skill", ftos(val));
	}
	else if (op == MENU_RIGHT)
	{
		val = min(3, cvar("skill")+1);
		cvar_set("skill", ftos(val));
	}
	return 0;
}

static string menu_dmm(float op)
{
	float val;
	
	if (gmapn_gamemode == GM_COOP && !cvar("deathmatch"))
		return 0;

	if (op == MENU_TITLE)
		return "Deathmatch Mode";
	else if (op == MENU_VALUE)
	{
		switch(cvar("deathmatch"))
		{
		case 0:		return "Coop";
		default:
		case 1:		return "Normal";
		case 2:		return "Unplayed"; // :D
		case 3:		return "Weaponstay";
		case 4:		return "Stacked";
		case 5:		return "Midair";
		case 6:		return "Instagib";
		}
	}
	else if (op == MENU_LEFT)
	{
		val = max((gmapn_gamemode == GM_COOP)?0:1, cvar("deathmatch")-1);
		if (val == 2)
			val -= 1; // skip dmm2
		cvar_set("deathmatch", ftos(val));
	}
	else if (op == MENU_RIGHT)
	{
		val = min(6, cvar("deathmatch")+1);
		if (val == 2)
			val += 1; // skip dmm2
		cvar_set("deathmatch", ftos(val));
	}
	gmapn_powerups_setitems(cvar("deathmatch") < 4);
	return 0;
};

static string menu_loadout(float op)
{
	if (cvar("deathmatch") >= 4)
		return 0;

	int loadout = getkey(game_loadout);
	int i;

	for (i = 0; i < loadouts.length; i++)
		if (loadout == loadouts[i].fl)
			break;

	if (op == MENU_TITLE)
		return "Loadout";
	if (op == MENU_VALUE)
	{
		string s = "axe + sg";
		if (i == loadouts.length || !i)
			return s;
		else
			return strcat(s, " + ", loadouts[i].name);
		return s;
	}
	if (op == MENU_LEFT)
		setkey("game_loadout", ftos(loadouts[(i==0?loadouts.length:i)-1].fl));
	else if (op == MENU_RIGHT)
		setkey("game_loadout", ftos(loadouts[(i>=loadouts.length-1?0:i+1)].fl));
	return 0;
};

static string menu_minplayers(float op)
{
	float teams = gmapn_gamemodeneedsteam(gmapn_gamemode);
	float cur;

	if (teams)
	{
		cur = getkey(minteamsize);
		if (op == MENU_TITLE)
			return "Min Team Size";
		else if (op == MENU_VALUE)
		{
			if (cur < 0)
				return strcat("Balanced (", ftos(getkey(maxteamsize)), ")");
			return ftos(cur);
		}
		else if (op == MENU_LEFT)
			setkey("minteamsize", ftos(max(-1,cur-1)));
		else if (op == MENU_RIGHT)
			setkey("minteamsize", ftos(cur+1));
		else
			return 0;

		if (getkey(maxteamsize) < getkey(minteamsize))
			setkey("maxteamsize", ftos(getkey(minteamsize)));
		if (getkey(maxteamsize) > getkey(game_clientlimit)/2)
			setkey("maxteamsize", ftos(ceil(getkey(game_clientlimit)/2)));
		if (getkey(minteamsize) > getkey(maxteamsize))
			setkey("minteamsize", ftos(getkey(maxteamsize)));
		gmapn_updatemaxclients();
	}
	else
	{
		cur = getkey(minplayers);
		if (op == MENU_TITLE)
			return "Min Players";
		else if (op == MENU_VALUE)
			return ftos(cur);
		else if (op == MENU_LEFT)
			setkey("minplayers", ftos(max(0,cur-1)));
		else if (op == MENU_RIGHT)
			setkey("minplayers", ftos(cur+1));
		else
			return 0;

		if (getkey(maxplayers) < getkey(minplayers))
			setkey("maxplayers", ftos(getkey(minplayers)));
		if (getkey(maxplayers) > getkey(game_clientlimit))
			setkey("maxplayers", ftos(getkey(game_clientlimit)));
		if (getkey(minplayers) >= getkey(maxplayers))
			setkey("minplayers", ftos(getkey(maxplayers)));

		gmapn_updatemaxclients();
	}
	return 0;
};

static string menu_maxplayers(float op)
{
	float teams = gmapn_gamemodeneedsteam(gmapn_gamemode);
	float cur;

	if (teams)
	{
		cur = getkey(maxteamsize);

		if (op == MENU_TITLE)
			return "Max Team Size";
		else if (op == MENU_VALUE)
			return ftos(cur);
		else if (op == MENU_LEFT)
			setkey("maxteamsize", ftos(max(1,cur-1)));
		else if (op == MENU_RIGHT)
			setkey("maxteamsize", ftos(cur+1));
		else
			return 0;

		if (getkey(maxteamsize) > getkey(game_clientlimit)/2)
			setkey("maxteamsize", ftos(ceil(getkey(game_clientlimit)/2)));
		if (getkey(minteamsize) > getkey(maxteamsize))
			setkey("minteamsize", ftos(getkey(maxteamsize)));
		gmapn_updatemaxclients();
	}
	else
	{
		cur = getkey(maxplayers);

		if (op == MENU_TITLE)
			return "Max Players";
		else if (op == MENU_VALUE)
			return ftos(cur);
		else if (op == MENU_LEFT)
			setkey("maxplayers", ftos(max(1,cur-1)));
		else if (op == MENU_RIGHT)
			setkey("maxplayers", ftos(cur+1));
		else
			return 0;

		if (getkey(maxplayers) > getkey(game_clientlimit))
			setkey("maxplayers", ftos(getkey(game_clientlimit)));
		if (getkey(minplayers) >= getkey(maxplayers))
			setkey("minplayers", ftos(getkey(maxplayers)));
		gmapn_updatemaxclients();
	}
	return 0;
};

static string menu_botskill(float op)
{
	float val = getkey(game_botskill);
	if (op == MENU_TITLE)
	{
		if (!getkey(allowbots))
			return 0;
		return "Bot Difficulty";
	}
	else if (op == MENU_VALUE)
	{
		/* switch(val-1) */
		/* { */
		/* case -1: return "No bots"; */
		/* case 0: return "Clay Pidgin"; */
		/* case 1: return "Joke"; */
		/* case 2: return "Noobs"; */
		/* case 3: return "Mobile Victims"; */
		/* default: return "Glitch"; */
		/* } */
		return botskillname[val];
	}
	else if (op == MENU_LEFT)
		setkey("game_botskill", ftos(max(0, val-1)));
	else if (op == MENU_RIGHT)
		setkey("game_botskill", ftos(min(4, val+1)));

	return 0;
};

static string menu_rounds(float op)
{
	float val = getkey(game_rounds);
	float modhasrounds = FALSE;

	if (gmapn_gamemode_rounds(gmapn_gamemodefromstring(getkey(game_mode))) > 1)
	{
		modhasrounds = TRUE;
	}
	
	if (op == MENU_TITLE)
	{
		if (modhasrounds == TRUE)
			return "Rounds per game";
		else
			return 0;
	}
	else if (op == MENU_VALUE)
		return ftos(val);
	else if (op == MENU_LEFT)
		setkey("game_rounds", ftos(max(2, val-2)));
	else if (op == MENU_RIGHT)
		setkey("game_rounds", ftos(min(20, val+2)));

	return 0;
}

static string menu_powerups(float op)
{
	if (gmapn_gamemode == GM_COOP && getkey(powerups_enabled))
		return 0;

	if (op == MENU_TITLE)
		return "Powerups";
	else if (op == MENU_VALUE)
	{
		if (getkey(powerups_enabled) == 0)
			return "Disabled";
		else
			return "Enabled";
	}
	else if (op == MENU_LEFT)
	{
		if (getkey(powerups_enabled) != 0)
			gmapn_powerups_disable();
	}
	else if (op == MENU_RIGHT)
	{
		if (getkey(powerups_enabled) == 0)
			gmapn_powerups_enable();
	}
	return 0;
};

static string menu_rulemaker(float op)
{
	if (self.rulesel == -1)	//can't vote for anyone to change the rules if changing the rules is disabled.
		return 0;
	if (op == MENU_TITLE)
		return "Rule Maker";
	else if (op == MENU_VALUE)
	{
		if (getkey(game_lockrules) < 0)
			return "Anyone";
		if (gmapn_gamemaster)
			return gmapn_gamemaster.netname;
		return "Noone";
	}
	else if (op == MENU_LEFT)
	{
		if (gmapn_isgamemaster(self) == 0)
			return 0;
		if (getkey(game_lockrules) == 0)
			setkey("game_lockrules", "-1");
	}
	else if (op == MENU_RIGHT)
	{
		//don't allow it to be set to 1, because then noone can edit the rules.
		if (gmapn_isgamemaster(self) == 0)
			cmd_rulemaker(string_null); // elect yourself to rulemaker
		else if (getkey(game_lockrules) < 0)
			setkey("game_lockrules", "0");
	}
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	return 0;
};

static string menu_antilag(float op)
{
	if (op == MENU_TITLE)
		return "Lag Compensation";
	if (op == MENU_VALUE)
	{
		if (cvar("sv_antilag"))
			return "on";
		else
			return "off";
	}
	if (op == MENU_LEFT)
		cvar_set("sv_antilag", "");
	if (op == MENU_RIGHT)
		cvar_set("sv_antilag", "1");
	return 0;

};

static string menu_minping(float op)
{
	float val = cvar("sv_minping");

	if (op == MENU_TITLE)
		return "Min Ping";
	if (op == MENU_VALUE)
	{
		if (val)
			return sprintf("%g ms", val);
		else
			return "off";
	}

	if (op == MENU_LEFT)
	{
		if (val < 10)
			cvar_set("sv_minping", "");
		else
			cvar_set("sv_minping", ftos(val - 10));
	}
	if (op == MENU_RIGHT)
		cvar_set("sv_minping", ftos(min(300, val + 10)));

	return 0;
};

static string menu_spawnmode(float op)
{
	float spawnmode = getkey(spawn_mode);
	
	if (op == MENU_TITLE)
		return "Spawn mode";
	
	if (op == MENU_VALUE)
	{
		if (spawnmode == 1)
			return "Fair";
		else if (spawnmode == 2)
			return "Competitive";
		else
			return "UNKNOWN";
	}

	if (op == MENU_LEFT)
	{
		spawnmode -= 1;
		setkey("spawn_mode", ftos(max(1, spawnmode)));
	}

	if (op == MENU_RIGHT)
	{
		spawnmode += 1;
		setkey("spawn_mode", ftos(min(2, spawnmode)));
	}

	return 0;
}

void gmapn_menu_showmatches(void);
static string menu_pastmatches(float op)
{
	if (op == MENU_TITLE)
		return "Past matches";
	if (op == MENU_VALUE)
		return "";

	if (op == MENU_LEFT)
		;
	if (op == MENU_RIGHT)
		gmapn_menu_showmatches();
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	return 0;
};

static string menu_modoptions(float op)
{
	if (op == MENU_TITLE)
		return "Mod options";
	else if (op == MENU_VALUE)
		return "";
	else if (op == MENU_LEFT)
		;
	else if (op == MENU_RIGHT)
		self.subsel = SUBSEL_MOD;
	else if (op == MENU_ISNONADMIN)
		return ".";
	return 0;
}

static string menu_srvoptions(float op)
{
	if (op == MENU_TITLE)
		return "Server options";
	else if (op == MENU_VALUE)
		return "";
	else if (op == MENU_LEFT)
		;
	else if (op == MENU_RIGHT)
		self.subsel = SUBSEL_SERVER;
	else if (op == MENU_ISNONADMIN)
		return ".";
	return 0;
}

static string menu_back(float op)
{
	if (op == MENU_TITLE)
		return "Back";
	else if (op == MENU_VALUE)
		return "";
	else if (op == MENU_LEFT)
		self.subsel = SUBSEL_MAIN;
	else if (op == MENU_ISNONADMIN)
		return ".";
	return 0;
}

static string menu_spacer(float op)
{
	return "";
};

static string(float op) rules[] =
{
	menu_readyteam,
	menu_mapvote,
	menu_rulemaker,
	menu_spacer,
	menu_gamemode,
	menu_dmm,
	menu_time,
	menu_powerups,
	menu_pastmatches,
	menu_spacer,
	menu_modoptions,
	menu_srvoptions
};

static string(float op) rules_mod[] =
{
	menu_maxplayers,
	menu_minplayers,
	menu_rounds,
	menu_loadout,
	menu_spacer,
	menu_back
};

static string(float op) rules_srv[] =
{
	menu_antilag,
	menu_minping,
	menu_botskill,
	menu_spawnmode,
	menu_spacer,
	menu_back
};

static float rulechangetime[rules.length];
static float modchangetime[rules_mod.length];
static float srvchangetime[rules_srv.length];

void SV_RunClientCommand()
{
	if (!self.ishuman)
		input_angles = self.v_angle;

	if (!self.maxspeed)
	{	//in menus or frozen
		input_buttons = 0;
		input_movevalues = '0 0 0';
	}

	if (self.hook)
		ctf_hookupdate();
	else
		runstandardplayerphysics(self);
};

string balancestrings(string left, string separator, string right)
{
	float len;
	float lenr;

	len = strlennocol(left);
	lenr = strlennocol(right);

	if (lenr > len)
		len = lenr;

	left = strpad(-len, left);
	right = strpad(len, right);

	return strcat(left, separator, right);
};

string gmapn_menu_maps(float keys)
{
	float i;
	float lim;
	string m = 0;

	if (keys & KEY_RIGHT)
	{
		gmapn_mapvote_removevote();
		gmapn_mapvote_addvote(infokey(world, strcat("gmapn_map", ftos(self.maps[self.mapsel-1]))));
	}
	if (keys & KEY_UP)
	{
		self.mapsel -= 1;
		if (!self.mapsel)
		{
			//while ("" != infokey(world, strcat("gmapn_map", ftos(self.maps[self.subsel]))))
				self.mapsel+=1;
		}
	}
	if (keys & KEY_DOWN)
	{
		self.mapsel += 1;
		//if ("" == infokey(world, strcat("gmapn_map", ftos(self.maps[self.subsel-1]))))
		if (self.mapsel > MAPLIMIT)
			self.mapsel = 1;
	}

	i = self.mapsel - (MAPLIMIT / 2);

	for (lim = (MAPLIMIT / 2); lim > 0; lim--)
	{
		if ("" != infokey(world, strcat("gmapn_map", ftos(i+MAPLIMIT-1))))
			break;
		i--;
	}
	if (i < 1)
		i = 1;

	lim = i + MAPLIMIT;
	for (; i < lim; i++)
	{

		string name = infokey(world, strcat("gmapn_map", ftos(self.maps[i-1])));
		if (name == "")
			break;
		if (i == self.mapsel)
			name = redify(name);
		m = strcat(m, name, "\n");
	}
	if (keys & (KEY_RIGHT|KEY_LEFT))
	{
		self.subsel = SUBSEL_MAIN;
		self.viewingrules = time;
	}

	return m;
};

string gmapn_menu_waitingfor(float highlightself)
{
	string m = "";
	entity unready = world;

	do unready = find(unready, classname, "player"); while (unready.ready);

	if (unready)
	{
		m = strcat(m, "Waiting for: ");
		for(;;)
		{
			if (unready == self && !self.rulesel && highlightself)
				m = strcat(m, redify(unready.netname));
			else
				m = strcat(m, unready.netname);

			do unready = find(unready, classname, "player"); while (unready.ready);

			if (unready)
				m = strcat(m, ", ");
			else
				break;
		}
	}

	return m;
};

string gmapn_menu_mod(float keys)
{
	int i;

	if (!gmapn_gamemaster)
		gmapn_evaluategamemaster();
	
	if (keys & KEY_RIGHT)
	{
		modchangetime[self.modsel] = time + 3;
		rules_mod[self.modsel](MENU_RIGHT);
	}
	
	if (keys & KEY_LEFT)
	{
		modchangetime[self.modsel] = time + 3;
		rules_mod[self.modsel](MENU_LEFT);
	}
	
	if (keys & KEY_UP)
	{
		do
		{
			self.modsel -= 1;
			if (self.modsel < 0)
				self.modsel = rules_mod.length-1;
		} while(!rules_mod[self.modsel](0) || (!gmapn_isgamemaster(self) && !rules_mod[self.modsel](4)));
	}
	
	if (keys & KEY_DOWN)
	{
		do
		{
			self.modsel += 1;
			if (self.modsel >= rules_mod.length)
				self.modsel = 0;
		} while(!rules_mod[self.modsel](0) || (!gmapn_isgamemaster(self) && !rules_mod[self.modsel](4)));
	}

	string m = "";
	
	if (gmapn_serverstate != gmapn_serverstate_countdown)
	{
		m = gmapn_menu_waitingfor(gmapn_gamemodeneedsteam(gmapn_gamemode));
		m = strcat(m, "\n\n");
	}

	for (i = 0; i < rules_mod.length; i++)
	{
		string t, mid, v;

		t = rules_mod[i](MENU_TITLE);
		if not (t)
			continue;
		if (t == "")
			continue;
			
		if (modchangetime[i] >= time)
			t = alternate(t);

		mid = ":";
		v = rules_mod[i](MENU_VALUE);

		if (self.modsel == i)
		{
			t = redify(t);
			mid = redify(mid);
		}

		m = strcat(m, balancestrings(t, mid, v), "\n");
	}

	return m;
}

string gmapn_menu_server(float keys)
{
	int i;
	
	if (keys & KEY_RIGHT)
	{
		srvchangetime[self.srvsel] = time + 3;
		rules_srv[self.srvsel](MENU_RIGHT);
	}
	
	if (keys & KEY_LEFT)
	{
		srvchangetime[self.srvsel] = time + 3;
		rules_srv[self.srvsel](MENU_LEFT);
	}
	
	if (keys & KEY_UP)
	{
		do
		{
			self.srvsel -= 1;
			if (self.srvsel < 0)
				self.srvsel = rules_srv.length-1;
		} while(!rules_srv[self.srvsel](0) || (!gmapn_isgamemaster(self) && !rules_srv[self.srvsel](4)));
	}
	
	if (keys & KEY_DOWN)
	{
		do
		{
			self.srvsel += 1;
			if (self.srvsel >= rules_srv.length)
				self.srvsel = 0;
		} while(!rules_srv[self.srvsel](0) || (!gmapn_isgamemaster(self) && !rules_srv[self.srvsel](4)));
	}

	string m = "";
	
	if (gmapn_serverstate != gmapn_serverstate_countdown)
	{
		m = gmapn_menu_waitingfor(gmapn_gamemodeneedsteam(gmapn_gamemode));
		m = strcat(m, "\n\n");
	}

	for (i = 0; i < rules_srv.length; i++)
	{
		string t, mid, v;

		t = rules_srv[i](MENU_TITLE);
		if not (t)
			continue;
		if (t == "")
			continue;
			
		if (srvchangetime[i] >= time)
			t = alternate(t);

		mid = ":";
		v = rules_srv[i](MENU_VALUE);

		if (self.srvsel == i)
		{
			t = redify(t);
			mid = redify(mid);
		}

		m = strcat(m, balancestrings(t, mid, v), "\n");
	}

	return m;
}

string gmapn_menu_rules(float keys)
{
	int i;

	if (!gmapn_gamemaster)
		gmapn_evaluategamemaster();

	//use gmapn_gamemaster instead of getkey(game_lockrules), because we might have/be a vip
	if (getkey(game_lockrules)>0 && !gmapn_gamemodeneedsteam(gmapn_gamemode))
	{
		self.rulesel = -1;
		keys = KEY_NONE;
	}
	else if (self.rulesel == -1)
		self.rulesel = 0;	//don't break

	if (keys & KEY_RIGHT)
	{
		rulechangetime[self.rulesel] = time+3;
		rules[self.rulesel](MENU_RIGHT);
	}
	if (keys & KEY_LEFT)
	{
		rulechangetime[self.rulesel] = time+3;
		rules[self.rulesel](MENU_LEFT);
	}

	if (keys & KEY_UP)
	{
		do
		{
			self.rulesel -= 1;
			if (self.rulesel < 0)
				self.rulesel = rules.length-1;
		} while(!rules[self.rulesel](0) || (!gmapn_isgamemaster(self) && !rules[self.rulesel](4)));
	}
	if (keys & KEY_DOWN)
	{
		do
		{
			self.rulesel += 1;
			if (self.rulesel >= rules.length)
				self.rulesel = 0;
		} while(!rules[self.rulesel](0) || (!gmapn_isgamemaster(self) && !rules[self.rulesel](4)));
	}

	string m = "";

	if (gmapn_serverstate != gmapn_serverstate_countdown)
	{
		m = gmapn_menu_waitingfor(gmapn_gamemodeneedsteam(gmapn_gamemode));
		m = strcat(m, "\n\n");
	}
	if (gmapn_gamemodeneedsteam(gmapn_gamemode))
	{
		int rows = 4;
		string left, right;

		left = " RED";
		right = "BLUE";

		if (!self.rulesel)
		{
			if (self.teamname == "red" && self.ready)
				left = redify(left);
			else if (self.teamname == "blue" && self.ready)
				right = redify(right);
			else
			{
				left = alternate(left);
				right = alternate(right);
			}
		}

		m = strcat(m, balancestrings(left, " : ", right), "\n");

		entity redplayer = findreadyteamplayer(world, "red");
		entity blueplayer = findreadyteamplayer(world, "blue");

		while(rows-- > 0)
		{
			if (redplayer == self && !self.rulesel)
				left = redify(redplayer.netname);
			else if (redplayer)
				left = redplayer.netname;
			else
				left = "---";

			if (blueplayer == self && !self.rulesel)
				right = redify(blueplayer.netname);
			else if (blueplayer)
				right = blueplayer.netname;
			else
				right= "---";

			m = strcat(m, balancestrings(left, " : ", right), "\n");

			if (redplayer)
				redplayer = findreadyteamplayer(redplayer, "red");
			if (blueplayer)
				blueplayer = findreadyteamplayer(blueplayer, "blue");
			if (!redplayer && !blueplayer)
				break;
		}

		i = 1;
		m = strcat(m, "\n");
	}
	else
	{
		i = 0;
	}

	for (; i < rules.length; i++)
	{
		string t, mid, v;

		t = rules[i](0);
		if not (t)
			continue;
		if (t == "")
			continue;
			
		if (rulechangetime[i] >= time)
			t = alternate(t);

		mid = ":";
		v = rules[i](1);

		if (self.rulesel == i)
		{
			t = redify(t);
			mid = redify(mid);
		}

		m = strcat(m, balancestrings(t, mid, v), "\n");
	}

	return m;
}
/*
string gmapn_menu_settings()
{
	string str, mid;

	str = "\n";
	mid = ":";
	str = strcat(str, balancestrings(redify("Deathmatch Mode"), mid, goldnmbr(ftos(cvar("deathmatch")))), "\n");
	str = strcat(str, balancestrings(redify("Timelimit"), mid, goldnmbr(ftos(cvar("timelimit")))), "\n");
	str = strcat(str, balancestrings(redify("Powerups"), mid, (getkey(powerups_enabled) == 0 ? "Disabled" : "Enabled")), "\n");

	return str;
}
*/
string gmapn_menu_settings()
{
	string str, mid, modified, loadout;
	int i, n;
	float printmodified;

	str = "";
	mid = ":";
	printmodified = FALSE;

	n = getkey(game_loadout);
	for (i = 0; i < loadouts.length; i++)
		if (n == loadouts[i].fl)
			break;
	loadout = (n ? sprintf("axe + sg + %s", loadouts[i].name) : "axe + sg");
	modified = "";
	if (getkey(game_loadout) != stof(infokey(world, "gmapn_game_loadout")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Loadout")), mid, loadout), "\n");

	modified = "";
	if (cvar("deathmatch") != stof(infokey(world, "gmapn_deathmatch")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Deathmatch Mode")), mid, goldnmbr(ftos(cvar("deathmatch")))), "\n");

	modified = "";
	if (cvar("timelimit") != stof(infokey(world, "gmapn_timelimit")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Timelimit")), mid, goldnmbr(ftos(cvar("timelimit")))), "\n");	

	modified = "";
	if (getkey(powerups_enabled) != stof(infokey(world, "gmapn_powerups_enabled")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Powerups")), mid, (getkey(powerups_enabled) ? "Enabled" : "Disabled")), "\n");

	modified = "";
	if (getkey(game_botskill) != stof(infokey(world, "gmapn_game_botskill")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Bot Difficulty")), mid, botskillname[getkey(game_botskill)]), "\n");

	modified = "";
	if (getkey(game_rounds) != stof(infokey(world, "gmapn_game_rounds")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Rounds Per Game")), mid, ftos(getkey(game_rounds))), "\n");

	modified = "";
	if (getkey(minplayers) != stof(infokey(world, "gmapn_minplayers")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Minplayers")), mid, ftos(getkey(minplayers))), "\n");

	modified = "";
	if (getkey(maxplayers) != stof(infokey(world, "gmapn_maxplayers")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Maxplayers")), mid, ftos(getkey(maxplayers))), "\n");

	modified = "";
	if (cvar("sv_antilag") != stof(infokey(world, "gmapn_antilag")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Lag Compensation")), mid, (cvar("sv_antilag") ? "On" : "Off")), "\n");

	modified = "";
	if (cvar("sv_minping") != stof(infokey(world, "gmapn_minping")))
	{
		modified = chr2str(0x87);
		printmodified = TRUE;
	}
	str = strcat(str, balancestrings(sprintf("%s%s", modified, redify("Min Ping")), mid, ftos(cvar("sv_minping"))), "\n");

	if (printmodified == TRUE)
	{
		str = strcat(flash("\nSome modified settings are used\n\n"), str);
	}
	else
	{
		str = strcat("\n\n\n\n", str);
	}
	
	return str;
}

void gmapn_menu_any(float keys)
{
	entity p;

	if (keys & (KEY_RIGHT|KEY_LEFT))
	{
		for (p = world; (p = find(p, classname, "player")); )
			p.viewingrules = time;
	}

	string host = getkey(info_hostname), city = getkey(info_city), region = getkey(info_state), nation = getkey(info_country);

	string m = "";
	m = strcat(m, host, "\n");

	if (city != "")
		m = strcat(m, city);
	if (region != "")
		m = strcat(m, (city!="")?", ":"", region);
	if (nation != "")
		m = strcat(m, (city!=""||region!="")?", ":"", nation);
	if (city != "" || region != "" || nation != "")
		m = strcat(m, "\n");
	m = strcat(m, "\n");

	if (gmapn_serverstate == gmapn_serverstate_countdown)
	{
		m = sprintf("\n\n%s starts in %s\n\n", redify(gmapn_gamemodetostring(gmapn_gamemode)), goldnmbr(ftos(ceil((gmapn_matchstarttimems/1000) - time))));
		m = strcat(m, gmapn_menu_settings());
	}
	else if (gmapn_serverstate == gmapn_serverstate_forcestart && !self.ready)
		m = strcat(m, flash("READY UP NOW\n"));
	else
		m = strcat(m, "\n");

	m = strcat(m, "\n");

	//use gmapn_gamemaster instead of getkey(game_lockrules), because we might have/be a vip
	if (!self.ready && time>5)
	{
		if (getkey(game_lockrules)>0 && !gmapn_gamemodeneedsteam(gmapn_gamemode))
			cmd_ready();
	}

	if (self.matchlistquery)
		m = strcat("/P", m, gmapn_menu_matchlist(keys));
	else if (self.ready || self.movetime >= time)
	{	//menu is temporarily hidden because the player is moving.
		if (self.ready || self.movement || self.button0 || self.button2)
			self.movetime = time + 3;

		if (gmapn_serverstate != gmapn_serverstate_countdown)
			m = strcat(m, gmapn_menu_waitingfor((time*2) & 1));
	}
	else if (self.subsel == SUBSEL_MAPS)
		m = strcat("/P", m, gmapn_menu_maps(keys));
	else if (self.subsel == SUBSEL_MOD)
		m = strcat("/P", m, gmapn_menu_mod(keys));
	else if (self.subsel == SUBSEL_SERVER)
		m = strcat("/P", m, gmapn_menu_server(keys));
	else
		m = strcat("/P", m, gmapn_menu_rules(keys));

	centerprint(self, m);
};

float gmapn_display_rules()
{
	float newkeys, keys;

	if (time < 1)	//can do weird things on loading screens
		return TRUE;

	if (time < self.menutime)
		return TRUE;

	newkeys = 0;

	if (self.movement_x > 100*frametime)
		newkeys |= KEY_UP;
	if (self.movement_x < -100*frametime)
		newkeys |= KEY_DOWN;
	if (self.movement_y > 100*frametime)
		newkeys |= KEY_RIGHT;
	if (self.movement_y < -100*frametime)
		newkeys |= KEY_LEFT;
	if (self.button2 || (self.csqcactive && self.movement))
		newkeys |= KEY_JUMP;

	if (self.viewingrules <= time)
		self.oldmkeys &= KEY_RIGHT|KEY_LEFT;

	keys = newkeys & ~self.oldmkeys;	//changed keys

	if (newkeys & KEY_JUMP)
	{
		if (self.movetime < time)
			self.viewingrules = time;
		self.movetime = time + 3;
	}

	if (self.ready || self.movetime > time)
	{
		if (gmapn_serverstate < gmapn_serverstate_playing)
			self.maxspeed = 320;
	}
	else
	{
		if (gmapn_serverstate < gmapn_serverstate_playing)
			self.maxspeed = 0;
	}

	self.oldmkeys = newkeys;

	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		if (gmapn_gamemode == GM_FREEZETAG)
		{
			if (self.viewingrules < time && self.deadflag)
			{
				centerprint(self, "YOU ARE FROZEN!\nHARASS A TEAM MATE TO HELP YOU!");
				self.viewingrules = time + 1;
			}
		}
		return FALSE;
	}

	//don't spam centerprints if there's no need.
	if (!keys && self.viewingrules > time)
		return TRUE;

	self.viewingrules = time + 0.25;

	gmapn_menu_any(keys);

	self.oldmkeys &= ~32;

	return TRUE;
};

void Cmd_mkey_s(string s)
{
	self.csqcactive = TRUE;

	if (s == "u")
		gmapn_menu_any(KEY_UP);
	else if (s == "d")
		gmapn_menu_any(KEY_DOWN);
	else if (s == "r")
		gmapn_menu_any(KEY_RIGHT);
	else if (s == "l")
		gmapn_menu_any(KEY_LEFT);
};

void bar(string T_Text,int array_size)
{
	float i;
	float text_size;
	text_size = strlen(T_Text);
	string text_array;//[text_size];
//	float text_array[text_size];
	string foo = (string)alloca(text_size);
	string foo2 = (string)alloca(64);

	for(i = 0; i < text_size, i++;)
	{
		text_array[2] = 4;//"hej";
	}
};
