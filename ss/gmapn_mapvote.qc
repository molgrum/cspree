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

strbuf gmapn_maplist;

//returns -1 on failure, 0+ for the index it was found at
float gmapn_map_pool_findidx(string map)
{
	float i = buf_getsize(gmapn_maplist);
	while (i > 0)
	{
		i--;
		if (bufstr_get(gmapn_maplist, i) == map)
			return i;
	}
	return -1;
};
//obtains a single map's name
string gmapn_map_pool_readidx(float idx)
{
	return bufstr_get(gmapn_maplist, idx);
};
float gmapn_map_pool_count(void)
{
	return buf_getsize(gmapn_maplist);
}
void gmapn_map_pool_parse(string fname)
{
	filestream f = fopen(fname, FILE_READ);
	if (f < 0)
		return;
	for(;;)
	{
		string l = fgets(f);
		if not (l)
			break;
		//just read each map name
		//we use strict tokenizing here, which allows for comments and multiple maps on a line, etc.
		//which can give nicer files than one-per-line like buf_loadfile would require. all maps of an episode on a single line, etc.
		float argc = tokenize_console(l);
		for (float a = 0; a < argc; a++)
			bufstr_add(gmapn_maplist, argv(a), TRUE);
	}
	fclose(f);
};
//reloads the map pool settings.
//FIXME: respond to player counts.
void gmapn_map_pool_init()
{
	string name;
	if (gmapn_maplist)
		buf_del(gmapn_maplist);

	gmapn_maplist = buf_create();

	//each game mode may have its own private map pool
	gmapn_map_pool_parse(sprintf("cfgs/maps/%s.pool", gmapn_gamemodetostring(gmapn_gamemode)));

	//fixme: various modes should be grouped for their own pools.
	if (!buf_getsize(gmapn_maplist))
		gmapn_map_pool_parse("cfgs/maps/default.pool");

	//read legacy infokeys into the pool, if they exist.
	for (int mapidx = 0; ; mapidx++)
	{
		name = infokey(world, sprintf("gmapn_map%i", mapidx));
		if (!name)
			break;
		bufstr_add(gmapn_maplist, name, TRUE);
	}

	//all else failed, scan for maps.
	if (!buf_getsize(gmapn_maplist))
	{
		searchhandle search_handle;
		float i, map_count;
		float offset;
		float namelength;

		search_handle = search_begin("maps/*.bsp", 0, 0);

		offset = 0;

		map_count = search_getsize(search_handle);
		for(i=0;i<map_count;i++)
		{
			/* Blacklist the b_ files :/ */
			name = search_getfilename(search_handle, i);
			if (substring(name, 0, 7) == "maps/b_")
			{
				offset++;
				continue;
			}

			name = search_getfilename(search_handle, i);
			namelength = strlen(name);
			name = substring(name, 5, namelength-5-4);

			bufstr_add(gmapn_maplist, name, TRUE);
		}

		search_end(search_handle);
	}
};

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
		if (player.ishuman == TRUE)
		{
			numplayers = numplayers + 1;
		}
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
