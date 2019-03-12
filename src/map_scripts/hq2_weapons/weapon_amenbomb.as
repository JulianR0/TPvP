/* 
* Skeleton of Death
*/

const int SKELETON_DEFAULT_GIVE = 1;
const int SKELETON_MAX_CARRY = 5;
const int SKELETON_MAX_CLIP = WEAPON_NOCLIP;
const int SKELETON_WEIGHT = -10;

enum skeleton_e
{
	SKELETON_IDLE1 = 0,
	SKELETON_FIDGET1,
	SKELETON_DRAW,
	SKELETON_DROP
};

enum skeleton_radio_e
{
	SKELETON_RADIO_IDLE1 = 0,
	SKELETON_RADIO_FIDGET1,
	SKELETON_RADIO_DRAW,
	SKELETON_RADIO_FIRE,
	SKELETON_RADIO_HOLSTER
};

class CSkeletonCharge : ScriptBaseEntity
{
	void Spawn()
	{
		Precache();
		
		// motor
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;
		
		g_EntityFuncs.SetModel( self, "models/snk_ema/hq2_phoenix/w_accelerator.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) ); // Uses point-sized, and can be stepped over
		
		SetTouch( TouchFunction( SatchelSlide ) );
		SetUse( UseFunction( DetonateUse ) );
		SetThink( ThinkFunction( SatchelThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;
		
		self.pev.gravity = 0.5;
		self.pev.friction = 0.8;
		
		self.pev.dmg = 120;
		self.pev.sequence = 1;
	}
	
	void Precache()
	{
		g_SoundSystem.PrecacheSound( "weapons/g_bounce1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce3.wav" );
	}
	
	void SatchelSlide( CBaseEntity@ pOther )
	{
		// don't hit the guy that launched this grenade
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
		if ( pOther == pOwner )
			return;
		
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		
		pev.gravity = 1; // normal gravity now
		
		// HACKHACK - on ground isn't always set, so look for ground underneath
		TraceResult tr;
		g_Utility.TraceLine( pev.origin, pev.origin - Vector( 0, 0, 10 ), ignore_monsters, pThis.edict(), tr );
		
		if ( tr.flFraction < 1.0 )
		{
			// add a bit of static friction
			pev.velocity = pev.velocity * 0.95;
			pev.avelocity = pev.avelocity * 0.9;
		}
		
		// play sliding sound, volume based on velocity
		int bCheck = pev.flags;
		if ( ( bCheck &= FL_ONGROUND ) != FL_ONGROUND && pev.velocity.Length2D() > 10 )
		{
			BounceSound();
		}
	}
	
	void DetonateUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		
		TraceResult tr;
		Vector vecSpot; // trace starts here!
		
		vecSpot = pev.origin + Vector( 0, 0, 8 );
		g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ), ignore_monsters, pThis.edict(), tr );
		
		g_EntityFuncs.CreateExplosion( tr.vecEndPos, Vector( 0, 0, -90 ), pev.owner, int( pev.dmg ), false );
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );
		
		g_EntityFuncs.Remove( pThis );
	}
	
	void SatchelThink()
	{	
		pev.nextthink = g_Engine.time + 0.1;
		
		if ( !self.IsInWorld() )
		{
			CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
			g_EntityFuncs.Remove( pThis );
			return;
		}
		
		if ( pev.waterlevel == 3 )
		{
			pev.movetype = MOVETYPE_FLY;
			pev.velocity = pev.velocity * 0.8;
			pev.avelocity = pev.avelocity * 0.9;
			pev.velocity.z += 8;
		}
		else if ( pev.waterlevel == 0 )
		{
			pev.movetype = MOVETYPE_BOUNCE;
		}
		else
		{
			pev.velocity.z -= 8;
		}
	}
	
	void BounceSound()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		
		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0:	g_SoundSystem.EmitSound( pThis.edict(), CHAN_VOICE, "weapons/g_bounce1.wav", 1, ATTN_NORM ); break;
			case 1:	g_SoundSystem.EmitSound( pThis.edict(), CHAN_VOICE, "weapons/g_bounce2.wav", 1, ATTN_NORM ); break;
			case 2:	g_SoundSystem.EmitSound( pThis.edict(), CHAN_VOICE, "weapons/g_bounce3.wav", 1, ATTN_NORM ); break;
		}
	}
	
	// do whatever it is we do to an orphaned satchel when we don't want it in the world anymore.
	void Deactivate()
	{
		pev.solid = SOLID_NOT;
		
		CBaseEntity@ pThis = g_EntityFuncs.Instance( pev );
		g_EntityFuncs.Remove( pThis );
	}
}

