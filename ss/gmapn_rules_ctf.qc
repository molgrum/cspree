/*
handles runes, flags, and grapple.
*/
.entity hook;

entity ctf_respawnrune(entity e)
{
	entity spot;
	float spots;
	e.classname = "rune";
	e.movetype = MOVETYPE_TOSS;
	e.solid = SOLID_TRIGGER;
	e.flags = FL_ITEM;
	e.touch = (void())
	{
		string rn;
		self.owner = world;
		if (other.classname != "player" || other.deadflag)
			return;
		if (other.items2 & (IT2_RUNE_RESISTANCE|IT2_RUNE_STRENGTH|IT2_RUNE_HASTE|IT2_RUNE_REGEN))
		{
			centerprint(other, "You already have a rune");
			return;
		}
		if (self.items2 & IT2_RUNE_RESISTANCE)
			rn = "resistance";
		else if (self.items2 & IT2_RUNE_STRENGTH)
			rn = "strength";
		else if (self.items2 & IT2_RUNE_HASTE)
			rn = "haste";
		else if (self.items2 & IT2_RUNE_REGEN)
			rn = "regeneration";
		else
			rn = "buggy";
		centerprint(other, "You got the ", rn, " rune");
		stuffcmd(other, "bf\n");
		other.items2 |= self.items2;
		other.items2 |= (self.items2&15)*32;	//make sure the hud is okay.
		remove(self);

		if (other.items2 & IT2_RUNE_HASTE)
			other.hasted = 1.25;
		else
			other.hasted = 0;
	};
	e.nextthink = time + 60;
	e.think = (void()){ctf_respawnrune(self);};
	if (e.items2 & IT2_RUNE_RESISTANCE)
		setmodel(e, "progs/end1.mdl");
	else if (e.items2 & IT2_RUNE_STRENGTH)
		setmodel(e, "progs/end2.mdl");
	else if (e.items2 & IT2_RUNE_HASTE)
		setmodel(e, "progs/end3.mdl");
	else if (e.items2 & IT2_RUNE_REGEN)
		setmodel(e, "progs/end4.mdl");
	else
		setmodel(e, "progs/end1.mdl");
	setsize(e, '-16 -16 -24', '16 16 32');

	for(spots = 0, spot = world; (spot = find(spot, classname, "info_player_deathmatch")); )
		spots++;
	for(spots = random(spots), spot = world; (spot = find(spot, classname, "info_player_deathmatch")) && spots >= 0; )
		spots--;
	setorigin(e, spot.origin);
	return e;
};
void ctf_tossrune()
{
	float mask = IT2_RUNE_RESISTANCE|IT2_RUNE_STRENGTH|IT2_RUNE_HASTE|IT2_RUNE_REGEN;
	float it = self.items2 & mask;
	if (it)
	{
		entity e = ctf_respawnrune(spawn(entity, items2:it));
		setorigin(e, self.origin);
		makevectors([0, self.v_angle_y, 0]);
		e.velocity = v_forward * 400 + v_up * 400;
		e.owner = self;
	}
	self.items2 &= ~(it*(1|32));
	self.items2 |= serverflags * 32;
};
//returns the flag to its original spawn state.
void ctf_flag_return()
{
	setattachment(self, world, "");
	if (self.owner)
	{
		self.owner.traileffectnum = 0;
		self.owner.thawplayer = world;
		setattachment(self, world, "");
	}
	self.traileffectnum = particleeffectnum(strcat("gmapn.tr_flag_", self.teamname));
	self.owner = world;
	self.cnt = FALSE;
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	setorigin(self, self.finaldest);
};
void() ctf_player_died = 
{
	if (self.thawplayer)
	{
		other = self.thawplayer;
		self.thawplayer = world;

		other.think = ctf_flag_return;
		other.nextthink = time + getkey(ctf_returntime);
		other.solid = SOLID_TRIGGER;
		other.cnt = FALSE;
		
		other.traileffectnum = particleeffectnum(strcat("gmapn.tr_flag_", other.teamname));
		self.traileffectnum = 0;
		setattachment(other, world, "");
		other.owner = world;
		setorigin(other, self.origin);
		other.movetype = MOVETYPE_TOSS;
		other.velocity = randomv('-600 -600 320', '600 600 320');
	}
	ctf_tossrune();	//runes are tossed on death. try not to die near an enemy.
};
void ctf_flag_grabbed()
{
	if (other.classname != "player" || other.deadflag)
	{
		if (other.solid == SOLID_BSP)
		{	//if we're touching a bsp object then its because we came to rest somewhere.
			//make sure we're not somewhere impossible like lava nor slime
			float c = pointcontents(self.origin);
			if (c == CONTENT_LAVA || c == CONTENT_SLIME)
				ctf_flag_return();
		}
		return;
	}
	if (infokey(other, "team") == self.teamname)
	{	//an allied player touched us
		if (self.cnt)
		{	//we're not sitting on our spot...
			bprint(PRINT_HIGH, other.netname, " returns the ", self.teamname, " flag\n");
			other.frags += getkey(ctf_returnscore);
			ctf_flag_return();
		}
		else if (other.thawplayer)
		{	//they're carrying a flag, return it and give the player some points.
			self = other.thawplayer;
			bprint(PRINT_HIGH, other.netname, " captures the ", self.teamname, " flag\n");
			other.frags += getkey(ctf_capturescore);
			ctf_flag_return();
		}
	}
	else
	{	//an enemy player touched us
		other.thawplayer = self;
		other.traileffectnum = self.traileffectnum;
		self.traileffectnum = 0;
		self.owner = other;
		self.origin = '-16 0 0';
		setattachment(self, other, "");
		self.solid = SOLID_NOT;
		self.cnt = TRUE;
		
		other.frags += getkey(ctf_grabscore);
		bprint(PRINT_HIGH, other.netname, " took the ", self.teamname, " flag!\n");
	}
};
void ctf_enableflags(float flagstate)
{
	for(entity e = world; (e = find(e, classname, "item_flag")); )
	{
		if (flagstate)
		{
			e.solid = SOLID_TRIGGER;
			setmodel(e, e.mdl);
			setsize(e, '-16 -16 0', '16 16 56');
		}
		else
		{
			e.solid = SOLID_NOT;
			setmodel(e, "");
			setsize(e, '-16 -16 0', '16 16 56');
		}
	}

	//remove any existing runes.
	for(entity e = world; (e = find(e, classname, "rune")); )
		remove(e);

	if (flagstate)
	{
		ctf_respawnrune(spawn(entity, items2:IT2_RUNE_RESISTANCE));
		ctf_respawnrune(spawn(entity, items2:IT2_RUNE_STRENGTH));
		ctf_respawnrune(spawn(entity, items2:IT2_RUNE_HASTE));
		ctf_respawnrune(spawn(entity, items2:IT2_RUNE_REGEN));
	}
};
void item_flag()
{
	if (!self.teamname)	//just in case
		self.teamname = self.netname;
	if (!self.teamname)
	{
		self.teamname = "neutral";
		self.skin = 2;
	}
	
	self.classname = "item_flag";
	self.mdl = "progs/flag.mdl";
	self.touch = ctf_flag_grabbed;
	self.think = ctf_flag_return;
	self.movetype = MOVETYPE_TOSS;
	precache_model(self.mdl);
	setmodel(self, self.mdl);
	setsize(self, '-16 -16 0', '16 16 56');
	droptofloor();	//hopefully noone will place one of these on a train or anything silly like that
	self.finaldest = self.origin;	//place to return to when dropped in lava etc

	self.traileffectnum = particleeffectnum(strcat("gmapn.tr_flag_", self.teamname));
};
void item_flag_team1()
{
	self.teamname = "red";
	self.skin = 0;
	item_flag();
};
void item_flag_team2()
{
	self.teamname = "blue";
	self.skin = 1;
	item_flag();
};

