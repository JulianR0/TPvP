enum THOMPSONAnimation_e
{
	TOMMY_IDLE = 0,
	TOMMY_RELOAD,
	TOMMY_DRAW,
	TOMMY_SHOOT1,
	TOMMY_SHOOT2,
	TOMMY_IDLE_EMPTY
};

const int TOMMY_MAX_CARRY		= 250;
const int TOMMY_DEFAULT_GIVE	= 120;
const int TOMMY_MAX_CLIP		= 30;
const int TOMMY_WEIGHT			= 25;

class weapon_thompson : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/thompson/w_tommy.mdl" );
		
		self.m_iDefaultAmmo = TOMMY_DEFAULT_GIVE;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/thompson/w_tommy.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/thompson/v_tommy.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/thompson/p_tommy.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_small.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/thompson_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/thompson_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/thompson_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/thompson_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/thompson_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/thompson_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_thompson.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_thompson.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= TOMMY_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= TOMMY_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= TOMMY_WEIGHT;
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage allies4( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies4.WriteLong( self.m_iId );
			allies4.End();
			
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/thompson/v_tommy.mdl" ), self.GetP_Model( "models/ww2projekt/thompson/p_tommy.mdl" ), TOMMY_DRAW, "mp5" );
		
			float deployTime = 1.13f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.105;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( TOMMY_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( TOMMY_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/thompson_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 26;
		
		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x += Math.RandomFloat( -2.0, -1.6 );
		if ( m_pPlayer.pev.punchangle.x < -20 )
			m_pPlayer.pev.punchangle.x = -20;
		
		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
		{
			vecDir = vecAiming + x * VECTOR_CONE_9DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_9DEGREES.y * g_Engine.v_up;
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_9DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		}
		else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			vecDir = vecAiming + x * VECTOR_CONE_7DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_7DEGREES.y * g_Engine.v_up;
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_7DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		}
		else
		{
			vecDir = vecAiming + x * VECTOR_CONE_5DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_5DEGREES.y * g_Engine.v_up;
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_5DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		}

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
		
		Vector vecShellVelocity, vecShellOrigin;
		
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 22, 4, -7 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		//Produces a tracer at the start of the attachment at a rate of 2 bullets
		switch( ( self.m_iClip ) % 2 )
		{
			case 0: WW2DynamicTracer( vecAttachOrigin, tr.vecEndPos ); break;
		}
	}
	
	void Reload()
	{
		if( self.m_iClip < TOMMY_MAX_CLIP )
			BaseClass.Reload();

		self.DefaultReload( TOMMY_MAX_CLIP, TOMMY_RELOAD, 2.8, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if( self.m_iClip <= 0 )
			self.SendWeaponAnim( TOMMY_IDLE_EMPTY );
		else
			self.SendWeaponAnim( TOMMY_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetTHOMPSONName()
{
	return "weapon_thompson";
}

void RegisterTHOMPSON()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetTHOMPSONName(), GetTHOMPSONName() );
	g_ItemRegistry.RegisterWeapon( GetTHOMPSONName(), "ww2projekt", "9mm" );
}