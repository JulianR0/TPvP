/* 
* DeathMatch Classic: Super Shotgun
*/

const int SSHOTGUN_DEFAULT_AMMO = 5;
const int SSHOTGUN_MAX_CARRY = 100;
const int SSHOTGUN_MAX_CLIP = WEAPON_NOCLIP;
const int SSHOTGUN_WEIGHT = 3;

enum sshotgun_e
{
	SSHOTGUN_IDLE = 0,
	SSHOTGUN_ATTACK
};

class weapon_dmcsupershotgun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/g_shot2.mdl") );
		self.m_iDefaultAmmo = SSHOTGUN_DEFAULT_AMMO;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_shot2.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_shot2.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_shot2T.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_shot2.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/guncock.wav" ); // player shotgun
		g_SoundSystem.PrecacheSound( "weapons/dmc/shotgn2.wav" ); // super shotgun
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/guncock.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/shotgn2.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudssg.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudssgammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcsupershotgun.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= SSHOTGUN_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= SSHOTGUN_MAX_CLIP;
		info.iSlot			= 1;
		info.iPosition		= 7;
		info.iFlags 		= 0;
		info.iWeight		= SSHOTGUN_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_shot2.mdl" ), self.GetP_Model( "models/dmc/p_shot2.mdl" ), SSHOTGUN_IDLE, "shotgun" );
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
		self.SendWeaponAnim( SSHOTGUN_IDLE );
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
		else if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 1 ) // Single attack
		{	
			// Attack animation
			self.SendWeaponAnim( SSHOTGUN_ATTACK );
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
		else // Double attack
		{
			// Attack animation
			self.SendWeaponAnim( SSHOTGUN_ATTACK );
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			
			// Gun volume
			m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
			
			// Play the sound
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/shotgn2.wav", 1.0, ATTN_NORM );
			
			// Decrease ammo by 2
			int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, iAmmo - 2 );
			
			// Get aiming vector and fire
			Vector vecDir = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
			Q_FireBullets( self, m_pPlayer, 14, vecDir, Vector( 0.14, 0.08, 0 ) );
			
			// Cooldown
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.7;
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
	}
}

string GetDMCSuperShotgunName()
{
	return "weapon_dmcsupershotgun";
}

void RegisterDMCSuperShotgun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcsupershotgun", GetDMCSuperShotgunName() );
	g_ItemRegistry.RegisterWeapon( GetDMCSuperShotgunName(), "dmc_weapons", "dmcshells");
}
