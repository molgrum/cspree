/*
    constants.qc

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

/* MOD INFO */
// Name is the shortened variant
// Version is always git when laying in the repo, do change it on release
// URL is a shortened link to the project page
const string URL     = "https://git.io/vSGFe";

///////////////////////////////////////////////////////////////////////////////
//                       Q U A K E   C O N S T A N T S                       //
///////////////////////////////////////////////////////////////////////////////

float	FALSE					= 0;
float	TRUE					= 1;

/*
 * .attackstate
 */

float  AS_STRAIGHT				= 1;
float  AS_SLIDING				= 2;
float  AS_MELEE					= 3;
float  AS_MISSILE				= 4;

/*
 * sound attenuation
 */

float  ATTN_NONE				= 0;
float  ATTN_NORM				= 1;
float  ATTN_IDLE				= 2;
float  ATTN_STATIC				= 3;

/*
 * sound channels
 */

float  CHAN_AUTO				= 0;
float  CHAN_WEAPON				= 1;
float  CHAN_VOICE				= 2;
float  CHAN_ITEM				= 3;
float  CHAN_BODY				= 4;
float  CHAN_NO_PHS_ADD			= 8;		// ie: CHAN_BODY+CHAN_NO_PHS_ADD

/*
 * .watertype
 */

float  CONTENT_EMPTY			= -1;
float  CONTENT_SOLID			= -2;
float  CONTENT_WATER			= -3;
float  CONTENT_SLIME			= -4;
float  CONTENT_LAVA				= -5;
float  CONTENT_SKY				= -6;

/*
 * .spawnflags counters
 */

float  COUNTER_SILENT			= 1;		// Doesn't centerprint sequence status

/*
 * .takedamage field
 * (note: ignores damage_aim
 */

float  DAMAGE_NOT			= 0;		// Does not take any damage
float  DAMAGE_TRIGGER			= 1;		// Invokes .use on the target
float  DAMAGE_BLEED			= 2;		// Bleeds from all entities except world (note that the engine's autoaim will auto-aim at these). Not that this is relevent for us.
float  DAMAGE_EXPLODE			= 3;		// Explodes
float  DAMAGE_INVINCIBLE		= 4;		// Can be knocked around, but does not otherwise get hurt.

/*
 * .deadflag
 */

float  DEAD_NO					= 0;		// Alive and able to walk, shoot and use
float  DEAD_DYING				= 1;		// Waiting for the death sequence to finish
float  DEAD_DEAD				= 2;		// Dead and waiting for respawning to unlock
float  DEAD_RESPAWNABLE			= 3;		// Dead and able to respawn

/*
 * .spawnflags doors
 */
float DOOR_START_OPEN			= 1;		// The door starts in open state
float DOOR_DONT_LINK			= 4;		// The door is not to be linked with nearby doors
float DOOR_GOLD_KEY				= 8;		// Requires the gold key
float DOOR_SILVER_KEY			= 16;		// Requires the silver key
float DOOR_TOGGLE				= 32;		// The door has no release function

/*
 * .deathtype
 */

enum
{
  DT_NULL = 0,
  DT_AXE,
  DT_BULLET,
  DT_SUPER_BULLET,
  DT_NAIL,
  DT_SUPER_NAIL,
  DT_GRENADE,
  DT_ROCKET,
  DT_BOLT,
  DT_DISCHARGE,
  DT_RAILGUN,
  DT_COILGUN,
  DT_TELEFRAG,
  DT_TELEFRAG_PENT,
  DT_TELEFRAG_PENT_BOTH,
  DT_SQUISH,
  DT_EXPLOSION,
  DT_LASER,
  DT_LAVABALL,
  DT_WATER,
  DT_SLIME,
  DT_LAVA,
  DT_EXIT,
  DT_FALL,
  DT_SUICIDE,
  DT_TEAMREFLECT,
  DT_MONSTER
};


/*
 * .effects
 */

//float EF_BRIGHTFIELD			  = 1;
//float EF_MUZZLEFLASH			  = 2;
float  EF_BRIGHTLIGHT			= 4;
float  EF_DIMLIGHT				= 8;
float  EF_FLAG1					= 16;
float  EF_FLAG2					= 32;
float  EF_BLUE					= 64;		// Blue globe effect (GL)
float  EF_RED					= 128;		// Red globe effect (GL)

/*
 * .flags
 */

float  FL_FLY					= 1;
float  FL_SWIM					= 2;
float  FL_CLIENT				= 8;		// set for all client edicts
float  FL_INWATER				= 16;		// for enter / leave water splash
float  FL_MONSTER				= 32;
float  FL_GODMODE				= 64;		// player cheat
float  FL_NOTARGET				= 128;		// player cheat
float  FL_ITEM					= 256;		// extra wide size for bonus items
float  FL_ONGROUND				= 512;		// standing on something
float  FL_PARTIALGROUND			= 1024;		// not all corners are valid
float  FL_WATERJUMP				= 2048;		// player jumping out of water
float  FL_JUMPRELEASED			= 4096;		// for jump debouncing

