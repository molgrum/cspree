/*
    gmapn_lightstyle.qc

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

string lightstyles[] =
{
	"m",
	"mmnmmommommnonmmonqnmmo",
	"abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba",
	"mmmmmaaaaammmmmaaaaaabcdefgabcdefg",
	"mamamamamama",
	"jklmnopqrstuvwxyzyxwvutsrqponmlkj",
	"nmonqnmomnmomomno",
	"mmmaaaabcdefgmmmmaaaammmaamm",
	"mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa",
	"aaaaaaaazzzzzzzz",
	"mmamammmmammamamaaamammma",
	"abcdefghijklmnopqrrqponmlkjihgfedcba"
};
string lightstyles63 = "a";

void() gmapn_lightstyle_reset
{
	lightstyle(0, lightstyles[0]);
	lightstyle(1, lightstyles[1]);
	lightstyle(2, lightstyles[2]);
	lightstyle(3, lightstyles[3]);
	lightstyle(4, lightstyles[4]);
	lightstyle(5, lightstyles[5]);
	lightstyle(6, lightstyles[6]);
	lightstyle(7, lightstyles[7]);
	lightstyle(8, lightstyles[8]);
	lightstyle(9, lightstyles[9]);
	lightstyle(10, lightstyles[10]);
	lightstyle(11, lightstyles[11]);
	lightstyle(63, lightstyles63);
};

float(string str) gmapn_lightstyle_ctof
{
	float ret;

	if (str == "a")
		ret = 0;
	else if (str == "b")
		ret = 1;
	else if (str == "c")
		ret = 2;
	else if (str == "d")
		ret = 3;
	else if (str == "e")
		ret = 4;
	else if (str == "f")
		ret = 5;
	else if (str == "g")
		ret = 6;
	else if (str == "h")
		ret = 7;
	else if (str == "i")
		ret = 8;
	else if (str == "j")
		ret = 9;
	else if (str == "k")
		ret = 10;
	else if (str == "l")
		ret = 11;
	else if (str == "m")
		ret = 12;
	else if (str == "n")
		ret = 13;
	else if (str == "o")
		ret = 14;
	else if (str == "p")
		ret = 15;
	else if (str == "q")
		ret = 16;
	else if (str == "r")
		ret = 17;
	else if (str == "s")
		ret = 18;
	else if (str == "t")
		ret = 19;
	else if (str == "u")
		ret = 20;
	else if (str == "v")
		ret = 21;
	else if (str == "w")
		ret = 22;
	else if (str == "x")
		ret = 23;
	else if (str == "y")
		ret = 24;
	else
		ret = 25;
	
	return ret;
};

string gmapn_lightstyle_ftoc(float f)
{
	string ret;

	f = rint(f);

	if (f == 0)
		ret = "a";
	else if (f == 1)
		ret = "b";
	else if (f == 2)
		ret = "c";
	else if (f == 3)
		ret = "d";
	else if (f == 4)
		ret = "e";
	else if (f == 5)
		ret = "f";
	else if (f == 6)
		ret = "g";
	else if (f == 7)
		ret = "h";
	else if (f == 8)
		ret = "i";
	else if (f == 9)
		ret = "j";
	else if (f == 10)
		ret = "k";
	else if (f == 11)
		ret = "l";
	else if (f == 12)
		ret = "m";
	else if (f == 13)
		ret = "n";
	else if (f == 14)
		ret = "o";
	else if (f == 15)
		ret = "p";
	else if (f == 16)
		ret = "q";
	else if (f == 17)
		ret = "r";
	else if (f == 18)
		ret = "s";
	else if (f == 19)
		ret = "t";
	else if (f == 20)
		ret = "u";
	else if (f == 21)
		ret = "v";
	else if (f == 22)
		ret = "w";
	else if (f == 23)
		ret = "x";
	else if (f == 24)
		ret = "y";
	else if (f == 25)
		ret = "z";
	else
		ret = "";

	return ret;
};

void gmapn_lightstyle_setstyle(string stylestr, float num, float intensity)
{
	string newstr;
	float i;
	float len;
	float f;

	newstr = "";
	i = 0;
	len = strlen(stylestr);
	while(i < len)
	{
		f = gmapn_lightstyle_ctof(substring(stylestr, i, 1));
		newstr = strcat(newstr, gmapn_lightstyle_ftoc(f*intensity));

		i++;
	}

	if (newstr)
	{
		lightstyle(num, newstr);
	}
};

void gmapn_lightstyle_setbrightness(float intensity)
{
	gmapn_lightstyle_setstyle(lightstyles[0], 0, intensity);
	gmapn_lightstyle_setstyle(lightstyles[1], 1, intensity);
	gmapn_lightstyle_setstyle(lightstyles[2], 2, intensity);
	gmapn_lightstyle_setstyle(lightstyles[3], 3, intensity);
	gmapn_lightstyle_setstyle(lightstyles[4], 4, intensity);
	gmapn_lightstyle_setstyle(lightstyles[5], 5, intensity);
	gmapn_lightstyle_setstyle(lightstyles[6], 6, intensity);
	gmapn_lightstyle_setstyle(lightstyles[7], 7, intensity);
	gmapn_lightstyle_setstyle(lightstyles[8], 8, intensity);
	gmapn_lightstyle_setstyle(lightstyles[9], 9, intensity);
	gmapn_lightstyle_setstyle(lightstyles[10], 10, intensity);
	gmapn_lightstyle_setstyle(lightstyles[11], 11, intensity);
};

void gmapn_lightstyle_fade_think()
{
	self.nextthink = time + 0.1;
	float intensity;

	if (time >= self.frags+self.cnt)
	{
		remove(self);
		return;
	}

	intensity = 1*(1-((time-self.frags)/self.cnt))+self.health*((time-self.frags)/self.cnt);

	gmapn_lightstyle_setbrightness(intensity);
};

void gmapn_lightstyle_fade_start(float intensity, float duration)
{
	entity e;

	e = spawn();
	e.classname = "gmapn_lightstyle_fade";
	e.solid = SOLID_NOT;
	e.nextthink = time + 0.001;
	e.health = intensity;
	e.frags = time;
	e.think = gmapn_lightstyle_fade_think;
	e.cnt = duration;
};

void gmapn_lightstyle_fade_stop()
{
	entity e;

	e = find(world, classname, "gmapn_lightstyle_fade");
	if (e)
		remove(e);
};

