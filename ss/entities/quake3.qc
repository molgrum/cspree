//file to emulate some q3 entities, so that we can (mostly) play on q3 maps too.
//some q3 ents conflict with q1 field names, so I'm just going to use the spawnfunc_ thing for all of them.
//FIXME: ammo/health items are off-center in quake, but not in q3. other bbox sizes are different. this results in lots of things dropping out of the world.
//FIXME: spawnflag&1 == suspended for q3 items (don't confuse with rotten health)

void() item_flag_team1,item_flag_team2;

void() spawnfunc_target_delay = {self.use = usetargets;};	//triggers after a delay.
void() spawnfunc_target_relay = {self.use = usetargets;};	//like trigger_relay, except with ctf filters. spawnflags&1=red team(1) only, &2=blueteam(2) only, &4=trigger only one target
//void() spawnfunc_target_kill = {remove(self);};	//gibs the activator. not sure this is actually used anywhere
void() spawnfunc_target_print = {self.use = (void()){if (self.spawnflags & 4)centerprint(activator, self.message);/*else if (spawflags&1)red; else if (2) blue; else centerprint(world, self.message);*/};};
void() spawnfunc_target_location = {remove(self);};	//for UI, to show areas, apparently, for large/team maps. QW does this purely clientside, which is stupid, but that's the convention.
void() spawnfunc_target_position = {};			//like info_notnull, typically target position for jumppads.
void() spawnfunc_target_speaker = {remove(self);};	//plays a sound
void() spawnfunc_target_remove_powerups = {remove(self);};//remove ctf flags, quad, pent, etc.
void() spawnfunc_target_give = {remove(self);};		//on trigger, simulates touch events on targets to give the activator each targetted item. targetted item will not respawn.
void() spawnfunc_func_timer = {remove(self);};		//repeatedly triggers.
void() spawnfunc_info_spectator_start = {remove(self);};
void() spawnfunc_info_camp = {remove(self);};		//campsite hint for bots.
//void() spawnfunc_misc_model = {remove(self);};	//q3map2 builds these into the bsp itself but doesn't strip them. on q1bsp we probably want to display them ourselves. we'll just let the engine deal with it...
void() spawnfunc_func_static = {setmodel(self, self.model); makestatic(self);};

void() spawnfunc_team_CTF_redflag = {item_flag_team1();};
void() spawnfunc_team_CTF_redspawn = {self.classname="info_player_team1";info_player_team1();};
void() spawnfunc_team_CTF_redplayer = {remove(self);};	//used for initial spawn positions

void() spawnfunc_team_CTF_blueflag = {item_flag_team2();};
void() spawnfunc_team_CTF_bluespawn = {self.classname="info_player_team2";info_player_team2();};
void() spawnfunc_team_CTF_blueplayer = {remove(self);};	//used for initial spawn positions

void() spawnfunc_shooter_grenade = {remove(self);};
void() spawnfunc_func_rotating = {if (!self.dmg) self.dmg = 2;if (!self.speed) self.speed = 1000; self.solid = SOLID_BSP; self.movetype = MOVETYPE_PUSH; if (self.spawnflags&4)self.avelocity_z = self.speed;else if (self.spawnflags&8)self.avelocity_x = self.speed;else self.avelocity_y = self.speed; setmodel(self, self.model); self.think = func_null; self.nextthink = 99999999999;};
void() spawnfunc_func_bobbing = {remove(self);};	//eg q3dm14
void() spawnfunc_func_pendulum = {remove(self);};	//eg q3dm15

void() spawnfunc_info_player_intermission =
{
	self.classname = "info_intermission";
	info_intermission();
};

void() spawnfunc_info_thirdplace = {remove(self);};	//we don't do q3's podium stuff
void() spawnfunc_info_firstplace = {remove(self);};
void() spawnfunc_info_secondplace = {remove(self);};
void() spawnfunc_info_notnull = {};
void() spawnfunc_trigger_always = {};	//FIXME: should fire on round start.
void() spawnfunc_misc_teleporter_dest = {self.classname = "info_teleport_destination";};

//armour
void() spawnfunc_item_armor_shard =
{	//we've no models for this stuff. besides, green armour is useless anyway.
	self.classname = "item_armor1";
	item_armor1();
};
void() spawnfunc_item_armor_body =
{	//red armour
	self.classname = "item_armorInv";
	item_armorInv();
};

void() spawnfunc_item_armor_combat =
{	//yellow armour
	self.classname = "item_armor2";
	item_armor2();
};

//health items
void() item_health_small =
{
	self.classname = "item_health";
	self.spawnflags &~= 3;
	self.spawnflags |= 1;	//rotten
	self.origin -= '16 16 16';	//quake is off-center
	item_health();
};
void() spawnfunc_item_health_large =
{
	self.classname = "item_health";
	self.spawnflags &~= 3;
	self.origin -= '16 16 16';
	item_health();
};
void() spawnfunc_item_health_mega =
{
	self.classname = "item_health";
	self.spawnflags &~= 3;
	self.spawnflags |= 2;	//megahealth
	self.origin -= '16 16 16';
	item_health();
};

//other powerups
void() spawnfunc_item_quad = {self.classname="item_artifact_super_damage";item_artifact_super_damage();};
void() spawnfunc_item_invis = {self.classname="item_artifact_invisibility";item_artifact_invisibility();};
void() spawnfunc_item_enviro = {self.classname="item_artifact_envirosuit";item_artifact_envirosuit();};
void() spawnfunc_item_haste = {remove(self);};
void() spawnfunc_item_flight = {remove(self);};
void() spawnfunc_item_regen = {remove(self);};
void() spawnfunc_holdable_teleporter = {remove(self);};
void() spawnfunc_holdable_medkit = {remove(self);};

//we don't have q3's machinegun nor its ammo, just pretend that this is ammo for the SG.
void() spawnfunc_ammo_bullets =
{
	item_shells();
};

//per-weapon renamed rl/gl ammo.
void() spawnfunc_ammo_rockets =
{
	self.classname = "item_rockets";
	item_rockets();
};
void() spawnfunc_ammo_grenades =
{
	self.classname = "item_rockets";
	item_rockets();
};
//rg ammo. we just use cells, but we do have a weapon_railgun already.
void() spawnfunc_ammo_slugs =
{
	self.classname = "item_cells";
	item_cells();
};

//treat the q3 shotgun and its ammo like ssg. a bit poo really.
void() spawnfunc_weapon_shotgun =
{
	weapon_supershotgun();
};
void() spawnfunc_ammo_shells =
{
	item_shells();
};

//treat the plasmagun and its ammo like sng.
void() spawnfunc_weapon_plasmagun =
{
	weapon_supernailgun();
};
void() spawnfunc_ammo_cells =
{	//fixme...
	item_spikes();
};

//lightning gun ammo is basically cells. not to be confused with the plasma gun.
void() spawnfunc_ammo_lightning =
{
	self.classname = "item_cells";
	item_cells();
};

//we don't have a bfg-equivelent. replace with lightning gun.
void() spawnfunc_weapon_bfg =
{
	self.classname = "weapon_lightning";
	weapon_lightning();
};
void() spawnfunc_ammo_bfg =
{
	self.classname = "item_cells";
	item_cells();
};
