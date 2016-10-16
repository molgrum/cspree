/*
    gmapn_game.qc

    Copyright (C) 2007 Mark Olsen
    Copyright (C) 2009 Andreas Nilsson
    Copyright (C) 2013 David Walton

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

static float gmapn_roundslimit;
static float gmapn_teamscores_red;
static float gmapn_teamscores_blue;

//let clients know the correct time.
float gmapn_matchstarttimems;

void() gmapn_round_end;

void gmapn_find_teamnames()
{
	gmapn_team_red = gmapn_team_blue = string_null;

	for(entity e = world; (e = find(e, classname, "player")); )
	{
		if (gmapn_team_red != string_null && gmapn_team_blue != string_null)
			break; // don't interate more than necessary

		if (gmapn_team_red == string_null)
			gmapn_team_red = e.teamname;
		else if (gmapn_team_blue == string_null && gmapn_team_red != e.teamname)
			gmapn_team_blue = e.teamname;
	}

	if (gmapn_team_red == string_null || gmapn_team_blue == string_null)
	{
		gmapn_team_red = "red";
		gmapn_team_blue = "blue";
	}
};

void gmapn_game_score_teampoint(string t, float points)
{
	if (t == gmapn_team_red)
		gmapn_teamscores_red += points;
	else if (t == gmapn_team_blue)
		gmapn_teamscores_blue += points;
};

void gmapn_record_demo()
{
	entity e;
	string recordstr, datetime;

	// FIXME: gmapn_recording should be set to TRUE in this function, not outside
	if (gmapn_recording == FALSE)
	{
		dprintln("Error: mod is not aware of any recording to be executed");
		return;
	}

	recordstr = "easyrecord ";
	recordstr = strcat(recordstr, getkey(game_mode), "_");

	switch (gmapn_gamemode)
	{
	case GM_DUEL:
		e = find(world, classname, "player");
		if (e)
		{
			recordstr = strcat(recordstr, e.netname, "_vs");
		}
		else
		{
			dprintln("Error: game mode requires players to record demo");
			return;
		}
		e = find(e, classname, "player");
		if (e)
		{
			recordstr = strcat(recordstr, "_", e.netname, "_");
		}
		else if (getkey(game_botskill))
		{
			recordstr = strcat(recordstr, "_bots_");
		}
		else
		{
			dprintln("Error: game mode requires more players to record demo");
			return;
		}
		break;
	case GM_2ON2:
	case GM_TDEATHMATCH:
		if (gmapn_team_red == string_null && gmapn_team_blue == string_null)
		{
			dprintln("Error: teams are not found!");
			return;
		}
		else if (gmapn_team_blue == string_null)
			recordstr = strcat(recordstr, gmapn_team_red, "_vs_bots", "_");
		else if (gmapn_team_red == string_null)
			recordstr = strcat(recordstr, gmapn_team_blue, "_vs_bots", "_");
		else
			recordstr = strcat(recordstr, gmapn_team_red, "_vs_", gmapn_team_blue, "_");
		break;
	default:
		break;
	}

	datetime = strftime(TRUE, "%H%M");
	recordstr = strcat(recordstr, mapname, "_");
	localcmd(strcat(recordstr, datetime, "\n"));
};

void gmapn_game_beginpregamecountdown(float countdowntime)
{
	if (cvar("teamplay"))
		gmapn_find_teamnames();

	if (coop == 0 && getkey(game_record))
	{
		gmapn_recording = TRUE;
		//localcmd("easyrecord\n");
		gmapn_record_demo();
	}
	localcmd("serverinfo status countdown\n");

	if (countdowntime < 0)
		countdowntime = 10;

	gmapn_countdown_start(countdowntime, gmapn_game_start, gmapn_countdown_style_prewar);

	gmapn_serverstate = gmapn_serverstate_countdown;
};

void gmapn_game_endpregamecountdown()
{
	if (gmapn_recording)
		localcmd("stop;rmdemonum 1\n");
	gmapn_recording = FALSE;
	localcmd("serverinfo status standby\n");

	gmapn_serverstate = gmapn_serverstate_prewar;
	gmapn_countdown_stop();
};

void gmapn_game_end()
{
	entity disconnected_player;
	
	localcmd("serverinfo status standby\n");
	
	entity e = find(world, classname, "gmapn_round_check");
	if (e)
		remove(e);

	e = find(world, classname, "gmapn_disconnected_player");
	while (e)
	{
		disconnected_player = spawnclient();

		disconnected_player.classname = "player";
		disconnected_player.netname = e.netname;
		if (gmapn_reconnected_player(disconnected_player) == TRUE)
		{
			disconnected_player.netname = strcat(chr2str(0x87), " ", disconnected_player.netname);
			e = find(world, classname, "gmapn_disconnected_player");
		}
		else
			break; // nothing left to do
	}

	gmapn_game_stats();
	gmapn_sql_logmatch();
	gmapn_countdown_stop();
	gmapn_serverstate = gmapn_serverstate_intermission;
	
	//if any players are dead, clear that out so that they appear properly on the scoreboard, and don't carry their spec status over to the next map.
	for (e = world; (e = find(e, classname, "player")); )
	{
		client_clearspectator(e);
		hidepic("hc", e);
	}
		
	execute_changelevel();
};

static void gmapn_randomize_playerteams()
{
	//FIXME: simple alternating sucks.
	//build a list of all pending players, then pull out a random one each time?
	float alt = floor(random() * 2);
	for (entity player = world; (player = find(player, classname, "player")); )
	{
		if (alt++ & 1)
		{
			gmapn_setteamandcolour(player, "red", 4, 4);
			centerprint(player, "You are now on RED team");
		}
		else
		{
			gmapn_setteamandcolour(player, "blue", 13, 13);
			centerprint(player, "You are now on BLUE team");
		}
	}
};

static float duel_count_challengers()
{
	float cnt = 0;
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (e.ready)
			cnt += 1;
	}
	return cnt;
}
static float duel_spawn_challenger()
{
	entity oldest = 0;
	float age = 0;
	string str;
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (e.deadflag && e.ready)
		if (!oldest || age > e.challengertime)
		{
			oldest = e;
			age = e.challengertime;
		}
	}
	if (!oldest)
		return FALSE;	//err... noone left to duel...
		
	self = oldest;
	client_clearspectator(self);
	self.challengertime = time;
	respawn_living();
	str = strcat("Round ", ftos(gmapn_roundnum + 1), "\nYou're up!");
	centerprint(self, str);
	bprint(PRINT_HIGH, self.netname, " is up!\n");
	stuffcmd(self, "bf 1 1 1 0.3 0.5\n");	//white flash
	return TRUE;
};

static void lastmancheck()
{
	self.nextthink = time + 1;
	
	if (teamplay)
	{
		string aliveteam = 0;
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (!e.deadflag)
			{
				if (aliveteam)
				{
					if (aliveteam != e.teamname)
						return;	//multiple live teams.
				}
				else
					aliveteam = e.teamname;
			}
		}
		
		if (aliveteam)
		{
			bprint(PRINT_HIGH, "Team ", aliveteam, " wins the round!\n");

			for (entity e = world; (e = find(e, classname, "player")); )
			{
				if (e.teamname == aliveteam)
					centerprint(e, "YOUR team wins the round!");
				else
					centerprint(e, "Team ", aliveteam, " wins the round!");
			}
			
			if (gmapn_gamemode != GM_ROVER)
			for (entity e = world; (e = find(e, classname, "player")); )
			{
				if (aliveteam == e.teamname)
					e.frags += 1;
			}
		}
		else
			bprint(PRINT_HIGH, "Round is drawn!\n");
	}
	else
	{
		entity aliveplayer = world;
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (!e.deadflag)
			{
				if (aliveplayer)
					return;	//multiple live players.
				aliveplayer = e;
			}
		}
		if (aliveplayer)
		{
			bprint(PRINT_HIGH, aliveplayer.netname, " wins the round!\n");
			aliveplayer.frags += 1;
		}
		else
			bprint(PRINT_HIGH, "Round is drawn!\n");
	}

	gmapn_round_end();
};

static void duelcheck()
{
	self.nextthink = time + 1;

	float liveplayers = 0;
	float totalplayers = 0;
	entity liveplayer = world;
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		//only ready players may be selected.
		if (e.ready)
		{
			if (!e.deadflag)
			{
				liveplayers++;
				liveplayer = e;
			}
			totalplayers++;
		}
	}
	
	//don't spam weird messages if there's only one ready player alive.
	//note: there is some weirdness in that breaking will de-spawn you if there are two or less possible players, and will not if there are 3. both cases won't respawn you of course.
	if (totalplayers < 2)
	{
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (e.ready)
				centerprint(e, "Waiting for competitors");
			else
				centerprint(e, "You are not ready!");
			if (!e.deadflag)
			{
				te_teleport(e.origin);
				forceinfokey(e, "*spectator", "2");
				e.movetype = MOVETYPE_TOSS;
				e.solid = SOLID_NOT;
				e.takedamage = DAMAGE_INVINCIBLE;
				e.vw_index = 0;
				e.think = 0;
				e.nextthink = 0;
				e.touch = 0;
				setmodel(e, "");
				e.deadflag = DEAD_DEAD;
				entity oself = self;
				self = e;
				respawn_living();
				self = oself;
			}
		}
		self.cnt = TRUE;
		return;
	}
	
	if (self.cnt)
	{
		while (liveplayers < 2)	//both players may have died.
		{
			if (!duel_spawn_challenger())
				break;
			liveplayers++;
		}
		self.cnt = FALSE;
		return;
	}

	if (liveplayers < 2)
	{	//find the player that has been sitting around for the longest without doing anything.
		if (liveplayers == 1)
		{
			for (entity e = world; (e = find(e, classname, "player")); )
			{
				if (e == liveplayer)
					centerprint(e, "You are victorious!");
				else
					centerprint(e, liveplayer.netname, " is victorious!\n", goldnmbr(ftos(liveplayer.health)), " health and ", goldnmbr(ftos(liveplayer.armorvalue)), " armor left");
			}
		}
		else
		{
			for (entity e = world; (e = find(e, classname, "player")); )
				centerprint(e, "Duel is tied!");
		}
		gmapn_round_end();	//okay, we're done.
	}
};

float game_is_tied()
{
	float side1, side2; // represents scores in duel and tdm

	side1 = side2 = 0;

	if (gmapn_gamemode == GM_DUEL)
	{
		entity e;
		e = find(world, classname, "player");
		if (e)
		{
			side1 = e.frags;
			e = find(e, classname, "player");
			if (e)
				side2 = e.frags;
		}
	}
	else if (gmapn_gamemode == GM_2ON2 || gmapn_gamemode == GM_TDEATHMATCH)
	{
		side1 = gmapn_teamscores_red;
		side2 = gmapn_teamscores_blue;
	}
	else
		return FALSE; // FIXME: don't care about other modes yet

	// equal frags, game is tied
	if (side1 == side2)
		return TRUE;

	return FALSE;
};

/*void spawnfake()
{
	entity p, oself;
	vector pos;

	p = spawn();
	p.classname = "fakeplayer";
	p.solid = SOLID_BBOX;
	p.movetype = MOVETYPE_STEP;
	p.view_ofs = '0 0 22';
	p.takedamage = DAMAGE_BLEED;
	p.deadflag = DEAD_NO;
	p.flags = FL_ONGROUND;
	p.items = IT_AXE | IT_SHOTGUN;
	p.health = 100;
	p.found = FALSE;
	p.netname = "faker";
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (e.teamname == gmapn_team_hiders)
		{
			p.colormap = e.colormap;
			break;
		}
	}
	oself = self;
	self = p;
	do
	{
		pos = '0 0 0';
		pos_x = random()*world.mins_x + random()*world.maxs_x;
		pos_y = random()*world.mins_y + random()*world.maxs_y;
		pos_z = random()*world.mins_z + random()*world.maxs_z;
		setorigin(self, pos);
		setmodel(self, "progs/player.mdl");
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	} while (!droptofloor());

	player_stand();

	self = oself;
	};*/

