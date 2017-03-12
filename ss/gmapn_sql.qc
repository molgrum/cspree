/*
    gmapn_hazards.qc

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


static var float gmapn_sql_matchlogdb = -1;


/*
match:
	id (integer)
	date
	demname

player:
	iid (integer)
	guid (or name if no guid known)

matchplayer:
	mid == match.id
	pid == player.id
	damage
	etc
*/
/*
The player table is pretty much just to track player guids when they change names lots, etc
*/

string gmapn_sql_upgradestring[] =
{
	//initial database creation
	"BEGIN TRANSACTION;\n"
	"CREATE TABLE master (version INTEGER DEFAULT 1);\n"
	"CREATE TABLE match	("
					"id		INTEGER	PRIMARY KEY AUTOINCREMENT,"
					"date		DATETIME	DEFAULT CURRENT_TIMESTAMP,"
					"matchtype	INTEGER,"
					"map		TEXT,"
					"demname 	TEXT);\n"
	"CREATE TABLE player	("
					"id		INTEGER	PRIMARY KEY AUTOINCREMENT,"
					"regdate	DATETIME	DEFAULT CURRENT_TIMESTAMP,"
					"seen		DATETIME	DEFAULT CURRENT_TIMESTAMP,"
					"name		TEXT,"
					"guid		TEXT		UNIQUE);\n"
	"CREATE TABLE matchplayer	("
					"mid		INTEGER	REFERENCES match(id),"
					"pid		INTEGER	REFERENCES player(id),"
					"name		TEXT,"
					"kills 	INTEGER,"
					"deaths 	INTEGER);\n"

	"INSERT OR REPLACE INTO master DEFAULT VALUES;\n"
	"END TRANSACTION;\n"
	//,
	//"BEGIN TRANSACTION;\n"
	//"UPDATE master SET version=2;\n"
	//"END TRANSACTION;\n"
};
#define DBVERSION (float)(sizeof(gmapn_sql_upgradestring)/sizeof(gmapn_sql_upgradestring[0]))

static void sqlprintout(float serveridx, float queryidx, float rows, float columns, float eof, float firstrow)
{
	if (columns < 0 || rows < 0)
		print("Database error: ", sqlerror(serveridx, queryidx), "\n");
	else
	{
		if (!rows)
			print("sql completed\n");
		else	
		{
			float r,c;
			for (c = 0; c < columns; c++)
			{
				print(sqlreadfield(serveridx, queryidx, -1, c));
				print("\t");
			}
			print("\n");
			for (r = 0; r < rows; r++)
			{
				for (c = 0; c < columns; c++)
				{
					print(sqlreadfield(serveridx, queryidx, r, c));
					print("\t");
				}
				print("\n");
			}
		}
	}
};
static void sqlerroronerror(float serveridx, float queryidx, float rows, float columns, float eof, float firstrow)
{
	if (columns < 0 || rows < 0)
		dprint("Database error. Try deleting it to reset it. ", sqlerror(serveridx, queryidx), "\n");
};
static void gmapn_sql_upgradeDB(float db, float queryidx, float rows, float columns, float eof, float firstrow)
{
	float dbver;

	if (columns < 1 || rows < 1)
		dbver = 0;	//version starts on 0...
	else
		dbver = sqlreadfloat(db, queryidx, 0, 0);

	if (dbver < DBVERSION)
	{
		//its outdated (or new). run the upgrade.
		string str = gmapn_sql_upgradestring[dbver];
		float st, end;
		st = 0;

		dprint("updating database to version ", ftos(dbver), "\n");
		while(1)
		{
			end = strstrofs(str, "\n", st);
			if (end < 0)
				break;
			sqlopenquery(db, sqlerroronerror, 0, substring(str, st, end-st));
			st = end+1;
		}

		//restart the query for each revision.
		sqlopenquery(db, gmapn_sql_upgradeDB, 0, "SELECT version FROM master;");
	}
	else
	{
		//version is okay. let the rest of the code use the database now.
		gmapn_sql_matchlogdb = db;
		dprint("database active\n");
	}
};
void gmapn_sql_init()
{
	float db;
	if (!gmapn_qsg_has_fte_sql)
	{
		dprint("server does not support FTE_SQL, not using database\n");
		return;
	}

	db = sqlconnect("", "", "", "matchlog", "sqlite");
	if (db >= 0)
	{
		dprint("Opening database\n");
		sqlopenquery(db, gmapn_sql_upgradeDB, 0, "SELECT version FROM master;");
	}
	else
		dprint("sqlconnect failed\n");
};





