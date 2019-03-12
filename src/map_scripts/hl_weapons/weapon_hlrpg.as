/* 
* The original Half-Life version of the rpg
*/

const int RPG_DEFAULT_GIVE = 1;
const int RPG_MAX_CARRY = 5;
const int RPG_MAX_CLIP = 1;
const int RPG_WEIGHT = 20;

enum rpg_e
{
	RPG_IDLE = 0,
	RPG_FIDGET,
	RPG_RELOAD,		// to reload
	RPG_FIRE2,		// to empty
	RPG_HOLSTER1,	// loaded
	RPG_DRAW1,		// loaded
	RPG_HOLSTER2,	// unloaded
	RPG_DRAW_UL,	// unloaded
	RPG_IDLE_UL,	// unloaded idle
	RPG_FIDGET_UL,	// unloaded fidget
};

class CLaserSpot : ScriptBaseEntity
{
	void Spawn()
	{
		Precache();
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_NOT;
		
		self.pev.rendermode = kRenderGlow;
		self.pev.renderfx = kRenderFxNoDissipation;
		self.pev.renderamt = 255;
		
		g_EntityFuncs.SetModel( self, "sprites/laserdot.spr" );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "sprites/laserdot.spr" );
	}
	
	// Suspend- make the laser sight invisible. 
	void Suspend( float flSuspendTime )
	{
		self.pev.effects |= EF_NODRAW;
		
		SetThink( ThinkFunction( Revive ) );
		self.pev.nextthink = g_Engine.time + flSuspendTime;
	}
	
	// Revive - bring a suspended laser sight back.
	void Revive()
	{
		self.pev.effects &= ~EF_NODRAW;

		SetThink( ThinkFunction( dummythink ) );
	}
	
	void dummythink()
	{
		// Dummy
	}
}

CLaserSpot@ CreateSpot()
{
	CBaseEntity@ pre_pSpot = g_EntityFuncs.CreateEntity( "hllaser_spot", null, false );
	CLaserSpot@ pSpot = cast<CLaserSpot@>(CastToScriptClass(pre_pSpot));
	
	pSpot.Spawn();
	
	return pSpot;
}

class CRpgRocket : ScriptBaseEntity
{
	int m_iTrail;
	float m_flIgniteTime;
	weapon_hlrpg@ m_pLauncher; // pointer back to the launcher that fired me. 
	
