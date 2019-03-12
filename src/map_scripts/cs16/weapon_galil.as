enum GalilAnimation
{
	GALIL_IDLE = 0,
	GALIL_RELOAD,
	GALIL_DRAW,
	GALIL_SHOOT1,
	GALIL_SHOOT2,
	GALIL_SHOOT3
};

const int GALIL_DEFAULT_GIVE		= 120;
const int GALIL_MAX_CARRY			= 90;
const int GALIL_MAX_CLIP			= 35;
const int GALIL_WEIGHT				= 25;

class weapon_galil : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int m_iShell;
	
	float m_flAccuracy;
	float m_flLastFire;
	int m_iShotsFired;
	int m_iDirection;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/galil/w_galil.mdl" );
		
		self.m_iDefaultAmmo = GALIL_DEFAULT_GIVE;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/galil/v_galil.mdl" );
		g_Game.PrecacheModel( "models/galil/w_galil.mdl" );
		g_Game.PrecacheModel( "models/galil/p_galil.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/galil-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/galil-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/galil_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/galil_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/galil_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/galil-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/galil-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/galil_boltpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/galil_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/galil_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud17.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud18.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_galil.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= GALIL_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= GALIL_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= GALIL_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dryfire_rifle.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flAccuracy = 0.2;
			m_iShotsFired = 0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/galil/v_galil.mdl" ), self.GetP_Model( "models/galil/p_galil.mdl" ), GALIL_DRAW, "m16" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}

		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			GalilFire( 0.04 + ( 0.3 * m_flAccuracy ), 0.0875, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			GalilFire( 0.04 + ( 0.07 * m_flAccuracy ), 0.0875, false );
		}
		else
		{
			GalilFire( 0.0375 * m_flAccuracy, 0.0875, false );
		}
	}
	
	void GalilFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 200.0 ) + 0.35;

		if ( m_flAccuracy > 1.25 )
			m_flAccuracy = 1.25; 
		
		m_flLastFire = WeaponTimeBase();
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
			return;
		}
		
		self.m_iClip--;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, GALIL_DISTANCE, GALIL_PENETRATION, BULLET_PLAYER_556MM, GALIL_DAMAGE, GALIL_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( GALIL_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( GALIL_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( GALIL_SHOOT3, 0, 0 ); break;
		}
		
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/galil-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/galil-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.9;
		
		if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7 );
		}
		else if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7 );
		}
		else
		{
			KickBack( 0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 8, -5 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void KickBack( float up_base, float lateral_base, float up_modifier, float lateral_modifier, float up_max, float lateral_max, int direction_change )
	{
		float front, side;
		
		if ( m_iShotsFired == 1 )
		{
			front = up_base;
			side = lateral_base;
		}
		else
		{
			front = m_iShotsFired * up_modifier + up_base;
			side = m_iShotsFired * lateral_modifier + lateral_base;
		}
		
		m_pPlayer.pev.punchangle.x -= front;
		
		if ( m_pPlayer.pev.punchangle.x < -up_max )
			m_pPlayer.pev.punchangle.x = -up_max;

		if ( m_iDirection == 1 )
		{
			m_pPlayer.pev.punchangle.y += side;
			
			if ( m_pPlayer.pev.punchangle.y > lateral_max )
				m_pPlayer.pev.punchangle.y = lateral_max;
		}
		else
		{
			m_pPlayer.pev.punchangle.y -= side;
			
			if ( m_pPlayer.pev.punchangle.y < -lateral_max )
				m_pPlayer.pev.punchangle.y = -lateral_max;
		}
		
		if ( Math.RandomLong( 0, direction_change ) == 0 )
		{
			m_iDirection ^= 1;
		}
	}
	
	void Reload()
	{
		if( self.m_iClip < GALIL_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( GALIL_MAX_CLIP, GALIL_RELOAD, 2.6, 0 ) )
		{
			m_flAccuracy = 0.2;
			m_iShotsFired = 0; 
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		// Recoil (Shots fired) does not reset on it's own until weapon is reloaded or holstered/deployed. Manual fix. -Giegue
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.175 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.175;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( GALIL_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetGALILName()
{
	return "weapon_galil";
}

void RegisterGALIL()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetGALILName(), GetGALILName() );
	g_ItemRegistry.RegisterWeapon( GetGALILName(), "cs_weapons", "ammo_556Nato" );
}