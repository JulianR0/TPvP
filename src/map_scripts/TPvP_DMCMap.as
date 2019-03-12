#include "dmc_weapons/dmc_utils"
#include "dmc_weapons/ammo_dmcshells"
#include "dmc_weapons/ammo_dmcnails"
#include "dmc_weapons/ammo_dmcrockets"
#include "dmc_weapons/ammo_dmccells"
#include "dmc_weapons/item_dmchealth"
#include "dmc_weapons/item_dmcarmor"
#include "dmc_weapons/weapon_dmcaxe"
#include "dmc_weapons/weapon_dmcshotgun"
#include "dmc_weapons/weapon_dmcsupershotgun"
#include "dmc_weapons/weapon_dmcnailgun"
#include "dmc_weapons/weapon_dmcsupernailgun"
#include "dmc_weapons/weapon_dmcgrenadelauncher"
#include "dmc_weapons/weapon_dmcrocketlauncher"
#include "dmc_weapons/weapon_dmclightninggun"

void MapInit()
{
	RegisterNailEntity();
	RegisterRocketEntity();
	
	RegisterDMCShellAmmo();
	RegisterDMCNailAmmo();
	RegisterDMCRocketAmmo();
	RegisterDMCCellAmmo();
	
	RegisterDMCHealthItem();
	RegisterDMCArmorItem();
	
	RegisterDMCAxe();
	RegisterDMCShotgun();
	RegisterDMCSuperShotgun();
	RegisterDMCNailgun();
	RegisterDMCSuperNailgun();
	RegisterDMCGrenadeLauncher();
	RegisterDMCRocketLauncher();
	RegisterDMCLightninggun();
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	pPlayer.GiveNamedItem( "weapon_dmcshotgun" );
	pPlayer.GiveNamedItem( "weapon_dmcaxe" );
	
	// maxarmor 0 is "illegal" on a map cfg, yet maxarmor 1 is valid. LOGIC.
	pPlayer.pev.armortype = 0;
	
	// Rare, but a player might spawn on an armor, and HUD will not be properly updated. Send message manually later
	g_Scheduler.SetTimeout( "UpdateBattery", 0.2, pPlayer.entindex() );
	
	return HOOK_CONTINUE;
}

void UpdateBattery( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
	{
		CustomKeyvalues@ pKVD = pPlayer.GetCustomKeyvalues();
		CustomKeyvalue pre_ArmorAmount( pKVD.GetKeyvalue( "$f_armor_value" ) );
		float flArmorValue = pre_ArmorAmount.GetFloat();
		
		NetworkMessage nmArmor( MSG_ONE_UNRELIABLE, NetworkMessages::Battery, pPlayer.edict() );
		nmArmor.WriteShort( int( flArmorValue ) );
		nmArmor.End();
		
		pPlayer.pev.fuser1 = flArmorValue; // Send to AMXX
	}
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
	// Handles as globals are not allowed, causing me to write this poorly optimized line of code. -Giegue
	CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( pEntity is null )
		return HOOK_CONTINUE;
	
	if ( g_EngineFuncs.PointContents( pPlayer.pev.origin ) == CONTENTS_LAVA )
	{
		pPlayer.TakeDamage( pEntity.pev, pEntity.pev, 1.0, ( DMG_BURN | DMG_NEVERGIB ) );
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	// Remove any armor the player might have
	pPlayer.KeyValue( "$f_armor_value", "0.0" );
	pPlayer.KeyValue( "$f_armor_type", "0.0" );
	
	return HOOK_CONTINUE;
}
