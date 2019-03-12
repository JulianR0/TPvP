enum USPAnimation
{
	USP_IDLE = 0,
	USP_SHOOT1,
	USP_SHOOT2,
	USP_SHOOT3,
	USP_SHOOTLAST,
	USP_RELOAD,
	USP_DRAW,
	USP_ADD_SILENCER,
	USP_IDLE_UNSIL,
	USP_SHOOT1_UNSIL,
	USP_SHOOT2_UNSIL,
	USP_SHOOT3_UNSIL,
	USP_SHOOTLAST_UNSIL,
	USP_RELOAD_UNSIL,
	USP_DRAW_UNSIL,
	USP_DETACH_SILENCER
};

enum SilencedMode
{
	MODE_NOSILENCER = 0,
	MODE_SILENCER
};

const int USP_DEFAULT_GIVE		= 112;
const int USP_MAX_CARRY			= 100;
const int USP_MAX_CLIP			= 12;
const int USP_WEIGHT			= 5;

class weapon_usp : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int g_iCurrentMode;
	int m_iShell;
	
	float m_flAccuracy;
	int m_iShotsFired;
	float m_flLastFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/usp/w_usp.mdl" );
		
		self.m_iDefaultAmmo = USP_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_flAccuracy = 0.92;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/usp/v_usp.mdl");
		g_Game.PrecacheModel( "models/usp/w_usp.mdl");
		g_Game.PrecacheModel( "models/usp/p_usp.mdl");
		g_Game.PrecacheModel( "models/cs16ammo/45acp/w_45acp.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/45acp/w_45acpt.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl");
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_unsil-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_silencer_off.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_silencer_on.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_slideback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/usp_sliderelease.wav" );
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp_unsil-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp_silencer_off.wav");
		g_SoundSystem.PrecacheSound( "weapons/usp_silencer_on.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/usp_clipin.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_usp.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= USP_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= USP_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= USP_WEIGHT;
		
		return true;
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
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs12( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs12.WriteLong( self.m_iId );
			cs12.End();
			
			@m_pPlayer = pPlayer;
			
			return true;
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
			m_flAccuracy = 0.92;
			
			if ( g_iCurrentMode == MODE_SILENCER )
			{
				bResult = self.DefaultDeploy ( self.GetV_Model( "models/usp/v_usp.mdl" ), self.GetP_Model( "models/usp/p_usp.mdl" ), USP_DRAW, "onehanded" );
			}
			else
			{
				bResult = self.DefaultDeploy ( self.GetV_Model( "models/usp/v_usp.mdl" ), self.GetP_Model( "models/usp/p_usp.mdl" ), USP_DRAW_UNSIL, "onehanded" );
			}
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;

			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( g_iCurrentMode == MODE_SILENCER )
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				USPFire( 1.3 * ( 1 - m_flAccuracy ), 0.225, false );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				USPFire( 0.25 * ( 1 - m_flAccuracy ), 0.225, false );
			}
			else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
			{
				USPFire( 0.125 * ( 1 - m_flAccuracy ), 0.225, false );
			}
			else
			{
				USPFire( 0.15 * ( 1 - m_flAccuracy ), 0.225, false );
			}
		}
		else
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				USPFire( 1.2 * ( 1 - m_flAccuracy ), 0.225, false );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				USPFire( 0.225 * ( 1 - m_flAccuracy ), 0.225, false );
			}
			else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
			{
				USPFire( 0.08 * ( 1 - m_flAccuracy ), 0.225, false );
			}
			else
			{
				USPFire( 0.1 * ( 1 - m_flAccuracy), 0.225, false);
			}
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 3.135f;
		switch ( g_iCurrentMode )
		{
			case MODE_NOSILENCER:
			{
				g_iCurrentMode = MODE_SILENCER;
				self.SendWeaponAnim( USP_ADD_SILENCER, 0, 0 );
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "sound/weapons/usp_silencer_on.wav", 0.9, ATTN_NORM, 0, PITCH_NORM);
				break;
			}
			case MODE_SILENCER:
			{
				g_iCurrentMode = MODE_NOSILENCER;
				self.SendWeaponAnim( USP_DETACH_SILENCER, 0, 0 );
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "sound/weapons/usp_silencer_off.wav", 0.9, ATTN_NORM, 0, PITCH_NORM);
				break;
			}
		}
		
	}
	
	void USPFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		if ( m_iShotsFired > 1 )
		{
			return;
		}

		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy -= ( 0.3 - ( WeaponTimeBase() - m_flLastFire ) ) * 0.275;

			if ( m_flAccuracy > 0.92 )
			{
				m_flAccuracy = 0.92;
			}
			else if ( m_flAccuracy < 0.6 )
			{
				m_flAccuracy = 0.6;
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
		
		flCycleTime -= 0.075;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, USP_DISTANCE, USP_PENETRATION, BULLET_PLAYER_45ACP, USP_DAMAGE, USP_RANGE_MODIFER );
		
		if( g_iCurrentMode == MODE_NOSILENCER )
		{
			m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		}
		else if ( g_iCurrentMode == MODE_SILENCER )
		{
			m_pPlayer.m_iWeaponVolume = 0;
			m_pPlayer.m_iWeaponFlash = 0;
		}
		
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if ( g_iCurrentMode == MODE_SILENCER )
		{
			if ( self.m_iClip <= 0 )
			{
				self.SendWeaponAnim( USP_SHOOTLAST, 0, 0 );
			}
			else
			{
				switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
				{
					case 0: self.SendWeaponAnim( USP_SHOOT1, 0, 0 ); break;
					case 1: self.SendWeaponAnim( USP_SHOOT2, 0, 0 ); break;
					case 2: self.SendWeaponAnim( USP_SHOOT3, 0, 0 ); break;
				}
			}
		}
		else if ( g_iCurrentMode == MODE_NOSILENCER )
		{
			if ( self.m_iClip <= 0 )
			{
				self.SendWeaponAnim( USP_SHOOTLAST_UNSIL, 0, 0 );
			}
			else
			{
				switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
				{
					case 0: self.SendWeaponAnim( USP_SHOOT1_UNSIL, 0, 0 ); break;
					case 1: self.SendWeaponAnim( USP_SHOOT2_UNSIL, 0, 0 ); break;
					case 2: self.SendWeaponAnim( USP_SHOOT3_UNSIL, 0, 0 ); break;
				}
			}
		}
		
		if ( g_iCurrentMode == MODE_SILENCER )
		{
			switch ( Math.RandomLong (0, 1) )
			{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/usp1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/usp2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			}
		}
		else if ( g_iCurrentMode == MODE_NOSILENCER )
		{
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/usp_unsil-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		}
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		m_pPlayer.pev.punchangle.x -= 2;
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 16, 7, -6 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < USP_MAX_CLIP )
			BaseClass.Reload();
		
		if ( g_iCurrentMode == MODE_SILENCER )
		{
			if( self.DefaultReload( USP_MAX_CLIP, USP_RELOAD, 2.73, 0 ) )
			{
				m_flAccuracy = 0.92;
			}
		}
		else
		{
			if( self.DefaultReload( USP_MAX_CLIP, USP_RELOAD_UNSIL, 2.73, 0 ) )
			{
				m_flAccuracy = 0.92;
			}
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
		
		int iAnim;
		switch ( Math.RandomLong ( 0, 0 ) )
		{
			case 0:
			if( g_iCurrentMode == MODE_SILENCER )
			{
				iAnim = USP_IDLE; break;
			}
			else
			{
				iAnim = USP_IDLE_UNSIL; break;
			}
		}
		
		self.SendWeaponAnim( iAnim );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class USPAmmoBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/45acp/w_45acp.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/45acp/w_45acp.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/45acp/w_45acpt.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = USP_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_45acp", USP_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetUSPName()
{
	return "weapon_usp";
}

void RegisterUSP()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetUSPName(), GetUSPName() );
	g_ItemRegistry.RegisterWeapon( GetUSPName(), "cs_weapons", "ammo_45acp" );
}

string GetUSPAmmoBoxName()
{
	return "ammo_45acp";
}

void RegisterUSPAmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "USPAmmoBox", GetUSPAmmoBoxName() );
}