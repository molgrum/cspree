/*
    client.qc

    Copyright (C) 1996-1997  Id Software, Inc.
    Copyright (C) 2009       Andreas Nilsson

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

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

string nextmap;

float	intermission_running;
float	intermission_exittime;

//we only write/read parms in coop.
//health will be 0 if the player has not transferred from the previous coop map
void SetChangeParms()
{
	//this function is called on map changes where ClientDisconnect might not be.
	//this gives us a chance to fix up *spectator so that they don't appear as spectators on the next map too.
	if (self.classname == "player" && stof(infokey(self, "*spectator")) == 2)
		forceinfokey(self, "*spectator", "");

	if (self.deadflag || !coop)
	{
		// reset inventory
		SetNewParms ();
	}
	else
	{
		parm1 = self.items & ~(IT_KEY1 | IT_KEY2 | IT_RING | IT_PENT | IT_SUIT | IT_QUAD | IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
		parm2 = bound(50, self.health, 100);
		parm3 = self.armorvalue;
		parm4 = max(25, self.ammo_shells);
		parm5 = self.ammo_nails;
		parm6 = self.ammo_rockets;
		parm7 = self.ammo_cells;
		parm8 = self.weapon;
		parm9 = self.armortype;
	}

	// rulemaker status is idependent of single player status
	parm10 = (gmapn_gamemaster == self);
};

void SetNewParms()
{
	//client spawn code will figure it out itself if 'health' is 0.
	parm1 = 0;
	parm2 = 0;
	parm3 = 0;
	parm4 = 0;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 0;
	parm9 = 0;
	parm10 = 0; // rulemaker status for this client
};

//player has already been given their defaults
void DecodeLevelParms()
{
	if (!coop || gmapn_serverstate != gmapn_serverstate_playing)
	{
		// when voting maps
		setspawnparms(self);
		if (parm10)
		{
			if (gmapn_gamemaster != self)
			{
				gmapn_gamemaster = self;
				bprintln(PRINT_HIGH, sprintf("%s gets rule maker rights from previous session", self.netname));
			}
		}

		return;
	}

	//start maps of any kind never let you carry weapons over.
	if (strstrofs(mapname, "start") >= 0)
		return;
		
	setspawnparms(self);
	
	//make sure that this stuff is actually valid.
	if (!parm2)
		return;
	//its all good, overwrite it now.

	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity FindIntermission()
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{		// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
	return world;
};


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void IntermissionThink()
{
	if (time < intermission_exittime)
		return;

	// Stop any demo recording
	if (gmapn_recording == TRUE) {
		localcmd("stop\n");
		gmapn_recording = FALSE;
	}

	if (!self.button0 && !self.button1 && !self.button2 && !getkey(runtests))
		return;

	//kick bots before we change the map. this prevents them from tagging along onto the next map.
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (clienttype(e) == CLIENTTYPE_BOT)
			dropclient(e);
	}

	if (coop && nextmap)
		changelevel(nextmap);
	else
		changelevel(mapname);
};

void SendIntermissionToPlayer(entity player)
{
	entity	pos;

	msg_entity = player;

	pos = FindIntermission();

// play intermission music
	WriteByte(MSG_ONE, SVC_CDTRACK);
	WriteByte(MSG_ONE, 3);

	WriteByte(MSG_ONE, SVC_INTERMISSION);
	WriteCoord(MSG_ONE, pos.origin_x);
	WriteCoord(MSG_ONE, pos.origin_y);
	WriteCoord(MSG_ONE, pos.origin_z);
	WriteAngle(MSG_ONE, pos.mangle_x);
	WriteAngle(MSG_ONE, pos.mangle_y);
	WriteAngle(MSG_ONE, pos.mangle_z);

	player.solid = SOLID_NOT;
	player.movetype = MOVETYPE_NONE;
	player.modelindex = 0;
	player.view_ofs = 0;
	player.vw_index = 0;
	player.model = "";
	player.takedamage = DAMAGE_NOT;		// No damage during intermissions
}

/*
============
execute_changelevel

The global "nextmap" has been set previously.
Take the players to the intermission spot
============
*/
void execute_changelevel()
{
	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	other = find(world, classname, "player");
	while(other != world)
	{
		//let the player know where the intermission camera is
		SendIntermissionToPlayer(other);
		//and fix anything dueling may have broken.
		forceinfokey(other, "*spectator", "");
	
		other = find(other, classname, "player");
	}		
};

/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

//void() set_suicide_frame;
void(entity ent) CopyToBodyQue;

// called by ClientKill and DeadThink
void respawn()
{
	// make a copy of the dead body for appearances sake
	CopyToBodyQue (self);
	// set default spawn parms
	SetNewParms ();
	// respawn				
	client_spawn(FALSE);
};

void respawn_living()
{
	SetNewParms();
	client_spawn(FALSE);
}

void client_setweapon(float flag)
{
	// Weapon is recognized so we can set the weaponflag
	self.weapon = flag;
	//self.weaponframe = 0;
	player_setweapon();
};

float client_checkammo()
{
	if (self.weapon == IT_SHOTGUN && self.ammo_shells < 1)
		return 0;
	else if (self.weapon == IT_SUPER_SHOTGUN && self.ammo_shells < 2)
		return 0;
	else if (self.weapon == IT_NAILGUN && self.ammo_nails < 1)
		return 0;
	else if (self.weapon == IT_SUPER_NAILGUN && self.ammo_nails < 2)
		return 0;
	else if (self.weapon == IT_GRENADE_LAUNCHER && self.ammo_rockets < 1)
		return 0;
	else if (self.weapon == IT_ROCKET_LAUNCHER && self.ammo_rockets < 1)
		return 0;
	else if (self.weapon == IT_LIGHTNING_GUN && self.ammo_cells < 1)
		return 0;

	return 1;
};

float client_bestweapon()
{
	if (deathmatch == DMM_INSTAGIB)
		return IT_COILGUN;
	else if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (self.items & IT_LIGHTNING_GUN))
	{
		return IT_LIGHTNING_GUN;
	}
	else if (self.ammo_nails >= 2 && (self.items & IT_SUPER_NAILGUN))
	{
		return IT_SUPER_NAILGUN;
	}
	else if (self.ammo_shells >= 2 && (self.items & IT_SUPER_SHOTGUN))
	{
		return IT_SUPER_SHOTGUN;
	}
	else if(self.ammo_nails >= 1 && (self.items & IT_NAILGUN))
	{
		return IT_NAILGUN;
	}
	else if (self.ammo_shells >= 1 && (self.items & IT_SHOTGUN))
	{
		return IT_SHOTGUN;
	}
	else
	{
		return IT_AXE;
	}
};

