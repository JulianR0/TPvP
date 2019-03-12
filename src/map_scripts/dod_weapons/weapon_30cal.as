enum THIRTYCALAnimation_e
{
	THIRTYCAL_UPIDLE = 0,
	THIRTYCAL_UPIDLE8,
	THIRTYCAL_UPIDLE7,
	THIRTYCAL_UPIDLE6,
	THIRTYCAL_UPIDLE5,
	THIRTYCAL_UPIDLE4,
	THIRTYCAL_UPIDLE3,
	THIRTYCAL_UPIDLE2,
	THIRTYCAL_UPIDLE1,
	THIRTYCAL_UPIDLE_EMPTY,
	THIRTYCAL_DOWNIDLE,
	THIRTYCAL_DOWNIDLE8,
	THIRTYCAL_DOWNIDLE7,
	THIRTYCAL_DOWNIDLE6,
	THIRTYCAL_DOWNIDLE5,
	THIRTYCAL_DOWNIDLE4,
	THIRTYCAL_DOWNIDLE3,
	THIRTYCAL_DOWNIDLE2,
	THIRTYCAL_DOWNIDLE1,
	THIRTYCAL_DOWNIDLE_EMPTY,
	THIRTYCAL_DOWNTOUP,
	THIRTYCAL_DOWNTOUP8,
	THIRTYCAL_DOWNTOUP7,
	THIRTYCAL_DOWNTOUP6,
	THIRTYCAL_DOWNTOUP5,
	THIRTYCAL_DOWNTOUP4,
	THIRTYCAL_DOWNTOUP3,
	THIRTYCAL_DOWNTOUP2,
	THIRTYCAL_DOWNTOUP1,
	THIRTYCAL_DOWNTOUP_EMPTY,
	THIRTYCAL_UPTODOWN,
	THIRTYCAL_UPTODOWN8,
	THIRTYCAL_UPTODOWN7,
	THIRTYCAL_UPTODOWN6,
	THIRTYCAL_UPTODOWN5,
	THIRTYCAL_UPTODOWN4,
	THIRTYCAL_UPTODOWN3,
	THIRTYCAL_UPTODOWN2,
	THIRTYCAL_UPTODOWN1,
	THIRTYCAL_UPTODOWN_EMPTY,
	THIRTYCAL_UPSHOOT,
	THIRTYCAL_UPSHOOT8,
	THIRTYCAL_UPSHOOT7,
	THIRTYCAL_UPSHOOT6,
	THIRTYCAL_UPSHOOT5,
	THIRTYCAL_UPSHOOT4,
	THIRTYCAL_UPSHOOT3,
	THIRTYCAL_UPSHOOT2,
	THIRTYCAL_UPSHOOT1,
	THIRTYCAL_DOWNSHOOT,
	THIRTYCAL_DOWNSHOOT8,
	THIRTYCAL_DOWNSHOOT7,
	THIRTYCAL_DOWNSHOOT6,
	THIRTYCAL_DOWNSHOOT5,
	THIRTYCAL_DOWNSHOOT4,
	THIRTYCAL_DOWNSHOOT3,
	THIRTYCAL_DOWNSHOOT2,
	THIRTYCAL_DOWNSHOOT1,
	THIRTYCAL_RELOAD
}; //HERE WE GO AGAIN

const int THIRTYCAL_DEFAULT_GIVE	= 400;
const int THIRTYCAL_MAX_CARRY		= 600;
const int THIRTYCAL_MAX_CLIP		= 200;
const int THIRTYCAL_WEIGHT			= 50;