	void Spawn()
	{
		Precache();
		// motor
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;
		
		g_EntityFuncs.SetModel( self, "models/rpgrocket.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		SetThink( ThinkFunction( IgniteThink ) );
		SetTouch( TouchFunction( ExplodeTouch ) );
		
		self.pev.angles.x -= 30;
		g_EngineFuncs.MakeVectors( self.pev.angles );
		self.pev.angles.x = -(self.pev.angles.x + 30);
		
		self.pev.velocity = g_Engine.v_forward * 250;
		self.pev.gravity = 0.5;
		
		self.pev.nextthink = g_Engine.time + 0.4;
		
		self.pev.dmg = 120;
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/rpgrocket.mdl" );
		m_iTrail = g_Game.PrecacheModel( "sprites/smoke.spr" );
		g_SoundSystem.PrecacheSound( "weapons/rocket1.wav" );
	}
	
	void IgniteThink()
	{
		self.pev.movetype = MOVETYPE_FLY;
		self.pev.effects |= EF_LIGHT;
		
		// make rocket sound
		g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/rocket1.wav", 1, 0.5 );
		
		// rocket trail
		uint8 r, g, b, a;
		r = 224;
		g = 224;
		b = 225;
		a = 255;
		
		NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
		msg.WriteByte( TE_BEAMFOLLOW );
		msg.WriteShort( self.entindex() ); // entity
		msg.WriteShort( m_iTrail ); // model
		msg.WriteByte( 40 ); // life
		msg.WriteByte( 5 ); // width
		msg.WriteByte( r ); // r, g, b
		msg.WriteByte( g ); // r, g, b
		msg.WriteByte( b ); // r, g, b
		msg.WriteByte( a ); // brightness
		msg.End(); // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
		
		m_flIgniteTime = g_Engine.time;
		
		// set to follow laser spot
		SetThink( ThinkFunction( FollowThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;
	}

	void FollowThink()
	{
		CBaseEntity@ pOther = null;
		Vector vecTarget;
		Vector vecDir;
		float flDist, flMax, flDot;
		TraceResult tr;
		
		Math.MakeAimVectors( self.pev.angles );

		vecTarget = g_Engine.v_forward;
		flMax = 4096;
		
		// Examine all entities within a reasonable radius
		while ( ( @pOther = g_EntityFuncs.FindEntityByClassname( pOther, "hllaser_spot" ) ) !is null )
		{
			g_Utility.TraceLine( self.pev.origin, pOther.pev.origin, dont_ignore_monsters, self.edict(), tr );
			if ( tr.flFraction >= 0.90 )
			{
				vecDir = pOther.pev.origin - self.pev.origin;
				flDist = vecDir.Length();
				vecDir = vecDir.Normalize();
				flDot = DotProduct( g_Engine.v_forward, vecDir );
				if ( (flDot > 0 ) && ( flDist * ( 1 - flDot ) < flMax ) )
				{
					flMax = flDist * ( 1 - flDot );
					vecTarget = vecDir;
				}
			}
		}
		
		g_EngineFuncs.VecToAngles( vecTarget, self.pev.angles );
		
		// this acceleration and turning math is totally wrong, but it seems to respond well so don't change it.
		float flSpeed = self.pev.velocity.Length();
		if ( g_Engine.time - m_flIgniteTime < 1.0)
		{
			self.pev.velocity = self.pev.velocity * 0.2 + vecTarget * ( flSpeed * 0.8 + 400 );
			if ( self.pev.waterlevel == 3 )
			{
				// go slow underwater
				if ( self.pev.velocity.Length() > 300)
				{
					self.pev.velocity = pev.velocity.Normalize() * 300;
				}
				g_Utility.BubbleTrail( self.pev.origin - self.pev.velocity * 0.1, self.pev.origin, 4 );
			}
			else 
			{
				if ( self.pev.velocity.Length() > 2000 )
				{
					self.pev.velocity = self.pev.velocity.Normalize() * 2000;
				}
			}
		}
		else
		{
			int bCheck = self.pev.effects;
			if ( ( bCheck &= EF_LIGHT ) == EF_LIGHT )
			{
				self.pev.effects = 0;
				g_SoundSystem.StopSound( self.edict(), CHAN_VOICE, "weapons/rocket1.wav" );
			}
			self.pev.velocity = self.pev.velocity * 0.2 + vecTarget * flSpeed * 0.798;
			if ( self.pev.waterlevel == 0 && self.pev.velocity.Length() < 1500 )
			{
				Detonate();
			}
		}
		
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	void RocketTouch( CBaseEntity@ pOther )
	{
		if ( m_pLauncher !is null )
		{
			// my launcher is still around, tell it I'm dead.
			m_pLauncher.m_cActiveRockets--;
		}
		
		g_SoundSystem.StopSound( self.edict(), CHAN_VOICE, "weapons/rocket1.wav" );
		ExplodeTouch( pOther );
	}
	
	void ExplodeTouch( CBaseEntity@ pOther )
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
		
		TraceResult tr;
		Vector vecSpot; // trace starts here!
		
		@self.pev.enemy = @pOther.edict();
		
		vecSpot = self.pev.origin - self.pev.velocity.Normalize() * 32;
		g_Utility.TraceLine( vecSpot, vecSpot + self.pev.velocity.Normalize() * 64, ignore_monsters, self.edict(), tr );
		
		g_EntityFuncs.CreateExplosion( tr.vecEndPos, self.pev.angles, self.pev.owner, int( self.pev.dmg ), false ); // Effect
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );
		
		g_EntityFuncs.Remove( pThis );
	}
	
	void Detonate()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
		
		TraceResult tr;
		Vector vecSpot; // trace starts here!

		vecSpot = self.pev.origin + Vector( 0, 0, 8 );
		g_Utility.TraceLine( vecSpot, vecSpot + Vector( 0, 0, -40 ), ignore_monsters, self.edict(), tr);
		
		g_EntityFuncs.CreateExplosion( tr.vecEndPos, self.pev.angles, self.pev.owner, int( self.pev.dmg ), false ); // Effect
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );
		
		g_EntityFuncs.Remove( pThis );
	}
	