/*
 * .items
 */

float  IT_SHOTGUN				= 1;		// Shotgun, always carried
float  IT_SUPER_SHOTGUN				= 2;		// Super shotgun
float  IT_NAILGUN				= 4;		// Nailgun
float  IT_SUPER_NAILGUN				= 8;		// Super nailgun
float  IT_GRENADE_LAUNCHER			= 16;		// Grenade launcher
float  IT_ROCKET_LAUNCHER			= 32;		// Rocket launcher
float  IT_LIGHTNING_GUN				= 64;		// Lightning gun
float  IT_RAILGUN				= 128;		// N/A for now
float  IT_HOOK					= 256;		//only enabled in ctf
float  IT_COILGUN				= 512;		//only enabled in instagib

float  IT_SHELLS				= 256;		// Ammo for shotguns
float  IT_NAILS					= 512;		// Ammo for nailguns
float  IT_ROCKETS				= 1024;		// Ammo for grenade and rocket launcher
float  IT_CELLS					= 2048;		// Ammo for lightning and railgun

float  IT_AXE					= 4096;		// Axe weapon, always carried

float  IT_ARMOR1				= 8192;		// Green armor
float  IT_ARMOR2				= 16384;	// Yellow armor
float  IT_ARMOR3				= 32768;	// Red armor

float  IT_PORTALGUN				= 65536;	// old Megahealth
float  IT_PORTALGUN_ALT			= IT_PORTALGUN|IT_CELLS;

float  IT_KEY1					= 131072;	// Silver key
float  IT_KEY2					= 262144;	// Gold key

float  IT_RING					= 524288;	// Ring of shadows
float  IT_PENT					= 1048576;	// Pentagram of protection
float  IT_SUIT					= 2097152;	// Biosuit
float  IT_QUAD					= 4194304;	// Quad damage

float  IT2_RUNE_RESISTANCE			= 1;
float  IT2_RUNE_STRENGTH			= 1;
float  IT2_RUNE_HASTE				= 4;
float  IT2_RUNE_REGEN				= 8;
//float  IT2_					= 16;

//hud display ((items2|serverflags)&15)*16
float  IT2_SIGIL1				= 32;
float  IT2_SIGIL2				= 64;
float  IT2_SIGIL3				= 128;
float  IT2_SIGIL4				= 256;

/*
 * .spawnflags items
 */

float  ITEM_AMMO_BIG			= 1;		// item_* big ammo flag (standard)

float  ITEM_WEAPON_SHELLS		= 1;		// item_weapon shells ammo
float  ITEM_WEAPON_ROCKETS		= 2;		// item_weapon rockets ammo
float  ITEM_WEAPON_NAILS		= 4;		// item_weapon nails ammo
float  ITEM_WEAPON_BIG			= 8;		// item_weapon big ammo

/*
 * .jointtype (ODE extension)
 */

float  JOINTTYPE_POINT			= 1;
float  JOINTTYPE_HINGE			= 2;
float  JOINTTYPE_SLIDER			= 3;
float  JOINTTYPE_UNIVERSAL		= 4;
float  JOINTTYPE_HINGE2			= 5;
float  JOINTTYPE_FIXED			= -1;

/*
 * .spawnflags lights
 */

float  LIGHT_START_OFF			= 1;

/*
 * .movetype
 */

float  MOVETYPE_NONE			= 0;		// never moves
//float  MOVETYPE_ANGLENOCLIP	  = 1;
//float  MOVETYPE_ANGLECLIP		  = 2;
float  MOVETYPE_WALK			= 3;		// players only
float  MOVETYPE_STEP			= 4;		// discrete, not real time unless fall
float  MOVETYPE_FLY				= 5;
float  MOVETYPE_TOSS			= 6;		// gravity
float  MOVETYPE_PUSH			= 7;		// no clip to world, push and crush
float  MOVETYPE_NOCLIP			= 8;
float  MOVETYPE_FLYMISSILE		= 9;		// fly with extra size against monsters
float  MOVETYPE_BOUNCE			= 10;
float  MOVETYPE_BOUNCEMISSILE	= 11;		// bounce with extra size
float  MOVETYPE_PHYSICS			= 32;		// ODE extension

/*
 * messages
 */

float  MSG_BROADCAST			= 0;		// unreliable to all
float  MSG_ONE					= 1;		// reliable to one (msg_entity)
float  MSG_ALL					= 2;		// reliable to all
float  MSG_INIT					= 3;		// write to the init string
float  MSG_MULTICAST			= 4;		// for multicast() call

