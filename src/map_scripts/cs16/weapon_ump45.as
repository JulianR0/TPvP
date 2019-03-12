enum UMP45Animation
{
	UMP45_IDLE = 0,
	UMP45_RELOAD,
	UMP45_DRAW,
	UMP45_SHOOT1,
	UMP45_SHOOT2,
	UMP45_SHOOT3
};

const int UMP45_DEFAULT_GIVE		= 125;
const int UMP45_MAX_CARRY			= 100;
const int UMP45_MAX_CLIP			= 25;
const int UMP45_WEIGHT				= 25;

class weapon_ump45 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/ump45/w_ump45.mdl" );
		
		self.m_iDefaultAmmo = UMP45_DEFAULT_GIVE;
		m_flAccuracy = 0.0;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ump45/v_ump45.mdl" );
		g_Game.PrecacheModel( "models/ump45/w_ump45.mdl" );
		g_Game.PrecacheModel( "models/ump45/p_ump45.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ump45-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ump45_boltslap.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ump45_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ump45_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ump45-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ump45_boltslap.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ump45_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ump45_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud16.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_ump45.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= UMP45_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= UMP45_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= UMP45_WEIGHT;
		
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
			m_flAccuracy = 0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ump45/v_ump45.mdl" ), self.GetP_Model( "models/ump45/p_ump45.mdl" ), UMP45_DRAW, "mp5" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			UMP45Fire( 0.24 * m_flAccuracy, 0.1, false );
		}
		else
		{
			UMP45Fire( 0.04 * m_flAccuracy, 0.1, false );
		}
	}
	
	void UMP45Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 210.0 ) + 0.5;

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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, UMP45_DISTANCE, UMP45_PENETRATION, BULLET_PLAYER_45ACP, UMP45_DAMAGE, UMP45_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( UMP45_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( UMP45_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( UMP45_SHOOT3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ump45-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 0.125, 0.65, 0.55, 0.0475, 5.5, 4.0, 10 );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 0.55, 0.3, 0.225, 0.03, 3.5, 2.5, 10 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.25, 0.175, 0.125, 0.02, 2.25, 1.25, 10 );
		}
		else
		{
			KickBack( 0.275, 0.2, 0.15, 0.0225, 2.5, 1.5, 10 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 7, -6 );
       
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
		if( self.m_iClip < UMP45_MAX_CLIP )
			BaseClass.Reload();
			
		if( self.DefaultReload( UMP45_MAX_CLIP, UMP45_RELOAD, 3.5, 0 ) )
		{
			m_flAccuracy = 0;
			m_iShotsFired = 0;
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		// Recoil (Shots fired) does not reset on it's own until weapon is reloaded or holstered/deployed. Manual fix. -Giegue
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.2 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.2;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( UMP45_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetUMP45Name()
{
	return "weapon_ump45";
}

void RegisterUMP45()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetUMP45Name(), GetUMP45Name() );
	g_ItemRegistry.RegisterWeapon( GetUMP45Name(), "cs_weapons", "ammo_45acp" );
}