const int HEGRENADE_DEFAULT_GIVE	= 5;
const int HEGRENADE_WEIGHT			= 5;
const int HEGRENADE_MAX_CARRY		= 1;

enum HEGRENADEAnimation 
{
	HEGRENADE_IDLE = 0,
	HEGRENADE_PULLPIN,
	HEGRENADE_THROW,
	HEGRENADE_DEPLOY
};

class weapon_hegrenade : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flStartThrow;
	float m_flReleaseThrow;
	CBaseEntity@ pGrenade;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16grenades/hegrenade/w_hegrenade.mdl" );
		self.pev.dmg = 4;
		self.m_iDefaultAmmo = HEGRENADE_DEFAULT_GIVE;
		m_flReleaseThrow = -1;
		m_flStartThrow = 0;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16grenades/hegrenade/w_hegrenade.mdl" );
		g_Game.PrecacheModel( "models/cs16grenades/hegrenade/v_hegrenade.mdl" );
		g_Game.PrecacheModel( "models/cs16grenades/hegrenade/p_hegrenade.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/pinpull.wav" );

		g_SoundSystem.PrecacheSound( "weapons/pinpull.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud3.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/640hud6.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs_weapons/weapon_hegrenade.txt" );
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

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= HEGRENADE_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 4;
		info.iPosition = 6;
		info.iWeight = HEGRENADE_WEIGHT;
		info.iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;

		return true;
	}

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	bool Deploy()
	{
		bool bResult;
		{
			m_flStartThrow = 0;
			m_flReleaseThrow = -1;
			
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16grenades/hegrenade/v_hegrenade.mdl" ), self.GetP_Model( "models/cs16grenades/hegrenade/p_hegrenade.mdl" ), HEGRENADE_DEPLOY, "crowbar" );

			float deployTime = 0.7;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skiplocal )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		
		m_flStartThrow = 0;
		m_flReleaseThrow = -1;
	}
	
	void InactiveItemPostFrame()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			self.DestroyItem();
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}
	
	void PrimaryAttack()
	{
		if( m_flStartThrow == 0 && m_pPlayer.m_rgAmmo ( self.m_iPrimaryAmmoType ) > 0 )
		{
			m_flReleaseThrow = 0;
			m_flStartThrow = g_Engine.time;
		
			self.SendWeaponAnim( HEGRENADE_PULLPIN );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.5;
		}
	}

	void WeaponIdle()
	{
		if ( m_flReleaseThrow == 0 && m_flStartThrow > 0.0 )
			m_flReleaseThrow = g_Engine.time;

		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if ( m_flStartThrow > 0.0 )
		{
			Vector angThrow = m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle;

			if ( angThrow.x < 0 )
				angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 );
			else
				angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 );
			
			float flVel = ( 90 - angThrow.x ) * 6;
			
			if ( flVel > 750 )
				flVel = 750;
			
			g_EngineFuncs.MakeVectors( angThrow );
			
			Vector vecSrc = m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs + g_Engine.v_forward * 16;
			Vector vecThrow = g_Engine.v_forward * flVel + m_pPlayer.pev.velocity;
			
			@pGrenade = g_EntityFuncs.ShootTimed( m_pPlayer.pev, vecSrc, vecThrow, 9.9 );
			g_EntityFuncs.SetModel( pGrenade, "models/cs16grenades/hegrenade/w_hegrenade.mdl" );
			
			// Meh. Hacky way.
			g_Scheduler.SetTimeout( "HE_Explode", 1.5, pGrenade.entindex() );
			
			self.SendWeaponAnim ( HEGRENADE_THROW );
			
			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_flStartThrow = 0;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.75;

			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
			
			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			{
				// just threw last grenade
				// set attack times in the future, and weapon idle in the future so we can see the whole throw
				// animation, weapon idle will automatically retire the weapon for us.
				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.75;
			}
			return;
		}
		else if( m_flReleaseThrow > 0 )
		{
			m_flStartThrow = 0;

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
			{
				self.SendWeaponAnim( HEGRENADE_DEPLOY );
				
				m_flReleaseThrow = -1;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
			}
			else
			{
				self.RetireWeapon();
			}
		}
		else if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			self.SendWeaponAnim( HEGRENADE_IDLE );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		}
	}

	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) != 0;
	}
}

class HEGrenadeAmmo : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16grenades/hegrenade/w_hegrenade.mdl" );
		BaseClass.Spawn();
	}

	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16grenades/hegrenade/w_hegrenade.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		int iGive;

		iGive = HEGRENADE_DEFAULT_GIVE;

		if( pOther.GiveAmmo( iGive, "weapon_hegrenade", HEGRENADE_MAX_CARRY ) != -1 )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

// When you just want things to work without creating separate custom entity for the same thing over and over again
void HE_Explode( const int& in iEntityIndex )
{
	CBaseEntity@ pGrenade = g_EntityFuncs.Instance( iEntityIndex );
	if ( pGrenade !is null )
	{
		g_EntityFuncs.CreateExplosion( pGrenade.pev.origin, pGrenade.pev.angles, pGrenade.pev.owner, int( pGrenade.pev.dmg ), false );
		g_WeaponFuncs.RadiusDamage( pGrenade.pev.origin, pGrenade.pev, pGrenade.pev.owner.vars, pGrenade.pev.dmg, ( pGrenade.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );
		g_EntityFuncs.Remove( pGrenade );
	}
}

string GetHEGRENADEName()
{
	return "weapon_hegrenade";
}

void RegisterHEGRENADE()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetHEGRENADEName(), GetHEGRENADEName() );
	g_ItemRegistry.RegisterWeapon( GetHEGRENADEName(), "cs_weapons", "weapon_hegrenade" );
}

string GetHEGrenadeAmmoName()
{
	return "weapon_hegrenade";
}

void RegisterHEGrenadeAmmo()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HEGrenadeAmmo", GetHEGrenadeAmmoName() );
}