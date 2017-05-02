/*
    gmapn_powerups.qc

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

void gmapn_powerups_enable_item(string itemclassname)
{
	entity e;

	e = find(world, classname, itemclassname);
	while(e)
	{
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER;
		setorigin(e, e.origin);

		e = find(e, classname, itemclassname);
	}
};

void gmapn_powerups_disable_item(string itemclassname)
{
	entity e;
	
	e = find(world, classname, itemclassname);
	while(e)
	{
		e.solid = SOLID_NOT;
		e.model = string_null;
		e.nextthink = 0;

		e = find(e, classname, itemclassname);
	}
};

void gmapn_powerups_enable()
{
	setkey("powerups_enabled", "1");

	if (self.classname == "player")
	{
		bprint(PRINT_HIGH, self.netname, " enabled powerups.\n");
	}

	gmapn_powerups_enable_item("item_artifact_invulnerability");
	gmapn_powerups_enable_item("item_artifact_invisibility");
	gmapn_powerups_enable_item("item_artifact_super_damage");
};

void gmapn_powerups_disable()
{
	setkey("powerups_enabled", "0");

	if (self.classname == "player")
	{
		bprint(PRINT_HIGH, self.netname, " disabled powerups.\n");
	}

	gmapn_powerups_disable_item("item_artifact_invulnerability");
	gmapn_powerups_disable_item("item_artifact_invisibility");
		gmapn_powerups_disable_item("item_artifact_super_damage");
};

void gmapn_powerups_toggle()
{
	if (getkey(powerups_enabled) == 0)
		gmapn_powerups_enable();
	else
		gmapn_powerups_disable();
};

void gmapn_powerups_setitems()
{
	int i;
	float newstate = 1; // show all items laying on the map per default

	switch (cvar("deathmatch"))
	{
	case 4:
	case DMM_MIDAIR:
	case DMM_INSTAGIB:
		newstate = 0;
		break;
	default:
		newstate = !getkey(noitems);
		break;
	}

	for (i = 0; i < itemnames.length; i++)
	{
		string n = itemnames[i];

		if (getkey(powerups_enabled) == 0 && i >= (itemnames.length - 7))
			newstate = 0;

		if (cvar("deathmatch") <= DMM_LIMITED && i >= (itemnames.length - 4))
			newstate = 1; // potentially hid armor & health, toggle on again

		entity e = find(world, classname, n);
		while(e)
		{
			//leave items that have targets.
			//there's a number of maps that trigger stuff from item pickups. these are rare in deathmatch maps of course, but single player maps can be weird.
			if (!e.target)
			{
				if (newstate)
				{
					e.model = e.mdl;
					e.solid = SOLID_TRIGGER;
					setorigin(e, e.origin);
				}
				else
				{
					e.solid = SOLID_NOT;
					e.model = string_null;
					e.nextthink = 0;
				}
			}

			e = find(e, classname, n);
		}
	}
};