#pragma warning disable F317
void() player_hook1 = [$rockatt1, player_hook2] {self.weaponframe = 1;};
void() player_hook2 = [$rockatt2, player_hook3] {self.weaponframe = 2;};
void() player_hook3 = [$rockatt3, player_hook4] {self.weaponframe = 3;};
void() player_hook4 = [$rockatt4, player_hook5] {self.weaponframe = 4;};
void() player_hook5 = [$rockatt5, player_hook6] {self.weaponframe = 5;};
void() player_hook6 = [$rockatt6, player_run]	  {self.weaponframe = 6;};
#pragma warning enable F317

void ctf_hook_release()
{
	entity h = self.hook;
	self.hook = world;
	remove(h);
	self.attack_finished = time + 0.3;
	self.movetype = MOVETYPE_WALK;
};
static void hook_impact()
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		self = self.owner;
		ctf_hook_release();
	}
	else if (other.solid == SOLID_BSP)
	{	//set up the hook to always follow the door/plan/train/etc
		self.movetype = MOVETYPE_FOLLOW;
		self.aiment = other;
		vector d = self.origin - other.origin;
		makevectors(other.angles);
		self.view_ofs_x = v_forward * d;
		self.view_ofs_y = v_right * d;
		self.view_ofs_z = v_up * d;
		self.view_ofs = d;
		self.touch = 0;
		self.velocity = '0 0 0';
		
		self.owner.movetype = MOVETYPE_FLY;
	}
};
void ctf_firehook()
{
	entity h;
	
	if (!self.hook)
	{
		self.attack_finished = time + 0.6;
		player_hook1();
		self.hook = h = spawn();
		h.touch = hook_impact;
		h.movetype = MOVETYPE_FLY;
		h.solid = SOLID_BBOX;
		h.velocity = v_forward * 1100;
		h.owner = self;
		setmodel(h, "progs/star.mdl");
		setsize(h, '0 0 0', '0 0 0');
		setorigin(h, self.origin);
	}
};
void() ctf_hookupdate = 
{
//	float olddist, newdist;
	if (!self.button0 && self.weapon == IT_HOOK)
		ctf_hook_release();
	if (self.movetype != MOVETYPE_FLY)
	{
		runstandardplayerphysics(self);
		return;	//still flying to the wall
	}
	self.velocity += normalize(self.hook.origin - self.origin)*1500*input_timelength;
	if (vlen(self.velocity) > 1000)
		self.velocity *= 1000 / vlen(self.velocity);
	self.velocity_z -= autocvar_sv_gravity*input_timelength;
	self.teleport_time = 0.1;
	input_movevalues = '0 0 0';
//	olddist = vlen(self.hook.origin - self.origin);
	runstandardplayerphysics(self);
//	newdist = vlen(self.hook.origin - self.origin);
	
//	if (newdist > olddist && newdist > 64)
//		self.velocity *= 1 - 0.5*input_timelength;
};

void SV_RunClientCommand() 
{
	if (!self.ishuman)
		input_angles = self.v_angle;

	if (!self.maxspeed)
	{	//in menus or frozen
		input_buttons = 0;
		input_movevalues = '0 0 0';
	} 

	if (self.hook)
		ctf_hookupdate();
	else
		runstandardplayerphysics(self);
};
