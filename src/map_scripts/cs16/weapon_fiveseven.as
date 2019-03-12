enum FiveSevenAnimation
{
	FIVE7_IDLE = 0,
	FIVE7_SHOOT1,
	FIVE7_SHOOT2,
	FIVE7_SHOOTLAST,
	FIVE7_RELOAD,
	FIVE7_DRAW
};

const int FIVE7_DEFAULT_GIVE		= 120;
const int FIVE7_MAX_CARRY			= 100;
const int FIVE7_MAX_CLIP			= 20;
const int FIVE7_WEIGHT				= 5;

class weapon_fiveseven : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int m_iShell;
	
	float m_flAccuracy;
	int m_iShotsFired;
	float m_flLastFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/five7/w_fiveseven.mdl" );
		
		self.m_iDefaultAmmo = FIVE7_DEFAULT_GIVE;
		m_flAccuracy = 0.92;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/five7/v_fiveseven.mdl" );
		g_Game.PrecacheModel( "models/five7/w_fiveseven.mdl" );
		g_Game.PrecacheModel( "models/five7/p_fiveseven.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/fiveseven-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/fiveseven_sliderelease.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/fiveseven_slidepull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/fiveseven_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/fiveseven_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/fiveseven-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/fiveseven_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/fiveseven_slidepull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/fiveseven_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/fiveseven_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_fiveseven.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= FIVE7_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= FIVE7_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 9;
		info.iFlags 	= 0;
		info.iWeight 	= FIVE7_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dryfire_pistol.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flAccuracy = 0.92;
			
			bResult = self.DefaultDeploy( self.GetV_Model( "models/five7/v_fiveseven.mdl" ), self.GetP_Model( "models/five7/p_fiveseven.mdl" ), FIVE7_DRAW, "onehanded" );
		
			float deployTime = 1;
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
			FiveSevenFire( 1.5 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			FiveSevenFire( 0.255 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			FiveSevenFire( 0.075 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else
		{
			FiveSevenFire( 0.15 * ( 1 - m_flAccuracy ), 0.2, false );
		}
	}
	
	void FiveSevenFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		if ( m_iShotsFired > 1 )
		{
			return;
		}
		
		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy -= ( 0.275 - ( WeaponTimeBase() - m_flLastFire ) ) * 0.25;

			if ( m_flAccuracy > 0.92 )
			{
				m_flAccuracy = 0.92;
			}
			else if ( m_flAccuracy < 0.725 )
			{
				m_flAccuracy = 0.725;
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
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, FIVESEVEN_DISTANCE, FIVESEVEN_PENETRATION, BULLET_PLAYER_57MM, FIVESEVEN_DAMAGE, FIVESEVEN_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		if ( self.m_iClip <= 0 )
		{
			self.SendWeaponAnim( FIVE7_SHOOTLAST, 0, 0 );
		}
		else
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
			{
				case 0: self.SendWeaponAnim( FIVE7_SHOOT1, 0, 0 ); break;
				case 1: self.SendWeaponAnim( FIVE7_SHOOT2, 0, 0 ); break;
			}
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/fiveseven-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		flCycleTime -= 0.05;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		m_pPlayer.pev.punchangle.x -= 2;
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 8, -6 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < FIVE7_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( FIVE7_MAX_CLIP, FIVE7_RELOAD, 3.24, 0 ) )
		{
			m_flAccuracy = 0.92;
		}
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
		
		self.SendWeaponAnim( FIVE7_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetFIVESEVENName()
{
	return "weapon_fiveseven";
}

void RegisterFIVESEVEN()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetFIVESEVENName(), GetFIVESEVENName() );
	g_ItemRegistry.RegisterWeapon( GetFIVESEVENName(), "cs_weapons", "ammo_fn57" );
}