void client_cycleweapon(float forward)
{
	float weapons_cycled = 0;

	do
	{
		if (weapons_cycled > 16)
			break; // no weapon found

		if (forward == TRUE && self.weapon == IT_COILGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (forward == FALSE && self.weapon == IT_AXE)
		{
			self.weapon = IT_COILGUN;
		}
		else if (forward == TRUE && self.weapon == IT_AXE)
		{
			self.weapon = IT_PORTALGUN;
		}
		else if (forward == FALSE && self.weapon == IT_PORTALGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (forward == TRUE && self.weapon == IT_PORTALGUN)
		{
			// we cannot bitshift since IT_AXE is 4096
			self.weapon = IT_SHOTGUN;
		}
		else if (forward == FALSE && self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_PORTALGUN;
		}
		else
		{
			// ok to shift
			if (forward == TRUE)
				self.weapon = self.weapon * 2;
			else
				self.weapon = self.weapon / 2;
		}
		weapons_cycled++;
	} while (!client_weaponokay());
};

.float lastroundnum;

entity client_spawnpoint()
{
	entity player, spawnp, bestspawn;
	float cur_distance, max_distance;
	float spawnmode;
	float spawns, occupiedspots;
	float f, rnd; // spawn mode 3
	string team1, team2;
	string spotclass;
	vector spawnpos, playerpos;
	float ignoreoccupied;

	bestspawn = world;
	
	spawnmode = getkey(spawn_mode);
	
	ignoreoccupied = 1;
	spotclass = "info_player_deathmatch";
	if (coop && gmapn_serverstate == gmapn_serverstate_playing)
		spotclass = "info_player_coop";
	
	if (teamplay)
	{
		team1 = self.teamname;
		team2 = 0;
		if (team1 == "red")
			team2 = "info_player_team1";
		if (team1 == "blue")
			team2 = "info_player_team2";
		if (team2)
		{
			if (find(world, classname, team2))
				spotclass = team2;
		}
	}
	
	if (spawnmode == 1)
	{
		// Find a spawn point as far from the enemy as possible
		max_distance = 0;
		spawnp = find(world, classname, spotclass);
		while (spawnp)
		{
			// Find the nearest enemy
			cur_distance = 0;
			player = find(world, classname, "player");
			while (player)
			{
				team1 = player.teamname;
				team2 = self.teamname;
				// Is it an enemy?
				if (team1 != team2)
				{
					spawnpos = spawnp.origin;
					playerpos = player.origin;
					if (!cur_distance || vlen(playerpos - spawnpos) < cur_distance)
					{
						cur_distance = vlen(playerpos - spawnpos);
					}
				}
				player = find(player, classname, "player");
			}
			// Is this distance the longest?
			if (cur_distance >= max_distance)
			{
				max_distance = cur_distance;
				bestspawn = spawnp;
			}
			cur_distance = 0;
			spawnp = find(spawnp, classname, spotclass);
		}
	}
	else if (spawnmode == 3)
	{
		//dprint("FIXME: spawn mode 3 is probably buggy\n");
		ignoreoccupied = 0;

		// Some stuff to ignore occupied spots at each round start
		if (0 && gmapn_serverstate != gmapn_serverstate_playing)
		{
			self.lastroundnum = 0;
		}
		else if (gmapn_serverstate == gmapn_serverstate_playing && self.lastroundnum < gmapn_roundnum)
		{
			ignoreoccupied = 1;
			self.lastroundnum = gmapn_roundnum;
		}

		// Count the number of spawns
		spawns = 0;
		occupiedspots = 0;
		spawnp = find(world, classname, spotclass);
		while (spawnp)
		{
			spawns++;

			// Is it occupied?
			if (ignoreoccupied)
				tracebox(spawnp.origin, VEC_HULL_MIN, VEC_HULL_MAX, spawnp.origin, FALSE, self);
			else
				trace_startsolid = FALSE;

			if (trace_startsolid)
				occupiedspots++;

			spawnp.voided = trace_startsolid;


			// Go to the next spawn in the chain
			spawnp = find(spawnp, classname, spotclass);
		}

		f = random() * (SP_WEIGHT*(spawns));
		rnd = floor(random() * (spawns - occupiedspots)); // for use if all spots are occupied

		// Get a random spawn point
		spawnp = find(world, classname, spotclass);
		bestspawn = spawnp;
		while (spawnp)
		{
			// If all spots are occupied, just get a random spot
			if (occupiedspots == spawns && rnd >= 0)
				bestspawn = spawnp;

			if ((ignoreoccupied && !spawnp.voided && rnd >= 0) || !ignoreoccupied)
				bestspawn = spawnp;

			f = f - spawnp.cnt;
			if (!ignoreoccupied && f < 0)
				break;

			if (!spawnp.voided)
				rnd--;

			spawnp = find(spawnp, classname, spotclass);
		}
		
		// Fix weights
		spawnp = find(world, classname, spotclass);
		while (spawnp)
		{
			if (spawnp == bestspawn)
			{
				spawnp.cnt = spawnp.cnt - 1;
			}
			else
			{
				spawnp.cnt = spawnp.cnt + 1/(spawns);
			}
			
			spawnp = find(spawnp, classname, spotclass);
		}
	}
	else
	{
		// Count the number of spawns
		spawns = 0;
		spawnp = find(world, classname, spotclass);
		while (spawnp)
		{
			if (ignoreoccupied)
				tracebox(spawnp.origin, VEC_HULL_MIN, VEC_HULL_MAX, spawnp.origin, FALSE, self);
			else
				trace_startsolid = FALSE;
			
			spawnp.voided = trace_startsolid;
			if (!trace_startsolid)
				spawns = spawns + 1;
			
			// Go to the next spawn in the chain
			spawnp = find(spawnp, classname, spotclass);
		}
		if (!spawns && ignoreoccupied)
		{	//err, no spawn points. I guess someone's standing on them all. just telefrag someone.
			for( spawnp = world; (spawnp = find(spawnp, classname, spotclass)); )
			{
				spawnp.voided = FALSE;
				spawns++;
			}
		}
		
		// Substract a random number from the max
		spawns = floor(random()*spawns);
		
		// Get a random spawn point
		spawnp = find(world, classname, spotclass);
		for(;spawnp;)
		{
			if (!spawnp.voided)
			{
				if (!spawns)
					break;
				spawns -= 1;
			}
			spawnp = find(spawnp, classname, spotclass);
		}
		
		bestspawn = spawnp;
	}

	if (bestspawn)
		bestspawn.attack_finished = time + 0.5;
	else
		dprintln("Error: spawn spot doesn't exist");

	return bestspawn;
};

void client_spawn(float sameplace)
{
	float  f;
	vector dir, org;
	
	// This is the place where the player spawns. It is used to set the player's origin
	entity spawn_point;
	
	float spectatormode = stof(infokey(self, "*spectator"));	//potentially set in duels when there are 3+ players.
	
	// Restore some attributes
	self.ammo_shells = 0;				// Always start with 0 shells
	self.ammo_nails = 0;				// Always start with 0 nails
	self.ammo_rockets = 0;				// Always start with 0 rockets
	self.ammo_cells = 0;				// Always start with 0 cells
	self.ammo_heads = 0;				// not carrying any heads yet.
	self.armortype = 0;
	self.armorvalue = 0;
	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	self.deadflag = DEAD_NO;
	self.effects = 0;
	self.skin = 0;
	self.view2 = world;
	self.colormap = num_for_edict(self);
	self.fallspeed = 0;						// To prevent damage if we died while falling
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED)
				- (self.flags & FL_INWATER);
	self.health = self.max_health;			// Set out health to the maximum
	self.pausetime = 0;
	self.show_hostile = 0;
	if (spectatormode == 1 || spectatormode == 2)
	{
		self.solid = SOLID_NOT;
		self.takedamage = DAMAGE_NO;
		self.deadflag = DEAD_DEAD;
		self.movetype = MOVETYPE_NOCLIP;		//
	}
	else if (spectatormode == 3)
	{
		client_setsemispectator(self);
		forceinfokey(self, "*spectator", "");
	}
	else
	{
		self.solid = SOLID_SLIDEBOX;			//
		self.takedamage = DAMAGE_BLEED;			// Set bleeding behaviour
		self.movetype = MOVETYPE_WALK;			//
	}
	self.waterlevel = 0;
	self.watertype = CONTENT_EMPTY;
	
	self.pent_finished = 0;
	self.quad_finished = 0;
	self.ring_finished = 0;
	self.suit_finished = 0;
	
	self.velocity = '0 0 0';			// No speed
	self.maxspeed = autocvar(sv_maxspeed, 320);
	self.hasted = 0;
	self.touch = 0;
	
	self.items = getkey(game_loadout);
	self.items2 = serverflags * 32;
	
	// in prewar and dmm4, give everything
	if (gmapn_serverstate == gmapn_serverstate_prewar || deathmatch == 4)
	{
		self.items = IT_AXE | IT_SHOTGUN;
		self.items = self.items | IT_SUPER_SHOTGUN;
		self.items = self.items | IT_NAILGUN;
		self.items = self.items | IT_SUPER_NAILGUN;
		self.items = self.items | IT_GRENADE_LAUNCHER;
		self.items = self.items | IT_ROCKET_LAUNCHER;
		self.items = self.items | IT_LIGHTNING_GUN;
//		self.items = self.items | IT_RAILGUN;
//		self.items = self.items | IT_PORTALGUN;
		// in prewar and dmm4, give starting ammo
		self.ammo_shells = self.max_ammo_shells;
		self.ammo_nails = self.max_ammo_nails;
		self.ammo_rockets = self.max_ammo_rockets;
		self.ammo_cells = self.max_ammo_cells;
		self.health = self.max_megahealth;
		self.items = self.items | IT_ARMOR3;

		if (gmapn_serverstate != gmapn_serverstate_prewar && deathmatch == 4) // Give pent in dmm4
			self.items |= IT_PENT;
		client_setweapon(IT_SHOTGUN);			// Starting weapon
	}
	else if (deathmatch == DMM_INSTAGIB)
	{	//instagib
		self.ammo_shells = self.max_ammo_shells;
		self.items = IT_HOOK | IT_COILGUN;		// Starting items
		client_setweapon(IT_COILGUN);			// Starting weapon
	}
	else if (deathmatch == DMM_MIDAIR)
	{	//midair
		self.ammo_rockets = self.max_ammo_rockets;
		self.items = IT_GRENADE_LAUNCHER|IT_ROCKET_LAUNCHER;	// Starting items
		client_setweapon(IT_ROCKET_LAUNCHER);			// Starting weapon
	}
	else
	{	//standard deathmatch
		self.ammo_shells = 25;				// Always start with 0 shells
		self.items |= IT_AXE | IT_SHOTGUN;		// Starting items
		client_setweapon(IT_SHOTGUN);			// Starting weapon
	}

	//make sure powerups work
	if (self.items & IT_PENT)
	{
		self.effects |= EF_RED;
		self.pent_finished = time + 3.0;
	}
	if (self.items & IT_QUAD)
	{
		self.effects |= EF_BLUE;
		self.quad_finished = time + 10.0;
	}
	if (self.items & IT_SUIT)
	{
		self.effects |= EF_GREEN;
		self.suit_finished = time + 10.0;
	}
	if (self.ammo_cells < 15 && (self.items & (IT_LIGHTNING_GUN | IT_RAILGUN)))
		self.ammo_cells = 15;
	if (self.ammo_rockets < 5 && (self.items & (IT_ROCKET_LAUNCHER | IT_GRENADE_LAUNCHER)))
		self.ammo_rockets = 5;
	if (self.ammo_nails < 50 && (self.items & (IT_SUPER_NAILGUN | IT_NAILGUN)))
		self.ammo_nails = 50;
	if (self.ammo_shells < 25 && (self.items & (IT_SUPER_SHOTGUN | IT_SHOTGUN)))
		self.ammo_shells = 25;
	
	//make sure armour is okay
	if (self.items & IT_ARMOR3)
	{
		self.armortype = getkey(armor3_absorb);
		self.armorvalue = getkey(armor3_amount);
		self.items &~= IT_ARMOR1|IT_ARMOR2;
	}
	else if (self.items & IT_ARMOR2)
	{
		self.armortype = getkey(armor2_absorb);
		self.armorvalue = getkey(armor2_amount);
		self.items &~= IT_ARMOR1|IT_ARMOR2;
	}
	else if (self.items & IT_ARMOR1)
	{
		self.armortype = getkey(armor1_absorb);
		self.armorvalue = getkey(armor1_amount);
		self.items &~= IT_ARMOR2|IT_ARMOR3;
	}

	DecodeLevelParms();
	
	//player_setweapon();
	
	if (!sameplace)
	{
		if (getkey(spawn_mode) == 2 && self.my_spawn != world)
		{
			// Spawn us at selected spawn
			spawn_point = self.my_spawn;
		}
		else
		{
			// Spawn us somewhere
			spawn_point = client_spawnpoint();
		}
		
		org = spawn_point.origin;
		
		if (spectatormode)
		{
			//no telefrag or anything
		}
		else if (gmapn_serverstate != gmapn_serverstate_playing || !getkey(spawn_telefrag))		{
			// Spawns (usually) never telefrag in prewar. sometimes we don't get a choice.
			float giveup = 256;
			
//			dprint(sprintf("Spawning player %s\n", self.netname));

			f = 1;
			dir = '0 0 0';
			for (;;)
			{
				if (giveup-- <= 0)
				{
					org = spawn_point.origin;
					break;
				}
				
//				dprint(sprintf("Trying %v\n", org));
				tracebox(org, VEC_HULL_MIN, VEC_HULL_MAX, org, FALSE, self);
				if (trace_fraction == 1 && !trace_startsolid)
					break;
				
				// Occupied or unspawnable, nudge it
			
				// Change next direction, clockwise
				if (dir == '0 0 0')
				{
					dir = '1 0 0';
				}
				else if (dir == '1 0 0')
				{
					dir = '0 -1 0';
				}
				else if (dir == '0 -1 0')
				{
					dir = '-1 0 0';
				}
				else if (dir == '-1 0 0')
				{
					dir = '0 1 0';
				}
				else
				{
					dir = '0 0 0';
			
					// move a little further out
					f = f + 1;
					
					if (f > 2)
					{
						spawn_point = client_spawnpoint();
						f = 1;
						dir = '0 1 0';
						org = spawn_point.origin;
						dprint(sprintf("Trying a different spot\n"));
						continue;
					}
				}
				// Choose another
				org = spawn_point.origin + (32)*floor(f)*dir;
			}
			
			gmapn_telefrag_check(self, org);
		}
		else
		{
			// Telefrag players occupying the spot
			gmapn_telefrag_check(self, org);
		}

		self.origin = org;					// Move the player to spawn_point
		self.angles = spawn_point.angles;	// Face the way spawn_point tells us
		self.fixangle = TRUE;				// Turn this way immediately
	}
	

	if (spectatormode)
	{
		setmodel(self, "");
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);	// Set the player size
		self.view_ofs = '0 0 0';
		
		//spectators don't need to think
		self.think = func_null;
		self.nextthink = 0;
	}
	else
	{
		setmodel(self, "progs/player.mdl");

		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);	// Set the player size
		self.view_ofs = '0 0 22';			// Center the view

		makevectors(self.angles);
		teleport_effect(self.origin + v_forward*20);
		
		// Begin standing animation
		player_stand();
	}
	
	if (gmapn_gamemode == GM_HEADHUNTER && gmapn_serverstate == gmapn_serverstate_playing)
		showpic("hc", sprintf("gfx/num_%g", bound(0, self.ammo_heads, 9)), 0, 0, 0, self);
};

