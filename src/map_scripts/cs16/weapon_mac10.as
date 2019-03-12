enum MAC10Animation
{
	MAC10_IDLE = 0,
	MAC10_RELOAD,
	MAC10_DRAW,
	MAC10_SHOOT1,
	MAC10_SHOOT2,
	MAC10_SHOOT3
};

const int MAC10_DEFAULT_GIVE		= 130;
const int MAC10_MAX_CARRY			= 100;
const int MAC10_MAX_CLIP			= 30;
const int MAC10_WEIGHT				= 25;

class weapon_mac10 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/mac10/w_mac10.mdl" );
		
		self.m_iDefaultAmmo = MAC10_DEFAULT_GIVE;
		m_flAccuracy = 0.15;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/mac10/v_mac10.mdl" );
		g_Game.PrecacheModel( "models/mac10/w_mac10.mdl" );
		g_Game.PrecacheModel( "models/mac10/p_mac10.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mac10-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mac10_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mac10_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/mac10_clipout.wav" );
		
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mac10-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mac10_boltpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mac10_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mac10_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_mac10.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= MAC10_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= MAC10_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= MAC10_WEIGHT;
		
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
			m_flAccuracy = 0.15;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/mac10/v_mac10.mdl" ), self.GetP_Model( "models/mac10/p_mac10.mdl" ), MAC10_DRAW, "onehanded" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			MAC10Fire( 0.375 * m_flAccuracy, 0.07, false );
		}
		else
		{
			MAC10Fire( 0.03 * m_flAccuracy, 0.07, false );
		}
	}
	
	void MAC10Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 200 ) + 0.6;
		
		if ( m_flAccuracy > 1.65 )
			m_flAccuracy = 1.65;
		
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, MAC10_DISTANCE, MAC10_PENETRATION, BULLET_PLAYER_45ACP, MAC10_DAMAGE, MAC10_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( MAC10_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( MAC10_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( MAC10_SHOOT3, 0, 0 ); break;
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/mac10-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.3, 0.55, 0.4, 0.05, 4.75, 3.75, 5 );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 0.9, 0.45, 0.25, 0.035, 3.5, 2.75, 7 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.75, 0.4, 0.175, 0.03, 2.75, 2.5, 10 );
		}
		else
		{
			KickBack( 0.775, 0.425, 0.2, 0.03, 3.0, 2.75, 9 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 7, -5 );
       
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
		if( self.m_iClip < MAC10_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( MAC10_MAX_CLIP, MAC10_RELOAD, 3.15, 0 ) )
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
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.14 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.14;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( MAC10_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetMAC10Name()
{
	return "weapon_mac10";
}

void RegisterMAC10()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMAC10Name(), GetMAC10Name() );
	g_ItemRegistry.RegisterWeapon( GetMAC10Name(), "cs_weapons", "ammo_45acp" );
}