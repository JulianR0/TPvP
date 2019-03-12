/* 
* DeathMatch Classic: Super Nail Gun
*/

const int SNAILGUN_DEFAULT_AMMO = 30;
const int SNAILGUN_MAX_CARRY = 200;
const int SNAILGUN_MAX_CLIP = WEAPON_NOCLIP;
const int SNAILGUN_WEIGHT = 5;

enum snailgun_e
{
	SNAILGUN_IDLE = 0,
	SNAILGUN_ATTACK
};

class weapon_dmcsupernailgun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iNailOffset;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/g_nail2.mdl") );
		self.m_iDefaultAmmo = SNAILGUN_DEFAULT_AMMO;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_nail2.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_nail2.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_nail2T.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_nail2.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/rocket1i.wav" ); // spike gun
		g_SoundSystem.PrecacheSound( "weapons/dmc/spike2.wav" ); // super spike
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/rocket1i.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/spike2.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudsng.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudsngammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcsupernailgun.txt" );
		
		g_Game.PrecacheOther( "dmcnail" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= SNAILGUN_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= SNAILGUN_MAX_CLIP;
		info.iSlot			= 2;
		info.iPosition		= 7;
		info.iFlags 		= 0;
		info.iWeight		= SNAILGUN_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_nail2.mdl" ), self.GetP_Model( "models/dmc/p_nail2.mdl" ), SNAILGUN_IDLE, "mp5" );
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
		self.SendWeaponAnim( SNAILGUN_IDLE );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			// No ammo
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
			self.PlayEmptySound();
			return;
		}
		else if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 1 ) // Normal Nail
		{
			// Attack animation
			self.SendWeaponAnim( SNAILGUN_ATTACK );
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			
			// Gun volume
			m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
			
			// Play the sound
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/rocket1i.wav", 1.0, ATTN_NORM );
			
			// Decrease ammo by 1
			int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
			
			// Fire the nail
			Vector vecDir = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
			CQuakeNail@ pNail = CreateNail( self.pev.origin + Vector( 0, 0, 16 ) + ( g_Engine.v_forward * 8 ), vecDir, m_pPlayer );
		}
		else // Super Nail
		{
			// Attack animation
			self.SendWeaponAnim( SNAILGUN_ATTACK );
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			
			// Gun volume
			m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
			
			// Play the sound
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/spike2.wav", 1.0, ATTN_NORM );
			
			// Decrease ammo by 2
			int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, iAmmo - 2 );
			
			// Fire the nail
			Vector vecDir = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
			CQuakeNail@ pNail = CreateSuperNail( self.pev.origin + Vector( 0, 0, 16 ) + ( g_Engine.v_forward * 8 ), vecDir, m_pPlayer );
		}
		
		// Cooldown
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
	}
}

string GetDMCSuperNailgunName()
{
	return "weapon_dmcsupernailgun";
}

void RegisterDMCSuperNailgun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcsupernailgun", GetDMCSuperNailgunName() );
	g_ItemRegistry.RegisterWeapon( GetDMCSuperNailgunName(), "dmc_weapons", "dmcnails");
}
