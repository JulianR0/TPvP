/* 
* DeathMatch Classic: Rocket Launcher
*/

const int RLAUNCHER_DEFAULT_AMMO = 5;
const int RLAUNCHER_MAX_CARRY = 100;
const int RLAUNCHER_MAX_CLIP = WEAPON_NOCLIP;
const int RLAUNCHER_WEIGHT = 7;

enum rlauncher_e
{
	RLAUNCHER_IDLE = 0,
	RLAUNCHER_ATTACK
};

class weapon_dmcrocketlauncher : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/g_rock2.mdl") );
		self.m_iDefaultAmmo = RLAUNCHER_DEFAULT_AMMO;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_rock2.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_rock2.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_rock2T.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_rock2.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/sgun1.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/sgun1.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudrl.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudrlammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcrocketlauncher.txt" );
		
		g_Game.PrecacheOther( "dmcrocket" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= RLAUNCHER_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= RLAUNCHER_MAX_CLIP;
		info.iSlot			= 4;
		info.iPosition		= 5;
		info.iFlags 		= 0;
		info.iWeight		= RLAUNCHER_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_rock2.mdl" ), self.GetP_Model( "models/dmc/p_rock2.mdl" ), RLAUNCHER_IDLE, "gauss" );
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
		self.SendWeaponAnim( RLAUNCHER_IDLE );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			// No ammo
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.8;
			self.PlayEmptySound();
			return;
		}
		
		// Attack animation
		self.SendWeaponAnim( RLAUNCHER_ATTACK );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		// Gun volume
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		
		// Play the sound
		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/sgun1.wav", 1.0, ATTN_NORM );
		
		// Decrease ammo by 1
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		
		// Create the rocket
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecOrg = self.pev.origin + ( g_Engine.v_forward * 8 ) + Vector( 0, 0, 16 );
		Vector vecDir = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		CQuakeRocket@ pRocket = CreateRocket( vecOrg, vecDir, m_pPlayer );
		
		// Cooldown
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.8;
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
	}
}

string GetDMCRocketLauncherName()
{
	return "weapon_dmcrocketlauncher";
}

void RegisterDMCRocketLauncher()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcrocketlauncher", GetDMCRocketLauncherName() );
	g_ItemRegistry.RegisterWeapon( GetDMCRocketLauncherName(), "dmc_weapons", "dmcrockets");
}
