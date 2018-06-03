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

#define SUBSEL_MAPS -2

string gmapn_menu_matchlist(float keys);
string gmapn_menu_maplist(float keys);
.float matchfirst;
.float matchlistquery;
.float matchstatsquery;
.float mapquery;

.float oldmkeys;
.float maps[11]; // list of maps displayed. randomizedish per player. FIXME: should probably just make this a string array, or tokens string.
string gmapn_menuarg;

entity gmapn_gamemaster;	//this is the player who is currently nominated to be the leader.
entity gmapn_monarchofthemound;	//this player is currently the king, the only player that rewards frags.

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
				return "Pick a team";
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

void menu_mapvote_randomize(int first)
{
	float mappoolsize, rnd;
	int retries = 30, i = first, j;

	mappoolsize = gmapn_map_pool_count();
	if (mappoolsize)
	{
		while (i < maps.length)
		{
			rnd = floor(random() * mappoolsize);

			for (j = 0; j < i; j++)
				if (self.maps[j] == rnd)
					break;
			if (j == i)
				self.maps[i++] = rnd;
			else if (retries --< 0)
				break;
		}
	}
	for (; i < maps.length; i++)
		self.maps[i++] = -1;


	self.subsel = SUBSEL_MAPS;
	self.viewingrules = time;
};

void gmapn_menu_mapvote_sql();
static string menu_mapvote(float op)

{
	if (op == MENU_TITLE)
		return "Map Vote";
	else if (op == MENU_VALUE)
	{
		if (getkey(maprotation) != "")
			return "Maprotation";
		string myvote = gmapn_mapvote_getvote();
		if (myvote)
			return myvote;
		else
			return "Abstain";
	}
	else if (op == MENU_LEFT && getkey(maprotation) == "")
	{
		gmapn_mapvote_removevote();
	}
	else if (op == MENU_RIGHT && getkey(maprotation) == "")
	{
		for (int i = 0; i < maps.length; i++)
			self.maps[i] = -1; // empty out map list

		self.mapsel = 0; // place marker on first map in the list

		if (uri_get(URL_MAPLIST(getkey(staturl), gmapn_gamemode, cvar("deathmatch")), URI_GET_MAPLIST) == 1)
		{
			self.mapquery = -1;
		}
		else
		{
			gmapn_menu_mapvote_sql();
		}
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
		return dmmname[cvar("deathmatch")];
	}
	else if (op == MENU_LEFT)
	{
		val = max((gmapn_gamemode == GM_COOP)?0:1, cvar("deathmatch")-1);
		if (val == 2)
			val -= 1; // skip dmm2
		cvar_set("deathmatch", ftos(val));
		gmapn_powerups_setitems();
	}
	else if (op == MENU_RIGHT)
	{
		val = min(7, cvar("deathmatch")+1);
		if (val == 2)
			val += 1; // skip dmm2
		cvar_set("deathmatch", ftos(val));
		gmapn_powerups_setitems();
	}

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
		if (getkey(game_lockrules) < 0)
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

	float v = cvar("sv_antilag");
	if (op == MENU_VALUE)
	{
		if (v==3)
			return "on (+knockback compensation)";	//compensates for the aiming player having moved differently from how the client had predicted, as well as the target players.
		else if (v==2)
			return "force (!!!)";	//hack all tracelines, which can break stuff, which is why we don't select it here.
		else if (v)
			return "on";	//compensates only for the other player moving around.
		else
			return "off";	//all MOVE_LAGGED etc stuff will be silently ignored.
	}
	if (op == MENU_LEFT)
	{
		if (v == 3)
			cvar_set("sv_antilag", "1");
		else
			cvar_set("sv_antilag", "");
	}
	if (op == MENU_RIGHT)
	{
		if (v)
			cvar_set("sv_antilag", "3");
		else
			cvar_set("sv_antilag", "1");
	}
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
		return spawnname[spawnmode];
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
	{
		gmapn_menu_showmatches();
		self.viewingrules = time;
	}
	else if (op == MENU_ISNONADMIN)
		return ".";	//anything not null
	return 0;
};

static string menu_back(float op)
{
	if (op == MENU_TITLE)
		return "Back";
	else if (op == MENU_VALUE)
		return "";
	else if (op == MENU_LEFT)
	{
		self.subsel = -1;
		self.viewingrules = time;
	}
	else if (op == MENU_ISNONADMIN)
		return ".";
	return 0;
}

