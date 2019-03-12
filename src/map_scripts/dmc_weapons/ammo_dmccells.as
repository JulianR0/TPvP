/* 
* DeathMatch Classic: Cells Ammunition
*/

const int CELLS_MAX_CARRY = 100;

class DMCCellAmmo : ScriptBasePlayerAmmoEntity
{
	int ammo_cells = 6;
	
	void Spawn()
	{
		Precache();
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_BIG_AMMOBOX ) == SF_BIG_AMMOBOX )
		{
			g_EntityFuncs.SetModel( self, "models/dmc/w_batteryl.mdl" );
			ammo_cells *= 2;
		}
		else
			g_EntityFuncs.SetModel( self, "models/dmc/w_battery.mdl" );
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/w_battery.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_batteryl.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_batteryt.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_batterylT.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/lock4.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/lock4.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( ammo_cells, "dmccells", CELLS_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "weapons/dmc/lock4.wav", 1.0, ATTN_NORM );
			return true;
		}
		
		return false;
	}
}

string GetDMCCellAmmoName()
{
	return "ammo_dmccells";
}

void RegisterDMCCellAmmo()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DMCCellAmmo", GetDMCCellAmmoName() );
}
