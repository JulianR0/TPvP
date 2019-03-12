/* 
* The original Half-Life version of the hornet gun
*/

const int HORNETGUN_DEFAULT_GIVE = 8;
const int HORNETGUN_MAX_CARRY = 8;
const int HORNETGUN_MAX_CLIP = WEAPON_NOCLIP;
const int HORNETGUN_WEIGHT = 10;

const int HORNET_TYPE_RED = 0;
const int HORNET_TYPE_ORANGE = 1;
const float HORNET_RED_SPEED = 600.0;
const float HORNET_ORANGE_SPEED = 800.0;
const float HORNET_BUZZ_VOLUME = 0.8;

enum hgun_e
{
	HGUN_IDLE1 = 0,
	HGUN_FIDGETSWAY,
	HGUN_FIDGETSHAKE,
	HGUN_DOWN,
	HGUN_UP,
	HGUN_SHOOT
};

enum firemode_e
{
	FIREMODE_TRACK = 0,
	FIREMODE_FAST
};

class CHornet : ScriptBaseMonsterEntity
{
	int iHornetTrail;
	int iHornetPuff;
	
	float m_flStopAttack;
	int m_iHornetType;
	float m_flFlySpeed;
	
	void Spawn()
	{
		Precache();
		
		self.pev.movetype = MOVETYPE_FLY;
		self.pev.solid = SOLID_BBOX;
		self.pev.takedamage = DAMAGE_YES;
		self.pev.flags |= FL_MONSTER;
		self.pev.health = 1; // weak!
		
		// hornets don't live as long in multiplayer
		m_flStopAttack = g_Engine.time + 3.5;
		
		self.m_flFieldOfView = 0.9; // +/- 25 degrees

		if ( Math.RandomLong( 1, 5 ) <= 2 )
		{
			m_iHornetType = HORNET_TYPE_RED;
			m_flFlySpeed = HORNET_RED_SPEED;
		}
		else
		{
			m_iHornetType = HORNET_TYPE_ORANGE;
			m_flFlySpeed = HORNET_ORANGE_SPEED;
		}
		
		g_EntityFuncs.SetModel( self, "models/hornet.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) );
		
		SetTouch( TouchFunction( DieTouch ) );
		SetThink( ThinkFunction( StartTrack ) );
		
		edict_t@ pSoundEnt = @pev.owner;
		if ( !FNullEnt( pSoundEnt ) )
			@pSoundEnt = @self.edict();

		self.pev.dmg = 10;
		
		self.pev.nextthink = g_Engine.time + 0.1;
		self.ResetSequenceInfo();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hornet.mdl" );
		
		g_SoundSystem.PrecacheSound( "agrunt/ag_fire1.wav" );
		g_SoundSystem.PrecacheSound( "agrunt/ag_fire2.wav" );
		g_SoundSystem.PrecacheSound( "agrunt/ag_fire3.wav" );
		
		g_SoundSystem.PrecacheSound( "hornet/ag_buzz1.wav" );
		g_SoundSystem.PrecacheSound( "hornet/ag_buzz2.wav" );
		g_SoundSystem.PrecacheSound( "hornet/ag_buzz3.wav" );
		
		g_SoundSystem.PrecacheSound( "hornet/ag_hornethit1.wav" );
		g_SoundSystem.PrecacheSound( "hornet/ag_hornethit2.wav" );
		g_SoundSystem.PrecacheSound( "hornet/ag_hornethit3.wav" );
		
		iHornetPuff = g_Game.PrecacheModel( "sprites/muz1.spr" );
		iHornetTrail = g_Game.PrecacheModel("sprites/laserbeam.spr");
	}
	
	// NOT ORIGINAL - Edited by Giegue for Team Deathmatch play
	int Classify()
	{
		CBaseEntity@ eEnemy = self.m_hEnemy;
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
		if ( eEnemy !is null )
		{
			switch( eEnemy.Classify() )
			{
				case CLASS_ALIEN_MILITARY: // Crimson
				{
					if ( pOwner.Classify() == CLASS_HUMAN_MILITARY )
						return CLASS_HUMAN_MILITARY; // Hornet is evil against opposite team
					
					return CLASS_ALIEN_MILITARY; // Hornet is friendly against other teammates
				}
				case CLASS_HUMAN_MILITARY: // Spiral
				{
					if ( pOwner.Classify() == CLASS_ALIEN_MILITARY )
						return CLASS_ALIEN_MILITARY; // Hornet is evil against opposite team
					
					return CLASS_HUMAN_MILITARY; // Hornet is friendly against other teammates
				}
			}
		}
		
		if ( pOwner.Classify() == CLASS_ALIEN_MILITARY )
			return CLASS_ALIEN_MILITARY;
		if ( pOwner.Classify() == CLASS_HUMAN_MILITARY )
			return CLASS_HUMAN_MILITARY;
		else
			return CLASS_PLAYER;
	}
	
	// hornets will never get mad at each other, no matter who the owner is.
	int IRelationship( CBaseEntity@ pTarget )
	{
		if ( pTarget.pev.modelindex == self.pev.modelindex )
		{
			return R_NO;
		}
		
		return self.IRelationship( pTarget );
	}
	
	// don't let hornets gib, ever.
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		// filter these bits a little.
		bitsDamageType &= ~( DMG_ALWAYSGIB );
		bitsDamageType |= DMG_NEVERGIB;
		
		return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}
	
