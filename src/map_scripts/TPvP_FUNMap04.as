// Style 04 of 99 allowed (fun_big_city)

#include "UTIL_GetDefaultShellInfo"

#include "cs16/Util"
#include "dod_weapons/ShellEject"
#include "dmc_weapons/dmc_utils"

#include "dmc_weapons/ammo_dmcnails"
#include "dmc_weapons/ammo_dmcrockets"
#include "dmc_weapons/ammo_dmcshells"
#include "cs16/weapon_p90"
#include "cs16/weapon_m4a1"
#include "cs16/weapon_ak47"

#include "cs16/weapon_csknife"
#include "cs16/weapon_fiveseven"
#include "cs16/weapon_galil"
#include "cs16/weapon_hegrenade"
#include "cs16/weapon_scout"

#include "dmc_weapons/weapon_dmcsupershotgun"
#include "dmc_weapons/weapon_dmcsupernailgun"
#include "dmc_weapons/weapon_dmcrocketlauncher"

#include "dod_weapons/weapon_garand"
#include "dod_weapons/weapon_greasegun"
#include "dod_weapons/weapon_fg42"
#include "dod_weapons/weapon_webley"
#include "dod_weapons/weapon_piat"

#include "cs16/func_vehicle_fix"

void MapInit()
{
	RegisterNailEntity();
	RegisterRocketEntity();
	
	RegisterDMCNailAmmo();
	RegisterDMCRocketAmmo();
	RegisterDMCShellAmmo();
	RegisterFN57Box();
	RegisterAmmo556NatoBox();
	RegisterAK47AmmoBox();
	
	RegisterCSKNIFE();
	RegisterFIVESEVEN();
	RegisterGALIL();
	RegisterHEGRENADE();
	RegisterSCOUT();
	
	RegisterDMCSuperShotgun();
	RegisterDMCSuperNailgun();
	RegisterDMCRocketLauncher();
	
	RegisterGARAND();
	RegisterGREASEGUN();
	RegisterFG42();
	RegisterWEBLEY();
	RegisterPIAT();
	
	g_Game.PrecacheOther( "ammo_dmcshells" );
	g_Game.PrecacheOther( "ammo_dmcnails" );
	g_Game.PrecacheOther( "ammo_dmcrockets" );
	
	VehicleMapInit( true );
	
	g_Scheduler.SetInterval( "CheckVehicle", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
}

void CheckVehicle()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "func_vehicle_custom" ) ) !is null )
	{
		if ( !ent.IsInWorld() )
		{
			func_vehicle_custom@ pVehicle = func_vehicle_custom_Instance( ent );
			pVehicle.Restart();
			g_Scheduler.SetTimeout( "ResetAngles", 0.1, ent.entindex() );
		}
	}
}

void ResetAngles( const int& in entity )
{
	CBaseEntity@ pVehicle = g_EntityFuncs.Instance( entity );
	
	// It's incorrect, but it will fix respawned vehicles from
	// being unusable because of screwed up angles (Upside down).
	pVehicle.pev.angles = Vector( 0, 0, 0 );
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	int RNG = Math.RandomLong( 1, 5 );
	if ( RNG == 1 )
	{
		pPlayer.GiveNamedItem( "weapon_csknife" );
		pPlayer.GiveNamedItem( "weapon_fiveseven" );
		pPlayer.GiveNamedItem( "weapon_galil" );
		pPlayer.GiveNamedItem( "weapon_hegrenade" );
		pPlayer.GiveNamedItem( "weapon_scout" );
	}
	else if ( RNG == 2 )
	{
		pPlayer.GiveNamedItem( "weapon_dmcsupershotgun" );
		pPlayer.GiveNamedItem( "weapon_dmcsupernailgun" );
		pPlayer.GiveNamedItem( "weapon_dmcrocketlauncher" );
		
		// Can't use m_rgAmmo with custom ammo, using this as a workaround
		pPlayer.GiveNamedItem( "ammo_dmcshells" );
		pPlayer.GiveNamedItem( "ammo_dmcshells" );
		pPlayer.GiveNamedItem( "ammo_dmcshells" );
		pPlayer.GiveNamedItem( "ammo_dmcshells" );
		pPlayer.GiveNamedItem( "ammo_dmcshells" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcnails" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
	}
	else if ( RNG == 3 )
	{
		pPlayer.GiveNamedItem( "weapon_garand" );
		pPlayer.GiveNamedItem( "weapon_greasegun" );
		pPlayer.GiveNamedItem( "weapon_fg42" );
		pPlayer.GiveNamedItem( "weapon_webley" );
		pPlayer.GiveNamedItem( "weapon_piat" );
		
		pPlayer.m_rgAmmo( 9, 240 ); // AMMO_9MM
		pPlayer.m_rgAmmo( 8, 36 ); // AMMO_357
		pPlayer.m_rgAmmo( 10, 200 ); // AMMO_556
	}
	else if ( RNG == 4 )
	{
		pPlayer.GiveNamedItem( "weapon_eagle" );
		pPlayer.GiveNamedItem( "weapon_mp5" );
		pPlayer.GiveNamedItem( "weapon_saw" );
		pPlayer.GiveNamedItem( "weapon_tripmine" );
		pPlayer.GiveNamedItem( "weapon_tripmine" );
		pPlayer.GiveNamedItem( "weapon_tripmine" );
		pPlayer.GiveNamedItem( "weapon_tripmine" );
		pPlayer.GiveNamedItem( "weapon_tripmine" );
		
		pPlayer.m_rgAmmo( 9, 250 ); // AMMO_9MM
		pPlayer.m_rgAmmo( 8, 36 ); // AMMO_357
		pPlayer.m_rgAmmo( 10, 600 ); // AMMO_556
	}
	else if ( RNG == 5 )
	{
		pPlayer.GiveNamedItem( "weapon_saw" );
		pPlayer.GiveNamedItem( "weapon_galil" );
		pPlayer.GiveNamedItem( "weapon_garand" );
		pPlayer.GiveNamedItem( "weapon_dmcrocketlauncher" );
		
		pPlayer.m_rgAmmo( 8, 36 ); // AMMO_357
		pPlayer.m_rgAmmo( 10, 600 ); // AMMO_556
		
		// Can't use m_rgAmmo with custom ammo, using this as a workaround
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
		pPlayer.GiveNamedItem( "ammo_dmcrockets" );
	}
	
	return HOOK_CONTINUE;
}

