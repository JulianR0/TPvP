/* 
* DeathMatch Classic: Rockets Ammunition
*/

const int ROCKETS_MAX_CARRY = 100;

class DMCRocketAmmo : ScriptBasePlayerAmmoEntity
{
	int ammo_rockets = 5;
	
	void Spawn()
	{
		Precache();
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_BIG_AMMOBOX ) == SF_BIG_AMMOBOX )
		{
			g_EntityFuncs.SetModel( self, "models/dmc/w_rpgammo_big.mdl" );
			ammo_rockets *= 2;
		}
		else
			g_EntityFuncs.SetModel( self, "models/dmc/w_rpgammo.mdl" );
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/w_rpgammo.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_rpgammo_big.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_rpgammot.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_rpgammo_bigT.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/lock4.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/lock4.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( ammo_rockets, "dmcrockets", ROCKETS_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "weapons/dmc/lock4.wav", 1.0, ATTN_NORM );
			return true;
		}
		
		return false;
	}
}

string GetDMCRocketAmmoName()
{
	return "ammo_dmcrockets";
}

void RegisterDMCRocketAmmo()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DMCRocketAmmo", GetDMCRocketAmmoName() );
}
