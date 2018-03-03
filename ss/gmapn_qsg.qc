/*
	gmapn_qsg.qc

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

void SV_ParseClientCommand(string str)
{
	float numargs;

	numargs = tokenize(str);
	if (numargs < 1)
		return;

	// When spectating you need to use say_game to talk to everyone during a game
	if (gmapn_serverstate == gmapn_serverstate_playing && self.classname != "player" && argv(0) == "say")
	{
		if (substring(argv(1), 0, 8) != "say_game")
		{
			str = substring(str, 3, strlen(str));
			str = strcat("say_team", str);
		}
		else if (substring(argv(1), 0, 8) == "say_game")
		{
			if (substring(str, 4, 1) == "\"")
			{
				// ezquake
				str = substring(str, 14, strlen(str) - 15);
			}
			else
			{
				// fodquake
				str = substring(str, 13, strlen(str));
			}

			str = strcat("say ", str);
		}
	}

	if (gmapn_serverstate == gmapn_serverstate_prewar && self.classname == "player")
	{
		if (argv(0) == "say")
		{
			string s1, s2;

			if (numargs < 3)
			{
				numargs = tokenize(argv(1));
				s1 = argv(0);
				s2 = argv(1);
			}
			else
			{
				s1 = argv(1);
				s2 = argv(2);
			}
			dprint(s1, " ", s2, "\n");
			if (s1 == ".menu" && s2 == "bind")
			{
				stuffcmd(self, "bind enter cmd menu show\n");
				return;
			}
		}
	}

	// FIXME: uncomment when LASTMANSTANDING spectating is working

	/* if (argv(0) == "ptrack" && infokey(self, INFOKEY_P_SPECTATOR) == "2") */
	/* { */
	/*	entity tracking = world, newtarget; */

	/*	while ((tracking = find(tracking, classname, "player"))) */
	/*	{ */
	/*		if (infokey(tracking, INFOKEY_P_USERID) == argv(1) || tracking == world) */
	/*			break; */
	/*	} */

	/*	newtarget = tracking; */
	/*	while (self.teamname != newtarget.teamname || stof(infokey(newtarget, INFOKEY_P_SPECTATOR))) */
	/*	{ */
	/*		newtarget = find(newtarget, classname, "player"); */
	/*		if (newtarget == tracking) */
	/*			break; */
	/*	} */

	/*	str = argv(0); */
	/*	str = strcat(str, " "); */
	/*	str = strcat(str, infokey(newtarget, INFOKEY_P_USERID)); */
	/* } */

	if (gmapn_handle_usercmd(numargs) == 0)
		clientcommand(self, str);
};

void gmapn_setteamandcolour(entity player, string teamstr, float topcolour, float bottomcolour)
{
#if 1
	player.teamname = teamstr;
	forceinfokey(player, "team", teamstr);
	forceinfokey(player, "topcolor", ftos(topcolour));
	forceinfokey(player, "bottomcolor", ftos(bottomcolour));
#else
	string t;

	t = strcat("team ", teamstr);
	t = strcat(t, "\n");
	clientcommand(player, t);
	stuffcmd(player, t);

	t = ftos(colour);
	t = strcat("color ", t);
	t = strcat(t, "\n");
	clientcommand(player, t);
	stuffcmd(player, t);
#endif
};
