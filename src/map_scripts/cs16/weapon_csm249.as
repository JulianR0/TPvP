enum M249Animation
{
	M249_IDLE = 0,
	M249_SHOOT1,
	M249_SHOOT2,
	M249_RELOAD,
	M249_DRAW
};

const int M249_DEFAULT_GIVE			= 300;
const int M249_MAX_CARRY			= 200;
const int M249_MAX_CLIP				= 100;
const int M249_WEIGHT				= 25;

class weapon_csm249 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/m249/w_m249.mdl" );
		
		self.m_iDefaultAmmo = M249_DEFAULT_GIVE;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/m249/v_m249.mdl" );
		g_Game.PrecacheModel( "models/m249/w_m249.mdl" );
		g_Game.PrecacheModel( "models/m249/p_m249.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556natobox.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556natoboxt.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249_coverup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249_coverdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249_chain.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249_boxout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m249_boxin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/slideback1.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249_boxin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249_boxout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249_chain.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249_coverup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/m249_coverdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/slideback1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud3.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud6.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_csm249.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= M249_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= M249_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= M249_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs22( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs22.WriteLong( self.m_iId );
			cs22.End();
			
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
		bResult = self.DefaultDeploy ( self.GetV_Model( "models/m249/v_m249.mdl" ), self.GetP_Model( "models/m249/p_m249.mdl" ), M249_DRAW, "saw" );
		
		float deployTime = 1.03;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
		return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			M249Fire( 0.045 + ( 0.5 * m_flAccuracy ), 0.1, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			M249Fire( 0.045 + ( 0.095 * m_flAccuracy ), 0.1, false );
		}
		else
		{
			M249Fire( 0.03 * m_flAccuracy, 0.1, false );
		}
	}
	
	void M249Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 175 ) + 0.4;
		
		if ( m_flAccuracy > 0.9 )
			m_flAccuracy = 0.9;
		
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, M249_DISTANCE, M249_PENETRATION, BULLET_PLAYER_556MM, M249_DAMAGE, M249_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( M249_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( M249_SHOOT2, 0, 0 ); break;
		}
		
		switch ( Math.RandomLong ( 0, 1 ) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/m249-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/m249-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.6;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.8, 0.65, 0.45, 0.125, 5.0, 3.5, 8 );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.1, 0.5, 0.3, 0.06, 4.0, 3.0, 8 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.75, 0.325, 0.25, 0.025, 3.5, 2.5, 9 );
		}
		else
		{
			KickBack( 0.8, 0.35, 0.3, 0.03, 3.75, 3.0, 9 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 9, -5 );
       
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
		if( self.m_iClip < M249_MAX_CLIP )
			BaseClass.Reload();
		
		if ( self.DefaultReload( M249_MAX_CLIP, M249_RELOAD, 4.7, 0 ) )
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
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.2 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.2;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( M249_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class Ammo_556NatoBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/556/w_556natobox.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556natobox.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556natoboxt.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = M249_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_556Natobox", M249_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetCSM249Name()
{
	return "weapon_csm249";
}

void RegisterCSM249()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetCSM249Name(), GetCSM249Name() );
	g_ItemRegistry.RegisterWeapon( GetCSM249Name(), "cs_weapons", "ammo_556Natobox" );
}

string GetAmmo_556NatoBoxName()
{
	return "ammo_556Natobox";
}

void RegisterAmmo_556NatoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "Ammo_556NatoBox", GetAmmo_556NatoBoxName() );
}