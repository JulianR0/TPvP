/* 
* DeathMatch Classic: Nail Gun
*/

const int NAILGUN_DEFAULT_AMMO = 30;
const int NAILGUN_MAX_CARRY = 200;
const int NAILGUN_MAX_CLIP = WEAPON_NOCLIP;
const int NAILGUN_WEIGHT = 4;

enum nailgun_e
{
	NAILGUN_IDLE = 0,
	NAILGUN_ATTACK
};

class weapon_dmcnailgun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iNailOffset;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/g_nail.mdl") );
		self.m_iDefaultAmmo = NAILGUN_DEFAULT_AMMO;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_nail.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_nail.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_nail.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/rocket1i.wav" ); // spike gun
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/rocket1i.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudng.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudngammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcnailgun.txt" );
		
		g_Game.PrecacheOther( "dmcnail" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= NAILGUN_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= NAILGUN_MAX_CLIP;
		info.iSlot			= 2;
		info.iPosition		= 6;
		info.iFlags 		= 0;
		info.iWeight		= NAILGUN_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_nail.mdl" ), self.GetP_Model( "models/dmc/p_nail.mdl" ), NAILGUN_IDLE, "mp5" );
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
		self.SendWeaponAnim( NAILGUN_IDLE );
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
		
		// Attack animation
		self.SendWeaponAnim( NAILGUN_ATTACK );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		// Gun volume
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		
		// Play the sound
		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/rocket1i.wav", 1.0, ATTN_NORM );
		
		// Decrease ammo by 1
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		
		// Fire left then right
		if ( m_iNailOffset == 2 )
			m_iNailOffset = -2;
		else
			m_iNailOffset = 2;
		
		// Fire the nail
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecDir = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		CQuakeNail@ pNail = CreateNail( self.pev.origin + Vector( 0, 0, 10 ) + ( g_Engine.v_right * m_iNailOffset ), vecDir, m_pPlayer );
		
		// Cooldown
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
	}
}

string GetDMCNailgunName()
{
	return "weapon_dmcnailgun";
}

void RegisterDMCNailgun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcnailgun", GetDMCNailgunName() );
	g_ItemRegistry.RegisterWeapon( GetDMCNailgunName(), "dmc_weapons", "dmcnails");
}