/*
 * multicast sets
 */

float  MULTICAST_ALL			= 0;		// every client
float  MULTICAST_PHS			= 1;		// within hearing
float  MULTICAST_PVS			= 2;		// within sight
float  MULTICAST_ALL_R			= 3;		// every client, reliable
float  MULTICAST_PHS_R			= 4;		// within hearing, reliable
float  MULTICAST_PVS_R			= 5;		// within sight, reliable

/*
 * .spawnflags plats
 */

float PLAT_LOW_TRIGGER = 1;

/*
 * bprint/sprint message levels
 */

float  PRINT_LOW				= 0;		// pickup messages
float  PRINT_MEDIUM				= 1;		// death messages
float  PRINT_HIGH				= 2;		// critical messages
float  PRINT_CHAT				= 3;		// also goes to chat console

/*
 * range values
 */

float  RANGE_MELEE				= 0;
float  RANGE_NEAR				= 1;
float  RANGE_MID				= 2;
float  RANGE_FAR				= 3;

/*
 * .spawnflags secret doors
 */

float  SECRET_STAY_OPEN    = 1;		// The door stays open when opened
float  SECRET_FIRST_LEFT   = 2;		// First move is left of arrow(?)
float  SECRET_FIRST_DOWN   = 4;		// First move is down from arrow(?)
float  SECRET_TRIGGER_OPEN = 8;		// The door is opened by a trigger
float  SECRET_SHOOTABLE    = 16;	// The door can also be shot

/*
 * .solid
 */

float  SOLID_NOT				= 0;		// no interaction with other objects
float  SOLID_TRIGGER			= 1;		// touch on edge, but not blocking
float  SOLID_BBOX				= 2;		// touch on edge, block
float  SOLID_SLIDEBOX			= 3;		// touch on edge, but not an onground
float  SOLID_BSP				= 4;		// bsp clip, touch on edge, block
float  SOLID_LADDER				= 20;		// FTE_SOLID_LADDER extension
float  SOLID_PHYSICS_BOX		= 32;		// ODE extension
float  SOLID_PHYSICS_SPHERE		= 33;		// ODE extension
float  SOLID_PHYSICS_CAPSULE	= 34;		// ODE extension

/*
 * .state
 */

// Plats
float  STATE_TOP				= 0;
float  STATE_BOTTOM				= 1;
float  STATE_UP					= 2;
float  STATE_DOWN				= 3;

// Buttons
float  STATE_PUSHED				= 4;
float  STATE_RELEASED			= 5;
float  STATE_PUSHING			= 6;
float  STATE_RELEASING			= 7;

// Doors
float  STATE_OPENED				= 8;
float  STATE_CLOSED				= 9;
float  STATE_OPENING			= 10;
float  STATE_CLOSING			= 11;

/*
 * serverflags global
 */

float  SV_EPISODE1				= 1;		// Earth magic, fist episode
float  SV_EPISODE2				= 2;		// Black magic, second episode
float  SV_EPISODE3				= 4;		// Nether magic, third episode
float  SV_EPISODE4				= 8;		// Elder magic, fourth episode
float  SV_MATCHLESS				= 256;		// when flagged, auto-start the game on the next map.

/*
 * protocol bytes
 */

float  SVC_UPDATEFRAGS			= 14;
float  SVC_TEMPENTITY			= 23;
float  SVC_KILLEDMONSTER		= 27;
float  SVC_FOUNDSECRET			= 28;
float  SVC_INTERMISSION			= 30;
float  SVC_FINALE				= 31;
float  SVC_CDTRACK				= 32;
float  SVC_SELLSCREEN			= 33;
float  SVC_SMALLKICK			= 34;
float  SVC_BIGKICK				= 35;
float  SVC_MUZZLEFLASH			= 39;

//FIXME: remove these, use the builtins instead.
float  TE_SPIKE					= 0;
float  TE_SUPERSPIKE			= 1;
float  TE_GUNSHOT				= 2;
float  TE_EXPLOSION				= 3;
float  TE_TAREXPLOSION			= 4;
float  TE_LIGHTNING1			= 5;
float  TE_LIGHTNING2			= 6;
float  TE_WIZSPIKE				= 7;
float  TE_KNIGHTSPIKE			= 8;
float  TE_LIGHTNING3			= 9;
float  TE_LAVASPLASH			= 10;
float  TE_TELEPORT				= 11;
float  TE_BLOOD					= 12;
float  TE_LIGHTNINGBLOOD		= 13;

/*
 * .spawnflags traps
 */

float TRAP_SUPERSPIKE = 1;
float TRAP_LASER	  = 2;

/*
 * update types
 */

