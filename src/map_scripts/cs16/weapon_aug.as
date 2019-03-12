enum AUGAnimation
{
	AUG_IDLE = 0,
	AUG_RELOAD,
	AUG_DRAW,
	AUG_SHOOT1,
	AUG_SHOOT2,
	AUG_SHOOT3
};

enum ScopedMode
{
	MODE_UNSCOPE = 0,
	MODE_SCOPE
};

const int AUG_DEFAULT_GIVE		= 120;
const int AUG_MAX_CARRY			= 90;
const int AUG_MAX_CLIP			= 30;
const int AUG_WEIGHT			= 25;

class weapon_aug : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int g_iCurrentMode;
	int m_iShell;
	
	float m_flAccuracy;
	float m_flLastFire;
	int m_iShotsFired;
	int m_iDirection;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/aug/w_aug.mdl" );
		
		self.m_iDefaultAmmo = AUG_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/aug/v_aug.mdl");
		g_Game.PrecacheModel( "models/aug/w_aug.mdl");
		g_Game.PrecacheModel( "models/aug/p_aug.mdl");
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl");
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/aug-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/aug_forearm.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/aug_clipout.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/aug_clipin.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/aug_boltslap.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/aug_boltpull.wav");
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav");
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/aug-1.wav");
		g_SoundSystem.PrecacheSound( "weapons/aug_forearm.wav");
		g_SoundSystem.PrecacheSound( "weapons/aug_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/aug_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/aug_boltpull.wav");
		g_SoundSystem.PrecacheSound( "weapons/aug_boltslap.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_aug.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= AUG_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= AUG_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= AUG_WEIGHT;
		
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
		
		if ( self.m_fInZoom )
			ToggleZoom();
		
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
	
	void ToggleZoom()
	{
		if ( self.m_fInZoom )
		{
			self.m_fInZoom = false;
			SetFOV( 0 ); // 0 means reset to default fov
		}
		else
		{
			self.m_fInZoom = true;
			SetFOV( 35 );
		}
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flAccuracy = 0.2;
			m_iShotsFired = 0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/aug/v_aug.mdl" ), self.GetP_Model( "models/aug/p_aug.mdl" ), AUG_DRAW, "m16" );
			
			g_iCurrentMode = 0;
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			AUGFire( 0.035 + 0.4 * m_flAccuracy, 0.0825, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			AUGFire( 0.035 + 0.07 * m_flAccuracy, 0.0825, false );
		}
		else if ( m_pPlayer.pev.fov == 0 ) // Default FOV I suppose...
		{
			AUGFire( 0.02 * m_flAccuracy, 0.0825, false );
		}
		else
		{
			AUGFire( 0.02 * m_flAccuracy, 0.135, false );
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
				ToggleZoom();
				break;
			}
			
			case MODE_SCOPE:
			{
				g_iCurrentMode = MODE_UNSCOPE;
				ToggleZoom();
				break;
			}
		}
	}
	
	void AUGFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 215.0 ) + 0.3;
		
		if ( m_flAccuracy > 1.0 )
		{
			m_flAccuracy = 1.0;
		} 
		
		m_flLastFire = WeaponTimeBase();
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_iClip--;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, AUG_DISTANCE, AUG_PENETRATION, BULLET_PLAYER_556MM, AUG_DAMAGE, AUG_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( AUG_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( AUG_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( AUG_SHOOT3, 0, 0 ); break;
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/aug-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self. m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.9;
		
		if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.0, 0.45, 0.275, 0.05, 4.0, 2.5, 7 );
		}
		else if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.25, 0.45, 0.22, 0.18, 5.5, 4.0, 5 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.575, 0.325, 0.2, 0.011, 3.25, 2.0, 8 );
		}
		else
		{
			KickBack( 0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8 );
		} 
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 12, -10 );
       
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
		if( self.m_iClip < AUG_MAX_CLIP )
		{
			g_iCurrentMode = 0;
			
			if ( self.m_fInZoom )
				ToggleZoom();
			
			BaseClass.Reload();
		}
		
		if ( self.DefaultReload( AUG_MAX_CLIP, AUG_RELOAD, 3.325, 0 ) )
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
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.165 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.165;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( AUG_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetAUGName()
{
	return "weapon_aug";
}

void RegisterAUG()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetAUGName(), GetAUGName() );
	g_ItemRegistry.RegisterWeapon( GetAUGName(), "cs_weapons", "ammo_556Nato" );
}