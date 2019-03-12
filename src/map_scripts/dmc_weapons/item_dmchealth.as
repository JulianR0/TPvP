/* 
* DeathMatch Classic: Health Item
*/

// Health SpawnFlags
const int SF_HP_ROTTEN = 1;
const int SF_HP_MEGA = 2;

class DMCHealthItem : ScriptBasePlayerAmmoEntity // Should be BasePlayerItem. Using BasePlayerAmmo + AddAmmo() for easier implement. -Giegue
{
	int m_iHealAmount;
	
	void Spawn()
	{
		Precache();
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_HP_ROTTEN ) == SF_HP_ROTTEN )
		{
			g_EntityFuncs.SetModel( self, "models/dmc/w_medkits.mdl" );
			self.pev.noise = string_t( "weapons/dmc/r_item1.wav" );
			m_iHealAmount = 15;
		}
		else
		{
			bCheck = self.pev.spawnflags;
			if ( ( bCheck &= SF_HP_MEGA ) == SF_HP_MEGA )
			{
				g_EntityFuncs.SetModel( self, "models/dmc/w_medkitl.mdl" );
				self.pev.noise = string_t( "weapons/dmc/r_item2.wav" );
				m_iHealAmount = 100;
			}
			else
			{
				g_EntityFuncs.SetModel( self, "models/dmc/w_medkit.mdl" );
				self.pev.noise = string_t( "weapons/dmc/health1.wav" );
				m_iHealAmount = 25;
			}
		}
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/w_medkit.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_medkits.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_medkitl.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_medkitt.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_medkitsT.mdl" );
		g_Game.PrecacheModel( "models/dmc/w_medkitlT.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/r_item1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/dmc/r_item2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/dmc/health1.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/r_item1.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/r_item2.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/health1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_HP_MEGA ) == SF_HP_MEGA )
		{
			if ( pOther.TakeHealth( m_iHealAmount, DMG_GENERIC, 200 ) ) // Limit to 200 HP max to prevent abuse of item respawning. -Giegue
			{
				g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, string( self.pev.noise ), 1.0, ATTN_NORM );
				return true;
			}
		}
		else
		{
			if ( pOther.TakeHealth( m_iHealAmount, DMG_GENERIC, 100 ) ) // Standard 100 HP limit
			{
				g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, string( self.pev.noise ), 1.0, ATTN_NORM );
				return true;
			}
		}
		
		return false;
	}
}

string GetDMCHealthItemName()
{
	return "item_dmchealth";
}

void RegisterDMCHealthItem()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DMCHealthItem", GetDMCHealthItemName() );
}