float  UPDATE_GENERAL			= 0;
float  UPDATE_STATIC			= 1;
float  UPDATE_BINARY			= 2;
float  UPDATE_TEMP				= 3;

vector VEC_ORIGIN				= '0 0 0';
vector VEC_HULL_MIN				= '-16 -16 -24';
vector VEC_HULL_MAX				= '16 16 32';
vector VEC_HULL2_MIN			= '-32 -32 -24';
vector VEC_HULL2_MAX			= '32 32 64';



///////////////////////////////////////////////////////////////////////////////
//                       G M A P N   C O N S T A N T S                       //
///////////////////////////////////////////////////////////////////////////////

// Spawn weights constant
float  SP_WEIGHT				= 0.5;

#define DMM_NORESPAWNS 0
#define DMM_LIMITED 5
#define DMM_MIDAIR	6
#define DMM_INSTAGIB	7

#define HAVE_PORTALS


enum
{
	STAT_ACTIVEWEAPON = 10,
	STAT_ITEMS = 15,
	STAT_MATCHSTARTTIME = 18,	//engine-specified
	STAT_READY = 32,		//mod-specific stats.
	STAT_GAMEMODE,
	STAT_CURROUND,
	STAT_MAXROUND,
	STAT_TEAMSCORES_RED,
	STAT_TEAMSCORES_BLUE,
};

enum
{
	//non-team games
	GM_FFA,			//non-team deathmatch
	GM_KING,		//frags awarded only for killing (or killing as) the king.
	GM_DA,		//when someone dies, the victor is respawned, the loser is returned to the spectators, and a new challenger is selected.
	GM_HEADHUNTER,		//collect heads, take them to the altar to earn frags. suicides still cost.
	GM_COOP,		//some weird mode that needs to restart the server
	GM_DUEL,		//1on1
	
	//team games
	GM_TDEATHMATCH,		//specifically tdm
	GM_2ON2,		//2on2 rules
	GM_LASTMANSTANDING,	//when dead, made spectator. 1 frag gained only from being the last person alive.
	GM_FREEZETAG,		//like LMS, but players can be revived.
	GM_DOMINATION,		//control point thingies. frags come over time.
	GM_ROVER,		//players switch teams to match their killer's team. strict teamplay.
	GM_CTF,			//regular CTF
	GM_1FCTF,		//CTF with 1 flag for both players to fight over
	GM_HIDENSEEK,		// one team hides, another tries to find them
	GM_COUNTERQUAKE,
	GM_MODES
};

enum
{
	URI_GET_MAPLIST
};

enum
{
	MENU_NULL,

	MENU_WELCOME,
	MENU_DOMINATION,
	MENU_DUELARENA,
	MENU_FREEZETAG,
	MENU_HEADHUNTERS,
	MENU_KILLTHEKING,
	MENU_LASTMANSTANDING,
	MENU_ROVER,
	MENU_END,
	MENU_SHOW
};

const struct
{
	int fl;
	string name;
} loadouts[] =
{
	{0,			"default"},
	{IT_SUPER_SHOTGUN,	"ssg"},
	{IT_NAILGUN,		"ng"},
	{IT_SUPER_NAILGUN,	"sng"},
	{IT_GRENADE_LAUNCHER,	"gl"},
	{IT_ROCKET_LAUNCHER,	"rl"},
	{IT_LIGHTNING_GUN,	"lg"},
	{IT_RAILGUN,		"rg"},
	{IT_ARMOR1,		"ga"},
	{IT_ARMOR2,		"ya"},
	{IT_ARMOR3,		"ra"},
#ifdef HAVE_PORTALS
	{IT_PORTALGUN,		"pg"},
#endif
	{IT_RING,		"ring"},
	{IT_PENT,		"pent"},
	{IT_SUIT,		"suit"},
	{IT_QUAD,		"quad"},
};

const string itemnames[] =
{
	"weapon_supershotgun", "weapon_nailgun", "weapon_supernailgun", "weapon_grenadelauncher", "weapon_rocketlauncher", "weapon_lightning", "weapon_railgun",
	"item_shells", "item_spikes", "item_rockets", "item_cells", "item_weapon",
	"item_artifact_invulnerability", "item_artifact_invisibility",
	"item_artifact_super_damage",
	"item_armor1", "item_armor2", "item_armorInv", "item_health",
};

const string botskillname[] =
{
	"No bots",
	"Clay Pidgin",
	"Joke",
	"Noobs",
	"Mobile Victims"
};

const string dmmname[] =
{
	"Coop",
	"Normal",
	"Never played",
	"Weaponstay",
	"Stacked (unlimited)",
	"Stacked (limited)",
	"Midair",
	"Instagib"
};

const string spawnname[] =
{
	"N/A",
	"Fair",
	"Competitive"
};