static string playerguid(entity pl)
{
	string guid;
	//favour the guid, but use something else if its ezquake or something.
	if (clienttype(pl) == CLIENTTYPE_BOT)
		guid = sprintf("BOT:%s", pl.netname);
	else
	{
		guid = infokey(pl, "guid");
		if (guid == "")
		{
			dprint("guid not known, using ip instead\n");
			guid = infokey(pl, "ip");
		}
	}
	return guid;
};
static void gmapn_sql_populatematch(float db, float queryidx, float rows, float columns, float eof, float firstrow)
{
	float matchid;
	entity player;
	string guid;
	if (columns < 0 || rows < 0)
	{
		dprint("Database error. Try deleting it to reset it\n");
		return;
	}

	
	if (columns < 1 || rows < 1)
	{
		dprint("Unable to populate match\n");
		return;
	}
	else
		matchid = sqlreadfloat(db, queryidx, 0, 0);

	dprint(sprintf("inserted match %g\n", matchid));

	player = find(world, classname, "player");
	while (player)
	{
		guid = sqlescape(db, playerguid(player));

		//don't care if the unique key constraint fails, it'll be a dupe.
		sqlopenquery(db, sqlerroronerror, 0, sprintf("INSERT OR IGNORE INTO player (guid) VALUES ('%s');", guid));
		//insert the actual matchplayer record (two people with the same ip can result in dupes... not much we can do about that other than encourage players to use fte...)
		sqlopenquery(db, sqlerroronerror, 0, sprintf("INSERT OR IGNORE INTO matchplayer (mid, pid, name, kills, deaths) VALUES ('%g', (SELECT id FROM player WHERE guid='%s'), '%s', %g, %g);", matchid, guid, sqlescape(db, player.netname), player.stats_kills, player.stats_deaths));

		//player column carries the name they most recently played with
		sqlopenquery(db, sqlerroronerror, 0, sprintf("UPDATE player SET name='%s', seen=datetime('now') WHERE guid='%s';", sqlescape(db, player.netname), sqlescape(db, guid)));

		player = find(player, classname, "player");
	}

	sqlopenquery(db, sqlerroronerror, 0, "END TRANSACTION;");
};

void gmapn_sql_logmatch()
{
	if (gmapn_sql_matchlogdb < 0)
	{
		return;
	}

	sqlopenquery(gmapn_sql_matchlogdb, sqlerroronerror, 0, "BEGIN TRANSACTION;");
	sqlopenquery(gmapn_sql_matchlogdb, sqlerroronerror, 0, sprintf("INSERT INTO match (matchtype, map, demname) VALUES (%g, '%s', '%s');", gmapn_gamemode, sqlescape(gmapn_sql_matchlogdb, mapname), sqlescape(gmapn_sql_matchlogdb, gmapn_demoname)));
	sqlopenquery(gmapn_sql_matchlogdb, gmapn_sql_populatematch, 0, "SELECT seq FROM SQLITE_SEQUENCE WHERE name='match';");
};

#define SQL_COLNAME -1
#define SQL_COLCOUNT -2
#define SQL_ROWCOUNT -3
#define SQL_TYPE_SLEEP 2
#define SQL_TYPE_PERSISTANT 1
#define SQL_TYPE_TRANSIENT 0

