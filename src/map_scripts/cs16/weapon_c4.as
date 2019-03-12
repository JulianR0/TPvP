const int C4_DEFAULT_GIVE = 1;
const int C4_MAX_CARRY = 1;
const int C4_MAX_CLIP = WEAPON_NOCLIP;
const int C4_WEIGHT = -1;

enum c4_e
{
	C4_IDLE1 = 0,
	C4_DRAW,
	C4_DROP,
	C4_ARM
};

class C4Zone : ScriptBaseEntity
{
	void Spawn()
	{
		self.pev.solid = SOLID_TRIGGER;
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.effects = EF_NODRAW;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin ); // set size and link into world
		g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
		g_EntityFuncs.SetModel( self, self.pev.model );
	}
}

class C4Grenade : ScriptBaseMonsterEntity
{
	float m_flC4Blow;
	float m_flNextFreqInterval;
	float m_flNextFreq;
	float m_flNextBeep;
	float m_flNextBlink;
	
	int m_iCurWave;
	float m_fAttenu;
	string m_sBeepName;
	
	float m_fNextDefuse;
	
	bool m_bStartDefuse;
	float m_fDisarmStart;
	
	CBasePlayer@ m_pBombDefuser;
	float m_flDefuseCountDown;
	string m_szTeam;
	
	void Spawn()
	{
		Precache();
		
		self.pev.movetype = MOVETYPE_TOSS;
		self.pev.solid = SOLID_BBOX;
		self.m_bloodColor = DONT_BLEED;
		
		g_EntityFuncs.SetModel( self, "models/c4/w_c4.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( -3, -6, -8 ), Vector( 3, 6, 8 ) );
		
		self.pev.dmg = 600;
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/c4/w_c4.mdl" );
		g_Game.PrecacheModel( "sprites/cs_weapons/c_laserdot.spr" );
		g_Game.PrecacheModel( "sprites/cs_weapons/s_laserdot.spr" );
		
		g_SoundSystem.PrecacheSound( "weapons/c4_beep1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_beep2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_beep3.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_beep4.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_beep5.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/c4_disarm.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_disarmed.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_plant.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/c4_plantnotice.wav" );
		g_SoundSystem.PrecacheSound( "weapons/c4_defusenotice.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/c4_beep1.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_beep2.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_beep3.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_beep4.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_beep5.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_disarm.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_disarmed.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_plant.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_plantnotice.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_defusenotice.wav" );
	}
	
	int	ObjectCaps()
	{
		return ( BaseClass.ObjectCaps() | FCAP_CONTINUOUS_USE ) & ~FCAP_ACROSS_TRANSITION;
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		//int barTime = 7.5;
		
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( pActivator.entindex() );
		
		if ( string( pPlayer.pev.targetname ) != m_szTeam ) // Only the opposing team should be able to defuse
		{
			CustomKeyvalues@ pKVD = pPlayer.GetCustomKeyvalues();
			CustomKeyvalue iLevel_pre( pKVD.GetKeyvalue( "$i_player_level" ) );
			int iLevel = iLevel_pre.GetInteger();
			
			float flModifier = 100.0;
			if ( iLevel >= 22 ) flModifier -= 2.0;
			if ( iLevel >= 41 ) flModifier -= 2.0;
			if ( iLevel >= 62 ) flModifier -= 2.0;
			if ( iLevel >= 78 ) flModifier -= 2.0;
			
			if ( m_bStartDefuse )
			{
				m_fNextDefuse = g_Engine.time + 0.5;
				
				float flProgress = ( g_Engine.time - m_fDisarmStart ) * 100.0 / ( 7.6 * flModifier / 100.0 );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Desarmando bomba...\n(" + int( flProgress ) + "%)\n" );
				
				return;
			}
			
			pPlayer.pev.maxspeed = 1.0;
			
			g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Desarmando bomba...\n(0%)\n" );
			g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, "weapons/c4_disarm.wav", VOL_NORM, ATTN_NORM );
			
			@m_pBombDefuser = pPlayer;
			m_bStartDefuse = true;
			
			m_flDefuseCountDown = g_Engine.time + ( 7.5 * flModifier / 100.0 );
			m_fDisarmStart = g_Engine.time;
			
			m_fNextDefuse = g_Engine.time + 0.5;
			
			//barTime = 7.5;
		}
	}
	
