enum MP5NavyAnimation
{
	MP5Navy_IDLE = 0,
	MP5Navy_RELOAD,
	MP5Navy_DRAW,
	MP5Navy_SHOOT1,
	MP5Navy_SHOOT2,
	MP5Navy_SHOOT3
};

const int MP5Navy_DEFAULT_GIVE		= 150;
const int MP5Navy_MAX_CARRY			= 120;
const int MP5Navy_MAX_CLIP			= 30;
const int MP5Navy_WEIGHT			= 25;

class weapon_mp5navy : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/mp5navy/w_mp5.mdl" );
		
		self.m_iDefaultAmmo = MP5Navy_DEFAULT_GIVE;
		m_flAccuracy = 0.0;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/mp5navy/v_mp5.mdl" );
		g_Game.PrecacheModel( "models/mp5navy/w_mp5.mdl" );
		g_Game.PrecacheModel( "models/mp5navy/p_mp5.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/9mmparab/w_9mmclip_big.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/9mmparab/w_9mmclip_bigt.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mp5-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mp5-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mp5_slideback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mp5_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mp5_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mp5-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mp5-2.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/mp5_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mp5_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mp5_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_mp5navy.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= MP5Navy_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= MP5Navy_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= MP5Navy_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs04( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs04.WriteLong( self.m_iId );
			cs04.End();
			
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
			m_flAccuracy = 0.0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/mp5navy/v_mp5.mdl" ), self.GetP_Model( "models/mp5navy/p_mp5.mdl" ), MP5Navy_DRAW, "mp5" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			MP5NFire( 0.2 * m_flAccuracy, 0.075, false );
		}
		else
		{
			MP5NFire( 0.04 * m_flAccuracy, 0.075, false );
		}
	}
	
	void MP5NFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 220.0 ) + 0.45;

		if ( m_flAccuracy > 0.75 )
			m_flAccuracy = 0.75; 
		
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, MP5N_DISTANCE, MP5N_PENETRATION, BULLET_PLAYER_9MM, MP5N_DAMAGE, MP5N_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( MP5Navy_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( MP5Navy_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( MP5Navy_SHOOT3, 0, 0 ); break;
		}
		
		switch ( Math.RandomLong (0, 1) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/mp5-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/mp5-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 0.9, 0.475, 0.35, 0.0425, 5.0, 3.0, 6 );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 0.5, 0.275, 0.2, 0.03, 3.0, 2.0, 10 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.225, 0.15, 0.1, 0.015, 2.0, 1.0, 10 );
		}
		else
		{
			KickBack( 0.25, 0.175, 0.125, 0.02, 2.25, 1.25, 10 );
		} 
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 8, -6 );
       
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
		if( self.m_iClip < MP5Navy_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( MP5Navy_MAX_CLIP, MP5Navy_RELOAD, 2.63, 0 ) )
		{
			m_flAccuracy = 0.0;
			m_iShotsFired = 0; 
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		// Recoil (Shots fired) does not reset on it's own until weapon is reloaded or holstered/deployed. Manual fix. -Giegue
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.15 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.15;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( MP5Navy_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class NinemmBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/9mmparab/w_9mmclip_big.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/9mmparab/w_9mmclip_big.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/9mmparab/w_9mmclip_bigt.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = MP5Navy_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_9mmparab", MP5Navy_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetMP5NavyName()
{
	return "weapon_mp5navy";
}

void RegisterMP5Navy()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMP5NavyName(), GetMP5NavyName() );
	g_ItemRegistry.RegisterWeapon( GetMP5NavyName(), "cs_weapons", "ammo_9mmparab" );
}

string GetNinemmBoxName()
{
	return "ammo_9mmparab";
}

void RegisterNinemmBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "NinemmBox", GetNinemmBoxName() );
}