	// StartTrack - starts a hornet out tracking its target
	void StartTrack()
	{
		IgniteTrail();
		
		SetTouch( TouchFunction( TrackTouch ) );
		SetThink( ThinkFunction( TrackTarget ) );
		
		self.pev.nextthink = g_Engine.time + 0.1;
	}

	// StartDart - starts a hornet out just flying straight.
	void StartDart()
	{
		IgniteTrail();
		
		SetTouch( TouchFunction( DartTouch ) );
		
		SetThink( ThinkFunction( DelayRemove ) );
		self.pev.nextthink = g_Engine.time + 4;
	}
	
	void IgniteTrail()
	{
		uint8 r, g, b;
		
		// trail
		NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
		msg.WriteByte(  TE_BEAMFOLLOW );
		msg.WriteShort( self.entindex() ); // entity
		msg.WriteShort( iHornetTrail );	// model
		msg.WriteByte( 10 ); // life
		msg.WriteByte( 2 );  // width
		
		switch ( m_iHornetType )
		{
			case HORNET_TYPE_RED:
			{
				r = 179;
				g = 39;
				b = 14;
				
				msg.WriteByte( r ); // r, g, b
				msg.WriteByte( g ); // r, g, b
				msg.WriteByte( b ); // r, g, b
				break;
			}
			case HORNET_TYPE_ORANGE:
			{
				r = 255;
				g = 128;
				b = 0;
				
				msg.WriteByte( r ); // r, g, b
				msg.WriteByte( g ); // r, g, b
				msg.WriteByte( b ); // r, g, b
				break;
			}
		}
		
		uint8 iBrightness;
		iBrightness = 128;
		
		msg.WriteByte( iBrightness ); // brightness
		msg.End();
	}
	