	void C4Think()
	{
		if ( !self.IsInWorld() )
		{
			g_EntityFuncs.Remove( self );
			return;
		}
		
		self.pev.nextthink = g_Engine.time + 0.12;
		
		if ( g_Engine.time >= m_flNextFreq )
		{
			m_flNextFreq = g_Engine.time + m_flNextFreqInterval;
			m_flNextFreqInterval *= 0.9;
			
			switch ( m_iCurWave )
			{
				case 0:
				{
					m_sBeepName = "weapons/c4_beep1.wav";
					m_fAttenu = 1.5;
					break;
				}
				case 1:
				{
					m_sBeepName = "weapons/c4_beep2.wav";
					m_fAttenu = 1.0;
					break;
				}
				case 2:
				{
					m_sBeepName = "weapons/c4_beep3.wav";
					m_fAttenu = 0.8;
					break;
				}
				case 3:
				{
					m_sBeepName = "weapons/c4_beep4.wav";
					m_fAttenu = 0.5;
					break;
				}
				case 4:
				{
					m_sBeepName = "weapons/c4_beep5.wav";
					m_fAttenu = 0.2;
					break;
				}
			}
			
			++m_iCurWave;
		}
		
		if ( m_flNextBeep < g_Engine.time )
		{
			m_flNextBeep = g_Engine.time + 1.4;
			g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, m_sBeepName, VOL_NORM, m_fAttenu );
		}

		if ( m_flNextBlink < g_Engine.time )
		{
			m_flNextBlink = g_Engine.time + 2.0;
			
			uint8 a, b, c;
			a = 1;
			b = 10;
			c = 255;
			
			NetworkMessage msg( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin, null );
			msg.WriteByte( TE_GLOWSPRITE );
			msg.WriteCoord( self.pev.origin.x );
			msg.WriteCoord( self.pev.origin.y );
			msg.WriteCoord( self.pev.origin.z + 5.0 );
			if ( m_szTeam == 'spiral' ) msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/cs_weapons/s_laserdot.spr" ) );
			else if ( m_szTeam == 'crimson' ) msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/cs_weapons/c_laserdot.spr" ) );
			else msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/error.spr" ) );
			msg.WriteByte( a );
			msg.WriteByte( b );
			msg.WriteByte( c );
			msg.End();
		}
		
		if ( m_flC4Blow <= g_Engine.time )
		{
			CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
			
			if ( pOwner !is null )
			{
				pOwner.pev.frags += 3;
			}
			
			// Plugin should take care of this
			SuccessDetonate( m_szTeam );
			
			if ( m_szTeam == 'spiral' )
			{
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Los Spiral explotaron la bomba!\n" );
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Spiral explotaron la bomba!\n" );
			}
			else if ( m_szTeam == 'crimson' )
			{
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Los Crimson explotaron la bomba!\n" );
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Crimson explotaron la bomba!\n" );
			}
			
			Vector pOrigin = self.pev.origin;
			pOrigin.z += 5.0;
			
			// We do another one just to show the effect
			g_EntityFuncs.CreateExplosion( pOrigin, Vector( 0, 0, 0 ), null, 400, false );
			
			g_EntityFuncs.CreateExplosion( pOrigin, Vector( 0, 0, 0 ), null, int( self.pev.dmg ), true );
			
			// Someone might has been defusing the bomb here. Forcefully kill
			if ( m_pBombDefuser !is null )
				m_pBombDefuser.TakeDamage( self.pev, self.pev, 10000.0, ( DMG_BLAST | DMG_ALWAYSGIB ) );
			
			g_EntityFuncs.Remove( self );
		}
		
