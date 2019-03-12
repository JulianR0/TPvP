/* 
* The original Half-Life version of the tripmine
* ...sort of...
*/

const int TRIPMINE_DEFAULT_GIVE = 1;
const int TRIPMINE_MAX_CARRY = 5;
const int TRIPMINE_MAX_CLIP = WEAPON_NOCLIP;
const int TRIPMINE_WEIGHT = -10;

enum tripmine_e
{
	TRIPMINE_IDLE1 = 0,
	TRIPMINE_IDLE2,
	TRIPMINE_ARM1,
	TRIPMINE_ARM2,
	TRIPMINE_FIDGET,
	TRIPMINE_HOLSTER,
	TRIPMINE_DRAW,
	TRIPMINE_WORLD,
	TRIPMINE_GROUND,
};

class CTripmineGrenade : ScriptBaseMonsterEntity
{
	float m_flPowerUp;
	Vector m_vecDir;
	Vector m_vecEnd;
	float m_flBeamLength;
	
	EHandle m_hOwner;
	CBeam@ m_pBeam;
	Vector m_posOwner;
	Vector m_angleOwner;
	edict_t@ m_pRealOwner; // tracelines don't hit PEV->OWNER, which means a player couldn't detonate his own trip mine, so we store the owner here.
	
	void Spawn()
	{
		Precache();
		// motor
		self.pev.movetype = MOVETYPE_FLY;
		self.pev.solid = SOLID_NOT;
		
		g_EntityFuncs.SetModel( self, "models/hl/v_tripmine.mdl" );
		self.pev.frame = 0;
		self.pev.body = 3;
		self.pev.sequence = TRIPMINE_WORLD;
		self.ResetSequenceInfo();
		self.pev.framerate = 0;
		self.m_bloodColor = DONT_BLEED;
		
		g_EntityFuncs.SetSize( self.pev, Vector( -8, -8, -8 ), Vector( 8, 8, 8 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		int bCheck = self.pev.spawnflags;
		if ( ( bCheck &= 1 ) == 1 )
		{
			// power up quickly
			m_flPowerUp = g_Engine.time + 1.0;
		}
		else
		{
			// power up in 2.5 seconds
			m_flPowerUp = g_Engine.time + 2.5;
		}
		
		SetThink( ThinkFunction( PowerupThink ) );
		self.pev.nextthink = g_Engine.time + 0.2;
		
		self.pev.takedamage = DAMAGE_YES;
		self.pev.dmg = 150;
		self.pev.health = 1; // don't let die normally
		
		if ( !FNullEnt( self.pev.owner ) )
		{
			// play deploy sound
			g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/mine_deploy.wav", 1.0, ATTN_NORM );
			g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "weapons/mine_charge.wav", 0.2, ATTN_NORM ); // chargeup
			
			@m_pRealOwner = @self.pev.owner;
		}
		
		Math.MakeAimVectors( self.pev.angles );
		
		m_vecDir = g_Engine.v_forward;
		m_vecEnd = self.pev.origin + m_vecDir * 2048;
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/v_tripmine.mdl" );
		g_SoundSystem.PrecacheSound( "weapons/mine_deploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mine_activate.wav" );
		g_SoundSystem.PrecacheSound( "weapons/mine_charge.wav" );
		
		g_Game.PrecacheModel( "sprites/laserbeam.spr" );
		
		g_SoundSystem.PrecacheSound( "common/null.wav" );
	}
	
	void PowerupThink()
	{
		TraceResult tr;
		
		CBaseEntity@ eOwner = m_hOwner.GetEntity();
		if ( eOwner is null )
		{
			// find an owner
			CBaseEntity@ oldowner = g_EntityFuncs.Instance( self.pev.owner );
			@self.pev.owner = @null;
			
			g_Utility.TraceLine( self.pev.origin + m_vecDir * 8, self.pev.origin - m_vecDir * 32, dont_ignore_monsters, self.edict(), tr );
			
			CBaseEntity@ eHit = g_EntityFuncs.Instance( tr.pHit );
			
			if ( tr.fStartSolid > 0 || ( eHit == oldowner ) )
			{
				@self.pev.owner = @oldowner.edict();
				m_flPowerUp += 0.1;
				self.pev.nextthink = g_Engine.time + 0.1;
				return;
			}
			if ( tr.flFraction < 1.0 )
			{
				@self.pev.owner = @tr.pHit;
				m_hOwner = g_EntityFuncs.Instance( self.pev.owner );
				m_posOwner = ( m_hOwner.GetEntity() ).pev.origin;
				m_angleOwner = ( m_hOwner.GetEntity() ).pev.angles;
			}
			else
			{
				g_SoundSystem.StopSound( self.edict(), CHAN_VOICE, "weapons/mine_deploy.wav" );
				g_SoundSystem.StopSound( self.edict(), CHAN_BODY, "weapons/mine_charge.wav" );
				SetThink( ThinkFunction( DelayRemove ) );
				self.pev.nextthink = g_Engine.time + 0.1;
				KillBeam();
				return;
			}
		}
		else if ( m_posOwner != ( m_hOwner.GetEntity() ).pev.origin || m_angleOwner != ( m_hOwner.GetEntity() ).pev.angles )
		{
			// disable
			g_SoundSystem.StopSound( self.edict(), CHAN_VOICE, "weapons/mine_deploy.wav" );
			g_SoundSystem.StopSound( self.edict(), CHAN_BODY, "weapons/mine_charge.wav" );
			CBaseEntity@ pMine = g_EntityFuncs.Create( "weapon_hltripmine", self.pev.origin + m_vecDir * 24, pev.angles, false );
			pMine.pev.spawnflags |= SF_NORESPAWN;
			
			SetThink( ThinkFunction( DelayRemove ) );
			KillBeam();
			self.pev.nextthink = g_Engine.time + 0.1;
			return;
		}
		
		if ( g_Engine.time > m_flPowerUp )
		{
			// make solid
			self.pev.solid = SOLID_BBOX;
			g_EntityFuncs.SetOrigin( self, self.pev.origin );
			
			MakeBeam();
			
			// play enabled sound
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "weapons/mine_activate.wav", 0.5, ATTN_NORM, 1.0, 75 );
		}
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	void KillBeam()
	{
		if ( m_pBeam !is null )
		{
			g_EntityFuncs.Remove( m_pBeam );
			@m_pBeam = null;
		}
	}
	
	void MakeBeam()
	{
		TraceResult tr;
		
		g_Utility.TraceLine( self.pev.origin, m_vecEnd, dont_ignore_monsters, self.edict(), tr );
		
		m_flBeamLength = tr.flFraction;
		
		// set to follow laser spot
		SetThink( ThinkFunction( BeamBreakThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;
		
		Vector vecTmpEnd = self.pev.origin + m_vecDir * 2048 * m_flBeamLength;
		
		@m_pBeam = @g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 10 );
		m_pBeam.PointEntInit( vecTmpEnd, self.entindex() );
		
		// set laser color according to team
		CBaseEntity@ eOwner = g_EntityFuncs.Instance( m_pRealOwner );
		if ( eOwner !is null )
		{
			if ( eOwner.Classify() == CLASS_HUMAN_MILITARY )
				m_pBeam.SetColor( 0, 214, 198 );
			else if ( eOwner.Classify() == CLASS_ALIEN_MILITARY )
				m_pBeam.SetColor( 214, 50, 10 );
			else
				m_pBeam.SetColor( 255, 198, 10 );
		}
		else
			m_pBeam.SetColor( 250, 250, 250 );
		
		m_pBeam.SetScrollRate( 255 );
		m_pBeam.SetBrightness( 64 );
	}
	
	void UpdateBeam()
	{
		// Update beam laser so players can know what this tripmine is
		if ( m_pBeam !is null )
		{
			CBaseEntity@ eOwner = g_EntityFuncs.Instance( m_pRealOwner );
			if ( eOwner !is null )
			{
				if ( eOwner.Classify() == CLASS_HUMAN_MILITARY )
					m_pBeam.SetColor( 0, 214, 198 );
				else if ( eOwner.Classify() == CLASS_ALIEN_MILITARY )
					m_pBeam.SetColor( 214, 50, 10 );
				else
					m_pBeam.SetColor( 255, 198, 10 );
			}
			else
				m_pBeam.SetColor( 250, 250, 250 );
		}
	}
	
	void BeamBreakThink()
	{
		bool bBlowup = false;
		UpdateBeam();
		
		TraceResult tr;
		
		// HACKHACK Set simple box using this really nice global!
		//g_Engine.trace_flags = FTRACE_SIMPLEBOX;
		g_Utility.TraceLine( self.pev.origin, m_vecEnd, dont_ignore_monsters, self.edict(), tr );
		
		// respawn detect.
		CBaseEntity@ eBeam = g_EntityFuncs.Instance( m_pBeam.edict() );
		if ( eBeam is null )
		{
			MakeBeam();
			CBaseEntity@ eHit = g_EntityFuncs.Instance( tr.pHit );
			if ( eHit !is null )
				m_hOwner = eHit; // reset owner too
		}
		
		if ( abs( m_flBeamLength - tr.flFraction ) > 0.001 )
		{
			CBaseEntity@ eHit = g_EntityFuncs.Instance( tr.pHit );
			if ( eHit !is null )
			{
				CBaseEntity@ eOwner = g_EntityFuncs.Instance( m_pRealOwner );
				if ( eOwner !is null )
				{
					if ( eHit.Classify() != eOwner.Classify() )
						bBlowup = true;
				}
			}
			
		}
		else
		{
			CBaseEntity@ eOwner = m_hOwner.GetEntity();
			if ( eOwner is null )
				bBlowup = true;
			else if ( m_posOwner != eOwner.pev.origin )
				bBlowup = true;
			else if ( m_angleOwner != eOwner.pev.angles )
				bBlowup = true;
		}

		if ( bBlowup )
		{
			// a bit of a hack, but all CGrenade code passes pev->owner along to make sure the proper player gets credit for the kill
			// so we have to restore pev->owner from pRealOwner, because an entity's tracelines don't strike it's pev->owner which meant
			// that a player couldn't trigger his own tripmine. Now that the mine is exploding, it's safe the restore the owner so the 
			// CGrenade code knows who the explosive really belongs to.
			@self.pev.owner = @m_pRealOwner;
			self.pev.health = 0;
			CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
			Killed( pOwner.pev, GIB_NORMAL );
			return;
		}
		
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		if ( g_Engine.time < m_flPowerUp && flDamage < self.pev.health )
		{
			// disable
			SetThink( ThinkFunction( DelayRemove ) );
			self.pev.nextthink = g_Engine.time + 0.1;
			KillBeam();
			return 0;
		}
		return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}
	
	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		self.pev.takedamage = DAMAGE_NO;
		
		// some client has destroyed this mine, he'll get credit for any kills
		// ...unless called from bBlowUp
		CBaseEntity@ moveme = g_EntityFuncs.Instance( pevAttacker );
		@self.pev.owner = @moveme.edict();
		
		SetThink( ThinkFunction( DelayDeathThink ) );
		self.pev.nextthink = g_Engine.time + Math.RandomFloat( 0.1, 0.3 );
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "common/null.wav", 0.5, ATTN_NORM ); // shut off chargeup
	}
	
