/* 
* DeathMatch Classic: Nails Ammunition
*/

const int NAILS_MAX_CARRY = 200;

class DMCNailAmmo : ScriptBasePlayerAmmoEntity
{
	int ammo_nails = 25;
	
	void Spawn()
	{
		Precache();
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_BIG_AMMOBOX ) == SF_BIG_AMMOBOX )
		{
			g_EntityFuncs.SetModel( self, "models/dmc/b_nail0.mdl" );
			ammo_nails *= 2;
		}
		else
			g_EntityFuncs.SetModel( self, "models/dmc/b_nail1.mdl" );
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/b_nail0.mdl" );
		g_Game.PrecacheModel( "models/dmc/b_nail1.mdl" );
		g_Game.PrecacheModel( "models/dmc/b_nail0T.mdl" );
		g_Game.PrecacheModel( "models/dmc/b_nail1T.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/lock4.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/lock4.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( ammo_nails, "dmcnails", NAILS_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "weapons/dmc/lock4.wav", 1.0, ATTN_NORM );
			return true;
		}
		
		return false;
	}
}

string GetDMCNailAmmoName()
{
	return "ammo_dmcnails";
}

void RegisterDMCNailAmmo()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DMCNailAmmo", GetDMCNailAmmoName() );
}
