/*
DEV NOTE:

To this day, I still don't know why I didn't move
this file outside and rename it to TPVP_CSMap.as

-Giegue
*/

#include "../UTIL_GetDefaultShellInfo"
#include "weapon_hegrenade"
#include "Util"
#include "weapon_ak47"
#include "weapon_m4a1"
#include "weapon_csdeagle"
#include "weapon_mp5navy"
#include "weapon_usp"
#include "weapon_aug"
#include "weapon_m3"
#include "weapon_xm1014"
#include "weapon_awp"
#include "weapon_p90"
#include "weapon_p228"
#include "weapon_dualelites"
#include "weapon_sg552"
#include "weapon_csm249"
#include "weapon_ump45"
#include "weapon_famas"
#include "weapon_sg550"
#include "weapon_g3sg1"
#include "weapon_csknife"
#include "weapon_tmp"
#include "weapon_galil"
#include "weapon_fiveseven"
#include "weapon_mac10"
#include "weapon_scout"
#include "weapon_csglock18"
#include "weapon_c4"
#include "item_kevlar"

void MapInit()
{
	RegisterHEGRENADE();
	RegisterAK47();
	RegisterAK47AmmoBox();
	RegisterM4A1();
	RegisterAmmo556NatoBox();
	RegisterCSDeagle();
	RegisterDeagleAmmoBox();
	RegisterMP5Navy();
	RegisterNinemmBox();
	RegisterUSP();
	RegisterUSPAmmoBox();
	RegisterAUG();
	RegisterM3Shotty();
	RegisterXM1014Shotty();
	RegisterTwelveGaugeBox();
	RegisterAWP();
	RegisterLapuaMagnumBox();
	RegisterP90();
	RegisterFN57Box();
	RegisterP228();
	RegisterSIG357Box();
	RegisterELITES();
	RegisterSG552();
	RegisterCSM249();
	RegisterAmmo_556NatoBox();
	RegisterUMP45();
	RegisterFAMAS();
	RegisterSG550();
	RegisterG3SG1();
	RegisterCSKNIFE();
	RegisterTMP();
	RegisterGALIL();
	RegisterFIVESEVEN();
	RegisterMAC10();
	RegisterSCOUT();
	RegisterGLOCK18();
	RegisterC4();
	RegisterKevlar();
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	// maxarmor 0 is "illegal" on a map cfg, yet maxarmor 1 is valid. LOGIC.
	pPlayer.pev.armortype = 0;
	
	// Rare, but a player might spawn on an armor, and HUD will not be properly updated. Send message manually later
	g_Scheduler.SetTimeout( "UpdateBattery", 0.2, pPlayer.entindex() );
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	// Remove any armor the player might have
	pPlayer.KeyValue( "$f_armor_value", "0.0" );
	pPlayer.KeyValue( "$f_armor_type", "0.0" );
	
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

void MapActivate()
{
	CBaseEntity@ ent = null;
}
