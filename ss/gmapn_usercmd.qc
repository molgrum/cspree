/*
	gmapn_usercmd.qc

	Copyright (C) 2007 Mark Olsen

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

#if 1
vector VelocityForDamage(float dm)
{
	vector v;

	{
		v_x = 100 * crandom();
		v_y = 100 * crandom();
		v_z = 200 + 100 * random();
	}

	//v_x = 100 * crandom();
	//v_y = 100 * crandom();
	//v_z = 200 + 100 * random();

	if (dm > -50)
	{
	//		dprint ("level 1\n");
		v = v * 0.7;
	}
	else if (dm > -200)
	{
	//		dprint ("level 3\n");
		v = v * 2;
	}
	else
		v = v * 10;

	return v;
};

void ThrowGib(string gibname, float dm)
{
	  entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};
#endif

void cmd_ready()
{
	entity player;
	float playersready, playerstotal, playersneeded;
	float count_red, count_blue, count_other;

	playersneeded = 0;
	switch (gmapn_serverstate)
	{
	case gmapn_serverstate_prewar:
	case gmapn_serverstate_forcestart:
	case gmapn_serverstate_lockready:

		if (cvar("teamplay"))
		{
			if (gmapn_gamemode == GM_COOP)
				forceinfokey(self, "team", (self.teamname="coop"));
			else if (self.teamname == "")
			{
				sprintln(self, PRINT_HIGH, _("Set your team first!"));
				return;
			}
			gmapn_find_teamnames();
		}

		playerstotal = 0;
		playersready = 0;
		count_red = 0;
		count_blue = 0;
		count_other = 0;

		player = find(world, classname, "player");
		while(player)
		{
			playerstotal+=1;
			if (player == self || player.ready || !player.ishuman)
			{
				playersready+=1;
			}
			if (player.teamname == gmapn_team_red)
				count_red += 1;
			else if (player.teamname == gmapn_team_blue)
				count_blue += 1;
			else
				count_other += 1;

			player = find(player, classname, "player");
		}

		switch(gmapn_gamemode)
		{
		case GM_DUEL:
		case GM_2ON2:
		case GM_TDEATHMATCH:
			playersneeded = getkey(minplayers) * !getkey(game_botskill);
			playersneeded += playerstotal * !!getkey(game_botskill);
			break;
		default:
			playersneeded = ceil(playerstotal * 0.51);
			break;
		}

		switch(gmapn_gamemode)
		{
		case GM_TDEATHMATCH:
		case GM_2ON2:
		case GM_LASTMANSTANDING:
		case GM_FREEZETAG:
		case GM_DOMINATION:
		case GM_CTF:
		case GM_HIDENSEEK:
			if (count_red+count_blue+count_other > getkey(maxteamsize)*2)
				sprint(self, PRINT_HIGH, _("There are too many people to begin a game.\n"));
			else if (count_red > getkey(maxteamsize))
				sprint(self, PRINT_HIGH, sprintf(_("There are too many people on %s team.\n"), gmapn_team_red));
			else if (count_blue > getkey(maxteamsize))
				sprint(self, PRINT_HIGH, sprintf(_("There are too many people on %s team.\n"), gmapn_team_blue));
			else
			{
				break;
			}
			return;	//refuse the readyup
		case GM_ROVER:	//teams are always randomly assigned
		case GM_FFA:
		case GM_KING:
		case GM_DA:
		case GM_HEADHUNTER:
		case GM_DUEL:
		default:
			//FIXME: force some players to (true) spectators if the max is exceeded.
			break;
		}

		if (!self.ready)
		{
			self.ready = 1;
			bprint(PRINT_HIGH, self.netname, redify(_(" is ready")));

			// clan information
			if (cvar("teamplay") && !cvar("coop"))
				bprint(PRINT_HIGH, " ", chr2str(0x90), self.teamname, chr2str(0x91));

			if (playersready < playersneeded)
			{
				bprint(PRINT_HIGH, " - ", chr2str(0x90), goldnmbr(ftos(playersneeded-playersready)), chr2str(0x91), _(" to go\n"));
			}
			else
			{
				bprint(PRINT_HIGH, "!\n");
			}
		}
		else
		{
			sprint(self, PRINT_HIGH, _("You're already ready.\n"));
		}

		if (gmapn_serverstate != gmapn_serverstate_forcestart && playersready >= playersneeded)
		{
			if (cvar("teamplay") && !cvar("coop") && !getkey(game_botskill))
			{
				if (count_red < getkey(minteamsize))
				{
					sprint(self, PRINT_HIGH, sprintf(_("There are too few people on team %s\n"), gmapn_team_red));
					return;
				}
				else if (count_blue < getkey(minteamsize))
				{
					sprint(self, PRINT_HIGH, sprintf(_("There are too few people on team %s\n"), gmapn_team_blue));
					return;
				}
			}
			gmapn_game_beginpregamecountdown(getkey(prewar_countdown));
		}

		break;

	case gmapn_serverstate_playing:

		if (self.ready == 0)
		{
			bprint(PRINT_HIGH, self.netname, _(" withdraws his vote for stopping the match\n"));

			self.ready = 1;
		}

		break;
	}
};

void cmd_break()
{
	entity player;
	float playersready;

	switch (gmapn_serverstate)
	{
	case gmapn_serverstate_prewar:
	case gmapn_serverstate_forcestart:
	case gmapn_serverstate_lockready:

		if (self.ready)
		{
			bprint(PRINT_HIGH, self.netname, _(" is not ready\n"));
		}
		else
		{
			sprint(self, PRINT_HIGH, _("You're not ready yet, cannot break\n"));
		}

		break;

	case gmapn_serverstate_countdown:

		if (getkey(game_lockrules) > 0)
		{
			sprintln(self, PRINT_HIGH, _("Cannot break, the mode is forced."));
			return;
		}
		bprint(PRINT_HIGH, self.netname, _(" aborts the countdown\n"));
		self.ready = 0;

		gmapn_game_endpregamecountdown();

		break;

	case gmapn_serverstate_playing:

		if (self.ready)
		{
			playersready = 0;

			player = find(world, classname, "player");
			while(player)
			{
				if (player.ready)
					if (clienttype(player) != CLIENTTYPE_BOT)	//bots don't have a vote.
						playersready++;

				player = find(player, classname, "player");
			}

			playersready--;

			bprint(PRINT_HIGH, self.netname, _(" votes for stopping the match"));

			if (playersready != 0)
			{
				bprint(PRINT_HIGH, " - ", chr2str(0x90), goldnmbr(ftos(playersready)), chr2str(0x91), " to go\n");
			}
			else
			{
				bprint(PRINT_HIGH, "\n");
				bprint(PRINT_HIGH, _("The match is stopped!\n"));

				gmapn_game_end();
				serverflags &= ~SV_MATCHLESS;	//make sure the menus come back
			}
		}

		break;
	}

	self.ready = 0;

	if (gmapn_serverstate == gmapn_serverstate_prewar)
	{	//if they used the menu to switch team, or the game forced their team then reset them back to their preferred team.
		self.teamname = self.userteam;
		forceinfokey(self, "team", self.userteam);
	}
};

void cmd_forcestart()
{
	entity p;
	float totalplayers;

	if (gmapn_serverstate == gmapn_serverstate_forcestart)
	{
		sprintln(self, PRINT_HIGH, _("Forcestart is already in effect!"));
		return;
	}

	totalplayers = 0;
	p = find(world, classname, "player");
	while (p)
	{
		totalplayers++;
		p = find(p, classname, "player");
	}

	if (totalplayers < getkey(minplayers))
	{
		sprintln(self, PRINT_HIGH, _("Not enough players to start a game."));
		return;
	}

	bprintln(PRINT_HIGH, _("Forcestart initialized, ready up!"));
	gmapn_forcestart();
};

void cmd_rndmap()
{
	int mapsavailable;
	string map;

	mapsavailable = gmapn_map_pool_count();
	if (mapsavailable == 0)
	{
		dprintln("no maps on the server!");
		return;
	}

	map = gmapn_map_pool_readidx(floor(random() * mapsavailable));
	if (map == "")
	{
		dprintln("rndmap picked a nonexistent map!");
		return;
	}

	bprintln(PRINT_HIGH, sprintf(_("%s votes for random map!"), self.netname));

	stuffcmd(self, "cmd votemap ");
	stuffcmd(self, map);
	stuffcmd(self, "\n");
};

void cmd_kick(string nick)
{
	entity target = matchclientname(nick);

	evoter = spawn();

	evoter.enemy = target;
	evoter.think1 = gmapn_kick;

	if (vote_in_progress == FALSE)
		bprintln(PRINT_HIGH, sprintf(_("%s wants to kick %s"), self.netname, target.netname));

	if (gmapn_vote_init() == FALSE)
		remove(evoter);
};

void cmd_ban(string nick)
{
	entity target = matchclientname(nick);

	evoter = spawn();

	evoter.enemy = target;
	evoter.think1 = gmapn_ban;

	if (vote_in_progress == FALSE)
		bprintln(PRINT_HIGH, sprintf(_("%s wants to ban %s"), self.netname, target.netname));

	if (gmapn_vote_init() == FALSE)
		remove(evoter);
};

void cmd_mute(string nick)
{
	entity target = matchclientname(nick);

	evoter = spawn();

	evoter.enemy = target;
	evoter.think1 = gmapn_mute;

	if (vote_in_progress == FALSE)
		bprintln(PRINT_HIGH, sprintf(_("%s wants to mute %s"), self.netname, target.netname));

	if (gmapn_vote_init() == FALSE)
		remove(evoter);
};


void cmd_rulemaker(string nick)
{
	entity target;

	if (getkey(game_lockrules) > 0)
	{
		sprintln(self, PRINT_HIGH, _("Server is locked!"));
		return;
	}
	if (gmapn_gamemaster == self)
	{
		target = matchclientname(nick);

		if (nick == string_null || self == target)
		{
			sprintln(self, PRINT_HIGH, _("You are already a rulemaker!"));
			return;
		}
		else if (target)
		{
			gmapn_gamemaster = target;
			bprintln(PRINT_HIGH, sprintf(_("%s passes rulemaker status to %s"), self.netname, target.netname));

			return;
		}
		else
		{
			sprintln(self, PRINT_HIGH, sprintf(_("Could not match any name, you typed: %s"), nick));
			return;
		}
	}

	if (nick != string_null)
	{
		sprintln(self, PRINT_HIGH, _("You cannot pass rulemaker status without being one!"));
		return;
	}

	evoter = spawn();

	evoter.owner = self;
	evoter.think1 = gmapn_newrulemaker;

	if (vote_in_progress == FALSE)
		bprintln(PRINT_HIGH, sprintf(_("%s requests to become rulemaker! Type /yes to vote"), self.netname));

	if (gmapn_vote_init() == FALSE)
		remove(evoter);
}

void cmd_shownick()
{
	if (gmapn_serverstate != gmapn_serverstate_prewar)
		return;
	if (self.movetime < time)
		return; // don't clotter the menu

	makevectors(self.angles);
	traceline(self.origin, self.origin + v_forward*512, FALSE|MOVE_LAGGED, self);
	if (trace_fraction != 1.0 && trace_ent.classname == "player")
	{
		self.menutime = time + 1; // hide the menu for a short period
		centerprint(self, trace_ent.netname);
	}
}

void cmd_placespot()
{
	entity pointer;

	pointer = find(world, classname, "gmapn_pointer");
	if (!pointer)
		pointer = spawn();
	pointer.classname = "gmapn_pointer";
	setorigin(pointer, self.origin);
	setmodel(pointer, "progs/lavaball.mdl");
}

void cmd_printspot()
{
	entity pointer;

	pointer = find(world, classname, "gmapn_pointer");
	if (!pointer)
		sprintln(self, PRINT_HIGH, "No spot exists, place with /cmd placespot");
	else
		bprint(PRINT_HIGH, "coords: ", vtos(pointer.origin), "\n");
}

void cmd_setaltar()
{
	entity pointer, altar;

	pointer = find(world, classname, "gmapn_pointer");
	if (pointer)
	{
		altar = find(world, classname, "info_altar");
		if (altar)
		{
			sprintln(self, PRINT_HIGH, "Overriding existing altar...");
		}
		else
		{
			sprintln(self, PRINT_HIGH, "Setting new altar...");
			altar = spawn();
		}
		altar.classname = "info_altar";
		setorigin(altar, pointer.origin);
		setmodel(altar, "progs/v_spike.mdl");
		remove(pointer);
		return;
	}
	sprintln(self, PRINT_HIGH, "No spot exists, place with /cmd placespot");
}

void cmd_setcontrol()
{
	entity pointer, controlpoint;

	pointer = find(world, classname, "gmapn_pointer");
	if (pointer)
	{
		controlpoint = find(world, classname, "info_controlpoint");
		if (controlpoint)
		{
			sprintln(self, PRINT_HIGH, "Adding new control point...");
		}
		else
		{
			sprintln(self, PRINT_HIGH, "Setting first control point...");
			controlpoint = spawn();
		}
		controlpoint.classname = "info_controlpoint";
		setorigin(controlpoint, pointer.origin);
		setmodel(controlpoint, "progs/v_spike.mdl");
		remove(pointer);
		return;
	}
	sprintln(self, PRINT_HIGH, "No spot exists, place with /cmd placespot");
}

void cmd_writeconfig()
{
	entity e;
	filestream f;

	f = fopen("entities.conf", FILE_WRITE);
	if (f < 0)
		return;

	e = find(world, classname, "info_altar");
	if (e)
	{
		bprintln(PRINT_HIGH, vtos(e.origin));
		fputs(f, sprintf("info_altar %g %g %g\n", ftos(e.origin_x), ftos(e.origin_y), ftos(e.origin_z)));
	}

	e = find(world, classname, "info_controlpoint");
	while (e)
	{
		fputs(f, sprintf("info_controlpoint %g %g %g\n", ftos(e.origin_x), ftos(e.origin_y), ftos(e.origin_z)));
		e = find(e, classname, "info_controlpoint");
	}
	fclose(f);
	sprintln(self, PRINT_HIGH, "Wrote config.");
}

void cmd_menushow()
{
	self.movetime = -1;
	self.menutime = -1;
}

float gmapn_handle_setinfo(string key, string value)
{
	if (key == "team")
	{
		self.userteam = value;
		if (self.classname == "player" && (self.ready || gmapn_serverstate == gmapn_serverstate_countdown || gmapn_serverstate == gmapn_serverstate_playing))
		{
			if (self.teamname != self.userteam)
				sprint(self, PRINT_HIGH, "Your team will be changed at the end of the match.\n");
			return TRUE;
		}
		forceinfokey(self, "team", value);
		self.teamname = infokey(self, "team");
		return TRUE;
	}
	if (key == "name")
	{
		if (self.classname == "player" && (gmapn_serverstate == gmapn_serverstate_countdown || gmapn_serverstate == gmapn_serverstate_playing))
		{
			if (self.netname != value)
				sprint(self, PRINT_HIGH, "You cannot change name while the game is in progress.\n");
			return TRUE;
		}
	}
	return FALSE;
};

float gmapn_handle_usercmd(float argc)
{
	string cmd;
	string mapstr;
	string tempstr;

	float dmm;

	if (argc < 1)
		return 0;

	cmd = argv(0);

	if (self.is_fully_connected == 0)
		return 0;

	if (cmd == "ready")
	{
		cmd_ready();
		return 1;
	}
	if (cmd == "break" || cmd == "notready")
	{
		cmd_break();
		return 1;
	}
	if (cmd == "toggleready")
	{
		if (self.ready)
		{
			cmd_break();
		}
		else
		{
			cmd_ready();
		}
		return 1;
	}
	if (cmd == "forcestart")
	{
		if (gmapn_gamemaster == self)
			cmd_forcestart();
		else
			sprintln(self, PRINT_HIGH, "Only the rulemaker can forcestart!");
		return 1;
	}
	if (cmd == "yes" || cmd == "agree")
	{
		if (gmapn_vote_check(self) == FALSE)
			return 1;

		gmapn_vote(self, VOTE_YES);
		return 1;
	}
	if (cmd == "no" || cmd == "disagree")
	{
		if (gmapn_vote_check(self) == FALSE)
			return 1;

		gmapn_vote(self, VOTE_NO);
		return 1;

	}
	if (cmd == "abstain" || cmd == "dontcare")
	{
		if (gmapn_vote_check(self) == FALSE)
			return 1;

		gmapn_vote(self, VOTE_ABSTAIN);
		return 1;

	}
	if (cmd == "votemap")
	{
		if (argc != 2)
		{
			sprint(self, PRINT_HIGH, "Usage: /cmd votemap <mapname>\n");
		}
		else
		{
			if (getkey(maprotation) != "")
			{
				sprint(self, PRINT_HIGH, "Cannot change map while playing with maprotation.\n");
			}
			else if (gmapn_serverstate == gmapn_serverstate_prewar || gmapn_serverstate == gmapn_serverstate_intermission)
			{
				mapstr = argv(1);
				gmapn_mapvote_addvote(mapstr);
			}
			else
			{
				sprint(self, PRINT_HIGH, "Cannot change map while game is in progress.\n");
			}
		}

		return 1;
	}
	if (cmd == "rndmap")
	{
		cmd_rndmap();
		return 1;
	}
	if (cmd == "gamemode")
	{
		if (argc != 2)
		{
			sprint(self, PRINT_HIGH, "Usage: /cmd gamemode <mode>\n");
		}
		else
		{
			float newmode = gmapn_gamemodefromstring(argv(1));

			if (newmode < 0 || newmode >= GM_MODES)
				return 1;

			if (gmapn_serverstate == gmapn_serverstate_prewar)
			{
				gmapn_apply_gamemode(newmode);
				gmapn_config_load();
				gmapn_updatemaxclients();
				bprint(PRINT_HIGH, self.netname, " activated ", gmapn_gamemodetostring(newmode), " config.\n");
				}
			else
			{
				sprint(self, PRINT_HIGH, "Cannot change deathmatch while game is in progress.\n");
			}
		}

		return 1;
	}
	if (cmd == "kick")
	{
		if (argc != 2)
		{
			sprintln(self, PRINT_HIGH, "Usage: /cmd kick <nick>");
			return 1;
		}

		cmd_kick(argv(1));
		return 1;

	}
	if (cmd == "ban")
	{
		if (argc != 2)
		{
			sprintln(self, PRINT_HIGH, "Usage: /cmd ban <nick>");
			return 1;
		}

		cmd_ban(argv(1));
		return 1;

	}
	if (cmd == "mute")
	{
		if (argc != 2)
		{
			sprintln(self, PRINT_HIGH, "Usage: /cmd mute <nick>");
			return 1;
		}

		cmd_mute(argv(1));
		return 1;

	}
	if (cmd == "rulemaker")
	{
		cmd_rulemaker(argv(1));
		return 1;
	}
	if (cmd == "shownick")
	{
		cmd_shownick();
		return 1;
	}
	if (cmd == "dmm")
	{
		if (argc != 2)
		{
			sprint(self, PRINT_HIGH, "Usage: /cmd dmm [1-6]\n");
		}
		else
		{
			if (gmapn_serverstate == gmapn_serverstate_prewar)
			{
				dmm = floor(stof(argv(1)));
				if (dmm >= 1 && dmm <= 7 && dmm == stof(argv(1)))
				{
					tempstr = ftos(dmm);
					if (cvar("deathmatch") != dmm)
					{
						if (dmm == DMM_INSTAGIB)
							bprint(PRINT_HIGH, self.netname, " changes deathmatch to instagib.\n");
						else if (dmm == DMM_MIDAIR)
							bprint(PRINT_HIGH, self.netname, " changes deathmatch to midair.\n");
						else
							bprint(PRINT_HIGH, self.netname, " changes deathmatch to ", tempstr, ".\n");
						cvar_set("deathmatch", tempstr);
						if (dmm)	//make sure coop is set so the server is always multiplayer.
							cvar_set("coop", "0");
						else
							cvar_set("coop", "1");

						gmapn_powerups_setitems();
					}
					else
					{
						sprint(self, PRINT_HIGH, "Deathmatch is already ", tempstr, ".\n");
					}
				}
				else
				{
					sprint(self, PRINT_HIGH, "Invalid deathmatch mode. Valid modes are 1 to 7.\n");
				}
			}
			else
			{
				sprint(self, PRINT_HIGH, "Cannot change deathmatch while game is in progress.\n");
			}
		}

		return 1;
	}
	if (cmd == "powerups")
	{
		if (gmapn_serverstate == gmapn_serverstate_prewar)
		{
			gmapn_powerups_toggle();
		}
		else
		{
			sprint(self, PRINT_HIGH, "Cannot change powerup state while game is in progress.\n");
		}

		return 1;
	}
	if (cmd == "maxplayers" || cmd == "minplayers" || cmd == "players" || cmd == "teamsize" || cmd == "maxteamsize" || cmd == "minteamsize")
	{
		if (gmapn_serverstate != gmapn_serverstate_prewar)
			sprint(self, PRINT_HIGH, "Cannot change powerup state while game is in progress.\n");
		else
		{
			float lim = getkey(game_clientlimit);
			if (cmd == "maxplayers" || cmd == "players")
				setkey("maxplayers", ftos(bound(2, floor(stof(argv(1))), floor(lim))));
			if (cmd == "minplayers" || cmd == "players")
				setkey("minplayers", ftos(bound(0, floor(stof(argv(1))), floor(lim))));
			if (cmd == "teamsize" || cmd == "maxteamsize")
				setkey("maxteamsize", ftos(bound(1, floor(stof(argv(1))), floor(lim/2))));
			if (cmd == "teamsize" || cmd == "minteamsize")
				setkey("minteamsize", ftos(bound(0, floor(stof(argv(1))), floor(lim/2))));

			gmapn_updatemaxclients();
		}
		return 1;
	}
	if (cmd == "ffa")
	{	SV_ParseClientCommand("gamemode ffa"); return 1; }
	if (cmd == "1on1")
	{	SV_ParseClientCommand("gamemode duel"); SV_ParseClientCommand("maxplayers 2"); return 1; }
	if (cmd == "2on2")
	{	SV_ParseClientCommand("gamemode 2on2"); SV_ParseClientCommand("teamsize 2"); return 1; }
	if (cmd == "3on3")
	{	SV_ParseClientCommand("gamemode tdm"); SV_ParseClientCommand("teamsize 3"); return 1; }
	if (cmd == "4on4")
	{	SV_ParseClientCommand("gamemode tdm"); SV_ParseClientCommand("teamsize 4"); return 1; }
	if (cmd == "time")
	{
		if (argc != 2)
		{
			sprint(self, PRINT_HIGH, "Usage: /cmd time <time limit in minutes>\n");
		}
		else
		{
			if (gmapn_serverstate == gmapn_serverstate_prewar)
			{
				float newtimelimit;
				float oldtimelimit;
				string temps;

				oldtimelimit = cvar("timelimit");

				temps = argv(1);
				newtimelimit = stof(temps);
				newtimelimit = floor(newtimelimit);

				if (newtimelimit < 3)
					newtimelimit = 3;
				else if (newtimelimit > 30)
					newtimelimit = 30;

				if (newtimelimit != oldtimelimit)
				{
					temps = ftos(newtimelimit);

					bprint(PRINT_HIGH, self.netname, " changes time limit to ", temps, ".\n");

					cvar_set("timelimit", temps);
				}
			}
			else
			{
				sprint(self, PRINT_HIGH, "Cannot change time limit while game is in progress.\n");
			}
		}

		return 1;
	}
	if (cmd == "setinfo")
		return gmapn_handle_setinfo(argv(1), argv(2));
	if (cmd == "team" || cmd == "name")	//for NQ users that lack userinfos clientside.
		return gmapn_handle_setinfo(cmd, argv(1));
	if (cmd == "rpickup")
	{
		if (self.vote_rpickup == 0)
		{
			bprint(PRINT_HIGH, self.netname, " votes for a random pickup game.\n");
			self.vote_rpickup = 1;

			gmapn_rpickup_countvotes();
		}

		return 1;
	}
	if (cmd == "placespot")
	{
		cmd_placespot();
		return 1;
	}
	if (cmd == "printspot")
	{
		cmd_printspot();
		return 1;
	}
	if (cmd == "setaltar")
	{
		cmd_setaltar();
		return 1;
	}
	if (cmd == "setcontrol")
	{
		cmd_setcontrol();
		return 1;
	}
	if (cmd == "writeconfig")
	{
		cmd_writeconfig();
		return 1;
	}
	if (cmd == "menu")
	{
		if (argc < 2)
		{
			sprint(self, PRINT_HIGH, _("Usage: menu show\n"));
			return 1;
		}
		if (argv(1) == "show")
		{
			cmd_menushow();
			return 1;
		}
	}
	return 0;
};
