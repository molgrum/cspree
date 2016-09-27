/*
    gmapn_latency.qc

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

void gmapn_latency_check_init()
{
	entity latencycheck;

	latencycheck = spawn();
	latencycheck.nextthink = time + 1;
	latencycheck.think = gmapn_latency_check_loop;
};

void gmapn_latency_check_loop()
{
	entity player;
	float delta;

	self.nextthink = time + 1;

	player = find(world, classname, "player");
	while (player)
	{
		delta = time - player.latency;

		if (delta > 12)
			dropclient(player);

		if (delta >= 4 && delta % 4 == 0)
		{
			bprint(PRINT_HIGH, player.netname);
			bprintln(PRINT_HIGH, " is timing!");
		}

		player = find(player, classname, "player");
	}
};