#define SVC_CSQCMESSAGE 83
#define CSM_MATCHLIST 8
#define CSM_MATCHINFO 9
void Cmd_matchlist_ff(float pid, float first)
{
//FIXME: throttle.
	float q;

	if (gmapn_sql_matchlogdb < 0)
	{
		sprint(self, PRINT_HIGH, "Match Database is not active on this server\n");
		return;
	}

	if (pid)
	{
		q = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_SLEEP, sprintf(
			"SELECT match.id, match.date, match.demname, match.map FROM match"
					" INNER JOIN matchplayer ON match.id == matchplayer.mid"
					" WHERE matchplayer.pid == '%f'"
					" ORDER BY match.date DESC LIMIT 20 OFFSET %f"
					, pid, first
				));
	}
	else
	{
		q = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_SLEEP, sprintf(
			"SELECT match.id, match.date, match.demname, match.map FROM match ORDER BY match.date DESC LIMIT 20 OFFSET %f"
					, first
				));
	}
	float m = sqlreadfloat(gmapn_sql_matchlogdb, q, SQL_ROWCOUNT, SQL_ROWCOUNT);
	float r;

	if (pid)
	{
		//look up the player's most recent name
		float p = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_SLEEP, sprintf(
			"SELECT name FROM player WHERE id == '%f' LIMIT 1"
					, pid
				));
		WriteByte(MSG_MULTICAST, SVC_CSQCMESSAGE);
		WriteByte(MSG_MULTICAST, CSM_MATCHLIST);
		WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, p, 0, 0));	//name
		sqlclosequery(gmapn_sql_matchlogdb, p);
	}
	else
	{
		WriteByte(MSG_MULTICAST, SVC_CSQCMESSAGE);
		WriteByte(MSG_MULTICAST, CSM_MATCHLIST);
		WriteString(MSG_MULTICAST, "");
	}

	if (m > 255)
		m = 255;	//shouldn't happen
	WriteByte(MSG_MULTICAST, m);
	for (r = 0; r < m; r+=1)
	{
		WriteLong(MSG_MULTICAST, sqlreadfloat(gmapn_sql_matchlogdb, q, r, 0));	//id
		WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, q, r, 1));	//date
		WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, q, r, 2));	//demname
		WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, q, r, 3));	//map
	}
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE_R);

	sqlclosequery(gmapn_sql_matchlogdb, q);
};

void Cmd_match_f(float matchid)
{
//FIXME: throttle.
	float mq, pq;
	float p, players;
	
	if (gmapn_sql_matchlogdb < 0)
	{
		sprint(self, PRINT_HIGH, "Match Database is not active on this server\n");
		return;
	}

	mq = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_SLEEP, sprintf(
			"SELECT match.date, match.demname FROM match WHERE match.id == %f", matchid
		));
	pq = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_SLEEP, sprintf(
			"SELECT matchplayer.pid, matchplayer.name, matchplayer.kills, matchplayer.deaths FROM matchplayer WHERE matchplayer.mid == %f", matchid
		));

	players = sqlreadfloat(gmapn_sql_matchlogdb, pq, SQL_ROWCOUNT, SQL_ROWCOUNT);

	if (self)
	{
		WriteByte(MSG_MULTICAST, SVC_CSQCMESSAGE);
		WriteByte(MSG_MULTICAST, CSM_MATCHINFO);

		//write out the match info
		WriteLong(MSG_MULTICAST, matchid);
		WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, mq, 0, 0));
		WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, mq, 0, 1));

		//write out the player info from that match.
		WriteByte(MSG_MULTICAST, players);
		for (p = 0; p < players; p++)
		{
			WriteLong(MSG_MULTICAST, sqlreadfloat(gmapn_sql_matchlogdb, pq, p, 0));		
			WriteString(MSG_MULTICAST, sqlreadfield(gmapn_sql_matchlogdb, pq, p, 1));		
			WriteFloat(MSG_MULTICAST, sqlreadfloat(gmapn_sql_matchlogdb, pq, p, 2));
			WriteFloat(MSG_MULTICAST, sqlreadfloat(gmapn_sql_matchlogdb, pq, p, 3));
		}

		msg_entity = self;
		multicast('0 0 0', MULTICAST_ONE_R);
	}
	
	sqlclosequery(gmapn_sql_matchlogdb, mq);
	sqlclosequery(gmapn_sql_matchlogdb, pq);
};

static void gmapn_sql_welcomeresult(float db, float queryidx, float rows, float columns, float eof, float firstrow)
{
//	float kills;
//	float deaths;
//	float matches;
	if (columns < 0 || rows < 0)
	{
		dprint(sprintf("Database error. Try deleting it to reset it. %s\n", sqlerror(db, queryidx)));
		return;
	}

	if (!sqlreadfloat(db, queryidx, 0, 2))
		sprint(self, PRINT_MEDIUM, sprintf("Hello %s, you look like you're a n00b! Welcome to the server!\n", self.netname));
	else
	{
		self.stats_life_kills = sqlreadfloat(db, queryidx, 0, 0);
		self.stats_life_deaths = sqlreadfloat(db, queryidx, 0, 1);
		sprint(self, PRINT_MEDIUM, sprintf("Hello %s, you have clocked up %g kills, %g deaths, from %g matches on this server\n", self.netname, self.stats_life_kills, self.stats_life_deaths, sqlreadfloat(db, queryidx, 0, 2)));
	}
};
void gmapn_sql_welcome()
{
	if (gmapn_sql_matchlogdb < 0)
	{
		return;
	}
	sqlopenquery(gmapn_sql_matchlogdb, gmapn_sql_welcomeresult, 0, sprintf("SELECT sum(matchplayer.kills), sum(matchplayer.deaths), count(*) FROM matchplayer INNER JOIN player ON matchplayer.pid = player.id WHERE player.guid='%s';", sqlescape(gmapn_sql_matchlogdb, playerguid(self))));
};

