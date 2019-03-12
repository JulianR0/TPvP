/*
* Classic HL Health Charger
*/

class CWallHealth : ScriptBaseEntity
{
	float m_flNextCharge; 
	int m_iReactivate; // DeathMatch Delay until reactvated
	int m_iJuice;
	int m_iOn; // 0 = off, 1 = startup, 2 = going
	float m_flSoundTime;
	
	void Spawn()
	{
		Precache();
		
		self.pev.solid = SOLID_BSP;
		self.pev.movetype = MOVETYPE_PUSH;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin ); // set size and link into world
		g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
		g_EntityFuncs.SetModel( self, self.pev.model );
		
		m_iJuice = 60;
		self.pev.frame = 0;	
	}
	
	void Precache()
	{
		g_SoundSystem.PrecacheSound( "items/medshot4.wav" );
		g_SoundSystem.PrecacheSound( "items/medshotno1.wav" );
		g_SoundSystem.PrecacheSound( "items/medcharge4.wav" );
	}
	
	int	ObjectCaps()
	{
		return ( BaseClass.ObjectCaps() | FCAP_CONTINUOUS_USE ) & ~FCAP_ACROSS_TRANSITION;
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		// Make sure that we have a caller
		if ( pActivator is null )
			return;
		// if it's not a player, ignore
		if ( !pActivator.IsPlayer() )
			return;
		
		// if there is no juice left, turn it off
		if ( m_iJuice <= 0 )
		{
			self.pev.frame = 1;			
			Off();
		}
		
		// if there is no juice left, make the deny noise
		if ( m_iJuice <= 0 )
		{
			if ( m_flSoundTime <= g_Engine.time )
			{
				m_flSoundTime = g_Engine.time + 0.62;
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/medshotno1.wav", 1.0, ATTN_NORM );
			}
			return;
		}
		
		self.pev.nextthink = self.pev.ltime + 0.25;
		SetThink( ThinkFunction( Off ) );

		// Time to recharge yet?
		
		if ( m_flNextCharge >= g_Engine.time )
			return;
		
		// Play the on sound or the looping charging sound
		if ( m_iOn == 0 )
		{
			m_iOn++;
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/medshot4.wav", 1.0, ATTN_NORM );
			m_flSoundTime = 0.56 + g_Engine.time;
		}
		if ( m_iOn == 1 && m_flSoundTime <= g_Engine.time )
		{
			m_iOn++;
			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "items/medcharge4.wav", 1.0, ATTN_NORM );
		}
		
		
		// charge the player
		if ( pActivator.TakeHealth( 1, DMG_GENERIC ) )
		{
			m_iJuice--;
		}
		
		// govern the rate of charge
		m_flNextCharge = g_Engine.time + 0.1;
	}
	
	void Recharge()
	{
		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/medshot4.wav", 1.0, ATTN_NORM );
		m_iJuice = 60;
		self.pev.frame = 0;			
		SetThink( ThinkFunction( dummythink ) );
	}
	
	void Off()
	{
		// Stop looping sound.
		if ( m_iOn > 1 )
			g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, "items/medcharge4.wav" );
		
		m_iOn = 0;
		
		if ( m_iJuice == 0 && ( m_iReactivate = 60 ) > 0 )
		{
			self.pev.nextthink = self.pev.ltime + m_iReactivate;
			SetThink( ThinkFunction( Recharge ) );
		}
		else
			SetThink( ThinkFunction( dummythink ) );
	}
	
	void dummythink()
	{
		// Dummy
	}
}

string GetHLHPChargerName()
{
	return "func_hlhealthcharger";
}

void RegisterHLHPCharger()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CWallHealth", GetHLHPChargerName() );
}
