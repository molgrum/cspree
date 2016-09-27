/*
    gmapn_mapvote.qc

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

#define firstvote goalentity
#define mapnodep movetarget
#define prev oldenemy
#define next enemy

void gmapn_mapvote_countvotes()
{
	entity player;
	entity mapnode;
	entity votenode;
	float i;
	float numplayers;

	numplayers = 0;
	player = find(world, classname, "player");
	while(player)
	{
		numplayers = numplayers + 1;
		player = find(player, classname, "player");
	}

	mapnode = find(world, classname, "gmapn_mapvote_map");
	while(mapnode)
	{
		i = 0;
		votenode = mapnode.firstvote;
		while(votenode)
		{
			i++;
			votenode = votenode.next;
		}

		if (i/numplayers > 0.5)
		{
			changelevel(mapnode.netname);
			break;
		}

		mapnode = find(mapnode, classname, "gmapn_mapvote_map");
	}
};

void gmapn_mapvote_removevote()
{
	entity votenode;

	votenode = find(world, classname, "gmapn_mapvote_vote");
	while(votenode)
	{
		if (votenode.owner == self)
		{
			if (!votenode.prev && !votenode.next)
			{
				/* Last vote for a particular map, remove it completely */
				strunzone(votenode.mapnodep.netname);
				remove(votenode.mapnodep);
			}
			else
			{
				if (votenode.prev)
					votenode.prev.next = votenode.next;
				else
					votenode.mapnodep.firstvote = votenode.next;
				if (votenode.next)
					votenode.next.prev = votenode.prev;
			}

			strunzone(votenode.netname);
			remove(votenode);
			break;
		}

		votenode = find(votenode, classname, "gmapn_mapvote_vote");
	}
};

string gmapn_mapvote_getvote()
{
	entity votenode;
	for (votenode = 0; (votenode = find(votenode, classname, "gmapn_mapvote_vote")); )
	{
		if (votenode.owner == self)
			return votenode.mapnodep.netname;
	}
	return 0;
};

void gmapn_mapvote_addvote(string mapstr)
{
	entity mapnode;
	entity votenode;
	
	if (mapstr == "" || !strncasecmp(mapstr, "b_", 2))
	{
		sprint(self, PRINT_HIGH, _("That (probably) isn't a map\n"));
		return;
	}
	if not(whichpack(strcat("maps/", mapstr, ".bsp"), FALSE))
	{
		sprint(self, PRINT_HIGH, _("The server does not have that map\n"));
		print(sprintf("Hey, Server Admin, %s wants to play on map %s, please install it!\n", self.netname, mapstr));
		return;
	}

	bprintln(PRINT_HIGH, sprintf(_("%s votes for map %s."), self.netname, mapstr));

	gmapn_mapvote_removevote();

	mapnode = find(world, classname, "gmapn_mapvote_map");
	while(mapnode)
	{
		if (mapnode.netname == mapstr)
			break;

		mapnode = find(mapnode, classname, "gmapn_mapvote_map");
	}

	if (!mapnode)
	{
		mapnode = spawn();
		mapnode.netname = strzone(mapstr);
		mapnode.classname = "gmapn_mapvote_map";
	}

	votenode = spawn();
	votenode.classname = "gmapn_mapvote_vote";
	votenode.owner = self;
	votenode.mapnodep = mapnode;
	votenode.prev = world;
	votenode.next = mapnode.firstvote;
	mapnode.firstvote = votenode;

	if (votenode.next)
	{
		votenode.next.prev = votenode;
	}

	gmapn_mapvote_countvotes();
};

#undef firstvote
#undef mapnodep
#undef prev
#undef next