	// Hornet is flying, gently tracking target
	void TrackTarget()
	{
		Vector vecFlightDir;
		Vector vecDirToEnemy;
		float flDelta;
		
		self.StudioFrameAdvance();
		
		if ( g_Engine.time > m_flStopAttack )
		{
			SetTouch( TouchFunction( dummytouch ) );
			SetThink( ThinkFunction( DelayRemove ) );
			self.pev.nextthink = g_Engine.time + 0.1;
			return;
		}

		// UNDONE: The player pointer should come back after returning from another level
		CBaseEntity@ eEnemy = self.m_hEnemy.GetEntity();
		if ( eEnemy is null )
		{
			// enemy is dead.
			self.Look( 512 );
			self.m_hEnemy = BestVisibleEnemy();
		}
		
		if ( eEnemy !is null && self.FVisible( eEnemy, true ) )
		{
			self.m_vecEnemyLKP = eEnemy.BodyTarget( self.pev.origin );
		}
		else
		{
			self.m_vecEnemyLKP = self.m_vecEnemyLKP + self.pev.velocity * m_flFlySpeed * 0.1;
		}
		
		vecDirToEnemy = ( self.m_vecEnemyLKP - self.pev.origin ).Normalize();
		
		if ( self.pev.velocity.Length() < 0.1 )
			vecFlightDir = vecDirToEnemy;
		else 
			vecFlightDir = self.pev.velocity.Normalize();
		
		// measure how far the turn is, the wider the turn, the slow we'll go this time.
		flDelta = DotProduct( vecFlightDir, vecDirToEnemy );
		
		if ( flDelta < 0.5 )
		{
			// hafta turn wide again. play sound
			switch ( Math.RandomLong( 0, 2 ) )
			{
				case 0:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hornet/ag_buzz1.wav", HORNET_BUZZ_VOLUME, ATTN_NORM ); break;
				case 1:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hornet/ag_buzz2.wav", HORNET_BUZZ_VOLUME, ATTN_NORM ); break;
				case 2:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hornet/ag_buzz3.wav", HORNET_BUZZ_VOLUME, ATTN_NORM ); break;
			}
		}
		
		if ( flDelta <= 0 && m_iHornetType == HORNET_TYPE_RED )
		{
			// no flying backwards, but we don't want to invert this, cause we'd go fast when we have to turn REAL far.
			flDelta = 0.25;
		}
		
		self.pev.velocity = ( vecFlightDir + vecDirToEnemy ).Normalize();

		switch ( m_iHornetType )
		{
			case HORNET_TYPE_RED:
			{
				self.pev.velocity = self.pev.velocity * ( m_flFlySpeed * flDelta ); // scale the dir by the ( speed * width of turn )
				self.pev.nextthink = g_Engine.time + Math.RandomFloat( 0.1, 0.3 );
				break;
			}
			case HORNET_TYPE_ORANGE:
			{
				self.pev.velocity = self.pev.velocity * m_flFlySpeed; // do not have to slow down to turn.
				self.pev.nextthink = g_Engine.time + 0.1; // fixed think time
				break;
			}
		}
		
		g_EngineFuncs.VecToAngles( self.pev.velocity, self.pev.angles );
		
		self.pev.solid = SOLID_BBOX;
	}
	
	// Tracking Hornet hit something
	void TrackTouch( CBaseEntity@ pOther )
	{
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
		if ( pOther == pOwner || pOther.pev.modelindex == self.pev.modelindex )
		{
			// bumped into the guy that shot it.
			self.pev.solid = SOLID_NOT;
			return;
		}
		
		if ( self.IRelationship( pOther ) <= R_NO )
		{
			// hit something we don't want to hurt, so turn around.
			
			self.pev.velocity = self.pev.velocity.Normalize();
			
			self.pev.velocity.x *= -1;
			self.pev.velocity.y *= -1;
			
			self.pev.origin = self.pev.origin + self.pev.velocity * 4; // bounce the hornet off a bit.
			self.pev.velocity = self.pev.velocity * m_flFlySpeed;

			return;
		}
		
		DieTouch( pOther );
	}
	
	void DartTouch( CBaseEntity@ pOther )
	{
		DieTouch( pOther );
	}

