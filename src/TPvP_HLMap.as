#include "hl_weapons/weapon_hlcrowbar"
#include "hl_weapons/weapon_hlmp5"
#include "hl_weapons/weapon_hlshotgun"
#include "hl_weapons/weapon_hlcrossbow"
#include "hl_weapons/weapon_hl9mmhandgun"
#include "hl_weapons/weapon_hl357"
#include "hl_weapons/weapon_hlsatchel"
#include "hl_weapons/weapon_hlsnark"
#include "hl_weapons/weapon_hltripmine"
#include "hl_weapons/weapon_hlrpg"
#include "hl_weapons/weapon_hlhandgrenade"
#include "hl_weapons/weapon_hlgauss"
#include "hl_weapons/weapon_hlegon"
#include "hlsp/func_healthcharger"
#include "hlsp/func_recharge"

array<ItemMapping@> g_ItemMappings =
{
	ItemMapping( "weapon_9mmAR", GetHLMP5Name() ),
	ItemMapping( "weapon_shotgun", GetHLShotgunName() ),
	ItemMapping( "weapon_m16", "weapon_hlcrowbar" ),
	ItemMapping( "weapon_crossbow", GetHLCrossbowName() ),
	ItemMapping( "weapon_9mmhandgun", GetHL9mmhandgunName() ),
	ItemMapping( "weapon_357", GetHL357Name() ),
	ItemMapping( "weapon_satchel", GetHLSatchelName() ),
	ItemMapping( "weapon_snark", GetHLSnarkName() ),
	ItemMapping( "weapon_tripmine", GetHLTripmineName() ),
	ItemMapping( "weapon_rpg", GetHLRpgName() ),
	ItemMapping( "weapon_handgrenade", GetHLHandgrenadeName() ),
	ItemMapping( "weapon_gauss", GetHLGaussName() ),
	ItemMapping( "weapon_egon", GetHLEgonName() )
	
	// No las reemplaza, debe hacerse manual desde ripent, agregar HL despues del func_
	// Ejemplo: func_hlhealthcharger. -Giegue
	
	//ItemMapping( "func_healthcharger", GetHLHPChargerName() ),
	//ItemMapping( "func_recharge", GetHLAPChargerName() )
};

void MapInit()
{
	RegisterHLCrowbar();
	RegisterHLMP5();
	RegisterHLShotgun();
	RegisterHLCrossbow();
	RegisterHL9mmhandgun();
	RegisterHL357();
	RegisterHLSatchel();
	RegisterHLSnark();
	RegisterHLTripmine();
	RegisterHLRpg();
	RegisterHLHandgrenade();
	RegisterHLGauss();
	RegisterHLEgon();
	RegisterHLHPCharger();
	RegisterHLAPCharger();
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	
	g_ClassicMode.EnableMapSupport();
	g_ClassicMode.SetEnabled( true );
	g_ClassicMode.SetItemMappings( @g_ItemMappings );
}

void MapActivate()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "ammo_ARgrenades" ) ) !is null )
	{
		g_EntityFuncs.Remove( ent );
	}
	
	@ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "weapon_hornetgun" ) ) !is null )
	{
		g_EntityFuncs.Remove( ent );
	}
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	pPlayer.GiveNamedItem( "weapon_hl9mmhandgun" );
	pPlayer.GiveNamedItem( "ammo_9mmclip" );
	pPlayer.GiveNamedItem( "ammo_9mmclip" );
	pPlayer.GiveNamedItem( "ammo_9mmclip" );
	pPlayer.GiveNamedItem( "weapon_hlcrowbar" );
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ dummy1, int dummy2 )
{
	DeactivateSatchels( pPlayer );
	
	return HOOK_CONTINUE;
}
