float quota(float score, float total)
{
	if (score > 0 && total > 0)
		return 100 * (score / total);
	else
		return 0;
}

void gmapn_game_stats_printbar(float length)
{
	length -= 2;
	bprint(PRINT_HIGH, chr2str(0x9d));
	for (int i = 0; i < length; i++)
	{
		bprint(PRINT_HIGH, chr2str(0x9e));
	}
	bprintln(PRINT_HIGH, chr2str(0x9f));
}

void gmapn_game_stats_printteam(string team)
{
	entity p;
	string lg, rl; // weapon stats
	string ga, ya, ra, mh; // armor&megah stats
	string quad, pent, ring; // powerups stats

	if (teamplay)
	{
		bprintln(PRINT_HIGH, sprintf(_("team %s:"), brackets(team)));
		gmapn_game_stats_printbar(37);
	}
	p = find(world, classname, "player");
	while (p)
	{
		if (teamplay && p.teamname != team)
		{
			p = find(p, classname, "player");
			continue; // not on the specified team
		}

		bprintln(PRINT_HIGH, disconnected(p.netname));
		
		bprintln(PRINT_HIGH, sprintf("  %g (%g) %g %g",
									 p.stats_kills,
									 p.stats_kills-p.stats_deaths,
									 0,
									 quota(p.stats_kills, p.stats_kills+p.stats_deaths)));
		
		lg = sprintf("%s%0.1f%%", redify("lg"), quota(p.stats_hit[W_LG], p.stats_total[W_LG]));
		rl = sprintf("%s%0.1f%%", redify("rl"), quota(p.stats_hit[W_RL], p.stats_total[W_RL]));
		bprintln(PRINT_HIGH, sprintf("%s: %s %s",
									 redify("wp"),
									 lg,
									 rl));
		bprintln(PRINT_HIGH, sprintf("%s:",
									 redify("rl skill"))); // FIXME: add rl damage and direct hits
		
		ga = sprintf("%s:%g", redify("ga"), p.stats_took[TK_GA]);
		ya = sprintf("%s:%g", redify("ya"), p.stats_took[TK_YA]);
		ra = sprintf("%s:%g", redify("ra"), p.stats_took[TK_RA]);
		mh = sprintf("%s:%g", redify("mh"), p.stats_took[TK_MH]);				
		bprintln(PRINT_HIGH, sprintf("%s: %s %s %s %s",
									 redify("armr&mhs"),
									 ga,
									 ya,
									 ra,
									 mh));
		
		quad = sprintf("%s:%g", redify("q"), p.stats_took[TK_QUAD]);
		pent = sprintf("%s:%g", redify("p"), p.stats_took[TK_PENT]);
		ring = sprintf("%s:%g", redify("r"), p.stats_took[TK_RING]);
		bprintln(PRINT_HIGH, sprintf("%s: %s %s %s",
									 redify("powerups"),
									 quad,
									 pent,
									 ring));
		
		bprintln(PRINT_HIGH, sprintf("%s:",
									 redify("      rl"))); // FIXME: add took killed dropped
		bprintln(PRINT_HIGH, sprintf("%s:",
									 redify("  damage"))); // FIXME: taken given team
		bprintln(PRINT_HIGH, sprintf("%s:",
									 redify(" streaks"))); // FIXME: frags quadrun (in one lifetime)
		bprintln(PRINT_HIGH, sprintf("%s:",
									 redify(" spawnfrags"))); // FIXME: spawnfrags in total
		bprintln(PRINT_HIGH, "");

		p = find(p, classname, "player");
	}
}

