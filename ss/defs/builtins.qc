/*
    builtins.qc

    Copyright (C) 2009 Andreas Nilsson

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

#pragma target FTE

///////////////////////////////////////////////////////////////////////////////
//                        G M A P N   B U I L T I N S                        //
///////////////////////////////////////////////////////////////////////////////

void    bprintln(float level, string s)
{
	bprint(level, s, "\n");
};

void    sprintln(entity client, float level, string s)
{
	sprint(client, level, s, "\n");
};

void    dprintln(string s)
{
	dprint(s, "\n");
};

void	 dbgprint(string s)
{
	if (cvar("developer"))
		dprint("DEBUG: ", s);
};

void	 dbgprintln(string s)
{
	dbgprint(strcat(s, "\n"));
};