void gmapn_hideandseek_check()
{
	float alldead, seekers, hiders;

	self.nextthink = time + 1;

	seekers = 0;
	hiders = 0;
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (e.teamname == gmapn_team_seekers)
			seekers += 1;
		else if (e.teamname == gmapn_team_hiders)
			hiders += 1;
	}

	if (seekers == 0 || hiders == 0)
	{
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			centerprint(e, "Waiting for more players to join...");
		}

		return;
	}
	
	alldead = TRUE;
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (e.teamname == gmapn_team_seekers && e.deadflag == DEAD_NO)
		{
			alldead = FALSE;
		}
	}

	if (gmapn_flag_found == TRUE)
	{
		bprintln(PRINT_HIGH, sprintf("The documents have been found, team %s wins!", gmapn_team_seekers));
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (e.teamname == gmapn_team_seekers)
			{
				centerprint(e, "Congratulations, your team is victorious!");
			}
			else
				centerprint(e, "The enemy team scores.");
		}
		gmapn_round_end();
	}
	else if (alldead == TRUE)
	{
		bprintln(PRINT_HIGH, "Round is a over, all seekers dead.");
		gmapn_round_end();
	}
	else
	{
		// hiders still alive, award one frag per second
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (e.teamname == gmapn_team_hiders && e.maxspeed == 0 && e.found == FALSE)
			{
				if (!(rint(time - (gmapn_matchstarttimems / 1000)) % 10))
				{
					stuffcmd(e, "bf\n");
					e.frags += 1;
					sound(e, CHAN_ITEM, "items/r_item2.wav", 1, ATTN_NORM);
				}
			}
		}
	}
};

