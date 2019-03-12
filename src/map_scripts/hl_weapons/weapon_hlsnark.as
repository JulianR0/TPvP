/* 
* The original Half-Life version of the snark grenade
*/

const int SNARK_DEFAULT_GIVE = 5;
const int SNARK_MAX_CARRY = 15;
const int SNARK_MAX_CLIP = WEAPON_NOCLIP;
const int SNARK_WEIGHT = 5;

const float SQUEEK_DETONATE_DELAY = 15.0;

enum w_squeak_e
{
	WSQUEAK_IDLE1 = 0,
	WSQUEAK_FIDGET,
	WSQUEAK_JUMP,
	WSQUEAK_RUN,
};

enum squeak_e
{
	SQUEAK_IDLE1 = 0,
	SQUEAK_FIDGETFIT,
	SQUEAK_FIDGETNIP,
	SQUEAK_DOWN,
	SQUEAK_UP,
	SQUEAK_THROW
};

class CSqueakGrenade : ScriptBaseMonsterEntity
{
	float m_flNextBounceSoundTime; // static float?
	
	float m_flDie;
	Vector m_vecTarget;
	float m_flNextHunt;
	float m_flNextHit;
	Vector m_posPrev;
	EHandle m_hOwner;
	int m_iMyClass;
	
	void Spawn()
	{
		Precache();
		
		// motor
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;
		
		g_EntityFuncs.SetModel( self, "models/hl/w_squeak.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, 0 ), Vector( 4, 4, 8 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		SetTouch( TouchFunction( SuperBounceTouch ) );
		SetThink( ThinkFunction( HuntThink ) );
		
		self.pev.nextthink = g_Engine.time + 0.1;
		m_flNextHunt = g_Engine.time + 1E6;
		
		self.pev.flags |= FL_MONSTER;
		self.pev.takedamage = DAMAGE_AIM;
		self.m_bloodColor = BLOOD_COLOR_YELLOW;
		self.pev.health = 2.0;
		self.pev.gravity = 0.5;
		self.pev.friction = 0.5;
		
		self.pev.dmg = 5;
		
		m_flDie = g_Engine.time + SQUEEK_DETONATE_DELAY;

		self.m_flFieldOfView = 0; // 180 degrees
		
		if ( !FNullEnt( self.pev.owner ) )
			m_hOwner = g_EntityFuncs.Instance( self.pev.owner );
		
		m_flNextBounceSoundTime = g_Engine.time; // reset each time a snark is spawned.
		
		self.pev.sequence = WSQUEAK_RUN;
		self.ResetSequenceInfo();
		
		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Snark" );
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/w_squeak.mdl" );
		
		g_SoundSystem.PrecacheSound( "squeek/sqk_blast1.wav" );
		g_SoundSystem.PrecacheSound( "squeek/sqk_die1.wav" );
		g_SoundSystem.PrecacheSound( "squeek/sqk_hunt1.wav" );
		g_SoundSystem.PrecacheSound( "squeek/sqk_hunt2.wav" );
		g_SoundSystem.PrecacheSound( "squeek/sqk_hunt3.wav" );
		g_SoundSystem.PrecacheSound( "squeek/sqk_deploy1.wav" );
		
		g_SoundSystem.PrecacheSound( "common/bodysplat.wav" );
	}
	
	// NOT ORIGINAL - Edited by Giegue for Team Deathmatch play
	int Classify()
	{
		if ( m_iMyClass != 0 )
			return m_iMyClass; // protect against recursion
		
		CBaseEntity@ eEnemy = self.m_hEnemy;
		CBaseEntity@ eOwner = m_hOwner.GetEntity();
		if ( eEnemy !is null )
		{
			m_iMyClass = CLASS_INSECT; // no one cares about it
			switch( eEnemy.Classify() )
			{
				case CLASS_ALIEN_MILITARY: // Crimson
				{
					if ( eOwner !is null )
					{
						if ( eOwner.Classify() == CLASS_HUMAN_MILITARY )
							return CLASS_HUMAN_MILITARY; // Snark is evil against opposite team
						
						return CLASS_ALIEN_MILITARY; // Snark is friendly against other teammates
					}
					
					return CLASS_PLAYER; // No owner, attack everyone
				}
				case CLASS_HUMAN_MILITARY: // Spiral
				{
					if ( eOwner !is null )
					{
						if ( eOwner.Classify() == CLASS_ALIEN_MILITARY )
							return CLASS_ALIEN_MILITARY; // Snark is evil against opposite team
						
						return CLASS_HUMAN_MILITARY; // Snark is friendly against other teammates
					}
					
					return CLASS_PLAYER; // No owner, attack everyone
				}
			}
			m_iMyClass = 0;
		}
		
		if ( eOwner !is null )
		{
			if ( eOwner.Classify() == CLASS_ALIEN_MILITARY )
				return CLASS_ALIEN_MILITARY;
			if ( eOwner.Classify() == CLASS_HUMAN_MILITARY )
				return CLASS_HUMAN_MILITARY;
		}
		
		return CLASS_PLAYER;
	}
	
	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
		
		//pev.model = 0; // make invisible
		//pThis.SUB_Remove();
		SetTouch( TouchFunction( dummytouch ) );
		pev.nextthink = g_Engine.time + 0.1;
		
		// since squeak grenades never leave a body behind, clear out their takedamage now.
		// Squeaks do a bit of radius damage when they pop, and that radius damage will
		// continue to call this function unless we acknowledge the Squeak's death now. (sjb)
		pev.takedamage = DAMAGE_NO;
		
		// play squeek blast
		g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_ITEM, "squeek/sqk_blast1.wav", 1, 0.5, 0, PITCH_NORM );
		
