// Style 06 of 99 allowed (fun_hq2_phoenix)

#include "hq2_weapons/weapon_amensword"
#include "hq2_weapons/weapon_amenrifle"
#include "hq2_weapons/weapon_amenbomb"

void MapInit()
{
	RegisterSword();
	RegisterRifle();
	RegisterSkeleton();
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ dummy1, int dummy2 )
{
	DeactivateSatchels( pPlayer );
	
	// Don't let attackers steal other's swords or it's going to be a spam-fest of crowbars >.>
	// Delete the sword of sadism a player has when it dies, if applicable.
	CBasePlayerItem@ pSword = pPlayer.HasNamedPlayerItem( "weapon_amensword" );
	if ( pSword !is null )
		pPlayer.RemovePlayerItem( pSword );
	
	return HOOK_CONTINUE;
}