void gmapn_hideandseek_report()
{
	gmapn_flag_found = TRUE;
}

void gmapn_hideandseek_touch()
{
	if (other.teamname != gmapn_team_seekers)
		return;
	
	stuffcmd(other, "bf\n");
	centerprint(other, "Picked up documents, reporting to HQ...");
	self.model = string_null;
	self.touch = func_null;
	self.nextthink = time + 5;
	self.think = gmapn_hideandseek_report;
}

void gmapn_hideandseek_drop()
{
	entity docs;
	
	docs = spawn();
	docs.classname = "item_documents";
	docs.solid = SOLID_TRIGGER;
	docs.touch = gmapn_hideandseek_touch;
	
	setorigin(docs, self.origin);
	setmodel(docs, "progs/backpack.mdl");
	setsize(docs, VEC_HULL_MIN, VEC_HULL_MAX);

	centerprint(self, "Documents stashed.");
	self.maxspeed = 320;
}

void gmapn_hideandseek_start()
{
	entity e, oself;

	bprintln(PRINT_HIGH, sprintf("Go team %s!", gmapn_team_seekers));
	for (e = world; (e = find(e, classname, "player")); )
	{
		if (e == gmapn_flag_carrier)
		{
			centerprint(e, "Dropping documents.");
			e.maxspeed = 0;
			e.nextthink = time + 3;
			e.think = gmapn_hideandseek_drop;
		}
		else
		{
			oself = self;
			self = e;
			self.dimension_seen = 1;
			self.dimension_see = 1;
			client_clearsemispectator(self);
			respawn_living();
			self = oself;
			centerprint(e, "Start searching for the documents!");
		}
	}
};