	void cSetTouch()
	{
		SetTouch( TouchFunction( RocketTouch ) );
	}
}

CRpgRocket@ CreateRpgRocket( Vector& in vecOrigin, Vector& in vecAngles, CBaseEntity@ pOwner, weapon_hlrpg@ pLauncher )
{
	CBaseEntity@ pre_pRocket = g_EntityFuncs.CreateEntity( "hlrpg_rocket", null, false );
	CRpgRocket@ pRocket = cast<CRpgRocket@>(CastToScriptClass(pre_pRocket));
	
	g_EntityFuncs.SetOrigin( pRocket.self, vecOrigin );
	//pRocket.pev.origin = vecOrigin;
	pRocket.pev.angles = vecAngles;
	pRocket.Spawn();
	pRocket.cSetTouch();
	@pRocket.m_pLauncher = @pLauncher; // remember what RPG fired me. 
	pRocket.m_pLauncher.m_cActiveRockets++; // register this missile as active for the launcher
	@pRocket.pev.owner = @pOwner.edict();

	return pRocket;
}

class weapon_hlrpg : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	CLaserSpot@ m_pSpot;
	int m_fSpotActive;
	int m_cActiveRockets; // how many missiles in flight from this launcher right now?
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_rpg.mdl" );
		
		m_fSpotActive = 0;
		
		self.m_iDefaultAmmo = RPG_DEFAULT_GIVE * 2; // more default ammo in multiplayer

		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/w_rpg.mdl" );
		g_Game.PrecacheModel( "models/hl/v_rpg.mdl" );
		g_Game.PrecacheModel( "models/hl/p_rpg.mdl" );
		
		g_Game.PrecacheOther( "hllaser_spot" );
		g_Game.PrecacheOther( "hlrpg_rocket" );
		
		g_SoundSystem.PrecacheSound( "weapons/rocketfire1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/glauncher.wav" ); // alternative fire sound
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hlrpg.txt" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
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
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= RPG_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= RPG_MAX_CLIP;
		info.iSlot 		= 3;
		info.iPosition 	= 5;
		info.iFlags 	= 0;
		info.iWeight 	= RPG_WEIGHT;
		
		return true;
	}
	
	bool Deploy()
	{
		if ( self.m_iClip == 0 )
		{
			return self.DefaultDeploy( self.GetV_Model( "models/hl/v_rpg.mdl" ), self.GetP_Model( "models/hl/p_rpg.mdl" ), RPG_DRAW_UL, "rpg" );
		}
		
		return self.DefaultDeploy( self.GetV_Model( "models/hl/v_rpg.mdl" ), self.GetP_Model( "models/hl/p_rpg.mdl" ), RPG_DRAW1, "rpg" );
	}
	
	bool CanHolster()
	{
		if ( m_fSpotActive > 0 && m_cActiveRockets > 0 )
		{
			// can't put away while guiding a missile.
			return false;
		}

		return true;
	}

	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false; // cancel any reload in progress.
		
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		
		self.SendWeaponAnim( RPG_HOLSTER1 );
		
		if ( m_pSpot !is null )
		{
			m_pSpot.pev.flags |= FL_KILLME;
			@m_pSpot = @null;
		}
	}
	
	void PrimaryAttack()
	{
		if ( self.m_iClip > 0 )
		{
			m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
			
			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			self.SendWeaponAnim( RPG_FIRE2 );
			m_pPlayer.pev.punchangle.x = -3.0;
			
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
			Vector vecSrc = m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -8;
			
			CRpgRocket@ pRocket = CreateRpgRocket( vecSrc, m_pPlayer.pev.v_angle, m_pPlayer, this );
			
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle ); // RpgRocket::Create stomps on globals, so remake.
			pRocket.pev.velocity = pRocket.pev.velocity + g_Engine.v_forward * DotProduct( m_pPlayer.pev.velocity, g_Engine.v_forward );
			
			// firing RPG no longer turns on the designator. ALT fire is a toggle switch for the LTD.
			// Ken signed up for this as a global change (sjb)
			
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/rocketfire1.wav", 1, ATTN_NORM );
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_BODY, "weapons/glauncher.wav", 1, ATTN_NORM );
			
			self.m_iClip--; 
			
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.5;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5;
		}
		else
		{
			PlayEmptySound();
		}
		UpdateSpot();
	}
	
	void DISABLED_SecondaryAttack()
	{
		m_fSpotActive = m_fSpotActive ^ 1;
		
		if ( m_fSpotActive == 0 && m_pSpot !is null )
		{
			m_pSpot.pev.flags |= FL_KILLME;
			@m_pSpot = @null;
		}
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
	}
	
	void UpdateSpot()
	{
		if ( m_fSpotActive > 0 )
		{
			if ( m_pSpot is null )
			{
				@m_pSpot = CreateSpot();
			}
			
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
			Vector vecSrc = m_pPlayer.GetGunPosition();
			Vector vecAiming = g_Engine.v_forward;
			
			TraceResult tr;
			g_Utility.TraceLine( vecSrc, vecSrc + vecAiming * 8192, dont_ignore_monsters, m_pPlayer.edict(), tr );
			
			g_EntityFuncs.SetOrigin( m_pSpot.self, tr.vecEndPos );
			//m_pSpot.pev.origin = tr.vecEndPos;
		}
	}
	
	void Reload()
	{
		bool iResult;
		
		if ( self.m_iClip == 1 )
		{
			// don't bother with any of this if don't need to reload.
			return;
		}
		
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		// because the RPG waits to autoreload when no missiles are active while  the LTD is on, the
		// weapons code is constantly calling into this function, but is often denied because 
		// a) missiles are in flight, but the LTD is on
		// or
		// b) player is totally out of ammo and has nothing to switch to, and should be allowed to
		//    shine the designator around
		//
		// Set the next attack time into the future so that WeaponIdle will get called more often
		// than reload, allowing the RPG LTD to be updated
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
		
		if ( m_cActiveRockets > 0 && m_fSpotActive > 0 )
		{
			// no reloading when there are active missiles tracking the designator.
			// ward off future autoreload attempts by setting next attack time into the future for a bit. 
			return;
		}
		
		if ( m_pSpot !is null && m_fSpotActive > 0 )
		{
			m_pSpot.Suspend( 2.1 );
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 2.1;
		}
		
		if ( self.m_iClip == 0 )
			iResult = self.DefaultReload( RPG_MAX_CLIP, RPG_RELOAD, 2 );
		
		if ( iResult )
			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}
	
	void WeaponIdle()
	{
		UpdateSpot();
		
		self.ResetEmptySound();
		
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			int iAnim;
			float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
			if ( flRand <= 0.75 || m_fSpotActive > 0 )
			{
				if ( self.m_iClip == 0 )
					iAnim = RPG_IDLE_UL;
				else
					iAnim = RPG_IDLE;
				
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 90.0 / 15.0;
			}
			else
			{
				if ( self.m_iClip == 0 )
					iAnim = RPG_FIDGET_UL;
				else
					iAnim = RPG_FIDGET;
				
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 3.0;
			}
			
			self.SendWeaponAnim( iAnim );
		}
		else
		{
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1;
		}
	}
}

string GetHLRpgName()
{
	return "weapon_hlrpg";
}

void RegisterHLRpg()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CLaserSpot", "hllaser_spot" );
	g_CustomEntityFuncs.RegisterCustomEntity( "CRpgRocket", "hlrpg_rocket" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlrpg", GetHLRpgName() );
	g_ItemRegistry.RegisterWeapon( GetHLRpgName(), "hl_weapons", "rockets" );
}
