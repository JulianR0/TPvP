enum SCOUTAnimation
{
	SCOUT_IDLE1 = 0,
	SCOUT_SHOOT1,
	SCOUT_SHOOT2,
	SCOUT_RELOAD,
	SCOUT_DRAW
};

const int SCOUT_DEFAULT_GIVE		= 100;
const int SCOUT_MAX_CARRY			= 90;
const int SCOUT_MAX_CLIP			= 10;
const int SCOUT_WEIGHT				= 30;

enum ModeScope
{
	MODE_NOMORESCOPE = 0,
	MODE_SURESCOPE,
	MODE_EVENMORESCOPE
};

class weapon_scout : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int g_iCurrentMode;
	int m_iShell;
	
	bool m_bResumeZoom;
	int m_iLastZoom; 
	int m_iLastMode;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/scout/w_scout.mdl" );
		
		self.m_iDefaultAmmo = SCOUT_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_bResumeZoom = false;
		m_iLastZoom = 0;
		m_iLastMode = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/scout/v_scout.mdl" );
		g_Game.PrecacheModel( "models/scout/w_scout.mdl" );
		g_Game.PrecacheModel( "models/scout/p_scout.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/scout_fire-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/scout_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/scout_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/scout_bolt.wav" );;
		g_Game.PrecacheGeneric( "sound/" + "weapons/zoom.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/scout_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/scout_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/scout_fire-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/scout_bolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/zoom.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud12.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud13.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/ch_sniper.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_scout.txt");
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= SCOUT_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= SCOUT_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 5;
		info.iFlags		= 0;
		info.iWeight	= SCOUT_WEIGHT;
		
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
	
	void Holster( int skipLocal = 0 ) 
    {     
        self.m_fInReload = false; 
         
        if ( self.m_fInZoom ) 
        { 
            SecondaryAttack(); 
        } 

        g_iCurrentMode = 0;
		ToggleZoom( 0 );
		m_bResumeZoom = false;
		m_iLastZoom = 0;
		m_iLastMode = 0;
		m_pPlayer.pev.maxspeed = 0;
		
		BaseClass.Holster( skipLocal ); 
    }
	
	void SetFOV( int fov )
	{
		m_pPlayer.pev.fov = m_pPlayer.m_iFOV = fov;
	}
	
	void ToggleZoom( int zoomedFOV )
	{
		if ( self.m_fInZoom == true )
		{
			SetFOV( 0 ); // 0 means reset to default fov
		}
		else if ( self.m_fInZoom == false )
		{
			SetFOV( zoomedFOV );
		}
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/scout/v_scout.mdl" ), self.GetP_Model( "models/scout/p_scout.mdl" ), SCOUT_DRAW, "sniper" );
			
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.25;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			SCOUTFire( 0.2, 1.25, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 170 )
		{
			SCOUTFire( 0.075, 1.25, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			SCOUTFire( 0.0, 1.25, false );
		}
		else
		{
			SCOUTFire( 0.007, 1.25, false );
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case MODE_NOMORESCOPE:
			{
				g_iCurrentMode = MODE_SURESCOPE;
				ToggleZoom( 40 );
				m_pPlayer.m_szAnimExtension = "sniperscope";
				m_pPlayer.pev.maxspeed = 220;
				break;
			}
		
			case MODE_SURESCOPE:
			{
				g_iCurrentMode = MODE_EVENMORESCOPE;
				ToggleZoom( 15 );
				m_pPlayer.m_szAnimExtension = "sniperscope";
				m_pPlayer.pev.maxspeed = 220;
				break;
			}
			
			case MODE_EVENMORESCOPE:
			{
				g_iCurrentMode = MODE_NOMORESCOPE;
				ToggleZoom( 0 );
				m_pPlayer.m_szAnimExtension = "sniper";
				m_pPlayer.pev.maxspeed = 0;
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/zoom.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void SCOUTFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		if ( m_pPlayer.pev.fov != 0 )
		{
			m_bResumeZoom = true;
			m_iLastZoom = m_pPlayer.m_iFOV;
			m_iLastMode = g_iCurrentMode;
			m_pPlayer.m_iFOV = 0;
			m_pPlayer.pev.fov = 0.0;
		}
		else
		{
			flCycleTime += 0.025;
		}
		
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, SCOUT_DISTANCE, SCOUT_PENETRATION, BULLET_PLAYER_762MM, SCOUT_DAMAGE, SCOUT_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( SCOUT_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( SCOUT_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/scout_fire-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.8;
		
		m_pPlayer.pev.punchangle.x -= 2;
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 14, 9, -5 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < SCOUT_MAX_CLIP )
		{	
			BaseClass.Reload();
			g_iCurrentMode = 0;
			ToggleZoom( 0 );
			m_bResumeZoom = false;
			m_iLastZoom = 0;
			m_iLastMode = 0;
			m_pPlayer.m_szAnimExtension = "sniper";
			m_pPlayer.pev.maxspeed = 0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 3.0;
		}
		
		self.DefaultReload( SCOUT_MAX_CLIP, SCOUT_RELOAD, 2.04, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			if ( m_bResumeZoom )
			{
				g_iCurrentMode = m_iLastMode;
				m_pPlayer.m_iFOV = m_iLastZoom;
				m_pPlayer.pev.fov = float( m_iLastZoom );
				
				m_bResumeZoom = false;
				m_iLastZoom = 0;
				m_iLastMode = 0;
			}
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( SCOUT_IDLE1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetSCOUTName()
{
	return "weapon_scout";
}

void RegisterSCOUT()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetSCOUTName(), GetSCOUTName() );
	g_ItemRegistry.RegisterWeapon( GetSCOUTName(), "cs_weapons", "ammo_762Nato" );
}