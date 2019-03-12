enum GLOCK18Animation
{
	GLOCK18_IDLE1 = 0,
	GLOCK18_IDLE2,
	GLOCK18_IDLE3,
	GLOCK18_SHOOT1,
	GLOCK18_SHOOT2,
	GLOCK18_SHOOT3,
	GLOCK18_SHOOTEMPTY,
	GLOCK18_RELOAD,
	GLOCK18_DRAW,
	GLOCK18_HOLSTER,
	GLOCK18_ADDSILENCER,
	GLOCK18_DRAW2,
	GLOCK18_RELOAD2
};
 
const int GLOCK18_DEFAULT_GIVE		= 140;
const int GLOCK18_MAX_CARRY			= 120;
const int GLOCK18_MAX_CLIP			= 20;
const int GLOCK18_WEIGHT			= 5;
 
enum GlockBurstFire
{
	MODE_UNBURST = 0,
	MODE_BURSTFIRE
}
 
class weapon_csglock18 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int g_iCurrentMode;
	int m_iShell;
	
	float m_flAccuracy;
	bool m_bBurstFire;
	int m_iShotsFired;
	int m_iGlock18ShotsFired;
	float m_flLastFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/glock18/w_glock18.mdl" );
	   
		self.m_iDefaultAmmo = GLOCK18_DEFAULT_GIVE;
		g_iCurrentMode = MODE_UNBURST;
		m_bBurstFire = false;
		m_iGlock18ShotsFired = 0;
		m_flAccuracy = 0.9;
		m_flLastFire = 0.0;
		
		self.FallInit();
	}
   
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/glock18/v_glock18.mdl" );
		g_Game.PrecacheModel( "models/glock18/w_glock18.mdl" );
		g_Game.PrecacheModel( "models/glock18/p_glock18.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
	   
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/glock18-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/glock18-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/clipout1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/clipin1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/slideback1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/sliderelease1.wav" );
	   
		g_SoundSystem.PrecacheSound( "weapons/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/glock18-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/glock18-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/clipout1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/clipin1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/slideback1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/sliderelease1.wav" );
	   
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_csglock18.txt" );
	}
   
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1  = GLOCK18_MAX_CARRY;
		info.iMaxAmmo2  = -1;
		info.iMaxClip   = GLOCK18_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition  = 6;
		info.iFlags		= 0;
		info.iWeight	= GLOCK18_WEIGHT;
	   
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
		   
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dryfire_pistol.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
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
			m_bBurstFire = false;
			m_iGlock18ShotsFired = 0;
			m_flAccuracy = 0.9;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/glock18/v_glock18.mdl" ), self.GetP_Model( "models/glock18/p_glock18.mdl" ), GLOCK18_DRAW, "onehanded" );
		   
			float deployTime = 1.1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( g_iCurrentMode == MODE_BURSTFIRE )
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				GLOCK18Fire( 1.2 * ( 1 - m_flAccuracy ), 0.05, true );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				GLOCK18Fire( 0.185 * ( 1 - m_flAccuracy ), 0.05, true );
			}
			else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
			{
				GLOCK18Fire( 0.095 * ( 1 - m_flAccuracy ), 0.05, true );
			}
			else
			{
				GLOCK18Fire( 0.3 * ( 1 - m_flAccuracy ), 0.05, true );
			}
		}
		else
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				GLOCK18Fire( 1.0 * ( 1 - m_flAccuracy ), 0.2, false );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				GLOCK18Fire( 0.165 * ( 1 - m_flAccuracy ), 0.2, false );
			}
			else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
			{
				GLOCK18Fire( 0.075 * ( 1 - m_flAccuracy ), 0.2, false );
			}
			else
			{
				GLOCK18Fire( 0.1 * ( 1 - m_flAccuracy ), 0.2, false );
			}
		}
	}
	
	void SecondaryAttack()
	{
		switch( g_iCurrentMode )
		{
			case MODE_UNBURST:
			{
				g_iCurrentMode = MODE_BURSTFIRE;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Cambiado a Burst-Fire\n" );
				break;
			}
			case MODE_BURSTFIRE:
			{
				g_iCurrentMode = MODE_UNBURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Cambiado a Semi-Automatica\n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}
	
	void GLOCK18Fire( float flSpread, float flCycleTime, bool fUseBurstMode )
	{
		if ( !fUseBurstMode )
		{
			m_iShotsFired++;

			if ( m_iShotsFired > 1 )
			{
				return;
			}

			flCycleTime -= 0.05;
		}
		
		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy -= ( 0.325 - ( WeaponTimeBase() - m_flLastFire ) ) * 0.275;

			if ( m_flAccuracy > 0.9 )
			{
				m_flAccuracy = 0.9;
			}
			else if ( m_flAccuracy < 0.6 )
			{
				m_flAccuracy = 0.6;
			}
		}
		
		m_flLastFire = WeaponTimeBase(); 
		
		if( self.m_iClip <= 0 )
		{
			m_iGlock18ShotsFired = 0;
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
			return;
		}
		
		self.m_iClip--;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, GLOCK18_DISTANCE, GLOCK18_PENETRATION, BULLET_PLAYER_9MM, GLOCK18_DAMAGE, GLOCK18_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.SendWeaponAnim( GLOCK18_SHOOT3, 0, 0 );
		
		if( self.m_iClip <= 0 )
			self.SendWeaponAnim( GLOCK18_SHOOTEMPTY, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/glock18-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	   
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.5;
		
		if ( fUseBurstMode )
		{
			m_iGlock18ShotsFired++;
			if ( m_iGlock18ShotsFired == 3 )
			{
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
				m_iGlock18ShotsFired = 0;
			}
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 10, -7 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < GLOCK18_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( GLOCK18_MAX_CLIP, GLOCK18_RELOAD, 2.2, 0 ) )
		{
			m_flAccuracy = 0.9;
			m_iGlock18ShotsFired = 0;
		}
	}
	
	//Overridden to prevent WeaponIdle from being blocked by holding down buttons.
	void ItemPostFrame()
	{
		//If firing bursts, handle next shot.
		if( m_iGlock18ShotsFired > 0 )
		{
			if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			{
				if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
				{
					GLOCK18Fire( 1.2 * ( 1 - m_flAccuracy ), 0.05, true );
				}
				else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
				{
					GLOCK18Fire( 0.185 * ( 1 - m_flAccuracy ), 0.05, true );
				}
				else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
				{
					GLOCK18Fire( 0.095 * ( 1 - m_flAccuracy ), 0.05, true );
				}
				else
				{
					GLOCK18Fire( 0.3 * ( 1 - m_flAccuracy ), 0.05, true );
				}
			}
			
			//While firing a burst, don't allow reload or any other weapon actions. Might be best to let some things run though.
			return;
		}
	   
		BaseClass.ItemPostFrame();
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
	   
		self.SendWeaponAnim( GLOCK18_IDLE1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}
 
string GetGLOCK18Name()
{
	return "weapon_csglock18";
}
 
void RegisterGLOCK18()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetGLOCK18Name(), GetGLOCK18Name() );
	g_ItemRegistry.RegisterWeapon( GetGLOCK18Name(), "cs_weapons", "ammo_9mmparab" );
}