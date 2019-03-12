enum MG42Animation_e
{
	MG42_UPIDLE = 0,
	MG42_UPIDLE8,
	MG42_UPIDLE7,
	MG42_UPIDLE6,
	MG42_UPIDLE5,
	MG42_UPIDLE4,
	MG42_UPIDLE3,
	MG42_UPIDLE2,
	MG42_UPIDLE1,
	MG42_UPIDLE_EMPTY,
	MG42_DOWNIDLE,
	MG42_DOWNIDLE8,
	MG42_DOWNIDLE7,
	MG42_DOWNIDLE6,
	MG42_DOWNIDLE5,
	MG42_DOWNIDLE4,
	MG42_DOWNIDLE3,
	MG42_DOWNIDLE2,
	MG42_DOWNIDLE1,
	MG42_DOWNIDLE_EMPTY,
	MG42_DOWNTOUP,
	MG42_DOWNTOUP8,
	MG42_DOWNTOUP7,
	MG42_DOWNTOUP6,
	MG42_DOWNTOUP5,
	MG42_DOWNTOUP4,
	MG42_DOWNTOUP3,
	MG42_DOWNTOUP2,
	MG42_DOWNTOUP1,
	MG42_DOWNTOUP_EMPTY,
	MG42_UPTODOWN,
	MG42_UPTODOWN8,
	MG42_UPTODOWN7,
	MG42_UPTODOWN6,
	MG42_UPTODOWN5,
	MG42_UPTODOWN4,
	MG42_UPTODOWN3,
	MG42_UPTODOWN2,
	MG42_UPTODOWN1,
	MG42_UPTODOWN_EMPTY,
	MG42_UPSHOOT,
	MG42_UPSHOOT8,
	MG42_UPSHOOT7,
	MG42_UPSHOOT6,
	MG42_UPSHOOT5,
	MG42_UPSHOOT4,
	MG42_UPSHOOT3,
	MG42_UPSHOOT2,
	MG42_UPSHOOT1,
	MG42_DOWNSHOOT,
	MG42_DOWNSHOOT8,
	MG42_DOWNSHOOT7,
	MG42_DOWNSHOOT6,
	MG42_DOWNSHOOT5,
	MG42_DOWNSHOOT4,
	MG42_DOWNSHOOT3,
	MG42_DOWNSHOOT2,
	MG42_DOWNSHOOT1,
	MG42_RELOAD
}; //THATS A VERY BIG NUMBER OF ANIMATIONS DONT YA THINK?

const int MG42_DEFAULT_GIVE		= 400;
const int MG42_MAX_CARRY		= 600;
const int MG42_MAX_CLIP			= 200;
const int MG42_WEIGHT			= 50;

