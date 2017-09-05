/*
	gmapn_aliasstuffer.qc

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

string stufflist[] =
{
	"alias toggleready cmd toggleready\n",
	"alias ready cmd ready\n",
	"alias break cmd break\n",
	"alias notready cmd notready\n",
	"alias forcestart cmd forcestart\n",
	"alias dmm1 cmd dmm 1\n",
	"alias dmm2 cmd dmm 2\n",
	"alias dmm3 cmd dmm 3\n",
	"alias dmm4 cmd dmm 4\n",
	"alias powerups cmd powerups\n",
	"alias 1on1 cmd 1on1\n",
	"alias 2on2 cmd 2on2\n",
	"alias 3on3 cmd 3on3\n",
	"alias 4on4 cmd 4on4\n",
	"alias time3 cmd time 3\n",
	"alias time5 cmd time 5\n",
	"alias time10 cmd time 10\n",
	"alias rpickup cmd rpickup\n",
	"alias yes cmd yes\n",
	"alias agree cmd agree\n",
	"alias no cmd no\n",
	"alias disagree cmd disagree\n",
	"alias abstain cmd abstain\n",
	"alias dontcare cmd dontcare\n",
	"alias rulemaker cmd rulemaker\n",
	"alias rndmap cmd rndmap\n",
	"alias shownick cmd shownick\n"
};

void() gmapn_aliasstuffer_think;

void gmapn_aliasstuffer_start(entity player)
{
	entity e;

	e = spawn();
	e.netname = player.netname;
	e.classname = "gmapn_aliasstuffer";
	e.solid = SOLID_NOT;
	e.nextthink = time + 0.2; /* Give a little room for the client to really connect, avoids weird delays when connecting. */
	e.think = gmapn_aliasstuffer_think;
	e.owner = player;
	e.cnt = 0;
};

void gmapn_aliasstuffer_think()
{
	float ok_to_stuff;
	entity player;

	/* A safety check to make sure the client didn't disappear */
	player = find(world, classname, "player");
	while(player && player.netname != self.netname && self.owner != player)
	{
		player = find(player, classname, "player");
	}

	if (!player)
	{
		/* OK, client disappeared, so we do too */
		remove(self);
		return;
	}

	if (gmapn_qsg_has_fte_isbackbuffered)
		ok_to_stuff = !isbackbuffered(self.owner);
	else
		ok_to_stuff = 1;

	while(ok_to_stuff)
	{
		if (self.cnt < stufflist.length)
			stuffcmd(self.owner, stufflist[self.cnt]);
		else
		{
			string name;
			string aliascmd;

			name = gmapn_map_pool_readidx(self.cnt - stufflist.length);
			if (name != "")
			{
				aliascmd = strcat("alias ", name);
				aliascmd = strcat(aliascmd, " cmd votemap ");
				aliascmd = strcat(aliascmd, name);
				aliascmd = strcat(aliascmd, "\n");
				stuffcmd(self.owner, aliascmd);
			}
			else
			{
				sprint(self.owner, PRINT_MEDIUM, "Aliases uploaded.\n");
				remove(self);
				return;
			}
		}

		self.cnt+= 1;

		if (gmapn_qsg_has_fte_isbackbuffered)
		{
			ok_to_stuff = !isbackbuffered(self.owner);
		}
		else
		{
			ok_to_stuff = 0;
		}
	}

	if (gmapn_qsg_has_fte_isbackbuffered)
	{
		self.nextthink = time + 0.01;
	}
	else
	{
		self.nextthink = time + 1;
	}
};
