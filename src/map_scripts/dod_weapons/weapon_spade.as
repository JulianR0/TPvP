enum SpadeAnimation_e
{
	SPADE_IDLE = 0,
	SPADE_SLASH1,
	SPADE_SLASH2,
	SPADE_DRAW
}

class weapon_spade : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iSwing;
	TraceResult m_trHit;
	
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/ww2projekt/spade/w_spade.mdl") );
		self.m_iClip			= -1;
		self.m_flCustomDmg		= self.pev.dmg;

		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( "models/ww2projekt/spade/w_spade.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/spade/v_spade.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/spade/p_spade.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/knifeswing.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/knifeswing2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/cbar_hit1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/cbar_hit2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/knife_hit1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/knife_hit2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/knife_hit3.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/knife_hit4.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/knifeswing.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/knifeswing2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/cbar_hit1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/cbar_hit2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/knife_hit1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/knife_hit2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/knife_hit3.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/knife_hit4.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_spade.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_spade.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= -1;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= WEAPON_NOCLIP;
		info.iSlot			= 0;
		info.iPosition		= 5;
		info.iWeight		= 0;
		return true;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/spade/v_spade.mdl" ), self.GetP_Model( "models/ww2projekt/spade/p_spade.mdl" ), SPADE_DRAW, "crowbar" );
			
			float deployTime = 0.78;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			NetworkMessage axis1( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis1.WriteLong( self.m_iId );
			axis1.End();
			
			@m_pPlayer = pPlayer;
			
			return true;
		}
		
		return false;
	}
	
	void WeaponIdle()
	{
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;
		
		self.SendWeaponAnim( SPADE_IDLE );
		self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 10, 15 );
	}
		
	
	void Holster( int skiplocal /* = 0 */ )
	{
		m_pPlayer.m_flNextAttack = g_Engine.time + 0.5; 
		self.SendWeaponAnim( SPADE_IDLE );
	}
	
	void PrimaryAttack()
	{
		if( !Swing( 1 ) )
		{
			SetThink( ThinkFunction( this.SwingAgain ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}
	
	void Smack()
	{
		g_WeaponFuncs.DecalGunshot( m_trHit, BULLET_PLAYER_CROWBAR );
	}
	
	void SwingAgain()
	{
		Swing( 0 );
	}
	
	bool Swing( int fFirst )
	{
		bool fDidHit = false;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 47;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch( ( m_iSwing++ ) % 2 )
				{
				case 0:
					self.SendWeaponAnim( SPADE_SLASH2 ); break;
				case 1:
					self.SendWeaponAnim( SPADE_SLASH1 ); break;
				}
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
				// play wiff or swish sound
				switch( Math.RandomLong( 0, 1 ) )
				{
					case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/knifeswing.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) ); break;
					case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/knifeswing2.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) ); break;
				}
				
				// player "shoot" animation
				m_pPlayer.m_iWeaponVolume = 0;
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch( ( ( m_iSwing++ ) % 2 ) )
			{
			case 0:
				self.SendWeaponAnim( SPADE_SLASH2 ); break;
			case 1:
				self.SendWeaponAnim( SPADE_SLASH1 ); break;
			}

			// player "shoot" animation
			m_pPlayer.m_iWeaponVolume = 0;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			// AdamR: Custom damage option
			float flDamage = 45;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;
			// AdamR: End
			
			g_WeaponFuncs.ClearMultiDamage();
			
			pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, ( DMG_CLUB | DMG_NEVERGIB ) );  
			
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			//m_flNextPrimaryAttack = gpGlobals->time + 0.30; //0.25

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5; //0.25

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
					// play thwack or smack sound
					switch( Math.RandomLong( 0, 3 ) )
					{
					case 0:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/knife_hit1.wav", 1, ATTN_NORM ); break;
					case 1:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/knife_hit2.wav", 1, ATTN_NORM ); break;
					case 2:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/knife_hit3.wav", 1, ATTN_NORM ); break;
					case 3:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/knife_hit4.wav", 1, ATTN_NORM ); break;
					}
					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5; //0.25
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.

				fvolbar = 1;

				// also play crowbar strike
				
				switch( Math.RandomLong( 0, 1 ) )
				{
					case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/cbar_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
					case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/cbar_hit2.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				}
			}

			// delay the decal a bit
			m_trHit = tr;
			SetThink( ThinkFunction( this.Smack ) );
			self.pev.nextthink = g_Engine.time + 0.1;

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}
}

string GetSPADEName()
{
	return "weapon_spade";
}

void RegisterSPADE()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetSPADEName(), GetSPADEName() );
	g_ItemRegistry.RegisterWeapon( GetSPADEName(), "ww2projekt" );
}