static string(float op) rules_misc[] =
{
	menu_maxplayers,
	menu_minplayers,
	menu_rounds,
	menu_loadout,
	menu_antilag,
	menu_minping,
	menu_botskill,
	menu_spawnmode,
	menu_back
};

static string menu_miscoptions(float op)
{
	if (op == MENU_TITLE)
		return "Misc options";
	else if (op == MENU_VALUE)
		return "";
	else if (op == MENU_LEFT)
		;
	else if (op == MENU_RIGHT)
	{
		self.subsel = -1;
		do
		{
			self.subsel += 1;
			if (self.subsel >= rules_misc.length)
			{
				self.subsel = rules_misc.length - 1;
				break;
			}
		} while(!rules_misc[self.subsel](4));
		self.viewingrules = time;
	}
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
	menu_mapvote,
	menu_rulemaker,
	menu_gamemode,
	menu_dmm,
	menu_time,
	menu_powerups,
	menu_pastmatches,
	menu_miscoptions
};

static string rules_desc[] =
{
	"Displays a list of maps\nto vote from",
	"The rulemaker can modify\nthe settings",
	"",
	"Choose item respawns and\nstarting items",
	"Timelimit in minutes\n ",
	"Quad Damage, Pentagram, etc\n ",
	"Show a history of your progress\n<right>",
	"Options for the game mode.\n<right>",
	"Options for the server.\n<right>"
};

static string rules_misc_desc[] =
{
	"Maximum clients to be playing\n ",
	"Minimum clients for\nthe game to start",
	"Rounds per match\n ",
	"Starting weapons and items\n ",
	"Aka antilag vastly increases\naccuracy",
	"Force a simulated lag for all\nplayers",
	"Set a skill for bots that autojoin\n ",
	"Spawn modes determine how you spawn\n ",
	"Back to main menu <left>\n "
};

static string gamemode_desc[] =
{
	"Pick up a gun and shoot anyone",
	"Frag whoever is king atm",
	"Rocket Arena style but on normal maps",
	"cl_gibfilter 0 is recommended",
	"Normal Coop Quake",
	"Normal 1on1",
	"Normal 4on4",
	"Normal 2on2",
	"Be the last man alive on the team",
	"Freeze all opponents to win",
	"Capture the control points",
	"You frag people, they come to your team",
	"Get the enemy flag to your base",
	"1FCTF",
	"It sucks",
	"Kill monsters"
};

string gmapn_menu_rules_describe(float rulesel)
{
	if (rules_desc[bound(0, rulesel, rules_desc.length)] == "")
	{
		string matchless;
		if (gmapn_ismatchless(gmapn_gamemode))
			matchless = brackets(redify("MATCHLESS"));
		else
			matchless = "";
		return sprintf("%s%s%s", gamemode_desc[bound(0, gmapn_gamemode, gamemode_desc.length-1)], "\n", matchless);
	}
	else
		return rules_desc[bound(0, rulesel, rules_desc.length)];
}

string gmapn_menu_misc_describe(float subsel)
{
	return rules_misc_desc[bound(0, subsel, rules_misc_desc.length)];
}

static float rulechangetime[rules.length];
static float miscchangetime[rules_misc.length];

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
	int i;
	int	 lim, first;
	float currentsel = self.mapsel;
	string m = 0;
	const float showmax = 20;

	if (keys & KEY_RIGHT)
	{
		gmapn_mapvote_removevote();
		gmapn_mapvote_addvote(gmapn_map_pool_readidx(self.maps[self.mapsel]));
	}
	if (keys & KEY_UP)
	{
		do
		{
			self.mapsel -= 1;

			if (self.mapsel<0)
				self.mapsel = maps.length-1;

			if (self.mapsel == currentsel)
				break;
		} while (gmapn_map_pool_readidx(self.maps[self.mapsel]) == "");
	}
	if (keys & KEY_DOWN)
	{
		do
		{
			self.mapsel += 1;

			if (self.mapsel >= maps.length)
				self.mapsel = 0;

			if (self.mapsel == currentsel)
				break;
		} while (gmapn_map_pool_readidx(self.maps[self.mapsel]) == "");
	}

	//usually, the first option displayed is the one half the max from the current option
	first = self.mapsel - floor(showmax / 2);
	if (first < 0)	//but sometimes its one of the first displayable
		first = 0;

	//and sometimes its one of the last. nudge the first upwards in that case.
	for (lim = floor(showmax / 2); lim > 0 && first > 0; lim--)
	{
		if (first+showmax <= maps.length)
			if ("" != gmapn_map_pool_readidx(self.maps[first+showmax-1]))
				break;
		first--;
	}

	//generate the display string now.
	lim = first + showmax;
	for (i = first; i < lim && i < maps.length; i++)
	{
		string name = gmapn_map_pool_readidx(self.maps[i]);
		if (name == "")
			break;
		if (i == self.mapsel)
			name = redify(name);
		m = strcat(m, name, "\n");
	}
	if (keys & (KEY_RIGHT|KEY_LEFT))
	{
		self.subsel = -1;
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
			if (unready == self && highlightself)
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
}

