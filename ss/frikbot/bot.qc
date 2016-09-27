
/*
======================================
FrikBot X (Version 0.10.2)
======================================

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

======================================
These installation instructions only apply to Normal Quake (as does this
entire file). For QuakeWorld, please refer to bot_qw.qc

--------------------------------------
To install on a new mod, do all this:
--------------------------------------
Place all included bot*.qc files in the subdirectory "frikbot"
in your source folder, then...

* Add the following lines to progs.src right after the defs.qc line
frikbot/bot.qc
frikbot/bot_way.qc
frikbot/bot_fight.qc 
frikbot/bot_ai.qc
frikbot/bot_misc.qc
frikbot/bot_phys.qc
frikbot/bot_move.qc
frikbot/bot_ed.qc

--------------------------------------
* Add this to worldspawn() in world.qc, right at the very top, before InitBodyQue();
BotInit();  // FrikBot
--------------------------------------
* add this line to StartFrame() in world.qc, at the very top
BotFrame(); // FrikBot
--------------------------------------
* Add these two lines to PlayerPreThink in client.qc at the very top
if (BotPreFrame()) // FrikBot
	return;
--------------------------------------
* Add this line to PlayerPostThink in client.qc at the very top
if (BotPostFrame()) // FrikBot
	return;
--------------------------------------
* Add the following line to the very top of Client Connect in client.qc
ClientInRankings(); // FrikBot
--------------------------------------
* Add these lines to the very top of ClientDisconnect in client.qc
ClientDisconnected(); // FrikBot
--------------------------------------

To install the waypoints:

add

waypoints/map_dm1.qc
waypoints/map_dm2.qc
waypoints/map_dm3.qc
waypoints/map_dm4.qc
waypoints/map_dm5.qc
waypoints/map_dm6.qc

To progs.src, immediately after defs.qc

To remove these waypoints:

Delete the code in bot_map_load, located below.
*/

void bot_map_load()
{
	// place your qc loaded waypoints here

	if (mapname == "dm1")
		map_dm1();
	else if (mapname == "dm2")
		map_dm2();
	else if (mapname == "dm3")
		map_dm3();
	else if (mapname == "dm4")
		map_dm4();
	else if (mapname == "dm5")
		map_dm5();
	else if (mapname == "dm6")
		map_dm6();
};

void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7)
frik_big_centerprint = #73;

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Variables and shtuff

bot.qc has become pretty much a header file
for all variable in the bot...

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float coop;
.vector punchangle;

// ----- entity fields ---
.float	wallhug, keys, oldkeys, ishuman;
.float	b_frags, b_shirt, b_pants; 
.float	priority, ai_time, missile_speed;
.int b_sound;
.float	portal_time, b_skill, switch_wallhug;
.float	b_aiflags, b_chattime;
.float	b_menu, b_menu_time, b_menu_value;
.float route_failed, dyn_flags, dyn_time;
.float dyn_plat;
.entity	temp_way, last_way, phys_obj;
.entity	target1, target2, target3, target4;
.entity	b_next, b_last;
.entity	current_way;
.vector	b_angle, b_dest, mouse_emu, obs_dir;
.vector	movevect, b_dir;
.vector dyn_dest;
.float search_time;
.float air_finished;
.vector dest1, dest2;

// used for the physics & movement AI
float KEY_MOVEUP 		= 1;
float KEY_MOVEDOWN 	= 2;
float KEY_MOVELEFT 	= 4;
float KEY_MOVERIGHT 	= 8;
float KEY_MOVEFORWARD	= 16;
float KEY_MOVEBACK	= 32;
float KEY_LOOKUP		= 64;
float KEY_LOOKDOWN	= 128;
float KEY_LOOKLEFT	= 256;
float KEY_LOOKRIGHT	= 512;

// these are aiflags for waypoints
// some overlap to the bot
float AI_TELELINK_1	= 1; // link type
float AI_TELELINK_2	= 2; // link type
float AI_TELELINK_3	= 4; // link type
float AI_TELELINK_4	= 8; // link type
float AI_DOORFLAG		= 16; // read ahead
float AI_PRECISION	= 32; // read ahead + point
float AI_SURFACE		= 64; // point 
float AI_BLIND		= 128; // read ahead + point
float AI_JUMP		= 256; // point + ignore
float AI_DIRECTIONAL	= 512; // read ahead + ignore
float AI_PLAT_BOTTOM	= 1024; // read ahead 
float AI_RIDE_TRAIN	= 2048; // read ahead 
float AI_SUPER_JUMP	= 4096; // point + ignore + route test
float AI_SNIPER		= 8192; // point type 
float AI_AMBUSH		= 16384; // point type
float AI_DOOR_NO_OPEN	= 32768; // read ahead
float AI_DIFFICULT	= 65536; // route test
float AI_TRACE_TEST	= 131072; // route test

