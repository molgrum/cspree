/*
	gmapn_help.qc

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
		Boston, MA	02111-1307, USA

*/

static string tips[] =
{
	_("Vote a map by its name FOR NOW, example:\n/dm4\nMap list is not available yet, menu map\nlist is unfinished so don't use it.\n"),
	_("To get a game going with too few players\ntry opening console and type: .qw get in\nhere NOW and play with ME!\n"),
	_("You can shoot, trigger, open and press.\nAny action you can think of to move\nthrough the map in prewar and exploring\nit. Everything in a map, will reset on\ngame start\n"),
	_("Since there is no maplist for ALL maps,\ntry to vote a random map with /rndmap\nfor now\n"),
	_("The rulemaker is simply the currently\nallowed tinkerer that picks the game\noptionsand can although allow ANYONE\nto set them. If you feel envyous, try to\nbecome one with /rulemaker\n"),
	_("If some settings are modified BY YOU\nfrom other than the server standard it\nwill show a blinking warning on\ncountdown where yellow leds indicate.\n"),
	_("You can kick, ban and mute other players\nthat you find annoying with /cmd\ncommands: kick, ban or mute\n"),
	_("Matchless game modes will continue\nplaying after intermission. Such as Duel Arena, Kill the King.\n"),
	_("Check your sorry ass stats by selecting\nPast Matches, you can even download demos\nhere\n"),
	_("Cooperative gamemode places you in\nsingle player missions with other\nplayers able to join in and help you\nkill monsters and find secrets.\n"),
	_("Domination. Right now the capture points\nare usually at RL, LG or even GL. Lack\nof information that is planned to be\nadded makes this mode not have its full\npotential.\n"),
	_("For newcomers, Duel Arena is a fun and\nrelaxed mode that only requires two\nplayers. Which makes it abit easier to\nmake the game start.\n"),
	_("Freezetag. Team based where your team\ntries to freeze all of the opponents.\nYou win the round when all opponents are\nfrozen!\n"),
	_("Headhunters. Free for All, gib the\nothers, collect heads from their dead\nbodies, bring the heads to the map altar\n(there is only one).\n"),
	_("Kill the King. Everyone starts as plebs,\nplebs can kill but not gain frags.\nWhoever gets first blood becomes king,\nand start accumuling frags. Try to\nsnatch the crown and win the amount of\nfrags!\n"),
	_("Did you like clan arena? Definitively\ntry out Last Man Standing then!\n"),
	_("Rover. The weirdest mode yet. You start\noff on rounds, two teams facing each\nother. When you kill an opponent, he\nsuddenly swaps team into your, meaning\nyou converted him. Keep doing this magic\nwith the whole opposing team until\neveryone is in your team. Score!\n")
};

void gmapn_print_tipoftheday()
{
	float rnd = floor(random() * tips.length);

	sprint(self, PRINT_HIGH, "\n", redify(_("Tip of the day:\n")), tips[rnd], "\n");
}

void gmapn_print_welcome()
{
	string m = "";

	m = strcat(m, sprintf("\n%s %s\n", NAME, redify(VERSION)));
	m = strcat(m, sprintf("(%s)\n", redify(DATE)));

	sprint(self, PRINT_HIGH, m);
}