class weapon_30cal : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/ww2projekt/30cal/w_30cal.mdl" );
		
		self.m_iDefaultAmmo = THIRTYCAL_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/30cal/w_30cal.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/30cal/v_30cal.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/30cal/p_30cal.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_medium.mdl" );
		g_Game.PrecacheModel( "models/egg.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/30cal_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/30cal_handle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bulletchain.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/30cal_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/30cal_handle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bulletchain.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_30cal.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_30cal.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= THIRTYCAL_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= THIRTYCAL_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= THIRTYCAL_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage allies8( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies8.WriteLong( self.m_iId );
			allies8.End();
			
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
		int AmmoAnim;
		bool bResult;
		{
			AmmoAnim = self.m_iClip <= 8 ? THIRTYCAL_DOWNTOUP_EMPTY - self.m_iClip : THIRTYCAL_DOWNTOUP;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/30cal/v_30cal.mdl" ), self.GetP_Model( "models/ww2projekt/30cal/p_30cal.mdl" ), AmmoAnim, "saw" );
			
			float deployTime = 1.20f;
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
		int AmmoAnim;
		
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.095;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			if( self.m_iClip == 7 )
				AmmoAnim = THIRTYCAL_UPSHOOT8;
			else if( self.m_iClip == 6 )
				AmmoAnim = THIRTYCAL_UPSHOOT7;
			else if( self.m_iClip == 5 )
				AmmoAnim = THIRTYCAL_UPSHOOT6;
			else if( self.m_iClip == 4 )
				AmmoAnim = THIRTYCAL_UPSHOOT5;
			else if( self.m_iClip == 3 )
				AmmoAnim = THIRTYCAL_UPSHOOT4;
			else if( self.m_iClip == 2 )
				AmmoAnim = THIRTYCAL_UPSHOOT3;
			else if( self.m_iClip == 1 )
				AmmoAnim = THIRTYCAL_UPSHOOT2;
			else if( self.m_iClip == 0 )
				AmmoAnim = THIRTYCAL_UPSHOOT1;
			else
				AmmoAnim = THIRTYCAL_UPSHOOT;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			if( self.m_iClip == 7 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT8;
			else if( self.m_iClip == 6 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT7;
			else if( self.m_iClip == 5 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT6;
			else if( self.m_iClip == 4 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT5;
			else if( self.m_iClip == 3 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT4;
			else if( self.m_iClip == 2 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT3;
			else if( self.m_iClip == 1 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT2;
			else if( self.m_iClip == 0 )
				AmmoAnim = THIRTYCAL_DOWNSHOOT1;
			else
				AmmoAnim = THIRTYCAL_DOWNSHOOT;
		}
		
		self.SendWeaponAnim( AmmoAnim, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/30cal_shoot.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 23;
		
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
			m_pPlayer.pev.punchangle.x -= 1.65;
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -6.0f, 6.0f );
			
			if( m_pPlayer.pev.punchangle.x < -48 ) //defines a max recoil
				m_pPlayer.pev.punchangle.x = -48;
			
			vecDir = vecAiming + x * VECTOR_CONE_20DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_20DEGREES.y * g_Engine.v_up;
			m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_20DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = -1.65;
			
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				vecDir = vecAiming + x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_4DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else
			{
				vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
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
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 10, 6, -8 );
		else if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 12, 6, -8 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		//Produces a tracer at the start of the attachment at a rate of 4 bullets
		switch( ( self.m_iClip ) % 4 )
		{
			case 0: WW2DynamicTracer( vecAttachOrigin, tr.vecEndPos ); break;
		}
	}
	
	void SecondaryAttack()
	{
		int AmmoAnim; // oh shiet...

		switch( g_iCurrentMode )
		{
			case BIPOD_UNDEPLOY:
			{
				if( m_pPlayer.pev.waterlevel == WATERLEVEL_DRY || m_pPlayer.pev.waterlevel == WATERLEVEL_FEET )
				{
					if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 ) //needs to be fully crouched and not jumping-crouched
					{
						g_iCurrentMode = BIPOD_DEPLOY;
					
						AmmoAnim = self.m_iClip <= 8 ? THIRTYCAL_UPTODOWN_EMPTY - self.m_iClip : THIRTYCAL_UPTODOWN;
				
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.62f;
						
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
						{
							g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
							self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.000000001;
						}
						g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
					}
				}
				else
				{
					g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGWaterDeploy );
					self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.000000001;
				}
		
				self.SendWeaponAnim( AmmoAnim );
				break;
			}

			case BIPOD_DEPLOY:
			{
				g_iCurrentMode = BIPOD_UNDEPLOY;

				AmmoAnim = self.m_iClip <= 8 ? THIRTYCAL_DOWNTOUP_EMPTY - self.m_iClip : THIRTYCAL_DOWNTOUP;

				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				
				self.SendWeaponAnim( AmmoAnim );
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.20f;
				
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
		if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			if( self.m_iClip < THIRTYCAL_MAX_CLIP )
				BaseClass.Reload();
			
			self.DefaultReload( THIRTYCAL_MAX_CLIP, THIRTYCAL_RELOAD, 6.05, 0 );
		}
		else
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGReloadDeploy );
	}
	
	void ItemPostFrame()
	{
		if ( g_iCurrentMode == BIPOD_DEPLOY )
			UpdateAiment();
		
		BaseClass.ItemPostFrame();
	}
	
	void WeaponIdle()
	{
		int AmmoAnim; 

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			AmmoAnim = self.m_iClip <= 8 ? THIRTYCAL_UPIDLE_EMPTY - self.m_iClip : THIRTYCAL_UPIDLE;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			AmmoAnim = self.m_iClip <= 8 ? THIRTYCAL_DOWNIDLE_EMPTY - self.m_iClip : THIRTYCAL_DOWNIDLE;
		}
		
		self.SendWeaponAnim( AmmoAnim );

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

string GetTHIRTYCALName()
{
	return "weapon_30cal";
}

void RegisterTHIRTYCAL()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetTHIRTYCALName(), GetTHIRTYCALName() );
	g_ItemRegistry.RegisterWeapon( GetTHIRTYCALName(), "ww2projekt", "556" );
}