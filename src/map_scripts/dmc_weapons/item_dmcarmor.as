/* 
* DeathMatch Classic: Armor Item
*/

// Armor SpawnFlags
const int SF_AP_GREEN = 1;
const int SF_AP_RED = 2;

class DMCArmorItem : ScriptBasePlayerAmmoEntity // Should be BasePlayerItem. Using BasePlayerAmmo + AddAmmo() for easier implement. -Giegue
{
	float m_flArmorValue;
	float m_flArmorType;
	
	void Spawn()
	{
		Precache();
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= SF_AP_GREEN ) == SF_AP_GREEN )
		{
			// Green armor
			g_EntityFuncs.SetModel( self, "models/dmc/armour_g.mdl" );
			
			m_flArmorValue = 100;
			m_flArmorType = 0.3;
		}
		else
		{
			bCheck = self.pev.spawnflags;
			if ( ( bCheck &= SF_AP_RED ) == SF_AP_RED )
			{
				// Red armor
				g_EntityFuncs.SetModel( self, "models/dmc/armour_r.mdl" );
				
				m_flArmorValue = 200;
				m_flArmorType = 0.8;
			}
			else
			{
				// Yellow armor
				g_EntityFuncs.SetModel( self, "models/dmc/armour_y.mdl" );
				
				m_flArmorValue = 150;
				m_flArmorType = 0.6;
			}
		}
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/armour_g.mdl" );
		g_Game.PrecacheModel( "models/dmc/armour_y.mdl" );
		g_Game.PrecacheModel( "models/dmc/armour_r.mdl" );
		g_Game.PrecacheModel( "models/dmc/armour_gT.mdl" );
		g_Game.PrecacheModel( "models/dmc/armour_yT.mdl" );
		g_Game.PrecacheModel( "models/dmc/armour_rT.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/armor1.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/armor1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( !pOther.IsAlive() )
			return false;
		
		CustomKeyvalues@ pKVD = pOther.GetCustomKeyvalues();
		CustomKeyvalue pre_ArmorAmount( pKVD.GetKeyvalue( "$f_armor_value" ) );
		CustomKeyvalue pre_ArmorCoverage( pKVD.GetKeyvalue( "$f_armor_type" ) );
		float plr_flArmorType = pre_ArmorCoverage.GetFloat();
		float plr_flArmorValue = pre_ArmorAmount.GetFloat();
		
		// Don't pickup if this armor isn't as good as the stuff we've got
		if ( ( plr_flArmorType * plr_flArmorValue ) >= ( m_flArmorType * m_flArmorValue ) )
			return false;
		
		pKVD.SetKeyvalue( "$f_armor_type", m_flArmorType );
		pKVD.SetKeyvalue( "$f_armor_value", m_flArmorValue );
		
		// Battery
		NetworkMessage nmArmor( MSG_ONE_UNRELIABLE, NetworkMessages::Battery, pOther.edict() );
		nmArmor.WriteShort( int( m_flArmorValue ) );
		nmArmor.End();
		
		g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "weapons/dmc/armor1.wav", 1.0, ATTN_NORM );
		return true;
	}
}

string GetDMCArmorItemName()
{
	return "item_dmcarmor";
}

void RegisterDMCArmorItem()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DMCArmorItem", GetDMCArmorItemName() );
}