void gmapn_game_stats_printtop()
{
	entity topfrags, topdeaths, toptkills, topeffi, topstreak, topquadrun;
	entity p;
	string frags, deaths, effi;

	topfrags = topdeaths = toptkills = topeffi = topstreak = topquadrun = world;
	p = find(world, classname, "player");
	while (p)
	{
		float f;
		f = quota(p.stats_kills, p.stats_kills + p.stats_deaths);
		// FIXME: implement teamkills, streak and quadrun
		if (!topfrags || topfrags.stats_kills < p.stats_kills)
			topfrags = p;
		if (!topdeaths || topdeaths.stats_deaths < p.stats_deaths)
			topdeaths = p;
		if (!topeffi || quota(topeffi.stats_kills, topeffi.stats_kills + topeffi.stats_deaths) < f)
			topeffi = p;
		p = find(p, classname, "player");
	}

	frags = ftos(topfrags.stats_kills);
	frags = brackets(frags);
	deaths = ftos(topdeaths.stats_deaths);
	deaths = brackets(deaths);
	effi = sprintf("%0.1f%%", quota(topeffi.stats_kills, topeffi.stats_deaths + topeffi.stats_kills));
	effi = brackets(effi);
	
	gmapn_game_stats_printbar(37);
	bprintln(PRINT_HIGH, sprintf(_("%s top scorers:"), brackets(mapname)));
	gmapn_game_stats_printbar(37);
	bprintln(PRINT_HIGH, sprintf(_("      frags: %s %s"),
								 topfrags.netname,
								 frags));
	bprintln(PRINT_HIGH, sprintf(_("     deaths: %s %s"),
								 topdeaths.netname,
								 deaths));
	bprintln(PRINT_HIGH, sprintf(_(" efficiency: %s %s"),
								 topeffi.netname,
								 effi));
								   
}

float gmapn_game_stats_printline(float hit, float total, string prefix)
{
	float percentage, pint, pdec;

	if (hit > 0 && total > 0)
	{
		percentage = 100 * (hit / total);
		pint = floor(percentage);
		pdec = rint(10 * (percentage - pint));

		bprint(PRINT_HIGH, sprintf("%s%5.1f%% %i dmg\n", prefix, percentage, (int)hit));
		return TRUE;
	}
	return FALSE;
};

void gmapn_game_stats()
{
	//entity player;
	//float allhit, alltotal;
	//float lines;

	bprintln(PRINT_HIGH, "");
	bprintln(PRINT_HIGH, _("Player statistics"));
	gmapn_game_stats_printbar(37);
	bprintln(PRINT_HIGH, "frags (rank) friendkills efficiency");
	if (teamplay)
	{
		gmapn_game_stats_printteam(gmapn_team_red);
		gmapn_game_stats_printteam(gmapn_team_blue);
	}
	else
		gmapn_game_stats_printteam(0);
	gmapn_game_stats_printtop();
	bprintln(PRINT_HIGH, "");
	//gmapn_game_stats_printbar(12);
	//bprintln(PRINT_HIGH, sprintf(_("%s vs %s", brackets(gmapn_team_red), brackets(gmapn_team_blue))));
	//gmapn_game_stats_printbar(12);
	//bprintln(PRINT_HIGH, "");
/*	
	player = find(world, classname, "player");

	while (player)
	{
		allhit = 0;
		alltotal = 0;
		for (float i = 0; i < stats_hit.length; i++)
		{
			allhit += player.stats_hit[i];
			alltotal += player.stats_total[i];
		}

		bprint(PRINT_HIGH, player.netname);
		bprintln(PRINT_HIGH, ":");

		lines = 0;
		for (float i = 0; i < stats_hit.length; i++)
			lines += gmapn_game_stats_printline(player.stats_hit[i], player.stats_total[i], strpad(5, strcat(wnames[i], ":")));
		if (!lines)
			bprintln(PRINT_HIGH, "No info");
		bprintln(PRINT_HIGH, "");

		if (gmapn_game_stats_printline(allhit, alltotal,  "Total: "))
			bprintln(PRINT_HIGH, "");

		// FIXME: Seperate midair stats maybe?
		if (deathmatch == DMM_MIDAIR)
		{
			float midairs = player.stats_midair[M_MIDAIR] +
				  		  player.stats_midair[M_SILVER] +
						  player.stats_midair[M_GOLD] +
						  player.stats_midair[M_DIAMOND];
			bprint(PRINT_HIGH, "Midairs: ");
			bprintln(PRINT_HIGH, ftos(midairs));
			bprintln(PRINT_HIGH, "");
		}

		if (gmapn_game_stats_printline(player.stats_kills, (player.stats_kills + player.stats_deaths), "Efficiency: "))
			bprintln(PRINT_HIGH, "");
		if (gmapn_game_stats_printline(player.stats_life_kills, (player.stats_life_kills + player.stats_life_deaths), "Lifetime Efficiency: "))
			bprintln(PRINT_HIGH, "");

		player = find(player, classname, "player");
	}
*/
};
