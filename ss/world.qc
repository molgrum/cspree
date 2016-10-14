/*
	world.qc

	main/world setup functions

	Copyright (C) 1996-1997  Id Software, Inc.

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
		Boston, MA	02111-1307, USA

*/

void() InitBodyQue;


void main()
{
	dbgprintln("=== main() ===");
	//this function is required to exist for the progs crc. but its not required to contain anything as it is never called.
};

entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void worldspawn()
{
	entity test;
	
	dbgprintln("=== worldspawn() ===");
	BotInit();
	gmapn_init();

	lastspawn = world;
	InitBodyQue();

	// Hardcoded gravity setting on Ziggurath Vertigo
	if (self.model == "maps/e1m8.bsp")
	{
		cvar_set ("sv_gravity", "100");
	}
	else
	{
		cvar_set ("sv_gravity", "800");
	}

	precache_model("progs/player.mdl"); // Visible player
	precache_model("progs/eyes.mdl");	// Invisible player
	precache_model("progs/backpack.mdl");	// Pack
	
	// Weapons on the ground
	precache_model("progs/g_shot.mdl"); // Super shotgun
	precache_model("progs/g_nail.mdl"); // Nailgun
	precache_model("progs/g_nail2.mdl");	// Super nailgun
	precache_model("progs/g_rock.mdl"); // Grenade launcher
	precache_model("progs/g_rock2.mdl");	// Rocket launcher
	precache_model("progs/g_light.mdl");	// Lightning gun

	// HUD models
	precache_model("progs/v_axe.mdl");	// Axe
	precache_model("progs/v_shot.mdl"); // Shotgun
	precache_model("progs/v_shot2.mdl");	// Super shotgun
	precache_model("progs/v_nail.mdl"); // Nailgun
	precache_model("progs/v_nail2.mdl");	// Super nailgun
	precache_model("progs/v_rock.mdl"); // Grenade launcher
	precache_model("progs/v_rock2.mdl");	// Rocket launcher
	precache_model("progs/v_light.mdl");	// Lightning gun

	if (gmapn_qsg_has_zq_vwep)
	{
		precache_vwep_model ("progs/vwplayer.mdl");
		precache_vwep_model ("progs/w_axe.mdl");
		precache_vwep_model ("progs/w_shot.mdl");
		precache_vwep_model ("progs/w_shot2.mdl");
		precache_vwep_model ("progs/w_nail.mdl");
		precache_vwep_model ("progs/w_nail2.mdl");
		precache_vwep_model ("progs/w_rock.mdl");
		precache_vwep_model ("progs/w_rock2.mdl");
		precache_vwep_model ("progs/w_light.mdl");
		precache_vwep_model ("progs/w_coil.mdl");
		precache_vwep_model ("progs/w_star.mdl");
		precache_vwep_model ("-");
	}

	precache_sound("buttons/switch02.wav"); //countdown sound

	precache_sound("items/itembk2.wav");	//item respawn sound
	precache_sound("items/r_item2.wav");	// mega health
	precache_sound("misc/h2ohit1.wav");

	// Creature models
	precache_model("progs/h_player.mdl");	// ???
	precache_sound("demon/dland2.wav");	// triggered by engine code in certain situations. annoying, but kinda needs to be precached.

	// Medieval keys
	precache_model("progs/w_s_key.mdl");	// Silver key
	precache_model("progs/w_g_key.mdl");	// Gold key

	// Rune keys
	precache_model("progs/m_s_key.mdl");
	precache_model("progs/m_g_key.mdl");

	// Hazard models
	precache_model("progs/spike.mdl");	// Nail
	precache_model("progs/s_spike.mdl");	// Super nail
	precache_model("progs/grenade.mdl");	// Grenade
	precache_model("progs/missile.mdl");	// Rocket
	precache_model("progs/bolt2.mdl");	// Lightning beam
	precache_model("progs/laser.mdl");	// ???
	precache_model("progs/w_spike.mdl");	// ???

	// Hazard sounds
	precache_sound("weapons/guncock.wav");	// Shotgun
	precache_sound("weapons/shotgn2.wav");	// Super shotgun
	precache_sound("weapons/rocket1i.wav"); // Nailgun
	precache_sound("weapons/spike2.wav");	// Super nailgun
	precache_sound("weapons/grenade.wav");	// Grenade launcher
	precache_sound("weapons/bounce.wav");	// Grenade bounce
	precache_sound("weapons/sgun1.wav");	// Rocket launcher
	precache_sound("weapons/r_exp3.wav");	// Explosion
	precache_sound("weapons/lstart.wav");	// Lightning gun start
	precache_sound("weapons/lhit.wav"); // Lightning gun buzz
	precache_sound("enforcer/enfstop.wav"); // ???
	precache_sound("misc/power.wav");	// Discharge
	precache_sound("weapons/ax1.wav");	// ???

	precache_sound("weapons/lock4.wav");

	// Teleport sounds
	precache_sound("misc/r_tele1.wav");
	precache_sound("misc/r_tele2.wav");
	precache_sound("misc/r_tele3.wav");
	precache_sound("misc/r_tele4.wav");
	precache_sound("misc/r_tele5.wav");

	// Powerup sounds
	precache_sound("items/inv1.wav");
	precache_sound("items/inv2.wav");
	precache_sound("items/inv3.wav");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	precache_sound("items/suit.wav");
	precache_sound("items/suit2.wav");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");

	// Player sounds
	precache_sound("misc/outwater.wav");
	precache_sound("player/axhit2.wav");
	precache_sound("player/death1.wav");
	precache_sound("player/death2.wav");
	precache_sound("player/death3.wav");
	precache_sound("player/death4.wav");
	precache_sound("player/death5.wav");
	precache_sound("player/drown1.wav");
	precache_sound("player/drown2.wav");
	precache_sound("player/h2ojump.wav");
	precache_sound("player/inh2o.wav");
	precache_sound("player/inlava.wav");
	precache_sound("player/land.wav");
	precache_sound("player/land2.wav");
	precache_sound("player/lburn1.wav");
	precache_sound("player/lburn2.wav");
	precache_sound("player/pain1.wav");
	precache_sound("player/pain2.wav");
	precache_sound("player/pain3.wav");
	precache_sound("player/pain4.wav");
	precache_sound("player/pain5.wav");
	precache_sound("player/pain6.wav");
	precache_sound("player/axhit1.wav");
	precache_sound("player/plyrjmp8.wav");
	precache_sound("player/slimbrn2.wav");
	precache_sound("player/teledth1.wav");
	precache_sound("player/tornoff2.wav");	//disconnection sound
	precache_sound("player/gib.wav");
	precache_sound("player/udeath.wav");

	// Water sounds
	precache_sound("misc/water1.wav");
	precache_sound("misc/water2.wav");

	// Monster and player gibs
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");
	
	//ruleset-specific stuff
	//freezetag
	precache_sound("player/frozen1.wav");
	//domination
	precache_model("progs/v_spike.mdl");
	//ctf
	precache_model("progs/v_star.mdl");
	precache_model("progs/star.mdl");
	precache_model("progs/flag.mdl");
	precache_model("progs/end1.mdl");
	precache_model("progs/end2.mdl");
	precache_model("progs/end3.mdl");
	precache_model("progs/end4.mdl");
	precache_sound("rune/rune1.wav");
	precache_sound("rune/rune2.wav");
	precache_sound("rune/rune3.wav");
	precache_sound("rune/rune4.wav");
	particleeffectnum("gmapn.tr_flag_red");
	particleeffectnum("gmapn.tr_flag_blue");
	//instagib
	precache_model("progs/v_coil.mdl");
	precache_sound("weapons/coilgun.wav");
#ifdef HAVE_PORTALS
	//portal gun
	precache_model("progs/b_portal.bsp");
	precache_model("progs/v_portal.mdl");
	if (gmapn_qsg_has_zq_vwep)
		precache_vwep_model ("progs/w_portal.mdl");
	particleeffectnum("portal.tr_portalgun_1");
	particleeffectnum("portal.tr_portalgun_2");
	particleeffectnum("portal.te_portalspawn_1");
	particleeffectnum("portal.te_portalspawn_2");
	particleeffectnum("portal.te_portalfizzle_1");
	particleeffectnum("portal.te_portalfizzle_2");
#endif

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	gmapn_lightstyle_reset();

	if (getkey(runtests) == 1) {
		test = spawn();
		test.think = gmapn_init_test;
		test.nextthink = time + 0.5;
	}

	world.nextthink = time + 0.5;
	world.think = gmapn_init_entities;

	//make sure some data is downloaded to clients.
//	whichpack("data/test.mnu", TRUE);
};

void StartFrame()
{
	BotFrame();
	
	framecount+=1;
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void bodyque()
{		// just here so spawn functions don't complain after the world
	// creates bodyques
};

void InitBodyQue()
{
	bodyque_head = spawn();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};


// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void CopyToBodyQue(entity ent)
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};

