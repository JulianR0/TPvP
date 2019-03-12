enum FAMASAnimation
{
	FAMAS_IDLE = 0,
	FAMAS_RELOAD,
	FAMAS_DRAW,
	FAMAS_SHOOT1,
	FAMAS_SHOOT2,
	FAMAS_SHOOT3
};

const int FAMAS_DEFAULT_GIVE		= 120;
const int FAMAS_MAX_CARRY		   = 90;
const int FAMAS_MAX_CLIP			= 25;
const int FAMAS_WEIGHT			  = 5;

enum FamasBurstFire
{
	MODE_NOBURST = 0,
	MODE_BURST
}

class weapon_famas : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int g_iCurrentMode;
	int m_iShell;
	
	float m_flAccuracy;
	bool m_bBurstFire;
	int m_iShotsFired;
	int m_iFamasShotsFired;
	float m_flLastFire;
	int m_iDirection;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/famas/w_famas.mdl" );

		self.m_iDefaultAmmo = FAMAS_DEFAULT_GIVE;
		g_iCurrentMode = MODE_NOBURST;
		m_iFamasShotsFired = 0;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/famas/v_famas.mdl" );
		g_Game.PrecacheModel( "models/famas/w_famas.mdl" );
		g_Game.PrecacheModel( "models/famas/p_famas.mdl" );

		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/famas-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/famas-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/famas_forearm.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/famas_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/famas_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/famas-burst.wav" );

		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/famas-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/famas-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/famas_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/famas_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/famas_forearm.wav" );
		g_SoundSystem.PrecacheSound( "weapons/famas-burst.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud17.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud18.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_famas.txt" );
	}
   
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1  = FAMAS_MAX_CARRY;
		info.iMaxAmmo2  = -1;
		info.iMaxClip   = FAMAS_MAX_CLIP;
		info.iSlot	  = 3;
		info.iPosition  = 5;
		info.iFlags	 = 0;
		info.iWeight	= FAMAS_WEIGHT;
	   
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
			m_iFamasShotsFired = 0;
			m_flAccuracy = 0.2;
			m_iShotsFired = 0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/famas/v_famas.mdl" ), self.GetP_Model( "models/famas/p_famas.mdl" ), FAMAS_DRAW, "m16" );
			
			float deployTime = 1.03;
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
		
		if ( g_iCurrentMode == MODE_BURST )
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				FamasFire( 0.030 + 0.3 * m_flAccuracy, 0.0825, false, true );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				FamasFire( 0.030 + 0.07 * m_flAccuracy, 0.0825, false, true );
			}
			else
			{
				FamasFire( 0.02 * m_flAccuracy, 0.0825, false, true );
			}
		}
		else
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				FamasFire( 0.030 + 0.3 * m_flAccuracy, 0.0825, false, false );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				FamasFire( 0.030 + 0.07 * m_flAccuracy, 0.0825, false, false );
			}
			else
			{
				FamasFire( 0.02 * m_flAccuracy, 0.0825, false, false );
			}
		}
	}
	
	void SecondaryAttack()
	{
		switch( g_iCurrentMode )
		{
			case MODE_NOBURST:
			{
				g_iCurrentMode = MODE_BURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Cambiado a Burst-Fire\n" );
				break;
			}
			case MODE_BURST:
			{
				g_iCurrentMode = MODE_NOBURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Cambiado a Automatica\n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}
	
	void FamasFire( float flSpread, float flCycleTime, bool fUseAutoAim, bool bFireBurst )
	{
		if ( !bFireBurst )
		{
			flSpread += 0.01;
		}
		
		m_iShotsFired++;

		m_flAccuracy = ( m_iShotsFired * m_iShotsFired * m_iShotsFired / 215.0 ) + 0.3;
		
		if ( m_flAccuracy > 1.0 )
		{
			m_flAccuracy = 1;
		}
		
		m_flLastFire = WeaponTimeBase();
		
		if( self.m_iClip <= 0 )
		{
			m_iFamasShotsFired = 0;
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_iClip--;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, FAMAS_DISTANCE, FAMAS_PENETRATION, BULLET_PLAYER_556MM, ( bFireBurst ? FAMAS_DAMAGE_BURST : FAMAS_DAMAGE ), FAMAS_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( FAMAS_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( FAMAS_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( FAMAS_SHOOT3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/famas-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.1;
		
		if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1, 0.45, 0.275, 0.05, 4, 2.5, 7 );
		}
		else if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.25, 0.45, 0.22, 0.18, 5.5, 4, 5 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.575, 0.325, 0.2, 0.011, 3.25, 2, 8 );
		}
		else
		{
			KickBack( 0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8 );
		}
		
		if ( bFireBurst )
		{
			m_iFamasShotsFired++;
			if ( m_iFamasShotsFired == 3 )
			{
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.55;
				m_iFamasShotsFired = 0;
			}
		}
		
		Vector vecShellVelocity, vecShellOrigin;

		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 19, 15, -12 );

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
		if( self.m_iClip < FAMAS_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( FAMAS_MAX_CLIP, FAMAS_RELOAD, 3.03, 0 ) )
		{
			m_flAccuracy = 0.2;
			m_iShotsFired = 0;
			m_iFamasShotsFired = 0;
		}
	}

	//Overridden to prevent WeaponIdle from being blocked by holding down buttons.
	void ItemPostFrame()
	{
		//If firing bursts, handle next shot.
		if( m_iFamasShotsFired > 0 )
		{
			if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			{
				if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
				{
					FamasFire( 0.030 + 0.3 * m_flAccuracy, 0.0825, false, true );
				}
				else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
				{
					FamasFire( 0.030 + 0.07 * m_flAccuracy, 0.0825, false, true );
				}
				else
				{
					FamasFire( 0.02 * m_flAccuracy, 0.0825, false, true );
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
		
		// Recoil (Shots fired) does not reset on it's own until weapon is reloaded or holstered/deployed. Manual fix. -Giegue
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.165 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.165;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( FAMAS_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetFAMASName()
{
	return "weapon_famas";
}

void RegisterFAMAS()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetFAMASName(), GetFAMASName() );
	g_ItemRegistry.RegisterWeapon( GetFAMASName(), "cs_weapons", "ammo_556Nato" );
}