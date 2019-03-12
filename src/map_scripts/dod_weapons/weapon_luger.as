enum LUGERAnimation_e
{
	LUGER_IDLE1 = 0,
	LUGER_IDLE2,
	LUGER_IDLE3,
	LUGER_SHOOT1,
	LUGER_SHOOT2,
	LUGER_SHOOT_EMPTY,
	LUGER_RELOAD_EMPTY,
	LUGER_RELOAD,
	LUGER_DRAW,
	LUGER_EMPTY_IDLE
};

const int LUGER_MAX_CARRY			= 250;
const int LUGER_DEFAULT_GIVE		= 36;
const int LUGER_MAX_CLIP			= 8;
const int LUGER_WEIGHT				= 25;

class weapon_luger : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iShell;
	
	int m_iShotsFired;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/luger/w_lugerp08.mdl" );
		
		self.m_iDefaultAmmo = LUGER_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/luger/w_lugerp08.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/luger/v_lugerp08.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/luger/p_lugerp08.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_small.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/luger_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/luger_clipout1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/luger_clipout2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/luger_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/luger_slideback.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/luger_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/luger_clipout1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/luger_clipout2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/luger_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/luger_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_luger.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_luger.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= LUGER_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= LUGER_MAX_CLIP;
		info.iSlot		= 0;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= LUGER_WEIGHT;
		
		return true;
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
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage axis2( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis2.WriteLong( self.m_iId );
			axis2.End();
			
			@m_pPlayer = pPlayer;
			
			return true;
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/luger/v_lugerp08.mdl" ), self.GetP_Model( "models/ww2projekt/luger/p_lugerp08.mdl" ), LUGER_DRAW, "onehanded" );
			
			float deployTime = 1.03f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void PrimaryAttack()
	{
		m_iShotsFired++;
		
		if ( m_iShotsFired > 1 )
		{
			return;
		}
		
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
		
		float flDelay = 0.223;
		flDelay -= 0.05;
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + flDelay;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( self.m_iClip == 0 )
		{
			self.SendWeaponAnim( LUGER_SHOOT_EMPTY, 0, 0 );
		}
		else if( self.m_iClip > 0 )
		{
			switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
			{
				case 0: self.SendWeaponAnim( LUGER_SHOOT1, 0, 0 ); break;
				case 1: self.SendWeaponAnim( LUGER_SHOOT2, 0, 0 ); break;
			}
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/luger_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 16;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		else
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -1.9, -1.1 );
		m_pPlayer.pev.angles.x = m_pPlayer.pev.v_angle.x;
		m_pPlayer.pev.angles.x -= Math.RandomFloat( 1.9, 1.1 );
		m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;

		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			vecDir = vecAiming + x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_4DEGREES.y * g_Engine.v_up;
		else
			vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		//Produces a tracer at the start of the attachment
		WW2DynamicTracer( vecAttachOrigin, tr.vecEndPos );
		
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
		
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 16, 5, -10 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < LUGER_MAX_CLIP )
			BaseClass.Reload();
		
		if( self.m_iClip == 0 )
			self.DefaultReload( LUGER_MAX_CLIP, LUGER_RELOAD, 2.525, 0 );
		else
			self.DefaultReload( LUGER_MAX_CLIP, LUGER_RELOAD_EMPTY, 2.525, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			// Can't attack if the player is holding the button
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
			{
				m_iShotsFired = 0;
			}
		}
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if( self.m_iClip <= 0 )
			self.SendWeaponAnim( LUGER_EMPTY_IDLE );
		else
			self.SendWeaponAnim( LUGER_IDLE1 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetLUGERName()
{
	return "weapon_luger";
}

void RegisterLUGER()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetLUGERName(), GetLUGERName() );
	g_ItemRegistry.RegisterWeapon( GetLUGERName(), "ww2projekt", "9mm" );
}