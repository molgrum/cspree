/*
    gmapn_disconnected.qc

    Copyright (C) 2016 Andreas Nilsson

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

void gmapn_disconnected_player(entity disconnected_player)
{
	entity e, oldest, newstatpreserver;
	float numstatpreservers;

	numstatpreservers = 0;
	oldest = world;
	e = find(world, classname, "gmapn_disconnected_player");
	oldest = e;
	while (e)
	{
		if (e.latency <= oldest.latency)
			oldest = e;

		numstatpreservers++;
		e = find(e, classname, "gmapn_disconnected_player");
	}

	// For gods sake don't remove(world)
	if (oldest != world && numstatpreservers > cvar("maxclients"))
	{
		dprintln("Avoiding entity bombing: Too many disconnected players so removing the oldest entry.");
		remove(oldest);
	}

	newstatpreserver = spawn();
	newstatpreserver.classname = "gmapn_disconnected_player";
	newstatpreserver.frags = disconnected_player.frags;
	newstatpreserver.latency = disconnected_player.latency;
	newstatpreserver.netname = disconnected_player.netname;
	newstatpreserver.teamname = disconnected_player.teamname;
	newstatpreserver.topcolor = stof(infokey(disconnected_player, INFOKEY_P_TOPCOLOR));
	newstatpreserver.bottomcolor = stof(infokey(disconnected_player, INFOKEY_P_BOTTOMCOLOR));

	newstatpreserver.targetname = infokey(disconnected_player, INFOKEY_P_REALIP);

	newstatpreserver.stats_kills = disconnected_player.stats_kills;
	newstatpreserver.stats_deaths = disconnected_player.stats_deaths;
	newstatpreserver.stats_life_kills = disconnected_player.stats_life_kills;
	newstatpreserver.stats_life_deaths = disconnected_player.stats_life_deaths;

	for (float i = 0; i < tknames.length; i++)
	{
		newstatpreserver.stats_took[i] = disconnected_player.stats_took[i];
	}

	for (float i = 0; i < wnames.length; i++)
	{
		newstatpreserver.stats_hit[i] = disconnected_player.stats_hit[i];
		newstatpreserver.stats_total[i] = disconnected_player.stats_total[i];
		newstatpreserver.stats_sent[i] = disconnected_player.stats_sent[i];
	}
}

float gmapn_reconnected_player(entity reconnected_player)
{
	entity statpreserver, matchedplayer, matchedip;

	matchedplayer = world;
	matchedip = world;
	statpreserver = find(world, classname, "gmapn_disconnected_player");
	while (statpreserver)
	{
		if (statpreserver.targetname == infokey(reconnected_player, INFOKEY_P_REALIP))
		{
			matchedip = statpreserver;
		}
		if (statpreserver.netname == reconnected_player.netname)
		{
			matchedplayer = statpreserver;
			break;
		}
		statpreserver = find(statpreserver, classname, "gmapn_disconnected_player");
	}

	if (matchedplayer == world)
	{
		// No netname match, check IP match instead (to allow nickname change)
		if (matchedip != world)
		{
			matchedplayer = matchedip; // OK found an entry
		}
		else
		{
			dprintln("Didn't find a match for disconnected player");
			return FALSE; // No netname or IP matched
		}
	}

	reconnected_player.frags = matchedplayer.frags;
	//reconnected_player.teamname = matchedplayer.teamname;
	//gmapn_setteamandcolour(reconnected_player, matchedplayer.teamname, matchedplayer.topcolor, matchedplayer.bottomcolor);

	reconnected_player.stats_kills = matchedplayer.stats_kills;
	reconnected_player.stats_deaths = matchedplayer.stats_deaths;
	reconnected_player.stats_life_kills = matchedplayer.stats_life_kills;
	reconnected_player.stats_life_deaths = matchedplayer.stats_life_deaths;

	for (float i = 0; i < tknames.length; i++)
	{
		reconnected_player.stats_took[i] = matchedplayer.stats_took[i];
	}

	for (float i = 0; i < wnames.length; i++)
	{
		reconnected_player.stats_hit[i] = matchedplayer.stats_hit[i];
		reconnected_player.stats_total[i] = matchedplayer.stats_total[i];
		reconnected_player.stats_sent[i] = matchedplayer.stats_sent[i];
	}

	 // Just remove the disconnection node match, the actual player is not removed
	remove(matchedplayer);

	return TRUE; // we found a node and destroyed it, all is well
};
