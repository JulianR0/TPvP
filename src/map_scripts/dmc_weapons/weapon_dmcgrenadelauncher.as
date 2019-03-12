/* 
* DeathMatch Classic: Grenade Launcher
*/

const int GLAUNCHER_DEFAULT_AMMO = 5;
const int GLAUNCHER_MAX_CARRY = 100;
const int GLAUNCHER_MAX_CLIP = WEAPON_NOCLIP;
const int GLAUNCHER_WEIGHT = 6;

enum glauncher_e
{
	GLAUNCHER_IDLE = 0,
	GLAUNCHER_ATTACK
};

class weapon_dmcgrenadelauncher : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/g_rock.mdl") );
		self.m_iDefaultAmmo = GLAUNCHER_DEFAULT_AMMO;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_rock.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_rock.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_rockT.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_rock.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/grenade.wav" ); // grenade launcher
		g_SoundSystem.PrecacheSound( "weapons/dmc/bounce.wav" ); // grenade bounce
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/grenade.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/bounce.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudgl.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudglammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcgrenadelauncher.txt" );
		
		g_Game.PrecacheOther( "dmcrocket" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= GLAUNCHER_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= GLAUNCHER_MAX_CLIP;
		info.iSlot			= 3;
		info.iPosition		= 5;
		info.iFlags 		= 0;
		info.iWeight		= GLAUNCHER_WEIGHT;
		return true;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
		
		@m_pPlayer = pPlayer;
		
		return true;
	}
	
	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_rock.mdl" ), self.GetP_Model( "models/dmc/p_rock.mdl" ), GLAUNCHER_IDLE, "gauss" );
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
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		self.SendWeaponAnim( GLAUNCHER_IDLE );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			// No ammo
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.6;
			self.PlayEmptySound();
			return;
		}
		
		// Attack animation
		self.SendWeaponAnim( GLAUNCHER_ATTACK );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		// Gun volume
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		
		// Play the sound
		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/grenade.wav", 1.0, ATTN_NORM );
		
		// Decrease ammo by 1
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		
		// Get initial velocity
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecVelocity;
		if ( m_pPlayer.pev.v_angle.x != 0 )
		{
			vecVelocity = g_Engine.v_forward * 600 + g_Engine.v_up * 200 + Math.RandomFloat( -1, 1 ) * g_Engine.v_right * 10 + Math.RandomFloat( -1, 1 ) * g_Engine.v_up * 10;
		}
		else
		{
			vecVelocity = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
			vecVelocity = vecVelocity * 600;
			vecVelocity.z = 200;
		}
		
		// Create the grenade
		CQuakeRocket@ pRocket = CreateGrenade( self.pev.origin, vecVelocity, m_pPlayer );
		
		// Cooldown
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.6;
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
	}
}

string GetDMCGrenadeLauncherName()
{
	return "weapon_dmcgrenadelauncher";
}

void RegisterDMCGrenadeLauncher()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcgrenadelauncher", GetDMCGrenadeLauncherName() );
	g_ItemRegistry.RegisterWeapon( GetDMCGrenadeLauncherName(), "dmc_weapons", "dmcrockets");
}