		CSoundEnt@ soundEnt = GetSoundEntInstance();
		soundEnt.InsertSound( bits_SOUND_COMBAT, pev.origin, SMALL_EXPLOSION_VOLUME, 3.0, pOwner );
		
		g_Utility.BloodDrips( pev.origin, g_vecZero, pThis.BloodColor(), 80 );
		
		if ( m_hOwner )
		{
			CBaseEntity@ eOwner = m_hOwner;
			if ( eOwner !is null )
				g_WeaponFuncs.RadiusDamage( pev.origin, pev, eOwner.pev, pev.dmg, 40.0, CLASS_NONE, DMG_BLAST );
			else
				g_WeaponFuncs.RadiusDamage( pev.origin, pev, pev, pev.dmg, 40.0, CLASS_NONE, DMG_BLAST );
		}
		
		// reset owner so death message happens
		CBaseEntity@ eOwner = m_hOwner;
		if ( eOwner !is null )
			@pev.owner = @eOwner.edict();
		
		//Killed( pevAttacker, GIB_ALWAYS );
		g_EntityFuncs.Remove( pThis );
	}
	
	void GibMonster()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_VOICE, "common/bodysplat.wav", 0.75, ATTN_NORM, 0, 200 );
	}
	
	void HuntThink()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
		CBaseEntity@ eEnemy = self.m_hEnemy;
		
		if ( !pThis.IsInWorld() )
		{
			SetTouch( TouchFunction( dummytouch ) );
			g_EntityFuncs.Remove( pThis );
			return;
		}
		
		pev.nextthink = g_Engine.time + 0.1;

		// explode when ready
		if ( g_Engine.time >= m_flDie )
		{
			Vector g_vecAttackDir = pev.velocity.Normalize();
			pev.health = -1;
			Killed( pev, 0 );
			return;
		}
		
		// float
		if ( pev.waterlevel != 0 )
		{
			if ( pev.movetype == MOVETYPE_BOUNCE )
			{
				pev.movetype = MOVETYPE_FLY;
			}
			pev.velocity = pev.velocity * 0.9;
			pev.velocity.z += 8.0;
		}
		else if ( pev.movetype == MOVETYPE_FLY )
		{
			pev.movetype = MOVETYPE_BOUNCE;
		}
		
		// return if not time to hunt
		if ( m_flNextHunt > g_Engine.time )
			return;

		m_flNextHunt = g_Engine.time + 2.0;
		
		Vector vecDir;
		TraceResult tr;
		
		Vector vecFlat = pev.velocity;
		vecFlat.z = 0;
		vecFlat = vecFlat.Normalize();

		g_EngineFuncs.MakeVectors( pev.angles );
		
		if ( eEnemy is null || !eEnemy.IsAlive() )
		{
			// find target, bounce a bit towards it.
			self.Look( 512 );
			self.m_hEnemy = BestVisibleEnemy();
		}
		
		// squeek if it's about time blow up
		if ( ( m_flDie - g_Engine.time <= 0.5 ) && ( m_flDie - g_Engine.time >= 0.3 ) )
		{
			g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_VOICE, "squeek/sqk_die1.wav", 1, ATTN_NORM, 0, 100 + Math.RandomLong( 0, 0x3F ) );
			
			CSoundEnt@ soundEnt = GetSoundEntInstance();
			soundEnt.InsertSound( bits_SOUND_COMBAT, pev.origin, 256, 0.25, pOwner );
		}
		
		// higher pitch as squeeker gets closer to detonation time
		float flpitch = 155.0 - 60.0 * ( ( m_flDie - g_Engine.time ) / SQUEEK_DETONATE_DELAY );
		
		if ( flpitch < 80 )
			flpitch = 80;
		
		if ( eEnemy !is null )
		{
			if ( self.FVisible( eEnemy, false ) )
			{
				vecDir = eEnemy.EyePosition() - pev.origin;
				m_vecTarget = vecDir.Normalize();
			}

			float flVel = pev.velocity.Length();
			float flAdj = 50.0 / ( flVel + 10.0 );

			if ( flAdj > 1.2 )
				flAdj = 1.2;
			
			pev.velocity = pev.velocity * flAdj + m_vecTarget * 300;
		}
		
		int bCheck = pev.flags;
		if ( ( bCheck &= FL_ONGROUND ) == FL_ONGROUND )
		{
			pev.avelocity = Vector( 0, 0, 0 );
		}
		else
		{
			if ( pev.avelocity == Vector( 0, 0, 0 ) )
			{
				pev.avelocity.x = Math.RandomFloat( -100, 100 );
				pev.avelocity.z = Math.RandomFloat( -100, 100 );
			}
		}
		
		if ( ( pev.origin - m_posPrev ).Length() < 1.0 )
		{
			pev.velocity.x = Math.RandomFloat( -100, 100 );
			pev.velocity.y = Math.RandomFloat( -100, 100 );
		}
		m_posPrev = pev.origin;
		
		g_EngineFuncs.VecToAngles( pev.velocity, pev.angles );
		pev.angles.z = 0;
		pev.angles.x = 0;
	}
	
	void SuperBounceTouch( CBaseEntity@ pOther )
	{
		float flpitch;
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
		CBaseEntity@ eOwner = m_hOwner.GetEntity();
		
		TraceResult tr = g_Utility.GetGlobalTrace();
		
		// don't hit the guy that launched this grenade
		//if ( pOwner == pOther )
		//	return;
		
		// at least until we've bounced once
		@pev.owner = @null;
		
		pev.angles.x = 0;
		pev.angles.z = 0;
		
		// avoid bouncing too much
		if ( m_flNextHit > g_Engine.time )
			return;
		
		// higher pitch as squeeker gets closer to detonation time
		flpitch = 155.0 - 60.0 * ( ( m_flDie - g_Engine.time ) / SQUEEK_DETONATE_DELAY );

		if ( pOther.pev.takedamage > 0 && self.m_flNextAttack < g_Engine.time )
		{
			// attack!
			
			// make sure it's me who has touched them
			CBaseEntity@ trace_pHit = g_EntityFuncs.Instance( tr.pHit );
			if ( trace_pHit == pOther )
			{
				// and it's not another squeakgrenade
				if ( trace_pHit.pev.modelindex != pev.modelindex )
				{
					g_WeaponFuncs.ClearMultiDamage();
					pOther.TraceAttack( pev, 10, g_Engine.v_forward, tr, DMG_SLASH ); 
					if ( eOwner !is null )
						g_WeaponFuncs.ApplyMultiDamage( pev, eOwner.pev );
					else
						g_WeaponFuncs.ApplyMultiDamage( pev, pev );
					
					pev.dmg += 5; // add more explosion damage
					
					// make bite sound
					g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_WEAPON, "squeek/sqk_deploy1.wav", 1.0, ATTN_NORM, 0, int( flpitch ) );
					self.m_flNextAttack = g_Engine.time + 0.5;
				}
			}
			else
			{
				// Nothing
			}
		}

		m_flNextHit = g_Engine.time + 0.1;
		m_flNextHunt = g_Engine.time;

		// in multiplayer, we limit how often snarks can make their bounce sounds to prevent overflows.
		if ( g_Engine.time < m_flNextBounceSoundTime )
		{
			// too soon!
			return;
		}
		
		CSoundEnt@ soundEnt = GetSoundEntInstance();
		
		int bCheck = pev.flags;
		if ( ( bCheck &= FL_ONGROUND ) != FL_ONGROUND )
		{
			// play bounce sound
			float flRndSound = Math.RandomFloat( 0, 1 );
			
			if ( flRndSound <= 0.33 )
				g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_VOICE, "squeek/sqk_hunt1.wav", 1, ATTN_NORM, 0, int( flpitch ) );
			else if (flRndSound <= 0.66)
				g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_VOICE, "squeek/sqk_hunt2.wav", 1, ATTN_NORM, 0, int( flpitch ) );
			else 
				g_SoundSystem.EmitSoundDyn( pThis.edict(), CHAN_VOICE, "squeek/sqk_hunt3.wav", 1, ATTN_NORM, 0, int( flpitch ) );
			soundEnt.InsertSound( bits_SOUND_COMBAT, pev.origin, 256, 0.25, pOwner );
		}
		else
		{
			// skittering sound
			soundEnt.InsertSound( bits_SOUND_COMBAT, pev.origin, 100, 0.1, pOwner );
		}
		
		m_flNextBounceSoundTime = g_Engine.time + 0.5;// half second.
	}
	
	// AngelScript's BestVisibleEnemy() does not work.
	// Workaround by Nero, Solokiller and Maestro Fenix.
	CBaseEntity@ BestVisibleEnemy()
	{
		CBaseEntity@ pReturn = null;
		
		//Seeks all possible enemies near
		while( ( @pReturn = g_EntityFuncs.FindEntityInSphere( pReturn, self.pev.origin, 500.0, "*", "classname" ) ) !is null )
		{
			//Is hostile to us and still alive? Then add consider it as target   
			if( self.IRelationship( pReturn ) > ( R_NO ) && pReturn.IsAlive() )
				return pReturn;

		}
		return pReturn;
	}
	
	void dummytouch( CBaseEntity@ pOther )
	{
		// Dummy
	}
}