void gmapn_round_start()
{
	entity e;

	for (int i = 0; i < itemnames.length; i++)
		gmapn_reset_entities(itemnames[i]);
	
	//let clients know the correct time.
	gmapn_matchstarttimems = 1000*time;

	//lets have 1-based rounds
	gmapn_roundnum++;
	
	//rover re-randomizes teams on EVERY round restart
	if (gmapn_gamemode == GM_ROVER)
		gmapn_randomize_playerteams();

	if (gmapn_gamemode == GM_KING)
	{	//in king of the hill, everyone starts equal until someone dies.
		//fixme: should we maybe pick a player randomly instead?
		for (e = world; (e = find(e, classname, "player")); )
		{
			gmapn_setteamandcolour(e, "pleb", 3, 3);
		}
		//clear teamplay, so that skin forcing doesn't break things.
		cvar_set("teamplay", "0");
		teamplay = 0;
	}

	//duel arena don't allow respawns until the end of the round.
	if (gmapn_gamemode == GM_DA)
	{
		float liveplayers = 0;
		float totalplayers = 0;
		for (e = world; (e = find(e, classname, "player")); )
		{
			if (e.ready)
				totalplayers++;
			if (!e.deadflag)
			{
				liveplayers++;
				if (!stof(infokey(e, "*spectator")))
				{
					//dueling players both respawn.
					self = e;
					if (!e.ready)
					{
						e.challengertime = time;
						client_setspectator(e);
						e.deadflag = DEAD_DEAD;	//stay dead...
						liveplayers--;
					}
					respawn_living();
				}
			}
		}
		
		//any player which isn't alive is a spectator now.
		//make sure the guy that died is converted properly.
		for (e = world; (e = find(e, classname, "player")); )
		{
			if (!e.deadflag)
				continue;
			if (!stof(infokey(e, "*spectator")))
			{
				CopyToBodyQue(e);

				setmodel(e, "");
				client_setspectator(e);
				e.challengertime = time;
//				respawn_living();
				e.deadflag = DEAD_DEAD;	//stay dead...
				stuffcmd(e, "bf 0 0 0 0.3 0.5\n");	//black flash, so people realise that they're now out.
			}
		}
	}
	else if (gmapn_gamemode == GM_HIDENSEEK)
	{
	  	float rnd = floor(random() * 2); // FIXME: alternate between teams
		if (gmapn_roundnum == 1)
		{
			dprintln("round 1, randomizing teams");
			if (rnd == 0)
			{
				// red starts
				gmapn_team_hiders = gmapn_team_red;
				gmapn_team_seekers = gmapn_team_blue;
			}
			else
			{
				// blue starts
				gmapn_team_hiders = gmapn_team_blue;
				gmapn_team_seekers = gmapn_team_red;
			}
		}

		float swapteams;
		swapteams = gmapn_flag_found;

		if (swapteams != FALSE)
		{
			if (gmapn_team_hiders == gmapn_team_red)
			{
				gmapn_team_hiders = gmapn_team_blue;
				gmapn_team_seekers = gmapn_team_red;
			}
			else
			{
				gmapn_team_hiders = gmapn_team_red;
				gmapn_team_seekers = gmapn_team_blue;
			}
		}

		gmapn_flag_found = FALSE;

		gmapn_countdown_start(15, gmapn_hideandseek_start, gmapn_countdown_style_game);
		bprintln(PRINT_HIGH, sprintf("Team %s is up!", gmapn_team_hiders));

		float count = 0;

		for (e = world; (e = find(e, classname, "player")); )
		{
			if (e.teamname == gmapn_team_hiders)
			{
				count += 1;
			}
		}

		rnd = floor(random() * count);
	   
		for (e = world; (e = find(e, classname, "player")); )
		{
			e.maxspeed = autocvar(sv_maxspeed, 320);
			if (e.teamname == gmapn_team_hiders)
			{
				self = e;
				self.deadflag = DEAD_NO;
				self.found = FALSE;
				self.dimension_seen = 1;
				self.dimension_see = 1;
				client_clearsemispectator(self);
				respawn_living();
				stuffcmd(e, "bf 1 1 1 0.5 0.5\n");
				
				if (rnd == 0)
				{
					gmapn_flag_carrier = e;
					centerprint(e, "You're up, hide the documents!");
				}

				rnd -= 1;
			}
			else
			{
				self = e;
				self.deadflag = DEAD_NO;
				self.dimension_seen = 0;
				self.dimension_see = 0;
				client_setsemispectator(self);
				centerprint(self, "Giving hiders a head start...");
			}
		}
	}
	else
	{
		for (e = world; (e = find(e, classname, "player")); )
		{
			self = e;
			client_clearspectator(e);
			respawn_living();
			stuffcmd(e, "bf 1 1 1 0.5 0.5\n");	//flashy!
		}
	}
	if (gmapn_gamemode == GM_HIDENSEEK)
	{
		self = spawn();
		self.classname = "gmapn_round_check";
		self.think = gmapn_hideandseek_check;
		self.nextthink = max(5,time);
	}
	if (gmapn_gamemode == GM_DA)
	{
		self = spawn();
		self.classname = "gmapn_round_check";
		self.think = duelcheck;
		self.cnt = TRUE;	//will try to spawn players when possible.
		self.nextthink = max(1,time);	//how long does it take for people to change maps? should we wait while there are still people (down)loading?
	}
	if (gmapn_gamemode == GM_LASTMANSTANDING || gmapn_gamemode == GM_FREEZETAG || gmapn_gamemode == GM_ROVER)
	{
		self = spawn();
		self.classname = "gmapn_round_check";
		self.think = lastmancheck;
		self.nextthink = max(5, time);	//how long does it take for people to change maps? should we wait while there are still people (down)loading?
	}
	
	if (gmapn_roundslimit > 1)
		bprint(PRINT_HIGH, sprintf("Round %g of %g!\n", gmapn_roundnum, gmapn_roundslimit));
};