void gmapn_menu_populatemaps_sql(float serveridx, float queryidx, float rows, float columns, float eof, float firstrow)
{
	int i, mapidx;

	// write the popular played maps on the server
	for (i = 0; i < MAPLIMIT; i++)
	{
		string sqlmapname;

		if (i >= sqlreadfloat(gmapn_sql_matchlogdb, self.mapquery, SQL_ROWCOUNT, SQL_ROWCOUNT))
		{
			if (i == 0)
				menu_mapvote_randomize();
			break;
		}
		
		sqlmapname = sqlreadfield(gmapn_sql_matchlogdb, self.mapquery, i, 0);

		for (mapidx = 0; infokey(world, strcat("gmapn_map", ftos(mapidx))) != ""; mapidx++)
		{
			if (infokey(world, strcat("gmapn_map", ftos(mapidx))) == sqlmapname)
				break;
		}

		
		self.maps[i] = mapidx;
	}
	
	self.subsel = SUBSEL_MAPS;
}

void gmapn_menu_mapvote_sql()
{
	if (gmapn_sql_matchlogdb < 0)
	{
		menu_mapvote_randomize();
		return;
	}

	if (self.mapquery)
		sqlclosequery(gmapn_sql_matchlogdb, self.mapquery);
	
	self.mapquery = sqlopenquery(gmapn_sql_matchlogdb, gmapn_menu_populatemaps_sql, SQL_TYPE_PERSISTANT, sprintf(
								"SELECT match.map, COUNT(*) FROM match WHERE match.matchtype == %f GROUP BY match.map ORDER BY COUNT(*) DESC", gmapn_gamemode
								));
}

string gmapn_menu_maplist(float keys)
{
	// override back to menu with additional SQL closing
	if (keys & 8)
	{
		sqlclosequery(gmapn_sql_matchlogdb, self.mapquery);
		self.mapquery = 0;
	}

	return gmapn_menu_maps(keys);
}

//centerprint menus
#define MAX_SHOWCOUNT 10
void gmapn_menu_showmatches()
{
	if (gmapn_sql_matchlogdb < 0)
	{
		sprint(self, PRINT_HIGH, "Match Database is not active on this server\n");
		return;
	}
	if (self.matchlistquery)	//erk...
		sqlclosequery(gmapn_sql_matchlogdb, self.matchlistquery);
	self.matchlistquery = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_PERSISTANT, sprintf(
			"SELECT match.id, match.date, match.demname, match.matchtype, match.map FROM match ORDER BY match.date DESC LIMIT %g OFFSET %f", MAX_SHOWCOUNT, self.matchfirst-self.matchfirst%MAX_SHOWCOUNT
		));

	//make sure this isn't still set
	if (self.matchstatsquery)
	{
		sqlclosequery(gmapn_sql_matchlogdb, self.matchstatsquery);
		self.matchstatsquery = 0;
	}
};
string gmapn_menu_matchstats(float keys)
{
	string r;
	float m = self.matchfirst%MAX_SHOWCOUNT;
	if (m >= sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, SQL_ROWCOUNT, SQL_ROWCOUNT))
		return "Invalid Match";