class weapon_mg42 : ScriptBasePlayerWeaponEntity
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
		g_EntityFuncs.SetModel( self, "models/ww2projekt/mg42/w_mg42.mdl" );
		
		self.m_iDefaultAmmo = MG42_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/mg42/w_mg42.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg42/v_mg42.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg42/p_mg42bu.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg42/p_mg42bd.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_medium.mdl" );
		g_Game.PrecacheModel( "models/egg.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mg42_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bulletchain.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgdeploy.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mg42_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bulletchain.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgdeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_mg42.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_mg42.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= MG42_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= MG42_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 10;
		info.iFlags		= 0;
		info.iWeight	= MG42_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage axis11( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis11.WriteLong( self.m_iId );
			axis11.End();
			
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
		int AmmoAnim; //here we go
		bool bResult;
		{
			AmmoAnim = self.m_iClip <= 8 ? MG42_DOWNTOUP_EMPTY - self.m_iClip : MG42_DOWNTOUP;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/mg42/v_mg42.mdl" ), self.GetP_Model( "models/ww2projekt/mg42/p_mg42bu.mdl" ), AmmoAnim, "saw" );
			
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
		int AmmoAnim; //again...
		
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.05;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			if( self.m_iClip == 7 )
				AmmoAnim = MG42_UPSHOOT8;
			else if( self.m_iClip == 6 )
				AmmoAnim = MG42_UPSHOOT7;
			else if( self.m_iClip == 5 )
				AmmoAnim = MG42_UPSHOOT6;
			else if( self.m_iClip == 4 )
				AmmoAnim = MG42_UPSHOOT5;
			else if( self.m_iClip == 3 )
				AmmoAnim = MG42_UPSHOOT4;
			else if( self.m_iClip == 2 )
				AmmoAnim = MG42_UPSHOOT3;
			else if( self.m_iClip == 1 )
				AmmoAnim = MG42_UPSHOOT2;
			else if( self.m_iClip == 0 )
				AmmoAnim = MG42_UPSHOOT1;
			else
				AmmoAnim = MG42_UPSHOOT;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			if( self.m_iClip == 7 )
				AmmoAnim = MG42_DOWNSHOOT8;
			else if( self.m_iClip == 6 )
				AmmoAnim = MG42_DOWNSHOOT7;
			else if( self.m_iClip == 5 )
				AmmoAnim = MG42_DOWNSHOOT6;
			else if( self.m_iClip == 4 )
				AmmoAnim = MG42_DOWNSHOOT5;
			else if( self.m_iClip == 3 )
				AmmoAnim = MG42_DOWNSHOOT4;
			else if( self.m_iClip == 2 )
				AmmoAnim = MG42_DOWNSHOOT3;
			else if( self.m_iClip == 1 )
				AmmoAnim = MG42_DOWNSHOOT2;
			else if( self.m_iClip == 0 )
				AmmoAnim = MG42_DOWNSHOOT1;
			else
				AmmoAnim = MG42_DOWNSHOOT;
		}
		
		self.SendWeaponAnim( AmmoAnim, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/mg42_shoot1.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 20;
		
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
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -5.0f, 5.0f );
			
			if( m_pPlayer.pev.punchangle.x < -40 ) //defines a max recoil
				m_pPlayer.pev.punchangle.x = -40;
			
			vecDir = vecAiming + x * VECTOR_CONE_20DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_20DEGREES.y * g_Engine.v_up;
			m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_20DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = -1.65;
			
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				vecDir = vecAiming + x * VECTOR_CONE_6DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_6DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else
			{
				vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
				m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_3DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
		}
		
		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
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
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 14, 7, -8 );
		else if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 9, 7, -8 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
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
					
						AmmoAnim = self.m_iClip <= 8 ? MG42_UPTODOWN_EMPTY - self.m_iClip : MG42_UPTODOWN;
				
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						m_pPlayer.pev.weaponmodel = ( "models/ww2projekt/mg42/p_mg42bd.mdl" );
						self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.2f;
						
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
						self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.000000001;
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

				AmmoAnim = self.m_iClip <= 8 ? MG42_DOWNTOUP_EMPTY - self.m_iClip : MG42_DOWNTOUP;

				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				m_pPlayer.pev.weaponmodel = ( "models/ww2projekt/mg42/p_mg42bu.mdl" );
				
				self.SendWeaponAnim( AmmoAnim );
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0f;
				
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
			if( self.m_iClip < MG42_MAX_CLIP )
				BaseClass.Reload();
			
			self.DefaultReload( MG42_MAX_CLIP, MG42_RELOAD, 6.95, 0 );
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
		int AmmoAnim; //Again with this?

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			AmmoAnim = self.m_iClip <= 8 ? MG42_UPIDLE_EMPTY - self.m_iClip : MG42_UPIDLE;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			AmmoAnim = self.m_iClip <= 8 ? MG42_DOWNIDLE_EMPTY - self.m_iClip : MG42_DOWNIDLE;
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

string GetMG42Name()
{
	return "weapon_mg42";
}

void RegisterMG42()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMG42Name(), GetMG42Name() );
	g_ItemRegistry.RegisterWeapon( GetMG42Name(), "ww2projekt", "556" );
}