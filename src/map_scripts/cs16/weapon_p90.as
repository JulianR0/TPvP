enum P90Animation
{
	P90_IDLE = 0,
	P90_RELOAD,
	P90_DRAW,
	P90_SHOOT1,
	P90_SHOOT2,
	P90_SHOOT3
};

const int P90_DEFAULT_GIVE		= 150;
const int P90_MAX_CARRY			= 100;
const int P90_MAX_CLIP			= 50;
const int P90_WEIGHT			= 26;

class weapon_p90 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/p90/w_p90.mdl" );
		
		self.m_iDefaultAmmo = P90_DEFAULT_GIVE;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/p90/v_p90.mdl" );
		g_Game.PrecacheModel( "models/p90/w_p90.mdl" );
		g_Game.PrecacheModel( "models/p90/p_p90.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/fn57/w_57mm.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/fn57/w_57mmt.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p90-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p90_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p90_cliprelease.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p90_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p90_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p90-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p90_boltpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p90_cliprelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p90_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p90_clipout.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud12.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud13.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_p90.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= P90_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= P90_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= P90_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs05( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs05.WriteLong( self.m_iId );
			cs05.End();
			
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
			m_iShotsFired = 0;
			m_flAccuracy = 0.2;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/p90/v_p90.mdl" ), self.GetP_Model( "models/p90/p_p90.mdl" ), P90_DRAW, "mp5" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			P90Fire( 0.3 * m_flAccuracy, 0.066, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 170 )
		{
			P90Fire( 0.115 * m_flAccuracy, 0.066, false );
		}
		else
		{
			P90Fire( 0.045 * m_flAccuracy, 0.066, false );
		}
	}
	
	void P90Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 175 ) + 0.45;
		
		if ( m_flAccuracy > 1.0 )
			m_flAccuracy = 1.0; 
		
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, P90_DISTANCE, P90_PENETRATION, BULLET_PLAYER_57MM, P90_DAMAGE, P90_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( P90_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( P90_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( P90_SHOOT3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/p90-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime; 
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 0.9, 0.45, 0.35, 0.04, 5.25, 3.5, 4 );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 0.45, 0.3, 0.2, 0.0275, 4.0, 2.25, 7 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.275, 0.2, 0.125, 0.02, 3.0, 1.0, 9 );
		}
		else
		{
			KickBack( 0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8 );
		} 
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 8, -5 );
       
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
		if( self.m_iClip < P90_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( P90_MAX_CLIP, P90_RELOAD, 3.4, 0 ) )
		{
			m_flAccuracy  = 0.2;
			m_iShotsFired = 0;
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		// Recoil (Shots fired) does not reset on it's own until weapon is reloaded or holstered/deployed. Manual fix. -Giegue
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.132 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.132;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( P90_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class FN57Box : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/fn57/w_57mm.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/fn57/w_57mm.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/fn57/w_57mmt.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = P90_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_fn57", P90_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetP90Name()
{
	return "weapon_p90";
}

void RegisterP90()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetP90Name(), GetP90Name() );
	g_ItemRegistry.RegisterWeapon( GetP90Name(), "cs_weapons", "ammo_fn57" );
}

string GetFN57BoxName()
{
	return "ammo_fn57";
}

void RegisterFN57Box()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "FN57Box", GetFN57BoxName() );
}