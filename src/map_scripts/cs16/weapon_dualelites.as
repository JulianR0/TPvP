enum ElitesAnimation
{
	ELITES_IDLE = 0,
	ELITES_IDLE_LEFTEMPTY,
	ELITES_SHOOTLEFT1,
	ELITES_SHOOTLEFT2,
	ELITES_SHOOTLEFT3,
	ELITES_SHOOTLEFT4,
	ELITES_SHOOTLEFT5,
	ELITES_SHOOTLEFTLAST,
	ELITES_SHOOTRIGHT1,
	ELITES_SHOOTRIGHT2,
	ELITES_SHOOTRIGHT3,
	ELITES_SHOOTRIGHT4,
	ELITES_SHOOTRIGHT5,
	ELITES_SHOOTRIGHTLAST,
	ELITES_RELOAD,
	ELITES_DRAW
};

const int ELITES_DEFAULT_GIVE	= 150;
const int ELITES_MAX_CARRY		= 120;
const int ELITES_MAX_CLIP		= 30;
const int ELITES_WEIGHT			= 5;

class weapon_dualelites : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int m_iShell;
	bool leftright = false;
	
	float m_flAccuracy;
	int m_iShotsFired;
	float m_flLastFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/dualelites/w_elite.mdl" );
		
		self.m_iDefaultAmmo = ELITES_DEFAULT_GIVE;
		m_flAccuracy = 0.88;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/dualelites/v_elite.mdl" );
		g_Game.PrecacheModel( "models/dualelites/w_elite.mdl" );
		g_Game.PrecacheModel( "models/dualelites/p_elite.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_fire.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_deploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_leftclipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_reloadstart.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_twirl.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_rightclipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/elite_sliderelease.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_fire.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_twirl.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_leftclipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_reloadstart.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/elite_rightclipin.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_dualelites.txt" );
		
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= ELITES_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= ELITES_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 4;
		info.iFlags 	= 0;
		info.iWeight 	= ELITES_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			NetworkMessage cs21( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs21.WriteLong( self.m_iId );
			cs21.End();
			
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dryfire_pistol.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flAccuracy = 0.88;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/dualelites/v_elite.mdl" ), self.GetP_Model( "models/dualelites/p_elite.mdl" ), ELITES_DRAW, "uzis" );
			
			float deployTime = 1.1f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			ELITEFire( 1.3 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			ELITEFire( 0.175 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			ELITEFire( 0.08 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else
		{
			ELITEFire( 0.1 * ( 1 - m_flAccuracy ), 0.2, false );
		}
	}
	
	void ELITEFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		if ( m_iShotsFired > 1 )
		{
			return;
		}

		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy -= ( 0.325 - ( WeaponTimeBase() - m_flLastFire ) ) * 0.275;

			if ( m_flAccuracy > 0.88 )
			{
				m_flAccuracy = 0.88;
			}
			else if ( m_flAccuracy < 0.55 )
			{
				m_flAccuracy = 0.55;
			}
		}

		m_flLastFire = WeaponTimeBase();
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
			return;
		}
		
		self.m_iClip--;
		
		flCycleTime -= 0.125;
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, ELITE_DISTANCE, ELITE_PENETRATION, BULLET_PLAYER_9MM, ELITE_DAMAGE, ELITE_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		if( leftright == true )
		{
			m_pPlayer.m_szAnimExtension = "uzis_right";
			leftright = false;
		}
		else
		{
			m_pPlayer.m_szAnimExtension = "uzis_left";
			leftright = true;
		}
		
		int iAnimation;

		if( self.m_iClip == 1 )
		{
			iAnimation = ELITES_SHOOTLEFTLAST;
		}
		else if( self.m_iClip == 0 )
		{
			iAnimation = ELITES_SHOOTRIGHTLAST;
		}
		else
		{
			iAnimation = ( ( self.m_iClip % 2 ) == 0 ) ? ELITES_SHOOTRIGHT1 : ELITES_SHOOTLEFT1;
			
			iAnimation += g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 4 );
		}
		
		self.SendWeaponAnim( iAnimation, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/elite_fire.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		m_pPlayer.pev.punchangle.x -= 2.0;
		
		Vector vecShellVelocity, vecShellOrigin;
		
		if( iAnimation == ELITES_SHOOTRIGHT1 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7 );
		else if( iAnimation == ELITES_SHOOTRIGHT2 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7 );
		else if( iAnimation == ELITES_SHOOTRIGHT3 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7 );
		else if( iAnimation == ELITES_SHOOTRIGHT4 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7 );
		else if( iAnimation == ELITES_SHOOTRIGHT5 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7 );
		else if( iAnimation == ELITES_SHOOTRIGHTLAST )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7 );
		else if ( iAnimation == ELITES_SHOOTLEFT1 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7 );
		else if ( iAnimation == ELITES_SHOOTLEFT2 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7 );
		else if ( iAnimation == ELITES_SHOOTLEFT3 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7 );
		else if ( iAnimation == ELITES_SHOOTLEFT4 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7 );
		else if ( iAnimation == ELITES_SHOOTLEFT5 )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7 );
		else if ( iAnimation == ELITES_SHOOTLEFTLAST )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7 );

		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < ELITES_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( ELITES_MAX_CLIP, ELITES_RELOAD, 4.6, 0 ) )
		{
			m_flAccuracy = 0.88;
		}
		
		m_pPlayer.m_szAnimExtension = "uzis";
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			// Can't attack if the player is holding the button
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
			{
				m_iShotsFired = 0;
			}
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( ELITES_IDLE );
		
		if ( self.m_iClip == 1 )
		{
			self.SendWeaponAnim( ELITES_IDLE_LEFTEMPTY );
		}
		
		if( leftright == true )
		{
			self.m_flTimeWeaponIdle = 0.28;
			m_pPlayer.m_szAnimExtension = "uzis";
		}
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.28;
		
		if( self.m_flTimeWeaponIdle == 0.28 )
			m_pPlayer.m_szAnimExtension = "uzis";
		
		m_pPlayer.m_szAnimExtension = "uzis";
	}
}	

string GetELITESName()
{
	return "weapon_dualelites";
}

void RegisterELITES()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetELITESName(), GetELITESName() );
	g_ItemRegistry.RegisterWeapon( GetELITESName(), "cs_weapons", "ammo_9mmparab" );
}