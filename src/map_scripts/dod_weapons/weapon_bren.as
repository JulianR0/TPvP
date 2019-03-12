enum BRENAnimation_e
{
	BREN_UPIDLE = 0,
	BREN_UPRELOAD,
	BREN_DRAW,
	BREN_UPSHOOT,
	BREN_UPTODOWN,
	BREN_DOWNIDLE,
	BREN_DOWNRELOAD,
	BREN_DOWNSHOOT,
	BREN_DOWNTOUP
};

const int BREN_MAX_CARRY	= 600;
const int BREN_DEFAULT_GIVE	= 120;
const int BREN_MAX_CLIP		= 30;
const int BREN_WEIGHT		= 35;

class weapon_bren : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int g_iCurrentMode;
	int m_iShell;
	
	CBaseEntity@ pWall;
	Vector pForward;
	Vector pAngles;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/bren/w_bren.mdl" );
		
		self.m_iDefaultAmmo = BREN_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/bren/w_bren.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/bren/v_bren.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/bren/p_brenbu.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/bren/p_brenbd.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_medium.mdl" );
		g_Game.PrecacheModel( "models/egg.mdl" );
		
		//Precache for download
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bren_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bren_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bren_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgdeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgup.wav" );
		
		//Precache for the Engine
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bren_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bren_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bren_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgdeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgup.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_bren.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_bren.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= BREN_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= BREN_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= BREN_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage british5( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				british5.WriteLong( self.m_iId );
			british5.End();
			
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/bren/v_bren.mdl" ), self.GetP_Model( "models/ww2projekt/bren/p_brenbu.mdl" ), BREN_DRAW, "saw" );
			
			float deployTime = 1.06f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
			SecondaryAttack();
		
		g_iCurrentMode = 0;
		m_pPlayer.pev.maxspeed = 0;
		m_pPlayer.pev.fuser4 = 0;
		
		if ( pWall !is null )
		{
			g_EntityFuncs.Remove( pWall );
			@pWall = null;
		}
		
		BaseClass.Holster( skipLocal );
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.116;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( BREN_UPSHOOT, 0, 0 );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( BREN_DOWNSHOOT, 0, 0 );
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/bren_shoot.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 43;
		
		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
		
		Vector vecDir;
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			m_pPlayer.pev.punchangle.x -= 1.4;
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -1.0f, 1.0f );
			
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				vecDir = vecAiming + x * VECTOR_CONE_15DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_15DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_15DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else if ( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				vecDir = vecAiming + x * VECTOR_CONE_10DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_10DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_10DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else
			{
				vecDir = vecAiming + x * VECTOR_CONE_8DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_8DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_8DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = 1.1;
			
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				vecDir = vecAiming + x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_4DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else
			{
				vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
		}
		
		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
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
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 3, -6 );
		else if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 16, 4, -6 );
			
		vecShellVelocity.y *= 1;
		vecShellVelocity.z *= -1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void SecondaryAttack()
	{
		switch( g_iCurrentMode )
		{
			case BIPOD_UNDEPLOY:
			{
				if( m_pPlayer.pev.waterlevel == WATERLEVEL_DRY || m_pPlayer.pev.waterlevel == WATERLEVEL_FEET )
				{
					if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 ) //needs to be fully crouched and not jump-crouched
					{
						g_iCurrentMode = BIPOD_DEPLOY;
						
						self.SendWeaponAnim( BREN_UPTODOWN );
						
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						m_pPlayer.pev.weaponmodel = ( "models/ww2projekt/bren/p_brenbd.mdl" );
						self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.7f;
						
						// Set up a small, invisible wall to keep player crouched
						Vector pOrigin;
						g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
						pForward = g_Engine.v_forward;
						
						pAngles = m_pPlayer.pev.v_angle;
						
						pOrigin = m_pPlayer.pev.origin - pForward * 8.0;
						pOrigin.z += 24.0;
						
						@pWall = g_EntityFuncs.Create( "item_generic", pOrigin, g_vecZero, false, null );
						g_EntityFuncs.SetModel( pWall, "models/ww2projekt/shell_medium.mdl" );
						g_EntityFuncs.SetSize( pWall.pev, Vector( -1.0, -1.0, -2.0 ), Vector( 1.0, 1.0, 2.0 ) );
						pWall.pev.solid = SOLID_BBOX;
						pWall.pev.effects = EF_NODRAW;
					}
					else if( m_pPlayer.pev.flags & FL_DUCKING == 0 )
					{
						if( m_pPlayer.pev.flags & FL_ONGROUND == 0 )
							g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
						
						g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
					}
				}
				else
					g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGWaterDeploy );
				
				break;
			}
			
			case BIPOD_DEPLOY:
			{
				g_iCurrentMode = BIPOD_UNDEPLOY;
				
				self.SendWeaponAnim( BREN_DOWNTOUP );
				
				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				
				m_pPlayer.pev.weaponmodel = ( "models/ww2projekt/bren/p_brenbu.mdl" );
				
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.66f;
				
				if ( pWall !is null )
				{
					g_EntityFuncs.Remove( pWall );
					@pWall = null;
				}
				
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip < BREN_MAX_CLIP )
		{
			if( g_iCurrentMode == BIPOD_DEPLOY )
			{
				self.DefaultReload( BREN_MAX_CLIP, BREN_DOWNRELOAD, 4.24, 0 );
			}
			else if( g_iCurrentMode == BIPOD_UNDEPLOY )
			{
				self.DefaultReload( BREN_MAX_CLIP, BREN_UPRELOAD, 3.82, 0 );
			}
			
			BaseClass.Reload();
		}
	}
	
	void ItemPostFrame()
	{
		if ( g_iCurrentMode == BIPOD_DEPLOY )
			UpdateAiment();
		
		BaseClass.ItemPostFrame();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( BREN_UPIDLE );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( BREN_DOWNIDLE );
		}
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
	
	void UpdateAiment()
	{
		// Update "wall" origin in the event the player is somehow moved while deployed
		if ( pWall !is null )
		{
			Vector pOrigin;
			
			pOrigin = m_pPlayer.pev.origin - pForward * 8.0;
			pOrigin.z += 24.0;
			
			g_EntityFuncs.SetOrigin( pWall, pOrigin );
			
			// Limit player view
			Vector old_pAngles = m_pPlayer.pev.v_angle;
			Vector new_pAngles;
			float min_pAngles = pAngles.y - 40;
			float max_pAngles = pAngles.y + 40;
			bool bShouldChange = false;
			
			new_pAngles.x = old_pAngles.x;
			if ( old_pAngles.x < -20 )
			{
				new_pAngles.x = -20;
				bShouldChange = true;
			}
			else if ( old_pAngles.x > 20 )
			{
				new_pAngles.x = 20;
				bShouldChange = true;
			}
			
			new_pAngles.y = old_pAngles.y;
			if ( old_pAngles.y < min_pAngles )
			{
				// Wrapped angles?
				if ( ( old_pAngles.y - max_pAngles ) < -140 )
				{
					// Still in bounds?
					old_pAngles.y += 360;
					if ( old_pAngles.y > max_pAngles )
					{
						// Fix me
						max_pAngles -= 360;
						new_pAngles.y = max_pAngles;
						bShouldChange = true;
					}
				}
				else
				{
					new_pAngles.y = min_pAngles;
					bShouldChange = true;
				}
			}
			else if ( old_pAngles.y > max_pAngles )
			{
				// Wrapped angles?
				if ( ( old_pAngles.y - min_pAngles ) > 140 )
				{
					// Still in bounds?
					old_pAngles.y -= 360;
					if ( old_pAngles.y < min_pAngles )
					{
						// Fix me
						min_pAngles += 360;
						new_pAngles.y = min_pAngles;
						bShouldChange = true;
					}
				}
				else
				{
					new_pAngles.y = max_pAngles;
					bShouldChange = true;
				}
			}
			
			if ( bShouldChange )
			{
				m_pPlayer.pev.angles = new_pAngles;
				m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
			}
		}
	}
}

string GetBRENName()
{
	return "weapon_bren";
}

void RegisterBREN()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetBRENName(), GetBRENName() );
	g_ItemRegistry.RegisterWeapon( GetBRENName(), "ww2projekt", "556" );
}