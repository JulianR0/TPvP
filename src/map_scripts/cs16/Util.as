// Utility code
// Lots of data for zee weapons
const int AK47_DISTANCE = 8192;
const int AUG_DISTANCE = 8192;
const int AWP_DISTANCE = 8192;
const int DEAGLE_DISTANCE = 4096;
const int ELITE_DISTANCE = 8192;
const int FAMAS_DISTANCE = 8192;
const int FIVESEVEN_DISTANCE = 4096;
const int G3SG1_DISTANCE = 8192;
const int GALIL_DISTANCE = 8192;
const int GLOCK18_DISTANCE = 8192;
const int M249_DISTANCE = 8192;
const int M4A1_DISTANCE = 8192;
const int MAC10_DISTANCE = 8192;
const int MP5N_DISTANCE = 8192;
const int P228_DISTANCE = 4096;
const int P90_DISTANCE = 8192;
const int SCOUT_DISTANCE = 8192;
const int SG550_DISTANCE = 8192;
const int SG552_DISTANCE = 8192;
const int TMP_DISTANCE = 8192;
const int UMP45_DISTANCE = 8192;
const int USP_DISTANCE = 4096;

const float AK47_DAMAGE = 36.0;
const float AUG_DAMAGE = 32.0;
const float AWP_DAMAGE = 115.0;
const float DEAGLE_DAMAGE = 54.0;
const float ELITE_DAMAGE = 36.0;
const float FAMAS_DAMAGE = 30.0;
const float FAMAS_DAMAGE_BURST = 34.0;
const float FIVESEVEN_DAMAGE = 20.0;
const float G3SG1_DAMAGE = 80.0;
const float GALIL_DAMAGE = 30.0;
const float GLOCK18_DAMAGE = 25.0;
const float M249_DAMAGE = 32.0;
const float M4A1_DAMAGE = 33.0;
const float M4A1_DAMAGE_SIL = 32.0;
const float MAC10_DAMAGE = 29.0;
const float MP5N_DAMAGE = 26.0;
const float P228_DAMAGE = 32.0;
const float P90_DAMAGE = 21.0;
const float SCOUT_DAMAGE = 75.0;
const float SG550_DAMAGE = 70.0;
const float SG552_DAMAGE = 33.0;
const float TMP_DAMAGE = 20.0;
const float UMP45_DAMAGE = 30.0;
const float USP_DAMAGE = 34.0;
const float USP_DAMAGE_SIL = 30.0;

const int AK47_PENETRATION = 2;
const int AUG_PENETRATION = 2;
const int AWP_PENETRATION = 3;
const int DEAGLE_PENETRATION = 2;
const int ELITE_PENETRATION = 1;
const int FAMAS_PENETRATION = 2;
const int FIVESEVEN_PENETRATION = 1;
const int G3SG1_PENETRATION = 3;
const int GALIL_PENETRATION = 2;
const int GLOCK18_PENETRATION = 1;
const int M249_PENETRATION = 2;
const int M4A1_PENETRATION = 2;
const int MAC10_PENETRATION = 1;
const int MP5N_PENETRATION = 1;
const int P228_PENETRATION = 1;
const int P90_PENETRATION = 1;
const int SCOUT_PENETRATION = 3;
const int SG550_PENETRATION = 2;
const int SG552_PENETRATION = 2;
const int TMP_PENETRATION = 1;
const int UMP45_PENETRATION = 1;
const int USP_PENETRATION = 1;

const float AK47_RANGE_MODIFER = 0.98;
const float AUG_RANGE_MODIFER = 0.96;
const float AWP_RANGE_MODIFER = 0.99;
const float DEAGLE_RANGE_MODIFER = 0.81;
const float ELITE_RANGE_MODIFER = 0.75;
const float FAMAS_RANGE_MODIFER = 0.96;
const float FIVESEVEN_RANGE_MODIFER = 0.885;
const float G3SG1_RANGE_MODIFER = 0.98;
const float GALIL_RANGE_MODIFER = 0.98;
const float GLOCK18_RANGE_MODIFER = 0.75;
const float M249_RANGE_MODIFER = 0.97;
const float M4A1_RANGE_MODIFER = 0.95;
const float M4A1_RANGE_MODIFER_SIL = 0.97;
const float MAC10_RANGE_MODIFER = 0.82;
const float MP5N_RANGE_MODIFER = 0.84;
const float P228_RANGE_MODIFER = 0.80;
const float P90_RANGE_MODIFER = 0.885;
const float SCOUT_RANGE_MODIFER = 0.98;
const float SG550_RANGE_MODIFER = 0.98;
const float SG552_RANGE_MODIFER = 0.955;
const float TMP_RANGE_MODIFER = 0.85;
const float UMP45_RANGE_MODIFER = 0.82;
const float USP_RANGE_MODIFER = 0.79;

const int BULLET_PLAYER_45ACP = 9;
const int BULLET_PLAYER_338MAG = 10;
const int BULLET_PLAYER_762MM = 11;
const int BULLET_PLAYER_556MM = 12;
const int BULLET_PLAYER_50AE = 13;
const int BULLET_PLAYER_57MM = 14;
const int BULLET_PLAYER_357SIG = 15;

