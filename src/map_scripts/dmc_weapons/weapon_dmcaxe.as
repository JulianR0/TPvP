/* 
* DeathMatch Classic: Axe
*/

const int AXE_MAX_CLIP = WEAPON_NOCLIP;
const int AXE_WEIGHT = 1;

enum axe_e
{
	AXE_IDLE = 0,
	AXE_ATTACK
};

class weapon_dmcaxe : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	float m_flAxeFire;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/dmc/p_crowbar.mdl") );
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/v_crowbar.mdl" );
		g_Game.PrecacheModel( "models/dmc/p_crowbar.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/ax1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/dmc/axhit2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/dmc/axhitbod.wav" );
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/ax1.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/axhit2.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/dmc/axhitbod.wav" );
		
		g_Game.PrecacheModel( "sprites/dmc_weapons/320hud2.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/crosshairs.spr" );
		g_Game.PrecacheModel( "sprites/dmc_weapons/hudcb.spr" );
		
		g_Game.PrecacheGeneric( "sprites/dmc_weapons/weapon_dmcaxe.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= -1;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= AXE_MAX_CLIP;
		info.iSlot			= 0;
		info.iPosition		= 5;
		info.iFlags 		= 0;
		info.iWeight		= AXE_WEIGHT;
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
		return self.DefaultDeploy( self.GetV_Model( "models/dmc/v_crowbar.mdl" ), self.GetP_Model( "models/dmc/p_crowbar.mdl" ), AXE_IDLE, "crowbar" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false;
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		m_pPlayer.pev.viewmodel = "";
		m_flAxeFire = 0;
	}
	
	void PrimaryAttack()
	{
		// Delay attack for 0.15
		m_flAxeFire = WeaponTimeBase() + 0.15;
		
		// Attack animation
		self.SendWeaponAnim( AXE_ATTACK );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
		
		// Swing Sound
		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "weapons/dmc/ax1.wav", 1.0, ATTN_NORM );
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
	}
	
	// Actual attack function
	void W_FireAxe()
	{
		TraceResult trace;
		Vector vecSrc = m_pPlayer.GetGunPosition();
		
		// Swing forward 64 units
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		g_Utility.TraceLine( vecSrc, vecSrc + ( g_Engine.v_forward * 64 ), dont_ignore_monsters, m_pPlayer.edict(), trace );
		
		if ( trace.flFraction == 1.0 )
			return;
		
		Vector vecOrg = trace.vecEndPos - g_Engine.v_forward * 4;
		
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( trace.pHit );
		if ( pEntity !is null && pEntity.pev.takedamage > 0 )
		{
			pEntity.TakeDamage( self.pev, m_pPlayer.pev, 38, DMG_GENERIC );
			
			if ( pEntity.IsPlayer() )
				g_WeaponFuncs.SpawnBlood( vecOrg, BLOOD_COLOR_RED, 38 * 4 ); // Make a lot of Blood!
			
			// Hit Sound
			g_SoundSystem.EmitSound( pEntity.edict(), CHAN_BODY, "weapons/dmc/axhitbod.wav", 1.0, ATTN_NORM );
		}
		else
		{
			// Miss Sound
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/dmc/axhit2.wav", 1.0, ATTN_NORM );
			
			// Decal
			g_WeaponFuncs.DecalGunshot( trace, BULLET_PLAYER_CROWBAR );
		}
	}
	
	void ItemPostFrame()
	{
		if ( m_flAxeFire > 0 && m_flAxeFire <= g_Engine.time )
		{
			m_flAxeFire = 0;
			W_FireAxe();
		}
		
		BaseClass.ItemPostFrame();
	}
}

string GetDMCAxeName()
{
	return "weapon_dmcaxe";
}

void RegisterDMCAxe()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_dmcaxe", GetDMCAxeName() );
	g_ItemRegistry.RegisterWeapon( GetDMCAxeName(), "dmc_weapons" );
}
