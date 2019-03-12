/*
* DeathMatch Classic: Utility Functions
*/

// Spawnflag for ammo_ entities
const int SF_BIG_AMMOBOX = 1;

// Quake Bullet firing
void Q_FireBullets( CBasePlayerWeapon@ pWeapon, CBasePlayer@ pPlayer, int& in iShots, Vector& in vecDir, Vector& in vecSpread )
{
	TraceResult trace;
	g_EngineFuncs.MakeVectors( pPlayer.pev.v_angle );
	
	Vector vecSrc = pPlayer.GetGunPosition() + ( g_Engine.v_forward * 10 );
	//vecSrc.z = pPlayer.pev.absmin.z + ( pPlayer.pev.size.z * 0.7 );
	g_WeaponFuncs.ClearMultiDamage();
	
	while ( iShots > 0 )
	{
		Vector vecPath = vecDir + ( Math.RandomFloat( -1, 1 ) * vecSpread.x * g_Engine.v_right ) + ( Math.RandomFloat( -1, 1 ) * vecSpread.y * g_Engine.v_up );
		Vector vecEnd = vecSrc + ( vecPath * 2048 );
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), trace );
		if ( trace.flFraction != 1.0 )
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( trace.pHit );
			if ( pEntity !is null && pEntity.pev.takedamage > 0 && pEntity.IsPlayer() )
			{
				pEntity.TraceAttack( pPlayer.pev, 4, vecPath, trace, DMG_BULLET );
				g_WeaponFuncs.AddMultiDamage( pPlayer.pev, pEntity, 4, DMG_BULLET );
			}
			else if ( pEntity !is null && pEntity.pev.takedamage > 0 )
			{
				pEntity.TakeDamage( pWeapon.pev, pPlayer.pev, 4, DMG_BULLET );
			}
			g_WeaponFuncs.DecalGunshot( trace, BULLET_PLAYER_BUCKSHOT );
		}
		
		iShots--;
	}
	
	g_WeaponFuncs.ApplyMultiDamage( pPlayer.pev, pPlayer.pev );
}

// Quake radius damage
// Modified to it only hurts "visible" entities. -Giegue
void Q_RadiusDamage( CBaseEntity@ pInflictor, CBaseEntity@ pAttacker, float& in flDamage, CBaseEntity@ pIgnore )
{
	CBaseEntity@ pEnt = null;
	
	TraceResult tr;
	
	Vector vecSrc = pInflictor.pev.origin;
	//vecSrc.z += 1; // in case grenade is lying on the ground
	
	while ( ( @pEnt = g_EntityFuncs.FindEntityInSphere( pEnt, vecSrc, flDamage+40, "*", "classname" ) ) !is null )
	{
		if ( pEnt != pIgnore )
		{
			if ( pEnt.pev.takedamage > 0 )
			{
				// blast's don't travel into or out of water
				if ( g_EngineFuncs.PointContents( vecSrc ) == CONTENTS_WATER && pEnt.pev.waterlevel == 0 )
					continue;
				if ( g_EngineFuncs.PointContents( vecSrc ) != CONTENTS_WATER && pEnt.pev.waterlevel == 3 )
					continue;
				
				Vector vecOrg = pEnt.pev.origin + ( ( pEnt.pev.mins + pEnt.pev.maxs ) * 0.5 );
				
				g_Utility.TraceLine( vecSrc, vecOrg, dont_ignore_monsters, pAttacker.edict(), tr );
				
				if ( tr.flFraction == 1.0 || tr.pHit is pEnt.edict() )
				{
					// the explosion can 'see' this entity, so hurt them!
					float flPoints = 0.5 * ( pInflictor.pev.origin - vecOrg ).Length();
					if ( flPoints < 0 )
						flPoints = 0;
					flPoints = flDamage - flPoints;
					
					if ( pEnt == pAttacker )
						flPoints = flPoints * 0.5;
					if ( flPoints > 0 )
					{
						pEnt.TakeDamage( pInflictor.pev, pAttacker.pev, flPoints, DMG_GENERIC );
					}
				}
			}
		}
	}
}