string gmapn_menu_misc(float keys)
{
	int i;

	if (keys & KEY_RIGHT)
	{
		miscchangetime[self.subsel] = time + 3;
		rules_misc[self.subsel](MENU_RIGHT);
	}

	if (keys & KEY_LEFT)
	{
		miscchangetime[self.subsel] = time + 3;
		rules_misc[self.subsel](MENU_LEFT);
	}

	if (keys & KEY_UP)
	{
		do
		{
			self.subsel -= 1;
			if (self.subsel < 0)
				self.subsel = rules_misc.length-1;
		} while(!rules_misc[self.subsel](0) || (!gmapn_isgamemaster(self) && !rules_misc[self.subsel](4)));
	}

	if (keys & KEY_DOWN)
	{
		do
		{
			self.subsel += 1;
			if (self.subsel >= rules_misc.length)
				self.subsel = 0;
		} while(!rules_misc[self.subsel](0) || (!gmapn_isgamemaster(self) && !rules_misc[self.subsel](4)));
	}

	string m = "";

	if (gmapn_serverstate != gmapn_serverstate_countdown)
	{
		m = gmapn_menu_waitingfor(gmapn_gamemodeneedsteam(gmapn_gamemode));
		m = strcat(m, "\n\n");
	}

	for (i = 0; i < rules_misc.length; i++)
	{
		string t, mid, v;

		t = rules_misc[i](MENU_TITLE);
		if not (t)
			continue;
		if (t == "")
			continue;

		if (miscchangetime[i] >= time)
			t = alternate(t);

		mid = ":";
		v = rules_misc[i](MENU_VALUE);

		if (self.subsel == i)
		{
			t = redify(t);
			mid = redify(mid);
		}

		m = strcat(m, balancestrings(t, mid, v), "\n");
	}

	return m;
}

string gmapn_menu_ready(float keys)
{
	string m = "";

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
				right= "----";

			m = strcat(m, balancestrings(left, " : ", right), "\n");

			if (redplayer)
				redplayer = findreadyteamplayer(redplayer, "red");
			if (blueplayer)
				blueplayer = findreadyteamplayer(blueplayer, "blue");
			if (!redplayer && !blueplayer)
				break;
		}

		m = strcat(m, "\n");
	}

	if (keys & KEY_LEFT)
		menu_readyteam(MENU_LEFT);
	if (keys & KEY_RIGHT)
		menu_readyteam(MENU_RIGHT);

	m = strcat(m, balancestrings(menu_readyteam(MENU_TITLE), ":", menu_readyteam(MENU_VALUE)));

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

string gmapn_menu_addentry(string name, string sep, string value)
{
	string ret, left, mid, right;

	if (name != __NULL__)
		left = name;
	else
		left = "";

	if (value != __NULL__)
		right = value;
	else
		right = "";

	if (sep != __NULL__)
		mid = sep;
	else
		mid = "";

	ret = balancestrings(left, mid, right);
	ret = strcat(ret, "\n");
	return ret;
}