	void DieTouch( CBaseEntity@ pOther )
	{
		if ( pOther !is null && pOther.pev.takedamage > 0 )
		{
			// do the damage
			
			switch( Math.RandomLong( 0, 2 ) )
			{
				// buzz when you plug someone
				case 0: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hornet/ag_hornethit1.wav", 1, ATTN_NORM ); break;
				case 1: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hornet/ag_hornethit2.wav", 1, ATTN_NORM ); break;
				case 2: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hornet/ag_hornethit3.wav", 1, ATTN_NORM ); break;
			}
			
			CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
			
			if ( pOwner !is null )
				pOther.TakeDamage( self.pev, pOwner.pev, self.pev.dmg, DMG_BULLET );
			else
				pOther.TakeDamage( self.pev, self.pev, self.pev.dmg, DMG_BULLET );
		}
		
		// Can't set. Reference is read-only. -Giegue
		//self.pev.modelindex = 0; // so will disappear for the 0.1 secs we wait until NEXTTHINK gets rid
		
		self.pev.effects |= EF_NODRAW; // Should be a good alternative to modelindex = 0. -Giegue
		self.pev.solid = SOLID_NOT;
		
		SetThink( ThinkFunction( DelayRemove ) );
		self.pev.nextthink = g_Engine.time + 1; // stick around long enough for the sound to finish!
	}
	
	// I should call SUB_Remove() instead, but I don't know how to use it... -Giegue
	void DelayRemove()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.pev );
		if ( pThis !is null )
			g_EntityFuncs.Remove( pThis );
	}
	
	// AngelScript's BestVisibleEnemy() does not work.
	// Workaround by Nero, Solokiller and Maestro Fenix.
	CBaseEntity@ BestVisibleEnemy()
	{
		CBaseEntity@ pReturn = null;
		
		//Seeks all possible enemies near
		while( ( @pReturn = g_EntityFuncs.FindEntityInSphere( pReturn, self.pev.origin, 512.0, "*", "classname" ) ) !is null )
		{
			//Is hostile to us and still alive? Then add consider it as target   
			if( self.IRelationship( pReturn ) > ( R_NO ) && pReturn.IsAlive() )
				return pReturn;

		}
		return pReturn;
	}
	
	void cSetThink()
	{
		SetThink( ThinkFunction( StartDart ) );
	}
	
	void dummytouch( CBaseEntity@ pOther )
	{
		// Dummy
	}
}