	void DelayDeathThink()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
		
		KillBeam();
		TraceResult tr;
		g_Utility.TraceLine( self.pev.origin + m_vecDir * 8, self.pev.origin - m_vecDir * 64, dont_ignore_monsters, self.edict(), tr );
		
		g_EntityFuncs.CreateExplosion( tr.vecEndPos, -( m_angleOwner ), pev.owner, int( pev.dmg ), false ); // Effect
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );
		
		g_EntityFuncs.Remove( pThis );
	}
	
	// I should call SUB_Remove() instead, but I don't know how to use it... -Giegue
	void DelayRemove()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.pev );
		if ( pThis !is null )
			g_EntityFuncs.Remove( pThis );
	}
}

class weapon_hltripmine : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_tripmine.mdl" );
		
		self.m_iDefaultAmmo = TRIPMINE_DEFAULT_GIVE;
		
		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/v_tripmine.mdl" );
		g_Game.PrecacheModel( "models/hl/w_tripmine.mdl" );
		g_Game.PrecacheModel( "models/hl/p_tripmine.mdl" );
		
		g_Game.PrecacheOther( "monster_hltripmine" );
		
		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hltripmine.txt" );
	}
	
	/*
	void SetObjectCollisionBox()
	{
		//!!!BUGBUG - fix the model!
		self.pev.absmin = self.pev.origin + Vector( -16, -16, -5 );
		self.pev.absmax = self.pev.origin + Vector( 16, 16, 28 ); 
	}
	*/
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= TRIPMINE_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= TRIPMINE_MAX_CLIP;
		info.iSlot 		= 4;
		info.iPosition 	= 6;
		info.iFlags 	= ( ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE );
		info.iWeight 	= TRIPMINE_WEIGHT;
		
		return true;
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
		return self.DefaultDeploy( "models/hl/v_tripmine.mdl", "models/hl/p_tripmine.mdl", TRIPMINE_DRAW, "trip" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		self.SendWeaponAnim( TRIPMINE_HOLSTER );
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
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecAiming = g_Engine.v_forward;
		
		TraceResult tr;
		
		g_Utility.TraceLine( vecSrc, vecSrc + vecAiming * 128, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		self.SendWeaponAnim( TRIPMINE_DRAW );
		
		if ( tr.flFraction < 1.0 )
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
			int bCheck = pEntity.pev.flags;
			if ( pEntity !is null && ( ( bCheck &= FL_CONVEYOR ) != FL_CONVEYOR ) )
			{
				Vector angles;
				g_EngineFuncs.VecToAngles( tr.vecPlaneNormal, angles );
				
				CBaseEntity@ pEnt = g_EntityFuncs.Create( "monster_hltripmine", tr.vecEndPos + tr.vecPlaneNormal * 8, angles, false, m_pPlayer.edict() );
				
				int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
				
				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
				
				if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
				{
					// no more mines! 
					self.RetireWeapon();
					return;
				}
			}
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}
	
	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if ( flRand <= 0.25 )
		{
			iAnim = TRIPMINE_IDLE1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 90.0 / 30.0;
		}
		else if (flRand <= 0.75)
		{
			iAnim = TRIPMINE_IDLE2;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 60.0 / 30.0;
		}
		else
		{
			iAnim = TRIPMINE_FIDGET;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 100.0 / 30.0;
		}

		self.SendWeaponAnim( iAnim );
	}
}

string GetHLTripmineName()
{
	return "weapon_hltripmine";
}

void RegisterHLTripmine()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CTripmineGrenade", "monster_hltripmine" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hltripmine", GetHLTripmineName() );
	g_ItemRegistry.RegisterWeapon( GetHLTripmineName(), "hl_weapons", "Trip Mine" );
}
