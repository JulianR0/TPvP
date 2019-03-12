enum P228Animation
{
	P228_IDLE = 0,
	P228_SHOOT1,
	P228_SHOOT2,
	P228_SHOOT3,
	P228_EMPTY,
	P228_RELOAD,
	P228_DRAW
};

const int P228_DEFAULT_GIVE		= 65;
const int P228_MAX_CARRY		= 52;
const int P228_MAX_CLIP			= 13;
const int P228_WEIGHT			= 5;

class weapon_p228 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int m_iShell;
	
	float m_flAccuracy;
	int m_iShotsFired;
	float m_flLastFire;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/p228/w_p228.mdl" );
		
		self.m_iDefaultAmmo = P228_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/p228/v_p228.mdl" );
		g_Game.PrecacheModel( "models/p228/w_p228.mdl" );
		g_Game.PrecacheModel( "models/p228/p_p228.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/357sig/w_357sig.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/357sig/w_357sigt.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p228-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p228_sliderelease.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p228_slidepull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p228_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/p228_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p228-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p228_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p228_slidepull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p228_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/p228_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud12.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud13.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_p228.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= P228_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= P228_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 8;
		info.iFlags 	= 0;
		info.iWeight 	= P228_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			NetworkMessage cs06( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs06.WriteLong( self.m_iId );
			cs06.End();
			
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dryfire_pistol.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flAccuracy = 0.9;
			
			bResult = self.DefaultDeploy( self.GetV_Model( "models/p228/v_p228.mdl" ), self.GetP_Model( "models/p228/p_p228.mdl" ), P228_DRAW, "onehanded" );
		
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void PrimaryAttack()
	{
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			P228Fire( 1.5 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			P228Fire( 0.255 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			P228Fire( 0.075 * ( 1 - m_flAccuracy ), 0.2, false );
		}
		else
		{
			P228Fire( 0.15 * ( 1 - m_flAccuracy ), 0.2, false );
		}
	}
	
	void P228Fire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		if ( m_iShotsFired > 1 )
		{
			return;
		}

		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy -= ( 0.325 - ( WeaponTimeBase() - m_flLastFire ) ) * 0.3;

			if ( m_flAccuracy > 0.9 )
			{
				m_flAccuracy = 0.9;
			}
			else if ( m_flAccuracy < 0.6 )
			{
				m_flAccuracy = 0.6;
			}
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, P228_DISTANCE, P228_PENETRATION, BULLET_PLAYER_357SIG, P228_DAMAGE, P228_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		if ( self.m_iClip <= 0 )
		{
			self.SendWeaponAnim( P228_EMPTY, 0, 0 );
		}
		else
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
			{
				case 0: self.SendWeaponAnim( P228_SHOOT1, 0, 0 ); break;
				case 1: self.SendWeaponAnim( P228_SHOOT2, 0, 0 ); break;
				case 2: self.SendWeaponAnim( P228_SHOOT3, 0, 0 ); break;
			}
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/p228-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		flCycleTime -= 0.05;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
		m_pPlayer.pev.punchangle.x -= 2;
		
		Vector vecShellVelocity, vecShellOrigin;
		
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 10, -6 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < P228_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( P228_MAX_CLIP, P228_RELOAD, 2.74, 0 ) )
		{
			m_flAccuracy = 0.9;
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			// Can't attack if the player is holding the button
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
			{
				m_iShotsFired = 0;
			}
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( P228_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class SIG357Box : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/357sig/w_357sig.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/357sig/w_357sig.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/357sig/w_357sigt.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = P228_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_357sig", P228_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetP228Name()
{
	return "weapon_p228";
}

void RegisterP228()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetP228Name(), GetP228Name() );
	g_ItemRegistry.RegisterWeapon( GetP228Name(), "cs_weapons", "ammo_357sig" );
}

string GetSIG357BoxName()
{
	return "ammo_357sig";
}

void RegisterSIG357Box()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "SIG357Box", GetSIG357BoxName() );
}