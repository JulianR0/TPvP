enum PIATAnimation_e
{
	PIAT_IDLE = 0,
	PIAT_IDLE_EMPTY,
	PIAT_DRAW,
	PIAT_DRAW_EMPTY,
	PIAT_AIMED,
	PIAT_AIMED_EMPTY,
	PIAT_LAUNCH,
	PIAT_DOWNTOUP,
	PIAT_DOWNTOUP_EMPTY,
	PIAT_UPTODOWN,
	PIAT_UPTODOWN_EMPTY,
	PIAT_RELOAD_IDLE,
	PIAT_RELOAD_AIMED
};

const int PIAT_DEFAULT_GIVE		= 5;
const int PIAT_MAX_CARRY		= 5;
const int PIAT_MAX_CLIP			= 1;
const int PIAT_WEIGHT			= 50;

class weapon_piat : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int g_iCurrentMode;
	CBaseEntity@ pRocket;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/piat/w_piat.mdl" );
		
		self.m_iDefaultAmmo = PIAT_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/piat/w_piat.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/piat/w_piat_rocket.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/piat/v_piat.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/piat/p_piat.mdl" );
		
		//Precache for Download
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/piat_rocket1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookadeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookapickup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadgetrocket.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadrocketin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		//Precache for the Engine
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/piat_rocket1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookadeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookapickup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadgetrocket.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadrocketin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_piat.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_piat.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= PIAT_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= PIAT_MAX_CLIP;
		info.iSlot		= 4;
		info.iPosition	= 9;
		info.iFlags		= ITEM_FLAG_NOAUTORELOAD;
		info.iWeight	= PIAT_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage british6( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				british6.WriteLong( self.m_iId );
			british6.End();
			
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
		
		if( self.m_iClip == 0 )
			AmmoAnim = PIAT_DRAW_EMPTY;
		else
			AmmoAnim = PIAT_DRAW;
		
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/piat/v_piat.mdl" ), self.GetP_Model( "models/ww2projekt/piat/p_piat.mdl" ), AmmoAnim, "rpg" );
			
			float deployTime = 1.03f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		
		if( g_iCurrentMode == InShoulder )
			SecondaryAttack();
		
		g_iCurrentMode = 0;
		m_pPlayer.pev.maxspeed = 0;
		m_pPlayer.pev.fuser4 = 0;
		
		BaseClass.Holster( skipLocal );
	}
	
	void PrimaryAttack()
	{
		if( g_iCurrentMode == InShoulder )
		{
			
			if ( !( ( m_pPlayer.pev.flags & FL_ONGROUND ) != 0 ) ) // Not on ground
			{
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, ROCKETCantOnAir );
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
		
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3;
		
			m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
			--self.m_iClip;
		
			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
			self.SendWeaponAnim( PIAT_LAUNCH );

			m_pPlayer.pev.punchangle.x -= 10;
			m_pPlayer.pev.punchangle.y -= 3;
		
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/piat_rocket1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
			Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
			@pRocket = g_EntityFuncs.CreateRPGRocket( m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -8, m_pPlayer.pev.v_angle, m_pPlayer.edict() );
			g_EntityFuncs.SetModel( pRocket, "models/ww2projekt/piat/w_piat_rocket.mdl" );
			
			pRocket.pev.dmg = 150; //projectile damage
			
			if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
				m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}
		else if( g_iCurrentMode == NotInShoulder )
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, ROCKETDeploy );
	}
	
	void SecondaryAttack()
	{
		switch( g_iCurrentMode )
		{
			case NotInShoulder:
			{
				g_iCurrentMode = InShoulder;
				if( self.m_iClip == 0 )
					self.SendWeaponAnim( PIAT_DOWNTOUP_EMPTY );
				else
					self.SendWeaponAnim( PIAT_DOWNTOUP );
				
				m_pPlayer.pev.maxspeed = 70; //will lower your speed
				m_pPlayer.pev.fuser4 = 1; // Prevent jumping
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.83;
				break;
			}
			
			case InShoulder:
			{
				g_iCurrentMode = NotInShoulder;
				if( self.m_iClip == 0 )
					self.SendWeaponAnim( PIAT_UPTODOWN_EMPTY );
				else
					self.SendWeaponAnim( PIAT_UPTODOWN );
			
				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.03;
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip < PIAT_MAX_CLIP )
			BaseClass.Reload();
		
		if( g_iCurrentMode == NotInShoulder )
			self.DefaultReload( PIAT_MAX_CLIP, PIAT_RELOAD_IDLE, 3.03, 0 );
		else
			self.DefaultReload( PIAT_MAX_CLIP, PIAT_RELOAD_AIMED, 3.03, 0 );
	}
	
	void WeaponIdle()
	{
		int AmmoAnim;
		
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if( g_iCurrentMode == InShoulder )
		{
			if( self.m_iClip == 0 )
				AmmoAnim = PIAT_AIMED_EMPTY;
			else
				AmmoAnim = PIAT_AIMED;
		}
		else if( g_iCurrentMode == NotInShoulder )
		{
			if( self.m_iClip == 0 )
				AmmoAnim = PIAT_IDLE_EMPTY;
			else
				AmmoAnim = PIAT_IDLE;
		}
		
		self.SendWeaponAnim( AmmoAnim );
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetPIATName()
{
	return "weapon_piat";
}

void RegisterPIAT()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetPIATName(), GetPIATName() );
	g_ItemRegistry.RegisterWeapon( GetPIATName(), "ww2projekt", "rockets" );
}