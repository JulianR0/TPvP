/* 
* DeathMatch Classic: Lightning Gun
*/

const int LIGHTGUN_DEFAULT_AMMO = 15;
const int LIGHTGUN_MAX_CARRY = 100;
const int LIGHTGUN_MAX_CLIP = WEAPON_NOCLIP;
const int LIGHTGUN_WEIGHT = 8;

enum lightgun_e
{
	LIGHTGUN_IDLE = 0,
	LIGHTGUN_ATTACK
};

class weapon_dmclightninggun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flLightningTime;
	bool playsound;
	bool m_afButtonPressed;
	CBeam@ m_pBeam;
	bool bThinkRunning;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/g_light.mdl") );
		self.m_iDefaultAmmo = LIGHTGUN_DEFAULT_AMMO;
		
		//SetThink( ThinkFunction( CheckSound ) );
		//self.pev.nextthink = g_Engine.time + 0.1;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_light.mdl" );
		g_Game.PrecacheModel( "models/dmc/g_light.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_light.mdl" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/laserbeam.spr" ); // lightning effect
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/lstart.wav" ); // lightning start
		g_SoundSystem.PrecacheSound( "weapons/dmc/lhit.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/lstart.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/lhit.wav" );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudlg.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudlgammo.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmclightninggun.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= LIGHTGUN_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= LIGHTGUN_MAX_CLIP;
		info.iSlot			= 5;
		info.iPosition		= 5;
		info.iFlags 		= 0;
		info.iWeight		= LIGHTGUN_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_light.mdl" ), self.GetP_Model( "models/dmc/p_light.mdl" ), LIGHTGUN_IDLE, "gauss" );
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
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.1;
		
		DestroyEffect();
		playsound = false;
		m_afButtonPressed = false;
		m_flLightningTime = 0.0;
		bThinkRunning = false;
		
		self.SendWeaponAnim( LIGHTGUN_IDLE );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			// No ammo
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
			self.PlayEmptySound();
			
			DestroyEffect();
			playsound = false;
			m_afButtonPressed = false;
			m_flLightningTime = 0.0;
			return;
		}
		
		// Gun volume
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		
		// Make lightning sound every 0.6 seconds
		if ( m_flLightningTime <= WeaponTimeBase() )
		{
			playsound = true;
			m_flLightningTime = WeaponTimeBase() + 0.6;
		}
		
		// Play the lightning start sound if gun just started firing
		if ( !m_afButtonPressed )
		{
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_AUTO, "weapons/dmc/lstart.wav", 1.0, ATTN_NORM );
			m_afButtonPressed = true;
		}
		
		// explode if under water
		if ( m_pPlayer.pev.waterlevel == 3 )
		{
			float flCellsBurnt = float( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, 0 );
			
			Q_RadiusDamage( self, m_pPlayer, 35 * flCellsBurnt, null );
			
			return;
		}
		
		// Decrease ammo by 1
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		
		// Attack animation
		self.SendWeaponAnim( LIGHTGUN_ATTACK );
		
		// Get position for LightningDamage()
		// (I have to ask myself, why duplicate this same code on ItemPostFrame? Ah yes, I'm a terrible coder. -Giegue)
		TraceResult trace;
		Vector vecOrg = self.pev.origin + Vector( 0, 0, 16 );
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		g_Utility.TraceLine( vecOrg, vecOrg + ( g_Engine.v_forward * 600 ), ignore_monsters, self.edict(), trace );
		
		// Do damage
		Vector vecDir = g_Engine.v_forward + ( 0.001 * g_Engine.v_right ) + ( 0.001 * g_Engine.v_up );
		LightningDamage( self.pev.origin, trace.vecEndPos + ( g_Engine.v_forward * 4 ), m_pPlayer, 30, vecDir );
		
		// Punch angle
		m_pPlayer.pev.punchangle.x = Math.RandomFloat( 1.0, 2.0 );
		//m_pPlayer.pev.punchangle.y = Math.RandomFloat( 1.0, 2.0 );
		
		// Cooldown
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
	}
	
	// Bolt effect
	void ItemPostFrame()
	{
		// Only update while firing
		if ( m_afButtonPressed )
		{
			// Get position for bolt effect
			TraceResult trace;
			Vector vecOrg = self.pev.origin + Vector( 0, 0, 16 );
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
			g_Utility.TraceLine( vecOrg, vecOrg + ( g_Engine.v_forward * 600 ), ignore_monsters, self.edict(), trace );
			
			// Now, do the effect
			UpdateEffect( vecOrg, trace.vecEndPos );
		}
		
		BaseClass.ItemPostFrame();
	}
	
	void UpdateEffect( const Vector& in startPoint, const Vector& in endPoint )
	{
		if ( m_pBeam is null )
		{
			CreateEffect();
		}
		
		m_pBeam.SetStartPos( endPoint );
		m_pBeam.SetBrightness( 250 );
		m_pBeam.SetWidth( 30 );
	}

	void CreateEffect()
	{
		DestroyEffect();
		
		@m_pBeam = @g_EntityFuncs.CreateBeam( "sprites/dmc_weapons/laserbeam.spr", 30 );
		m_pBeam.PointEntInit( self.pev.origin, m_pPlayer.entindex() );
		m_pBeam.SetEndAttachment( 1 );
		m_pBeam.SetScrollRate( 30 );
		m_pBeam.SetNoise( 15 );
		m_pBeam.pev.spawnflags |= SF_BEAM_TEMPORARY; // Flag these to be destroyed on save/restore or level transition
		//m_pBeam.pev.flags |= FL_SKIPLOCALHOST;
		@m_pBeam.pev.owner = @m_pPlayer.edict();
	}
	
	void DestroyEffect()
	{
		if ( m_pBeam !is null )
		{
			g_EntityFuncs.Remove( m_pBeam );
			@m_pBeam = @null;
		}
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
		
		DestroyEffect();
		playsound = false;
		m_afButtonPressed = false;
		m_flLightningTime = 0.0;
		
		SetThink( ThinkFunction( CheckSound ) );
		if ( !bThinkRunning )
		{
			self.pev.nextthink = g_Engine.time + 0.1;
			bThinkRunning = true;
		}
	}
	
	void CheckSound()
	{
		if ( playsound )
		{
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_AUTO, "weapons/dmc/lhit.wav", 1.0, ATTN_NORM );
			playsound = false;
		}
		
		self.pev.nextthink = g_Engine.time + 0.1;
	}
}

string GetDMCLightninggunName()
{
	return "weapon_dmclightninggun";
}

void RegisterDMCLightninggun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmclightninggun", GetDMCLightninggunName() );
	g_ItemRegistry.RegisterWeapon( GetDMCLightninggunName(), "dmc_weapons", "dmccells");
}
