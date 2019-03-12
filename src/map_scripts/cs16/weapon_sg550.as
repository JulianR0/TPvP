enum SG550Animation
{
	SG550_IDLE = 0,
	SG550_SHOOT1,
	SG550_SHOOT2,
	SG550_RELOAD,
	SG550_DRAW
};

const int SG550_DEFAULT_GIVE		= 120;
const int SG550_MAX_CARRY			= 90;
const int SG550_MAX_CLIP			= 30;
const int SG550_WEIGHT				= 20;

enum ScopelMode
{
	MODE_NOSCOPER = 0,
	MODE_SCOPEDO,
	MODE_MORESCOPER
};

class weapon_sg550 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int g_iCurrentMode;
	int m_iShell;
	
	float m_flAccuracy;
	float m_flLastFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/sg550/w_sg550.mdl" );
		
		self.m_iDefaultAmmo = SG550_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_flAccuracy = 0.0;
		m_flLastFire = 0.0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/sg550/v_sg550.mdl");
		g_Game.PrecacheModel( "models/sg550/w_sg550.mdl");
		g_Game.PrecacheModel( "models/sg550/p_sg550.mdl");
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/sg550-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/sg550_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/sg550_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/sg550_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/sg550_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/sg550_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/sg550_boltpull.wav");
		g_SoundSystem.PrecacheSound( "weapons/sg550-1.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud14.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud15.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_sg550.txt" );
		
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= SG550_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= SG550_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= SG550_WEIGHT;
		
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
		
		BaseClass.Holster( skipLocal ); 
    }
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
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
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flAccuracy = 0.0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/sg550/v_sg550.mdl" ), self.GetP_Model( "models/sg550/p_sg550.mdl" ), SG550_DRAW, "m16" );
			
			g_iCurrentMode = 0;
			ToggleZoom( 0 );
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			SG550Fire( 0.45 * ( 1 - m_flAccuracy ), 0.25, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			SG550Fire( 0.15, 0.25, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			SG550Fire( 0.04 * ( 1 - m_flAccuracy ), 0.25, false );
		}
		else
		{
			SG550Fire( 0.05 * ( 1 - m_flAccuracy ), 0.25, false );
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case MODE_NOSCOPER:
			{
				g_iCurrentMode = MODE_SCOPEDO;
				ToggleZoom( 40 );
				break;
			}
		
			case MODE_SCOPE:
			{
				g_iCurrentMode = MODE_MORESCOPER;
				ToggleZoom( 15 );
				break;
			}
			
			case MODE_MORESCOPER:
			{
				g_iCurrentMode = MODE_NOSCOPER;
				ToggleZoom( 0 );
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/zoom.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void SG550Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		if ( m_pPlayer.pev.fov == 0 )
		{
			flSpread += 0.025;
		}
		
		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy = ( WeaponTimeBase() - m_flLastFire ) * 0.35 + 0.65;

			if ( m_flAccuracy > 0.98 )
				m_flAccuracy = 0.98;
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, SG550_DISTANCE, SG550_PENETRATION, BULLET_PLAYER_556MM, SG550_DAMAGE, SG550_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( SG550_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( SG550_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/sg550-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.8;
		
		m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 4, 1.5, 1.75 ) + m_pPlayer.pev.punchangle.x * 0.25;
		m_pPlayer.pev.punchangle.y += g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 5, -1.0, 1.0 ); 
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 11, -8 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < SG550_MAX_CLIP )
		{
			BaseClass.Reload();
			g_iCurrentMode = 0;
			ToggleZoom( 0 );
			m_flAccuracy = 0.0;
		}
		self.DefaultReload( SG550_MAX_CLIP, SG550_RELOAD, 3.82, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( SG550_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetSG550Name()
{
	return "weapon_sg550";
}

void RegisterSG550()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetSG550Name(), GetSG550Name() );
	g_ItemRegistry.RegisterWeapon( GetSG550Name(), "cs_weapons", "ammo_556Nato" );
}