//
void client_clearspectator(entity player)
{
	forceinfokey(player, "*spectator", "");	//ezquake bug - \*spectator\0 = spectating... if you fill your userinfo its your own fault.
	
	//ezquake bug - players switching between spectator and player end up with -999 frags.
	WriteByte(MSG_MULTICAST, SVC_UPDATEFRAGS);
	WriteByte(MSG_MULTICAST, player.colormap-1);
	WriteShort(MSG_MULTICAST, player.frags);
	multicast('0 0 0', MULTICAST_ALL_R);

	//make sure it worked properly.
	if (stof(infokey(player, "*spectator")))
	{
		sprint(player, PRINT_HIGH, "Please empty out your userinfo a little\n");
		dropclient(player);
	}
};

void client_setspectator(entity player)
{
	forceinfokey(player, "*spectator", "2");
	if (!stof(infokey(player, "*spectator")))
	{
		sprint(player, PRINT_HIGH, "Please empty out your userinfo a little\n");
		dropclient(player);
	}
};

void client_clearsemispectator(entity player)
{
	player.solid = SOLID_SLIDEBOX;
	player.takedamage = DAMAGE_BLEED;
	player.movetype = MOVETYPE_WALK;
	player.dimension_seen = 1;
};

void client_setsemispectator(entity player)
{
	player.solid = SOLID_NOT;
	player.takedamage = DAMAGE_NO;
	player.movetype = MOVETYPE_NOCLIP;
	player.armortype = 0;
	player.armorvalue = 0;
	player.health = player.max_health;
	player.vw_index = 0;
	player.weapon = 0;
	player.weaponmodel = "";
	player.items = 0;
	player.ammo_shells = 0;
	player.ammo_nails = 0;
	player.ammo_rockets = 0;
	player.ammo_cells = 0;
	player.dimension_seen = 0;
};

