const Vector VECTOR_CONE_M3( 0.06750, 0.06850, 0.00 );

const int M3_DEFAULT_GIVE	= 40;
const int M3_MAX_CARRY 		= 32;
const int M3_MAX_CLIP 		= 8;
const int M3_WEIGHT 		= 20;

const uint SHOTGUN_PELLETCOUNT = 9;

enum M3Animation
{
	M3_IDLE = 0,
	M3_SHOOT1,
	M3_SHOOT2,
	M3_INSERT,
	M3_AFTER_RELOAD,
	M3_START_RELOAD,
	M3_DRAW
}

class weapon_m3 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextReload;
	int m_iShell;
	float m_flPumpTime;
	bool m_fPlayPumpSound;
	bool m_fShotgunReload;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/m3/w_m3.mdl" );
		
		self.m_iDefaultAmmo = M3_MAX_CARRY;

		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/m3/v_m3.mdl" );
		g_Game.PrecacheModel( "models/m3/w_m3.mdl" );
		g_Game.PrecacheModel( "models/m3/p_m3.mdl" );
		g_Game.PrecacheModel( "models/w_shotbox.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/shotgunshell.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m3-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m3_pump.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m3_insertshell.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/m3-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m3_pump.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m3_insertshell.wav" );
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_m3.txt" );
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dryfire_rifle.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			NetworkMessage cs15( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs15.WriteLong( self.m_iId );
			cs15.End();
			
			@m_pPlayer = pPlayer;
			
			return true;
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= M3_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= M3_MAX_CLIP;
		info.iSlot 		= 2;
		info.iPosition 	= 10;
		info.iFlags 	= 0;
		info.iWeight 	= M3_WEIGHT;

		return true;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/m3/v_m3.mdl" ), self.GetP_Model( "models/m3/p_m3.mdl" ), M3_DRAW, "shotgun" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void CreatePelletDecals( const Vector& in vecSrc, const Vector& in vecAiming, const Vector& in vecSpread, const uint uiPelletCount )
	{
		TraceResult tr;
		
		float x, y;
		
		for( uint uiPellet = 0; uiPellet < uiPelletCount; ++uiPellet )
		{
			g_Utility.GetCircularGaussianSpread( x, y );
			
			Vector vecDir = vecAiming 
							+ x * vecSpread.x * g_Engine.v_right 
							+ y * vecSpread.y * g_Engine.v_up;

			Vector vecEnd	= vecSrc + vecDir * 2048;
			
			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
			
			if( tr.flFraction < 1.0 )
			{
				if( tr.pHit !is null )
				{
					CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
					
					if( pHit is null || pHit.IsBSPModel() == true )
						g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_BUCKSHOT );
				}
			}
		}
	}
	
	void PrimaryAttack()
	{
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.159;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;
			self.Reload();
			self.PlayEmptySound();
			return;
		}
	
		self.m_iClip--;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		m_pPlayer.FireBullets( 9, m_pPlayer.GetGunPosition(), g_Engine.v_forward, VECTOR_CONE_M3, 3000, BULLET_PLAYER_CUSTOMDAMAGE, 0, 10 );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( M3_SHOOT1, 0, 0 );
			{
				while ( m_pPlayer.random_seed == 0 ) // ???
				{
					self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.18;
				}
				break;
			}
			
			case 1: self.SendWeaponAnim( M3_SHOOT2, 0, 0 );break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/m3-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );

		if( self.m_iClip != 0 )
			m_flPumpTime = WeaponTimeBase() + 0.5;
			
		if ( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 )
			m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed + 1, 4, 6 );
		else
			m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed + 1, 8, 11 );

		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.85;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.85;

		if( self.m_iClip != 0 )
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 5.0;
		else
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.75;

		m_fShotgunReload = false;
		m_fPlayPumpSound = true;
		
		CreatePelletDecals( m_pPlayer.GetGunPosition(), g_Engine.v_forward, VECTOR_CONE_M3, SHOTGUN_PELLETCOUNT );
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 15, -5 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHOTSHELL );
	}
	
	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == M3_MAX_CLIP )
			return;

		if( m_flNextReload >  WeaponTimeBase() )
			return;

		// don't reload until recoil is done
		if( self.m_flNextPrimaryAttack > WeaponTimeBase() && !m_fShotgunReload )
			return;

		// check to see if we're ready to reload
		if( !m_fShotgunReload )
		{
			self.SendWeaponAnim( M3_START_RELOAD, 0, 0 );
			m_pPlayer.m_flNextAttack 	= 0.6;	//Always uses a relative time due to prediction
			self.m_flTimeWeaponIdle			= WeaponTimeBase() + 0.6;
			self.m_flNextPrimaryAttack 		= WeaponTimeBase() + 1.0;
			m_fShotgunReload = true;
			return;
		}
		else if( m_fShotgunReload )
		{
			if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
				return;

			if( self.m_iClip == M3_MAX_CLIP )
			{
				m_fShotgunReload = false;
				return;
			}

			self.SendWeaponAnim( M3_INSERT, 0 );
			m_flNextReload 					= WeaponTimeBase() + 0.5;
			self.m_flNextPrimaryAttack 		= WeaponTimeBase() + 0.5;
			self.m_flTimeWeaponIdle 		= WeaponTimeBase() + 0.5;
				
			// Add them to the clip
			self.m_iClip += 1;
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
			
			switch( Math.RandomLong( 0, 0 ) )
			{
			case 0:
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "weapons/m3_insertshell.wav", 1, ATTN_NORM, 0, 85 + Math.RandomLong( 0, 0x1f ) );
				break;
			}
		}
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle < g_Engine.time )
		{
			if( self.m_iClip == 0 && !m_fShotgunReload && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) != 0 )
			{
				self.Reload();
			}
			else if( m_fShotgunReload )
			{
				if( self.m_iClip != M3_MAX_CLIP && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
				{
					self.Reload();
				}
				else
				{
					// reload debounce has timed out
					self.SendWeaponAnim( M3_AFTER_RELOAD, 0, 0 );

					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "weapons/m3_pump.wav", 1, ATTN_NORM, 0, 95 + Math.RandomLong( 0,0x1f ) );
					m_fShotgunReload = false;
					self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
				}
			}
			else
			{
				int iAnim;
				float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
				if( flRand <= 0.8 )
				{
					iAnim = M3_IDLE;
					self.m_flTimeWeaponIdle = g_Engine.time + (60.0/12.0);// * RANDOM_LONG(2, 5);
				}
			}
		}
	}
}

class TwelveGaugeBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/w_shotbox.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/w_shotbox.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = M3_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_12gauge", M3_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetM3Shotty()
{
	return "weapon_m3";
}

void RegisterM3Shotty()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetM3Shotty(), GetM3Shotty() );
	g_ItemRegistry.RegisterWeapon( GetM3Shotty(), "cs_weapons", "ammo_12gauge" );
}

string GetTwelveGaugeBoxName()
{
	return "ammo_12gauge";
}

void RegisterTwelveGaugeBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "TwelveGaugeBox", GetTwelveGaugeBoxName() );
}