// Lightning hit a target
void LightningHit( CBaseEntity@ pTarget, CBaseEntity@ pAttacker, Vector& in vecHitPos, float& in flDamage, TraceResult ptr, Vector& in vecDir ) 
{
	g_WeaponFuncs.SpawnBlood( vecHitPos, BLOOD_COLOR_RED, flDamage * 1.5 );
	
	pTarget.TakeDamage( pAttacker.pev, pAttacker.pev, flDamage, DMG_GENERIC );
	
	if ( pTarget.IsPlayer() )
		pTarget.TraceBleed( flDamage, vecDir, ptr, DMG_BULLET ); // have to use DMG_BULLET or it wont spawn.
}

// Lightning Damage
void LightningDamage( Vector& in p1, Vector& in p2, CBaseEntity@ pAttacker, float flDamage, Vector& in vecDir )
{
	TraceResult trace;
	Vector vecThru = ( p2 - p1 ).Normalize();
	vecThru.x = 0 - vecThru.y;
	vecThru.y = vecThru.x;
	vecThru.z = 0;
	vecThru = vecThru * 16;
	
	CBaseEntity@ pEntity1 = null;
	CBaseEntity@ pEntity2 = null;
	
	// Hit first target?
	g_Utility.TraceLine( p1, p2, dont_ignore_monsters, pAttacker.edict(), trace );
	CBaseEntity@ pEntity = g_EntityFuncs.Instance( trace.pHit );
	if ( pEntity !is null && pEntity.pev.takedamage > 0 )
	{
		LightningHit( pEntity, pAttacker, trace.vecEndPos, flDamage, trace, vecDir );
	}
	@pEntity1 = @pEntity;
	
	// Hit second target?
	g_Utility.TraceLine( p1 + vecThru, p2 + vecThru, dont_ignore_monsters, pAttacker.edict(), trace );
	@pEntity = g_EntityFuncs.Instance( trace.pHit );
	if ( pEntity !is null && pEntity !is pEntity1 && pEntity.pev.takedamage > 0 )
	{
		LightningHit( pEntity, pAttacker, trace.vecEndPos, flDamage, trace, vecDir );
	}
	@pEntity2 = @pEntity;
	
	// Hit third target?
	g_Utility.TraceLine( p1 - vecThru, p2 - vecThru, dont_ignore_monsters, pAttacker.edict(), trace );
	@pEntity = g_EntityFuncs.Instance( trace.pHit );
	if ( pEntity !is null && pEntity !is pEntity1 && pEntity !is pEntity2 && pEntity.pev.takedamage > 0 )
	{
		LightningHit( pEntity, pAttacker, trace.vecEndPos, flDamage, trace, vecDir );
	}
}

/* NAIL ENTITY - START */
class CQuakeNail : ScriptBaseEntity
{
	void Spawn()
	{
		Precache();
		
		// Setup
		self.pev.movetype = MOVETYPE_FLYMISSILE;
		self.pev.solid = SOLID_BBOX;
		
		// Safety removal
		self.pev.nextthink = g_Engine.time + 6;
		SetThink( ThinkFunction( DelayRemove ) );
		
		// Touch
		SetTouch( TouchFunction( NailTouch ) );
		
		// Model
		g_EntityFuncs.SetModel( self, "models/dmc/spike.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		// Damage
		self.pev.dmg = 18;
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/spike.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/dmc/tink1.wav" ); // spike tink
		
		g_Game.PrecacheGeneric( "sound/weapons/dmc/tink1.wav" );
	}
	
	void NailTouch( CBaseEntity@ pOther )
	{
		if ( pOther.pev.solid == SOLID_TRIGGER )
			return;
		
		// Remove if we've hit skybrush
		if ( g_EngineFuncs.PointContents( pev.origin ) == CONTENTS_SKY )
		{
			DelayRemove();
			return;
		}
		
		// Hit something that bleeds
		if ( pOther.pev.takedamage > 0 )
		{
			CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
			
			if ( pOther.IsPlayer() )
				g_WeaponFuncs.SpawnBlood( self.pev.origin, BLOOD_COLOR_RED, self.pev.dmg );
			
			pOther.TakeDamage( self.pev, pOwner.pev, self.pev.dmg, DMG_GENERIC );
			DelayRemove(); // Remove now.
		}
		else
		{
			if ( pOther.pev.solid == SOLID_BSP || pOther.pev.movetype == MOVETYPE_PUSHSTEP )
			{
				TraceResult tr;
				tr.vecEndPos = self.pev.origin;
				@tr.pHit = @pOther.edict();
				
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "weapons/dmc/tink1.wav", 1.0, ATTN_NORM );
				g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				self.pev.nextthink = g_Engine.time + 0.1; // stick around long enough for the sound to finish!
				SetThink( ThinkFunction( DelayRemove ) );
			}
		}
	}
	
