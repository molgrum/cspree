/*
	gmapn_reset.qc

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

void gmapn_reset_think()
{
	self.nextthink = time + 0.1;
	self.think = gmapn_reset_stoptimer;

	// do not reset when rules are locked since there is nothing to reset
	if (getkey(game_lockrules) > 0)
		return;

	serverflags = 0;
	localcmd("exec cfgs/reset.conf\n");
};

void gmapn_reset_starttimer()
{
	entity e;

	e = spawn();
	e.classname = "gmapn_reset";
	e.solid = SOLID_NOT;
	e.nextthink = time + 5;
	e.think = gmapn_reset_think;
};

void gmapn_reset_stoptimer()
{
	entity e;

	e = find(world, classname, "gmapn_reset");

	remove(e);
};