// these are flags for bots/players (dynamic/editor flags)
float AI_OBSTRUCTED	= 1;
float AI_HOLD_SELECT	= 2;
float AI_ROUTE_FAILED	= 2;
float AI_WAIT		= 4;
float AI_DANGER		= 8;


// addition masks
float AI_POINT_TYPES 	= 29152;
float AI_READAHEAD_TYPES	= 36528;
float AI_IGNORE_TYPES	= 4864;

float WM_UNINIT		= 0;
float WM_DYNAMIC		= 1;
float WM_LOADING		= 2;
float WM_LOADED		= 3;
float WM_EDITOR		= 4;
float WM_EDITOR_DYNAMIC	= 5;
float WM_EDITOR_DYNLINK	= 6;


float OPT_SAVEBOTS	= 1;
float OPT_NOCHAT	= 2;

// -------globals-----
float		max_clients, real_frametime;
float		bot_count, b_options;
float		waypoint_mode, dump_mode; 
float		waypoints, direct_route;
float		sv_friction, sv_gravity;
float		sv_accelerate, sv_maxspeed, sv_stopspeed;
entity	fixer;
entity	route_table;
entity	b_temp1, b_temp3;
entity 	player_head, way_head;
float		busy_waypoints;

.int	b_clientno;

// -------ProtoTypes------
// external
void()				ClientConnect;
void()				ClientDisconnect;
void()				SetNewParms;

// rankings
void(float whichteam) BotConnect;
void(entity bot)			BotDisconnect;

// waypointing
void()				DynamicWaypoint;
entity(vector org)		make_waypoint;
void()				ClearAllWays;
void()				FixWaypoints;
float()				begin_route;
void(entity this, float direct)			bot_get_path;
void()				WaypointThink;
entity(entity start)				FindWayPoint;

// physics & movement
float(entity e)			bot_can_rj;
void()				bot_jump;
void()				frik_bot_roam;
float(vector weird)		frik_walkmove;
void()				frik_movetogoal;
void()				frik_obstacles;
float(float flag)			frik_recognize_plat;
float(vector sdir)		frik_KeysForDir;
void(vector whichway, float danger) frik_obstructed;
void()				SV_Physics_Client;
void()				SV_ClientThink;
void() 				CL_KeyMove;

// ai & misc
string()				PickARandomName;
float(entity targ)		fov;
float(float y1, float y2)	angcomp;
float(entity targ1, entity targ2)		wisible;
float(entity targ)		sisible;
float(entity targ)		fisible;
vector(entity ent)		realorigin;
void(entity ent)			target_drop;
void(entity ent)			target_add;
void()				KickABot;
void(entity targ, float success) bot_lost;
float(float v)			frik_anglemod;
void() bot_chat;
void(float tpic) bot_start_topic;


// editor stuffs

void()				bot_way_edit;
void()				bot_menu_display;

//----------------------------------------------------------------------------


int ClientBitFlag(int clientno)
{
	return 1i<<clientno;
};



