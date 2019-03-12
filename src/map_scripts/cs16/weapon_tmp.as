enum TMPAnimation
{
	TMP_IDLE = 0,
	TMP_RELOAD,
	TMP_DRAW,
	TMP_SHOOT1,
	TMP_SHOOT2,
	TMP_SHOOT3
};

const int TMP_DEFAULT_GIVE		= 150;
const int TMP_MAX_CARRY			= 120;
const int TMP_MAX_CLIP			= 30;
const int TMP_WEIGHT			= 25;

class weapon_tmp : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/tmp/w_tmp.mdl" );
		
		self.m_iDefaultAmmo = TMP_DEFAULT_GIVE;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/tmp/v_tmp.mdl" );
		g_Game.PrecacheModel( "models/tmp/w_tmp.mdl" );
		g_Game.PrecacheModel( "models/tmp/p_tmp.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/tmp-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/tmp-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/clipin1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/clipout1.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/tmp-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/tmp-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/clipin1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/clipout1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud2.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud5.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_tmp.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= TMP_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= TMP_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 5;
		info.iFlags		= 0;
		info.iWeight	= TMP_WEIGHT;
		
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
			m_flAccuracy  = 0.2;
			m_iShotsFired = 0;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/tmp/v_tmp.mdl" ), self.GetP_Model( "models/tmp/p_tmp.mdl" ), TMP_DRAW, "onehanded" );
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			TMPFire( 0.25 * m_flAccuracy, 0.07, false );
		}
		else
		{
			TMPFire( 0.03 * m_flAccuracy, 0.07, false );
		}
	}
	
	void TMPFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 200 ) + 0.55;

		if ( m_flAccuracy > 1.4 )
			m_flAccuracy = 1.4;
		
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, TMP_DISTANCE, TMP_PENETRATION, BULLET_PLAYER_9MM, TMP_DAMAGE, TMP_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = 0;
		m_pPlayer.m_iWeaponFlash = 0;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( TMP_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( TMP_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( TMP_SHOOT3, 0, 0 ); break;
		}
		
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/tmp-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/tmp-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.1, 0.5, 0.35, 0.045, 4.5, 3.5, 6 );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 0.8, 0.4, 0.2, 0.03, 3.0, 2.5, 7 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.7, 0.35, 0.125, 0.025, 2.5, 2.0, 10 );
		}
		else
		{
			KickBack( 0.725, 0.375, 0.15, 0.025, 2.75, 2.25, 9 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 10, 7, -8 );
       
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
		if( self.m_iClip < TMP_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( TMP_MAX_CLIP, TMP_RELOAD, 2.16, 0 ) )
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
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.14 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.14;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( TMP_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetTMPName()
{
	return "weapon_tmp";
}

void RegisterTMP()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetTMPName(), GetTMPName() );
	g_ItemRegistry.RegisterWeapon( GetTMPName(), "cs_weapons", "ammo_9mmparab" );
}