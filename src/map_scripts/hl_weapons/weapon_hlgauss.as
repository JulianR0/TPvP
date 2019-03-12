/* 
* The original Half-Life version of the gloun gun
*/

const int GAUSS_PRIMARY_CHARGE_VOLUME = 256; // how loud gauss is while charging
const int GAUSS_PRIMARY_FIRE_VOLUME = 450; // how loud gauss is when discharged

const int GAUSS_DEFAULT_GIVE = 20;
const int GAUSS_MAX_CARRY = 100;
const int GAUSS_MAX_CLIP = WEAPON_NOCLIP;
const int GAUSS_WEIGHT = 20;

enum gauss_e
{
	GAUSS_IDLE = 0,
	GAUSS_IDLE2,
	GAUSS_FIDGET,
	GAUSS_SPINUP,
	GAUSS_SPIN,
	GAUSS_FIRE,
	GAUSS_FIRE2,
	GAUSS_HOLSTER,
	GAUSS_DRAW
};

class weapon_hlgauss : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iBeam;
	//int m_iSoundState; // don't save this
	
	// has this weapon just fired primary or secondary?
	// we need to know so we can pick the right set of effects. 
	bool m_fPrimaryFire;
	
	// these are present in player.h, but can't be accessed from AngelScript. -Giegue
	float m_flStartCharge;
	float m_flAmmoStartCharge;
	float m_flPlayAftershock;
	float m_flNextAmmoBurn; // while charging, when to absorb another unit of player's ammo? 
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_gauss.mdl" );
		
		self.m_iDefaultAmmo = GAUSS_DEFAULT_GIVE;

		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/w_gauss.mdl" );
		g_Game.PrecacheModel( "models/hl/v_gauss.mdl" );
		g_Game.PrecacheModel( "models/hl/p_gauss.mdl" );

		g_SoundSystem.PrecacheSound( "weapons/gauss2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/electro4.wav" );
		g_SoundSystem.PrecacheSound( "weapons/electro5.wav" );
		g_SoundSystem.PrecacheSound( "weapons/electro6.wav" );
		g_SoundSystem.PrecacheSound( "ambience/pulsemachine.wav" );
		
		m_iBeam = g_Game.PrecacheModel( "sprites/laserbeam.spr" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hlgauss.txt" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				message.WriteLong( self.m_iId );
			message.End();
			
			@m_pPlayer = pPlayer;
			
			return true;
		}
		
		return false;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= GAUSS_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= GAUSS_MAX_CLIP;
		info.iSlot 		= 3;
		info.iPosition 	= 6;
		info.iFlags 	= 0;
		info.iWeight 	= GAUSS_WEIGHT;
		
		return true;
	}
	
	bool Deploy()
	{
		m_flPlayAftershock = 0.0;
		return self.DefaultDeploy( self.GetV_Model( "models/hl/v_gauss.mdl" ), self.GetP_Model( "models/hl/p_gauss.mdl" ), GAUSS_DRAW, "gauss" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav" );
		
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		
		self.SendWeaponAnim( GAUSS_HOLSTER );
		self.pev.iuser2 = 0;
	}
	
	void PrimaryAttack()
	{
		// don't fire underwater
		if ( m_pPlayer.pev.waterlevel == 3 )
		{
			self.PlayEmptySound();
			self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}
		
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) < 2 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			return;
		}
		
		m_pPlayer.m_iWeaponVolume = GAUSS_PRIMARY_FIRE_VOLUME;
		m_fPrimaryFire = true;
		
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, iAmmo - 2 );
		
		StartFire();
		self.pev.iuser2 = 0;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
	}
	
	void SecondaryAttack()
	{
		// don't fire underwater
		if ( m_pPlayer.pev.waterlevel == 3 )
		{
			if ( self.pev.iuser2 != 0 )
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro4.wav", 1.0, ATTN_NORM, 0, 80 + Math.RandomLong( 0, 0x3F ) );
				self.SendWeaponAnim( GAUSS_IDLE );
				self.pev.iuser2 = 0;
			}
			else
			{
				self.PlayEmptySound();
			}
			
			self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			return;
		}
		
		if ( self.pev.iuser2 == 0 )
		{
			if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				self.PlayEmptySound();
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
				return;
			}
			
			m_fPrimaryFire = false;
			
			int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo ); // take one ammo just to start the spin
			m_flNextAmmoBurn = WeaponTimeBase();
			
			// spin up
			m_pPlayer.m_iWeaponVolume = GAUSS_PRIMARY_CHARGE_VOLUME;
			
			self.SendWeaponAnim( GAUSS_SPINUP );
			self.pev.iuser2 = 1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.5;
			m_flStartCharge = g_Engine.time;
			m_flAmmoStartCharge = WeaponTimeBase() + GetFullChargeTime();
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav", 1.0, ATTN_NORM, 0, 110 );
			//g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav", 1.0, ATTN_NORM, m_iSoundState, int( m_flAmmoStartCharge - m_flStartCharge ) );
			
			//m_iSoundState = SND_CHANGE_PITCH;
		}
		else if ( self.pev.iuser2 == 1 )
		{
			if ( self.m_flTimeWeaponIdle < WeaponTimeBase() )
			{
				self.SendWeaponAnim( GAUSS_SPIN );
				self.pev.iuser2 = 2;
			}
		}
		else
		{
			// during the charging process, eat one bit of ammo every once in a while
			if ( WeaponTimeBase() >= m_flNextAmmoBurn && m_flNextAmmoBurn != 1000 )
			{
				int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
				m_flNextAmmoBurn = WeaponTimeBase() + 0.175;
			}
			
			if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				// out of ammo! force the gun to fire
				StartFire();
				self.pev.iuser2 = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 1;
				return;
			}
			
			if ( WeaponTimeBase() >= m_flAmmoStartCharge )
			{
				// don't eat any more ammo after gun is fully charged.
				m_flNextAmmoBurn = 1000;
			}

			int pitch = int( ( g_Engine.time - m_flStartCharge ) * ( 150 / GetFullChargeTime() ) + 100 );
			if ( pitch > 250 )
				pitch = 250;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav", 1.0, ATTN_NORM, SND_CHANGE_PITCH, pitch );
			
			m_pPlayer.m_iWeaponVolume = GAUSS_PRIMARY_CHARGE_VOLUME;
			
			// m_flTimeWeaponIdle = UTIL_WeaponTimeBase() + 0.1;
			if ( m_flStartCharge < g_Engine.time - 10 )
			{
				// Player charged up too long. Zap him.
				g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav" );
				
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro4.wav", 1.0, ATTN_NORM, 0, 80 + Math.RandomLong( 0, 0x3F ) );
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "weapons/electro6.wav", 1.0, ATTN_NORM, 0, 75 + Math.RandomLong( 0, 0x3F ) );
				
				self.pev.iuser2 = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
				
				m_pPlayer.TakeDamage( m_pPlayer.pev, m_pPlayer.pev, 50, DMG_SHOCK );
				
				g_PlayerFuncs.ScreenFade( m_pPlayer, Vector( 255, 128, 0 ), 2, 0.5, 128, FFADE_IN );
				
				self.SendWeaponAnim( GAUSS_IDLE );
				
				// Player may have been killed and this weapon dropped, don't execute any more code after this!
				return;
			}
		}
	}
	
	// StartFire: Since all of this code has to run and then call Fire(), it was easier at this point to rip it out of
	// weaponidle() and make its own function then to try to merge this into Fire(), which has some identical variable names 
	void StartFire()
	{
		float flDamage;
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		Vector vecAiming = g_Engine.v_forward;
		Vector vecSrc = m_pPlayer.GetGunPosition(); // + gpGlobals->v_up * -8 + gpGlobals->v_right * 8;
		self.pev.vuser1 = vecSrc + g_Engine.v_up * -8 + g_Engine.v_right * 8;
		
		if ( g_Engine.time - m_flStartCharge > GetFullChargeTime() )
		{
			flDamage = 200;
		}
		else
		{
			flDamage = 200 * ( ( g_Engine.time - m_flStartCharge ) / GetFullChargeTime() );
		}
		
		if ( m_fPrimaryFire )
		{
			// fixed damage on primary attack
			flDamage = 20;
		}
		
		if ( self.pev.iuser2 != 3)
		{
			float flZVel = m_pPlayer.pev.velocity.z;
			
			if ( !m_fPrimaryFire )
			{
				m_pPlayer.pev.velocity = m_pPlayer.pev.velocity - g_Engine.v_forward * flDamage * 5;
			}
			
			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			
			switch( Math.RandomLong( 1, 2 ) )
			{
				case 1: self.SendWeaponAnim( GAUSS_FIRE ); break;
				case 2: self.SendWeaponAnim( GAUSS_FIRE2 ); break;
			}
			
			// don't let the weapon to be rapid-fired with M1/M2 alts
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
		}
		
		// time until aftershock 'static discharge' sound
		m_flPlayAftershock = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0.3, 0.8 );
		
		Fire( vecSrc, vecAiming, flDamage );
	}
	
	void Fire( Vector& in vecOrigSrc, Vector& in vecDir, float flDamage )
	{
		m_pPlayer.m_iWeaponVolume = GAUSS_PRIMARY_FIRE_VOLUME;
		m_pPlayer.pev.punchangle.x = -3.0;
		
		Vector vecSrc = vecOrigSrc;
		Vector vecDest = vecSrc + vecDir * 8192;
		edict_t@ pentIgnore;
		TraceResult tr, beam_tr, effect_tr;
		float flMaxFrac = 1.0;
		int fHasPunched = 0;
		int fFirstBeam = 1;
		int	nMaxHits = 10;
		
		@pentIgnore = @m_pPlayer.edict();
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "weapons/gauss2.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 0xF ) );
		g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav" );
		
		// In the event that the first StopSound does not take effect, send it again after a short delay. -Giegue
		SetThink( ThinkFunction( StopMe ) );
		self.pev.nextthink = g_Engine.time + 0.1;
		
		// Beam effect - START
		Vector vecWeapon = self.pev.vuser1;
		g_Utility.TraceLine( vecSrc, vecDest, dont_ignore_monsters, pentIgnore, effect_tr );
		
		uint8 r, g, b, a, Z_h;
		if ( m_fPrimaryFire )
		{
			r = 250;
			g = 200;
			b = 10;
			Z_h = 9;
		}
		else
		{
			r = 250;
			g = 250;
			b = 250;
			Z_h = 3;
		}
		a = 250;
		
		NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
		msg.WriteByte( TE_BEAMPOINTS );
		msg.WriteCoord( vecWeapon.x );
		msg.WriteCoord( vecWeapon.y );
		msg.WriteCoord( vecWeapon.z );
		msg.WriteCoord( effect_tr.vecEndPos.x );
		msg.WriteCoord( effect_tr.vecEndPos.y );
		msg.WriteCoord( effect_tr.vecEndPos.z );
		msg.WriteShort( m_iBeam );
		msg.WriteByte( 0 ); // framestart
		msg.WriteByte( 1 ); // framerate
		msg.WriteByte( 1 ); // life
		msg.WriteByte( 10 ); // width
		msg.WriteByte( Z_h ); // noise
		msg.WriteByte( r );
		msg.WriteByte( g );
		msg.WriteByte( b );
		msg.WriteByte( a ); // brightness
		msg.WriteByte( 1 ); // scroll rate
		msg.End();
		// Beam effect - END
		
		while ( flDamage > 10 && nMaxHits > 0 )
		{
			nMaxHits--;
			
			g_Utility.TraceLine( vecSrc, vecDest, dont_ignore_monsters, pentIgnore, tr );
			
			if ( tr.fAllSolid > 0 )
				break;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
			
			if ( pEntity is null )
				break;
			
			if ( fFirstBeam > 0 )
			{
				m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
				fFirstBeam = 0;
			}
			
			if ( pEntity.pev.takedamage > 0 )
			{
				g_WeaponFuncs.ClearMultiDamage();
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, vecDir, tr, DMG_BULLET );
				g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
			}
			
			if ( pEntity.ReflectGauss() )
			{
				float Z_n;
				
				@pentIgnore = @null;
				
				Z_n = -( DotProduct( tr.vecPlaneNormal, vecDir ) );
				
				if ( Z_n < 0.5 ) // 60 degrees
				{
					// reflect
					Vector Z_r;
					
					Z_r = 2.0 * tr.vecPlaneNormal * Z_n + vecDir;
					flMaxFrac = flMaxFrac - tr.flFraction;
					vecDir = Z_r;
					vecSrc = tr.vecEndPos + vecDir * 8;
					vecDest = vecSrc + vecDir * 8192;
					
					// explode a bit
					g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, m_pPlayer.pev, flDamage * Z_n, flDamage * 1.75, CLASS_NONE, DMG_BLAST );
					
					// lose energy
					if ( Z_n == 0 ) Z_n = 0.1;
					flDamage = flDamage * ( 1 - Z_n );
				}
				else
				{	
					// limit it to one hole punch
					if ( fHasPunched > 0 )
						break;
					
					fHasPunched = 1;
					
					// DISABLED - No more wallgaussing -Giegue
					flDamage = 0;
					/*
					// try punching through wall if secondary attack (primary is incapable of breaking through)
					if ( !m_fPrimaryFire )
					{
						g_Utility.TraceLine( tr.vecEndPos + vecDir * 8, vecDest, dont_ignore_monsters, pentIgnore, beam_tr);
						if ( beam_tr.fAllSolid == 0 )
						{
							// trace backwards to find exit point
							g_Utility.TraceLine( beam_tr.vecEndPos, tr.vecEndPos, dont_ignore_monsters, pentIgnore, beam_tr);
							
							float Y_n = ( beam_tr.vecEndPos - tr.vecEndPos ).Length();
							
							if ( Y_n < flDamage )
							{
								if ( Y_n == 0 ) Y_n = 1;
								flDamage -= Y_n;
								
								// exit blast damage
								//m_pPlayer->RadiusDamage( beam_tr.vecEndPos + vecDir * 8, pev, m_pPlayer->pev, flDamage, CLASS_NONE, DMG_BLAST );
								float damage_radius;
								damage_radius = flDamage * 1.75;  // Old code == 2.5
								
								g_WeaponFuncs.RadiusDamage( beam_tr.vecEndPos + vecDir * 8, self.pev, m_pPlayer.pev, flDamage, damage_radius, CLASS_NONE, DMG_BLAST );
								
								CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
								CSoundEnt@ soundEnt = GetSoundEntInstance();
								soundEnt.InsertSound( bits_SOUND_COMBAT, self.pev.origin, NORMAL_EXPLOSION_VOLUME, 3.0, pOwner );
								
								vecSrc = beam_tr.vecEndPos + vecDir;
							}
						}
						else
						{
							flDamage = 0;
						}
					}
					else
					{
						flDamage = 0;
					}
					*/
				}
			}
			else
			{
				vecSrc = tr.vecEndPos + vecDir;
				@pentIgnore = @pEntity.edict();
			}
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		// play aftershock static discharge
		if ( m_flPlayAftershock > 0 && m_flPlayAftershock < g_Engine.time )
		{
			switch ( Math.RandomLong( 0, 3 ) )
			{
				case 0:	g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro4.wav", Math.RandomFloat( 0.7, 0.8 ), ATTN_NORM); break;
				case 1:	g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro5.wav", Math.RandomFloat( 0.7, 0.8 ), ATTN_NORM); break;
				case 2:	g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro6.wav", Math.RandomFloat( 0.7, 0.8 ), ATTN_NORM); break;
				case 3:	break; // no sound
			}
			m_flPlayAftershock = 0.0;
		}
		
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if ( self.pev.iuser2 != 0 )
		{
			StartFire();
			self.pev.iuser2 = 0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		}
		else
		{
			int iAnim;
			float flRand = Math.RandomFloat( 0, 1 );
			if ( flRand <= 0.5 )
			{
				iAnim = GAUSS_IDLE;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			}
			else if ( flRand <= 0.75 )
			{
				iAnim = GAUSS_IDLE2;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			}
			else
			{
				iAnim = GAUSS_FIDGET;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 3;
			}
			self.SendWeaponAnim( iAnim );
		}
	}
	
	float GetFullChargeTime()
	{
		return 2.00;
		//return 1.5;
		//return 4;
	}
	
	void StopMe()
	{
		g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "ambience/pulsemachine.wav" );
	}
}

string GetHLGaussName()
{
	return "weapon_hlgauss";
}

void RegisterHLGauss()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlgauss", GetHLGaussName() );
	g_ItemRegistry.RegisterWeapon( GetHLGaussName(), "hl_weapons", "uranium" );
}