	// I should call SUB_Remove() instead, but I don't know how to use it... -Giegue
	void DelayRemove()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.pev );
		if ( pThis !is null )
			g_EntityFuncs.Remove( pThis );
	}
}

CQuakeNail@ CreateNail( Vector& in vecOrigin, Vector& in vecAngles, CBasePlayer@ pOwner )
{
	CBaseEntity@ pre_pNail = g_EntityFuncs.CreateEntity( "dmcnail", null, false );
	CQuakeNail@ pNail = cast<CQuakeNail@>(CastToScriptClass(pre_pNail));
	
	g_EntityFuncs.SetOrigin( pNail.self, vecOrigin );
	
	pNail.pev.velocity = vecAngles * 1000;
	g_EngineFuncs.VecToAngles( vecAngles, pNail.pev.angles );
	@pNail.pev.owner = @pOwner.edict();
	pNail.Spawn();
	
	return pNail;
}

CQuakeNail@ CreateSuperNail( Vector& in vecOrigin, Vector& in vecAngles, CBasePlayer@ pOwner )
{
	CQuakeNail@ pNail = CreateNail( vecOrigin, vecAngles, pOwner );
	
	// Super nails simply do more damage
	pNail.pev.dmg = 36;
	return pNail;
}

void RegisterNailEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CQuakeNail", "dmcnail" );
}
/* NAIL ENTITY - END */

/* GRENADE/ROCKET ENTITY - START */
class CQuakeRocket : ScriptBaseEntity
{
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetSize( self.pev, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/dmc/rocket_v3.mdl" );
		g_Game.PrecacheModel( "models/dmc/grenade_v3.mdl" );
	}
	
	void RocketTouch( CBaseEntity@ pOther )
	{
		// Remove if we've hit skybrush
		if ( g_EngineFuncs.PointContents( pev.origin ) == CONTENTS_SKY )
		{
			DelayRemove();
			return;
		}
		
		// Do touch damage
		float flDmg = Math.RandomFloat( 100, 120 );
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
		if ( pOther.pev.health > 0 )
		{
			// If player, mark
			if ( pOther.IsPlayer() )
			{
				if ( !pOther.pev.FlagBitSet( FL_ONGROUND ) )
				{
					pOther.pev.target = "AERIAL_HIT";
					g_Scheduler.SetTimeout( "ResetAerial", 0.2, pOther.entindex() );
				}
			}
			pOther.TakeDamage( self.pev, pOwner.pev, flDmg, DMG_BULLET );
		}
		
		// Don't do radius damage to the other, because all the damage was done in the impact
		Q_RadiusDamage( self, pOwner, 120, pOther ); // Here too. -Giegue
		
		// Finish and remove
		Explode();
	}
	
	void GrenadeTouch( CBaseEntity@ pOther )
	{
		if ( pOther.pev.takedamage == DAMAGE_AIM )
		{
			// If player, mark
			if ( pOther.IsPlayer() )
			{
				if ( !pOther.pev.FlagBitSet( FL_ONGROUND ) )
				{
					pOther.pev.target = "AERIAL_HIT";
					g_Scheduler.SetTimeout( "ResetAerial", 0.2, pOther.entindex() );
				}
			}
			
			GrenadeExplode();
			return;
		}
		
		int bCheck = self.pev.flags;
		if ( ( bCheck &= FL_ONGROUND ) == FL_ONGROUND )
		{
			// add a bit of static friction
			self.pev.velocity = self.pev.velocity * 0.75;
			
			if ( self.pev.velocity.Length() <= 20 )
			{
				self.pev.avelocity = g_vecZero;
			}
		}
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "weapons/dmc/bounce.wav", 1.0, ATTN_NORM );
		
