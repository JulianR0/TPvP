/* 
* Not really Kevlar
*/

class CSArmorItem : ScriptBasePlayerAmmoEntity // Should be BasePlayerItem. Using BasePlayerAmmo + AddAmmo() for easier implement. -Giegue
{
	float m_flArmorValue;
	float m_flArmorType;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, "models/kevlar/w_kevlar.mdl" );
		
		m_flArmorValue = 100;
		m_flArmorType = 0.1;
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/kevlar/w_kevlar.mdl" );
		g_SoundSystem.PrecacheSound( "items/ammopickup2.wav" );
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
		
		g_SoundSystem.EmitSound( pOther.edict(), CHAN_ITEM, "items/ammopickup2.wav", 1.0, ATTN_NORM );
		return true;
	}
}

string GetCSKevlarName()
{
	return "item_kevlar";
}

void RegisterKevlar()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CSArmorItem", GetCSKevlarName() );
}
