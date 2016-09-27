/*
    gmapn_config.qc

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

/* Ugly, ugly, ugly */
float gmapn_config_version;

void gmapn_config_update()
{
	if (stof(infokey(world, "gmapn_config_version")) == gmapn_config_version)
	{
		gmapn_init_entities();
		remove(self);
		return;
	}

	self.nextthink = time + 0.001;
};

void gmapn_config_load()
{
	string gametype;
	string str;
	entity e;

	dbgprintln("=== gmapn_config_load() ===");
/*
	if (stof(infokey(world, "gmapn_gametype")) == gmapn_gametype_ffa)
		gametype = "ffa";
	else if (stof(infokey(world, "gmapn_gametype")) == gmapn_gametype_1on1)
		gametype = "1on1";
	else if (stof(infokey(world, "gmapn_gametype")) == gmapn_gametype_2on2)
		gametype = "2on2";
	else
		gametype = "4on4";
*/
	gametype = getkey(game_mode);

	localcmd("exec configs/default.cfg\n");

	str = strcat("exec configs/rules/", gametype);
	str = strcat(str, ".cfg\n");
	localcmd(str);

	str = strcat("exec configs/maps/", mapname);
	str = strcat(str, "/default.cfg\n");
	localcmd(str);

	str = strcat("exec configs/maps/", mapname);
	str = strcat(str, "/");
	str = strcat(str, gametype);
	str = strcat(str, ".cfg\n");
	localcmd(str);

	gmapn_config_version+= 1;
	if (gmapn_config_version == 65536)
		gmapn_config_version = 0;

	str = strcat("localinfo gmapn_config_version ", ftos(gmapn_config_version));
	str = strcat(str, "\n");
	localcmd(str);

	localcmd(strcat("serverinfo config ", gametype, "\n"));

	/* We need to wait for the server to actually load the config... */
	e = spawn();
	e.nextthink = time + 0.001;
	e.think = gmapn_config_update;
	e.health = gmapn_config_version;
};

