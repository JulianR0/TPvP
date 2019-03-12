/* 
* DeathMatch Classic: Shotgun
*/

const int SHOTGUN_DEFAULT_AMMO = 25;
const int SHOTGUN_MAX_CARRY = 100;
const int SHOTGUN_MAX_CLIP = WEAPON_NOCLIP;
const int SHOTGUN_WEIGHT = 2;

enum shotgun_e
{
	SHOTGUN_IDLE = 0,
	SHOTGUN_ATTACK
};

class weapon_dmcshotgun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/p_shot.mdl") );
		self.m_iDefaultAmmo = SHOTGUN_DEFAULT_AMMO;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_shot.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_shot.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/guncock.wav" ); // player shotgun
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/guncock.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudsg.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudsgammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcshotgun.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= SHOTGUN_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= SHOTGUN_MAX_CLIP;
		info.iSlot			= 1;
		info.iPosition		= 6;
		info.iFlags 		= 0;
		info.iWeight		= SHOTGUN_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_shot.mdl" ), self.GetP_Model( "models/dmc/p_shot.mdl" ), SHOTGUN_IDLE, "shotgun" );
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
		self.SendWeaponAnim( SHOTGUN_IDLE );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			// No ammo
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			self.PlayEmptySound();
			return;
		}
		
		// Attack animation
		self.SendWeaponAnim( SHOTGUN_ATTACK );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		// Gun volume
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		
		// Play the sound
		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/guncock.wav", 1.0, ATTN_NORM );
		
		// Decrease ammo by 1
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		
		// Get aiming vector and fire
		Vector vecDir = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		Q_FireBullets( self, m_pPlayer, 6, vecDir, Vector( 0.04, 0.04, 0 ) );
		
		// Cooldown
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
	}
}

string GetDMCShotgunName()
{
	return "weapon_dmcshotgun";
}

void RegisterDMCShotgun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcshotgun", GetDMCShotgunName() );
	g_ItemRegistry.RegisterWeapon( GetDMCShotgunName(), "dmc_weapons", "dmcshells");
}
