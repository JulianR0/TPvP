enum AK47Animation
{
	AK47_IDLE = 0,
	AK47_RELOAD,
	AK47_DRAW,
	AK47_SHOOT1,
	AK47_SHOOT2,
	AK47_SHOOT3
};

const int AK47_DEFAULT_GIVE		= 120;
const int AK47_MAX_CARRY		= 90;
const int AK47_MAX_CLIP			= 30;
const int AK47_WEIGHT			= 25;

class weapon_ak47 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/ak47/w_ak47.mdl" );
		
		self.m_iDefaultAmmo = AK47_DEFAULT_GIVE;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ak47/v_ak47.mdl" );
		g_Game.PrecacheModel( "models/ak47/w_ak47.mdl" );
		g_Game.PrecacheModel( "models/ak47/p_ak47.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/762/w_762nato.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/762/w_762natot.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ak47-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ak47-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ak47_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ak47_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ak47_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ak47-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ak47-2.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ak47_boltpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ak47_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ak47_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud10.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud11.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_ak47.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= AK47_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= AK47_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= AK47_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs02( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs02.WriteLong( self.m_iId );
			cs02.End();
			
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
			m_flAccuracy = 0.2;
			m_iShotsFired = 0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ak47/v_ak47.mdl" ), self.GetP_Model( "models/ak47/p_ak47.mdl" ), AK47_DRAW, "m16" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			AK47Fire( 0.04 + ( 0.4 * m_flAccuracy ), 0.0955, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			AK47Fire( 0.04 + ( 0.07 * m_flAccuracy ), 0.0955, false );
		}
		else
		{
			AK47Fire( 0.0275 * m_flAccuracy, 0.0955, false );
		}
	}
	
	void AK47Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = 0.35 + ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 200 );
		
		if ( m_flAccuracy > 1.25 )
		{
			m_flAccuracy = 1.25;
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, AK47_DISTANCE, AK47_PENETRATION, BULLET_PLAYER_762MM, AK47_DAMAGE, AK47_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( AK47_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( AK47_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( AK47_SHOOT3, 0, 0 ); break;
		}
		
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ak47-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ak47-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.9;
		
		if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7 );
		}
		else if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 2.0, 1.0, 0.5, 0.35, 9.0, 6.0, 5 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9 );
		}
		else
		{
			KickBack( 1.0, 0.375, 0.175, 0.0375, 5.75, 1.75, 8 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
		
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 12, -9 );
		
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
		if ( self.m_iClip < AK47_MAX_CLIP )
			BaseClass.Reload();
		
		if ( self.DefaultReload( AK47_MAX_CLIP, AK47_RELOAD, 2.45, 0 ) )
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
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.191 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.191;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( AK47_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class AK47AmmoBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/762/w_762nato.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/762/w_762nato.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/762/w_762natot.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = AK47_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_762Nato", AK47_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetAK47Name()
{
	return "weapon_ak47";
}

void RegisterAK47()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetAK47Name(), GetAK47Name() );
	g_ItemRegistry.RegisterWeapon( GetAK47Name(), "cs_weapons", "ammo_762Nato" );
}

string GetAK47AmmoBoxName()
{
	return "ammo_762Nato";
}

void RegisterAK47AmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "AK47AmmoBox", GetAK47AmmoBoxName() );
}