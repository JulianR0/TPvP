#include "UTIL_GetDefaultShellInfo"
#include "dod_weapons/ShellEject"
#include "dod_weapons/weapon_enfield"
#include "dod_weapons/weapon_sten"
#include "dod_weapons/weapon_webley"
#include "dod_weapons/weapon_bren"
#include "dod_weapons/weapon_piat"
#include "dod_weapons/weapon_mp40"
#include "dod_weapons/weapon_mp44"
#include "dod_weapons/weapon_kar98k"
#include "dod_weapons/weapon_g43"
#include "dod_weapons/weapon_fg42"
#include "dod_weapons/weapon_luger"
#include "dod_weapons/weapon_mg42"
#include "dod_weapons/weapon_mg34"
#include "dod_weapons/weapon_stick"
#include "dod_weapons/weapon_spade"
#include "dod_weapons/weapon_garand"
#include "dod_weapons/weapon_m1911"
#include "dod_weapons/weapon_greasegun"
#include "dod_weapons/weapon_thompson"
#include "dod_weapons/weapon_m1carbine"
#include "dod_weapons/weapon_springfield"
#include "dod_weapons/weapon_bar"
#include "dod_weapons/weapon_30cal"
#include "dod_weapons/util_controlpoint"

void MapInit()
{
	RegisterENFIELD();
	RegisterSTEN();
	RegisterWEBLEY();
	RegisterBREN();
	RegisterPIAT();
	RegisterMP40();
	RegisterMP44();
	RegisterK98K();
	RegisterG43();
	RegisterFG42();
	RegisterLUGER();
	RegisterMG42();
	RegisterMG34();
	RegisterSTICK();
	RegisterSPADE();
	RegisterGARAND();
	RegisterM1911();
	RegisterGREASEGUN();
	RegisterTHOMPSON();
	RegisterM1CARB();
	RegisterSPRINGF();
	RegisterBAR();
	RegisterTHIRTYCAL();
	RegisterControlPoint();
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Scheduler.SetInterval( "CPCheck", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	pPlayer.GiveNamedItem( "weapon_m1911" );
	pPlayer.GiveNamedItem( "weapon_spade" );
	pPlayer.GiveNamedItem( "weapon_stick" );
	
	return HOOK_CONTINUE;
}

void CPCheck()
{
	bool bSpiral = false;
	bool bCrimson = false;	
	
	// Iterate through all control points
	CBaseEntity@ pPoint = null;
	while ( ( @pPoint = g_EntityFuncs.FindEntityByClassname( pPoint, "sys_control_point" ) ) !is null )
	{
		if ( pPoint.pev.skin == 0 ) // 0 = SPIRAL
		{
			// At least 1 point belongs to the Spirals
			bSpiral = true;
		}
		else if ( pPoint.pev.skin == 1 ) // 1 = CRIMSON
		{
			// At least 1 point belongs to the Crimsons
			bCrimson = true;
		}
	}
	
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData !is null )
	{
		CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
		
		if ( bSpiral )
		{
			CustomKeyvalue pre_CPSpiralTime( pCustom.GetKeyvalue( "$i_cp_spiral" ) );
			if ( pre_CPSpiralTime.Exists() )
			{
				// Store here the amount of time a Control Point was in Spiral's possession
				int CPSpiralTime = pre_CPSpiralTime.GetInteger();
				CPSpiralTime++;
				
				pCustom.SetKeyvalue( "$i_cp_spiral", CPSpiralTime );
			}
			else
			{
				// Initialize
				pCustom.SetKeyvalue( "$i_cp_spiral", 1 );
			}
		}
		
		if ( bCrimson )
		{
			CustomKeyvalue pre_CPCrimsonTime( pCustom.GetKeyvalue( "$i_cp_crimson" ) );
			if ( pre_CPCrimsonTime.Exists() )
			{
				// Store here the amount of time a Control Point was in Crimson's possession
				int CPCrimsonTime = pre_CPCrimsonTime.GetInteger();
				CPCrimsonTime++;
				
				pCustom.SetKeyvalue( "$i_cp_crimson", CPCrimsonTime );
			}
			else
			{
				// Initialize
				pCustom.SetKeyvalue( "$i_cp_crimson", 1 );
			}
		}
	}
}