// CS Bullet Fire
Vector FireBullets3( CBasePlayer@ pPlayer, Vector& in vecDirShooting, float& in flSpread, float& in flDistance, int& in iPenetration, int& in iBulletType, float& in iDamage, float& in flRangeModifier )
{
	// This function has too many arguments! Shrink down a little by retrieving data rather than passing values
	Vector vecSrc = pPlayer.GetGunPosition();
	int shared_rand = pPlayer.random_seed;
	// bPistol is unneeded, deleted
	// pevAttacker = pPlayer.pev
	
	int originalPenetration = iPenetration;
	float penetrationPower;
	float penetrationDistance;
	
	float currentDamage = iDamage;
	float currentDistance;
	
	TraceResult tr;
	
	Vector vecRight = g_Engine.v_right;
	Vector vecUp = g_Engine.v_up;
	
	switch ( iBulletType )
	{
		case BULLET_PLAYER_9MM:
		{
			penetrationPower = 21.0;
			penetrationDistance = 800;
			break;
		}
		case BULLET_PLAYER_45ACP:
		{
			penetrationPower = 15.0;
			penetrationDistance = 500;
			break;
		}
		case BULLET_PLAYER_50AE:
		{
			penetrationPower = 30.0;
			penetrationDistance = 1000;
			break;
		}
		case BULLET_PLAYER_762MM:
		{
			penetrationPower = 39.0;
			penetrationDistance = 5000;
			break;
		}
		case BULLET_PLAYER_556MM:
		{
			penetrationPower = 35.0;
			penetrationDistance = 4000;
			break;
		}
		case BULLET_PLAYER_338MAG:
		{
			penetrationPower = 45.0;
			penetrationDistance = 8000;
			break;
		}
		case BULLET_PLAYER_57MM:
		{
			penetrationPower = 30.0;
			penetrationDistance = 2000;
			break;
		}
		case BULLET_PLAYER_357SIG:
		{
			penetrationPower = 25.0;
			penetrationDistance = 800;
			break;
		}
		default:
		{
			penetrationPower = 0.0;
			penetrationDistance = 0;
			break;
		}
	}
	
	float x, y, z;
	
	x = g_PlayerFuncs.SharedRandomFloat( shared_rand, -0.5, 0.5 ) + g_PlayerFuncs.SharedRandomFloat( shared_rand + 1, -0.5, 0.5 );
	y = g_PlayerFuncs.SharedRandomFloat( shared_rand + 2, -0.5, 0.5 ) + g_PlayerFuncs.SharedRandomFloat( shared_rand + 3, -0.5, 0.5 );
	
	Vector vecDir = vecDirShooting + x * flSpread * vecRight + y * flSpread * vecUp;
	Vector vecEnd = vecSrc + vecDir * flDistance;
	
	float damageModifier = 0.5;

	while ( iPenetration > 0 )
	{
		g_WeaponFuncs.ClearMultiDamage();
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
		
		CBaseEntity@ tEntity = g_EntityFuncs.Instance( tr.pHit );
		string szTexture = g_Utility.TraceTexture( tEntity !is null ? tEntity.edict() : null, vecSrc, vecEnd );
		
		if ( szTexture == 'CHAR_TEX_METAL' )
		{
			penetrationPower *= 0.15;
			damageModifier = 0.2;
		}
		else if ( szTexture == 'CHAR_TEX_CONCRETE' )
		{
			penetrationPower *= 0.25;
		}
		else if ( szTexture == 'CHAR_TEX_GRATE' )
		{
			penetrationPower *= 0.5;
			damageModifier = 0.4;
		}
		else if ( szTexture == 'CHAR_TEX_VENT' )
		{
			penetrationPower *= 0.5;
			damageModifier = 0.45;
		}
		else if ( szTexture == 'CHAR_TEX_TILE' )
		{
			penetrationPower *= 0.65;
			damageModifier = 0.3;
		}
		else if ( szTexture == 'CHAR_TEX_COMPUTER' )
		{
			penetrationPower *= 0.4;
			damageModifier = 0.45;
		}
		else if ( szTexture == 'CHAR_TEX_WOOD' )
		{
			damageModifier = 0.6;
		}
		
		if ( tr.flFraction != 1.0 )
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
			
			iPenetration--;
			
			currentDistance = tr.flFraction * flDistance;
			currentDamage *= pow( flRangeModifier, currentDistance / 500 );
			
			if ( currentDistance > penetrationDistance )
			{
				iPenetration = 0;
			}
			
			float distanceModifier;
			
			if ( pEntity.pev.solid != SOLID_BSP || iPenetration == 0 )
			{
				penetrationPower = 42.0;
				distanceModifier = 0.75;
				damageModifier = 0.75;
			}
			else
			{
				distanceModifier = 0.75;
			}
			
			g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			
			vecSrc = tr.vecEndPos + ( vecDir * penetrationPower );
			flDistance = ( flDistance - currentDistance ) * distanceModifier;
			vecEnd = vecSrc + ( vecDir * flDistance );
			
			pEntity.TraceAttack( pPlayer.pev, currentDamage, vecDir, tr, ( DMG_BULLET | DMG_NEVERGIB ) );
			currentDamage *= damageModifier;
		}
		else
		{
			iPenetration = 0;
		}
		
		g_WeaponFuncs.ApplyMultiDamage( pPlayer.pev, pPlayer.pev );
	}
	
	return Vector( x * flSpread, y * flSpread, 0 );
}
