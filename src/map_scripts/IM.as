/* InstaGib Map */

#include "misc_weapons/weapon_igauss"
#include "misc_weapons/weapon_icrowbar"

array<ItemMapping@> g_ItemMappings =
{
	ItemMapping( "weapon_igauss", GetIGaussName() ),
	ItemMapping( "weapon_icrowbar", GetICrowbarName() )
	
};

void MapInit()
{
	RegisterIGauss();
	RegisterICrowbar();
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_ClassicMode.EnableMapSupport();
	g_ClassicMode.SetEnabled( true );
	g_ClassicMode.SetItemMappings( @g_ItemMappings );
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	pPlayer.GiveNamedItem( "weapon_igauss" );
	pPlayer.GiveNamedItem( "weapon_icrowbar" );
	
	return HOOK_CONTINUE;
}