string gmapn_menu_countdown()
{
	string str, litem, ritem, set[64];
	int i;

	str = "";
	litem = "";
	ritem = "";

	for (i = 0; i < set.length; i++)
	{
		set[i] = "";
	}

	if (getkey(game_loadout) && getkey(game_loadout) != stof(infokey(world, "gmapn_game_loadout")))
	{
		set[0] = "Loadout";
	}

	if (cvar("deathmatch") && cvar("deathmatch") != stof(infokey(world, "gmapn_deathmatch")))
	{
		set[1] = "Deathmatch";
	}

	if (cvar("timelimit") && cvar("timelimit") != stof(infokey(world, "gmapn_timelimit")))
	{
		set[2] = "Timelimit";
	}

	if (getkey(powerups_enabled) && getkey(powerups_enabled) != stof(infokey(world, "gmapn_powerups_enabled")))
	{
		set[3] = "Powerups";
	}

	if (getkey(spawn_mode) != stof(infokey(world, "gmapn_spawn_mode")))
	{
		set[4] = "Spawn Mode";
	}

	if (getkey(game_botskill) && getkey(game_botskill) != stof(infokey(world, "gmapn_game_botskill")))
	{
		set[5] = "Bot Skill";
	}

	if (getkey(game_rounds) && getkey(game_rounds) != stof(infokey(world, "gmapn_game_rounds")))
	{
		set[6] = "Game Rounds";
	}

	if (cvar("sv_antilag") && cvar("sv_antilag") != stof(infokey(world, "gmapn_antilag")))
	{
		set[7] = "Lag Compensation";
	}

	if (cvar("sv_minping") && cvar("sv_minping") != stof(infokey(world, "gmapn_minping")))
	{
		set[8] = "Min Ping";
	}

	for (i = 0; i < set.length; i++)
	{
		if (set[i] != "")
		{
			if (litem == "")
			{
				litem = set[i];
			}
			else if (ritem == "")
			{
				ritem = set[i];
				str = strcat(str, gmapn_menu_addentry(litem, "   ", ritem));
				litem = ritem = "";
			}
		}
	}

	if (litem != "")
	{
		str = strcat(str, litem, "\n");
	}

	if (str != "")
	{
		str = strcat("\n", alternate("Some settings are modified"), "\n\n", str);
	}
	else
	{
		str = strcat("\n\n\n\n", str);
	}

	str = strcat(sprintf("%s starts in %s\n", redify(gmapn_gamemodefullname(gmapn_gamemode)), goldnmbr(ftos(ceil((gmapn_matchstarttimems/1000) - time)))), str);
	return str;
}

void gmapn_menu_any(float keys)
{
	entity p;
	string prefix;

	self.menutime = time;

	string host = getkey(info_hostname), city = getkey(info_city), region = getkey(info_state), nation = getkey(info_country);

	string m = "";

	if (gmapn_serverstate == gmapn_serverstate_prewar)
	{
		m = strcat(m, host, "\n");

		if (city != "")
			m = strcat(m, city);
		if (region != "")
			m = strcat(m, (city!="")?", ":"", region);
		if (nation != "")
			m = strcat(m, (city!=""||region!="")?", ":"", nation);
		if (city != "" || region != "" || nation != "")
			m = strcat(m, "\n");

		if (!gmapn_gamemaster)
			m = strcat(m, sprintf(_("\nNobody is %s\n"), redify("the Rulemaker")));
		else if (self == gmapn_gamemaster)
			m = strcat(m, sprintf(_("\nYou are %s\n"), redify("the Rulemaker")));
		else
			m = strcat(m, sprintf(_("\n%s is %s\n"), gmapn_gamemaster.netname, redify("the Rulemaker")));
	}
	else if (gmapn_serverstate == gmapn_serverstate_forcestart && !self.ready)
		m = strcat(m, flash("\nREADY UP NOW\n"));
	else
		m = strcat(m, "\n");

	m = strcat(m, "\n");

	//use gmapn_gamemaster instead of getkey(game_lockrules), because we might have/be a vip
	if (!self.ready && time>5)
	{
		if (getkey(game_lockrules)>0 && !gmapn_gamemodeneedsteam(gmapn_gamemode))
			cmd_ready();
	}

	if (substring(infokey(self, "*ver"), 0, 3) == "FTE")
		prefix = "/P";
	else
		prefix = "";

	if (self.matchlistquery)
		m = strcat(prefix, m, gmapn_menu_matchlist(keys));
	else if (self.mapquery != 0) // -1 for URI GET
		m = strcat(prefix, m, gmapn_menu_maplist(keys));
	else if (gmapn_serverstate == gmapn_serverstate_lockready)
	{
		m = flash("There are enough players to start\n\n");
		m = strcat(prefix, m, gmapn_menu_waitingfor((time*2) & 1), "\n\n");
		m = strcat(prefix, m, gmapn_menu_ready(keys));
	}
	else if (self.ready || self.movetime >= time)
	{	//menu is temporarily hidden because the player is moving.
		if (self.ready || self.movement || self.button0 || self.button2)
			self.movetime = time + 3;

		if (gmapn_serverstate != gmapn_serverstate_countdown)
			m = gmapn_menu_waitingfor((time*2) & 1);
	}
	else if (self.subsel == SUBSEL_MAPS)
	{
		m = strcat(prefix, m, gmapn_menu_maps(keys));
	}
	else if (self.subsel >= 0)
	{
		m = strcat(prefix, m, gmapn_menu_misc(keys));
		m = strcat(prefix, m, gmapn_menu_misc_describe(self.subsel));
	}
	else
	{
		m = strcat(prefix, m, gmapn_menu_rules(keys));
		m = strcat(m, "\n", gmapn_menu_rules_describe(self.rulesel));
	}

	centerprint(self, m);
};

