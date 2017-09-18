// FIXME: these are the current unimplemented entity spawn functions

/*
========================================================================

	Functions called from C

========================================================================
*/

//======================================================================
// air_bubbles
//
//
//
//======================================================================
void air_bubbles()
{
	// Dunno
	remove(self);
};

//======================================================================
// ambient_comp_hum
//
//
//
//======================================================================
void ambient_comp_hum()
{
	self.noise = "ambience/comp1.wav";
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, 1, ATTN_STATIC);
};

//======================================================================
// ambient_drip
//
//
//
//======================================================================
void ambient_drip()
{
	self.noise = "ambience/drip1.wav";
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, 0.5, ATTN_STATIC);
};

//======================================================================
// ambient_drone
//
//
//
//======================================================================
void ambient_drone()
{
	self.noise = "ambience/drone6.wav";
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, 0.5, ATTN_STATIC);
};

//======================================================================
// ambient_suck_wind
//
//
//
//======================================================================
void ambient_suck_wind()
{
	self.noise = "ambience/suck1.wav";
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, 1, ATTN_STATIC);
};

//======================================================================
// ambient_swamp1
//
//
//
//======================================================================
void ambient_swamp1()
{
	self.noise = "ambience/swamp1.wav";
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, 0.5, ATTN_STATIC);
};

//======================================================================
// ambient_swamp2
//
//
//
//======================================================================
void ambient_swamp2()
{
	self.noise = "ambience/swamp2.wav";
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, 0.5, ATTN_STATIC);
};

//======================================================================
// event_lightning
//
//
//
//======================================================================
/*void event_lightning()
{
	// e1m7 lightning?
	remove(self);
};
*/

//======================================================================
// func_bossgate
//
//
//
//======================================================================
void func_bossgate()
{
	float eps = SV_EPISODE1 | SV_EPISODE2 | SV_EPISODE3 | SV_EPISODE4;
	if (coop && (serverflags & eps) == eps)
	{
		// All episodes are done, the gate is removed
		remove(self);
		return;
	}
	// Still more episodes to go, the gate becomes solid
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_NONE;
	setmodel(self, self.model);
};

//======================================================================
// func_episodegate
//
//
//
//======================================================================
void func_episodegate()
{
	if (coop && (serverflags & self.spawnflags))
	{	//these ents block you if you've already progressed beyond them.
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
		setmodel(self, self.model);
	}
	else
		remove(self);
};

//======================================================================
// func_illusionary
//
//
//
//======================================================================
void func_illusionary()
{
	self.angles = '0 0 0';
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	setorigin(self, self.origin);
	setmodel(self, self.model);
};

//======================================================================
// func_ladder
//
//
//
//======================================================================
void func_ladder()
{
	if (!gmapn_qsg_has_fte_solid_ladder)
	{
		remove(self);
	}
	else
	{
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_LADDER;
		setorigin(self, self.origin);
		setmodel(self, self.model);
		self.modelindex = 0;
		self.model = "";
	}
};

//======================================================================
// func_wall
//
//
//
//======================================================================
void func_wall()
{
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin(self, self.origin);
	setmodel(self, self.model);
};

//======================================================================
// air_bubbles
//
//
//
//======================================================================
void info_intermission()
{
	self.angles = self.mangle; // So C can get at it
};

//======================================================================
// info_null
//
// Mostly used as a positional targeting for spotlights.
//
//======================================================================
void info_null()
{
	remove(self);
};

//======================================================================
// air_bubbles
//
//
//
//======================================================================
void info_player_deathmatch()
{
	// Standard orientation for deathmatch spawns
	self.origin = self.origin + '0 0 1';

	// This is meant to be a fix for setting all spawn points
	// directly on the ground, with no airbourne positioning at all
	if (getkey(spawn_drop) != 0)
	{
		self.nextthink = self.ltime + 0.3;
		self.think = gmapn_dropspawn;
	}

	// Spawn weight
	self.cnt = SP_WEIGHT;
};

void info_player_team1()
{
	info_player_deathmatch();
};
void info_player_team2()
{
	info_player_deathmatch();
};
void info_player_coop()
{
	if (coop)
		info_player_deathmatch();
	else
		remove(self);
};

//======================================================================
// air_bubbles
//
//
//
//======================================================================
void() info_teleport_destination;
void info_player_start()
{
	if (getkey(game_exittele) != 0)
	{
		dprintln("Converting info_player_start");
		self.classname = "info_teleport_destination";
		self.targetname = "start";
		info_teleport_destination();
	}
};

//======================================================================
// air_bubbles
//
//
//
//======================================================================
void info_player_start2()
{
	// Coop
	remove(self);
};

//======================================================================
// air_bubbles
//
//
//
//======================================================================
void info_teleport_destination()
{
	// Standard orientation for teleporter spawns
	self.origin = self.origin + '0 0 27';
};

//======================================================================
// light
//
//
//
//======================================================================
void light_use()
{
	if (self.spawnflags & LIGHT_START_OFF)
	{
		lightstyle(self.style, "a");
		self.spawnflags -= LIGHT_START_OFF;
	}
	else
	{
		lightstyle(self.style, "m");
		self.spawnflags += LIGHT_START_OFF;
	}
};

