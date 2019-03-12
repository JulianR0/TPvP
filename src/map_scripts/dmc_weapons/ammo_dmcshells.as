/* 
* DeathMatch Classic: Shells Ammunition
*/

const int SHELLS_MAX_CARRY = 100;

class DMCShellAmmo : ScriptBasePlayerAmmoEntity
{
	int ammo_shells = 20;
	
	void Spawn()
	{
		Precache();
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_BIG_AMMOBOX ) == SF_BIG_AMMOBOX )
		{
			g_EntityFuncs.SetModel( self, "models/dmc/w_shotbox_big.mdl" );
			ammo_shells *= 2;
		}
		else
			g_EntityFuncs.SetModel( self, "models/dmc/w_shotbox.mdl" );
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/w_shotbox.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_shotbox_big.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_shotbox_bigT.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_shotboxt.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/lock4.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/lock4.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( ammo_shells, "dmcshells", SHELLS_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "weapons/dmc/lock4.wav", 1.0, ATTN_NORM );
			return true;
		}
		
		return false;
	}
}

string GetDMCShellAmmoName()
{
	return "ammo_dmcshells";
}

void RegisterDMCShellAmmo()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DMCShellAmmo", GetDMCShellAmmoName() );
}
