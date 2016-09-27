/*
    gmapn_rpickup.qc

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
        Boston, MA  02111-1307, USA

*/

float gmapn_rpickup_getpredefinedteamcolour(float teamnum)
{
	if (teamnum == 0)
		return 4;
	else if (teamnum == 1)
		return 6;
	else if (teamnum == 2)
		return 12;
	else
		return 13;
};

string gmapn_rpickup_getpredefinedteamname(float teamnum)
{
	if (teamnum == 0)
		return "red";
	else if (teamnum == 1)
		return "pink";
	else if (teamnum == 2)
		return "yell";
	else
		return "blue";
};

void gmapn_rpickup_assignplayerstoteam(string teamname, float teamcolour, float numplayers, float numplayerstoassign)
{
	entity player;
	float playernum;

	while(numplayerstoassign > 0)
	{
		playernum = rint(random() * (numplayers - 1));

		player = find(world, classname, "player");
		while(player)
		{
			if (player.vote_rpickup)
			{
				if (playernum == 0)
				{
					gmapn_setteamandcolour(player, teamname, teamcolour, teamcolour);
					player.vote_rpickup = 0;
					break;
				}

				playernum--;
			}

			player = find(player, classname, "player");
		}

		numplayers--;
		numplayerstoassign--;
	}
};

void gmapn_rpickup_countvotes()
{
	entity player;
	float numplayers;
	float numplayersvoted;
	float team1;
	float team2;
	float team1count;
	float team2count;
	float team1colour;
	float team2colour;
	string team1name;
	string team2name;

	numplayers = 0;
	numplayersvoted = 0;

	player = find(world, classname, "player");
	while(player)
	{
		numplayers++;

		if (player.vote_rpickup)
			numplayersvoted++;

		player = find(player, classname, "player");
	}

	if (numplayersvoted/numplayers > 0.5 && numplayers > 2)
	{
		bprint(PRINT_HIGH, "Doing random pickup.\n");

		team1 = rint(random() * (gmapn_rpickup_maxpredefinedteams - 1));
		team2 = rint(random() * (gmapn_rpickup_maxpredefinedteams - 2));
		if (team2 == team1)
			team2++;

		team1colour = gmapn_rpickup_getpredefinedteamcolour(team1);
		team2colour = gmapn_rpickup_getpredefinedteamcolour(team2);
		team1name = gmapn_rpickup_getpredefinedteamname(team1);
		team2name = gmapn_rpickup_getpredefinedteamname(team2);

		team1count = rint(numplayers/2);
		team2count = numplayers - team1count;

		/* We're gonna use vote_rpickup as a flag to see if the client has already been assigned to a team */
		player = find(world, classname, "player");
		while(player)
		{
			player.vote_rpickup = 1;

			player = find(player, classname, "player");
		}


		gmapn_rpickup_assignplayerstoteam(team1name, team1colour, numplayers, team1count);
		gmapn_rpickup_assignplayerstoteam(team2name, team2colour, numplayers - team1count, team2count);
	}
};