void light()
{
	if (!self.targetname)
	{
		// Non-triggered lights are safe to remove

		remove(self);

		return;
	}

	self.use = light_use;

	light_use();
};

//======================================================================
//
//
//
//======================================================================
void light_flame_large_yellow()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void light_flame_small_white()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void light_flame_small_yellow()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void light_fluoro()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void light_fluorospark()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void light_globe()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void light_torch_small_walltorch()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void misc_explobox()
{
	self.health = 20;						// Damage needed to explode
	self.solid = SOLID_BBOX;				// Solid box
	self.takedamage = DAMAGE_EXPLODE;		// It can be fired at

	precache_model("maps/b_explob.bsp");	// Large exploding box
	precache_sound("weapons/r_exp3.wav");	// Explosion
	setmodel(self, "maps/b_explob.bsp");	// Set the model
	setsize(self, '0 0 0', '32 32 64');		// This is large box size

	item_drop();

	self.movetype = MOVETYPE_NONE;			// Doesn't move at all
};

//======================================================================
//
//
//
//======================================================================
void misc_explobox2()
{
	self.health = 20;						// Damage needed to explode
	self.movetype = MOVETYPE_NONE;			// Doesn't move at all
	self.solid = SOLID_BBOX;				// Solid box
	self.takedamage = DAMAGE_EXPLODE;		// It can be fired at

	precache_model("maps/b_exbox2.bsp");	// Small exploding box
	precache_sound("weapons/r_exp3.wav");	// Explosion
	setmodel(self, "maps/b_exbox2.bsp");	// Set the model
	setsize(self, '0 0 0', '32 32 32');		// This is small box size

	item_drop();
};

//======================================================================
//
//
//
//======================================================================
void misc_fireball()
{
	precache_model("progs/lavaball.mdl");	// Lava ball
	self.think = (void())
	{
		self.nextthink = time + random(3,8);
		other = spawn();
		setmodel(other, "progs/lavaball.mdl");	// Set the model
		setsize(other, '0 0 0', '0 0 0');	// This is lava ball size
		other.classname = "fireball";		// The killing identifier
		other.solid = SOLID_TRIGGER;		// Can be touched and walked through
		other.movetype = MOVETYPE_TOSS;		// Just flies trough the air if a speed is set
		other.velocity = randomv([-50,-50,self.speed], [50,50,self.speed+200]);
		setorigin(other, self.origin);
		other.nextthink = time + 5;

//		other.traileffectnum = particleeffectnum("tr_lavaball");

		other.think = (void())
		{
			remove(self);
		};
		other.touch = (void())
		{
			if (other.takedamage)
			{
				other.deathtype = DT_LAVABALL;
				gmapn_impact(other, self, 20, 1);
			}
			remove(self);
		};
	};
	self.nextthink = time + random(1,5);
	if (!self.speed)
		self.speed = 1000;
};

//======================================================================
//
//
//
//======================================================================
/*
void path_corner()
{
	// Used by trains

	self.solid = SOLID_NOT;
};
*/
//======================================================================
//
//
//	FIXME: these are often used for void-zones.
//======================================================================
void trigger_hurt_touch()
{
	gmapn_impact(other, world, self.dmg, 1.0);
}

void trigger_hurt()
{
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	setorigin(self, self.origin);
	setmodel(self, self.model);
	self.modelindex = 0;
	self.model = "";
	self.touch = trigger_hurt_touch;
}

//======================================================================
//
//
//
//======================================================================
void trigger_monsterjump()
{
	remove(self);
};

//======================================================================
//
//
//
//======================================================================
void trigger_push_touch()
{
	float  PUSH_ONCE = 1;

	if (other.classname != "player" && other.classname != "grenade")
	{
		return;
	}
	if (other.movetype == MOVETYPE_FLY || other.movetype == MOVETYPE_NOCLIP)
		return;	//don't fuck with player velocities if they're cheating

	if (other.classname == "player")
	{
		if (other.fly_sound < time)
		{
			other.fly_sound = time + 1.5;
			gmapn_sound(other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM, 0);
		}
	}

	if (self.enemy)	//q3-style jumppad, fling the player at the target
	{
		vector vel = self.enemy.origin-other.origin;
		float ftime = sqrt( vel_z / ( 0.5 * autocvar_sv_gravity ) );
		vel /= ftime;
		vel_z = ftime * autocvar_sv_gravity;
		other.velocity = vel;
	}
	else
		other.velocity = other.velocity * 0.1 + self.speed * self.movedir * 10;

	if (self.spawnflags & PUSH_ONCE)
	{
		remove(self);
	}
};

void trigger_push_link()
{
	self.enemy = find(world, targetname, self.target);
};

void trigger_push()
{
	gmapn_id_angles_sucks();

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	setmodel(self, self.model);
	setorigin(self, self.origin);
	self.modelindex = 0;
	self.model = "";
	precache_sound("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (!self.speed)
		self.speed = 1000;

	if (self.target != "")
	{
		self.think = trigger_push_link;
		self.nextthink = time + 0.1;
	}
};

//======================================================================
//
//
//
//======================================================================
void trigger_relay()
{
	self.use = usetargets;
};

//======================================================================
//
//
//
//======================================================================
void trigger_setskill()
{
	remove(self);
};

/*
========================================================================

	Functions not called from C

========================================================================
*/
