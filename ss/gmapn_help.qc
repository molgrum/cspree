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

static string helperprints[] =
{
	"Welcome peasant.",
	"more text"
};

static float index;

void gmapn_help_think()
{
	sprint(self.owner, PRINT_HIGH, redify("console: "));
	sprintln(self.owner, PRINT_HIGH, redify(helperprints[index]));
	self.nextthink = time + 5.0;
	index++;

	if (index >= helperprints.length || !self.owner)
		remove(self);
};

void gmapn_help_init()
{
	index = 0;
	self.nextthink = time + 1.0;
	self.think = gmapn_help_think;
};