//called after intra-round breather
void gmapn_round_restart()
{
	self.nextthink = time + 1;
	self.cnt--;
	if (self.cnt > 0)
	{
		for (entity e = world; (e = find(e, classname, "player")); )
			centerprint(e, sprintf(_("Round %s of %s starts in "), goldnmbr(ftos(gmapn_roundnum+1)), goldnmbr(ftos(getkey(game_rounds)))), goldnmbr(ftos(self.cnt)), " seconds");
		sound(self, CHAN_VOICE, sprintf("announcer/%g.wav", self.cnt), 1, ATTN_NONE, 100, SOUNDFLAG_RELIABLE|8, 0);
	}
	else
	{
		sound(self, CHAN_VOICE, "announcer/fight.wav", 1, ATTN_NONE, 100, SOUNDFLAG_RELIABLE|8, 0);
		remove(self);
		gmapn_round_start();
		gmapn_countdown_start(timelimit, gmapn_round_end, gmapn_countdown_style_game);
	}
};

//called when a round has ended, gives time for a breather.
void gmapn_round_end()
{
	// applies for duel, 2on2 and tdm
	if (game_is_tied())
	{
		bprintln(PRINT_HIGH, sprintf(_("Game is tied, %s minutes overtime follows"), ftos(getkey(overtime))));
		self.cnt += getkey(overtime) * 60;
		return;
	}
	// FIXME: display the below when time is up, not otherwise
/*
	for (entity e = world ; e = find(e, classname, "player") ; )
	{
		centerprint(e, "Time's up!");
	}
*/
	gmapn_countdown_stop();
	
	//don't fight too much
	other = find(world, classname, "gmapn_round_check");
	if (other)
		remove(other);

	if (gmapn_gamemode == GM_HIDENSEEK)
	{
		other = find(world, classname, "item_documents");
		if (other)
			remove(other);
	}
	
	if (gmapn_roundslimit == gmapn_roundnum)
		gmapn_game_end();
	else
	{
		other = spawn();
		other.classname = "gmapn_round_check";
		other.think = gmapn_round_restart;
		other.nextthink = time + 2;
		other.cnt = 4;
	}
};

