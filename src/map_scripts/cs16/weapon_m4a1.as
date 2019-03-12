enum M4A1Animation
{
	M4A1_IDLE = 0,
	M4A1_SHOOT1,
	M4A1_SHOOT2,
	M4A1_SHOOT3,
	M4A1_RELOAD,
	M4A1_DRAW,
	M4A1_ADD_SILENCER,
	M4A1_IDLE_UNSIL,
	M4A1_SHOOT1_UNSIL,
	M4A1_SHOOT2_UNSIL,
	M4A1_SHOOT3_UNSIL,
	M4A1_RELOAD_UNSIL,
	M4A1_DRAW_UNSIL,
	M4A1_DETACH_SILENCER
};

enum eFireMode
{
	MODE_UNSILENCED = 0,
	MODE_SILENCED
};

const int M4A1_DEFAULT_GIVE		= 120;
const int M4A1_MAX_CARRY		= 90;
const int M4A1_MAX_CLIP			= 30;
const int M4A1_WEIGHT			= 25;

class weapon_m4a1 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/m4a1/w_m4a1.mdl" );
		
		self.m_iDefaultAmmo = M4A1_DEFAULT_GIVE;
		g_iCurrentMode = 0;
		m_flAccuracy = 0.2;
		m_iShotsFired = 0;
		m_iDirection = 0;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/m4a1/v_m4a1.mdl");
		g_Game.PrecacheModel( "models/m4a1/w_m4a1.mdl");
		g_Game.PrecacheModel( "models/m4a1/p_m4a1.mdl");
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556nato.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556natot.mdl" );
		
		m_iShell = g_Game.PrecacheModel ( "models/shell.mdl");
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_unsil-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_unsil-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_silencer_off.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_silencer_on.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_deploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_clipout.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_clipin.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/m4a1_boltpull.wav");
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/m4a1_unsil-1.wav");
		g_SoundSystem.PrecacheSound( "weapons/m4a1_unsil-2.wav");
		g_SoundSystem.PrecacheSound( "weapons/m4a1-1.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/m4a1_silencer_off.wav");
		g_SoundSystem.PrecacheSound( "weapons/m4a1_silencer_on.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/m4a1_deploy.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/m4a1_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/m4a1_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/m4a1_boltpull.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_m4a1.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= M4A1_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= M4A1_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= M4A1_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage cs03( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs03.WriteLong( self.m_iId );
			cs03.End();
			
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
		return g_Engine.time; //g_weaponFuncs.WeaponTimeBase();
	}
	
	
	
	bool Deploy()
	{	//this fixes the draw anim getting cut off by the idle animation
		bool bResult;
		{
			m_flAccuracy = 0.2;
			m_iShotsFired = 0;
			
			if ( g_iCurrentMode == MODE_SILENCED )
			{
				bResult = self.DefaultDeploy ( self.GetV_Model( "models/m4a1/v_m4a1.mdl" ), self.GetP_Model( "models/m4a1/p_m4a1.mdl" ), M4A1_DRAW, "m16" );
			}
			else
			{
				bResult = self.DefaultDeploy ( self.GetV_Model( "models/m4a1/v_m4a1.mdl" ), self.GetP_Model( "models/m4a1/p_m4a1.mdl" ), M4A1_DRAW_UNSIL, "m16" );
			}
			
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;

			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if ( g_iCurrentMode == MODE_SILENCED )
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				M4A1Fire( 0.035 + ( 0.4 * m_flAccuracy ), 0.0875, false);
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				M4A1Fire( 0.035 + ( 0.07  * m_flAccuracy ), 0.0875, false );
			}
			else
			{
				M4A1Fire( 0.025 * m_flAccuracy, 0.0875, false );
			}
		}
		else
		{
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				M4A1Fire( 0.035 + ( 0.4 * m_flAccuracy ), 0.0875, false );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				M4A1Fire( 0.035 + ( 0.07 * m_flAccuracy ), 0.0875, false );
			}
			else
			{
				M4A1Fire( 0.02 * m_flAccuracy, 0.0875, false );
			}
		}
	}
	
	void M4A1Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		m_flAccuracy = ( ( m_iShotsFired * m_iShotsFired * m_iShotsFired ) / 220.0 ) + 0.3;

		if ( m_flAccuracy > 1.0 )
			m_flAccuracy = 1; 
		
		m_flLastFire = WeaponTimeBase();
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
			return;
		}
		
		self.m_iClip--;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		if( g_iCurrentMode == MODE_UNSILENCED )
		{
			m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
			
			Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, M4A1_DISTANCE, M4A1_PENETRATION, BULLET_PLAYER_556MM, M4A1_DAMAGE, M4A1_RANGE_MODIFER );
		}
		else if ( g_iCurrentMode == MODE_SILENCED )
		{
			m_pPlayer.m_iWeaponVolume = 0;
			m_pPlayer.m_iWeaponFlash = 0;
			
			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
			Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, M4A1_DISTANCE, M4A1_PENETRATION, BULLET_PLAYER_556MM, M4A1_DAMAGE_SIL, M4A1_RANGE_MODIFER_SIL );
		}
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0:	
			{
				if ( g_iCurrentMode == MODE_SILENCED )
				{
					self.SendWeaponAnim( M4A1_SHOOT1, 0, 0 );
				}
				else 
				{ 
					self.SendWeaponAnim( M4A1_SHOOT1_UNSIL, 0, 0 );
				}
				break;
			}
			case 1: 
			{
				if ( g_iCurrentMode == MODE_SILENCED )
				{
					self.SendWeaponAnim( M4A1_SHOOT2, 0, 0 );
				}
				else
				{
					self.SendWeaponAnim( M4A1_SHOOT2_UNSIL, 0, 0 );
				}
				break;
			}
			case 2: 
			{
				if ( g_iCurrentMode == MODE_SILENCED )
				{
					self.SendWeaponAnim( M4A1_SHOOT3, 0, 0 );
				}
				else
				{
					self.SendWeaponAnim( M4A1_SHOOT3_UNSIL, 0, 0 );
				}
				break;
			}
		}
		
		if ( g_iCurrentMode == MODE_UNSILENCED )
		{
			switch( Math.RandomLong( 0, 1 ) )
			{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/m4a1_unsil-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/m4a1_unsil-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			}
		}
		else if ( g_iCurrentMode == MODE_SILENCED )
		{
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/m4a1-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5;
		
		if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7 );
		}
		else if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			KickBack( 1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6 );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			KickBack( 0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7 );
		}
		else
		{
			KickBack( 0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7 );
		}
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 10, -5 );
       
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
	
	void SecondaryAttack()
	{
		switch ( g_iCurrentMode )
		{
			case MODE_UNSILENCED:
			{
				g_iCurrentMode = MODE_SILENCED;
				self.SendWeaponAnim( M4A1_ADD_SILENCER, 0, 0 );
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "sound/weapons/m4a1_silencer_on.wav", 0.9, ATTN_NORM, 0, PITCH_NORM);
				break; 
			}
			case MODE_SILENCED:
			{
				g_iCurrentMode = MODE_UNSILENCED;
				self.SendWeaponAnim( M4A1_DETACH_SILENCER, 0, 0 );
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "sound/weapons/m4a1_silencer_off.wav", 0.9, ATTN_NORM, 0, PITCH_NORM);
				break;
			}
		}
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.5;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 2.0;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 2.0;
	}
	
	void Reload()
	{
		if( self.m_iClip < M4A1_MAX_CLIP )
			BaseClass.Reload();
		
		if ( g_iCurrentMode == MODE_SILENCED )
		{
			if ( self.DefaultReload( M4A1_MAX_CLIP, M4A1_RELOAD, 3.08, 0 ) )
			{
				m_flAccuracy = 0.2;
				m_iShotsFired = 0;
			}
		}
		else
		{
			if ( self.DefaultReload( M4A1_MAX_CLIP, M4A1_RELOAD_UNSIL, 3.08, 0 ) )
			{
				m_flAccuracy = 0.2;
				m_iShotsFired = 0;
			}
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		// Recoil (Shots fired) does not reset on it's own until weapon is reloaded or holstered/deployed. Manual fix. -Giegue
		if ( m_iShotsFired > 0 && WeaponTimeBase() > ( m_flLastFire + 0.175 ) )
		{
			m_iShotsFired--;
			m_flLastFire = WeaponTimeBase() + 0.175;
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		switch ( Math.RandomLong ( 0, 0 ) )
		{
			case 0:
			if( g_iCurrentMode == MODE_SILENCED )
			{
				iAnim = M4A1_IDLE; break;
			}
			else
			{
				iAnim = M4A1_IDLE_UNSIL; break;
			}
		}
		
		self.SendWeaponAnim( iAnim );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class Ammo556NatoBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/556/w_556nato.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556nato.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/556/w_556natot.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = M4A1_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_556Nato", M4A1_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetM4A1Name()
{
	return "weapon_m4a1";
}

void RegisterM4A1()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetM4A1Name(), GetM4A1Name() );
	g_ItemRegistry.RegisterWeapon( GetM4A1Name(), "cs_weapons", "ammo_556Nato" );
}

string GetAmmo556NatoBoxName()
{
	return "ammo_556Nato";
}

void RegisterAmmo556NatoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "Ammo556NatoBox", GetAmmo556NatoBoxName() );
}