class weapon_hlsnark : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_fJustThrown;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_sqknest.mdl" );
		
		self.m_iDefaultAmmo = SNARK_DEFAULT_GIVE;

		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{	
		g_Game.PrecacheModel( "models/hl/w_sqknest.mdl" );
		g_Game.PrecacheModel( "models/hl/v_squeak.mdl" );
		g_Game.PrecacheModel( "models/hl/p_squeak.mdl" );
		
		g_SoundSystem.PrecacheSound( "squeek/sqk_hunt2.wav" );
		g_SoundSystem.PrecacheSound( "squeek/sqk_hunt3.wav" );
		
		g_Game.PrecacheOther( "monster_hlsnark" );
		
		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hlsnark.txt" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= SNARK_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= SNARK_MAX_CLIP;
		info.iSlot 		= 4;
		info.iPosition 	= 7;
		info.iFlags 	= ( ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE );
		info.iWeight 	= SNARK_WEIGHT;
		
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
		// play hunt sound
		float flRndSound = Math.RandomFloat( 0, 1 );
		
		if ( flRndSound <= 0.5 )
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "squeek/sqk_hunt2.wav", 1, ATTN_NORM, 0, 100 );
		else 
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "squeek/sqk_hunt3.wav", 1, ATTN_NORM, 0, 100 );
		
		m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
		
		return self.DefaultDeploy( "models/hl/v_squeak.mdl", "models/hl/p_squeak.mdl", SQUEAK_UP, "squeak" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		self.SendWeaponAnim( SQUEAK_DOWN );
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
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
			TraceResult tr;
			Vector trace_origin;

			// HACK HACK:  Ugly hacks to handle change in origin based on new physics code for players
			// Move origin up if crouched and start trace a bit outside of body ( 20 units instead of 16 )
			trace_origin = m_pPlayer.pev.origin;
			
			int bCheck = m_pPlayer.pev.flags;
			if ( ( bCheck &= FL_DUCKING ) == FL_DUCKING )
			{
				trace_origin = trace_origin - ( VEC_HULL_MIN - VEC_DUCK_HULL_MIN );
			}
			
			// find place to toss monster
			g_Utility.TraceLine( trace_origin + g_Engine.v_forward * 20, trace_origin + g_Engine.v_forward * 64, dont_ignore_monsters, null, tr );
			
			if ( tr.fAllSolid == 0 && tr.fStartSolid == 0 && tr.flFraction > 0.25 )
			{
				// player "shoot" animation
				self.SendWeaponAnim( SQUEAK_THROW );
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
				
				CBaseEntity@ pSqueak = g_EntityFuncs.Create( "monster_hlsnark", tr.vecEndPos, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
				pSqueak.pev.velocity = g_Engine.v_forward * 200 + m_pPlayer.pev.velocity;
				
				// play hunt sound
				float flRndSound = Math.RandomFloat( 0, 1 );
				
				if ( flRndSound <= 0.5 )
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "squeek/sqk_hunt2.wav", 1, ATTN_NORM, 0, 105 );
				else 
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "squeek/sqk_hunt3.wav", 1, ATTN_NORM, 0, 105 );

				m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
				
				int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
				
				m_fJustThrown = 1;
				
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
			}
		}
	}
	
	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if ( m_fJustThrown == 1 )
		{
			m_fJustThrown = 0;

			if ( m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex() ) == 0 )
			{
				self.RetireWeapon();
				return;
			}

			self.SendWeaponAnim( SQUEAK_UP );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			return;
		}
		
		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if ( flRand <= 0.75 )
		{
			iAnim = SQUEAK_IDLE1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 30.0 / 16 * ( 2 );
		}
		else if ( flRand <= 0.875 )
		{
			iAnim = SQUEAK_FIDGETFIT;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 70.0 / 16.0;
		}
		else
		{
			iAnim = SQUEAK_FIDGETNIP;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 80.0 / 16.0;
		}
		self.SendWeaponAnim( iAnim );
	}
}

string GetHLSnarkName()
{
	return "weapon_hlsnark";
}

void RegisterHLSnark()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CSqueakGrenade", "monster_hlsnark" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlsnark", GetHLSnarkName() );
	g_ItemRegistry.RegisterWeapon( GetHLSnarkName(), "hl_weapons", "Snarks" );
}