//	float matchid = sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, m, 0);
	string date = sqlreadfield(gmapn_sql_matchlogdb, self.matchlistquery, m, 1);
	string demoname = sqlreadfield(gmapn_sql_matchlogdb, self.matchlistquery, m, 2);
	float matchtype = sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, m, 3);
	string matchmapname = sqlreadfield(gmapn_sql_matchlogdb, self.matchlistquery, m, 4);

	if (demoname)
		r = sprintf("Date: %s\nDemo: %s\nMatch type: %s\nMap %s\n\n", date, demoname, gmapn_gamemodefullname(matchtype), matchmapname);
	else
		r = sprintf("Date: %s\nDemo: <no demo>\nMatch type: %s\nMap %s\n\n", date, gmapn_gamemodefullname(matchtype), matchmapname);

	float players = sqlreadfloat(gmapn_sql_matchlogdb, self.matchstatsquery, SQL_ROWCOUNT, SQL_ROWCOUNT);
	for (float p = 0; p < players; p++)
	{
//		string plid = sqlreadfield(gmapn_sql_matchlogdb, self.matchstatsquery, p, 0);
		string plname = sqlreadfield(gmapn_sql_matchlogdb, self.matchstatsquery, p, 1);
		float plkills = sqlreadfloat(gmapn_sql_matchlogdb, self.matchstatsquery, p, 2);
		float pldeaths = sqlreadfloat(gmapn_sql_matchlogdb, self.matchstatsquery, p, 3);
		r = strcat(r, sprintf("%16s, %3gkls %3gdth\n", plname, plkills, pldeaths));
		//FIXME: if selected, display weapon stats.
		//FIXME: add weapon stats into database...
	}

	if (keys & 4)
	{
		if (demoname != "")
		{
			if (whichpack(demoname, FALSE))
				stuffcmd(self, sprintf("toggleconsole;download \"%s\"\n", demoname));
			else
				stuffcmd(self, sprintf("toggleconsole;echo Demo was deleted\n", demoname));
		}
	}
	if (keys & 8)
	{	//left. kill the menu
		sqlclosequery(gmapn_sql_matchlogdb, self.matchstatsquery);
		self.matchstatsquery = 0;
		return __NULL__;
	}
	return r;
};

//code to handle the match-list menu. no individual players.
string gmapn_menu_matchlist(float keys)
{
	float m;
	if (self.matchstatsquery)
		return gmapn_menu_matchstats(keys);
	
	if (keys & 4)	//right, show full match details
	{
		m = self.matchfirst%MAX_SHOWCOUNT;
		if (m < sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, SQL_ROWCOUNT, SQL_ROWCOUNT))
		{
			float matchid = sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, m, 0);
			self.matchstatsquery = sqlopenquery(gmapn_sql_matchlogdb, __NULL__, SQL_TYPE_PERSISTANT, sprintf(
					"SELECT matchplayer.pid, matchplayer.name, matchplayer.kills, matchplayer.deaths FROM matchplayer WHERE matchplayer.mid == %f", matchid
				));
			return gmapn_menu_matchstats(0);
		}
	}
	if (keys & 3)
	{
		m = floor(self.matchfirst/MAX_SHOWCOUNT);
		if (keys & 1)
			self.matchfirst = max(0, self.matchfirst-1);
		else
			self.matchfirst += 1;
		if (m != floor(self.matchfirst/MAX_SHOWCOUNT))
			gmapn_menu_showmatches();
	}
	float base = self.matchfirst - self.matchfirst%MAX_SHOWCOUNT;
	string r = sprintf("Past Matches %g - %g\n", base, base+MAX_SHOWCOUNT-1);
	float matches = sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, SQL_ROWCOUNT, SQL_ROWCOUNT);
	for (m = 0; m < matches; m++)
	{
//		float matchid = sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, m, 0);
		string date = sqlreadfield(gmapn_sql_matchlogdb, self.matchlistquery, m, 1);
//		string demoname = sqlreadfield(gmapn_sql_matchlogdb, self.matchlistquery, m, 2);
		float matchtype = sqlreadfloat(gmapn_sql_matchlogdb, self.matchlistquery, m, 3);
		string matchmapname = sqlreadfield(gmapn_sql_matchlogdb, self.matchlistquery, m, 4);

		string l = sprintf("%s %s on %s\n", date, gmapn_gamemodefullname(matchtype), matchmapname);
		if (base+m == self.matchfirst)
			l = redify(l);
		r = strcat(r, l);
	}
	
	if (keys & 8)	//left, back to main menu
	{
		sqlclosequery(gmapn_sql_matchlogdb, self.matchlistquery);
		self.matchlistquery = 0;
	}
	return r;
};


//for debugging. For handling the server's console commands.
float ConsoleCmd(string line)
{
	tokenize(line);
	string cmd = argv(0);
	if (cmd == "sql")
	{
		sqlopenquery(gmapn_sql_matchlogdb, sqlprintout, 0, substring(line, argv_end_index(0), -1));
		return 1;
	}
	else
		return 0;
};