		if ( m_bStartDefuse )
		{
			if ( m_pBombDefuser !is null && m_flDefuseCountDown > g_Engine.time )
			{
				bool onGround = true;
				if ( !( ( m_pBombDefuser.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
				{
					onGround = false;
				}

				if ( !onGround || m_fNextDefuse < g_Engine.time )
				{
					if ( !onGround )
					{
						g_EngineFuncs.ClientPrintf( m_pBombDefuser, print_center, "Debes estar en tierra firme\n" );
					}
					
					m_pBombDefuser.pev.maxspeed = 0;
					
					m_bStartDefuse = false;
					m_flDefuseCountDown = 0.0;
				}
			}
			else
			{
				// Plugin should take care of this
				SuccessDefuse( m_szTeam );
				
				if ( m_pBombDefuser.pev.targetname == 'spiral' )
				{
					g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Los Spiral han desarmado la bomba!\n" );
					g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Spiral han desarmado la bomba!\n" );
				}
				else if ( m_pBombDefuser.pev.targetname == 'crimson' )
				{
					g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Los Crimson han desarmado la bomba!\n" );
					g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Crimson han desarmado la bomba!\n" );
				}
				
				g_SoundSystem.EmitSound( m_pBombDefuser.edict(), CHAN_VOICE, "weapons/c4_defusenotice.wav", VOL_NORM, ATTN_NONE );
				
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "weapons/c4_beep5.wav", 0, ATTN_NONE, SND_STOP, 0 ); // ???
				g_SoundSystem.EmitSound( m_pBombDefuser.edict(), CHAN_WEAPON, "weapons/c4_disarmed.wav", 0.8, ATTN_NORM );
				
				g_EntityFuncs.Remove( self );
				
				m_pBombDefuser.pev.maxspeed = 0;
				
				m_pBombDefuser.pev.frags += 3;
			}
		}
	}

	void C4Touch( CBaseEntity@ pOther )
	{
		// Nothing.
	}
	
	void SuccessDetonate( const string& in szTeam )
	{
		CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
		CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
		
		if ( szTeam == 'spiral' )
		{
			pCustom.SetKeyvalue( "$i_extra_spiral", 6 );
			
			CustomKeyvalue pre_C4SpiralDetonate( pCustom.GetKeyvalue( "$i_c4_spiral_detonate" ) );
			if ( pre_C4SpiralDetonate.Exists() )
			{
				// Store here the amount of times a C4 bomb was successfully detonated
				int C4SpiralDetonate = pre_C4SpiralDetonate.GetInteger();
				C4SpiralDetonate++;
				
				pCustom.SetKeyvalue( "$i_c4_spiral_detonate", C4SpiralDetonate );
			}
			else
			{
				// Initialize
				pCustom.SetKeyvalue( "$i_c4_spiral_detonate", 1 );
			}
		}
		else if ( szTeam == 'crimson' )
		{
			pCustom.SetKeyvalue( "$i_extra_crimson", 6 );
			
			CustomKeyvalue pre_C4CrimsonDetonate( pCustom.GetKeyvalue( "$i_c4_crimson_detonate" ) );
			if ( pre_C4CrimsonDetonate.Exists() )
			{
				// Store here the amount of times a C4 bomb was successfully detonated
				int C4CrimsonDetonate = pre_C4CrimsonDetonate.GetInteger();
				C4CrimsonDetonate++;
				
				pCustom.SetKeyvalue( "$i_c4_crimson_detonate", C4CrimsonDetonate );
			}
			else
			{
				// Initialize
				pCustom.SetKeyvalue( "$i_c4_crimson_detonate", 1 );
			}
		}
	}

	void SuccessDefuse( const string& in szTeam )
	{
		CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
		CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
		
		if ( szTeam == 'spiral' )
		{
			pCustom.SetKeyvalue( "$i_extra_crimson", 6 );
			
			CustomKeyvalue pre_C4CrimsonDefuse( pCustom.GetKeyvalue( "$i_c4_crimson_defuse" ) );
			if ( pre_C4CrimsonDefuse.Exists() )
			{
				// Store here the amount of times a C4 bomb was successfully defused
				int C4CrimsonDefuse = pre_C4CrimsonDefuse.GetInteger();
				C4CrimsonDefuse++;
				
				pCustom.SetKeyvalue( "$i_c4_crimson_defuse", C4CrimsonDefuse );
			}
			else
			{
				// Initialize
				pCustom.SetKeyvalue( "$i_c4_crimson_defuse", 1 );
			}
		}
		else if ( szTeam == 'crimson' )
		{
			pCustom.SetKeyvalue( "$i_extra_spiral", 6 );
			
			CustomKeyvalue pre_C4SpiralDefuse( pCustom.GetKeyvalue( "$i_c4_spiral_defuse" ) );
			if ( pre_C4SpiralDefuse.Exists() )
			{
				// Store here the amount of times a C4 bomb was successfully defused
				int C4SpiralDefuse = pre_C4SpiralDefuse.GetInteger();
				C4SpiralDefuse++;
				
				pCustom.SetKeyvalue( "$i_c4_spiral_defuse", C4SpiralDefuse );
			}
			else
			{
				// Initialize
				pCustom.SetKeyvalue( "$i_c4_spiral_defuse", 1 );
			}
		}
	}
	
	void cSetThink()
	{
		SetThink( ThinkFunction( C4Think ) );
	}
	
	void cSetTouch()
	{
		SetTouch( TouchFunction( C4Touch ) );
	}
}

C4Grenade@ ShootSatchelCharge( entvars_t@ pevOwner, Vector& in vecStart, Vector& in vecVelocity )
{
	CBaseEntity@ pre_pGrenade = g_EntityFuncs.CreateEntity( "c4", null, false );
	C4Grenade@ pGrenade = cast<C4Grenade@>(CastToScriptClass(pre_pGrenade));
	
	pGrenade.Spawn();
	
	pGrenade.pev.movetype = MOVETYPE_TOSS;
	pGrenade.pev.solid = SOLID_BBOX;
	
	g_EntityFuncs.SetModel( pGrenade.self, "models/c4/w_c4.mdl" );
	
	g_EntityFuncs.SetSize( pGrenade.pev, Vector( -3, -6, -8 ), Vector( 3, 6, 8 ) );
	g_EntityFuncs.SetOrigin( pGrenade.self, vecStart );
	
	pGrenade.pev.dmg = 600;
	pGrenade.pev.angles = vecVelocity;
	pGrenade.pev.velocity = g_vecZero;
	
	CBaseEntity@ pOwner = g_EntityFuncs.Instance( pevOwner );
	
	CustomKeyvalues@ pKVD = pOwner.GetCustomKeyvalues();
	CustomKeyvalue iLevel_pre( pKVD.GetKeyvalue( "$i_player_level" ) );
	int iLevel = iLevel_pre.GetInteger();
	
	@pGrenade.pev.owner = @pOwner.edict();
	pGrenade.m_szTeam = string( pOwner.pev.targetname );
	
	pGrenade.cSetThink();
	pGrenade.cSetTouch();
	
	//pGrenade.pev.spawnflags = SF_DETONATE;
	pGrenade.pev.nextthink = g_Engine.time + 0.1;
	
	float flModifier = 100.0;
	if ( iLevel >= 22 ) flModifier -= 2.0;
	if ( iLevel >= 41 ) flModifier -= 2.0;
	if ( iLevel >= 62 ) flModifier -= 2.0;
	if ( iLevel >= 78 ) flModifier -= 2.0;
	
	pGrenade.m_flC4Blow = g_Engine.time + ( 45.0 * flModifier / 100.0 );
	pGrenade.m_flNextFreqInterval = ( 45.0 * flModifier / 100.0 ) / 4.0;
	
	pGrenade.m_flNextFreq = g_Engine.time;
	pGrenade.m_flNextBeep = g_Engine.time + 0.5;
	pGrenade.m_flNextBlink = g_Engine.time + 2.0;
	
	pGrenade.m_iCurWave	= 0;
	pGrenade.m_fAttenu = 0.0;
	pGrenade.m_sBeepName = "";
	
	pGrenade.m_fNextDefuse = 0;
	
	pGrenade.m_bStartDefuse = false;
	
	pGrenade.pev.friction = 0.9;
	
	if ( FNullEnt( pevOwner ) )
	{
		g_EntityFuncs.Remove( pGrenade.self );
	}
	
	return pGrenade;
}

class weapon_c4 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	bool m_bStartedArming;
	float m_fArmedTime;
	float m_fArmStart;
	bool m_bBombPlacedAnimation;
	C4Grenade@ pGrenade;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, "models/c4/w_backpack.mdl" );
		
		self.pev.frame = 0;
		self.pev.body = 3;
		self.pev.sequence = 0;
		self.pev.framerate = 0;
		self.m_iDefaultAmmo = C4_DEFAULT_GIVE;
		m_bStartedArming = false;
		m_fArmedTime = 0.0;
		m_bBombPlacedAnimation = false;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/c4/v_c4.mdl" );
		g_Game.PrecacheModel( "models/c4/w_c4.mdl" );
		g_Game.PrecacheModel( "models/c4/p_c4.mdl" );
		g_Game.PrecacheModel( "models/c4/w_backpack.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/c4_click.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/c4_click.wav" );
		
		g_Game.PrecacheOther( "c4" );
		
		g_Game.PrecacheGeneric( "sprites/cs_weapons/weapon_c4.txt" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= C4_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= C4_MAX_CLIP;
		info.iSlot 		= 4;
		info.iPosition 	= 7;
		info.iFlags 	= ( ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE );
		info.iWeight 	= C4_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
		
		@m_pPlayer = pPlayer;
		
		return true;
	}
	
	bool Deploy()
	{
		self.pev.body = 0;
		
		m_bStartedArming = false;
		m_fArmedTime = 0.0;
		
		return self.DefaultDeploy( self.GetV_Model( "models/c4/v_c4.mdl" ), self.GetP_Model( "models/c4/p_c4.mdl" ), C4_DRAW, "trip" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		
		m_bStartedArming = false;
		m_pPlayer.pev.maxspeed = 0;
	}
	
	void InactiveItemPostFrame()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			self.DestroyItem();
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}
	
	void PrimaryAttack()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			return;
		}
		
		bool onBombZone = false;
		bool onGround = true;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			onGround = false;
		}
		
		// FIX: Iterate through all bomb zones and check if we are inside
		CBaseEntity@ pBombZone = null;
		while ( ( @pBombZone = g_EntityFuncs.FindEntityByClassname( pBombZone, "func_bomb_target" ) ) !is null )
		{
			if ( m_pPlayer.Intersects( pBombZone ) )
			{
				onBombZone = true;
			}
		}
		
		if ( !m_bStartedArming )
		{
			if ( !onBombZone )
			{
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "La C4 no puede usarse aqui\n" );
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
				return;
			}

			if ( !onGround )
			{
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Debes estar en tierra firme\n" );
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 1;
				return;
			}
			
			m_bStartedArming = true;
			m_bBombPlacedAnimation = false;
			m_fArmStart = WeaponTimeBase();
			m_fArmedTime = WeaponTimeBase() + 3.0;
			
			self.SendWeaponAnim( C4_ARM );
			m_pPlayer.pev.maxspeed = 1.0;
		}
		else
		{
			if ( !onGround || !onBombZone )
			{
				if ( onBombZone )
					g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Debes estar en tierra firme\n" );
				else
					g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "La C4 no puede usarse aqui\n" );
				
				m_bStartedArming = false;
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.5;
				
				m_pPlayer.pev.maxspeed = 0;
				
				self.SendWeaponAnim( m_bBombPlacedAnimation ? C4_DRAW : C4_IDLE1 );
				
				return;
			}
			
			if ( WeaponTimeBase() >= m_fArmedTime )
			{
				if ( m_bStartedArming )
				{
					m_bStartedArming = false;
					m_fArmedTime = 0.0;
					
					CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
					CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
					
					CustomKeyvalue pre_C4Bombs( pCustom.GetKeyvalue( "$i_c4_times" ) );
					if ( pre_C4Bombs.Exists() )
					{
						// Store here the amount of times a C4 bomb was planted
						int C4Bombs = pre_C4Bombs.GetInteger();
						C4Bombs++;
						
						pCustom.SetKeyvalue( "$i_c4_times", C4Bombs );
					}
					else
					{
						// Initialize
						pCustom.SetKeyvalue( "$i_c4_times", 1 );
					}
					
					if ( m_pPlayer.pev.targetname == 'spiral' )
					{
						g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Los Spiral han colocado la bomba!\n" );
						g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Spiral han colocado la bomba!\n" );
					}
					else if ( m_pPlayer.pev.targetname == 'crimson' )
					{
						g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Los Crimson han colocado la bomba!\n" );
						g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Crimson han colocado la bomba!\n" );
					}
					
					g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "weapons/c4_plantnotice.wav", VOL_NORM, ATTN_NONE );
					
					@pGrenade = ShootSatchelCharge( m_pPlayer.pev, m_pPlayer.pev.origin, Vector( 0, 0, 0 ) );
					
					g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/c4_plant.wav", VOL_NORM, ATTN_NORM );

					m_pPlayer.pev.maxspeed = 0;
					
					m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
					
					if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
					{
						self.RetireWeapon();
						return;
					}
				}
				else
				{
					if ( WeaponTimeBase() >= m_fArmedTime - 0.75 && !m_bBombPlacedAnimation )
					{
						m_bBombPlacedAnimation = true;
						
						self.SendWeaponAnim( C4_DROP );
					}
				}
			}
		}
		
		if ( m_bStartedArming )
		{
			float flProgress = ( WeaponTimeBase() - m_fArmStart ) * 100.0 / 3.1;
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "(" + int( flProgress ) + "%)\n" );
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
	
	void WeaponIdle()
	{
		if ( m_bStartedArming )
		{
			m_bStartedArming = false;
			
			m_pPlayer.pev.maxspeed = 0;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
			
			self.SendWeaponAnim( m_bBombPlacedAnimation ? C4_DRAW : C4_IDLE1 );
		}
		
		if ( self.m_flTimeWeaponIdle <= WeaponTimeBase() )
		{
			if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				self.RetireWeapon();
				return;
			}
			
			self.SendWeaponAnim( C4_DRAW );
			self.SendWeaponAnim( C4_IDLE1 );
		}
	}
}

class C4Ammo : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, "models/c4/w_backpack.mdl" );
		self.pev.frame = 0;
		self.pev.body = 3;
		self.pev.sequence = 0;
		self.pev.framerate = 0;
		
		BaseClass.Spawn();
	}

	void Precache()
	{
		g_Game.PrecacheModel( "models/c4/w_backpack.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		if( pOther.GiveAmmo( 1, "weapon_c4", C4_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetC4Name()
{
	return "weapon_c4";
}

void RegisterC4()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "C4Zone", "func_bomb_target" );
	g_CustomEntityFuncs.RegisterCustomEntity( "C4Grenade", "c4" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_c4", GetC4Name() );
	g_ItemRegistry.RegisterWeapon( GetC4Name(), "cs_weapons", "weapon_c4" );
	//g_CustomEntityFuncs.RegisterCustomEntity( "C4Ammo", "weapon_c4" );
}
