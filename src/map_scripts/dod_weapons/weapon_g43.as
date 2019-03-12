enum GEWEHRAnimation_e
{
	G43_IDLE = 0,
	G43_SHOOT1,
	G43_SHOOT2,
	G43_RELOAD,
	G43_DRAW,
	G43_EMPTY_IDLE,
	G43_SMASH
};

const int G43_MAX_CARRY			= 36;
const int G43_DEFAULT_GIVE		= 20;
const int G43_MAX_CLIP			= 10;
const int G43_WEIGHT			= 25;

class weapon_g43 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iShell;
	
	int m_iShotsFired;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/g43/w_k43.mdl" );
		
		self.m_iDefaultAmmo = G43_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/g43/w_k43.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/g43/v_k43PHX.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/g43/p_k43.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_large.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/k43_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/gewehr_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/gewehr_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/tommy_reload_slap.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mp44_draw_slideback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bulletchain.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/k43_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/gewehr_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/gewehr_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/tommy_reload_slap.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mp44_draw_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bulletchain.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_g43.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_g43.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= G43_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= G43_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= G43_WEIGHT;
		
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
			NetworkMessage axis6( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis6.WriteLong( self.m_iId );
			axis6.End();
			
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/g43/v_k43PHX.mdl" ), self.GetP_Model( "models/ww2projekt/g43/p_k43.mdl" ), G43_DRAW, "sniper" );
			
			float deployTime = 0.69f;
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
		
		float flDelay = 0.276;
		flDelay -= 0.05;
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flDelay;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( G43_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( G43_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/k43_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 55;
		
		if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		else
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomLong( -5, -4 );
		m_pPlayer.pev.angles.x = m_pPlayer.pev.v_angle.x;
		m_pPlayer.pev.angles.x -= Math.RandomLong( 5, 4 );
		m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
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
		
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 16, 6, -10 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip < G43_MAX_CLIP )
			BaseClass.Reload();

		self.DefaultReload( G43_MAX_CLIP, G43_RELOAD, 4.08, 0 );
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
			self.SendWeaponAnim( G43_EMPTY_IDLE );
		else
			self.SendWeaponAnim( G43_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetG43Name()
{
	return "weapon_g43";
}

void RegisterG43()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetG43Name(), GetG43Name() );
	g_ItemRegistry.RegisterWeapon( GetG43Name(), "ww2projekt", "357" );
}