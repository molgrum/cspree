/*
    gmapn_countdown.qc

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

void gmapn_countdown_start(float length, void() triggerfunc, float countdownstyle)
{
	entity e;

	e = spawn();
	e.classname = "gmapn_countdown";
	e.solid = SOLID_NOT;
	if (!time)
		e.nextthink = e.frags = 0.001;
	else
		e.nextthink = e.frags = time;
	e.think = gmapn_countdown_think;
	e.think1 = triggerfunc;
	e.cnt = length + 1;
	e.health = countdownstyle;

	if (countdownstyle == gmapn_countdown_style_prewar)
	{
		gmapn_lightstyle_fade_start(0.3, 1);
		gmapn_matchstarttimems = 1000*(time + length);
	}
//	else if (countdownstyle == gmapn_countdown_style_round)
//		gmapn_roundendtime = time + length;
};

void gmapn_countdown_stop()
{
	entity e;

	e = find(world, classname, "gmapn_countdown");
	if (e)
	{
		if (e.health == gmapn_countdown_style_prewar)
		{
			gmapn_lightstyle_fade_stop();
			gmapn_lightstyle_reset();
			
			//if a countdown is abandoned, release any unready players back to their preferred teams
			entity p = find(world, classname, "player");
			while (p)
			{
				if (!p.ready)
				{
					p.teamname = p.userteam;
					forceinfokey(p, "team", p.teamname);
				}
				p = find(p, classname, "player");
			}
		}

		remove(e);
	}
};

void gmapn_countdown_think()
{
	entity p;
	string plural;

	self.cnt-= 1;
	self.frags+= 1;
	self.nextthink = self.frags;

	if (self.cnt)
	{
		if (gmapn_serverstate == gmapn_serverstate_countdown)
		{
			if (self.cnt <= 5)
			{
				sound(self, CHAN_VOICE, "buttons/switch02.wav", 1, ATTN_NONE, 100, SOUNDFLAG_RELIABLE|8, 0);
				// Play countdown sound for each player
				p = find(world, classname, "player");
				while (p)
				{
					p = find(p, classname, "player");
				}
			}
			
			if (self.cnt == 10)
			{
				sound(self, CHAN_VOICE, "items/protect2.wav", 1, ATTN_NONE, 100, SOUNDFLAG_RELIABLE|8, 0); // everyone hears the start of countdown
				p = find(world, classname, "player");
				while (p)
				{
					p = find(p, classname, "player");
				}
			}
		}
		else if (self.cnt >= 60)
		{
			if (floor(self.cnt/60)*60 == self.cnt)
			{
				if (self.cnt > 61)
					plural = "s";
				else
					plural = "";

				bprint(PRINT_MEDIUM, chr2str(0x90), goldnmbr(ftos(self.cnt/60)), chr2str(0x91), " minute", plural, " remaining\n");
			}
		}
		else if (self.cnt <= 5 || self.cnt == 30 || self.cnt == 15 || self.cnt == 10)
		{
			if (self.cnt > 1)
				plural = "s";
			else
				plural = "";
			
			bprint(PRINT_MEDIUM, chr2str(0x90), goldnmbr(ftos(self.cnt)), chr2str(0x91), " second", plural, "\n");
		}
	}
	else
	{
		if (self.health == gmapn_countdown_style_prewar)
		{
			gmapn_lightstyle_reset();
			gmapn_matchstarttimems = 1000*time;	//make sure its correct
		}

		void() fnc = self.think1;
		if (self.health == gmapn_countdown_style_prewar || game_is_tied() == FALSE)
			remove(self);
		fnc();
	}
};
