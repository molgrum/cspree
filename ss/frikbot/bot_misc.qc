/***********************************************
*                                              *
*              FrikBot Misc Code               *
*   "Because you can't name it anything else"  *
*                                              *
***********************************************/

/*
This program is in the Public Domain. My crack legal
team would like to add:

RYAN "FRIKAC" SMITH IS PROVIDING THIS SOFTWARE "AS IS"
AND MAKES NO WARRANTY, EXPRESS OR IMPLIED, AS TO THE
ACCURACY, CAPABILITY, EFFICIENCY, MERCHANTABILITY, OR
FUNCTIONING OF THIS SOFTWARE AND/OR DOCUMENTATION. IN
NO EVENT WILL RYAN "FRIKAC" SMITH BE LIABLE FOR ANY
GENERAL, CONSEQUENTIAL, INDIRECT, INCIDENTAL,
EXEMPLARY, OR SPECIAL DAMAGES, EVEN IF RYAN "FRIKAC"
SMITH HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES, IRRESPECTIVE OF THE CAUSE OF SUCH DAMAGES. 

You accept this software on the condition that you
indemnify and hold harmless Ryan "FrikaC" Smith from
any and all liability or damages to third parties,
including attorney fees, court costs, and other
related costs and expenses, arising out of your use
of this software irrespective of the cause of said
liability. 

The export from the United States or the subsequent
reexport of this software is subject to compliance
with United States export control and munitions
control restrictions. You agree that in the event you
seek to export this software, you assume full
responsibility for obtaining all necessary export
licenses and approvals and for assuring compliance
with applicable reexport restrictions. 

Any reproduction of this software must contain
this notice in its entirety. 

*/
#define POSSIBLEBOTNAMES 32
string possiblebotnames [POSSIBLEBOTNAMES] = {
	"Bot: Vincent",	//0
	"Bot: Bishop",	//1
	"Bot: Nomad",	//2
	"Bot: Hudson",	//3
	"Bot: Lore",	//4
	"Bot: Servo",	//5
	"Bot: Gort",	//6
	"Bot: Kryten",	//7
	"Bot: Elden",	//8
	"Bot: Max",	//9
	"Bot: Marvin",	//10
	"Bot: Erwin",	//11
	"Bot: Betty",	//12
	"Bot: Krosis",	//13
	"Bot: Gypsy",	//14
	"Bot: Hal",	//15
	"Bot: Buck",	//16
	"Bot: Zackary",	//17
	"Bot: Alonso",	//18
	"Bot: Hank",	//19
	"Bot: Alfonzo",	//20
	"Bot: Boris",	//21
	"Bot: Lucian",	//22
	"Bot: Seymour",	//23
	"Bot: Dirk",	//24
	"Bot: Irwin",	//25
	"Bot: Gavin",	//26
	"Bot: Barry",	//27
	"Bot: Harry",	//28
	"Bot: Garry",	//29
	"Bot: Mary",	//30
	"Bot: Hairy"	//31
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotName

Sets bot's name and colors

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
string  PickARandomName()
{
	self.b_pants = floor(random()*14);
	self.b_shirt = floor(random()*14);

	float y, test;
	string h = 0;
	entity t;
	y = 64;
	while(y)
	{
		y--;
		test = floor(random() * POSSIBLEBOTNAMES);
		h = possiblebotnames[test];
		t = find(world, netname, h);
		if (t == world)
			y = FALSE;
	}
	return h;
};



// I didn't like the old code so this is very stripped down

entity b_originator;
float b_topic;
/* FBX Topics

b_originator == self
 1 - sign on
 2 - killed targ
 3 - team message "friendly eyes"
 4 - team message "on your back"
 5 - team message "need back up"
 6 - excuses
 ----
 7 - gameover
 ----
 8 - welcoming someone onto server
 9 - ridicule lost frag (killed self?)
 10 - ridicule lost frag (lava)
 11 - lag
b_originator == targ

 
*/
void bot_start_topic(float tpic)
{
	if (random() < 0.2)
	{
		b_topic = tpic;
		b_originator = self;
	}
	else
		b_topic = 0;
};

void bot_chat()
{
	float r;
	if (b_options & OPT_NOCHAT)
		return;
	r = ceil (random() * 6);
	
	if (self.b_chattime > time)
	{
		if (self.b_skill < 2)
			self.keys = self.button0 = self.button2 = 0;
		return;
	}
	else if (self.b_chattime)
	{
		if (b_topic == 1)
		{
			if (b_originator == self)
			{
				if (r == 1)
				{
					BotSay(": lo all\n");
					bot_start_topic(8);
				}
				else if (r == 2)
				{
					BotSay(": hey everyone\n");
					bot_start_topic(8);
				}
				else if (r == 3)
				{
					BotSay(": prepare to be fragged!\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(": boy this is laggy\n");
					bot_start_topic(11);
				}
				else if (r == 5)
				{
					BotSay(": #mm getting some lag here\n");
					bot_start_topic(11);
				}
				else
				{
					BotSay(": hi everyone\n");
					bot_start_topic(8);
				}
			}
		}
		else if (b_topic == 2)
		{
			if (b_originator == self)
			{
				if (r == 1)
					BotSay(": take that\n");
				else if (r == 2)
					BotSay(": yehaww!\n");
				else if (r == 3)
					BotSay(": wh00p\n");
				else if (r == 4)
					BotSay(": j00_sawk();\n");
				else if (r == 5)
					BotSay(": i rule\n");
				else
					BotSay(": eat that\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 3)
		{
			if (b_originator == self)
			{
				if (r < 3)
					BotSayTeam(": friendly eyes\n");
				else
					BotSayTeam(": team eyes\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 4)
		{
			if (b_originator == self)
			{
				if (r < 3)
					BotSayTeam(": on your back\n");
				else
					BotSayTeam(": I'm with you\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 5)
		{
			if (b_originator == self)
			{
				if (r < 3)
					BotSayTeam(": I need help\n");
				else
					BotSayTeam(": need backup\n");
				bot_start_topic(0);
			}
		}
		else if (b_topic == 6)
		{
			if (b_originator == self)
			{
				if (r == 1)
				{
					BotSay(": sun got in my eyes\n");
					bot_start_topic(0);
				}
				else if (r == 2)
				{
					BotSay(": mouse needs cleaning\n");
					bot_start_topic(0);
				}
				else if (r == 3)
				{
					BotSay(": i meant to do that\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(": lag\n");
					bot_start_topic(11);
				}
				else if (r == 5)
				{
					BotSay(": killer lag\n");
					bot_start_topic(11);
				}
				else
				{
					BotSay(": 100% lag\n");
					bot_start_topic(11);
				}
			}
		}
		else if (b_topic == 7)
		{
			if (r == 1)
				BotSay(": gg\n");
			else if (r == 2)
				BotSay(": gg all\n");
			else if (r == 3)
				BotSay(": that was fun\n");
			else if (r == 4)
				BotSay(": good game\n");
			else if (r == 5)
				BotSay(": pah\n");
			else
				BotSay(": hrm\n");
			bot_start_topic(0);
		}
		else if (b_topic == 8)
		{
			if (b_originator != self)
			{
				if (r == 1)
				{
					BotSay(": heya\n");
					bot_start_topic(0);
				}
				else if (r == 2)
				{
					BotSay(": welcome\n");
					bot_start_topic(0);
				}
				else if (r == 3)
				{
					BotSay(strcat(": hi ", b_originator.netname, "\n"));
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(strcat(": hey ", b_originator.netname, "\n"));
					bot_start_topic(0);
				}
				else if (r == 5)
				{
					BotSay(": howdy\n");
					bot_start_topic(0);
				}
				else
				{
					BotSay(": lo\n");
					bot_start_topic(0);	
				}
			}
		}

		else if (b_topic == 9)
		{
			if (b_originator != self)
			{
				if (r == 1)
					BotSay(": hah\n");
				else if (r == 2)
					BotSay(": heheh\n");
				else if (r == 3)
					BotSay(strcat(": good work ", b_originator.netname, "\n"));
				else if (r == 4)
					BotSay(strcat(": nice1 ", b_originator.netname, "\n"));
				else if (r == 5)
					BotSay(": lol\n");
				else
					BotSay(": :)\n");
				b_topic = 6;
			}
		}
		else if (b_topic == 10)
		{
			if (b_originator != self)
			{
				if (r == 1)
					BotSay(": have a nice dip?\n");
				else if (r == 2)
					BotSay(": bah I hate levels with lava\n");
				else if (r == 3)
					BotSay(strcat(": good job ", b_originator.netname, "\n"));
				else if (r == 4)
					BotSay(strcat(": nice backflip ", b_originator.netname, "\n"));
				else if (r == 5)
					BotSay(": watch your step\n");
				else
					BotSay(": hehe\n");
				b_topic = 6;
			}
		}

		else if (b_topic == 11)
		{
			if (b_originator != self)
			{
				if (r == 1)
				{
					BotSay(strcat(": yeah right ", b_originator.netname, "\n"));
					bot_start_topic(0);
				}
				else if (r == 2)
				{
					BotSay(": ping\n");
					bot_start_topic(0);
				}
				else if (r == 3)
				{
					BotSay(": shuddup, you're an lpb\n");
					bot_start_topic(0);
				}
				else if (r == 4)
				{
					BotSay(": lag my eye\n");
					bot_start_topic(0);
				}
				else if (r == 5)
				{
					BotSay(": yeah\n");
					bot_start_topic(11);
				}
				else
				{
					BotSay(": totally\n");
					bot_start_topic(11);
				}
			}
		}
		self.b_chattime = 0;
	}
	else if (b_topic)
	{
		if (random() < 0.5)
		{
			if (self == b_originator)
			{
				if (b_topic <= 7)
					self.b_chattime = time + 2;
			}
			else
			{
				if (b_topic >= 7)
					self.b_chattime = time + 2;
			}
		}
	}
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Kick A Bot. 

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void KickABot()
{
	entity ty;
	ty = find(world, classname, "player");
	while (ty != world)
	{
		if (!(ty.ishuman))
		{
			
			BotDisconnect(ty);
			ty.ishuman = TRUE;
			ty = world;
		}
		else
			ty = find(ty, classname, "player");
	}

};


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Simplified origin checking. 

God, I wish I had inline

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

vector realorigin(entity ent)
{
// even more simplified...
	return (ent.absmin + ent.absmax) * 0.5;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fisible

a version of visible that checks for corners
of the bounding boxes

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float  fisible(entity targ)
{
	vector	spot1, org;
	float thruwater, pc1, pc2;
	
	org = realorigin(targ);
	spot1 = self.origin + self.view_ofs;
	
	if (targ.solid == SOLID_BSP)
	{
		traceline (spot1, org, TRUE, self);
		if (trace_ent == targ)
			return TRUE;
		else if (trace_fraction == 1)
			return TRUE;
		return FALSE;
	}
	else
	{
		pc1 = pointcontents(org);
		pc2 = pointcontents(spot1);
		if (targ.classname == "player")
			thruwater = FALSE;
		else if (pc1 == CONTENT_LAVA)
			return FALSE;
		else	
			thruwater = TRUE;
	}
	
	if (pc1 < -1) // targ's origin is in water or other liquid
	{
		if (pc2 != pc1)
		{
			// look for their head
			traceline (spot1, org + targ.mins, TRUE, self);
			// cross the water check
			if (trace_inopen)
				if (trace_inwater)
					if (!thruwater)
						return FALSE;
			if (trace_ent == targ)
				return TRUE;
			else if (trace_fraction == 1)
				return TRUE;
			return FALSE;
		}
	}
	else
	{
		if (pc2 != pc1)
		{
			traceline (spot1, org + targ.maxs, TRUE, self);
			if (trace_inopen)
				if (trace_inwater)
					if (!thruwater)
						return FALSE;
			if (trace_ent == targ)
				return TRUE;
			else if (trace_fraction == 1)
				return TRUE;
			return FALSE;
		}
	}
	traceline (spot1, org, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	traceline (spot1, org + targ.maxs, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	traceline (spot1, org + targ.mins, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Wisible 

goes through movable brushes/entities, used
for waypoints

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

// this is used for waypoint stuff....
float  wisible(entity targ1, entity targ2)
{
	vector	spot1, spot2;
	entity ignore;

	spot1 = targ1.origin;
	spot2 = realorigin(targ2);
	
	ignore = self;
	do
	{
		traceline (spot1, spot2, TRUE, ignore);
		spot1 = realorigin(trace_ent);
                ignore = trace_ent;
	} while ((trace_ent != world) && (trace_fraction != 1));
	if (trace_endpos == spot2)
		return TRUE;
	else 
		return FALSE;
};


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

sisible

Now this is getting ridiculous. Simple visible,
used when we need just a simple traceline nothing else

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float  sisible(entity targ)
{
	traceline (self.origin, targ.origin, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

angcomp

subtracts one angle from another

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float (float y1, float y2) angcomp = 
{
	y1 = frik_anglemod(y1);
	y2 = frik_anglemod(y2);

	float answer;
	answer = y1 - y2;
	if (answer > 180)
		answer = answer - 360;
	else if (answer < -180)
		answer = answer + 360;
	return answer;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fov

is the entity in the bot's field of view

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float  fov(entity targ)
{
	vector yawn;
	float g;
	yawn = realorigin(targ);
	yawn = (yawn + targ.view_ofs) - (self.origin + self.view_ofs);
	yawn = normalize(yawn);
	yawn = vectoangles(yawn);
	g = angcomp(self.v_angle_x, yawn_x);
	if (fabs(g) > 45)
		return FALSE;
	g = angcomp(self.v_angle_y, yawn_y);
	if (fabs(g) > 60)
		return FALSE;
 
	return TRUE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

frik_anglemod

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float frik_anglemod(float v)
{
	return v - floor(v/360) * 360;
};