class weapon_amenbomb : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/snk_ema/hq2_phoenix/w_accelerator.mdl" );
		
		self.m_iDefaultAmmo = SKELETON_DEFAULT_GIVE;

		self.FallInit(); // get ready to fall down.
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/hl/v_satchel.mdl" );
		g_Game.PrecacheModel( "models/snk_ema/hq2_phoenix/w_accelerator.mdl" ); // kek
		g_Game.PrecacheModel( "models/hl/p_satchel.mdl" );
		
		g_Game.PrecacheModel( "models/hl/v_satchel_radio.mdl" );
		g_Game.PrecacheModel( "models/hl/p_satchel_radio.mdl" );
		
		g_Game.PrecacheOther( "monster_amenbomb" );
		
		g_Game.PrecacheGeneric( "sprites/hq2_weapons/weapon_amenbomb.txt" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}
	
	// CALLED THROUGH the newly-touched weapon's instance. The existing player weapon is pOriginal
	bool AddDuplicate( CBasePlayerItem@ pOriginal )
	{
		weapon_amenbomb@ pSatchel = cast<weapon_amenbomb@>(CastToScriptClass(pOriginal));
		
		if ( pSatchel.pev.iuser1 != 0 )
		{
			// player has some satchels deployed. Refuse to add more.
			return false;
		}
		
		return BaseClass.AddDuplicate( pOriginal );
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		bool bResult = BaseClass.AddToPlayer( pPlayer );
		
		self.pev.iuser1 = 0; // this satchel charge weapon now forgets that any satchels are deployed by it.
		
		if ( bResult )
		{
			@m_pPlayer = pPlayer;
			return self.AddWeapon();
		}
		
		return false;
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= SKELETON_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= SKELETON_MAX_CLIP;
		info.iSlot 		= 4;
		info.iPosition 	= 5;
		info.iFlags 	= ( ITEM_FLAG_SELECTONEMPTY | ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE );
		info.iWeight 	= SKELETON_WEIGHT;
		
		return true;
	}
	
	bool IsUseable()
	{
		if ( m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex() ) > 0 ) 
		{
			// player is carrying some satchels
			return true;
		}

		if ( self.pev.iuser1 != 0 )
		{
			// player isn't carrying any satchels, but has some out
			return true;
		}

		return false;
	}
	
	bool CanDeploy()
	{
		if ( m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex() ) > 0 ) 
		{
			// player is carrying some satchels
			return true;
		}

		if ( self.pev.iuser1 != 0 )
		{
			// player isn't carrying any satchels, but has some out
			return true;
		}

		return false;
	}
	
	bool Deploy()
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 1.0;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
		
		if ( self.pev.iuser1 > 0 )
			return self.DefaultDeploy( self.GetV_Model( "models/hl/v_satchel_radio.mdl" ), self.GetP_Model( "models/hl/p_satchel_radio.mdl" ), SKELETON_RADIO_DRAW, "hive" );
		else
			return self.DefaultDeploy( self.GetV_Model( "models/hl/v_satchel.mdl" ), self.GetP_Model( "models/hl/p_satchel.mdl" ), SKELETON_DRAW, "trip" );
	}
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.5;
	
		if ( self.pev.iuser1 > 0 )
		{
			self.SendWeaponAnim( SKELETON_RADIO_HOLSTER );
		}
		else
		{
			self.SendWeaponAnim( SKELETON_DROP );
		}
	}
	
	void InactiveItemPostFrame()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 && self.pev.iuser1 == 0 )
		{
			self.DestroyItem();
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}
	
	void PrimaryAttack()
	{
		switch( self.pev.iuser1 )
		{
			case 0:
			{
				Throw();
				break;
			}
			case 1:
			{
				self.SendWeaponAnim( SKELETON_RADIO_FIRE );
				
				CBaseEntity@ pSatchel = null;
				while ( ( @pSatchel = g_EntityFuncs.FindEntityInSphere( pSatchel, m_pPlayer.pev.origin, 4096, "*", "classname" ) ) !is null )
				{
					string cname = pSatchel.pev.classname;
					if ( cname == 'monster_amenbomb' )
					{
						CBaseEntity@ pevOwner = g_EntityFuncs.Instance( pSatchel.pev.owner );
						if ( pevOwner == m_pPlayer )
						{
							pSatchel.Use( m_pPlayer, m_pPlayer, USE_ON, 0 );
							self.pev.iuser1 = 2;
						}
					}
				}
				
				self.pev.iuser1 = 2;
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.5;
				break;
			}
			case 2:
			{
				// we're reloading, don't allow fire
				break;
			}
		}
	}
	
	void SecondaryAttack()
	{
		if ( self.pev.iuser1 != 2 )
		{
			Throw();
		}
	}
	
	void Throw()
	{
		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			Vector vecSrc = m_pPlayer.pev.origin;
			
			Vector vecThrow = g_Engine.v_forward * 274 + m_pPlayer.pev.velocity; // shouldn't makevectors go first? -Giegue
			
			CBaseEntity@ pSatchel = g_EntityFuncs.Create( "monster_amenbomb", vecSrc, g_vecZero, false, m_pPlayer.edict() );
			pSatchel.pev.velocity = vecThrow;
			pSatchel.pev.avelocity.y = 400;
			
			m_pPlayer.pev.viewmodel = string( "models/hl/v_satchel_radio.mdl" );
			m_pPlayer.pev.weaponmodel = string( "models/hl/p_satchel_radio.mdl" );
			
			self.SendWeaponAnim( SKELETON_RADIO_DRAW );
			
			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			
			self.pev.iuser1 = 1;
			
			int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, --iAmmo );
			
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
			
			// use hivehand animations
			m_pPlayer.m_szAnimExtension = "hive";
		}
	}
	
	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		switch( self.pev.iuser1 )
		{
			case 0:
			{
				self.SendWeaponAnim( SKELETON_FIDGET1 );
				// use tripmine animations
				m_pPlayer.m_szAnimExtension = "trip";
				break;
			}
			case 1:
			{
				self.SendWeaponAnim( SKELETON_RADIO_FIDGET1 );
				// use hivehand animations
				m_pPlayer.m_szAnimExtension = "hive";
				break;
			}
			case 2:
			{
				if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
				{
					self.pev.iuser1 = 0;
					self.RetireWeapon();
					return;
				}
				
				m_pPlayer.pev.viewmodel = string( "models/hl/v_satchel.mdl" );
				m_pPlayer.pev.weaponmodel = string( "models/hl/p_satchel.mdl" );
				
				self.SendWeaponAnim( SKELETON_DRAW );
				
				// use tripmine animations
				m_pPlayer.m_szAnimExtension = "trip";
				
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
				self.pev.iuser1 = 0;
				break;
			}
		}
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 ); // how long till we do this again.
	}
}

//=========================================================
// DeactivateSatchels - removes all satchels owned by
// the provided player. Should only be used upon death.
//
// Made this global on purpose.
//=========================================================
void DeactivateSatchels( CBasePlayer@ pOwner )
{
	CBaseEntity@ pFind = null;
	while ( ( @pFind = g_EntityFuncs.FindEntityInSphere( pFind, pOwner.pev.origin, 4096.0, "*", "classname" ) ) !is null )
	{
		string cname = pFind.pev.classname;
		if ( cname == 'monster_amenbomb' )
		{
			CSkeletonCharge@ pSatchel = cast<CSkeletonCharge@>(CastToScriptClass(pFind));
			CBaseEntity@ pevOwner = g_EntityFuncs.Instance( pSatchel.pev.owner );
			if ( pevOwner == pOwner )
			{
				pSatchel.Deactivate();
			}
		}
	}
}

string GetSkeletonName()
{
	return "weapon_amenbomb";
}

void RegisterSkeleton()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CSkeletonCharge", "monster_amenbomb" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_amenbomb", GetSkeletonName() );
	g_ItemRegistry.RegisterWeapon( GetSkeletonName(), "hq2_weapons", "Satchel Charge" );
}