void gmapn_display_welcome()
{
	filestream helpfile = -1;
	string msg = "";

	switch (gmapn_gamemode)
	{
	case GM_DOMINATION:

		helpfile = fopen("cfgs/help/domination.txt", FILE_READ);
		break;

	case GM_DA:

		helpfile = fopen("cfgs/help/duelarena.txt", FILE_READ);
		break;

	case GM_FREEZETAG:

		helpfile = fopen("cfgs/help/freezetag.txt", FILE_READ);
		break;

	case GM_HEADHUNTER:

		helpfile = fopen("cfgs/help/headhunters.txt", FILE_READ);
		break;

	case GM_KING:

		helpfile = fopen("cfgs/help/killtheking.txt", FILE_READ);
		break;

	case GM_LASTMANSTANDING:

		helpfile = fopen("cfgs/help/lastmanstanding.txt", FILE_READ);
		break;

	case GM_ROVER:

		helpfile = fopen("cfgs/help/rover.txt", FILE_READ);
		break;

	default:

		helpfile = fopen("cfgs/help/motd.txt", FILE_READ);
		break;
	}

	if (helpfile >= 0)
	{
		string s;

		// title of MOTD is the current game mode
		msg = strcat("\b", gmapn_gamemodefullname(gmapn_gamemode), "\n\n");

		while ((s = fgets(helpfile)))
		{
			msg = strcat(msg, s, "\n");
		}

		fclose(helpfile);
	}

	centerprint(self, msg);
	self.viewingrules = time + 0.25;
}

float gmapn_display_rules()
{
	float newkeys, keys;

	if (time < 1)	//can do weird things on loading screens
		return TRUE;

	// display a help text when match is started
	if (self.matchtime > max(0, time - 12))
	{
		gmapn_display_welcome();
		return FALSE;
	}

	if (gmapn_serverstate == gmapn_serverstate_lockready)
	{
		self.maxspeed = 0;
		self.rulesel = 0;
	}

	if (self.maxspeed && self.movement || self.button2)
	{
		if (gmapn_serverstate < gmapn_serverstate_playing)
			self.movetime = time + 3;
	}

	if (self.menutime > time || self.menutime < time - 3)
	{
		self.menutime = time + 3;
		self.movetime = time + 3;
	}

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

	if (newkeys & KEY_JUMP && gmapn_serverstate < gmapn_serverstate_playing)
	{
		if (self.movetime < time)
			self.viewingrules = time;
		self.movetime = time + 3;
	}

	if (self.movetime > time)
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

	if (gmapn_serverstate == gmapn_serverstate_prewar)
	{
		if (self.menutime > time)
		{
			centerprint(self, sprintf("Type %s to bind ENTER\n\nPress ENTER to show the menu", redify(".menu bind")));
			return FALSE;
		}
	}
	else if (gmapn_serverstate == gmapn_serverstate_countdown)
	{
		centerprint(self, gmapn_menu_countdown());
		return FALSE;
	}
	else if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		if (gmapn_gamemode == GM_FREEZETAG)
		{
			if (self.viewingrules < time && self.deadflag)
			{
				centerprint(self, "YOU ARE FROZEN!\nHARASS A TEAM MATE TO HELP YOU!");
				self.viewingrules = time + 1;
			}
		}

		if (gmapn_gamemode == GM_HEADHUNTER)
		{
			if (self.viewingrules < time && self.ammo_heads > 0)
			{
				if (self.ammo_heads > 1)
					centerprint(self, sprintf("YOU HAVE %s HEADS!\nBRING THEM TO THE ALTAR!", goldnmbr(ftos(self.ammo_heads))));
				else
					centerprint(self, sprintf("YOU HAVE %s HEAD!\nBRING IT TO THE ALTAR!", goldnmbr(ftos(self.ammo_heads))));
				self.viewingrules = time + 1;
			}
		}

		return FALSE;
	}
	else if (gmapn_serverstate == gmapn_serverstate_breather)
	{
		// FIXME: move serverstate logic into gmapn_menu_any and centerprint info
		// about health/armor/round countdown/frozen/etc there
		// breathers prints the time until the next round starts

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