//called at the very start of the game
void gmapn_game_start()
{
	//entity player;
	entity oldself;
	gmapn_roundnum = 0;
	gmapn_roundslimit = 1;

	oldself = self;

	timelimit = cvar("timelimit")*60;
	teamplay = cvar("teamplay");
	deathmatch = cvar("deathmatch");
	
	if (gmapn_gamemode == GM_COOP)
		teamplay = TRUE;

	if (gmapn_ismatchless(gmapn_gamemode))
		serverflags |= SV_MATCHLESS;
	else
		serverflags &= ~SV_MATCHLESS;

	gmapn_reset_entities("func_button");
	gmapn_reset_entities("func_door");
	gmapn_reset_entities("func_door_secret");
	gmapn_reset_entities("func_plat");
	gmapn_reset_entities("func_train");
	gmapn_reset_entities("trigger_counter");
	gmapn_reset_entities("trigger_once");
	gmapn_reset_entities("trigger_onlyregistered");
	gmapn_reset_entities("info_controlpoint");
//	gmapn_reset_entities("item_flag");

	//kill any lingering menus
	for (self = world; (self = find(self, classname, "player")); )
		centerprint(self, "");

	localcmd("serverinfo status playing\n");
	if (gmapn_ismatchless(gmapn_gamemode))
		bprint(PRINT_MEDIUM, _("The game has begun - "), gmapn_gamemodefullname(gmapn_gamemode), "\n");
	else
		bprint(PRINT_MEDIUM, _("The match has begun - "), gmapn_gamemodefullname(gmapn_gamemode), "\n");
	gmapn_serverstate = gmapn_serverstate_playing;

	gmapn_roundslimit = gmapn_gamemode_rounds(gmapn_gamemode);
	if (gmapn_gamemode == GM_DA)
	{
		gmapn_roundslimit = getkey(game_rounds);
		for (self = world; (self = find(self, classname, "player")); )
		{
			self.deadflag = DEAD_DEAD;
			self.challengertime = time-random();
			client_setspectator(self);
		}

		duel_spawn_challenger();
		duel_spawn_challenger();
		gmapn_round_start();
	}
	else
	{
/*
		player = find(world, classname, "player");
		while(player)
		{
			self = player;
			respawn_living();
			stuffcmd(self, "bf 1 1 1 0.3\n");	//white flash to signify the round started
			player = find(player, classname, "player");
		}
*/		
		gmapn_round_start();
	}
	
	if (gmapn_gamemode == GM_FREEZETAG)
		precache_sound("player/frozen1.wav");
	if (gmapn_gamemode == GM_DOMINATION)
		domination_startup();
	if (gmapn_gamemode == GM_HEADHUNTER)
		headhunter_startup();
	if (gmapn_gamemode == GM_CTF)
		ctf_enableflags(TRUE);

	if (getkey(game_botskill) > 0)
	{
		if (cvar("teamplay") && coop == 0)
			BotBalanceTeams(getkey(minteamsize));
		else
			BotEnforceMinimum(getkey(minplayers));	
	}
	
	if ((gmapn_gamemode == GM_COOP) != coop || (coop && skill != cvar("skill")))
	{
		cvar_set("coop", ftos(gmapn_gamemode == GM_COOP));
		if (gmapn_gamemode == GM_COOP)
			cvar_set("deathmatch", "");
		serverflags = SV_MATCHLESS;	//also clears out any runes.
		changelevel(mapname);
	}
	
	if (timelimit)
		gmapn_countdown_start(timelimit, gmapn_round_end, gmapn_countdown_style_game);
	else
		bprint(PRINT_HIGH, "WARNING: no timelimit set\n");

	self = oldself;
};

void gmapn_forcestart_check()
{
	entity p;
	float allplayersready;

	allplayersready = TRUE;
	p = find(world, classname, "player");
	while (p)
	{
		if (!p.ready)
		{
			allplayersready = FALSE;
			localcmd("kick ");
			localcmd(infokey(p, INFOKEY_P_USERID));
			localcmd("\n");
		}
		p = find(p, classname, "player");
	}

	if (allplayersready == FALSE)
	{
		gmapn_serverstate = gmapn_serverstate_prewar;
		bprintln(PRINT_HIGH, "Not enough players ready, aborting countdown.");
	}
	else
	{
		gmapn_game_beginpregamecountdown(getkey(prewar_countdown));
	}
	remove(self);
};

void gmapn_forcestart()
{
	self.ready = 1;
	gmapn_serverstate = gmapn_serverstate_forcestart;
	gmapn_countdown_start(getkey(forcestart_countdown), gmapn_forcestart_check, gmapn_countdown_style_forcestart);
};
