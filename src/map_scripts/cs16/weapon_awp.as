enum AWPAnimation
{
	AWP_IDLE1 = 0,
	AWP_SHOOT1,
	AWP_SHOOT2,
	AWP_SHOOT3,
	AWP_RELOAD,
	AWP_DRAW
};

const int AWP_DEFAULT_GIVE		= 40;
const int AWP_MAX_CARRY			= 30;
const int AWP_MAX_CLIP			= 10;
const int AWP_WEIGHT			= 30;

enum ScopeMode
{
	MODE_NOSCOPE = 0,
	MODE_SCOPED,
	MODE_MORESCOPE
};

class weapon_awp : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/awp/w_awp.mdl" );
		
		self.m_iDefaultAmmo = AWP_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_bResumeZoom = false;
		m_iLastZoom = 0;
		m_iLastMode = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/awp/v_awp.mdl" );
		g_Game.PrecacheModel( "models/awp/w_awp.mdl" );
		g_Game.PrecacheModel( "models/awp/p_awp.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/338lapua/w_338magnum.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/338lapua/w_338magnumt.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/awp1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/boltdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/boltpull1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/awp_deploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/boltup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/awp_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/awp_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/zoom.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/awp_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/awp_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/awp1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/boltup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/boltdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/boltpull1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/zoom.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud2.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud5.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/ch_sniper.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_awp.txt");
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= AWP_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= AWP_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= AWP_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs25( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs25.WriteLong( self.m_iId );
			cs25.End();
			
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/awp/v_awp.mdl" ), self.GetP_Model( "models/awp/p_awp.mdl" ), AWP_DRAW, "sniper" );
			
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.45;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			AWPFire( 0.85, 1.45, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			AWPFire( 0.25, 1.45, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 10 )
		{
			AWPFire( 0.1, 1.45, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			AWPFire( 0.0, 1.45, false );
		}
		else
		{
			AWPFire( 0.001, 1.45, false );
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case MODE_UNSCOPE:
			{
				g_iCurrentMode = MODE_SCOPE;
				ToggleZoom( 40 );
				m_pPlayer.m_szAnimExtension = "sniperscope";
				m_pPlayer.pev.maxspeed = 150;
				break;
			}
		
			case MODE_SCOPE:
			{
				g_iCurrentMode = MODE_MORESCOPE;
				ToggleZoom( 10 );
				m_pPlayer.m_szAnimExtension = "sniperscope";
				m_pPlayer.pev.maxspeed = 150;
				break;
			}
			
			case MODE_MORESCOPE:
			{
				g_iCurrentMode = MODE_NOSCOPE;
				ToggleZoom( 0 );
				m_pPlayer.m_szAnimExtension = "sniper";
				m_pPlayer.pev.maxspeed = 0;
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/zoom.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void AWPFire( float flSpread, float flCycleTime, bool fUseAutoAim )
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
			flCycleTime += 0.08;
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, AWP_DISTANCE, AWP_PENETRATION, BULLET_PLAYER_338MAG, AWP_DAMAGE, AWP_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( AWP_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( AWP_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( AWP_SHOOT3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/awp1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime; 
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		
		m_pPlayer.pev.punchangle.x -= 2;
		
		Vector vecShellVelocity, vecShellOrigin;
		
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 9, -8 );
		
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < AWP_MAX_CLIP )
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
		self.DefaultReload( AWP_MAX_CLIP, AWP_RELOAD, 3.0, 0 );
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
		
		self.SendWeaponAnim( AWP_IDLE1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class LapuaMagnumBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/338lapua/w_338magnum.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/338lapua/w_338magnum.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/338lapua/w_338magnumt.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = AWP_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_338lapua", AWP_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetAWPName()
{
	return "weapon_awp";
}

void RegisterAWP()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetAWPName(), GetAWPName() );
	g_ItemRegistry.RegisterWeapon( GetAWPName(), "cs_weapons", "ammo_338lapua" );
}

string GetLapuaMagnumBoxName()
{
	return "ammo_338lapua";
}

void RegisterLapuaMagnumBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "LapuaMagnumBox", GetLapuaMagnumBoxName() );
}