#define MAPLIMIT 11

string gmapn_menu_matchlist(float keys);
.float matchfirst;
.float matchlistquery;
.float matchstatsquery;

.float oldmkeys;
.float viewingrules;	//timer when it should next be resent
.float rulesel;	//main option on the menu
.float subsel;	//map or election
.float maps[MAPLIMIT]; // list of maps displayed
string gmapn_menuarg;

.float csqcactive;	//our csprogs is running on this client. yay.
.float movetime;	//the time until the menu remains mostly hidden.

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

#define MENU_TITLE 0
#define MENU_VALUE 1
#define MENU_LEFT 2
#define MENU_RIGHT 3
#define MENU_ISNONADMIN 4
#define MENU_CLIENTCMD 5

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
		self.subsel = 1;
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
		case 1:		return "dmm1";
		case 2:		return "dmm2";
		case 3:		return "dmm3";
		case 4:		return "dmm4";
		case 5:		return "midair";
		case 6:		return "instagib";
		}
	}
	else if (op == MENU_LEFT)
	{
		val = max((gmapn_gamemode == GM_COOP)?0:1, cvar("deathmatch")-1);
		cvar_set("deathmatch", ftos(val));
	}
	else if (op == MENU_RIGHT)
	{
		val = min(6, cvar("deathmatch")+1);
		cvar_set("deathmatch", ftos(val));
	}
	gmapn_powerups_setitems(cvar("deathmatch") < 4);
	return 0;
};

static string menu_loadout(float op)
{
	static const struct
	{
		int fl;
		string name;
	} loadouts[] =
	{
		{0,			"default"},
		{IT_SUPER_SHOTGUN,	"ssg"},
		{IT_NAILGUN,		"ng"},
		{IT_SUPER_NAILGUN,	"sng"},
		{IT_GRENADE_LAUNCHER,	"gl"},
		{IT_ROCKET_LAUNCHER,	"rl"},
		{IT_LIGHTNING_GUN,	"lg"},
		{IT_RAILGUN,		"rg"},
		{IT_ARMOR1,		"ga"},
		{IT_ARMOR2,		"ya"},
		{IT_ARMOR3,		"ra"},
#ifdef HAVE_PORTALS
		{IT_PORTALGUN,		"pg"},
#endif
		{IT_RING,		"ring"},
		{IT_PENT,		"pent"},
		{IT_SUIT,		"suit"},
		{IT_QUAD,		"quad"},
	};

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
		switch(val-1)
		{
		case -1: return "No bots";
		case 0: return "Clay Pidgin";
		case 1: return "Joke";
		case 2: return "Noobs";
		case 3: return "Mobile Victims";
		default: return "Glitch";
		}
	}
	else if (op == MENU_LEFT)
		setkey("game_botskill", ftos(max(0, val-1)));
	else if (op == MENU_RIGHT)
		setkey("game_botskill", ftos(min(4, val+1)));

	return 0;
};

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

void gmapn_menu_showmatches(void);
static string menu_pastmatches(float op)
{
	if (op == MENU_TITLE)
		return "Past matches";
	if (op == MENU_VALUE)
		return "<show>";

	if (op == MENU_LEFT)
		;
	if (op == MENU_RIGHT)
		gmapn_menu_showmatches();
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	return 0;
};

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
	menu_loadout,
	menu_maxplayers,
	menu_minplayers,
	menu_botskill,
	menu_time,
	menu_powerups,
	menu_antilag,
	menu_minping,
	menu_pastmatches,
};

static float rulechangetime[rules.length];

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

void balancestrings(__inout string left, __inout string right)
{
	float len;
	float lenr;

	len = strlennocol(left);
	lenr = strlennocol(right);

	if (lenr > len)
		len = lenr;

	left = strpad(-len, left);
	right = strpad(len, right);
};

string gmapn_menu_maps(float keys)
{
	float i;
	float lim;
	string m = 0;

	if (keys & 4)
	{
		gmapn_mapvote_removevote();
		gmapn_mapvote_addvote(infokey(world, strcat("gmapn_map", ftos(self.maps[self.subsel-1]))));
	}
	if (keys & 1)
	{
		self.subsel -= 1;
		if (!self.subsel)
		{
			//while ("" != infokey(world, strcat("gmapn_map", ftos(self.maps[self.subsel]))))
				self.subsel+=1;
		}
	}
	if (keys & 2)
	{
		self.subsel += 1;
		//if ("" == infokey(world, strcat("gmapn_map", ftos(self.maps[self.subsel-1]))))
		if (self.subsel > MAPLIMIT)
			self.subsel = 1;
	}

	i = self.subsel - (MAPLIMIT / 2);

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
		if (i == self.subsel)
			name = redify(name);
		m = strcat(m, name, "\n");
	}
	if (keys & (4|8))
	{
		self.subsel = 0;
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

string gmapn_menu_rules(float keys)
{
	int i;

	if (!gmapn_gamemaster)
		gmapn_evaluategamemaster();

	//use gmapn_gamemaster instead of getkey(game_lockrules), because we might have/be a vip
	if (getkey(game_lockrules)>0 && !gmapn_gamemodeneedsteam(gmapn_gamemode))
	{
		self.rulesel = -1;
		keys = 0;
	}
	else if (self.rulesel == -1)
		self.rulesel = 0;	//don't break

	if (keys & 4)
	{
		rulechangetime[self.rulesel] = time+3;
		rules[self.rulesel](MENU_RIGHT);
	}
	if (keys & 8)
	{
		rulechangetime[self.rulesel] = time+3;
		rules[self.rulesel](MENU_LEFT);
	}

	if (keys & 1)
	{
		do
		{
			self.rulesel -= 1;
			if (self.rulesel < 0)
				self.rulesel = rules.length-1;
		} while(!rules[self.rulesel](0) || (!gmapn_isgamemaster(self) && !rules[self.rulesel](4)));
	}
	if (keys & 2)
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

		balancestrings(left, right);
		m = strcat(m, left, " : ", right, "\n");

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

			balancestrings(left, right);
			m = strcat(m, left, " : ", right, "\n");

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

		balancestrings(t, v);
		m = strcat(m, t, mid, v, "\n");
	}

	return m;
};

void gmapn_menu_any(float keys)
{
	entity p;

	if (keys & (4|8))
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
		m = strcat(m, "Game starts in ", ftos(ceil((gmapn_matchstarttimems/1000) - time)), "\n");
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

		m = strcat(m, gmapn_menu_waitingfor((time*2) & 1));	
	}
	else if (self.subsel > 0)
		m = strcat("/P", m, gmapn_menu_maps(keys));
	else
		m = strcat("/P", m, gmapn_menu_rules(keys));

	centerprint(self, m);
};

float gmapn_display_rules()
{
	float newkeys, keys;

	if (time < 1)	//can do weird things on loading screens
		return TRUE;

	newkeys = 0;

	if (self.movement_x > 100*frametime)
		newkeys |= 1;
	if (self.movement_x < -100*frametime)
		newkeys |= 2;	
	if (self.movement_y > 100*frametime)
		newkeys |= 4;
	if (self.movement_y < -100*frametime)
		newkeys |= 8;
	if (self.button2 || (self.csqcactive && self.movement))
		newkeys |= 16;

	if (self.viewingrules <= time)
		self.oldmkeys &= 4|8;

	keys = newkeys & ~self.oldmkeys;	//changed keys

	if (newkeys & 16)
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
		gmapn_menu_any(1);
	else if (s == "d")
		gmapn_menu_any(2);
	else if (s == "r")
		gmapn_menu_any(4);
	else if (s == "l")
		gmapn_menu_any(8);
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
