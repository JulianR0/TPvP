enum DeagleAnimation
{
	DEAGLE_IDLE = 0,
	DEAGLE_SHOOT1,
	DEAGLE_SHOOT2,
	DEAGLE_EMPTY,
	DEAGLE_RELOAD,
	DEAGLE_DRAW
};

const int DEAGLE_DEFAULT_GIVE	= 42;
const int DEAGLE_MAX_CARRY		= 35;
const int DEAGLE_MAX_CLIP		= 7;
const int DEAGLE_WEIGHT			= 7;

class weapon_csdeagle : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/csdeagle/w_deagle.mdl" );
		
		self.m_iDefaultAmmo = DEAGLE_DEFAULT_GIVE;
		m_flAccuracy = 0.9;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/csdeagle/v_deagle.mdl" );
		g_Game.PrecacheModel( "models/csdeagle/w_deagle.mdl" );
		g_Game.PrecacheModel( "models/csdeagle/p_deagle.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/50ae/w_50ae.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/50ae/w_50aet.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/deagle-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/deagle-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/de_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/de_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/de_deploy.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/deagle-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/deagle-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/de_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/de_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/de_deploy.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud10.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud11.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_csdeagle.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= DEAGLE_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= DEAGLE_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 10;
		info.iFlags 	= 0;
		info.iWeight 	= DEAGLE_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			NetworkMessage cs01( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cs01.WriteLong( self.m_iId );
			cs01.End();
			
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
			
			bResult = self.DefaultDeploy( self.GetV_Model( "models/csdeagle/v_deagle.mdl" ), self.GetP_Model( "models/csdeagle/p_deagle.mdl" ), DEAGLE_DRAW, "onehanded" );
			
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
			DEAGLEFire( 1.5 * ( 1 - m_flAccuracy ), 0.3, false );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			DEAGLEFire( 0.25 * ( 1 - m_flAccuracy ), 0.3, false );
		}
		else if ( ( m_pPlayer.pev.flags & FL_DUCKING ) != 0 )
		{
			DEAGLEFire( 0.115 * ( 1 - m_flAccuracy ), 0.3, false );
		}
		else
		{
			DEAGLEFire( 0.13 * ( 1 - m_flAccuracy ), 0.3, false );
		}
	}
	
	void DEAGLEFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		m_iShotsFired++;
		
		if ( m_iShotsFired > 1 )
		{
			return;
		}
		
		if ( m_flLastFire > 0.0 )
		{
			m_flAccuracy -= ( 0.4 - ( WeaponTimeBase() - m_flLastFire ) ) * 0.35;
			
			if ( m_flAccuracy > 0.9 )
			{
				m_flAccuracy = 0.9;
			}
			else if ( m_flAccuracy < 0.55 )
			{
				m_flAccuracy = 0.55;
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
		
		Vector vecDir = FireBullets3( m_pPlayer, g_Engine.v_forward, flSpread, DEAGLE_DISTANCE, DEAGLE_PENETRATION, BULLET_PLAYER_50AE, DEAGLE_DAMAGE, DEAGLE_RANGE_MODIFER );
		
		m_pPlayer.m_iWeaponVolume = BIG_EXPLOSION_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		
		if ( self.m_iClip <= 0 )
		{
			self.SendWeaponAnim( DEAGLE_EMPTY, 0, 0 );
		}
		else
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
			{
				case 0: self.SendWeaponAnim( DEAGLE_SHOOT1, 0, 0 ); break;
				case 1: self.SendWeaponAnim( DEAGLE_SHOOT2, 0, 0 ); break;
			}
		}
		
		switch ( Math.RandomLong (0, 1) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/deagle-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/deagle-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		
		flCycleTime -= 0.075;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flCycleTime;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.8;
		
		m_pPlayer.pev.punchangle.x -= 2;
		
		Vector vecShellVelocity, vecShellOrigin;
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 10, -6 );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < DEAGLE_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.DefaultReload( DEAGLE_MAX_CLIP, DEAGLE_RELOAD, 2.2, 0 ) )
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
		
		self.SendWeaponAnim( DEAGLE_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

class DeagleAmmoBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16ammo/50ae/w_50ae.mdl" );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16ammo/50ae/w_50ae.mdl" );
		g_Game.PrecacheModel( "models/cs16ammo/50ae/w_50aet.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pither )
	{
		int iGive;
		
		iGive = DEAGLE_DEFAULT_GIVE;
		
		if( pither.GiveAmmo( iGive, "ammo_50ae", DEAGLE_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetCSDeagleName()
{
	return "weapon_csdeagle";
}

void RegisterCSDeagle()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetCSDeagleName(), GetCSDeagleName() );
	g_ItemRegistry.RegisterWeapon( GetCSDeagleName(), "cs_weapons", "ammo_50ae" );
}

string GetDeagleAmmoBoxName()
{
	return "ammo_50ae";
}

void RegisterDeagleAmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "DeagleAmmoBox", GetDeagleAmmoBoxName() );
}