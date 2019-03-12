enum G3SG1Animation
{
	G3SG1_IDLE = 0,
	G3SG1_SHOOT1,
	G3SG1_SHOOT2,
	G3SG1_RELOAD,
	G3SG1_DRAW
};

const int G3SG1_DEFAULT_GIVE		= 110;
const int G3SG1_MAX_CARRY			= 90;
const int G3SG1_MAX_CLIP			= 20;
const int G3SG1_WEIGHT				= 20;

enum ScoperlMode
{
	MODE_NOUNSCOPE = 0,
	MODE_SCOPEDOR,
	MODE_MORESCOPERL
};

class weapon_g3sg1 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/g3sg1/w_g3sg1.mdl" );
		
		self.m_iDefaultAmmo = G3SG1_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_flAccuracy = 0.2;
		m_flLastFire = 0.0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/g3sg1/v_g3sg1.mdl");
		g_Game.PrecacheModel( "models/g3sg1/w_g3sg1.mdl");
		g_Game.PrecacheModel( "models/g3sg1/p_g3sg1.mdl");
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/g3sg1-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/g3sg1_slide.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/g3sg1_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/g3sg1_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/g3sg1_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/g3sg1_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/g3sg1_slide.wav");
		g_SoundSystem.PrecacheSound( "weapons/g3sg1-1.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/ch_sniper.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_g3sg1.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= G3SG1_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= G3SG1_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= G3SG1_WEIGHT;
		
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
			m_flAccuracy = 0.2;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/g3sg1/v_g3sg1.mdl" ), self.GetP_Model( "models/g3sg1/p_g3sg1.mdl" ), G3SG1_DRAW, "m16" );
			
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
			G3SG1Fire( 0.45, 0.25, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			G3SG1Fire( 0.15, 0.25, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			G3SG1Fire( 0.035, 0.25, false );
		}
		else
		{
			G3SG1Fire( 0.055, 0.25, false );
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case MODE_NOUNSCOPE:
			{
				g_iCurrentMode = MODE_SCOPEDOR;
				ToggleZoom( 40 );
				break;
			}
		
			case MODE_SCOPE:
			{
				g_iCurrentMode = MODE_MORESCOPERL;
				ToggleZoom( 10 );
				break;
			}
			
			case MODE_MORESCOPERL:
			{
				g_iCurrentMode = MODE_NOUNSCOPE;
				ToggleZoom( 0 );
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/zoom.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void G3SG1Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		if ( m_pPlayer.pev.fov == 0 )
		{
			flSpread += 0.025;
		}
		
		float spreadModifier = 0.02;
		
		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy = ( WeaponTimeBase() - m_flLastFire ) * 0.3 + 0.55;

			if ( m_flAccuracy > 0.98 )
			{
				m_flAccuracy = 0.98;
			}
			else
			{
				spreadModifier = 1 - m_flAccuracy;
			}
		}
		else
		{
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread * spreadModifier, G3SG1_DISTANCE, G3SG1_PENETRATION, BULLET_PLAYER_762MM, G3SG1_DAMAGE, G3SG1_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( G3SG1_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( G3SG1_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/g3sg1-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.8;
		
		m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 4, 2.75, 3.25 ) + m_pPlayer.pev.punchangle.x * 0.25;
		m_pPlayer.pev.punchangle.y += g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 5, -1.25, 1.5 );
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 11, -6 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < G3SG1_MAX_CLIP )
		{
			BaseClass.Reload();
			g_iCurrentMode = 0;
			ToggleZoom( 0 );
		}
		if( self.DefaultReload( G3SG1_MAX_CLIP, G3SG1_RELOAD, 4.7, 0 ) )
		{
			m_flAccuracy = 0.2;
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( G3SG1_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetG3SG1Name()
{
	return "weapon_g3sg1";
}

void RegisterG3SG1()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetG3SG1Name(), GetG3SG1Name() );
	g_ItemRegistry.RegisterWeapon( GetG3SG1Name(), "cs_weapons", "ammo_762Nato" );
}