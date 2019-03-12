/*

-- Starting Weapons --

weapon_crowbar
weapon_pipewrench
weapon_9mmhandgun

-- Pickup(-able) Weapons --

weapon_357
weapon_uzi
weapon_mp5
weapon_shotgun
weapon_crossbow
weapon_m16
weapon_handgrenade
weapon_satchel
weapon_saw
weapon_displacer


ENTITY REPLACEMENT:

Egon = SAW
Gauss = Displacer
RPG = M16
Snark = <delete>
TripMine = <delete>
Hornet = Uzi
M16 Grenades = <delete>
RPG Ammo = 556 Clip ammo

*/

void MapInit()
{
	g_Scheduler.SetInterval( "GrenadeCheck", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void GrenadeCheck()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "grenade" ) ) !is null )
	{
		ent.pev.dmg = 60.0;
	}
}