		if ( self.pev.velocity == g_vecZero )
			self.pev.avelocity = g_vecZero;
	}
	
	void GrenadeExplode()
	{
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
		
		Q_RadiusDamage( self, pOwner, 120, null );
		
		// Finish and remove
		Explode();
	}
	
	void Explode()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.pev );
		
		g_EntityFuncs.CreateExplosion( self.pev.origin, self.pev.angles, null, 120, false ); // Don't do damage
		g_EntityFuncs.Remove( pThis );
	}
	
	// I should call SUB_Remove() instead, but I don't know how to use it... -Giegue
	void DelayRemove()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.pev );
		if ( pThis !is null )
			g_EntityFuncs.Remove( pThis );
	}
	
	void rSetTouch()
	{
		SetTouch( TouchFunction( RocketTouch ) );
	}
	
	void rSetThink()
	{
		SetThink( ThinkFunction( DelayRemove ) );
	}
	
	void gSetTouch()
	{
		SetTouch( TouchFunction( GrenadeTouch ) );
	}
	
	void gSetThink()
	{
		SetThink( ThinkFunction( GrenadeExplode ) );
	}
}

CQuakeRocket@ CreateRocket( Vector& in vecOrigin, Vector& in vecAngles, CBasePlayer@ pOwner )
{
	CBaseEntity@ pre_pRocket = g_EntityFuncs.CreateEntity( "dmcrocket", null, false );
	CQuakeRocket@ pRocket = cast<CQuakeRocket@>(CastToScriptClass(pre_pRocket));
	
	g_EntityFuncs.SetOrigin( pRocket.self, vecOrigin );
	
	g_EntityFuncs.SetModel( pRocket.self, "models/dmc/rocket_v3.mdl" );
	pRocket.Spawn();
	@pRocket.pev.owner = @pOwner.edict();
	
	// Setup
	pRocket.pev.movetype = MOVETYPE_FLYMISSILE;
	pRocket.pev.solid = SOLID_BBOX;
	
	// Velocity
	pRocket.pev.velocity = vecAngles * 1000;
	g_EngineFuncs.VecToAngles( vecAngles, pRocket.pev.angles );
	
	// Touch
	pRocket.rSetTouch();
	
	// Safety Remove
	pRocket.pev.nextthink = g_Engine.time + 5;
	pRocket.rSetThink();
	
	return pRocket;
} 

CQuakeRocket@ CreateGrenade( Vector& in vecOrigin, Vector& in vecVelocity, CBasePlayer@ pOwner )
{
	CBaseEntity@ pre_pRocket = g_EntityFuncs.CreateEntity( "dmcrocket", null, false );
	CQuakeRocket@ pRocket = cast<CQuakeRocket@>(CastToScriptClass(pre_pRocket));

	g_EntityFuncs.SetOrigin( pRocket.self, vecOrigin );
	
	g_EntityFuncs.SetModel( pRocket.self, "models/dmc/grenade_v3.mdl" );
	pRocket.Spawn();
	@pRocket.pev.owner = @pOwner.edict();
	
	// Setup
	pRocket.pev.movetype = MOVETYPE_BOUNCE;
	pRocket.pev.solid = SOLID_BBOX;
	
	pRocket.pev.avelocity = Vector( 300, 300, 300 );
	
	// Velocity
	pRocket.pev.velocity = vecVelocity;
	g_EngineFuncs.VecToAngles( vecVelocity, pRocket.pev.angles );
	pRocket.pev.friction = 0.5;
	
	// Touch
	pRocket.gSetTouch();
	
	pRocket.pev.nextthink = g_Engine.time + 2.5;
	pRocket.gSetThink();
	
	return pRocket;
}

void RegisterRocketEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CQuakeRocket", "dmcrocket" );
}
/* GRENADE/ROCKET ENTITY - END */

// Experimental
void ResetAerial( const int& in index )
{
	CBaseEntity@ pPlayer = g_EntityFuncs.Instance( index );
	if ( pPlayer !is null )
		pPlayer.pev.target = "";
}
