/*
    gmapn_misc.qc

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

void gmapn_telefrag_check(entity source, vector destination)
{
	entity oldself; /* Yikes, Id Software suck */
	entity p;
	entity p2;
	
	entity teledeath;

	vector tmin;
	vector pmin;

	tmin = destination + source.mins;

	oldself = self;

	p = find(world, classname, "player");
	while(p)
	{
		if (p.netname != "" && p != source && p.health > 0 && p.solid != SOLID_NOT)
		{
			pmin = p.origin + p.mins;

			if (pmin_x + p.size_x > tmin_x && pmin_x < tmin_x + source.size_x
			 && pmin_y + p.size_y > tmin_y && pmin_y < tmin_y + source.size_y
			 && pmin_z + p.size_z > tmin_z && pmin_z < tmin_z + source.size_z)
			{
				teledeath = spawn();
				teledeath.movetype = MOVETYPE_NONE;
				teledeath.solid = SOLID_NOT;
				//teledeath.nextthink = time + 0.01;
				//teledeath.think = func_null;

				self = teledeath;

				p2 = source;
				if (deathmatch != 4 && p.pent_finished > time && p2.pent_finished > time)
				{
					//teledeath.deathtype = DT_TELEFRAG_PENT_BOTH;

					p.pent_finished = 0;
					p2.pent_finished = 0;

					p.deathtype = DT_TELEFRAG_PENT_BOTH;
					p2.deathtype = DT_TELEFRAG_PENT_BOTH;

					teledeath.owner = p2;
					gmapn_kill(p, teledeath.owner);
					teledeath.owner = p;
					gmapn_kill(p2, teledeath.owner);
				}
				else if (deathmatch != 4 && p.pent_finished > time)
				{
					//teledeath.deathtype = DT_TELEFRAG_PENT;
					teledeath.owner = p;
					p2.deathtype = DT_TELEFRAG_PENT;
					gmapn_kill(p2, teledeath.owner);
				}
				else
				{
					//teledeath.deathtype = DT_TELEFRAG;
					teledeath.owner = p2;
					p.deathtype = DT_TELEFRAG;
					gmapn_kill(p, teledeath.owner);
				}
			}
		}

		p = find(p, classname, "player");
	}

	self = oldself;
};

void gmapn_reset_entities(string classnamestr)
{
	entity oself = self;
	entity e;

	e = find(world, classname, classnamestr);

	while (e)
	{
		if (classnamestr == "func_button")
		{
			self = e;
			button_reset();
			self = oself;
		}
		else if (classnamestr == "func_door")
		{
			self = e;
			door_reset();
			self = oself;
		}
		else if (classnamestr == "func_door_secret")
		{
			self = e;
			door_secret_reset();
			self = oself;
		}
		else if (classnamestr == "func_plat")
		{
			self = e;
			plat_reset();
			self = oself;
		}
		else if (classnamestr == "func_train")
		{
			self = e;
			train_reset();
			self = oself;
		}
		else if (classnamestr == "trigger_counter"
			  || classnamestr == "trigger_once"
			  || classnamestr == "trigger_onlyregistered")
		{
			self = e;
			trigger_reset();
			self = oself;
		}
		else if (classnamestr == "info_controlpoint")
		{
			self = e;
			controlpoint_reset();
			self = oself;
		}
		else // items
		{
			e.model = e.mdl;
			e.nextthink = 0;
			e.solid = SOLID_TRIGGER;
		}

		e = find(e, classname, classnamestr);
	}
};
