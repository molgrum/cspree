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
        Boston, MA  02111-1307, USA

*/

static string tips[] =
{
	"Vote a map by its name, example: /dm4",
	"To get a game going with too few players try enabling bots",
	"You can shoot and trigger everything in a map, it will reset on game start",
	"Try to vote a random map with /rndmap",
	"The rulemaker decides the game options and can allow anyone to set them. Try to become one with /rulemaker",
	"If some settings are modified from the server standard it will show them on countdown",
	"You can kick, ban and mute other players with /cmd kick ban mute",
	"Matchless game modes will continue playing after intermission"
};

void gmapn_print_tipoftheday()
{
	float rnd = floor(random() * tips.length);

	sprint(self, PRINT_HIGH, "\n", redify(_("Tip of the day:\n")), tips[rnd], "\n\n");
}
