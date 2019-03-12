// Style 02 of 99 allowed (fun_big_city2)

#include "UTIL_GetDefaultShellInfo"

#include "cs16/weapon_hegrenade"
#include "cs16/Util"
#include "cs16/weapon_ak47"
#include "cs16/weapon_m4a1"
#include "cs16/weapon_csdeagle"
#include "cs16/weapon_mp5navy"
#include "cs16/weapon_usp"
#include "cs16/weapon_aug"
#include "cs16/weapon_m3"
#include "cs16/weapon_awp"
#include "cs16/weapon_p90"
#include "cs16/weapon_p228"
#include "cs16/weapon_dualelites"
#include "cs16/weapon_sg552"
#include "cs16/weapon_csm249"
#include "cs16/weapon_ump45"
#include "cs16/weapon_famas"
#include "cs16/weapon_sg550"
#include "cs16/weapon_g3sg1"
#include "cs16/weapon_csknife"
#include "cs16/weapon_tmp"
#include "cs16/weapon_galil"
#include "cs16/weapon_fiveseven"
#include "cs16/weapon_xm1014"
#include "cs16/weapon_mac10"
#include "cs16/weapon_scout"
#include "cs16/weapon_csglock18"
#include "cs16/func_vehicle_fix"

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
	RegisterXM1014Shotty();
	RegisterMAC10();
	RegisterSCOUT();
	RegisterGLOCK18();
	
	VehicleMapInit( true );
	
	g_Scheduler.SetInterval( "CheckVehicle", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
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