class weapon_hlhornet : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	float m_flNextAnimTime;
	float m_flRechargeTime;
	int m_iFirePhase;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hl/w_hgun.mdl" );
		
		self.m_iDefaultAmmo = HORNETGUN_DEFAULT_GIVE;
		m_iFirePhase = 0;

		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/v_hgun.mdl" );
		g_Game.PrecacheModel( "models/hl/w_hgun.mdl" );
		g_Game.PrecacheModel( "models/hl/p_hgun.mdl" );
		
		g_Game.PrecacheOther( "hlhornet" );
		
		g_Game.PrecacheGeneric( "sprites/hl_weapons/weapon_hlhornet.txt" );
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
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= HORNETGUN_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= HORNETGUN_MAX_CLIP;
		info.iSlot 		= 3;
		info.iPosition 	= 8;
		info.iFlags 	= ( ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_NOAUTORELOAD );
		info.iWeight 	= HORNETGUN_WEIGHT;
		
		return true;
	}
	
	bool IsUseable()
	{
		return true;
	}
	
	bool Deploy()
	{
		return self.DefaultDeploy( "models/hl/v_hgun.mdl", "models/hl/p_hgun.mdl", HGUN_UP, "hive" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
		self.SendWeaponAnim( HGUN_DOWN );
		
		//!!!HACKHACK - can't select hornetgun if it's empty! no way to get ammo for it, either.
		if ( m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex() ) == 0 )
		{
			m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex(), 1 );
		}
	}
	
	void PrimaryAttack()
	{
		Reload();
		
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			return;
		}

		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		
		CBaseEntity @pHornet = g_EntityFuncs.Create( "hlhornet", m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -12, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
		pHornet.pev.velocity = g_Engine.v_forward * 300;
		
		m_flRechargeTime = g_Engine.time + 0.5;
		
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		
		m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;
		
		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "agrunt/ag_fire1.wav", 1, ATTN_NORM ); break;
			case 1: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "agrunt/ag_fire2.wav", 1, ATTN_NORM ); break;
			case 2: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "agrunt/ag_fire3.wav", 1, ATTN_NORM ); break;
		}
		
		self.SendWeaponAnim( HGUN_SHOOT );
		
		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.25;
		
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.25;
		}
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}
	
	void SecondaryAttack()
	{
		Reload();

		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0)
		{
			return;
		}
		
		// Wouldn't be a bad idea to completely predict these, since they fly so fast...
		Vector vecSrc;
		
		g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
		
		vecSrc = m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -12;
		
		m_iFirePhase++;
		switch ( m_iFirePhase )
		{
			case 1:
			{
				vecSrc = vecSrc + g_Engine.v_up * 8;
				break;
			}
			case 2:
			{
				vecSrc = vecSrc + g_Engine.v_up * 8;
				vecSrc = vecSrc + g_Engine.v_right * 8;
				break;
			}
			case 3:
			{
				vecSrc = vecSrc + g_Engine.v_right * 8;
				break;
			}
			case 4:
			{
				vecSrc = vecSrc + g_Engine.v_up * -8;
				vecSrc = vecSrc + g_Engine.v_right * 8;
				break;
			}
			case 5:
			{
				vecSrc = vecSrc + g_Engine.v_up * -8;
				break;
			}
			case 6:
			{
				vecSrc = vecSrc + g_Engine.v_up * -8;
				vecSrc = vecSrc + g_Engine.v_right * -8;
				break;
			}
			case 7:
			{
				vecSrc = vecSrc + g_Engine.v_right * -8;
				break;
			}
			case 8:
			{
				vecSrc = vecSrc + g_Engine.v_up * 8;
				vecSrc = vecSrc + g_Engine.v_right * -8;
				m_iFirePhase = 0;
				break;
			}
		}

		CBaseEntity @pHornet = g_EntityFuncs.Create( "hlhornet", vecSrc, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
		pHornet.pev.velocity = g_Engine.v_forward * 1200;
		g_EngineFuncs.VecToAngles( pHornet.pev.velocity, pHornet.pev.angles );
		
		CHornet@ cHornet = cast< CHornet@ >( CastToScriptClass( pHornet ) );
		cHornet.cSetThink();
		
		m_flRechargeTime = g_Engine.time + 0.5;
		
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;
		
		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "agrunt/ag_fire1.wav", 1, ATTN_NORM ); break;
			case 1: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "agrunt/ag_fire2.wav", 1, ATTN_NORM ); break;
			case 2: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_VOICE, "agrunt/ag_fire3.wav", 1, ATTN_NORM ); break;
		}
		
		self.SendWeaponAnim( HGUN_SHOOT );
		
		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.1;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}
	
	void Reload()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) >= HORNETGUN_MAX_CARRY )
			return;
		
		while ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) < HORNETGUN_MAX_CARRY && m_flRechargeTime < g_Engine.time )
		{
			int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, ++iAmmo );
			m_flRechargeTime += 0.5;
		}
	}
	
	void WeaponIdle()
	{
		Reload();
		
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if ( flRand <= 0.75 )
		{
			iAnim = HGUN_IDLE1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 30.0 / 16 * ( 2 );
		}
		else if (flRand <= 0.875)
		{
			iAnim = HGUN_FIDGETSWAY;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 40.0 / 16.0;
		}
		else
		{
			iAnim = HGUN_FIDGETSHAKE;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 35.0 / 16.0;
		}
		self.SendWeaponAnim( iAnim );
	}
}

string GetHLHornetName()
{
	return "weapon_hlhornet";
}

void RegisterHLHornet()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CHornet", "hlhornet" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlhornet", GetHLHornetName() );
	g_ItemRegistry.RegisterWeapon( GetHLHornetName(), "hl_weapons", "hornet" );
}