float client_weaponokay()
{
	float w = self.weapon;
	if (w == IT_HOOK && getkey(hook_enabled) != 0)
		return TRUE;
	if (deathmatch == DMM_INSTAGIB)	//in instagib, any other gun but coilgun is disallowed / irrelevant
		return w == IT_COILGUN;
	if (w == IT_AXE)
		return TRUE;
	if (w == IT_COILGUN)
		return FALSE;
	if (self.items & w)
	{
		switch(w)
		{
		case IT_SHOTGUN:
		case IT_SUPER_SHOTGUN:
			return self.ammo_shells > 0;
		case IT_NAILGUN:
		case IT_SUPER_NAILGUN:
			return self.ammo_nails > 0;
		case IT_GRENADE_LAUNCHER:
		case IT_ROCKET_LAUNCHER:
			return self.ammo_rockets > 0;
		case IT_LIGHTNING_GUN:
		case IT_RAILGUN:
			return self.ammo_cells > 0;
		case IT_AXE:
		case IT_PORTALGUN:
			return TRUE;
		}
	}
	return FALSE;
};

void client_impulses()
{	
	// Weapon change impulses can only be used if we're not shooting
	if (self.impulse >= 1 && self.impulse <= 12 || self.impulse == 22)
	{
		if (self.attack_finished > time)
 			return;
	}
	
	if (self.impulse == 1 && (self.items & IT_AXE))
	{
		self.weapon = IT_AXE;
	}
	else if (self.impulse == 2 && ((self.items & IT_SHOTGUN) || (self.items & IT_COILGUN)))
	{
		// coilgun is bound to shotgun
		if (self.items & IT_COILGUN)
			self.weapon = IT_COILGUN;
		else if (self.ammo_shells >= 1)
		{
			self.weapon = IT_SHOTGUN;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 3 && (self.items & IT_SUPER_SHOTGUN))
	{
		// Change weapon to Super Shotgun
		if (self.ammo_shells >= 2)
		{
			self.weapon = IT_SUPER_SHOTGUN;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 4 && (self.items & IT_NAILGUN))
	{
		// Change weapon to Nailgun
		if (self.ammo_nails >= 1)
		{
			self.weapon = IT_NAILGUN;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 5 && (self.items & IT_SUPER_NAILGUN))
	{
		// Change weapon to Super Nailgun
		if (self.ammo_nails >= 2)
		{
			self.weapon = IT_SUPER_NAILGUN;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 6 && (self.items & IT_GRENADE_LAUNCHER))
	{
		// Change weapon to Greande Launcher
		if (self.ammo_rockets >= 1)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 7 && (self.items & IT_ROCKET_LAUNCHER))
	{
		// Change weapon to Rocket Launcher
		if (self.ammo_rockets >= 1)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 8 && (self.items & IT_LIGHTNING_GUN))
	{
		// Change weapon to Lightning Gun
		if (self.ammo_cells >= 1)
		{
			self.weapon = IT_LIGHTNING_GUN;
		}
		else
		{
			self.weapon = client_bestweapon();
		}
	}
	else if (self.impulse == 9)
	{
		// If railgun is disabled, set to Coilgun instead
		if (getkey(rail) == 0 && (self.items & IT_COILGUN))
		{
			self.weapon = IT_COILGUN;
		}
		else if (self.items & IT_RAILGUN)
		{
			// Change weapon to Railgun
			if (self.ammo_cells >= 4)
			{
				self.weapon = IT_RAILGUN;
			}
			else
			{
				self.weapon = client_bestweapon();
			}
		}
	}
	else if (self.impulse == 10)
	{
		// Cycle weapon forward
		client_cycleweapon(TRUE);
	}
	else if (self.impulse == 12)
	{
		// Cycle weapon backward
		client_cycleweapon(FALSE);
	}
	else if (self.impulse == 22)
	{
		if (getkey(hook_enabled) != 0)
		{
			self.weapon = IT_HOOK;
		}
	}

	client_setweapon(self.weapon);
	self.impulse = 0;
};

void() ctf_firehook;

void client_attack()
{
	// No attack
	if (!self.button0 || self.maxspeed == 0 || self.movetype == MOVETYPE_NOCLIP)
	{
		return;
	}

	if (self.attack_finished > time)
	{
		return;
	}

	if (gmapn_serverstate == gmapn_serverstate_countdown)
	{
		return;
	}

	// If quaded, play quad sound
	if (self.items & IT_QUAD)
	{
		sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
	}

	makevectors(self.v_angle);
	
	//player_setweapon();

	// Attack with axe
	if (self.weapon == IT_AXE)
	{
		float rnd;

		self.attack_finished = time + getkey(axe_reload);

		sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		if (getkey(axe_new) == 0)
		{
			rnd = random()*4;
			if (rnd < 1)
			{
				player_axea1();
			}
			else if (rnd < 2)
			{
				player_axeb1();
			}
			else if (rnd < 3)
			{
				player_axec1();
			}
			else
			{
				player_axed1();
			}
		}
		else
		{
			if (self.axe_attack == 1)
			{
				player_axeb1();
				self.axe_attack = 2;
			}
			else
			{
				player_axea1();
				self.axe_attack = 1;
			}
		}
	}
	else if (self.weapon == IT_COILGUN)
	{
		player_shot1();
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1();
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1();
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_spike1();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_spike1();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_grenade1();
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
	}
	else if (self.weapon == IT_LIGHTNING_GUN)
	{
		if (self.ammo_cells >= 1 && (self.waterlevel < 2 || self.waterlevel >= 2 && time > self.beam_finished))
		{
			sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		}
		player_lightning1();
	}
	else if (self.weapon == IT_RAILGUN)
	{
		player_railgun1();
	}
	else if (self.weapon == IT_HOOK)
	{
		ctf_firehook();
	}
	else if (self.weapon == IT_PORTALGUN)
	{
#ifdef HAVE_PORTALS
		player_portal1();
#endif
	}
	else
	{
		error("Invalid weapon\n");
	}
	
	// Used by "fairpacks"
	self.lastweap = self.weapon;
};

void client_use()
{
	// If dead, use this as a spawn button
	return;
};

//======================================================================
// client_jump
//
//
//
//======================================================================
void client_jump()
{
	// No jump, set the flag
	if (!self.button2 || !self.maxspeed)
	{
		self.flags = self.flags | FL_JUMPRELEASED;
		return;
	}

	// If dead, use this as a spawn button

	// Swimming player doesn't jump but create bubbles
	if (self.waterlevel >= 2)
	{
		// We aren't done making the previous noise in water
		if (time < self.swim_finished)
		{
			return;
		}

		// Make some swimming noise in water
		if (rint(random()) == 1)
		{
			sound(self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
		}
		else
		{
			sound(self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		// Make the next noise after one second
		self.swim_finished = time + 1;

		return;
	}

	// Not on ground, can't jump
	if (!(self.flags & FL_ONGROUND))
	{
		return;
	}

	// Prevent pogo stick effect, must release button between jumps
	if (!(self.flags & FL_JUMPRELEASED))
	{
		return;
	}

	// Play jump animation
	//player_run();

	// Unset the flag for released jump button
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	// Bug fix
	if (self.velocity_z < 0)
	{
		self.velocity_z = 0;
	}

	// CPMA style double jumping
	if (getkey(game_cpmajump) != 0)
	{
		if (time <= self.jump_finished)
		{
			self.velocity_z = self.velocity_z + 170;
		}
		self.jump_finished = time + 0.4;
	}

	// Play jumping sound
	sound(self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
};

void client_powerups()
{
	if (self.ring_finished && time >= self.ring_finished - 3)
	{
		if (self.ring_time == 0)
		{
			sprintln(self, PRINT_MEDIUM, _("Ring of Shadows magic is fading"));
			sound(self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
		}
		if (time >= self.ring_time)
		{
			stuffcmd(self, "bf\n");
			self.ring_time = time + 1;
		}
	}
	if (self.pent_finished && time >= self.pent_finished - 3)
	{
		if (self.pent_time == 0)
		{
			sprintln(self, PRINT_MEDIUM, _("Protection is almost burned out"));
			sound(self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
		}
		if (time >= self.pent_time)
		{
			stuffcmd(self, "bf\n");
			self.pent_time = time + 1;
		}
	}
	if (self.suit_finished && time >= self.suit_finished - 3)
	{
		if (self.suit_time == 0)
		{
			sprintln(self, PRINT_MEDIUM, _("Air supply in Biosuit expiring"));
			sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
		}
		if (time >= self.suit_time)
		{
			stuffcmd(self, "bf\n");
			self.suit_time = time + 1;
		}
	}
	if (self.quad_finished && time >= self.quad_finished - 3)
	{
		if (self.quad_time == 0)
		{
			sprintln(self, PRINT_MEDIUM, _("Quad Damage is wearing off"));
			sound(self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
		}
		if (time >= self.quad_time)
		{
			stuffcmd(self, "bf\n");
			self.quad_time = time + 1;
		}
	}

	// Remove powerup if time is up
	if (time >= self.ring_finished)
	{
		setmodel(self, "progs/player.mdl");		// Switch to normal model instantly
		self.items = self.items - (self.items & IT_RING);
		self.ring_finished = 0;
	}
	if (time >= self.pent_finished)
	{
		self.items = self.items - (self.items & IT_PENT);
		self.pent_finished = 0;
		self.effects = self.effects - (self.effects & EF_RED);
	}
	if (time >= self.suit_finished)
	{
		self.items = self.items - (self.items & IT_SUIT);
		self.suit_finished = 0;
		self.effects = self.effects - (self.effects & EF_GREEN);
	}
	if (time >= self.quad_finished)
	{
		self.items = self.items - (self.items & IT_QUAD);
		self.quad_finished = 0;
		self.effects = self.effects - (self.effects & EF_BLUE);
	}
	
	if (self.items2 & IT2_RUNE_REGEN)
	{
		if (time > self.runetime)
		{
			if ((self.runetime*2) & 1)
				sound(self, CHAN_BODY, "rune/rune4.wav", 1, ATTN_NORM);
			self.runetime = time + 0.5;
			
			if (self.health < 150)
				self.health = min(150, self.health+5);
			else if (self.armorvalue > 0 && self.armorvalue < 250)
				self.armorvalue = min(250, self.armorvalue+5);
		}
	}
};

void client_content()
{
	if (self.movetype == MOVETYPE_NOCLIP)
	{
		// spectators and dead bodies aren't affected by contents
		return;
	}
	if (self.waterlevel == 0)
	{
		if (self.flags & FL_INWATER)
		{
			// flag is outdated, now outside of water
			self.flags = self.flags - (self.flags & FL_INWATER);
			sound(self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
		}
		return;
	}
	if (!(self.flags & FL_INWATER))
	{
		// flag is outdated, now inside of water
		self.flags = self.flags | FL_INWATER;

		if (gmapn_serverstate == gmapn_serverstate_prewar && self.velocity_z >= -600 && vlen(self.velocity) > 600)
		{
			self.velocity_z = self.velocity_z + 570;
		}

		if (self.watertype == CONTENT_WATER)
		{
			sound(self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		}
		else if (self.watertype == CONTENT_SLIME)
		{
			sound(self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
		}
		else if (self.watertype == CONTENT_LAVA)
		{
			sound(self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		}
	}

	if (self.watertype == CONTENT_SLIME && time > self.damage_finished && time > self.suit_finished)
	{
		self.deathtype = DT_SLIME;
		gmapn_impact(self, world, 4*self.waterlevel, 0);
		self.damage_finished = time + 1;
	}
	if (self.watertype == CONTENT_LAVA && time > self.damage_finished)
	{
		self.deathtype = DT_LAVA;
		gmapn_impact(self, world, 10*self.waterlevel, 0);
		if (time > self.suit_finished)
		{
			self.damage_finished = time + 0.2;
		}
		else
		{
			self.damage_finished = time + 1;
		}
	}
};

//fixme: send to spectators too
void client_update_teaminfo()
{
	float sendlimit = 10;
	
	if (stof(infokey(self, "ti")) <= 0)	//not set or -1, then the user doesn't give a damn about their teammates
		return;
		
	string checkteam = self.teamname;
	for (entity e = world; (e = find(e, classname, "player")); )
	{
		if (e == self)
			continue;
		if (e.teamname != checkteam)
			continue;

		if (sendlimit-- == 0)	//don't spam too much
			break;

		stuffcmdflags(self, STUFFCMD_IGNOREINDEMO, sprintf("//tinfo %g %v %g %g %g\n", num_for_edict(e)-1, e.origin, floor(bound(0, e.health, 999)), floor(bound(0, e.armorvalue, 999)), e.items));
	}
};

void client_update_weaponstats()
{	//FIXME: need a version of this function for when specs switch pov, thanks to the cache thing.
	float fl = 0;
	if (stof(infokey(self, "wpsx")) <= 0)	//not set or -1, then the user doesn't give a damn about their weapon stats. but we can still waste demo sizes with this junk. yay qtv.
		fl = STUFFCMD_DEMOONLY;

	for (int i = 0; i < wnames.length; i++)
	{
		if (self.stats_sent[i] != self.stats_total[i])
			stuffcmdflags(self, fl, sprintf("//wps %g %s %g %g\n", num_for_edict(self)-1, wnames[i], self.stats_total[i], self.stats_hit[i]));
	}
};

void client_pack_touch()
{
	if (other.classname != "player")
	{
		return;
	}

	if (deathmatch == 4)
	{
		other.health += 10;
	}
	else
	{
		ammo_add();
	}

	item_pickup(-1);
};

// Throw a backpack from this player
void client_pack_throw()
{
	entity pack;
	string mdl;

	if (gmapn_serverstate != gmapn_serverstate_playing)
	{
		// Only spawn backpacks during games

		return;
	}

	// Create a backpack
	pack = spawn();
	pack.attenuation = ATTN_NORM;
	pack.channel = CHAN_ITEM;
	pack.classname = "backpack";
	pack.movetype = MOVETYPE_TOSS;
	pack.noise = "weapons/lock4.wav";
	pack.solid = SOLID_TRIGGER;
	pack.touch = client_pack_touch;
	
	pack.nextthink = time + 60*2;
	pack.think = (void()){remove(self);};

	//determine the weapon to put in the backpack
	switch(getkey(game_fairpacks))
	{
	default:
	case 0:	//standard behaviour
		pack.items = self.weapon;
		break;
	case 1:	//fairpacks
		pack.items = self.lastweap?:self.weapon;
		break;
	case 2: //unfair packs
		if (self.attack_finished > time && self.lastweap)
			pack.items = self.lastweap;
		else
			pack.items = self.weapon;
		break;
	}

	// Insert ammunition
	if (self.ammo_shells > 0)
	{
		pack.items = pack.items | IT_SHELLS;
		pack.ammo_shells = self.ammo_shells;
	}
	if (self.ammo_nails > 0)
	{
		pack.items = pack.items | IT_NAILS;
		pack.ammo_nails = self.ammo_nails;
	}
	if (self.ammo_rockets > 0)
	{
		pack.items = pack.items | IT_ROCKETS;
		pack.ammo_rockets = self.ammo_rockets;
	}
	if (self.ammo_cells > 0)
	{
		pack.items = pack.items | IT_CELLS;
		pack.ammo_cells = self.ammo_cells;
	}
	if (self.ammo_heads > 0)
	{
		pack.ammo_heads = self.ammo_heads;
		self.ammo_heads = 0;
	}

	
	// Set the backpack model to the weapon it contains
	if (pack.items & IT_ROCKET_LAUNCHER)
	{
		mdl = "progs/g_rock2.mdl";
		pack.netname = "Rocket Launcher";
	}
	else if (pack.items & IT_LIGHTNING_GUN)
	{
		mdl = "progs/g_light.mdl";
		pack.netname = "Lightning Gun";
	}
	else if (pack.items & IT_GRENADE_LAUNCHER)
	{
		mdl = "progs/g_rock.mdl";
		pack.netname = "Grenade Launcher";
	}
	else if (pack.items & IT_SUPER_NAILGUN)
	{
		mdl = "progs/g_nail2.mdl";
		pack.netname = "Super Nailgun";
	}
	else if (pack.items & IT_NAILGUN)
	{
		mdl = "progs/g_nail.mdl";
		pack.netname = "Nailgun";
	}
	else if (pack.items & IT_SUPER_SHOTGUN)
	{
		mdl = "progs/g_shot.mdl";
		pack.netname = "Super Shotgun";
	}
	//FIXME: use ammo boxes?
	else
	{	//other weapons don't have pickup models.
		mdl = "progs/backpack.mdl";
		pack.items = 0;
	}

	
	// Set the backpack model
	if (getkey(game_visiblepacks) != 1)
		mdl = "progs/backpack.mdl";
	setmodel(pack, mdl);

	setorigin(pack, self.origin);
	setsize(pack, '-16 -16 0', '16 16 56');
	
	makevectors(self.v_angle);
	pack.velocity_x = -100 * v_forward_x;
	pack.velocity_y = -100 * v_forward_y;
	pack.velocity_z = 300;
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void NextLevel()
{
	entity o;

	if (nextmap != "")
		return; // already done

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & SV_EPISODE1))
		{
			mapname = "e1m1";
			serverflags = serverflags | SV_EPISODE1;
		}
		else if (!(serverflags & SV_EPISODE2))
		{
			mapname = "e2m1";
			serverflags = serverflags | SV_EPISODE2;
		}
		else if (!(serverflags & SV_EPISODE3))
		{
			mapname = "e3m1";
			serverflags = serverflags | SV_EPISODE3;
		}
		else if (!(serverflags & SV_EPISODE4))
		{
			mapname = "e4m1";
			serverflags &= ~(SV_EPISODE1|SV_EPISODE2|SV_EPISODE3|SV_EPISODE4);
		}
 
		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");
		if (!o || mapname == "start")
		{		// go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

//============================================================================

void PlayerDeathThink()
{
	float forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

	if (time > self.death_finished)
	{
		self.deadflag = DEAD_RESPAWNABLE;
	}

	// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}
	
	if (gmapn_gamemode == GM_LASTMANSTANDING || gmapn_gamemode == GM_DA)
		return; //last man standing does not allow respawning, nor do duel arena.  FIXME: make spectator
	if (gmapn_gamemode == GM_FREEZETAG && self.watertype != CONTENT_LAVA && self.watertype != CONTENT_SLIME)
		return;	//in freezetag, players can't respawn themselves, but rather are respawned by other players (unless they died or were knocked into lava/slime/void).
	if (gmapn_gamemode == GM_HIDENSEEK)
	{
		if (self.teamname == gmapn_team_hiders)
			self.found = TRUE; //don't message anything if killed by lava or something
		return; // don't allow found players to respawn
	}
	// wait for any button down
	if (time < self.death_finished && !self.button2 && !self.button1 && !self.button0)
		return;
		
	player_headhunter_respawned();

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	client_spawn(FALSE);
};

void client_obituary(entity targ, entity attacker)
{
	float rnum;
	string attackerteam, targteam;

	rnum = random();
	//ZOID 12-13-96: self.team doesn't work in QW.	Use keys
	attackerteam = attacker.teamname;
	targteam = targ.teamname;

	if (targ.classname == "player")
	{
		if (deathmatch > 3) 
		{
			if (targ.deathtype == DT_DISCHARGE)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s electrocutes himself.\n"), targ.netname));
				gmapn_suicidefrags(targ, -1);
				return;
			}
		}

		if (deathmatch == DMM_MIDAIR)
		{
			float midairheight = targ.origin_z - attacker.origin_z;
			
			if (targ.deathtype == DT_ROCKET && midairheight > 190)
			{

				if (midairheight > 900)
				{
					bprint (PRINT_MEDIUM, sprintf(_("%s got a DIAMOND midair.\n"), attacker.netname));
					attacker.stats_midair[M_DIAMOND]++;
					gmapn_scorefrags(attacker, targ, +8);
					return;
				}
				if (midairheight > 500)
				{
					bprint (PRINT_MEDIUM, sprintf(_("%s got a GOLD midair.\n"), attacker.netname));
					attacker.stats_midair[M_GOLD]++;
					gmapn_scorefrags(attacker, targ, +4);
					return;
				}
				if (midairheight > 380)
				{
					bprint (PRINT_MEDIUM, sprintf(_("%s got a SILVER midair.\n"), attacker.netname));
					attacker.stats_midair[M_SILVER]++;
					gmapn_scorefrags(attacker, targ, +2);
					return;
				}
				bprint (PRINT_MEDIUM, sprintf(_("%s got a midair.\n"), attacker.netname));
				attacker.stats_midair[M_MIDAIR]++;
				gmapn_scorefrags(attacker, targ, +1);
				return;
			}
		}

		if (targ.deathtype == DT_TEAMREFLECT)
		{
			bprint (PRINT_MEDIUM,sprintf(_("%s didn't understand the concept of a team\n"), targ.netname));

			gmapn_suicidefrags(targ, -1);
			logfrag (targ, targ);
			return;
		}

		
		if (targ.deathtype == DT_TELEFRAG)
		{
			bprint (PRINT_MEDIUM,sprintf(_("%s was telefragged by %s\n"), targ.netname, attacker.netname));
			logfrag (attacker, targ);

			gmapn_scorefrags(attacker, targ, +1);
			return;
		}

		if (targ.deathtype == DT_TELEFRAG_PENT)
		{
			bprint (PRINT_MEDIUM,sprintf(_("Satan's power deflects %s's telefrag\n"), targ.netname));

			gmapn_suicidefrags(targ, -1);
			logfrag (targ, targ);
			return;
		}

		// double 666 telefrag (can happen often in deathmatch 4)
		if (targ.deathtype == DT_TELEFRAG_PENT_BOTH) 
		{
			bprint (PRINT_MEDIUM,sprintf(_("%s was telefragged by %s's Satan's power\n"), targ.netname, attacker.netname));
			gmapn_suicidefrags(targ, -1);
			logfrag (targ, targ);
			return;
		}
	

		if (targ.deathtype == DT_SQUISH)
		{
			if (teamplay && targteam == attackerteam && attackerteam != "" && targ != attacker)
			{
				logfrag (attacker, attacker);
				gmapn_teamkillfrags(attacker, targ, -1);
				bprint (PRINT_MEDIUM,sprintf(_("%s squished a teammate\n"), attacker.owner.netname));
				return;
			}
			else if (attacker.classname == "player" && attacker != targ)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s squishes %s\n"), attacker.netname, targ.netname));
				logfrag (attacker, targ);
				gmapn_scorefrags(attacker, targ, +1);
				return;
			}
			else
			{
				logfrag (targ, targ);
				gmapn_suicidefrags(targ, -1);
				bprint (PRINT_MEDIUM,sprintf(_("%s was squished\n"), targ.netname));
				return;
			}
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				if (targ.deathtype == DT_SUICIDE)
				{
					logfrag (attacker, attacker);
					gmapn_suicidefrags(targ, -2);
					bprint (PRINT_MEDIUM,sprintf(_("%s suicides\n"), targ.netname));
				}
				else
				{
					logfrag (attacker, attacker);
					attacker.frags = attacker.frags - 1;
					if (targ.deathtype == DT_GRENADE)
					{
						bprint (PRINT_MEDIUM,sprintf(_("%s tries to put the pin back in\n"), targ.netname));
					}
					else if (targ.deathtype == DT_ROCKET)
					{
						bprint (PRINT_MEDIUM,sprintf(_("%s becomes bored with life\n"), targ.netname));
					}
					else if (targ.deathtype == DT_DISCHARGE)
					{
						if (targ.watertype == CONTENT_SLIME)
						{
							bprint (PRINT_MEDIUM,sprintf(_("%s discharges into the slime\n"), targ.netname));
						}
						else if (targ.watertype == CONTENT_LAVA)
						{
							bprint (PRINT_MEDIUM,sprintf(_("%s discharges into the lava\n"), targ.netname));
						}
						else
						{
							bprint (PRINT_MEDIUM,sprintf(_("%s discharges into the water\n"), targ.netname));
						}
					}
					else if (targ.deathtype == DT_BULLET || targ.deathtype == DT_SUPER_BULLET || targ.deathtype == DT_COILGUN)	//various guns now allow you to suicide by shooting yourself through a portal.
						bprint (PRINT_MEDIUM,sprintf(_("%s wasn't thinking with portals\n"), targ.netname));
					else
					{
						bprint (PRINT_MEDIUM,sprintf(_("%s becomes bored with life\n"), targ.netname));
					}
				}
				return;
			}
			else if (teamplay && (targteam == attackerteam) &&
				(attackerteam != "") )
			{
				if (rnum < 0.25)
					bprint (PRINT_MEDIUM,sprintf(_("%s mows down a teammate\n"), attacker.netname));
				else if (rnum < 0.50)
					bprint (PRINT_MEDIUM,sprintf(_("%s checks his glasses\n"), attacker.netname));
				else if (rnum < 0.75)
					bprint (PRINT_MEDIUM,sprintf(_("%s gets a frag for the other team\n"), attacker.netname));
				else
					bprint (PRINT_MEDIUM,sprintf(_("%s loses another friend\n"), attacker.netname));
				gmapn_teamkillfrags(attacker, targ, -1);
				//ZOID 12-13-96:  killing a teammate logs as suicide
				logfrag (attacker, attacker);
				return;
			}
			else
			{
				logfrag (attacker, targ);
				gmapn_scorefrags(attacker, targ, +1);

				rnum = attacker.weapon;
				if (targ.deathtype == DT_NAIL)
					bprint (PRINT_MEDIUM,sprintf(_("%s was nailed by %s\n"), targ.netname, attacker.netname));
				else if (targ.deathtype == DT_SUPER_NAIL)
					bprint (PRINT_MEDIUM,sprintf(_("%s was punctured by %s\n"), targ.netname, attacker.netname));
				else if (targ.deathtype == DT_GRENADE)
				{
					if (targ.health < -40)
						bprint (PRINT_MEDIUM,sprintf(_("%s was gibbed by %s's grenade\n"), targ.netname, attacker.netname));
					else
						bprint (PRINT_MEDIUM,sprintf(_("%s eats %s's pineapple\n"), targ.netname, attacker.netname));
				}
				else if (targ.deathtype == DT_ROCKET)
				{
					if (attacker.quad_finished > 0 && targ.health < -40)
					{
						rnum = random();
						if (rnum < 0.3)
							bprint (PRINT_MEDIUM,sprintf(_("%s was brutalized by %s's quad rocket\n"), targ.netname, attacker.netname));
						else if (rnum < 0.6)
							bprint (PRINT_MEDIUM,sprintf(_("%s was smeared by %s's quad rocket\n"), targ.netname, attacker.netname));
						else
							bprint (PRINT_MEDIUM,sprintf(_("%s rips %s a new one\n"), attacker.netname, targ.netname));
					}
					else
					{
						if (targ.health < -40)
							bprint (PRINT_MEDIUM,sprintf(_("%s was gibbed by %s's rocket\n"), targ.netname, attacker.netname));
						else
							bprint (PRINT_MEDIUM,sprintf(_("%s rides %s's rocket\n"), targ.netname, attacker.netname));
					}
				}
				else if (rnum == IT_AXE)
					bprint (PRINT_MEDIUM,sprintf(_("%s was ax-murdered by %s\n"), targ.netname, attacker.netname));
				else if (rnum == IT_SHOTGUN)
					bprint (PRINT_MEDIUM,sprintf(_("%s chewed on %s's boomstick\n"), targ.netname, attacker.netname));
				else if (rnum == IT_SUPER_SHOTGUN)
					bprint (PRINT_MEDIUM,sprintf(_("%s ate 2 loads of %s's buckshot\n"), targ.netname, attacker.netname));
				else if (rnum == IT_LIGHTNING_GUN)
				{
					if (attacker.waterlevel > 1)
						bprint (PRINT_MEDIUM,sprintf(_("%s accepts %s's discharge\n"), targ.netname, attacker.netname));
					else
						bprint (PRINT_MEDIUM,sprintf(_("%s accepts %s's shaft\n"), targ.netname, attacker.netname));
				}
				else if (rnum == IT_RAILGUN)
					bprint (PRINT_MEDIUM,sprintf(_("%s ate %s railgun slug\n"), targ.netname, attacker.netname));
				else if (rnum == IT_COILGUN)	//FIXME: add more variants.
					bprint (PRINT_MEDIUM,sprintf(_("%s was coiled by %s\n"), targ.netname, attacker.netname));
				else
					bprint (PRINT_MEDIUM,sprintf(_("%s killed %s with magic or something\n"), attacker.netname, targ.netname));
			}
			return;
		}
		else
		{
			logfrag (targ, targ);
			gmapn_suicidefrags(targ, -1);

			if (targ.deathtype == DT_WATER)
			{
				if (random() < 0.5)
					bprint (PRINT_MEDIUM,sprintf(_("%s sleeps with the fishes\n"), targ.netname));
				else
					bprint (PRINT_MEDIUM,sprintf(_("%s sucks it down\n"), targ.netname));
				return;
			}
			else if (targ.deathtype == DT_SLIME)
			{
				if (random() < 0.5)
					bprint (PRINT_MEDIUM,sprintf(_("%s gulped a load of slime\n"), targ.netname));
				else
					bprint (PRINT_MEDIUM,sprintf(_("%s can't exist on slime alone\n"), targ.netname));
				return;
			}
			else if (targ.deathtype == DT_LAVA)
			{
				if (targ.health < -15)
				{
					bprint (PRINT_MEDIUM,sprintf(_("%s burst into flames\n"), targ.netname));
					return;
				}
				if (random() < 0.5)
					bprint (PRINT_MEDIUM,sprintf(_("%s turned into hot slag\n"), targ.netname));
				else
					bprint (PRINT_MEDIUM,sprintf(_("%s visits the Volcano God\n"), targ.netname));
				return;
			}

			if (targ.deathtype == DT_EXPLOSION)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s blew up\n"), targ.netname));
				return;
			}
			if (targ.deathtype == DT_FALL)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s fell to his death\n"), targ.netname));
				return;
			}
			if (targ.deathtype == DT_NAIL || targ.deathtype == DT_SUPER_NAIL)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s was spiked\n"), targ.netname));
				return;
			}
			if (targ.deathtype == DT_LASER)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s was zapped\n"), targ.netname));
				return;
			}
			if (targ.deathtype == DT_LAVABALL)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s ate a lavaball\n"), targ.netname));
				return;
			}
			if (targ.deathtype == DT_EXIT)
			{
				bprint (PRINT_MEDIUM,sprintf(_("%s tried to leave\n"), targ.netname));
				return;
			}

			bprint (PRINT_MEDIUM,sprintf(_("%s died\n"), targ.netname));
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void PlayerPreThink()
{
	BotPreFrame();

	// Check impulses
	client_impulses();

	if (intermission_running)
	{
		if (gmapn_serverstate != gmapn_serverstate_intermission)
		{
			gmapn_game_end();
		}
		IntermissionThink();   // otherwise a button could be missed between
		return;									// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;			// intermission or finale

	makevectors (self.v_angle);				// is this still used

	self.deathtype = DT_NULL;

	client_content();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return; // dying, so do nothing

	client_attack();

	if (self.button2)
	{
		client_jump();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	if (self.fallspeed == 0)
		self.flags = self.flags | FL_ONGROUND;
	else
		self.flags = self.flags - (self.flags & FL_ONGROUND);

// teleporters can force a non-moving pause time		
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if(time > self.attack_finished && !client_weaponokay())
	{
		client_setweapon(client_bestweapon());
		//player_setweapon();
	}
};

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void PlayerPostThink()
{
	BotPostFrame();
	self.latency = time;
	if (self.view_ofs == '0 0 0')
		return;			// intermission or finale
	if (self.deadflag)
		return;

// check to see if player landed and play landing sound 
	if ((self.fallspeed < -300) && (self.flags & FL_ONGROUND) )
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.fallspeed < -650)
		{
			self.deathtype = DT_FALL;
			gmapn_impact(self, world, 5, 0);
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
	}

	self.fallspeed = self.velocity_z;

	client_powerups();

	gmapn_detect_fast_angles();
	
	
	if (self.teaminfo_update < time)
	{
		client_update_teaminfo();
		client_update_weaponstats();
		self.teaminfo_update = time + 2;
	}
	if (!gmapn_display_rules())
	{
		// FIXME: place in a think function instead
		if (gmapn_serverstate == gmapn_serverstate_prewar)
		{
			makevectors(self.v_angle);
			traceline(self.origin + '0 0 16', self.origin + v_forward * 2048, FALSE, self);
			if (trace_fraction < 1.0 && (trace_ent.flags & FL_CLIENT))
			{
				gmapn_centerprint(self, trace_ent.netname, 0.5);
			}
		}
	}
	
	if (gmapn_gamemode == GM_FREEZETAG)
	{
		if (self.thawplayer)
		{
			if (!self.thawplayer.deadflag || !self.thawplayer.solid)
				self.thawplayer = world;	//they're already alive, or dropped.
			else if (vlen(self.origin - self.thawplayer.origin) > 128)
			{	//we moved too far away from them.
				centerprint(self.thawplayer, self.netname, " leaves you for dead");
				self.thawplayer = world;
				centerprint(self, "Thawing aborted");
			}
			else if (self.thawtime < time)
			{
				other = self;
				self = self.thawplayer;
				other.thawplayer = world;
				te_teleport(self.origin);
				SetNewParms();
				client_spawn(getkey(freezetag_thawinplace));
				centerprint(self, "Resurrected by ", other.netname);
				self = other;
			}
		}
	}
	else if (gmapn_gamemode == GM_DOMINATION)
	{
		if (self.thawplayer)
		{
			if (vlen(self.origin - self.thawplayer.origin) > 128)
			{	//we moved too far away from them.
				self.thawplayer = world;
				centerprint(self, "Capture aborted");
			}
			else if (self.thawplayer.teamname == self.teamname)
			{
				self.thawplayer = world;	//someone else capped it, and we were helping.
				self.frags += getkey(domination_capassist);
				centerprint(self, "Capture assist!");
			}
			else if (self.thawtime < time)
			{
				self.thawplayer.teamname = self.teamname;
				bprint(PRINT_HIGH, self.netname, " captured ", self.thawplayer.netname?:"a control point", "\n");
				self.thawplayer.nextthink = time + getkey(domination_pointinterval);
				self.thawplayer.pflags = PFLAGS_CORONA;
				self.thawplayer.light_lev = 300;
				if (self.teamname == "red")
					self.thawplayer.color = self.thawplayer.colormod = '1 0 0';
				else if (self.teamname == "blue")
					self.thawplayer.color = self.thawplayer.colormod = '0 0 1';
				else
					self.thawplayer.color = self.thawplayer.colormod = '0 1 0';
				
				self.thawplayer = world;
				centerprint(self, "Control Point Captured!");
				self.frags += getkey(domination_cap);
			}
			else
				centerprint(self, "Capturing: ", ftos(ceil(self.thawtime - time)));
		}
	}
};

//======================================================================
// ClientKill
//
// Received a kill-command from a client. Usually this means that the
// player suicides. Modify this function if you want to control what
// happens if someone sends a kill-command.
//
//======================================================================
void ClientKill()
{
	if (gmapn_serverstate != gmapn_serverstate_prewar)
	{	//FIXME: in GT_FREEZETAG a player could use this to get free health by getting a player to res them.
		self.deathtype = DT_SUICIDE;
		// FIXME: should gmapn_kill require 2 arguments or 1 + setting self.enemy before calling it?
		self.enemy = self;
		gmapn_kill(self, self);
	}
	else
	{
		respawn_living();
	}
};

/*
===========
ClientConnect

called when a player connects to a server
============
*/
void ClientConnect()
{
	dbgprintln("=== ClientConnect() ===");
	self.teamname = infokey(self, "team");

	ClientInRankings();
	
	if (clienttype(self) == CLIENTTYPE_BOT && gmapn_serverstate == gmapn_serverstate_prewar)
		dropclient(self);
	else
	{
		bprint(PRINT_HIGH, sprintf(_("%s entered the game\n"), self.netname));
	}

	self.is_fully_connected = 1;

	gmapn_aliasstuffer_start(self);
	
	if (intermission_running)
	{
		SendIntermissionToPlayer(self);
	}

	gmapn_sql_welcome();

	self.connectedtime = time;
	self.challengertime = time;	//make sure we can't bypass duel queues by just reconnecting
};

//======================================================================
// PutClientInServer
//
// A client requests to enter the current map. This is called whenever a
// player enters a map.
//
//======================================================================
void PutClientInServer()
{
	dbgprintln("=== PutClientInServer() ===");

	// Standard attributes for the client
	self.classname = "player";			// The client is a player, always
	self.flags = FL_CLIENT;				// This is a client
	self.max_health = 100;				// Maximum health a player can have
	self.max_megahealth = 250;			// Maximum megahealth a player can have
	self.max_ammo_shells = 100;			// Maximum shells a player can have
	self.max_ammo_nails = 200;			// Maximum nails a player can have
	self.max_ammo_rockets = 100;			// Maximum rockets a player can have
	self.max_ammo_cells = 100;			// Maximum cells a player can have;
	self.my_spawn = world;				// Has not selected a spawn yet
	self.vote = VOTE_NULL;					// Start with no vote
	self.lastroundnum = -1;
	for (float i = 0; i < stats_hit.length; i++)
	{
		self.stats_hit[i] = 0;
		self.stats_total[i] = 0;
	}
	for (float i = 0; i < stats_midair.length; i++)
	{
		self.stats_midair[i] = 0;
	}

	gmapn_print_version();
	if (gmapn_reconnected_player(self) == TRUE)
		bprintln(PRINT_HIGH, sprintf("%s reconnects with %s frags", self.netname, ftos(self.frags)));

	gmapn_rules_handleconnect();

	client_spawn(FALSE);
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void ClientDisconnect()
{
	entity e;
	
	// Let everyone else know
	if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		bprint(PRINT_HIGH, sprintf(_("%s left the game with %s frags\n"), self.netname, ftos(self.frags)));
		gmapn_disconnected_player(self);
	}
	else if (clienttype(self) != CLIENTTYPE_BOT)
	{
		bprint(PRINT_HIGH, sprintf(_("%s left the game\n"), self.netname));
	}
	
	if (gmapn_gamemode == GM_CTF || gmapn_gamemode == GM_1FCTF)
		ctf_player_died();

	sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);

	// Nullify disconnected player
	self.classname = 0;
	self.movetype = MOVETYPE_TOSS; // FIXME: why not MOVETYPE_NONE?
	self.nextthink = 0;
	self.solid = SOLID_NOT;
	self.think = 0;
	self.touch = 0;
	self.model = 0;
	self.modelindex = 0;
	ClientDisconnected();

	gmapn_mapvote_removevote();

	if (gmapn_serverstate == gmapn_serverstate_prewar)
	{
		gmapn_mapvote_countvotes();
		gmapn_rpickup_countvotes();
	}
	else if (gmapn_serverstate == gmapn_serverstate_countdown)
	{
		gmapn_game_endpregamecountdown();
	}

	//clear some stuff out
	if (self == gmapn_gamemaster)
		gmapn_gamemaster = world;
	if (self == gmapn_monarchofthemound)
	{
		gmapn_monarchofthemound = world;
		cvar_set("teamplay", "0");	//need to clear teamplay to rework clientside enemyskin forcing so everyone appears as a valid target.
		
	}

	/* Stop match if no players are left */

	for (e = find(world, classname, "player"); e; e = find(e, classname, "player"))
	{
		if (clienttype(e) == CLIENTTYPE_REAL)
			break;
	}

	if (clienttype(e) != CLIENTTYPE_REAL && clienttype(self) != CLIENTTYPE_BOT)
	{
		if (gmapn_serverstate == gmapn_serverstate_playing)
		{
			bprint(PRINT_HIGH, _("All players gone, aborting match.\n"));
			gmapn_game_end();
		}

		gmapn_reset_starttimer();
	}
};

