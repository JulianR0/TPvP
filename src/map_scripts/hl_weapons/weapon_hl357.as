/* 
* The original Half-Life version of the 357 revolver
*/

const int PYTHON_DEFAULT_GIVE = 6;
const int _357_MAX_CARRY = 36;
const int PYTHON_MAX_CLIP = 6;
const int PYTHON_WEIGHT = 15;

enum python_e
{
	PYTHON_IDLE1 = 0,
	PYTHON_FIDGET,
	PYTHON_FIRE1,
	PYTHON_RELOAD,
	PYTHON_HOLSTER,
	PYTHON_DRAW,
	PYTHON_IDLE2,
	PYTHON_IDLE3
};

class weapon_hl357 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_357.mdl" );
		
		self.m_iDefaultAmmo = PYTHON_DEFAULT_GIVE;

		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/v_357.mdl" );
		g_Game.PrecacheModel( "models/hl/w_357.mdl" );
		g_Game.PrecacheModel( "models/hl/p_357.mdl" );
		
		g_Game.PrecacheModel( "models/w_357ammobox.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/357_reload1.wav" );
		//g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_shot2.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hl357.txt" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= _357_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= PYTHON_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 6;
		info.iFlags 	= 0;
		info.iWeight 	= PYTHON_WEIGHT;
		
		return true;
	}
	
	bool Deploy()
	{
		self.pev.body = 1;
		return self.DefaultDeploy( self.GetV_Model( "models/hl/v_357.mdl" ), self.GetP_Model( "models/hl/p_357.mdl" ), PYTHON_DRAW, "python", 0, 1 );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false; // cancel any reload in progress.
		
		if ( self.m_fInZoom )
		{
			SecondaryAttack();
		}
		
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 1.0;
		self.m_flTimeWeaponIdle = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
		self.SendWeaponAnim( PYTHON_HOLSTER, self.UseDecrement() ? 1 : 0, 1 );
		
		BaseClass.Holster( skiplocal );
	}
	
	void SecondaryAttack()
	{
		if ( m_pPlayer.pev.fov != 0 )
		{
			self.m_fInZoom = false;
			m_pPlayer.pev.fov = m_pPlayer.m_iFOV = 0; // 0 means reset to default fov
		}
		else if ( m_pPlayer.pev.fov != 40 )
		{
			self.m_fInZoom = true;
			m_pPlayer.pev.fov = m_pPlayer.m_iFOV = 40;
		}
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
	}
	
	void PrimaryAttack()
	{
		// don't fire underwater
		if ( m_pPlayer.pev.waterlevel == 3 )
		{
			PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}
		
		if ( self.m_iClip <= 0 )
		{
			if ( !self.m_bFireOnEmpty )
				Reload();
			else
			{
				PlayEmptySound();
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			}
			
			return;
		}
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip--;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		
		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_357, 0 );
		m_pPlayer.pev.punchangle.x = -10.0;
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/357_shot2.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 95 + Math.RandomLong( 0, 0xF ) );
		self.SendWeaponAnim( PYTHON_FIRE1, self.UseDecrement() ? 1 : 0, 1 );
		
		// Decal
		TraceResult tr;
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecSpread = VECTOR_CONE_1DEGREES;
		Vector vecDir = vecAiming + x * vecSpread.x * g_Engine.v_right + y * vecSpread.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 4096;
		
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_357 );
			}
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.75;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}

	void Reload()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		if ( self.m_iClip == 6 )
			return;
		
		if ( m_pPlayer.pev.fov != 0 )
		{
			self.m_fInZoom = false;
			m_pPlayer.pev.fov = m_pPlayer.m_iFOV = 0; // 0 means reset to default fov
		}
		
		self.DefaultReload( 6, PYTHON_RELOAD, 2.0, 1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
		
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if ( flRand <= 0.5 )
		{
			iAnim = PYTHON_IDLE1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 70.0 / 30.0;
		}
		else if ( flRand <= 0.7 )
		{
			iAnim = PYTHON_IDLE2;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 60.0 / 30.0;
		}
		else if ( flRand <= 0.9 )
		{
			iAnim = PYTHON_IDLE3;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 88.0 / 30.0;
		}
		else
		{
			iAnim = PYTHON_FIDGET;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 170.0 / 30.0;
		}
		
		self.SendWeaponAnim( iAnim, self.UseDecrement() ? 1 : 0, 1 );
	}
}

string GetHL357Name()
{
	return "weapon_hl357";
}

void RegisterHL357()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hl357", GetHL357Name() );
	g_ItemRegistry.RegisterWeapon( GetHL357Name(), "hl_weapons", "357" );
}