/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotPreFrame & BotPostFrame, used to make the
bot easier to install

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float  BotPreFrame()
{
	if (self.ishuman)
		return FALSE;

	if (self.b_frags != self.frags)
	{
		
		if (self.b_frags > self.frags)
		{
			if (pointcontents(self.origin) == CONTENT_LAVA)
				bot_start_topic(10);
			else
				bot_start_topic(9);
		}
		else
			bot_start_topic(2);
		self.b_frags = self.frags;
	}
	DynamicWaypoint();
	return FALSE;
};
float  BotPostFrame()
{
	if (self.ishuman)
	{

		if (waypoint_mode > WM_LOADED)
			bot_menu_display();
	}
	return FALSE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Bot Chat code

The rest of this code is in bot_misc.qc

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
void(string h) BotSay = // simulate talking by composing a 'chat' message
{
/*	WriteByte(MSG_ALL, 8);
	WriteByte(MSG_ALL, PRINT_CHAT);
	WriteByte(MSG_ALL, 1);
	WriteString(MSG_ALL, self.netname);
	WriteByte(MSG_ALL, 8);
	WriteByte(MSG_ALL, 2);
	WriteString(MSG_ALL, h);
*/
};
/*void BotSayInit()
{
	WriteByte(MSG_ALL, 8);
	WriteByte(MSG_ALL, PRINT_CHAT);
	WriteByte(MSG_ALL, 1);
	WriteString(MSG_ALL, self.netname);
};
void BotSay2(string h)
{
	WriteByte(MSG_ALL, 8);
	WriteByte(MSG_ALL, PRINT_CHAT);
	WriteByte(MSG_ALL, 2);
	WriteString(MSG_ALL, h);
};
*/
void(string h) BotSayTeam = 
{
	entity t;
	string tn;
	if (!teamplay)
		return;
	tn = self.teamname;
	t = player_head;
	while(t)
	{
		if (t.teamname == tn)
		{
			msg_entity = t;
			WriteByte(MSG_ONE, 8);
			WriteByte(MSG_ONE, 1);
			WriteByte(MSG_ONE, 40);
			WriteString(MSG_ONE, self.netname);
			WriteByte(MSG_ONE, 8);
			WriteByte(MSG_ONE, 2);
			WriteByte(MSG_ONE, 41);
			WriteString(MSG_ONE, h);
		}
		t = t.b_next;
	}
};
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotInit

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/


void BotInit()
{
	precache_model("progs/s_light.spr");
	precache_model("progs/s_bubble.spr");

	max_clients = 16;
};

void DeveloperLightning(entity e1, entity e2, float flag)
{
	// used to show waypoint links for debugging
	WriteByte (MSG_BROADCAST, 23);
	if (flag)
		WriteByte (MSG_BROADCAST, 6);
	else
		WriteByte (MSG_BROADCAST, 13);
	WriteEntity (MSG_BROADCAST, e2);
	WriteCoord (MSG_BROADCAST, e1.origin_x);
	WriteCoord (MSG_BROADCAST, e1.origin_y);
	WriteCoord (MSG_BROADCAST, e1.origin_z);
	WriteCoord (MSG_BROADCAST, e2.origin_x);
	WriteCoord (MSG_BROADCAST, e2.origin_y);
	WriteCoord (MSG_BROADCAST, e2.origin_z); 
};

#if 0
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Find Another Color

Team finding code

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float FindAnotherColor(float tcolor)
{
	float bestbet, scolor, pcount, bestp;
	bestbet = -1;
	bestp = 16;
	while(scolor < 14)
	{
		if (scolor != tcolor)
		{
			b_temp2 = player_head;
			pcount = 0;
			while(b_temp2 != world)
			{
				if (b_temp2.team == scolor + 1)
					pcount = pcount + 1;
				b_temp2 = b_temp2.b_next;
			}
			if ((pcount < bestp) && pcount)
			{
				bestbet = scolor;
				bestp = pcount;
			}
		}
		scolor = scolor + 1;
	}
	if (bestbet < 0)
	{
		bestbet = tcolor;
		while (bestbet == tcolor)
		{
			bestbet = floor(random() * 13);
		}
	}
	return bestbet;
};
#endif

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotConnect and related functions.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void RegeneratePlayerList(entity exclude)
{
	entity e;
	player_head = world;

	e = find(world, classname, "player");
	while(e)
	{
		if (e != exclude)
		{
			e.b_next = player_head;
			player_head = e;
		}

		e = find(e, classname, "player");
	}	
};				

void ClientInRankings()
{
	float whatskill;
	self.ishuman = (clienttype(self) != CLIENTTYPE_BOT);
	if (!self.ishuman)
		bot_count = bot_count + 1;


	// players can set skill all weird, so leave these checks in
	whatskill = rint(getkey(game_botskill)-1);
	if (whatskill > 3)
		whatskill = 3;
	else if (whatskill < 0)
		whatskill = 0;
	self.b_skill = whatskill;

	if (teamplay && !coop)
	{
		self.b_pants = self.clientcolors&15;
		self.b_shirt = (self.clientcolors/16)&15;
	}


	self.b_clientno = (self.colormap-1)&31;	//we use 32bit integers for bot numbers in waypoints. there may still be issues with you go beyond 255 clients, but meh.
	
	RegeneratePlayerList(world);
};

void BotConnect(float whichteam)
{
	entity uself;

	uself = self;
	
	self = spawnclient();
	if(!self)
	{
		bprint(PRINT_HIGH, "Unable to connect a bot, server is full.\n");
		self = uself;
		return;
	}
	bprint(PRINT_HIGH, "Allocated a bot.\n");

	forceinfokey(self, "name", PickARandomName());
	forceinfokey(self, "*bot", "1");
	if (whichteam)
	{
		self.b_pants = whichteam-1;
		self.b_shirt = whichteam-1;
		forceinfokey(self, "topcolor", sprintf("%g", whichteam-1));
		forceinfokey(self, "bottomcolor", sprintf("%g", whichteam-1));
		switch(whichteam-1)
		{
		case 0:
			forceinfokey(self, "team", "white");
			break;
		case 4:
			forceinfokey(self, "team", "red");
			break;
		case 13:
			forceinfokey(self, "team", "blue");
			break;
		}
	}

	self.clientcolors = self.b_pants + self.b_shirt*16;
	
	// chat thing
	bot_start_topic(1);	//make it say hello.

	SetNewParms();
	ClientConnect();
	PutClientInServer();

	self = uself;

	RegeneratePlayerList(world);
};

void ClientDisconnected()
{
	if (!self.ishuman)
		bot_count = bot_count - 1;

	RegeneratePlayerList(self);
};

void BotDisconnect(entity bot)
{
	dropclient(bot);
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Waypoint Loading from file

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
void(float saved1, float saved2, float saved3, float saved4, float scratch1, float scratch2, float scratch3, float scratch4) LoadWaypoint = 
{
	vector org;
	entity tep;
	float r;
	org = [saved1, saved2, saved3];
	
	tep = make_waypoint(org);

	r = saved4;

	tep.b_aiflags = floor(r / 4);
	tep.b_pants = scratch1;
	tep.b_skill = scratch2;
	tep.b_shirt = scratch3;
	tep.b_frags = scratch4;
};

float wpwcount;
void WaypointWatch()
{
	wpwcount++;
	if (wpwcount < 4)
		return;
	if (max_clients < 2)
		return;
	if (waypoint_mode == WM_UNINIT)
	{
		float f = fopen(sprintf("maps/%s.way", mapname), FILE_READ);
		if (f >= 0)
		{
			float saved1=0, saved2=0, saved3=0, saved4=0;
			float scratch1=0, scratch2=0, scratch3=0, scratch4=0;
			string line;
			ClearAllWays();
			while((line = fgets(f)))
			{
				tokenize(line);
				float v = stof(argv(1));
				switch(argv(0))
				{
				case "scratch1": scratch1 = v; break;
				case "scratch2": scratch2 = v; break;
				case "scratch3": scratch3 = v; break;
				case "scratch4": scratch4 = v; break;
				case "saved1": saved1 = v; break;
				case "saved2": saved2 = v; break;
				case "saved3": saved3 = v; break;
				case "saved4": saved4 = v;
					LoadWaypoint(saved1, saved2, saved3, saved4, scratch1, scratch2, scratch3, scratch4);
					break;
				}
			}
			FixWaypoints();
	
			fclose(f);
			waypoint_mode = WM_LOADED;
		}
		else
		{
			waypoint_mode = WM_DYNAMIC;
			bot_map_load();
		}
	}
};
void() BotAI;
float lasttime;
void BotFrame()
{
	float num;

	// for the sake of speed
	sv_maxspeed = autocvar(sv_maxspeed, 320);
	sv_gravity = autocvar(sv_gravity, 800);
	sv_friction = autocvar(sv_friction, 4);
	sv_accelerate = autocvar(sv_accelerate, 10);
	sv_stopspeed = autocvar(sv_stopspeed, 100);
	real_frametime = time - lasttime;
	lasttime = time;
	
	self = player_head;
	num = 0;
	while (self)
	{
		if (self.ishuman == FALSE)
		{
			if (!self.modelindex)
				self.impulse = floor(random()*10);	//try random impulses until we seem to have spawned.
			frik_obstacles();
			CL_KeyMove();
			SV_ClientThink();
			BotAI();
			self.angles = self.v_angle;
			self.angles_x *= -1/3;
//			self.fixangle=TRUE;
//			SV_Physics_Client();
		}
		self = self.b_next;
	}
	WaypointWatch();
};




void BotBalanceTeams(float mincount)
{
	float red = 0, blue = 0;
	for (entity p = world; (p = find(p, classname, "player")); )
	{
		string t = p.teamname;
		if (t == "blue")
			blue++;
		else if (t == "red")
			red++;
	}
	if (mincount < 0)
		mincount = max(red, blue);

	while (red < mincount)
	{
		BotConnect(4+1);
		red++;
	}
	while (blue < mincount)
	{
		BotConnect(13+1);
		blue++;
	}
};
void BotEnforceMinimum(float minplayers)
{
	float players = 0;
	for (entity p = world; (p = find(p, classname, "player")); )
	{
		players++;
	}
	while (players < minplayers)
	{
		BotConnect(0);
		players++;
	}
};
