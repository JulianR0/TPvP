/*  
* Rifle of Amen
*/

enum HQ2AR_Animation
{
	HQ2AR_LONGIDLE = 0,
	HQ2AR_IDLE1,
	HQ2AR_LAUNCH,
	HQ2AR_RELOAD,
	HQ2AR_DEPLOY,
	HQ2AR_FIRE1,
	HQ2AR_FIRE2,
	HQ2AR_FIRE3,
};

const int HQ2AR_DEFAULT_GIVE 	= 50;
const int HQ2AR_MAX_AMMO		= 250;
const int HQ2AR_MAX_AMMO2 	= 10;
const int HQ2AR_MAX_CLIP 		= 50;
const int HQ2AR_WEIGHT 		= 5;

class weapon_amenrifle : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	int m_iShell;
	int	m_iSecondaryAmmo;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_9mmAR.mdl" ); // use vanilla HLC models for everything but V_ model

		self.m_iDefaultAmmo = HQ2AR_DEFAULT_GIVE;

		self.m_iSecondaryAmmoType = 0;
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/hq2/v_rifle.mdl" );
		g_Game.PrecacheModel( "models/hl/w_9mmAR.mdl" );
		g_Game.PrecacheModel( "models/hl/p_9mmAR.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		
		g_Game.PrecacheModel( "models/grenade.mdl" );
		g_Game.PrecacheModel( "models/w_9mmARclip.mdl" );
		
		g_Game.PrecacheGeneric( "sound/weapons/hq2/rifle_hks1.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/hq2/rifle_hks2.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/hq2/rifle_hks3.wav" );
		g_Game.PrecacheGeneric( "sprites/hq2_weapons/weapon_amenrifle.txt" );

		g_SoundSystem.PrecacheSound( "weapons/hq2/rifle_hks1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/hq2/rifle_hks2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/hq2/rifle_hks3.wav" );
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/clipinsert1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/cliprelease1.wav" );
		g_SoundSystem.PrecacheSound( "hl/items/guncock1.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/glauncher.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/glauncher2.wav" );
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= HQ2AR_MAX_AMMO;
		info.iMaxAmmo2 	= HQ2AR_MAX_AMMO2;
		info.iMaxClip 	= HQ2AR_MAX_CLIP;
		info.iSlot 		= 2;
		info.iPosition 	= 4;
		info.iFlags 	= 0;
		info.iWeight 	= HQ2AR_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;

		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/hq2/v_rifle.mdl" ), self.GetP_Model( "models/hl/p_9mmAR.mdl" ), HQ2AR_DEPLOY, "mp5" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void PrimaryAttack()
	{
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0:
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/hq2/rifle_hks1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
				self.SendWeaponAnim( HQ2AR_FIRE1, 0, 0 );
				break;
			}
			case 1:
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/hq2/rifle_hks2.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
				self.SendWeaponAnim( HQ2AR_FIRE2, 0, 0 );
				break;
			}
			case 2:
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/hq2/rifle_hks3.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
				self.SendWeaponAnim( HQ2AR_FIRE3, 0, 0 );
				break;
			}
		}

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		// optimized multiplayer. Widened to make it easier to hit a moving player
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_MP5, 2 );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		m_pPlayer.pev.punchangle.x = Math.RandomLong( -2, 2 );

		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.1;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
						+ x * VECTOR_CONE_6DEGREES.x * g_Engine.v_right 
						+ y * VECTOR_CONE_6DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
	}
	
	// Since we currenly use this weapon on a map that does not have 9mmAR grenades (fun_hq2_phoenix)
	// and this weapon isn't installed outside of said map, I disabled the secondary attack.
	// Re-enable if needed. -Giegue
	void DISABLED_SecondaryAttack()
	{
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}
		
		if( m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 )
		{
			self.PlayEmptySound();
			return;
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		m_pPlayer.m_iExtraSoundTypes = bits_SOUND_DANGER;
		m_pPlayer.m_flStopExtraSoundTime = WeaponTimeBase() + 0.2;

		m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) - 1 );

		m_pPlayer.pev.punchangle.x = -10.0;

		self.SendWeaponAnim( HQ2AR_LAUNCH );

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		if ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) != 0 )
		{
			// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/glauncher.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		else
		{
			// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/glauncher2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
	
		Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );

		// we don't add in player velocity anymore.
		if( ( m_pPlayer.pev.button & IN_DUCK ) != 0 )
		{
			g_EntityFuncs.ShootContact( m_pPlayer.pev, 
								m_pPlayer.pev.origin + g_Engine.v_forward * 16 + g_Engine.v_right * 6, 
								g_Engine.v_forward * 900 ); //800
		}
		else
		{
			g_EntityFuncs.ShootContact( m_pPlayer.pev, 
								m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs * 0.5 + g_Engine.v_forward * 16 + g_Engine.v_right * 6, 
								g_Engine.v_forward * 900 ); //800
		}
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 1;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 1;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 5;// idle pretty soon after shooting.

		if( m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 )
			// HEV suit - indicate out of ammo condition
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
	}

	void Reload()
	{
		self.DefaultReload( HQ2AR_MAX_CLIP, HQ2AR_RELOAD, 1.5, 0 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
		case 0:	
			iAnim = HQ2AR_LONGIDLE;	
			break;
		
		case 1:
			iAnim = HQ2AR_IDLE1;
			break;
			
		default:
			iAnim = HQ2AR_IDLE1;
			break;
		}

		self.SendWeaponAnim( iAnim );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );// how long till we do this again.
	}
}

string GetRifleName()
{
	return "weapon_amenrifle";
}

void RegisterRifle()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_amenrifle", GetRifleName() );
	g_ItemRegistry.RegisterWeapon( GetRifleName(), "hq2_weapons", "9mm", "ARgrenades" );
}
