/*
	Team Player vs Player: Main Script
	Copyright (C) 2019  Julian Rodriguez
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <https://www.gnu.org/licenses/>.
*/

// Main vars
int spirals;
int crimsons;

int score_spiral;
int score_crimson;

bool bDeadChat;
bool bAutoBalance;
bool bAllowBoost;

bool bC4Exists;
bool bCanGiveC4;

// Duel vars
bool bDuelVote;
array< bool > bAskedDuel( 33 );
int iDuelXPPool;

// General Stats
array< int > iSwaps( 33 );
array< bool > bAutoChange( 33 );
array< bool > bSpectate( 33 );
array< bool > adm_hide( 33 );

array< int > iOldKillStreak( 33 );
array< int > iCurrentKillStreak( 33 );
array< int > iSpiralScore( 33 );
array< int > iCrimsonScore( 33 );

int iSpiralKills;
int iSpiralSuicides;
int iSpiralSwaps;

string szBestSpiral;
int iBestSpiralScore;

string szKillStreakSpiral;
int iSpiral_KS_Score;

int iCrimsonKills;
int iCrimsonSuicides;
int iCrimsonSwaps;

string szBestCrimson;
int iBestCrimsonScore;

string szKillStreakCrimson;
int iCrimson_KS_Score;

// General map stats
DateTime dtMapStart;
DateTime dtMapFinish;
int iChangelevelTime;

int iWeaponInitialized;
array< string > szWeaponClassname( 64 );

int iMostWeaponKills;
string szMostWeaponKills;
int iLeastWeaponKills;
string szLeastWeaponKills;

/* Secret map stats
------------------- */
// hl_boot_camp ~ hl_bounce ~ hl_datacore ~ hl_frenzy ~ hl_gasworks ~ hl_snark_pit ~ hl_stalkyard ~ hl_undertow ~ fun_spooks
int iSpiralTripmineKills;
int iCrimsonTripmineKills;

// hl_campgrounds ~ hl_lambda_bunker
int iSpiralSatchelKills;
int iCrimsonSatchelKills;

// hl_crossfire
int iBombTimes;

// hl_npc ~ fun_big_city ~ fun_big_city2
int iSpiralVehicleKills;
int iCrimsonVehicleKills;

// hl_rapidcore
int iSpiralSnarkKills;
int iCrimsonSnarkKills;

// hl_subtransit
int iTrainKills;

// cs_airstrip ~ cs_dust2 ~ cs_inferno ~ cs_nuke ~ cs_prodigy ~ cs_shoothouse ~ cs_vangogh ~ fun_teleport ~ fun_darkmines ~ fun_the_stairs2
int iTotalBombs;
int iSpiralDetonate;
int iSpiralDefuse;
int iCrimsonDetonate;
int iCrimsonDefuse;

// cs_assault ~ cs_ng_deck16
int iSpiralHEKills;
int iCrimsonHEKills;

// cs_backalley ~ cs_estate ~ cs_havana ~ cs_italy ~ cs_militia ~ cs_office
int iSpiralP228Kills;
int iCrimsonP228Kills;

// ALL dmc_ maps
int iSpiralAXEKills;
int iCrimsonAXEKills;

// ALL dod_ maps
int iSpiralCPTime;
int iCrimsonCPTime;
string szSpiralCPTime;
string szCrimsonCPTime;

// ALL aim_ maps
int iSpiralMeleeKills;
int iCrimsonMeleeKills;

// fun_hq2_phoenix
int iSpiralHornetKills;
int iCrimsonHornetKills;

// fun_sky_world_arena
int iSpiralAerialKills;
int iCrimsonAerialKills;

/* Level variables */
const string PATH_MAIN_DATA = "scripts/plugins/store/tdm_data/";
array< int > iRemainingXP( 33 );
array< int > iLevel( 33 );
array< float > flSpawnProtectionTime( 33 ); // Boosts from here on
array< int > iTeamHPReg( 33 );
array< int > iTeamAPReg( 33 );
array< int > iCriticalResist( 33 );
array< int > iFalldamageResist( 33 );
array< bool > bHasNightvision( 33 );
array< bool > bIsNightvisionOn( 33 );
array< int > iExtraMaxHP( 33 );
array< int > iExtraMaxAP( 33 );
array< int > iExtraStartHP( 33 );
array< int > iShopDiscount( 33 );
array< DateTime > dtFirstPlay( 33 );

/* Cosmetic stuff - START */
// Color names
const array< string > _ColorNames =
{
	"aliceblue",
	"antiquewhite",
	"aqua",
	"aquamarine",
	"azure",
	"beige",
	"bisque",
	"black",
	"blue",
	"blueviolet",
	"brown",
	"burlywood",
	"cadetblue",
	"chartreuse",
	"chocolate",
	"coral",
	"cornflowerblue",
	"cornsilk",
	"crimson",
	"cyan",
	"darkblue",
	"darkcyan",
	"darkgolden",
	"darkgray",
	"darkgreen",
	"darkkhaki",
	"darkmagenta",
	"darkolive",
	"darkorange",
	"darkorchid",
	"darkred",
	"darksalmon",
	"darkseagreen",
	"darkslateblue",
	"darkslategray",
	"darkturquoise",
	"darkviolet",
	"deeppink",
	"deepskyblue",
	"dimgray",
	"firebrick",
	"forestgreen",
	"gold",
	"gray",
	"green",
	"greenyellow",
	"hotpink",
	"indianred",
	"indigo",
	"ivory",
	"khaki",
	"lavender",
	"lightblue",
	"lightcoral",
	"lightcyan",
	"lightgreen",
	"lightgray",
	"lightpink",
	"lightsalmon",
	"lightseagreen",
	"lightskyblue",
	"lightslategray",
	"lightsteelblue",
	"lightyellow",
	"lime",
	"limegreen",
	"magenta",
	"maroon",
	"mediumblue",
	"mediumorchid",
	"mediumpurple",
	"mediumseagreen",
	"mediumslateblue",
	"mediumturquoise",
	"midnightblue",
	"navy",
	"olive",
	"orange",
	"orangered",
	"orchid",
	"pink",
	"plum",
	"purple",
	"red",
	"rosybrown",
	"royalblue",
	"salmon",
	"scoobidoo",
	"seagreen",
	"sienna",
	"silver",
	"skyblue",
	"slateblue",
	"slategray",
	"snoz",
	"steelblue",
	"tan",
	"teal",
	"tomato",
	"turquoise",
	"violet",
	"wheat",
	"white",
	"yellow",
	"yellowgreen"
};

// Color RGB codes
const array< Vector > _ColorCodes =
{
	Vector( 240, 248, 255 ),
	Vector( 250, 235, 215 ),
	Vector( 000, 255, 255 ),
	Vector( 127, 255, 212 ),
	Vector( 240, 255, 255 ),
	Vector( 245, 245, 220 ),
	Vector( 255, 228, 196 ),
	Vector( 050, 050, 050 ),
	Vector( 010, 010, 250 ),
	Vector( 138, 043, 226 ),
	Vector( 139, 059, 019 ),
	Vector( 222, 184, 135 ),
	Vector( 095, 158, 160 ),
	Vector( 127, 255, 000 ),
	Vector( 210, 105, 030 ),
	Vector( 255, 127, 080 ),
	Vector( 100, 149, 237 ),
	Vector( 255, 248, 220 ),
	Vector( 220, 020, 060 ),
	Vector( 000, 255, 255 ),
	Vector( 024, 000, 076 ),
	Vector( 000, 139, 139 ),
	Vector( 184, 134, 011 ),
	Vector( 169, 169, 169 ),
	Vector( 000, 100, 000 ),
	Vector( 189, 184, 107 ),
	Vector( 139, 000, 139 ),
	Vector( 085, 107, 047 ),
	Vector( 255, 140, 000 ),
	Vector( 153, 050, 204 ),
	Vector( 139, 000, 000 ),
	Vector( 233, 150, 122 ),
	Vector( 143, 188, 143 ),
	Vector( 072, 061, 139 ),
	Vector( 047, 079, 079 ),
	Vector( 000, 206, 209 ),
	Vector( 148, 000, 211 ),
	Vector( 255, 020, 147 ),
	Vector( 000, 191, 255 ),
	Vector( 105, 105, 105 ),
	Vector( 178, 034, 034 ),
	Vector( 034, 139, 034 ),
	Vector( 218, 165, 032 ),
	Vector( 128, 128, 128 ),
	Vector( 010, 250, 010 ),
	Vector( 173, 255, 047 ),
	Vector( 255, 105, 180 ),
	Vector( 205, 092, 092 ),
	Vector( 075, 000, 130 ),
	Vector( 255, 255, 240 ),
	Vector( 240, 230, 140 ),
	Vector( 230, 230, 250 ),
	Vector( 173, 216, 230 ),
	Vector( 240, 128, 128 ),
	Vector( 224, 255, 255 ),
	Vector( 144, 238, 144 ),
	Vector( 211, 211, 211 ),
	Vector( 255, 182, 193 ),
	Vector( 255, 160, 122 ),
	Vector( 032, 178, 170 ),
	Vector( 135, 206, 250 ),
	Vector( 119, 136, 153 ),
	Vector( 176, 196, 222 ),
	Vector( 255, 255, 224 ),
	Vector( 010, 010, 250 ),
	Vector( 050, 205, 050 ),
	Vector( 255, 000, 255 ),
	Vector( 128, 000, 000 ),
	Vector( 000, 000, 205 ),
	Vector( 186, 085, 211 ),
	Vector( 147, 112, 216 ),
	Vector( 060, 179, 113 ),
	Vector( 125, 104, 238 ),
	Vector( 072, 209, 204 ),
	Vector( 025, 025, 112 ),
	Vector( 000, 000, 128 ),
	Vector( 128, 128, 000 ),
	Vector( 255, 148, 009 ),
	Vector( 255, 071, 000 ),
	Vector( 218, 112, 214 ),
	Vector( 255, 192, 203 ),
	Vector( 221, 160, 221 ),
	Vector( 128, 000, 128 ),
	Vector( 250, 010, 010 ),
	Vector( 188, 143, 143 ),
	Vector( 065, 105, 225 ),
	Vector( 250, 128, 114 ),
	Vector( 154, 130, 189 ),
	Vector( 046, 139, 087 ),
	Vector( 160, 082, 045 ),
	Vector( 192, 192, 192 ),
	Vector( 000, 000, 255 ),
	Vector( 106, 090, 205 ),
	Vector( 112, 128, 144 ),
	Vector( 255, 250, 250 ),
	Vector( 070, 130, 180 ),
	Vector( 210, 180, 140 ),
	Vector( 000, 255, 255 ),
	Vector( 255, 099, 071 ),
	Vector( 064, 224, 208 ),
	Vector( 238, 130, 238 ),
	Vector( 245, 222, 179 ),
	Vector( 250, 250, 250 ),
	Vector( 250, 250, 010 ),
	Vector( 154, 205, 050 )
};

const array< string > _TrailSprites =
{
	"sprites/laserbeam.spr", // A
	"sprites/xbeam1.spr", // B
	"sprites/xbeam3.spr", // C
	"sprites/xbeam5.spr", // D
	"sprites/zbeam1.spr", // E
	"sprites/zbeam2.spr", // F
	"sprites/zbeam3.spr", // G
	"sprites/zbeam4.spr", // H
	"sprites/zbeam5.spr", // I
	"sprites/zbeam6.spr", // J
	"sprites/xenobeam.spr", // K
	"sprites/kingpin_beam.spr", // L
	"sprites/glow02.spr", // M
	"sprites/interlace.spr", // N
	"sprites/select.spr", // O
	"sprites/shellchrome.spr", // P
	"sprites/vhe-iconsprites/light.spr", // Q
	"sprites/vhe-iconsprites/light_environment.spr", // R
	"sprites/vhe-iconsprites/light_spot.spr" // S
};

const array< string > _HatsNames =
{
	"afro",
	"angel2",
	"awesome",
	"barrel",
	"beerhat",
	"bucket",
	"cowboy",
	"crowbared",
	"devil2",
	"elf",
	"headphones",
	"hellokitty",
	"jackinbox",
	"jackolantern",
	"jamacahat2",
	"joker",
	"js",
	"lemonhead",
	"magic",
	"mau5",
	"pirate2",
	"popeye",
	"psycho",
	"rubikscube",
	"santahat2",
	"shoopdawhoop",
	"spongebob",
	"svencoop",
	"tv",
	"zippy"
};

const array< string > _NormalWeaponNames =
{
	"Revolver 357",
	"Ballesta",
	"Snark",
	"Escopeta",
	"AK-47 Kalashnikov",
	"Schmidt Scout",
	"Dual Elites Berettas",
	"Ingram MAC-10",
	"Nailgun",
	"Classic Super-Shotgun",
	"Lanza Granadas",
	"Lightning Gun",
	"Lee Enfield",
	"Stg-44",
	"PIAT Launcher",
	"Sten Mk2",
	"Spore Launcher",
	"Sven Eagle",
	"XV11382 Displacer",
	"Sven M249"
};

const array< string > _NormalWeaponClassnames =
{
	"weapon_hl357",
	"weapon_hlcrossbow",
	"weapon_hlsnark",
	"weapon_hlshotgun",
	"weapon_ak47",
	"weapon_scout",
	"weapon_dualelites",
	"weapon_mac10",
	"weapon_dmcnailgun",
	"weapon_dmcsupershotgun",
	"weapon_dmcgrenadelauncher",
	"weapon_dmclightninggun",
	"weapon_enfield",
	"weapon_mp44",
	"weapon_piat",
	"weapon_sten",
	"weapon_sporelauncher",
	"weapon_eagle",
	"weapon_displacer",
	"weapon_saw"
};

const array< int > _NormalWeaponCosts =
{
	48,
	64,
	32,
	56,
	80,
	48,
	64,
	56,
	48,
	32,
	64,
	128,
	48,
	80,
	96,
	64,
	96,
	64,
	128,
	112
};

// Main data
array< int > iCP( 33 );
array< bool > bShouldUpdate( 33 );

// Glow data
array< array< bool >> bGlow( 33, array< bool > ( 6 ) );

array< int > iSelectedColors( 33 );
array< int > iChoosenColors( 33 );
array< int > iMaxColors( 33 );

array< array< Vector >> vecGlowColor( 33, array< Vector > ( 6 ) );
array< array< Vector >> vecGlowUpdate( 33, array< Vector > ( 6 ) );

array< int > iGlowAlternate( 33 );

// Trail data
array< bool > bTrail( 33 );
array< int > iTrailSpriteIndex( _TrailSprites.length() );
array< int > iMaxTrails( 33 );

array< Vector > vecTrailColor( 33 );
array< int > iTrailSprite( 33 );
array< uint8 > iTrailLong( 33 );
array< uint8 > iTrailSize( 33 );
array< Vector > vecTrailUpdate( 33 );
array< int > iTrailNewSprite( 33 );
array< uint8 > iTrailNewLong( 33 );
array< uint8 > iTrailNewSize( 33 );

array< bool > bTrailActive( 33 );

// Hat data
array< EHandle > hatEntity( 33 );
array< array< bool >> bHatGlow( 33, array< bool > ( 6 ) );

array< int > iHatSelectedColors( 33 );
array< int > iHatChoosenColors( 33 );
array< int > iMaxHatColors( 33 );

array< array< Vector >> vecHatGlowColor( 33, array< Vector > ( 6 ) );
array< array< Vector >> vecHatGlowUpdate( 33, array< Vector > ( 6 ) );

array< int > iHatGlowAlternate( 33 );

// Weapon data
array< int > iAutoBuy( 33 );
array< int > iBuyWeapons( 33 );
array< int > iMaxWeapons( 33 );
array< array< string >> szAutoWeapon( 33, array< string > ( 4 ) );
array< int > iAutoCost( 33 );
array< int > iWeaponCooldown( 33 );
array< int > iWeaponSelected( 33 );

// Cosmetic package
array< bool > bHasCosmeticPack( 33 );
array< bool > bIsCPActive( 33 );
array< int > iCPGlowColors( 33 );
array< array< Vector >> vecCPGlowColor( 33, array< Vector > ( 6 ) );
array< bool > bCPTrail( 33 );
array< Vector > vecCPTrailColor( 33 );
array< int > iCPTrailSprite( 33 );
array< uint8 > iCPTrailLong( 33 );
array< uint8 > iCPTrailSize( 33 );
array< string > szCPHatName( 33 );
array< int > iCPHatGlowColors( 33 );
array< array< Vector >> vecCPHatGlowColor( 33, array< Vector > ( 6 ) );
array< int > iCPAux( 33 );
/* Cosmetic stuff - END */

// Misc variables
array< bool > bLoadData( 33 );
string szMapName;
bool bGameEnd;

// MenuHandler
dictionary pmenu_state;
class MenuHandler
{
	CTextMenu@ menu;
	
	void InitMenu( CBasePlayer@ pPlayer, TextMenuPlayerSlotCallback@ callback )
	{
		CTextMenu temp( @callback );
		@menu = @temp;
	}
	
	void OpenMenu( CBasePlayer@ pPlayer, int& in time, int& in page )
	{
		menu.Register();
		menu.Open( time, page, pPlayer );
	}
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Julian \"Giegue\" Rodriguez" );
	g_Module.ScriptInfo.SetContactInfo( "www.steamcommunity.com/id/ngiegue" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	
	g_Scheduler.SetInterval( "ShowScore", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
	g_Scheduler.SetInterval( "CheckTeams", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
	g_Scheduler.SetInterval( "CheckSystem", 0.3, g_Scheduler.REPEAT_INFINITE_TIMES );
	
	g_Scheduler.SetInterval( "CP_Think", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void MapInit()
{
	spirals = 0;
	crimsons = 0;
	
	score_spiral = 0;
	score_crimson = 0;
	
	bDeadChat = true;
	bAutoBalance = true;
	bAllowBoost = true;
	
	bC4Exists = false;
	bCanGiveC4 = false;
	
	bDuelVote = false;
	iDuelXPPool = 0;
	
	iSpiralKills = 0;
	iSpiralSuicides = 0;
	iSpiralSwaps = 0;
	
	szBestSpiral = "";
	iBestSpiralScore = 0;
	
	szKillStreakSpiral = "";
	iSpiral_KS_Score = 0;
	
	iCrimsonKills = 0;
	iCrimsonSuicides = 0;
	iCrimsonSwaps = 0;
	
	szBestCrimson = "";
	iBestCrimsonScore = 0;
	
	szKillStreakCrimson = "";
	iCrimson_KS_Score = 0;
	
	dtMapStart = UnixTimestamp();
	
	iWeaponInitialized = 0;
	
	iMostWeaponKills = 0;
	szMostWeaponKills = "";
	iLeastWeaponKills = 99;
	szLeastWeaponKills = "";
	
	iSpiralTripmineKills = 0;
	iCrimsonTripmineKills = 0;
	iSpiralSatchelKills = 0;
	iCrimsonSatchelKills = 0;
	iBombTimes = 0;
	iSpiralVehicleKills = 0;
	iCrimsonVehicleKills = 0;
	iSpiralSnarkKills = 0;
	iCrimsonSnarkKills = 0;
	iTrainKills = 0;
	iTotalBombs = 0;
	iSpiralDetonate = 0;
	iSpiralDefuse = 0;
	iCrimsonDetonate = 0;
	iCrimsonDefuse = 0;
	iSpiralHEKills = 0;
	iCrimsonHEKills = 0;
	iSpiralP228Kills = 0;
	iCrimsonP228Kills = 0;
	iSpiralAXEKills = 0;
	iCrimsonAXEKills = 0;
	iSpiralCPTime = 0;
	iCrimsonCPTime = 0;
	szSpiralCPTime = "";
	szCrimsonCPTime = "";
	iSpiralMeleeKills = 0;
	iCrimsonMeleeKills = 0;
	iSpiralHornetKills = 0;
	iCrimsonHornetKills = 0;
	iSpiralAerialKills = 0;
	iCrimsonAerialKills = 0;
	
	szMapName = g_Engine.mapname;
	bGameEnd = false;
	iChangelevelTime = 15;
	
	for( int i = 0; i < 33; i++ )
	{
		iSwaps[ i ] = 0;
		bAutoChange[ i ] = false;
		bSpectate[ i ] = false;
		adm_hide[ i ] = false;
		bAskedDuel[ i ] = false;
		
		iOldKillStreak[ i ] = 0;
		iCurrentKillStreak[ i ] = 0;
		iSpiralScore[ i ] = 0;
		iCrimsonScore[ i ] = 0;
		
		iRemainingXP[ i ] = 0;
		iLevel[ i ] = 0;
		flSpawnProtectionTime[ i ] = 0.0;
		iTeamHPReg[ i ] = 0;
		iTeamAPReg[ i ] = 0;
		iCriticalResist[ i ] = 0;
		iFalldamageResist[ i ] = 0;
		bHasNightvision[ i ] = false;
		bIsNightvisionOn[ i ] = false;
		iExtraMaxHP[ i ] = 0;
		iExtraMaxAP[ i ] = 0;
		iExtraStartHP[ i ] = 0;
		bLoadData[ i ] = false;
		
		iCP[ i ] = 0;
		bShouldUpdate[ i ] = false;
		
		for ( int j = 0; j < 6; j++ )
		{
			bGlow[ i ][ j ] = false;
			vecGlowColor[ i ][ j ] = g_vecZero;
			vecGlowUpdate[ i ][ j ] = g_vecZero;
			bHatGlow[ i ][ j ] = false;
			vecHatGlowColor[ i ][ j ] = g_vecZero;
			vecHatGlowUpdate[ i ][ j ] = g_vecZero;
			vecCPGlowColor[ i ][ j ] = g_vecZero;
			vecCPHatGlowColor[ i ][ j ] = g_vecZero;
			if ( j < 4 ) szAutoWeapon[ i ][ j ] = "";
		}
		iGlowAlternate[ i ] = 1;
		iSelectedColors[ i ] = 1;
		iChoosenColors[ i ] = 0;
		iMaxColors[ i ] = 1;
		
		bTrail[ i ] = false;
		vecTrailColor[ i ] = g_vecZero;
		iMaxTrails[ i ] = 1;
		iTrailSprite[ i ] = 0;
		iTrailLong[ i ] = 20;
		iTrailSize[ i ] = 8;
		vecTrailUpdate[ i ] = g_vecZero;
		iTrailNewSprite[ i ] = 0;
		iTrailNewLong[ i ] = 20;
		iTrailNewSize[ i ] = 8;
		bTrailActive[ i ] = false;
		
		hatEntity[ i ] = null;
		iHatGlowAlternate[ i ] = 1;
		iHatSelectedColors[ i ] = 0;
		iHatChoosenColors[ i ] = 0;
		iMaxHatColors[ i ] = 1;
		
		iAutoBuy[ i ] = 0;
		iBuyWeapons[ i ] = 1;
		iMaxWeapons[ i ] = 0;
		iAutoCost[ i ] = 0;
		iWeaponCooldown[ i ] = 0;
		iWeaponSelected[ i ] = 0;
		
		bHasCosmeticPack[ i ] = false;
		bIsCPActive[ i ] = false;
		iCPGlowColors[ i ] = 0;
		bCPTrail[ i ] = false;
		vecCPTrailColor[ i ] = g_vecZero;
		iCPTrailSprite[ i ] = 0;
		iCPTrailLong[ i ] = 20;
		iCPTrailSize[ i ] = 8;
		szCPHatName[ i ] = "";
		iCPHatGlowColors[ i ] = 0;
		iCPAux[ i ] = 0;
		
		iShopDiscount[ i ] = 0;
	}
	
	for ( uint i = 0; i < _TrailSprites.length(); i++ )
	{
		iTrailSpriteIndex[ i ] = g_Game.PrecacheModel( _TrailSprites[ i ] );
	}
	
	for ( uint i = 0; i < _HatsNames.length(); i++ )
	{
		string szModel = "models/hats/" + _HatsNames[ i ] + ".mdl";
		g_Game.PrecacheModel( szModel );
	}
	
	for( uint i = 0; i < szWeaponClassname.length(); i++ )
	{
		szWeaponClassname[ i ] = "";
	}
	
	g_Scheduler.SetTimeout( "AddGlobal", 0.5 );
	g_Scheduler.SetTimeout( "MapCheck", 1.0 );
	g_Scheduler.SetTimeout( "ResetC4", 60.0 );
	
	g_Game.PrecacheModel( "sprites/ecsc/teamhud.spr" );
	
	g_Game.PrecacheGeneric( "sound/ecsc/tpvp/gameend_1.ogg" );
	g_Game.PrecacheGeneric( "sound/ecsc/tpvp/gameend_2.ogg" );
	g_Game.PrecacheGeneric( "sound/ecsc/tpvp/gameend_3.ogg" );
	g_Game.PrecacheGeneric( "sound/ecsc/tpvp/gameend_3_v2.ogg" );
	g_Game.PrecacheGeneric( "sound/ecsc/tpvp/xp.ogg" );
	g_Game.PrecacheGeneric( "sound/ecsc/tpvp/levelup.ogg" );
	
	g_SoundSystem.PrecacheSound( "ambience/goal_1.wav" );
	
	g_SoundSystem.PrecacheSound( "ecsc/tpvp/gameend_1.ogg" );
	g_SoundSystem.PrecacheSound( "ecsc/tpvp/gameend_2.ogg" );
	g_SoundSystem.PrecacheSound( "ecsc/tpvp/gameend_3.ogg" );
	g_SoundSystem.PrecacheSound( "ecsc/tpvp/gameend_3_v2.ogg" );
	g_SoundSystem.PrecacheSound( "ecsc/tpvp/xp.ogg" );
	g_SoundSystem.PrecacheSound( "ecsc/tpvp/levelup.ogg" );
	
	g_SoundSystem.PrecacheSound( "vox/deeoo.wav" );
	g_SoundSystem.PrecacheSound( "vox/bizwarn.wav" );
	g_SoundSystem.PrecacheSound( "fvox/ten.wav" );
	g_SoundSystem.PrecacheSound( "fvox/nine.wav" );
	g_SoundSystem.PrecacheSound( "fvox/eight.wav" );
	g_SoundSystem.PrecacheSound( "fvox/seven.wav" );
	g_SoundSystem.PrecacheSound( "fvox/six.wav" );
	g_SoundSystem.PrecacheSound( "fvox/five.wav" );
	g_SoundSystem.PrecacheSound( "fvox/four.wav" );
	g_SoundSystem.PrecacheSound( "fvox/three.wav" );
	g_SoundSystem.PrecacheSound( "fvox/two.wav" );
	g_SoundSystem.PrecacheSound( "fvox/one.wav" );
	g_SoundSystem.PrecacheSound( "barney/ba_bring.wav" );
	
	array< string >@ states = pmenu_state.getKeys();
	for ( uint i = 0; i < states.length(); i++ )
	{
		MenuHandler@ state = cast< MenuHandler@ >( pmenu_state[ states[ i ] ] );
		if ( state.menu !is null )
			@state.menu = null;
	}
	
	g_Hooks.RemoveHook( Hooks::Player::PlayerTakeDamage );
	
	// Additional hooks
	g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @GLOBAL_TakeDamage );
	if ( szMapName.StartsWith( "dmc_" ) )
		g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @DMC_TakeDamage );
	else if ( szMapName.StartsWith( "cs_" ) || szMapName == 'aim_scout_crhd' )
		g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @CS_TakeDamage );
}

MenuHandler@ MenuGetPlayer( CBasePlayer@ pPlayer )
{
	string steamid = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if ( steamid == 'STEAM_ID_LAN' )
	{
		steamid = pPlayer.pev.netname;
	}
	
	if ( !pmenu_state.exists( steamid ) )
	{
		MenuHandler state;
		pmenu_state[ steamid ] = state;
	}
	return cast< MenuHandler@ >( pmenu_state[ steamid ] );
}

void MapActivate()
{
	if ( szMapName[ 0 ] == 'f' && szMapName[ 1 ] == 'u' && szMapName[ 2 ] == 'n' )
		return;
	
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "item_longjump" ) ) !is null )
	{
		g_EntityFuncs.Remove( ent );
	}
}

void AddGlobal()
{
	CBaseEntity@ gData = g_EntityFuncs.Create( "info_target", g_vecZero, g_vecZero, false );
	gData.pev.targetname = "sys_game";
	
	if ( szMapName == 'hl_crossfire' )
	{
		CBaseEntity@ pMapStat = g_EntityFuncs.Create( "trigger_changevalue", g_vecZero, g_vecZero, false );
		pMapStat.pev.targetname = "strike_mm";
		pMapStat.pev.target = "sys_game";
		pMapStat.KeyValue( "m_iszValueName", "$i_bomb_times" );
		pMapStat.KeyValue( "m_iszNewValue", "1" );
		pMapStat.KeyValue( "m_iszValueType", "1" );
	}
}

void MapCheck()
{
	if ( szMapName[ 0 ] == 'c' && szMapName[ 1 ] == 's' || szMapName[ 0 ] == 'f' && szMapName[ 1 ] == 'u' && szMapName[ 2 ] == 'n' )
	{
		CBaseEntity@ eCheck = g_EntityFuncs.FindEntityByClassname( null, "func_bomb_target" );
		if ( eCheck !is null )
		{
			bC4Exists = true;
			bCanGiveC4 = true;
		}
	}
}

void ResetC4()
{
	if ( bC4Exists )
	{
		bCanGiveC4 = true;
	}
	
	g_Scheduler.SetTimeout( "ResetC4", 60.0 );
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	// Set up start time
	CustomKeyvalues@ pKVD = pPlayer.GetCustomKeyvalues();
	pKVD.SetKeyvalue( "$f_join_time", g_Engine.time );
	
	// StartUp data
	int index = pPlayer.entindex();
	bLoadData[ index ] = false;
	XP_LoadData( index );
	pKVD.SetKeyvalue( "$i_player_level", iLevel[ index ] );
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	int index = pPlayer.entindex();
	
	iSwaps[ index ] = 0;
	bAutoChange[ index ] = false;
	bSpectate[ index ] = false;
	adm_hide[ index ] = false;
	bAskedDuel[ index ] = false;
	
	iOldKillStreak[ index ] = 0;
	iCurrentKillStreak[ index ] = 0;
	iSpiralScore[ index ] = 0;
	iCrimsonScore[ index ] = 0;
	
	bLoadData[ index ] = false;
	iRemainingXP[ index ] = 0;
	iLevel[ index ] = 0;
	flSpawnProtectionTime[ index ] = 0.0;
	iTeamHPReg[ index ] = 0;
	iTeamAPReg[ index ] = 0;
	iCriticalResist[ index ] = 0;
	iFalldamageResist[ index ] = 0;
	bHasNightvision[ index ] = false;
	bIsNightvisionOn[ index ] = false;
	iExtraMaxHP[ index ] = 0;
	iExtraMaxAP[ index ] = 0;
	iExtraStartHP[ index ] = 0;
	
	iCP[ index ] = 0;
	bShouldUpdate[ index ] = false;
	
	for ( int i = 0; i < 6; i++ )
	{
		bGlow[ index ][ i ] = false;
		vecGlowColor[ index ][ i ] = g_vecZero;
		vecGlowUpdate[ index ][ i ] = g_vecZero;
		bHatGlow[ index ][ i ] = false;
		vecHatGlowColor[ index ][ i ] = g_vecZero;
		vecHatGlowUpdate[ index ][ i ] = g_vecZero;
		vecCPGlowColor[ index ][ i ] = g_vecZero;
		vecCPHatGlowColor[ index ][ i ] = g_vecZero;
		if ( i < 4 ) szAutoWeapon[ index ][ i ] = "";
	}
	iGlowAlternate[ index ] = 1;
	iSelectedColors[ index ] = 1;
	iChoosenColors[ index ] = 0;
	iMaxColors[ index ] = 1;
	
	bTrail[ index ] = false;
	vecTrailColor[ index ] = g_vecZero;
	iMaxTrails[ index ] = 1;
	iTrailSprite[ index ] = 0;
	iTrailLong[ index ] = 20;
	iTrailSize[ index ] = 8;
	vecTrailUpdate[ index ] = g_vecZero;
	iTrailNewSprite[ index ] = 0;
	iTrailNewLong[ index ] = 20;
	iTrailNewSize[ index ] = 8;
	bTrailActive[ index ] = false;
	
	// Destroy hat entity if it exists. Prevents another player from using others hat ( same index slot )
	if ( hatEntity[ index ].GetEntity() !is null )
		g_EntityFuncs.Remove( hatEntity[ index ].GetEntity() );
	hatEntity[ index ] = null;
	
	iHatGlowAlternate[ index ] = 1;
	iHatSelectedColors[ index ] = 0;
	iHatChoosenColors[ index ] = 0;
	iMaxHatColors[ index ] = 1;
	
	iAutoBuy[ index ] = 0;
	iBuyWeapons[ index ] = 1;
	iMaxWeapons[ index ] = 0;
	iAutoCost[ index ] = 0;
	iWeaponCooldown[ index ] = 0;
	iWeaponSelected[ index ] = 0;
	
	bHasCosmeticPack[ index ] = false;
	bIsCPActive[ index ] = false;
	iCPGlowColors[ index ] = 0;
	bCPTrail[ index ] = false;
	vecCPTrailColor[ index ] = g_vecZero;
	iCPTrailSprite[ index ] = 0;
	iCPTrailLong[ index ] = 20;
	iCPTrailSize[ index ] = 8;
	szCPHatName[ index ] = "";
	iCPHatGlowColors[ index ] = 0;
	iCPAux[ index ] = 0;
	
	iShopDiscount[ index ] = 0;
	
	return HOOK_CONTINUE;
}

CClientCommand ADMIN_FORCESWAP( "forceswap", "<Nombre> - Obliga al jugador a cambiarse de equipo", @admin_forceswap, ConCommandFlag::AdminOnly );
void admin_forceswap( const CCommand@ pArgs )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	if ( pArgs.ArgC() >= 2 )
	{
		if ( !bAutoBalance )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "* No se pueden realizar cambios de equipo en este mapa\n" );
			return;
		}
		
		CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
		if ( gData is null )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "* Error inesperado en el servidor\n" );
			return;
		}
		
		bool bMultiple = false;
		CBasePlayer@ pTarget = FindPlayer( pArgs[ 1 ], bMultiple );
		
		if ( bMultiple )
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "* Multiples jugadores encontrados. Se mas especifico\n" );
		else if ( pTarget !is null )
		{
			// Get now the target's and the admin's name and steamid
			string aname = pPlayer.pev.netname;
			string asteamid = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			string tname = pTarget.pev.netname;
			string tsteamid = g_EngineFuncs.GetPlayerAuthId( pTarget.edict() );
			
			if ( pTarget.pev.targetname == 'spiral' )
			{
				pTarget.TakeDamage( gData.pev, gData.pev, 10000.0, DMG_LAUNCH );
				score_crimson--;
				
				pTarget.pev.targetname = "crimson";
				pTarget.KeyValue( "classify", "5" );
				g_PlayerFuncs.ClientPrint( pTarget, HUD_PRINTTALK, "* Ahora juegas para el equipo Crimson\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
				eModel.Use( pTarget, pTarget, USE_TOGGLE );
				
				iSwaps[ pTarget.entindex() ]++;
				
				g_Game.AlertMessage( at_logged, "[TPvP] " + aname + " (" + asteamid + ") cambio de equipo a " + tname + " (" + tsteamid + ") al equipo CRIMSON\n" );
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "ADMIN " + aname + ": " + tname + " cambiado al equipo CRIMSON\n" );
			}
			else if ( pTarget.pev.targetname == 'crimson' )
			{
				pTarget.TakeDamage( gData.pev, gData.pev, 10000.0, DMG_LAUNCH );
				score_spiral--;
				
				pTarget.pev.targetname = "spiral";
				pTarget.KeyValue( "classify", "4" );
				g_PlayerFuncs.ClientPrint( pTarget, HUD_PRINTTALK, "* Ahora juegas para el equipo Spiral\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
				eModel.Use( pTarget, pTarget, USE_TOGGLE );
				
				iSwaps[ pTarget.entindex() ]++;
				
				g_Game.AlertMessage( at_logged, "[TPvP] " + aname + " (" + asteamid + ") cambio de equipo a " + tname + " (" + tsteamid + ") al equipo SPIRAL\n" );
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "ADMIN " + aname + ": " + tname + " cambiado al equipo SPIRAL\n" );
			}
			else if ( pTarget.pev.targetname == 'observer' )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "* " + tname + " es un Observador y no se lo puede cambiar de equipo\n" );
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "* Error inesperado en el servidor\n" );
		}
	}
	else
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "* Modo de uso: .forceswap <Nombre> - Obliga al jugador a cambiarse de equipo\n" );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	ClientSayType type = pParams.GetSayType();
	int index = pPlayer.entindex();
	
	if ( type == CLIENTSAY_SAY )
	{
		string text = pParams.GetCommand();
		if ( text == '/swap' )
		{
			pParams.ShouldHide = true;
			MM_Swap( pPlayer.entindex() );
			return HOOK_CONTINUE;
		}
		else if ( text == '/auto' )
		{
			pParams.ShouldHide = true;
			MM_Auto( pPlayer.entindex() );
			return HOOK_CONTINUE;
		}
		else if ( text == '/spectate' )
		{
			pParams.ShouldHide = true;
			MM_Observe( pPlayer.entindex() );
			return HOOK_CONTINUE;
		}
		else if ( text == '/stats' )
		{
			pParams.ShouldHide = true;
			MM_Stats( pPlayer.entindex() );
			return HOOK_CONTINUE;
		}
		else if ( text == '/character' )
		{
			pParams.ShouldHide = true;
			MM_Character( pPlayer.entindex() );
			return HOOK_CONTINUE;
		}
		else if ( text == '/ahide' )
		{
			pParams.ShouldHide = true;
			
			AdminLevel_t alevel = g_PlayerFuncs.AdminLevel( pPlayer );
			if ( alevel == ADMIN_YES || alevel == ADMIN_OWNER )
			{
				if ( !adm_hide[ index ] )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Visualizacion de mensajes de equipo ajenos: DESACTIVADO\n" );
					adm_hide[ index ] = true;
				}
				else
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Visualizacion de mensajes de equipo ajenos: ACTIVADO\n" );
					adm_hide[ index ] = false;
				}
			}
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Acceso denegado\n" );
			
			return HOOK_CONTINUE;
		}
		else if ( text == '/shop' )
		{
			pParams.ShouldHide = true;
			CPMenu( pPlayer.entindex() );
			return HOOK_HANDLED;
		}
		else if ( text == '/nv' )
		{
			pParams.ShouldHide = true;
			if ( bHasNightvision[ pPlayer.entindex() ] )
			{
				if ( !bIsNightvisionOn[ pPlayer.entindex() ] )
				{
					bIsNightvisionOn[ pPlayer.entindex() ] = true;
					NV_Think( pPlayer.entindex() );
				}
				else
				{
					bIsNightvisionOn[ pPlayer.entindex() ] = false;
					g_PlayerFuncs.ScreenFade( pPlayer, Vector( 0, 250, 0 ), 0.0, 0.20, 64, FFADE_IN );
				}
			}
			return HOOK_HANDLED;
		}
		else if ( text == '/hats' )
		{
			pParams.ShouldHide = true;
			
			if ( bIsCPActive[ pPlayer.entindex() ] )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero apaga tu Paquete Cosmetico\n" );
			else
				CP_Hats( pPlayer.entindex() );
			
			return HOOK_HANDLED;
		}
		else if ( text == '/cp' )
		{
			pParams.ShouldHide = true;
			
			if ( bHasCosmeticPack[ pPlayer.entindex() ] )
				CP_Pack_Toggle( pPlayer.entindex() );
			
			return HOOK_HANDLED;
		}
		else if ( text == '/menu' )
		{
			pParams.ShouldHide = true;
			MainMenu( pPlayer.entindex() );
			return HOOK_HANDLED;
		}
		else if ( text == '/help' )
		{
			pParams.ShouldHide = true;
			MM_Help( pPlayer.entindex() );
			return HOOK_HANDLED;
		}
		else
		{
			// Check for commands with arguments
			const CCommand@ args = pParams.GetArguments();
			if ( args[ 0 ] == '/glow' )
			{
				GlowCommand( pParams );
				return HOOK_HANDLED;
			}
			else if ( args[ 0 ] == '/trail' )
			{
				TrailCommand( pParams );
				return HOOK_HANDLED;
			}
			else if ( args[ 0 ] == '/inspect' )
			{
				InspectPlayer( pParams );
				return HOOK_HANDLED;
			}
			else if ( args[ 0 ] == '/duel' )
			{
				DuelPlayer( pParams );
				return HOOK_HANDLED;
			}
		}
		
		if ( !pPlayer.IsAlive() )
		{
			if ( !bDeadChat )
			{
				pParams.ShouldHide = true;
				
				if ( text.Length() == 0 )
					return HOOK_CONTINUE;
				
				for ( int i = 1; i <= g_Engine.maxClients; i++ )
				{
					CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
					
					if ( iPlayer !is null && iPlayer.IsConnected() )
					{
						if ( !iPlayer.IsAlive() )
						{
							g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "*DEAD* " + pPlayer.pev.netname + ": " + text + "\n" );
						}
						else
						{
							AdminLevel_t alevel = g_PlayerFuncs.AdminLevel( iPlayer );
							
							// Admins should still be able to see messages
							if ( alevel == ADMIN_YES || alevel == ADMIN_OWNER )
								g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "*DEAD* " + pPlayer.pev.netname + ": " + text + "\n" );
						}
					}
				}
				
				g_Game.AlertMessage( at_logged, "*DEAD* " + pPlayer.pev.netname + ": " + text + "\n" );
			}
		}
	}
	else if ( type == CLIENTSAY_SAYTEAM )
	{
		pParams.ShouldHide = true;
		string tname = pPlayer.pev.targetname;
		string text = pParams.GetCommand();
		
		if ( text.Length() == 0 )
			return HOOK_CONTINUE;
		
		if ( tname == 'spiral' )
		{
			for ( int i = 1; i <= g_Engine.maxClients; i++ )
			{
				CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
				
				if ( iPlayer !is null && iPlayer.IsConnected() )
				{
					tname = iPlayer.pev.targetname;
					if ( tname == 'spiral' )
					{
						if ( !bDeadChat )
						{
							if ( !pPlayer.IsAlive() )
							{
								if ( !iPlayer.IsAlive() )
									g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "*DEAD* (Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
							}
							else
								g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "(Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
						}
						else
							g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "(Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
					}
					else
					{
						AdminLevel_t alevel = g_PlayerFuncs.AdminLevel( iPlayer );
						
						// Admins should still be able to see messages
						if ( alevel == ADMIN_YES || alevel == ADMIN_OWNER )
						{
							if ( !adm_hide[ i ] )
							{
								if ( !pPlayer.IsAlive() )
									g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "*DEAD* (Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
								else
									g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "(Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
							}
						}
					}
				}
			}
			
			if ( !pPlayer.IsAlive() )
				g_Game.AlertMessage( at_logged, "*DEAD* (Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
			else
				g_Game.AlertMessage( at_logged, "(Spiral) " + pPlayer.pev.netname + ": " + text + "\n" );
		}
		else if ( tname == 'crimson' )
		{
			for ( int i = 1; i <= g_Engine.maxClients; i++ )
			{
				CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
				
				if ( iPlayer !is null && iPlayer.IsConnected() )
				{
					tname = iPlayer.pev.targetname;
					if ( tname == 'crimson' )
					{
						if ( !bDeadChat )
						{
							if ( !pPlayer.IsAlive() )
							{
								if ( !iPlayer.IsAlive() )
									g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "*DEAD* (Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
							}
							else
								g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "(Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
						}
						else
							g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "(Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
					}
					else
					{
						AdminLevel_t alevel = g_PlayerFuncs.AdminLevel( iPlayer );
						
						// Admins should still be able to see messages
						if ( alevel == ADMIN_YES || alevel == ADMIN_OWNER )
						{
							if ( !adm_hide[ i ] )
							{
								if ( !pPlayer.IsAlive() )
									g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "*DEAD* (Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
								else
									g_PlayerFuncs.ClientPrint( iPlayer, HUD_PRINTTALK, "(Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
							}
						}
					}
				}
			}
			
			if ( !pPlayer.IsAlive() )
				g_Game.AlertMessage( at_logged, "*DEAD* (Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
			else
				g_Game.AlertMessage( at_logged, "(Crimson) " + pPlayer.pev.netname + ": " + text + "\n" );
		}
	}
	
	return HOOK_CONTINUE;
}

void MainMenu( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, MainMenu_CB );
	state.menu.SetTitle( "Menu Principal\n\nNivel: " + iLevel[ index ] + "\n\n" );
	
	state.menu.AddItem( "Cambiar de equipo\n", any( "item1" ) );
	state.menu.AddItem( "Cambio automatico de equipo [ " + ( bAutoChange[ index ] ? "SI" : "NO" ) + " ]\n\n", any( "item2" ) );
	state.menu.AddItem( "Observar\n", any( "item3" ) );
	state.menu.AddItem( "Cantidad de jugadores\n\n", any( "item4" ) );
	state.menu.AddItem( "Mi personaje\n\n", any( "item5" ) );
	state.menu.AddItem( "Tienda\n", any( "item6" ) );
	if ( bHasCosmeticPack[ index ] ) state.menu.AddItem( "Paquete Cosmetico\n\n", any( "item7" ) );
	state.menu.AddItem( "Lista de Comandos", any( "item8" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void MainMenu_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
		g_Scheduler.SetTimeout( "MM_Swap", 0.01, index );
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "MM_Auto", 0.01, index );
	else if ( selection == 'item3' )
		g_Scheduler.SetTimeout( "MM_Observe", 0.01, index );
	else if ( selection == 'item4' )
		g_Scheduler.SetTimeout( "MM_Stats", 0.01, index );
	else if ( selection == 'item5' )
		g_Scheduler.SetTimeout( "MM_Character", 0.01, index );
	else if ( selection == 'item6' )
		g_Scheduler.SetTimeout( "CPMenu", 0.01, index );
	else if ( selection == 'item7' )
		g_Scheduler.SetTimeout( "CP_Pack_Main", 0.01, index );
	else if ( selection == 'item8' )
		g_Scheduler.SetTimeout( "MM_Help", 0.01, index );
}

void MM_Swap( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( !bAutoBalance )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No puedes cambiar de equipo en este mapa\n" );
		return;
	}
	
	if ( iSwaps[ index ] < 3 )
	{
		CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
		if ( gData is null )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Error inesperado en el servidor\n" );
			return;
		}
		
		if ( pPlayer.pev.targetname == 'spiral' )
		{
			pPlayer.TakeDamage( gData.pev, gData.pev, 10000.0, DMG_LAUNCH );
			score_crimson--;
			
			pPlayer.pev.targetname = "crimson";
			pPlayer.KeyValue( "classify", "5" );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Ahora juegas para el equipo Crimson\n" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
			eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
			
			iSwaps[ index ]++;
			
		}
		else if ( pPlayer.pev.targetname == 'crimson' )
		{
			pPlayer.TakeDamage( gData.pev, gData.pev, 10000.0, DMG_LAUNCH );
			score_spiral--;
			
			pPlayer.pev.targetname = "spiral";
			pPlayer.KeyValue( "classify", "4" );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Ahora juegas para el equipo Spiral\n" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
			eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
			
			iSwaps[ index ]++;
		}
		else if ( pPlayer.pev.targetname == 'observer' )
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Debes entrar a la partida\n" );
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Error inesperado en el servidor\n" );
	}
	else
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Solo se permite un maximo de 3 cambios de equipo por mapa\n" );
}

void MM_Auto( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( !bAutoBalance )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No puedes ajustar el cambio automatico de equipo en este mapa\n" );
		return;
	}
	
	if ( !bAutoChange[ index ] )
	{
		bAutoChange[ index ] = true;
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Cambio automatico de equipo: ACTIVADO\n" );
	}
	else
	{
		bAutoChange[ index ] = false;
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Cambio automatico de equipo: DESACTIVADO\n" );
	}
}

void MM_Observe( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( g_EngineFuncs.CVarGetFloat( "mp_observer_mode" ) == 0.0 )
	{
		if ( !pPlayer.IsAlive() )
		{
			if ( !bSpectate[ index ] )
			{
				bSpectate[ index ] = true;
				
				g_Scheduler.SetTimeout( "SpectateFix", 0.05, pPlayer.entindex() );
				pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
				g_Scheduler.SetTimeout( "SpectateFix", 0.10, pPlayer.entindex() );
				
				pPlayer.pev.targetname = "observer";
			}
			else
			{
				bSpectate[ index ] = false;
				pPlayer.m_flRespawnDelayTime = 0.0f; // Let game handle respawn
			}
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Debes estar muerto\n" );
	}
	else
	{
		if ( bDuelVote )
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No! Hay combatientes en medio de un duelo!\n" );
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No puedes observar en este mapa\n" );
	}
}

void MM_Stats( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Spirals: " + spirals + " jugador(es) ~ Crimsons: " + crimsons + " jugador(es)\n" );
}

void MM_Character( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, MM_Character_CB );
	
	string title = "Mi personaje\n\n";
	title += g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + "\n\n";
	
	title += "Nivel " + iLevel[ index ] + "\n";
	title += "Siguiente nivel a " + AddCommas( iRemainingXP[ index ] ) + " EXP\n\n";
	
	title += "Bonos disponibles:\n";
	if ( iLevel[ index ] < 10 ) title += "<ninguno>";
	if ( iLevel[ index ] >= 10 ) title += "\n- Resistencia a las caidas: " + iFalldamageResist[ index ] + "%";
	if ( iLevel[ index ] >= 12 ) title += "\n- Proteccion de spawn: " + fl2Decimals( flSpawnProtectionTime[ index ] ) + " seg.";
	if ( iLevel[ index ] >= 21 ) title += "\n- Resistencia Critica: " + iCriticalResist[ index ] + "%";
	if ( iLevel[ index ] >= 16 ) title += "\n- EquipoRegeneracion de Vida: " + iTeamHPReg[ index ] + "%";
	if ( iLevel[ index ] >= 17 ) title += "\n- EquipoRegeneracion de Armadura: " + iTeamHPReg[ index ] + "%";
	
	if ( iLevel[ index ] >= 22 ) title += "\n- Velocidad de Bomba C4: +";
	if ( iLevel[ index ] >= 78 ) title += "8%";
	else if ( iLevel[ index ] >= 62 ) title += "6%";
	else if ( iLevel[ index ] >= 41 ) title += "4%";
	else if ( iLevel[ index ] >= 22 ) title += "2%";
	
	if ( iLevel[ index ] >= 23 ) title += "\n- Velocidad de Captura: +";
	if ( iLevel[ index ] >= 79 ) title += "8%";
	else if ( iLevel[ index ] >= 64 ) title += "6%";
	else if ( iLevel[ index ] >= 42 ) title += "4%";
	else if ( iLevel[ index ] >= 23 ) title += "2%";
	
	if ( iLevel[ index ] >= 27 ) title += "\n- Vida Maxima: +" + iExtraMaxHP[ index ];
	if ( iLevel[ index ] >= 34 ) title += "\n- Armadura Maxima: +" + iExtraMaxAP[ index ];
	
	if ( iLevel[ index ] >= 100 ) title += "\n- Vida Inicial: +" + iExtraStartHP[ index ];
	
	title += "\n\nEmpezaste a jugar el dia\n";
	title += GetSpanishDate( dtFirstPlay[ index ] ) + "\n";
	
	state.menu.SetTitle( title );
	state.menu.AddItem( "Informacion de los Bonos", any( "item1" ) );
	state.menu.AddItem( "Volver al Menu Principal", any( "item2" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void MM_Character_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	
	if ( selection == 'item1' )
		g_Scheduler.SetTimeout( "XP_Info", 0.01, index );
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "MainMenu", 0.01, index );
}

void InspectPlayer( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	int index = pPlayer.entindex();
	
	const CCommand@ args = pParams.GetArguments();
	
	if ( args.ArgC() > 1 )
	{
		bool bMultiple = false;
		CBasePlayer@ pTarget = FindPlayer( args[ 1 ], bMultiple );
		
		if ( bMultiple )
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Multiples jugadores encontrados. Se mas especifico\n" );
		else if ( pTarget !is null )
		{
			if ( pTarget is pPlayer )
			{
				g_Scheduler.SetTimeout( "MM_Character", 0.01, index );
				return;
			}
			
			MenuHandler@ state = MenuGetPlayer( pPlayer );
			state.InitMenu( pPlayer, InspectPlayer_CB );
			
			int target_index = pTarget.entindex();
			
			string title = string( pTarget.pev.netname ) + "\n\n";
			title += g_EngineFuncs.GetPlayerAuthId( pTarget.edict() ) + "\n\n";
			
			title += "Nivel " + iLevel[ target_index ] + "\n";
			title += "Siguiente nivel a " + AddCommas( iRemainingXP[ target_index ] ) + " EXP\n\n";
			
			title += "Bonos disponibles:\n";
			if ( iLevel[ target_index ] < 10 ) title += "<ninguno>";
			if ( iLevel[ target_index ] >= 10 ) title += "\n- Resistencia a las caidas: " + iFalldamageResist[ target_index ] + "%";
			if ( iLevel[ target_index ] >= 12 ) title += "\n- Proteccion de spawn: " + fl2Decimals( flSpawnProtectionTime[ target_index ] ) + " seg.";
			if ( iLevel[ target_index ] >= 21 ) title += "\n- Resistencia Critica: " + iCriticalResist[ target_index ] + "%";
			if ( iLevel[ target_index ] >= 16 ) title += "\n- EquipoRegeneracion de Vida: " + iTeamHPReg[ target_index ] + "%";
			if ( iLevel[ target_index ] >= 17 ) title += "\n- EquipoRegeneracion de Armadura: " + iTeamHPReg[ target_index ] + "%";
			
			if ( iLevel[ target_index ] >= 22 ) title += "\n- Velocidad de Bomba C4: +";
			if ( iLevel[ target_index ] >= 78 ) title += "8%";
			else if ( iLevel[ target_index ] >= 62 ) title += "6%";
			else if ( iLevel[ target_index ] >= 41 ) title += "4%";
			else if ( iLevel[ target_index ] >= 22 ) title += "2%";
			
			if ( iLevel[ target_index ] >= 23 ) title += "\n- Velocidad de Captura: +";
			if ( iLevel[ target_index ] >= 79 ) title += "8%";
			else if ( iLevel[ target_index ] >= 64 ) title += "6%";
			else if ( iLevel[ target_index ] >= 42 ) title += "4%";
			else if ( iLevel[ target_index ] >= 23 ) title += "2%";
			
			if ( iLevel[ target_index ] >= 27 ) title += "\n- Vida Maxima: +" + iExtraMaxHP[ target_index ];
			if ( iLevel[ target_index ] >= 34 ) title += "\n- Armadura Maxima: +" + iExtraMaxAP[ target_index ];
			
			if ( iLevel[ target_index ] >= 100 ) title += "\n- Vida Inicial: +" + iExtraStartHP[ target_index ];
			
			title += "\n\nEmpezo a jugar el dia\n";
			title += GetSpanishDate( dtFirstPlay[ target_index ] ) + "\n";
			
			state.menu.SetTitle( title );
			state.menu.AddItem( "Mi personaje", any( "item1" ) );
			state.menu.AddItem( "Volver al Menu Principal", any( "item2" ) );
			
			state.OpenMenu( pPlayer, 0, 0 );
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Jugador no encontrado\n" );
	}
	else
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Modo de uso: /inspect <Jugador>\n" );
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Muestra informacion adicional sobre el jugador especificado\n" );
	}
}

void InspectPlayer_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	
	if ( selection == 'item1' )
		g_Scheduler.SetTimeout( "MM_Character", 0.01, index );
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "MainMenu", 0.01, index );
}

void XP_Info( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	string szInfo = "ACLARACION: La lista de bonos excluye los articulos cosmeticos y los descuentos en la Tienda";
	szInfo += "\n\n1. Resistencia a las caidas:\n   Disminuye el danio por caida (Falldamage)";
	szInfo += "\n\n2. Proteccion de spawn:\n   Te protege temporalmente contra cualquier danio inicial al respawnear";
	szInfo += "\n\n3. Resistencia Critica:\n   Probabilidad de sobrevivir un golpe fatal con 1 HP";
	szInfo += "\n\n4. EquipoRegeneracion de Vida:\n   Regenera vida a aliados cercanos al respawnear";
	szInfo += "\n\n5. EquipoRegeneracion de Armadura:\n   Regenera armadura a aliados cercanos al respawnear";
	szInfo += "\n\n6. Velocidad de Bomba C4:\n   Te permite detonar y/o desarmar bombas C4 con mas rapidez";
	szInfo += "\n\n7. Velocidad de Captura:\n   Te permite capturar y/o descapturar Puntos de Control con mas rapidez";
	
	ShowMOTD( pPlayer, "Informacion de los Bonos", szInfo );
}

void MM_Help( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	string szInfo = "/swap\n   Te cambia de equipo";
	szInfo += "\n\n/auto\n   Activa/Desactiva el cambio automatico de equipo";
	szInfo += "\n\n/spectate\n   Te pone en observador";
	szInfo += "\n\n/stats\n   Muestra la cantidad de jugadores presentes en cada equipo";
	szInfo += "\n\n/character\n   Muestra un resumen de tu personaje";
	szInfo += "\n\n/shop\n   Abre la Tienda";
	szInfo += "\n\n/menu\n   Todos los comandos aqui mencionados, resumidos en un menu para usar";
	
	ShowMOTD( pPlayer, "Lista de Comandos", szInfo );
}

void DuelPlayer( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	int index = pPlayer.entindex();
	
	if ( bDuelVote )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Peticion de duelo en progreso o duelo ya activo. Espera unos minutos\n" );
		return;
	}
	else if ( bAskedDuel[ index ] )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Este comando solo puede ser usado 1 vez por mapa\n" );
		return;
	}
	else if ( iCP[ index ] < 300 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No tienes Creditos suficientes para pedir un duelo (Necesitas: 300 C)\n" );
		return;
	}
	else if ( !bAutoBalance )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No puedes hacer duelos en este mapa\n" );
		return;
	}
	
	const CCommand@ args = pParams.GetArguments();
	
	if ( args.ArgC() > 1 )
	{
		bool bMultiple = false;
		CBasePlayer@ pTarget = FindPlayer( args[ 1 ], bMultiple );
		
		if ( bMultiple )
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Multiples jugadores encontrados. Se mas especifico\n" );
		else if ( pTarget !is null )
		{
			if ( pTarget is pPlayer )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Desafiarte a ti mismo? No te han golpeado la cabeza muy fuerte?\n" );
				return;
			}
			
			if ( iCP[ pTarget.entindex() ] < 300 )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tu adversario no puede pagar los costos del duelo y no puede ser desafiado\n" );
				return;
			}
			
			MenuHandler@ state = MenuGetPlayer( pPlayer );
			state.InitMenu( pPlayer, DuelPlayer_CB );
			
			string title = "Alto ahi!\n\n";
			
			title += "Los duelos son tema serio.\n";
			if ( g_PlayerFuncs.GetNumPlayers() > 2 )
			{
				title += "No le gustara a los demas jugadores\n";
				title += "que no puedan jugar debido a un reto.\n";
			}
			
			title += "\nHay precios que se pagan antes de cada duelo.\n";
			
			title += "Ambas partes pagan 300 Creditos.\n";
			title += "Tu pagas " + iLevel[ index ] * 6 + " EXP.\n";
			title += "Tu adversario paga " + iLevel[ pTarget.entindex() ] * 6 + " EXP.\n\n";
			
			title += "Si eres victorioso, ganaras 600 Creditos y " + ( ( iLevel[ index ] * 6 ) + ( iLevel[ pTarget.entindex() ] * 6 ) ) + " EXP.\n";
			title += "Si eres derrotado, te vas con las manos vacias!\n";
			title += "Desconectarse durante el duelo es considerado como DERROTA.\n\n";
			
			title += "Realmente quieres desafiar a " + pTarget.pev.netname + "?\n";
			
			state.menu.SetTitle( title );
			state.menu.AddItem( "Desafiar!", any( string( pTarget.pev.netname ) ) );
			state.menu.AddItem( "Mejor no...", any( "dummy" ) );
			
			state.OpenMenu( pPlayer, 0, 0 );
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Jugador no encontrado\n" );
	}
	else
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Modo de uso: /duel <Jugador>\n" );
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Reta al jugador especificado a un combate 1 contra 1\n" );
	}
}

void DuelPlayer_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'dummy' )	return;
	
	bool bFUCKTHISSHIT = false;
	bool bMultiple = false;
	CBasePlayer@ pTarget = FindPlayer( selection, bMultiple );
	if ( bMultiple )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Error inesperado en el servidor\n" );
		return;
	}
	else if ( pTarget !is null )
	{
		CBaseEntity@ pEntity = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pEntity = g_EntityFuncs.Instance( i );
			if ( pEntity !is null )
			{
				if ( pEntity.IsPlayer() )
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "vox/deeoo.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
			}
		}
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* ATENCION! " + pPlayer.pev.netname + " ha desafiado a " + pTarget.pev.netname + " a un duelo!\n" );
		bDuelVote = true;
		bAskedDuel[ pPlayer.entindex() ] = true;
		
		MenuHandler@ state = MenuGetPlayer( pTarget );
		state.InitMenu( pTarget, DuelConfirm_CB );
		
		string title = "Has sido desafiado a un duelo!\n\n";
		
		title += "Los duelos son tema serio.\n";
		if ( g_PlayerFuncs.GetNumPlayers() > 2 )
		{
			title += "No le gustara a los demas jugadores\n";
			title += "que no puedan jugar debido a un reto.\n";
		}
		
		title += "\nHay precios que se pagan antes de cada duelo.\n";
		
		title += "Ambas partes pagan 300 Creditos.\n";
		title += "Tu pagas " + iLevel[ pTarget.entindex() ] * 6 + " EXP.\n";
		title += "Tu retador paga " + iLevel[ pPlayer.entindex() ] * 6 + " EXP.\n\n";
		
		title += "Si eres victorioso, ganaras 600 Creditos y " + ( ( iLevel[ pTarget.entindex() ] * 6 ) + ( iLevel[ pPlayer.entindex() ] * 6 ) ) + " EXP.\n";
		title += "Si eres derrotado, te vas con las manos vacias!\n";
		title += "Desconectarse durante el duelo es considerado como DERROTA.\n\n";
		
		title += "Aceptar el desafio de " + pPlayer.pev.netname + "?\n";
		
		state.menu.SetTitle( title );
		state.menu.AddItem( "Acepto!", any( string( pPlayer.pev.netname ) ) );
		state.menu.AddItem( "Me rehuso", any( "dummy" ) );
		
		state.OpenMenu( pTarget, 20, 0 );
		g_Scheduler.SetTimeout( "DuelCancel", 20.0 );
	}
	else
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Jugador no encontrado\n" );
}

void DuelCancel()
{
	if ( g_EngineFuncs.CVarGetFloat( "mp_timelimit" ) == 0.0 )
		return;
	
	CBaseEntity@ pEntity = null;
	for ( int i = 0; i < 33; i++ )
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
				g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "vox/deeoo.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
		}
	}
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* La peticion de duelo ha sido rechazada!\n" );
	bDuelVote = false;
}

void DuelConfirm_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'dummy' )	return;
	
	bool bFUCKTHISSHIT = false;
	bool bMultiple = false;
	CBasePlayer@ pTarget = FindPlayer( selection, bMultiple );
	if ( bMultiple )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Error inesperado en el servidor\n" );
		return;
	}
	else if ( pTarget !is null )
	{
		int iPlayerIndex = pPlayer.entindex();
		int iTargetIndex = pTarget.entindex();
		
		CBaseEntity@ pEntity = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pEntity = g_EntityFuncs.Instance( i );
			if ( pEntity !is null )
			{
				if ( pEntity.IsPlayer() )
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "vox/bizwarn.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
			}
		}
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* ATENCION! " + pPlayer.pev.netname + " ha aceptado el desafio de " + pTarget.pev.netname + "! DUELO INMINENTE!\n" );
		
		// Prepare duel mode
		// CVars
		g_EngineFuncs.CVarSetFloat( "mp_timelimit", 0.0 );
		g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1.0 );
		g_EngineFuncs.ServerCommand( "map_rtv_percent 0\n" );
		
		// Spawns
		@pEntity = null;
		while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "info_player_deathmatch" ) ) !is null )
		{
			pEntity.pev.spawnflags = 24; // Filter player targetname + Invert Filter
			pEntity.pev.message = "observer";
		}
		
		// Players
		@pEntity = null;
		while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "player" ) ) !is null )
		{
			// Everyone but the challenger and the challenged
			if ( pEntity !is pTarget && pEntity !is pPlayer )
				pEntity.pev.targetname = "observer";
		}
		
		// If the players are on the same team, swap the challenged
		if ( pPlayer.pev.targetname == 'crimson' && pTarget.pev.targetname == 'crimson' )
		{
			pPlayer.pev.targetname = "spiral";
			pPlayer.KeyValue( "classify", "4" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
			eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
		}
		else if ( pPlayer.pev.targetname == 'spiral' && pTarget.pev.targetname == 'spiral' )
		{
			pPlayer.pev.targetname = "crimson";
			pPlayer.KeyValue( "classify", "5" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
			eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
		}
		
		// XP Price Pool
		iRemainingXP[ iPlayerIndex ] += ( iLevel[ iPlayerIndex ] * 6 );
		iRemainingXP[ iTargetIndex ] += ( iLevel[ iTargetIndex ] * 6 );
		iDuelXPPool += ( iLevel[ iPlayerIndex ] * 6 );
		iDuelXPPool += ( iLevel[ iTargetIndex ] * 6 );
		
		// Prepare credits
		iCP[ iPlayerIndex ] -= 300;
		iCP[ iTargetIndex ] -= 300;
		
		// Save NOW
		XP_SaveData( iPlayerIndex );
		XP_SaveData( iTargetIndex );
		
		// HUD Message
		HUDTextParams tpDuel;
		tpDuel.x = -1;
		tpDuel.y = 0.3;
		tpDuel.effect = 1;
		tpDuel.r1 = 255;
		tpDuel.g1 = 255;
		tpDuel.b1 = 255;
		tpDuel.a1 = 0;
		tpDuel.r2 = 255;
		tpDuel.g2 = 0;
		tpDuel.b2 = 0;
		tpDuel.a2 = 255;
		tpDuel.fadeinTime = 1.0;
		tpDuel.fadeoutTime = 0.0;
		tpDuel.holdTime = 4.0;
		tpDuel.fxTime = 0.0;
		tpDuel.channel = 8;
		g_PlayerFuncs.HudMessageAll( tpDuel, "DUELO INMINENTE!" );
		
		g_Scheduler.SetTimeout( "DuelCountdown", 5.00, iPlayerIndex, iTargetIndex, 10 );
	}
	else
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Jugador no encontrado\n" );
}

void DuelCountdown( const int& in iPlayerIndex, const int& in iTargetIndex, int& in iStartTime )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );
	CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex( iTargetIndex );
	
	if ( pPlayer is null && pTarget is null )
	{
		// HOW IN THE FUCK.
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* WTF BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOM\n" );
		g_EngineFuncs.ServerCommand( "restart\n" );
		return;
	}
	
	if ( pPlayer is null )
	{
		// Challenged left!
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* El desafiado se ha ido! Se asume derrota! " + pTarget.pev.netname + " es el ganador!\n" );
		DuelEnd( iTargetIndex );
		return;
	}
	
	if ( pTarget is null )
	{
		// Challenger left!
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* El desafiante se ha ido! Se asume derrota! " + pPlayer.pev.netname + " es el ganador!\n" );
		DuelEnd( iPlayerIndex );
		return;
	}
	
	// Init HUD
	HUDTextParams tpDuel;
	tpDuel.x = -1;
	tpDuel.y = 0.3;
	tpDuel.effect = 0;
	tpDuel.r1 = 0;
	tpDuel.g1 = 255;
	tpDuel.b1 = 0;
	tpDuel.a1 = 0;
	tpDuel.r2 = 0;
	tpDuel.g2 = 0;
	tpDuel.b2 = 0;
	tpDuel.a2 = 0;
	tpDuel.fadeinTime = 0.0;
	tpDuel.fadeoutTime = 0.0;
	tpDuel.holdTime = 2.0;
	tpDuel.fxTime = 0.0;
	tpDuel.channel = 8;
	
	// Message
	string szMessage = "DUELO!\n\n" + pTarget.pev.netname + " |VS| " + pPlayer.pev.netname + "\n\n";
	if ( iStartTime > 0 )
	{
		szMessage += "El combate empieza en " + iStartTime + "\n";
		CBaseEntity@ pEntity = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pEntity = g_EntityFuncs.Instance( i );
			if ( pEntity !is null )
			{
				if ( pEntity.IsPlayer() )
				{
					switch ( iStartTime )
					{
						case 10: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/ten.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 9: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/nine.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 8: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/eight.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 7: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/seven.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 6: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/six.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 5: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/five.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 4: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/four.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 3: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/three.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 2: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/two.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
						case 1: g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "fvox/one.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() ); break;
					}
				}
			}
		}
	}
	else if ( iStartTime == 0 )
	{
		szMessage += "FIGHT!\n";
		CBaseEntity@ pEntity = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pEntity = g_EntityFuncs.Instance( i );
			if ( pEntity !is null )
			{
				if ( pEntity.IsPlayer() )
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "barney/ba_bring.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
			}
		}
	}
	else
	{
		// Manage players
		CBaseEntity@ pEntity = null;
		while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "player" ) ) !is null )
		{
			// Kill all players that are still alive and reset score/deaths
			pEntity.TakeDamage( pEntity.pev, pEntity.pev, 10000.0, DMG_ALWAYSGIB );
			pEntity.pev.frags = 0.0;
			cast< CBasePlayer@ >( pEntity ).m_iDeaths = 0;
		}
		
		// Start duel!
		score_spiral = 0;
		score_crimson = 0;
		DuelCheck( iTargetIndex, iPlayerIndex, 600 );
		return;
	}
	
	g_PlayerFuncs.HudMessageAll( tpDuel, szMessage );
	iStartTime--;
	g_Scheduler.SetTimeout( "DuelCountdown", 1.0, iPlayerIndex, iTargetIndex, iStartTime );
}

void DuelCheck( const int& in iPlayerIndex, const int& in iTargetIndex, int& in iDuelTime )
{
	if ( !bDuelVote )
		return;
	
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );
	CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex( iTargetIndex );
	
	if ( pPlayer is null && pTarget is null )
	{
		// HOW IN THE FUCK.
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* WTF BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOM\n" );
		g_EngineFuncs.ServerCommand( "restart\n" );
		return;
	}
	
	if ( pPlayer is null )
	{
		// Challenged left!
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* El desafiado se ha ido! Se asume derrota! " + pTarget.pev.netname + " es el ganador!\n" );
		DuelEnd( iTargetIndex );
		return;
	}
	
	if ( pTarget is null )
	{
		// Challenger left!
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* El desafiante se ha ido! Se asume derrota! " + pPlayer.pev.netname + " es el ganador!\n" );
		DuelEnd( iPlayerIndex );
		return;
	}
	
	HUDTextParams rtime;
	rtime.x = -1;
	rtime.y = 0.85;
	rtime.effect = 0;
	rtime.r1 = 250;
	rtime.g1 = 250;
	rtime.b1 = 250;
	rtime.a1 = 250;
	rtime.r2 = 250;
	rtime.g2 = 250;
	rtime.b2 = 250;
	rtime.a2 = 250;
	rtime.fadeinTime = 0.0;
	rtime.fadeoutTime = 0.0;
	rtime.holdTime = 255.0;
	rtime.fxTime = 0.0;
	rtime.channel = 8;
	
	iDuelTime--;
	int seconds = iDuelTime;
	int minutes = 0;
	
	while ( seconds >= 60 )
	{
		seconds -= 60;
		minutes++;
	}
	
	string szTime1 = "0" + minutes + ":";
	string szTime2 = "";
	if ( seconds < 10 )
		szTime2 += "0" + seconds + "\n";
	else
		szTime2 += "" + seconds + "\n";
	
	if ( iDuelTime >= 0 )
		g_PlayerFuncs.HudMessageAll( rtime, "" + szTime1 + szTime2 + "\n" );
	else
		DuelEnd();
	
	g_Scheduler.SetTimeout( "DuelCheck", 1.0, iPlayerIndex, iTargetIndex, iDuelTime );
}

void DuelEnd( int& in iAutowinIndex = 0 )
{
	// Remove all map stuff
	CBaseEntity@ pEntity = null;
	string szClassname;
	for ( int i = 1; i < 2048; i++ ) // No deathmatch map should have more than this many entites
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
			{
				pEntity.pev.flags |= FL_GODMODE;
				cast< CBasePlayer@ >( pEntity ).RemoveAllItems( true );
			}
			else
			{
				szClassname = pEntity.pev.classname;
				if ( szClassname[ 0 ] == 'w' && szClassname[ 1 ] == 'e' && szClassname[ 2 ] == 'a' && szClassname[ 3 ] == 'p' && szClassname[ 4 ] == 'o' && szClassname[ 5 ] == 'n' && szClassname[ 6 ] == '_' )
					g_EntityFuncs.Remove( pEntity );
				else if ( szClassname[ 0 ] == 'a' && szClassname[ 1 ] == 'm' && szClassname[ 2 ] == 'm' && szClassname[ 3 ] == 'o' && szClassname[ 4 ] == '_' )
					g_EntityFuncs.Remove( pEntity );
				else if ( szClassname[ 0 ] == 'i' && szClassname[ 1 ] == 't' && szClassname[ 2 ] == 'e' && szClassname[ 3 ] == 'm' && szClassname[ 4 ] == '_' )
					g_EntityFuncs.Remove( pEntity );
				else if ( szClassname == 'c4' ) // Map-specific removal from here
				{
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_VOICE, "weapons/c4_beep5.wav", 0, ATTN_NONE, SND_STOP, 0 ); // Kill sound
					g_EntityFuncs.Remove( pEntity );
				}
				else if ( szClassname == 'sys_control_point' )
					g_EntityFuncs.Remove( pEntity );
			}
		}
	}
	
	// Dummys
	HUDTextParams tDummy;
	
	tDummy.channel = 5;
	g_PlayerFuncs.HudMessageAll( tDummy, " " );
	tDummy.channel = 6;
	g_PlayerFuncs.HudMessageAll( tDummy, " " );
	tDummy.channel = 7;
	g_PlayerFuncs.HudMessageAll( tDummy, " " );
	tDummy.channel = 8;
	g_PlayerFuncs.HudMessageAll( tDummy, " " );
	
	if ( iAutowinIndex > 0 )
	{
		// Autowin is set, skip and go to end screen
		HUDTextParams textParams;
		textParams.x = -1;
		textParams.y = 0.3;
		textParams.effect = 1;
		textParams.a1 = 250;
		textParams.r2 = 250;
		textParams.g2 = 250;
		textParams.b2 = 250;
		textParams.a2 = 250;
		textParams.fadeinTime = 0.0;
		textParams.fadeoutTime = 1.0;
		textParams.holdTime = 4.0;
		textParams.fxTime = 0.0;
		textParams.channel = 1;
		
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iAutowinIndex );
		if ( pPlayer.pev.targetname == 'spiral' )
		{
			textParams.r1 = 10;
			textParams.g1 = 200;
			textParams.b1 = 200;
			
			g_PlayerFuncs.HudMessageAll( textParams, "" + pPlayer.pev.netname + " es el ganador del duelo!" );
		}
		else if ( pPlayer.pev.targetname == 'crimson' )
		{
			textParams.r1 = 200;
			textParams.g1 = 100;
			textParams.b1 = 10;
			
			g_PlayerFuncs.HudMessageAll( textParams, "" + pPlayer.pev.netname + " es el ganador del duelo!" );
		}
		
		@pEntity = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pEntity = g_EntityFuncs.Instance( i );
			if ( pEntity !is null )
			{
				if ( pEntity.IsPlayer() )
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_WEAPON, "ecsc/tpvp/gameend_3.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
			}
		}
		
		g_Scheduler.SetTimeout( "DuelFinish3", 5.0, iAutowinIndex );
	}
	else
	{
		@pEntity = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pEntity = g_EntityFuncs.Instance( i );
			if ( pEntity !is null )
			{
				if ( pEntity.IsPlayer() )
				{
					pEntity.pev.flags |= FL_FROZEN;
					pEntity.pev.effects &= ~EF_DIMLIGHT;
					
					g_Scheduler.SetTimeout( "SND_Effect", 0.01, pEntity.entindex() );
				}
			}
		}
		
		g_Scheduler.SetTimeout( "DuelFinish1", 1.0 );
	}
	
	@pEntity = null;
	for ( int i = 0; i < 33; i++ )
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
				bAskedDuel[ i ] = true;
		}
	}
	bDuelVote = false;
}

void DuelFinish1()
{
	HUDTextParams textParams;
	textParams.x = -1;
	textParams.y = 0.4;
	textParams.effect = 0;
	textParams.r1 = 250;
	textParams.g1 = 250;
	textParams.b1 = 250;
	textParams.a1 = 0;
	textParams.r2 = 250;
	textParams.g2 = 250;
	textParams.b2 = 250;
	textParams.a2 = 0;
	textParams.fadeinTime = 0.0;
	textParams.fadeoutTime = 0.0;
	textParams.holdTime = 2.0;
	textParams.fxTime = 0.0;
	textParams.channel = 1;
	
	g_PlayerFuncs.HudMessageAll( textParams, "SE ACABO!" );
	
	g_Scheduler.SetTimeout( "DuelFinish2", 3.0 );
}

void DuelFinish2()
{
	HUDTextParams textParams;
	textParams.x = -1;
	textParams.y = 0.3;
	textParams.effect = 1;
	textParams.a1 = 250;
	textParams.r2 = 250;
	textParams.g2 = 250;
	textParams.b2 = 250;
	textParams.a2 = 250;
	textParams.fadeinTime = 0.0;
	textParams.fadeoutTime = 1.0;
	textParams.holdTime = 4.0;
	textParams.fxTime = 0.0;
	textParams.channel = 1;
	
	if ( score_spiral > score_crimson )
	{
		textParams.r1 = 10;
		textParams.g1 = 200;
		textParams.b1 = 200;
		
		CBasePlayer@ pPlayer = cast< CBasePlayer@ >( g_EntityFuncs.FindEntityByTargetname( null, "spiral" ) );
		if ( pPlayer !is null )
		{
			g_PlayerFuncs.HudMessageAll( textParams, "" + pPlayer.pev.netname + " es el ganador del duelo!" );
			g_Scheduler.SetTimeout( "DuelFinish3", 5.0, pPlayer.entindex() );
		}
		else
		{
			g_PlayerFuncs.HudMessageAll( textParams, "El Spiral es el ganador del duelo!" );
			g_Scheduler.SetTimeout( "DuelFinish3", 5.0, 0 );
		}
	}
	else if ( score_crimson > score_spiral )
	{
		textParams.r1 = 200;
		textParams.g1 = 100;
		textParams.b1 = 10;
		
		CBasePlayer@ pPlayer = cast< CBasePlayer@ >( g_EntityFuncs.FindEntityByTargetname( null, "crimson" ) );
		if ( pPlayer !is null )
		{
			g_PlayerFuncs.HudMessageAll( textParams, "" + pPlayer.pev.netname + " es el ganador del duelo!" );
			g_Scheduler.SetTimeout( "DuelFinish3", 5.0, pPlayer.entindex() );
		}
		else
		{
			g_PlayerFuncs.HudMessageAll( textParams, "El Crimson es el ganador del duelo!" );
			g_Scheduler.SetTimeout( "DuelFinish3", 5.0, 0 );
		}
	}
	else if ( score_spiral == score_crimson )
	{
		textParams.fadeinTime = 1.0;
		textParams.fadeoutTime = 1.0;
		textParams.holdTime = 3.0;
		textParams.effect = 0;
		
		textParams.r1 = 200;
		textParams.g1 = 200;
		textParams.b1 = 200;
		
		g_PlayerFuncs.HudMessageAll( textParams, "Es un empate! No hay ganadores en este duelo!" );
		
		g_Scheduler.SetTimeout( "DuelFinish3", 5.0, 1337 );
	}
	
	CBaseEntity@ pEntity = null;
	for ( int i = 0; i < 33; i++ )
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
				g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_WEAPON, "ecsc/tpvp/gameend_3.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
		}
	}
}

void DuelFinish3( const int& in iWinnerIndex )
{
	HUDTextParams textParams1;
	textParams1.x = -1;
	textParams1.y = 0.4;
	textParams1.effect = 2;
	textParams1.r1 = 250;
	textParams1.g1 = 200;
	textParams1.b1 = 10;
	textParams1.a1 = 0;
	textParams1.r2 = 250;
	textParams1.g2 = 250;
	textParams1.b2 = 250;
	textParams1.a2 = 0;
	textParams1.fadeinTime = 0.03;
	textParams1.fadeoutTime = 1.0;
	textParams1.holdTime = 255.0;
	textParams1.fxTime = 0.3;
	textParams1.channel = 1;
	
	HUDTextParams textParams2;
	textParams2.x = -1;
	textParams2.y = 0.3;
	textParams2.effect = 2;
	textParams2.r1 = 200;
	textParams2.g1 = 10;
	textParams2.b1 = 200;
	textParams2.a1 = 0;
	textParams2.r2 = 250;
	textParams2.g2 = 250;
	textParams2.b2 = 250;
	textParams2.a2 = 0;
	textParams2.fadeinTime = 0.03;
	textParams2.fadeoutTime = 1.0;
	textParams2.holdTime = 255.0;
	textParams2.fxTime = 0.3;
	textParams2.channel = 2;
	
	// Manual: Iterate through all players
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			// Get winner player
			if ( iWinnerIndex != 0 && iWinnerIndex != 1337 )
			{
				if ( i == iWinnerIndex )
				{
					// Prepare HUD message
					string szText1 = "Recompensa por victoria: " + AddCommas( iDuelXPPool ) + " EXP\n";
					szText1 += "Recompensa adicional: 600 Creditos\n";
					szText1 += "\nTotal experiencia adquirida: " + AddCommas( iDuelXPPool ) + " EXP\n";
					if ( iLevel[ i ] >= 100 ) szText1 += "Siguiente nivel a: ------ EXP";
					else szText1 += "Siguiente nivel a: " + AddCommas( iRemainingXP[ i ] ) + " EXP";
					
					// Give XP
					iCP[ i ] += 600;
					g_Scheduler.SetTimeout( "XP_AddLevel", 5.0, i, iDuelXPPool, 1, 0 );
					
					g_PlayerFuncs.HudMessage( pPlayer, textParams1, szText1 );
				}
			}
			else if ( iWinnerIndex == 1337 )
			{
				// Draw!
				if ( pPlayer.pev.targetname == 'spiral' || pPlayer.pev.targetname == 'crimson' )
				{
					// Prepare HUD message
					string szText1 = "Reembolso del duelo: " + AddCommas( iDuelXPPool / 2 ) + " EXP\n";
					szText1 += "Reembolso adicional: 300 Creditos\n";
					szText1 += "\nTotal experiencia adquirida: " + AddCommas( iDuelXPPool / 2 ) + " EXP\n";
					if ( iLevel[ i ] >= 100 ) szText1 += "Siguiente nivel a: ------ EXP";
					else szText1 += "Siguiente nivel a: " + AddCommas( iRemainingXP[ i ] ) + " EXP";
					
					// Give XP
					iCP[ i ] += 300;
					g_Scheduler.SetTimeout( "XP_AddLevel", 5.0, i, ( iDuelXPPool / 2 ), 1, 0 );
					
					g_PlayerFuncs.HudMessage( pPlayer, textParams1, szText1 );
				}
			}
		}
	}
	
	g_PlayerFuncs.HudMessageAll( textParams2, "FIN DEL DUELO" );
	
	// Set the nextmap on cycle to the nextmap
	g_EngineFuncs.CVarSetString( "mp_nextmap", g_MapCycle.GetNextMap() );
	g_Scheduler.SetTimeout( "Finish6", 1.0, iChangelevelTime );
}

void CheckTeams()
{
	crimsons = 0;
	spirals = 0;
	string tname;
	
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( iPlayer !is null && iPlayer.IsConnected() )
		{
			tname = iPlayer.pev.targetname;
			if ( tname == 'crimson' ) crimsons++;
			if ( tname == 'spiral' ) spirals++;
		}
	}
}

// TakeDamage (ALL MAPS)
HookReturnCode GLOBAL_TakeDamage( DamageInfo@ diData )
{
	// Boosting is disabled, don't care
	if ( !bAllowBoost )
		return HOOK_CONTINUE;
	
	entvars_t@ pFuckDevs = @diData.pVictim.pev;
	CBaseEntity@ f_pVictim = g_EntityFuncs.Instance( pFuckDevs );
	
	// Falldamage Resist
	if ( diData.pAttacker.entindex() == 0 )
	{
		// Reduce damage
		float flNewDamage = diData.flDamage;
		flNewDamage = flNewDamage * ( 100.0 - float( iFalldamageResist[ f_pVictim.entindex() ] ) ) / 100.0;
		diData.flDamage = flNewDamage;
	}
	
	// Critical Resist
	if ( iCriticalResist[ f_pVictim.entindex() ] > 0 && diData.pAttacker.entindex() != 0 ) // Do not apply critical resistance to falldamage
	{
		// Only care if the player does NOT have ANY armor with him/her and NOT already at a critical state
		CustomKeyvalues@ pKVD = f_pVictim.GetCustomKeyvalues();
		
		// Custom armor is active?
		CustomKeyvalue pre_CustomArmor( pKVD.GetKeyvalue( "$f_armor_value" ) );
		float flCustomArmor = pre_CustomArmor.GetFloat();
		if ( flCustomArmor == 0.0 && f_pVictim.pev.health > 1.0 )
		{
			// Next hit would of kill us?
			if ( ( f_pVictim.pev.health - diData.flDamage ) < 1.0 )
			{
				// This is a random chance
				if ( Math.RandomLong( 1, 100 ) <= iCriticalResist[ f_pVictim.entindex() ] )
				{
					// Active! 1 HP and block all futher damage
					f_pVictim.pev.health = 1.0;
					diData.flDamage = 0.0;
				}
			}
		}
	}
	
	return HOOK_CONTINUE;
}

// TakeDamage (DMC MAPS)
HookReturnCode DMC_TakeDamage( DamageInfo@ diData )
{
	entvars_t@ pFuckDevs = @diData.pVictim.pev;
	CBaseEntity@ f_pVictim = g_EntityFuncs.Instance( pFuckDevs );
	
	// save damage based on the target's armor level
	CustomKeyvalues@ pKVD = f_pVictim.GetCustomKeyvalues();
	
	CustomKeyvalue pre_ArmorAmount( pKVD.GetKeyvalue( "$f_armor_value" ) );
	CustomKeyvalue pre_ArmorCoverage( pKVD.GetKeyvalue( "$f_armor_type" ) );
	
	float flArmorType = pre_ArmorCoverage.GetFloat();
	float flArmorValue = pre_ArmorAmount.GetFloat();
	
	float flSave = Math.Ceil( flArmorType * diData.flDamage );
	
	if ( flSave >= flArmorValue )
	{
		flSave = flArmorValue;
		flArmorType = 0.0; // lost all armor
	}
	flArmorValue -= flSave;
	float flTake = Math.Ceil( diData.flDamage - flSave );
	
	// Override pushing velocity for grenade/rocket-jumping
	if ( f_pVictim is diData.pAttacker && diData.pInflictor.pev.classname == 'dmcrocket' )
	{
		// Gather a lot of data
		Vector vecVelocity = f_pVictim.pev.velocity;
		Vector vecOrigin = f_pVictim.pev.origin;
		Vector vecAbsMin = diData.pInflictor.pev.absmin;
		Vector vecAbsMax = diData.pInflictor.pev.absmax;
		
		// Calculate pushing vector
		Vector vecPush = ( vecOrigin - ( vecAbsMin + vecAbsMax ) * 0.5 );
		vecPush.Normalize();
		
		// Calculate velocity
		vecVelocity = vecVelocity + vecPush * diData.flDamage * 0.16;
		
		// Set
		f_pVictim.pev.velocity = vecVelocity;
	}
	
	// do the damage
	pKVD.SetKeyvalue( "$f_armor_value", flArmorValue );
	diData.flDamage = flTake;
	
	// update battery message
	NetworkMessage nmBattery( MSG_ONE_UNRELIABLE, NetworkMessages::Battery, f_pVictim.edict() );
	nmBattery.WriteShort( int( flArmorValue ) );
	nmBattery.End();
	f_pVictim.pev.fuser1 = flArmorValue; // Send to AMXX
	
	return HOOK_CONTINUE;
}

// TakeDamage (CS MAPS)
HookReturnCode CS_TakeDamage( DamageInfo@ diData )
{
	entvars_t@ pFuckDevs = @diData.pVictim.pev;
	CBaseEntity@ f_pVictim = g_EntityFuncs.Instance( pFuckDevs );
	
	// Ignore all damage calculations if the damage retrieved is falling...
	if ( diData.pAttacker.entindex() != 0 )
	{
		// save damage based on the target's armor level
		CBaseEntity@ pSelf = cast< CBaseEntity@ >( g_EntityFuncs.Instance( diData.pVictim.pev ) );
		CustomKeyvalues@ pKVD = pSelf.GetCustomKeyvalues();
		
		CustomKeyvalue pre_ArmorAmount( pKVD.GetKeyvalue( "$f_armor_value" ) );
		CustomKeyvalue pre_ArmorCoverage( pKVD.GetKeyvalue( "$f_armor_type" ) );
		
		float flArmorType = pre_ArmorCoverage.GetFloat();
		float flArmorValue = pre_ArmorAmount.GetFloat();
		
		float flSave = Math.Ceil( flArmorType * diData.flDamage );
		
		// blasts damage armor more.
		if ( ( diData.bitsDamageType & DMG_BLAST ) != 0 )
			flSave *= 2;
		
		if ( flSave >= flArmorValue )
		{
			flSave = flArmorValue;
			flArmorType = 0.0; // lost all armor
		}
		flArmorValue -= flSave;
		float flTake = Math.Ceil( diData.flDamage - flSave );
		
		// do the damage
		pKVD.SetKeyvalue( "$f_armor_value", flArmorValue );
		diData.flDamage = flTake;
		
		// update battery message
		NetworkMessage nmBattery( MSG_ONE_UNRELIABLE, NetworkMessages::Battery, f_pVictim.edict() );
		nmBattery.WriteShort( int( flArmorValue ) );
		nmBattery.End();
		f_pVictim.pev.fuser1 = flArmorValue; // Send to AMXX
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{	
	if ( !bAutoBalance )
		return HOOK_CONTINUE;
	
	int index = pPlayer.entindex();
	string tname = pPlayer.pev.targetname;
	if ( tname == 'crimson' )
	{
		if ( crimsons == 1 && spirals == 0 || spirals == crimsons )
		{
			// C4
			if ( bC4Exists && bCanGiveC4 )
			{
				if ( Math.RandomLong( 1, 100 ) >= 50 )
				{
					pPlayer.GiveNamedItem( "weapon_c4" );
					bCanGiveC4 = false;
					
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tienes una C4! Usala en un lugar apropiado para obtener puntos extra\n" );
					
					// For some reason this center print appears faaar on the upper side of the screen...
					g_EngineFuncs.ClientPrintf( pPlayer, print_center, "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTienes una C4!\n\nUsala en un lugar apropiado\npara obtener puntos extra\n" );
				}
			}
		}
		else if ( crimsons > spirals )
		{
			// Crimson is winning or they have an uneven number of players
			if ( score_crimson >= score_spiral || ( crimsons - spirals ) > 1 )
			{
				// Auto-team change is enabled
				if ( bAutoChange[ index ] )
				{
					pPlayer.pev.targetname = "spiral";
					pPlayer.KeyValue( "classify", "4" );
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Estas jugando para el equipo Spiral\n" );
					g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Spiral\n" );
					
					CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
					eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
				}
			}
			else // Did not want to duplicate code, but FFS whatever. I want this fixed already
			{
				// C4
				if ( bC4Exists && bCanGiveC4 )
				{
					if ( Math.RandomLong( 1, 100 ) >= 50 )
					{
						pPlayer.GiveNamedItem( "weapon_c4" );
						bCanGiveC4 = false;
						
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tienes una C4! Usala en un lugar apropiado para obtener puntos extra\n" );
						
						// For some reason this center print appears faaar on the upper side of the screen...
						g_EngineFuncs.ClientPrintf( pPlayer, print_center, "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTienes una C4!\n\nUsala en un lugar apropiado\npara obtener puntos extra\n" );
					}
				}
			}
		}
		else
		{
			// C4
			if ( bC4Exists && bCanGiveC4 )
			{
				if ( Math.RandomLong( 1, 100 ) >= 50 )
				{
					pPlayer.GiveNamedItem( "weapon_c4" );
					bCanGiveC4 = false;
					
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tienes una C4! Usala en un lugar apropiado para obtener puntos extra\n" );
					
					// For some reason this center print appears faaar on the upper side of the screen...
					g_EngineFuncs.ClientPrintf( pPlayer, print_center, "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTienes una C4!\n\nUsala en un lugar apropiado\npara obtener puntos extra\n" );
				}
			}
		}
	}
	else if ( tname == 'spiral' )
	{
		if ( spirals == 1 && crimsons == 0 || crimsons == spirals )
		{
			// C4
			if ( bC4Exists && bCanGiveC4 )
			{
				if ( Math.RandomLong( 1, 100 ) >= 50 )
				{
					pPlayer.GiveNamedItem( "weapon_c4" );
					bCanGiveC4 = false;
					
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tienes una C4! Usala en un lugar apropiado para obtener puntos extra\n" );
					
					// For some reason this center print appears faaar on the upper side of the screen...
					g_EngineFuncs.ClientPrintf( pPlayer, print_center, "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTienes una C4!\n\nUsala en un lugar apropiado\npara obtener puntos extra\n" );
				}
			}
		}
		else if ( spirals > crimsons )
		{
			// Spiral is winning or they have an uneven number of players
			if ( score_spiral >= score_crimson || ( spirals - crimsons ) > 1 )
			{
				// Auto-team change is enabled
				if ( bAutoChange[ index ] )
				{
					pPlayer.pev.targetname = "crimson";
					pPlayer.KeyValue( "classify", "5" );
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Estas jugando para el equipo Crimson\n" );
					g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Crimson\n" );
					
					CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
					eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
				}
			}
			else // Did not want to duplicate code, but FFS whatever. I want this fixed already
			{
				// C4
				if ( bC4Exists && bCanGiveC4 )
				{
					if ( Math.RandomLong( 1, 100 ) >= 50 )
					{
						pPlayer.GiveNamedItem( "weapon_c4" );
						bCanGiveC4 = false;
						
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tienes una C4! Usala en un lugar apropiado para obtener puntos extra\n" );
						
						// For some reason this center print appears faaar on the upper side of the screen...
						g_EngineFuncs.ClientPrintf( pPlayer, print_center, "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTienes una C4!\n\nUsala en un lugar apropiado\npara obtener puntos extra\n" );
					}
				}
			}
		}
		else
		{
			// C4
			if ( bC4Exists && bCanGiveC4 )
			{
				if ( Math.RandomLong( 1, 100 ) >= 50 )
				{
					pPlayer.GiveNamedItem( "weapon_c4" );
					bCanGiveC4 = false;
					
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tienes una C4! Usala en un lugar apropiado para obtener puntos extra\n" );
					
					// For some reason this center print appears faaar on the upper side of the screen...
					g_EngineFuncs.ClientPrintf( pPlayer, print_center, "\n\n\n\n\n\n\n\n\n\n\n\n\n\nTienes una C4!\n\nUsala en un lugar apropiado\npara obtener puntos extra\n" );
				}
			}
		}
	}
	else
	{
		if ( bDuelVote && g_EngineFuncs.CVarGetFloat( "mp_timelimit" ) == 0.0 )
		{
			// Duel active, observer BOI
			pPlayer.pev.targetname = "observer";
			pPlayer.pev.effects |= EF_NODRAW;
			pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
		}
		else
		{
			if ( spirals > crimsons )
			{
				pPlayer.pev.targetname = "crimson";
				pPlayer.KeyValue( "classify", "5" );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Crimson\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
			}
			else
			{
				pPlayer.pev.targetname = "spiral";
				pPlayer.KeyValue( "classify", "4" );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Spiral\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
			}
		}
	}
	
	// Weapon Auto-Buy
	if ( iAutoBuy[ index ] == 2 )
	{
		if ( iCP[ index ] >= GetShopDiscount( index, iAutoCost[ index ] ) )
		{
			for ( int i = 0; i < 4; i++ )
			{
				if ( szAutoWeapon[ index ][ i ].Length() > 0 )
					pPlayer.GiveNamedItem( szAutoWeapon[ index ][ i ] );
			}
			
			iCP[ index ] -= GetShopDiscount( index, iAutoCost[ index ] );
		}
		else
		{
			iAutoBuy[ index ] = 0;
			g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Creditos insuficientes!\nCompra automatica de armas desactivada\n" );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes! Compra automatica de armas desactivada\n" );
		}
	}
	
	// Apply boosters
	g_Scheduler.SetTimeout( "XP_SetBoost", 0.05, index );
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	if ( bGameEnd ) return HOOK_CONTINUE;
	
	int index = pPlayer.entindex();
	int attackerIndex = pAttacker.entindex();
	string tname = pPlayer.pev.targetname;
	
	if ( tname == 'spiral' )
	{
		// Team swap
		if ( pAttacker.pev.targetname == 'sys_game' )
			iSpiralSwaps++;
		
		score_crimson++;
		
		// Kill streak
		if ( iCurrentKillStreak[ index ] > iOldKillStreak[ index ] )
			iOldKillStreak[ index ] = iCurrentKillStreak[ index ];
		iCurrentKillStreak[ index ] = 0;
	}
	else if ( tname == 'crimson' )
	{
		// Team swap
		if ( pAttacker.pev.targetname == 'sys_game' )
			iCrimsonSwaps++;
		
		score_spiral++;
		
		// Kill streak
		if ( iCurrentKillStreak[ index ] > iOldKillStreak[ index ] )
			iOldKillStreak[ index ] = iCurrentKillStreak[ index ];
		iCurrentKillStreak[ index ] = 0;
	}
	
	// Turn off player nightvision now
	bHasNightvision[ index ] = false;
	if ( bIsNightvisionOn[ index ] )
		g_PlayerFuncs.ScreenFade( pPlayer, Vector( 0, 250, 0 ), 0.0, 0.20, 64, FFADE_IN );
	bIsNightvisionOn[ index ] = false;
	
	if ( pAttacker.IsPlayer() && pPlayer !is pAttacker )
	{
		// Score
		if ( tname == 'spiral' )
		{
			iCrimsonScore[ attackerIndex ]++;
			iCrimsonKills++;
		}
		else if ( tname == 'crimson' )
		{
			iSpiralScore[ attackerIndex ]++;
			iSpiralKills++;
		}
		
		iCurrentKillStreak[ attackerIndex ]++;
		pPlayer.m_iDeaths += 1;
		
		// Credits
		iCP[ attackerIndex ] += 7 + Math.RandomLong( 0, 7 );
		
		// Store weapon used
		CBaseEntity@ pInflictor = g_EntityFuncs.Instance( pPlayer.pev.dmg_inflictor );
		if ( pInflictor.IsPlayer() ) // "Direct" shot weapon
		{
			// Aerial kill?
			if ( !pAttacker.pev.FlagBitSet( FL_ONGROUND ) ) // Not on ground
			{
				string aname = pAttacker.pev.targetname;
				if ( aname == 'spiral' ) iSpiralAerialKills++;
				else if ( aname == 'crimson' ) iCrimsonAerialKills++;
			}
			
			CBasePlayerItem@ pItem = cast< CBasePlayerItem@ >( cast< CBasePlayer@ >( pAttacker ).m_hActiveItem.GetEntity() ); // cast cast cast while i sing this song
			if ( pItem !is null )
			{
				CBasePlayerWeapon@ pWeapon = pItem.GetWeaponPtr();
				string szClassname = pWeapon.pev.classname;
				
				CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
				if ( pEntity !is null )
				{
					CustomKeyvalues@ pKVD = pEntity.GetCustomKeyvalues();
					
					CustomKeyvalue pre_WeaponData( pKVD.GetKeyvalue( "$i_" + szClassname ) );
					if ( pre_WeaponData.Exists() )
					{
						// Store here the amount of times a player killed with this weapon
						int WeaponData = pre_WeaponData.GetInteger();
						WeaponData++;
						
						pKVD.SetKeyvalue( "$i_" + szClassname, WeaponData );
					}
					else
					{
						// Initialize
						pKVD.SetKeyvalue( "$i_" + szClassname, 1 );
						
						// Store here the classname used, so we can know which keyvalue should we retrieve when game ends
						szWeaponClassname[ iWeaponInitialized ] = szClassname;
						iWeaponInitialized++;
					}
					
					// Check for map-specific deaths
					CheckMapStat( tname, szClassname );
				}
				
				//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* DEBUG: Classname = " + szClassname + " | WeaponName = " + GetWeaponName( szClassname ) + "\n" );
			}
		}
		else // Fired missile, grenade, etc
		{
			// Aerial kill?
			if ( !pAttacker.pev.FlagBitSet( FL_ONGROUND ) ) // Not on ground
			{
				string aname = pAttacker.pev.targetname;
				if ( aname == 'spiral' ) iSpiralAerialKills++;
				else if ( aname == 'crimson' ) iCrimsonAerialKills++;
			}
			
			string szClassname = pInflictor.pev.classname;
			string szWeaponname = "";
			
			CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
			if ( pEntity !is null )
			{
				CustomKeyvalues@ pKVD = pEntity.GetCustomKeyvalues();
				
				// "this" inflictor means "that" weapon
				if ( szClassname == 'hlcrossbow_bolt' ) szWeaponname = "weapon_hlcrossbow";
				else if ( szClassname == 'weapon_hlcrossbow' ) szWeaponname = "weapon_hlcrossbow";
				else if ( szClassname == 'weapon_dmcaxe' ) szWeaponname = "weapon_dmcaxe";
				else if ( szClassname == 'hlrpg_rocket' ) szWeaponname = "weapon_hlrpg";
				else if ( szClassname == 'hlgrenade' ) szWeaponname = "weapon_hlhandgrenade";
				else if ( szClassname == 'monster_hlsatchel' ) szWeaponname = "weapon_hlsatchel";
				else if ( szClassname == 'monster_hlsnark' ) szWeaponname = "weapon_hlsnark";
				else if ( szClassname == 'monster_hltripmine' ) szWeaponname = "weapon_hltripmine";
				else if ( szClassname == 'monster_tripmine' ) szWeaponname = "weapon_tripmine";
				else if ( szClassname == 'monster_satchel' ) szWeaponname = "weapon_satchel";
				else if ( szClassname == 'monster_amenbomb' ) szWeaponname = "weapon_amenbomb";
				else if ( szClassname == 'playerhornet' ) szWeaponname = "weapon_hornetgun";
				else if ( szClassname == 'bolt' ) szWeaponname = "weapon_crossbow";
				else if ( szClassname == 'func_vehicle_custom' ) szWeaponname = "func_vehicle_custom";
				else if ( szClassname == 'displacer_portal' ) szWeaponname = "weapon_displacer";
				else if ( szClassname == 'sporegrenade' ) szWeaponname = "weapon_sporelauncher";
				else if ( szClassname == 'dmcrocket' )
				{
					// This could mean...
					if ( pInflictor.pev.model == 'models/dmc/rocket_v3.mdl' ) szWeaponname = "weapon_dmcrocketlauncher";
					else szWeaponname = "weapon_dmcgrenadelauncher";
				}
				else if ( szClassname == 'dmcnail' )
				{
					// This could mean...
					if ( pInflictor.pev.dmg == 36 ) szWeaponname = "weapon_dmcsupernailgun";
					else szWeaponname = "weapon_dmcnailgun";
				}
				else if ( szClassname == 'grenade' ) // Multiple usage inflictor from here
				{
					if ( szMapName.StartsWith( "hl_" ) ) szWeaponname = "weapon_hlmp5";
					else if ( szMapName.StartsWith( "cs_" ) ) szWeaponname = "weapon_hegrenade";
					else if ( szMapName.StartsWith( "dod_" ) ) szWeaponname = "weapon_stick";
					else if ( IsCSGrenadeMap( szMapName ) ) szWeaponname = "weapon_hegrenade";
					else if ( IsSCGrenadeMap( szMapName ) ) szWeaponname = "weapon_handgrenade";
					else szWeaponname = "weapon_unknown";
				}
				else if ( szClassname == 'rpg_rocket' )
				{
					if ( szMapName.StartsWith( "dod_" ) ) szWeaponname = "weapon_piat";
					else if ( szMapName == 'fun_big_city' ) szWeaponname = "weapon_piat";
					else szWeaponname = "weapon_unknown";
				}
				
				CustomKeyvalue pre_WeaponData( pKVD.GetKeyvalue( "$i_" + szWeaponname ) );
				if ( pre_WeaponData.Exists() )
				{
					// Store here the amount of times a player killed with this weapon
					int WeaponData = pre_WeaponData.GetInteger();
					WeaponData++;
					
					pKVD.SetKeyvalue( "$i_" + szWeaponname, WeaponData );
				}
				else
				{
					// Initialize
					pKVD.SetKeyvalue( "$i_" + szWeaponname, 1 );
					
					// Store here the classname used, so we can know which keyvalue should we retrieve when game ends
					szWeaponClassname[ iWeaponInitialized ] = szWeaponname;
					iWeaponInitialized++;
				}
				
				// Check for map-specific deaths
				CheckMapStat( tname, szWeaponname );
			}
			
			//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* DEBUG: Inflictor Classname = " + szClassname + " | Internal Name = " + szWeaponname + " | WeaponName = " + GetWeaponName( szWeaponname ) + "\n" );
		}
	}
	else if ( pAttacker is pPlayer )
	{
		// Suicide
		if ( tname == 'spiral' ) iSpiralSuicides++;
		else if ( tname == 'crimson' ) iCrimsonSuicides++;
	}
	else
	{
		// Non-player entity did the kill, check for map-specific death
		CheckMapStat( tname, pAttacker.pev.classname );
	}
	
	/*
	// Attempt to locate weapon entities and remove their ANNOYING use/touch delay
	CBaseEntity@ pWeaponBox = null;
	while ( ( @pWeaponBox = g_EntityFuncs.FindEntityByClassname( pWeaponBox, "weapon_*" ) ) !is null )
	{
		// Force-remove the protection by setting it's owner to NULL
		CBasePlayerWeapon@ pCast = cast< CBasePlayerWeapon@ >( pWeaponBox );
		if ( pCast.m_hPlayer.GetEntity() is pPlayer )
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* DEBUG: Found weapon\n" );
			pCast.m_hPlayer = pWeaponBox;
		}
	}*/
	
	return HOOK_CONTINUE;
}

void CheckMapStat( const string& in szTeam, const string& in szClassname )
{
	if ( szClassname == 'weapon_hltripmine' )
	{
		if ( szTeam == 'spiral' ) iCrimsonTripmineKills++;
		else if ( szTeam == 'crimson' ) iSpiralTripmineKills++;
	}
	else if ( szClassname == 'weapon_hlsatchel' )
	{
		if ( szTeam == 'spiral' ) iCrimsonSatchelKills++;
		else if ( szTeam == 'crimson' ) iSpiralSatchelKills++;
	}
	else if ( szClassname == 'weapon_hlsnark' )
	{
		if ( szTeam == 'spiral' ) iCrimsonSnarkKills++;
		else if ( szTeam == 'crimson' ) iSpiralSnarkKills++;
	}
	else if ( szClassname == 'func_breakable' || szClassname == 'func_vehicle_custom' )
	{
		if ( szTeam == 'spiral' ) iCrimsonVehicleKills++;
		else if ( szTeam == 'crimson' ) iSpiralVehicleKills++;
	}
	else if ( szClassname == 'func_tracktrain' )
		iTrainKills++;
	else if ( szClassname == 'weapon_hegrenade' )
	{
		if ( szTeam == 'spiral' ) iCrimsonHEKills++;
		else if ( szTeam == 'crimson' ) iSpiralHEKills++;
	}
	else if ( szClassname == 'weapon_p228' )
	{
		if ( szTeam == 'spiral' ) iCrimsonP228Kills++;
		else if ( szTeam == 'crimson' ) iSpiralP228Kills++;
	}
	else if ( szClassname == 'weapon_dmcaxe' )
	{
		if ( szTeam == 'spiral' ) iCrimsonAXEKills++;
		else if ( szTeam == 'crimson' ) iSpiralAXEKills++;
	}
	else if ( szClassname == 'weapon_hornetgun' )
	{
		if ( szTeam == 'spiral' ) iCrimsonHornetKills++;
		else if ( szTeam == 'crimson' ) iSpiralHornetKills++;
	}
	else if ( szClassname == 'weapon_dmcaxe' || szClassname == 'weapon_csknife' || szClassname == 'weapon_amensword' || szClassname == 'weapon_icrowbar' || szClassname == 'weapon_spade' || szClassname == 'weapon_hlcrowbar' )
	{
		if ( szTeam == 'spiral' ) iCrimsonMeleeKills++;
		else if ( szTeam == 'crimson' ) iSpiralMeleeKills++;
	}
	else if ( szClassname == 'world' || szClassname == 'worldspawn' )
	{
		if ( szTeam == 'spiral' ) iSpiralSuicides++;
		else if ( szTeam == 'crimson' ) iCrimsonSuicides++;
	}
}

void SpectateFix( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
		pPlayer.m_flRespawnDelayTime = Math.FLOAT_MAX;
}

void ShowScore()
{
	if ( bGameEnd ) return;
	
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			HUDTextParams score1;
			score1.x = 0.4;
			score1.y = 0.025;
			score1.effect = 0;
			score1.r1 = 10;
			score1.g1 = 200;
			score1.b1 = 200;
			score1.a1 = 250;
			score1.r2 = 10;
			score1.g2 = 200;
			score1.b2 = 200;
			score1.a2 = 250;
			score1.fadeinTime = 0.0;
			score1.fadeoutTime = 0.0;
			score1.holdTime = 255.0;
			score1.fxTime = 0.0;
			score1.channel = 5;
			
			HUDTextParams score2;
			score2.x = -1;
			score2.y = 0.025;
			score2.effect = 0;
			score2.r1 = 250;
			score2.g1 = 250;
			score2.b1 = 250;
			score2.a1 = 250;
			score2.r2 = 250;
			score2.g2 = 250;
			score2.b2 = 250;
			score2.a2 = 250;
			score2.fadeinTime = 0.0;
			score2.fadeoutTime = 0.0;
			score2.holdTime = 255.0;
			score2.fxTime = 0.0;
			score2.channel = 6;
			
			HUDTextParams score3;
			score3.x = 0.55;
			score3.y = 0.025;
			score3.effect = 0;
			score3.r1 = 200;
			score3.g1 = 100;
			score3.b1 = 10;
			score3.a1 = 250;
			score3.r2 = 200;
			score3.g2 = 100;
			score3.b2 = 10;
			score3.a2 = 250;
			score3.fadeinTime = 0.0;
			score3.fadeoutTime = 0.0;
			score3.holdTime = 255.0;
			score3.fxTime = 0.0;
			score3.channel = 7;
			
			string hudtext1 = "Spiral: " + AddCommas( score_spiral );
			string hudtext2 = "-";
			string hudtext3 = "Crimson: " + AddCommas( score_crimson );
			
			g_PlayerFuncs.HudMessage( pPlayer, score1, hudtext1 );
			g_PlayerFuncs.HudMessage( pPlayer, score2, hudtext2 );
			g_PlayerFuncs.HudMessage( pPlayer, score3, hudtext3 );
			
			HUDSpriteParams hTeam;
			hTeam.channel = 1;
			hTeam.flags = ( HUD_ELEM_SCR_CENTER_X | HUD_ELEM_SCR_CENTER_Y );
			hTeam.spritename = "ecsc/teamhud.spr";
			hTeam.x = -0.96;
			hTeam.y = 0.43;
			hTeam.numframes = 1;
			hTeam.holdTime = 255.0;
			hTeam.left = 2;
			hTeam.height = 23;
			
			if ( pPlayer.pev.targetname == 'spiral' )
			{
				hTeam.top = 44;
				hTeam.width = 241;
				hTeam.color1 = hTeam.color2 = RGBA( 10, 250, 250, 255 );
			}
			else if ( pPlayer.pev.targetname == 'crimson' )
			{
				hTeam.top = 78;
				hTeam.width = 286;
				hTeam.color1 = hTeam.color2 = RGBA( 200, 100, 10, 255 );
			}
			else if ( pPlayer.pev.targetname == 'observer' )
			{
				hTeam.top = 112;
				hTeam.width = 344;
				hTeam.color1 = hTeam.color2 = RGBA( 250, 250, 10, 255 );
			}
			else
			{
				hTeam.top = 10;
				hTeam.width = 184;
				hTeam.color1 = hTeam.color2 = RGBA( 250, 250, 250, 255 );
			}
			
			g_PlayerFuncs.HudCustomSprite( pPlayer, hTeam );
			g_PlayerFuncs.HudToggleElement( pPlayer, 1, true );
		}
	}
}

void CheckSystem()
{	
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	
	if ( gData !is null )
	{
		CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
		
		// Add/Remove team score
		CustomKeyvalue iSpiral_pre( pCustom.GetKeyvalue( "$i_extra_spiral" ) );
		CustomKeyvalue iCrimson_pre( pCustom.GetKeyvalue( "$i_extra_crimson" ) );
		
		int iSpiral = iSpiral_pre.GetInteger();
		int iCrimson = iCrimson_pre.GetInteger();
		
		if ( iSpiral != 0 )
		{
			score_spiral += iSpiral;
			pCustom.SetKeyvalue( "$i_extra_spiral", 0 );
		}
		
		if ( iCrimson != 0 )
		{
			score_crimson += iCrimson;
			pCustom.SetKeyvalue( "$i_extra_crimson", 0 );
		}
		
		// Dead Chat Disabler. If "1", dead players messages cannot be seen by the living
		CustomKeyvalue bDisableDeadChat_pre( pCustom.GetKeyvalue( "$i_disable_deadchat" ) );
		
		int bDisableDeadChat = bDisableDeadChat_pre.GetInteger();
		
		if ( bDisableDeadChat == 1 )
			bDeadChat = false;
		else
			bDeadChat = true;
		
		// Team Balance Disabler. If "1", automatic team balance is disabled.
		// Teams will have to be FULLY defined manually via script in this mode.
		CustomKeyvalue bDisableTeamB_pre( pCustom.GetKeyvalue( "$i_disable_teambalance" ) );
		
		int bDisableTeamB = bDisableTeamB_pre.GetInteger();
		
		if ( bDisableTeamB == 1 )
			bAutoBalance = false;
		else
			bAutoBalance = true;
		
		// Footsteps Disabler. If "1", CVar "mp_footsteps" is set to 0.
		CustomKeyvalue bDisableFootsteps_pre( pCustom.GetKeyvalue( "$i_disable_footsteps" ) );
		
		int bDisableFootsteps = bDisableFootsteps_pre.GetInteger();
		
		if ( bDisableFootsteps == 1 )
			g_EngineFuncs.ServerCommand( "mp_footsteps 0\n" );
		else
			g_EngineFuncs.ServerCommand( "mp_footsteps 1\n" );
		
		// Level Booster Disabler. If "1", all boosts given by levels will be disabled.
		CustomKeyvalue bDisableBoosting_pre( pCustom.GetKeyvalue( "$i_disable_boosting" ) );
		
		int bDisableBoosting = bDisableBoosting_pre.GetInteger();
		
		if ( bDisableBoosting == 1 )
			bAllowBoost = false;
		else
			bAllowBoost = true;
		
		// Game end
		CustomKeyvalue bEndGame_pre( pCustom.GetKeyvalue( "$i_end" ) );
		
		int bEndGame = bEndGame_pre.GetInteger();
		
		if ( bEndGame == 1 )
		{
			bGameEnd = true;
			
			// Dummys
			HUDTextParams tDummy;
			
			tDummy.channel = 5;
			g_PlayerFuncs.HudMessageAll( tDummy, " " );
			tDummy.channel = 6;
			g_PlayerFuncs.HudMessageAll( tDummy, " " );
			tDummy.channel = 7;
			g_PlayerFuncs.HudMessageAll( tDummy, " " );
			tDummy.channel = 8;
			g_PlayerFuncs.HudMessageAll( tDummy, " " );
			
			EndGame();
		}
	}
}

void EndGame()
{
	CBaseEntity@ pEntity = null;
	string szClassname;
	for ( int i = 1; i < 2048; i++ ) // No deathmatch map should have more than this many entites
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
			{
				pEntity.pev.flags |= FL_GODMODE;
				cast< CBasePlayer@ >( pEntity ).RemoveAllItems( true );
				pEntity.pev.flags |= FL_FROZEN;
				pEntity.pev.effects &= ~EF_DIMLIGHT;
				
				// Hide team HUD
				g_PlayerFuncs.HudToggleElement( cast< CBasePlayer@ >( pEntity ), 1, false );
				
				// Set up finish time
				CustomKeyvalues@ pKVD = pEntity.GetCustomKeyvalues();
				pKVD.SetKeyvalue( "$f_finish_time", g_Engine.time );
				
				g_Scheduler.SetTimeout( "SND_Effect", 0.01, pEntity.entindex() );
			}
			else
			{
				szClassname = pEntity.pev.classname;
				if ( szClassname[ 0 ] == 'w' && szClassname[ 1 ] == 'e' && szClassname[ 2 ] == 'a' && szClassname[ 3 ] == 'p' && szClassname[ 4 ] == 'o' && szClassname[ 5 ] == 'n' && szClassname[ 6 ] == '_' )
					g_EntityFuncs.Remove( pEntity );
				else if ( szClassname[ 0 ] == 'a' && szClassname[ 1 ] == 'm' && szClassname[ 2 ] == 'm' && szClassname[ 3 ] == 'o' && szClassname[ 4 ] == '_' )
					g_EntityFuncs.Remove( pEntity );
				else if ( szClassname[ 0 ] == 'i' && szClassname[ 1 ] == 't' && szClassname[ 2 ] == 'e' && szClassname[ 3 ] == 'm' && szClassname[ 4 ] == '_' )
					g_EntityFuncs.Remove( pEntity );
				else if ( szClassname == 'c4' ) // Map-specific removal from here
				{
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_VOICE, "weapons/c4_beep5.wav", 0, ATTN_NONE, SND_STOP, 0 ); // Kill sound
					g_EntityFuncs.Remove( pEntity );
				}
				else if ( szClassname == 'sys_control_point' )
					g_EntityFuncs.Remove( pEntity );
			}
		}
	}
	
	// Retrieve map stats
	dtMapFinish = UnixTimestamp();
	
	CBaseEntity@ pGameData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	CustomKeyvalues@ pKVD = pGameData.GetCustomKeyvalues();
	
	// Most used weapon
	for ( int i = 0; i < iWeaponInitialized; i++ )
	{
		CustomKeyvalue pre_WeaponData( pKVD.GetKeyvalue( "$i_" + szWeaponClassname[ i ] ) );
		int WeaponData = pre_WeaponData.GetInteger();
		
		if ( WeaponData > iMostWeaponKills )
		{
			iMostWeaponKills = WeaponData;
			szMostWeaponKills = GetWeaponName( szWeaponClassname[ i ] );
		}
	}
	
	// Least used weapon
	for ( int i = 0; i < iWeaponInitialized; i++ )
	{
		CustomKeyvalue pre_WeaponData( pKVD.GetKeyvalue( "$i_" + szWeaponClassname[ i ] ) );
		int WeaponData = pre_WeaponData.GetInteger();
		
		if ( WeaponData < iLeastWeaponKills )
		{
			iLeastWeaponKills = WeaponData;
			szLeastWeaponKills = GetWeaponName( szWeaponClassname[ i ] );
		}
	}
	
	// Map-specific data
	if ( szMapName == 'hl_crossfire' )
	{
		CustomKeyvalue pre_MapData( pKVD.GetKeyvalue( "$i_bomb_times" ) );
		int MapData = pre_MapData.GetInteger();
		
		iBombTimes = MapData;
	}
	else if ( szMapName == 'cs_airstrip' || szMapName == 'cs_dust2' || szMapName == 'cs_inferno' || szMapName == 'cs_nuke' || szMapName == 'cs_prodigy' || szMapName == 'cs_shoothouse' || szMapName == 'cs_vangogh' || szMapName == 'fun_teleport' || szMapName == 'fun_darkmines' || szMapName == 'fun_the_stairs2' )
	{
		CustomKeyvalue pre_MapData1( pKVD.GetKeyvalue( "$i_c4_times" ) );
		CustomKeyvalue pre_MapData2( pKVD.GetKeyvalue( "$i_c4_spiral_detonate" ) );
		CustomKeyvalue pre_MapData3( pKVD.GetKeyvalue( "$i_c4_crimson_detonate" ) );
		CustomKeyvalue pre_MapData4( pKVD.GetKeyvalue( "$i_c4_crimson_defuse" ) );
		CustomKeyvalue pre_MapData5( pKVD.GetKeyvalue( "$i_c4_spiral_defuse" ) );
		int MapData1 = pre_MapData1.GetInteger();
		int MapData2 = pre_MapData2.GetInteger();
		int MapData3 = pre_MapData3.GetInteger();
		int MapData4 = pre_MapData4.GetInteger();
		int MapData5 = pre_MapData5.GetInteger();
		
		iTotalBombs = MapData1;
		iSpiralDetonate = MapData2;
		iCrimsonDetonate = MapData3;
		iCrimsonDefuse = MapData4;
		iSpiralDefuse = MapData5;
	}
	else if ( szMapName[ 0 ] == 'd' && szMapName[ 1 ] == 'o' && szMapName[ 2 ] == 'd' )
	{
		CustomKeyvalue pre_MapData1( pKVD.GetKeyvalue( "$i_cp_spiral" ) );
		CustomKeyvalue pre_MapData2( pKVD.GetKeyvalue( "$i_cp_crimson" ) );
		int MapData1 = pre_MapData1.GetInteger();
		int MapData2 = pre_MapData2.GetInteger();
		
		// Store these now, we will need it on map end
		iSpiralCPTime = MapData1;
		iCrimsonCPTime = MapData2;
		
		int iSeconds1 = MapData1;
		int iMinutes1 = 0;
		while ( iSeconds1 >= 60 )
		{
			iMinutes1++;
			iSeconds1 -= 60;
		}
		if ( iMinutes1 < 10 ) szSpiralCPTime += "0" + iMinutes1 + ":"; else szSpiralCPTime += "" + iMinutes1 + ":";
		if ( iSeconds1 < 10 ) szSpiralCPTime += "0" + iSeconds1; else szSpiralCPTime += "" + iSeconds1;
		
		int iSeconds2 = MapData2;
		int iMinutes2 = 0;
		while ( iSeconds2 >= 60 )
		{
			iMinutes2++;
			iSeconds2 -= 60;
		}
		if ( iMinutes2 < 10 ) szCrimsonCPTime += "0" + iMinutes2 + ":"; else szCrimsonCPTime += "" + iMinutes2 + ":";
		if ( iSeconds2 < 10 ) szCrimsonCPTime += "0" + iSeconds2; else szCrimsonCPTime += "" + iSeconds2;
	}
	
	// KILL ME!
	g_EntityFuncs.Remove( pGameData );
	
	g_Scheduler.SetTimeout( "Finish1", 1.0 );
}

string GetWeaponName( const string& in szClassname )
{
	// Long hardcoded list...
	if ( szClassname == 'weapon_hl357' ) // HL
		return "Revolver 357";
	else if ( szClassname == 'weapon_hl9mmhandgun' )
		return "Pistola 9mm";
	else if ( szClassname == 'weapon_hlcrossbow' )
		return "Ballesta";
	else if ( szClassname == 'weapon_hlcrowbar' )
		return "Crowbar";
	else if ( szClassname == 'weapon_hlgauss' )
		return "Gauss";
	else if ( szClassname == 'weapon_hlegon' )
		return "Egon";
	else if ( szClassname == 'weapon_hlmp5' )
		return "Rifle MP5";
	else if ( szClassname == 'weapon_hlshotgun' )
		return "Escopeta";
	else if ( szClassname == 'weapon_hlrpg' )
		return "RPG Launcher";
	else if ( szClassname == 'weapon_hlgrenade' )
		return "Granada";
	else if ( szClassname == 'weapon_hlsatchel' )
		return "Satchel";
	else if ( szClassname == 'weapon_hltripmine' )
		return "Tripmine";
	else if ( szClassname == 'weapon_hlsnark' )
		return "Snark";
	else if ( szClassname == 'weapon_ak47' ) // CS
		return "AK-47 Kalashnikov";
	else if ( szClassname == 'weapon_aug' )
		return "Steyr AUG A1";
	else if ( szClassname == 'weapon_awp' )
		return "AWP Magnum Sniper";
	else if ( szClassname == 'weapon_csdeagle' )
		return "Desert Eagle .50 AE";
	else if ( szClassname == 'weapon_csglock18' )
		return "Glock 18C";
	else if ( szClassname == 'weapon_csknife' )
		return "Cuchillo";
	else if ( szClassname == 'weapon_csm249' )
		return "M249 Para Machinegun";
	else if ( szClassname == 'weapon_dualelites' )
		return "Dual Elite Berettas";
	else if ( szClassname == 'weapon_famas' )
		return "Famas";
	else if ( szClassname == 'weapon_fiveseven' )
		return "FiveSeven";
	else if ( szClassname == 'weapon_g3sg1' )
		return "G3SG1 Auto-Sniper";
	else if ( szClassname == 'weapon_galil' )
		return "IMI Galil";
	else if ( szClassname == 'weapon_hegrenade' )
		return "HE Grenade";
	else if ( szClassname == 'weapon_m3' )
		return "M3 Super 90";
	else if ( szClassname == 'weapon_xm1014' )
		return "XM1014 M4";
	else if ( szClassname == 'weapon_m4a1' )
		return "M4A1 Carbine";
	else if ( szClassname == 'weapon_mac10' )
		return "Ingram MAC-10";
	else if ( szClassname == 'weapon_mp5navy' )
		return "MP5 Navy";
	else if ( szClassname == 'weapon_p228' )
		return "P228 Compact";
	else if ( szClassname == 'weapon_p90' )
		return "ES P90";
	else if ( szClassname == 'weapon_scout' )
		return "Schmidt Scout";
	else if ( szClassname == 'weapon_sg550' )
		return "SG-550 Auto-Sniper";
	else if ( szClassname == 'weapon_sg552' )
		return "SG-552 Commando";
	else if ( szClassname == 'weapon_tmp' )
		return "Schmidt TMP";
	else if ( szClassname == 'weapon_ump45' )
		return "UMP 45";
	else if ( szClassname == 'weapon_usp' )
		return "USP .45 ACP Tactical";
	else if ( szClassname == 'weapon_dmcaxe' ) // DMC
		return "Axe";
	else if ( szClassname == 'weapon_dmcgrenadelauncher' )
		return "Lanza Granadas";
	else if ( szClassname == 'weapon_dmcrocketlauncher' )
		return "Lanza Cohetes";
	else if ( szClassname == 'weapon_dmclightninggun' )
		return "Lightning Gun";
	else if ( szClassname == 'weapon_dmcnailgun' )
		return "Nailgun";
	else if ( szClassname == 'weapon_dmcshotgun' )
		return "Classic Shotgun";
	else if ( szClassname == 'weapon_dmcsupershotgun' )
		return "Classic Super-Shotgun";
	else if ( szClassname == 'weapon_dmcsupernailgun' )
		return "Super-Nailgun";
	else if ( szClassname == 'weapon_30cal' ) // DoD
		return "M1919A4 .30 Cal";
	else if ( szClassname == 'weapon_bar' )
		return "Browning Automatic Rifle";
	else if ( szClassname == 'weapon_bren' )
		return "Bren Light Machine Gun";
	else if ( szClassname == 'weapon_enfield' )
		return "Lee Enfield";
	else if ( szClassname == 'weapon_fg42' )
		return "FG-42";
	else if ( szClassname == 'weapon_g43' )
		return "Gewehr 43";
	else if ( szClassname == 'weapon_garand' )
		return "M1 Garand";
	else if ( szClassname == 'weapon_greasegun' )
		return "Thompson M3 Grease Gun";
	else if ( szClassname == 'weapon_kar98k' )
		return "Karabiner 98k";
	else if ( szClassname == 'weapon_luger' )
		return "Luger P08";
	else if ( szClassname == 'weapon_m1911' )
		return "Colt M1911";
	else if ( szClassname == 'weapon_m1carbine' )
		return "M1 Carbine";
	else if ( szClassname == 'weapon_mg34' )
		return "MG-34";
	else if ( szClassname == 'weapon_mg42' )
		return "MG-42";
	else if ( szClassname == 'weapon_mp40' )
		return "MP-40";
	else if ( szClassname == 'weapon_mp44' )
		return "Stg-44";
	else if ( szClassname == 'weapon_piat' )
		return "PIAT Launcher";
	else if ( szClassname == 'weapon_spade' )
		return "Shovel";
	else if ( szClassname == 'weapon_springfield' )
		return "Springfield";
	else if ( szClassname == 'weapon_sten' )
		return "Sten Mk2";
	else if ( szClassname == 'weapon_stick' )
		return "Stielhandgranate";
	else if ( szClassname == 'weapon_thompson' )
		return "Thompson M1A1 Submachine Gun";
	else if ( szClassname == 'weapon_webley' )
		return "Webley Revolver";
	else if ( szClassname == 'weapon_pipewrench' )
		return "Pipe Wrench";
	else if ( szClassname == 'weapon_amensword' ) // Misc
		return "Sword of Sadism";
	else if ( szClassname == 'weapon_amenrifle' )
		return "Rifle of Amen";
	else if ( szClassname == 'weapon_amenbomb' )
		return "Skeleton of Death";
	else if ( szClassname == 'weapon_crowbar' )
		return "Sven Crowbar";
	else if ( szClassname == 'weapon_mp5' || szClassname == 'weapon_9mmAR' )
		return "Sven MP5";
	else if ( szClassname == 'weapon_crossbow' )
		return "Poisonous Crossbow";
	else if ( szClassname == 'weapon_hornetgun' )
		return "Hornet Gun";
	else if ( szClassname == 'weapon_eagle' )
		return "Sven Eagle";
	else if ( szClassname == 'weapon_shotgun' )
		return "Sven Shotgun";
	else if ( szClassname == 'weapon_handgrenade' )
		return "Sven Grenade";
	else if ( szClassname == 'weapon_satchel' )
		return "Sven Satchel";
	else if ( szClassname == 'weapon_tripmine' )
		return "Sven Tripmine";
	else if ( szClassname == 'weapon_sniperrifle' )
		return "Sven Sniper";
	else if ( szClassname == 'weapon_saw' || szClassname == 'weapon_m249' )
		return "Sven M249";
	else if ( szClassname == 'weapon_displacer' )
		return "XV11382 Displacer";
	else if ( szClassname == 'weapon_sporelauncher' )
		return "Spore Launcher";
	else if ( szClassname == 'weapon_uzi' )
		return "Fashionable Uzi";
	else if ( szClassname == 'weapon_icrowbar' )
		return "InstaGib Crowbar";
	else if ( szClassname == 'weapon_igauss' )
		return "InstaGib Gauss";
	else if ( szClassname == 'func_vehicle_custom' )
		return "PhysicsBreaker Vehicle";
	else
		return "ERR_UNKNOWN_WEAPON";
}

void SND_Effect( const int& in index )
{
	CBaseEntity@ pEntity = g_EntityFuncs.Instance( index );
	
	// Update kill streak now
	if ( iCurrentKillStreak[ index ] > iOldKillStreak[ index ] )
		iOldKillStreak[ index ] = iCurrentKillStreak[ index ];
	iCurrentKillStreak[ index ] = 0;
	
	g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_BODY, "ecsc/tpvp/gameend_1.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, index );
	g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_ITEM, "ecsc/tpvp/gameend_2.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, index );
}

void Finish1()
{
	HUDTextParams textParams;
	textParams.x = -1;
	textParams.y = 0.4;
	textParams.effect = 0;
	textParams.r1 = 250;
	textParams.g1 = 250;
	textParams.b1 = 250;
	textParams.a1 = 0;
	textParams.r2 = 250;
	textParams.g2 = 250;
	textParams.b2 = 250;
	textParams.a2 = 0;
	textParams.fadeinTime = 0.0;
	textParams.fadeoutTime = 0.0;
	textParams.holdTime = 2.0;
	textParams.fxTime = 0.0;
	textParams.channel = 1;
	
	g_PlayerFuncs.HudMessageAll( textParams, "SE ACABO!" );
	
	// We are playing a custom mod map. Don't care about stats and just finish.
	if ( szMapName == 'fun_hide_n_seek' || szMapName == 'fun_hide_n_seek2' || szMapName == 'fun_clue_3' )
		g_Scheduler.SetTimeout( "Finish2_NoStats", 3.0 );
	else
		g_Scheduler.SetTimeout( "Finish2", 3.0 );
}

void Finish2()
{
	int iSpiralHighScore = 0;
	int iSpiralBest = 0;
	int iCrimsonHighScore = 0;
	int iCrimsonBest = 0;
	
	int iSpiralHighStreak = 0;
	int iSpiralBestStreak = 0;
	int iCrimsonHighStreak = 0;
	int iCrimsonBestStreak = 0;
	
	CBaseEntity@ pEntity = null;
	for ( int i = 0; i < 33; i++ )
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
			{
				pEntity.pev.flags &= ~FL_FROZEN;
				
				if ( score_spiral != score_crimson )
				{
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_WEAPON, "ecsc/tpvp/gameend_3_v2.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_STATIC, "ambience/goal_1.wav", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
				}
				else
				{
					// Different music if draw
					g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_WEAPON, "ecsc/tpvp/gameend_3.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
				}
				
				// Get kill streak
				if ( pEntity.pev.targetname == 'spiral' )
				{
					if ( iOldKillStreak[ i ] > iSpiralHighStreak )
					{
						iSpiralHighStreak = iOldKillStreak[ i ];
						iSpiralBestStreak = i;
					}
				}
				else if ( pEntity.pev.targetname == 'crimson' )
				{
					if ( iOldKillStreak[ i ] > iCrimsonHighStreak )
					{
						iCrimsonHighStreak = iOldKillStreak[ i ];
						iCrimsonBestStreak = i;
					}
				}
			}
		}
		
		// Get best players
		if ( iSpiralScore[ i ] > iSpiralHighScore )
		{
			iSpiralHighScore = iSpiralScore[ i ];
			iSpiralBest = i;
		}
		if ( iCrimsonScore[ i ] > iCrimsonHighScore )
		{
			iCrimsonHighScore = iCrimsonScore[ i ];
			iCrimsonBest = i;
		}
	}
	
	// Store data
	CBaseEntity@ pPlayer1 = g_EntityFuncs.Instance( iSpiralBest );
	CBaseEntity@ pPlayer2 = g_EntityFuncs.Instance( iCrimsonBest );
	CBaseEntity@ pPlayer3 = g_EntityFuncs.Instance( iSpiralBestStreak );
	CBaseEntity@ pPlayer4 = g_EntityFuncs.Instance( iCrimsonBestStreak );
	
	string szName1 = pPlayer1.pev.netname;
	string szName2 = pPlayer2.pev.netname;
	string szName3 = pPlayer3.pev.netname;
	string szName4 = pPlayer4.pev.netname;
	
	szBestSpiral = szName1;
	iBestSpiralScore = iSpiralHighScore;
	
	szBestCrimson = szName2;
	iBestCrimsonScore = iCrimsonHighScore;
	
	szKillStreakSpiral = szName3;
	iSpiral_KS_Score = iSpiralHighStreak;
	
	szKillStreakCrimson = szName4;
	iCrimson_KS_Score = iCrimsonHighStreak;
	
	// Done, let's continue
	HUDTextParams textParams;
	textParams.x = -1;
	textParams.y = 0.3;
	textParams.effect = 1;
	textParams.a1 = 250;
	textParams.r2 = 250;
	textParams.g2 = 250;
	textParams.b2 = 250;
	textParams.a2 = 250;
	textParams.fadeinTime = 0.0;
	textParams.fadeoutTime = 1.0;
	textParams.holdTime = 4.0;
	textParams.fxTime = 0.0;
	textParams.channel = 1;
	
	if ( score_spiral > score_crimson )
	{
		textParams.r1 = 10;
		textParams.g1 = 200;
		textParams.b1 = 200;
		
		g_PlayerFuncs.ScreenFadeAll( Vector( 10, 200, 200 ), 5.0, 0.5, 180, FFADE_IN );
		
		g_PlayerFuncs.HudMessageAll( textParams, "Ganan los Spiral!" );
	}
	else if ( score_crimson > score_spiral )
	{
		textParams.r1 = 200;
		textParams.g1 = 100;
		textParams.b1 = 10;
		
		g_PlayerFuncs.ScreenFadeAll( Vector( 200, 100, 10 ), 5.0, 0.5, 180, FFADE_IN );
		
		g_PlayerFuncs.HudMessageAll( textParams, "Ganan los Crimson!" );
	}
	else if ( score_spiral == score_crimson )
	{
		textParams.fadeinTime = 1.0;
		textParams.fadeoutTime = 1.0;
		textParams.holdTime = 3.0;
		textParams.effect = 0;
		
		textParams.r1 = 200;
		textParams.g1 = 200;
		textParams.b1 = 200;
		
		g_PlayerFuncs.HudMessageAll( textParams, "Empate!" );
	}
	
	g_Scheduler.SetTimeout( "Finish3", 5.0 );
}

void Finish2_NoStats()
{
	CBaseEntity@ pEntity = null;
	for ( int i = 0; i < 33; i++ )
	{
		@pEntity = g_EntityFuncs.Instance( i );
		if ( pEntity !is null )
		{
			if ( pEntity.IsPlayer() )
			{
				pEntity.pev.flags &= ~FL_FROZEN;
				g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_WEAPON, "ecsc/tpvp/gameend_3.ogg", VOL_NORM, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, pEntity.entindex() );
			}
		}
	}
	
	// Secret XP method are HIDDEN on mod maps
	// Calculate winning team/secret bonus, if applicable
	int iTeamBonus1 = 0;
	int iTeamBonus2 = 0;
	int iData1 = 0;
	int iData2 = 0;
	
	// On mod maps, team is irrelevant, so reset the score to delete XP from it
	score_spiral = 0;
	score_crimson = 0;
	
	if ( szMapName == 'fun_clue_3' )
	{
		iTeamBonus1 = 1;
		
		// Calculate secret XP
		CBaseEntity@ pPlayer = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pPlayer = g_EntityFuncs.Instance( i );
			if ( pPlayer !is null )
			{
				if ( pPlayer.IsPlayer() )
				{
					CustomKeyvalues@ pKVD = pPlayer.GetCustomKeyvalues();
					CustomKeyvalue pre_iWinTimes( pKVD.GetKeyvalue( "$i_secret_wins" ) );
					int iWinTimes = pre_iWinTimes.GetInteger();
					if ( iWinTimes > 0 )
					{
						// Move this player to spiral to give the bonus
						pPlayer.pev.targetname = "spiral";
						
						// Add to total times assassins won
						iData1 += iWinTimes;
					}
				}
			}
		}
		
		// Every time assassins won a round, they earn extra 27 XP for each victory
		iData1 = iData1 * 27;
	}
	else if ( szMapName == 'fun_hide_n_seek' || szMapName == 'fun_hide_n_seek2' )
	{
		iTeamBonus1 = 1;
		
		// Calculate secret XP
		CBaseEntity@ pPlayer = null;
		for ( int i = 0; i < 33; i++ )
		{
			@pPlayer = g_EntityFuncs.Instance( i );
			if ( pPlayer !is null )
			{
				if ( pPlayer.IsPlayer() )
				{
					CustomKeyvalues@ pKVD = pPlayer.GetCustomKeyvalues();
					CustomKeyvalue pre_iRoundTimes( pKVD.GetKeyvalue( "$i_secret_rounds" ) );
					int iRoundTimes = pre_iRoundTimes.GetInteger();
					if ( iRoundTimes > 0 )
					{
						// Move this player to spiral to give the bonus
						pPlayer.pev.targetname = "spiral";
						
						// Add to total times players managed 10+ rounds on a match
						iData1 += iRoundTimes;
					}
				}
			}
		}
		
		// Every round is worth 6 XP each
		// EVERY single player can perform this regardless of team, compensate or we are having absurd amounts of XP
		iData1 = iData1 * 6;
	}
	
	// Now go to EXP
	Finish5( iTeamBonus1, iTeamBonus2, iData1, iData2 );
}

void Finish3()
{
	HUDTextParams textParams1;
	textParams1.x = 0.25;
	textParams1.y = 0.4;
	textParams1.effect = 2;
	textParams1.r1 = 10;
	textParams1.g1 = 200;
	textParams1.b1 = 200;
	textParams1.a1 = 0;
	textParams1.r2 = 250;
	textParams1.g2 = 250;
	textParams1.b2 = 250;
	textParams1.a2 = 0;
	textParams1.fadeinTime = 0.03;
	textParams1.fadeoutTime = 1.0;
	textParams1.holdTime = 255.0;
	textParams1.fxTime = 0.3;
	textParams1.channel = 1;
	
	HUDTextParams textParams2;
	textParams2.x = 0.60;
	textParams2.y = 0.4;
	textParams2.effect = 2;
	textParams2.r1 = 200;
	textParams2.g1 = 100;
	textParams2.b1 = 10;
	textParams2.a1 = 0;
	textParams2.r2 = 250;
	textParams2.g2 = 250;
	textParams2.b2 = 250;
	textParams2.a2 = 0;
	textParams2.fadeinTime = 0.03;
	textParams2.fadeoutTime = 1.0;
	textParams2.holdTime = 255.0;
	textParams2.fxTime = 0.3;
	textParams2.channel = 2;
	
	HUDTextParams textParams3;
	textParams3.x = -1;
	textParams3.y = 0.3;
	textParams3.effect = 2;
	textParams3.r1 = 200;
	textParams3.g1 = 10;
	textParams3.b1 = 200;
	textParams3.a1 = 0;
	textParams3.r2 = 250;
	textParams3.g2 = 250;
	textParams3.b2 = 250;
	textParams3.a2 = 0;
	textParams3.fadeinTime = 0.03;
	textParams3.fadeoutTime = 1.0;
	textParams3.holdTime = 255.0;
	textParams3.fxTime = 0.3;
	textParams3.channel = 4;
	
	string szText1 = "SPIRAL\n";
	szText1 += "Puntaje final: " + AddCommas( score_spiral ) + "\n\n";
	szText1 += "Victimas: " + iSpiralKills + "\n";
	szText1 += "Suicidios: " + iSpiralSuicides + "\n";
	szText1 += "Cambios de equipo: " + iSpiralSwaps + "\n\n";
	szText1 += "Mejor jugador: " + szBestSpiral + " (" + iBestSpiralScore + " victimas)\n";
	szText1 += "Mayor racha: " + szKillStreakSpiral + " (" + iSpiral_KS_Score + " victimas seguidas)";
	
	string szText2 = "CRIMSON\n";
	szText2 += "Puntaje final: " + AddCommas( score_crimson ) + "\n\n";
	szText2 += "Victimas: " + iCrimsonKills + "\n";
	szText2 += "Suicidios: " + iCrimsonSuicides + "\n";
	szText2 += "Cambios de equipo: " + iCrimsonSwaps + "\n\n";
	szText2 += "Mejor jugador: " + szBestCrimson + " (" + iBestCrimsonScore + " victimas)\n";
	szText2 += "Mayor racha: " + szKillStreakCrimson + " (" + iCrimson_KS_Score + " victimas seguidas)";
	
	g_PlayerFuncs.HudMessageAll( textParams1, szText1 );
	g_PlayerFuncs.HudMessageAll( textParams2, szText2 );
	g_PlayerFuncs.HudMessageAll( textParams3, "RESUMEN DE PARTIDA" );
	
	g_Scheduler.SetTimeout( "Finish4", 9.0 );
}

void Finish4()
{
	HUDTextParams textParams1;
	textParams1.x = -1;
	textParams1.y = 0.4;
	textParams1.effect = 2;
	textParams1.r1 = 10;
	textParams1.g1 = 200;
	textParams1.b1 = 10;
	textParams1.a1 = 0;
	textParams1.r2 = 250;
	textParams1.g2 = 250;
	textParams1.b2 = 250;
	textParams1.a2 = 0;
	textParams1.fadeinTime = 0.03;
	textParams1.fadeoutTime = 1.0;
	textParams1.holdTime = 255.0;
	textParams1.fxTime = 0.3;
	textParams1.channel = 1;
	
	HUDTextParams textParams2;
	textParams2.x = -1;
	textParams2.y = 0.3;
	textParams2.effect = 2;
	textParams2.r1 = 200;
	textParams2.g1 = 10;
	textParams2.b1 = 200;
	textParams2.a1 = 0;
	textParams2.r2 = 250;
	textParams2.g2 = 250;
	textParams2.b2 = 250;
	textParams2.a2 = 0;
	textParams2.fadeinTime = 0.03;
	textParams2.fadeoutTime = 1.0;
	textParams2.holdTime = 255.0;
	textParams2.fxTime = 0.3;
	textParams2.channel = 4;
	
	HUDTextParams textParams3;
	textParams3.channel = 2;
	
	TimeDifference tdTotalTime( dtMapFinish, dtMapStart );
	int iMapTime = tdTotalTime.GetMinutes();
	
	string szText1 = "Duracion del mapa: " + iMapTime + " minutos\n\n";
	szText1 += "Arma mas usada: " + szMostWeaponKills + " (" + iMostWeaponKills + " victimas)\n";
	szText1 += "Arma menos usada: " + szLeastWeaponKills + " (" + iLeastWeaponKills + " victimas)\n\n";
	
	// Secret map stat
	int iTeamBonus1 = 0;
	int iTeamBonus2 = 0;
	int iData1 = 0;
	int iData2 = 0;
	if ( szMapName == 'hl_boot_camp' || szMapName == 'hl_bounce' || szMapName == 'hl_datacore' || szMapName == 'hl_frenzy' || szMapName == 'hl_gasworks' || szMapName == 'hl_snark_pit' || szMapName == 'hl_stalkyard' || szMapName == 'hl_undertow' || szMapName == 'fun_spooks' )
	{
		szText1 += "Muertes cobradas por Tripmines:\n\n";
		szText1 += "SPIRAL: " + iSpiralTripmineKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonTripmineKills + " victimas\n";
		
		if ( iSpiralTripmineKills > iCrimsonTripmineKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralTripmineKills * 3;
		}
		else if ( iCrimsonTripmineKills > iSpiralTripmineKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonTripmineKills * 3;
		}
	}
	else if ( szMapName == 'hl_campgrounds' || szMapName == 'hl_lambda_bunker' )
	{
		szText1 += "Muertes cobradas por Satchels:\n\n";
		szText1 += "SPIRAL: " + iSpiralSatchelKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonSatchelKills + " victimas\n";
		
		if ( iSpiralSatchelKills > iCrimsonSatchelKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralSatchelKills * 3;
		}
		else if ( iCrimsonSatchelKills > iSpiralSatchelKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonSatchelKills * 3;
		}
	}
	else if ( szMapName == 'hl_crossfire' )
		szText1 += "Total de bombas activadas: " + iBombTimes + "\n";
	else if ( szMapName == 'hl_npc' || szMapName == 'fun_big_city' || szMapName == 'fun_big_city2' || szMapName == 'fun_cars_n_robots' || szMapName == 'fun_megacrazycar' || szMapName == 'fun_supercrazycar2' )
	{
		szText1 += "Muertes cobradas por Vehiculos:\n\n";
		szText1 += "SPIRAL: " + iSpiralVehicleKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonVehicleKills + " victimas\n";
		
		if ( iSpiralVehicleKills > iCrimsonVehicleKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralVehicleKills * 3;
		}
		else if ( iCrimsonVehicleKills > iSpiralVehicleKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonVehicleKills * 3;
		}
	}
	else if ( szMapName == 'hl_rapidcore' )
	{
		szText1 += "Muertes cobradas por Snarks:\n\n";
		szText1 += "SPIRAL: " + iSpiralSnarkKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonSnarkKills + " victimas\n";
		
		if ( iSpiralSnarkKills > iCrimsonSnarkKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralSnarkKills * 3;
		}
		else if ( iCrimsonSnarkKills > iSpiralSnarkKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonSnarkKills * 3;
		}
	}
	else if ( szMapName == 'hl_subtransit' )
		szText1 += "Muertes cobradas por el Tren: " + iTrainKills + "\n";
	else if ( szMapName == 'cs_airstrip' || szMapName == 'cs_dust2' || szMapName == 'cs_inferno' || szMapName == 'cs_nuke' || szMapName == 'cs_prodigy' || szMapName == 'cs_shoothouse' || szMapName == 'cs_vangogh' || szMapName == 'fun_teleport' || szMapName == 'fun_darkmines' || szMapName == 'fun_the_stairs2' )
	{
		szText1 += "Total de Bombas C4 colocadas: " + iTotalBombs + "\n\n";
		szText1 += "Detonadas por SPIRAL: " + iSpiralDetonate + "\n";
		szText1 += "Detonadas por CRIMSON: " + iCrimsonDetonate + "\n\n";
		szText1 += "Desarmadas por SPIRAL: " + iSpiralDefuse + "\n";
		szText1 += "Desarmadas por CRIMSON: " + iCrimsonDefuse + "\n";
		
		if ( iSpiralDetonate > iCrimsonDetonate )
		{
			iTeamBonus1 = 1;
			iData1 = int( iSpiralDetonate * 1.5 );
		}
		else if ( iCrimsonDetonate > iSpiralDetonate )
		{
			iTeamBonus1 = 2;
			iData1 = int( iCrimsonDetonate * 1.5 );
		}
		
		if ( iSpiralDefuse > iCrimsonDefuse )
		{
			iTeamBonus2 = 1;
			iData2 = int( iSpiralDefuse * 1.5 );
		}
		else if ( iCrimsonDefuse > iSpiralDefuse )
		{
			iTeamBonus2 = 2;
			iData2 = int( iCrimsonDefuse * 1.5 );
		}
	}
	else if ( szMapName == 'cs_assault' || szMapName == 'cs_ng_deck16' )
	{
		szText1 += "Muertes cobradas por HE Grenade:\n\n";
		szText1 += "SPIRAL: " + iSpiralHEKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonHEKills + " victimas\n";
		
		if ( iSpiralHEKills > iCrimsonHEKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralHEKills * 3;
		}
		else if ( iCrimsonHEKills > iSpiralHEKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonHEKills * 3;
		}
	}
	else if ( szMapName == 'cs_backalley' || szMapName == 'cs_estate' || szMapName == 'cs_havana' || szMapName == 'cs_italy' || szMapName == 'cs_militia' || szMapName == 'cs_office' )
	{
		szText1 += "Muertes cobradas por P228 Compact:\n\n";
		szText1 += "SPIRAL: " + iSpiralP228Kills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonP228Kills + " victimas\n";
		
		if ( iSpiralP228Kills > iCrimsonP228Kills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralP228Kills * 3;
		}
		else if ( iCrimsonP228Kills > iSpiralP228Kills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonP228Kills * 3;
		}
	}
	else if ( szMapName[ 0 ] == 'd' && szMapName[ 1 ] == 'm' && szMapName[ 2 ] == 'c' )
	{
		szText1 += "Muertes cobradas por Axe:\n\n";
		szText1 += "SPIRAL: " + iSpiralAXEKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonAXEKills + " victimas\n";
		
		if ( iSpiralAXEKills > iCrimsonAXEKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralAXEKills * 3;
		}
		else if ( iCrimsonAXEKills > iSpiralAXEKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonAXEKills * 3;
		}
	}
	else if ( szMapName[ 0 ] == 'd' && szMapName[ 1 ] == 'o' && szMapName[ 2 ] == 'd' )
	{
		szText1 += "Tiempo de posesion de Puntos de Control:\n\n";
		szText1 += "SPIRAL: " + szSpiralCPTime + " minutos\n";
		szText1 += "CRIMSON: " + szCrimsonCPTime + " minutos\n";
		
		if ( iSpiralCPTime > iCrimsonCPTime )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralCPTime / 20;
		}
		else if ( iCrimsonCPTime > iSpiralCPTime )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonCPTime / 20;
		}
	}
	else if ( szMapName[ 0 ] == 'a' && szMapName[ 1 ] == 'i' && szMapName[ 2 ] == 'm' )
	{
		szText1 += "Muertes cobradas por armas cuerpo a cuerpo:\n\n";
		szText1 += "SPIRAL: " + iSpiralMeleeKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonMeleeKills + " victimas\n";
		
		if ( iSpiralMeleeKills > iCrimsonMeleeKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralMeleeKills * 3;
		}
		else if ( iCrimsonMeleeKills > iSpiralMeleeKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonMeleeKills * 3;
		}
	}
	else if ( szMapName == 'fun_hq2_phoenix' )
	{
		szText1 += "Muertes cobradas por Hornet Gun:\n\n";
		szText1 += "SPIRAL: " + iSpiralHornetKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonHornetKills + " victimas\n";
		
		if ( iSpiralHornetKills > iCrimsonHornetKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralHornetKills * 3;
		}
		else if ( iCrimsonHornetKills > iSpiralHornetKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonHornetKills * 3;
		}
	}
	else if ( szMapName == 'fun_sky_world_arena' )
	{
		szText1 += "Muertes aereas cobradas:\n\n";
		szText1 += "SPIRAL: " + iSpiralAerialKills + " victimas\n";
		szText1 += "CRIMSON: " + iCrimsonAerialKills + " victimas\n";
		
		if ( iSpiralAerialKills > iCrimsonAerialKills )
		{
			iTeamBonus1 = 1;
			iData1 = iSpiralAerialKills * 3;
		}
		else if ( iCrimsonAerialKills > iSpiralAerialKills )
		{
			iTeamBonus1 = 2;
			iData1 = iCrimsonAerialKills * 3;
		}
	}
	
	g_PlayerFuncs.HudMessageAll( textParams1, szText1 );
	g_PlayerFuncs.HudMessageAll( textParams2, "ESTADISTICAS DEL MAPA" );
	g_PlayerFuncs.HudMessageAll( textParams3, "" ); // Clear channel
	
	g_Scheduler.SetTimeout( "Finish5", 9.0, iTeamBonus1, iTeamBonus2, iData1, iData2 );
}

void Finish5( const int& in iTeamBonus1, const int& in iTeamBonus2, const int& in iData1, const int& in iData2 )
{
	bool bIsDoDMap = false;
	if ( szMapName[ 0 ] == 'd' && szMapName[ 1 ] == 'o' && szMapName[ 2 ] == 'd' )
		bIsDoDMap = true;
	
	bool bIsModMap = false;
	if ( szMapName == 'fun_hide_n_seek' || szMapName == 'fun_hide_n_seek2' || szMapName == 'fun_clue_3' )
		bIsModMap = true;
	
	HUDTextParams textParams1;
	textParams1.x = -1;
	textParams1.y = 0.4;
	textParams1.effect = 2;
	textParams1.r1 = 250;
	textParams1.g1 = 200;
	textParams1.b1 = 10;
	textParams1.a1 = 0;
	textParams1.r2 = 250;
	textParams1.g2 = 250;
	textParams1.b2 = 250;
	textParams1.a2 = 0;
	textParams1.fadeinTime = 0.03;
	textParams1.fadeoutTime = 1.0;
	textParams1.holdTime = 255.0;
	textParams1.fxTime = 0.3;
	textParams1.channel = 1;
	
	HUDTextParams textParams2;
	textParams2.x = -1;
	textParams2.y = 0.3;
	textParams2.effect = 2;
	textParams2.r1 = 200;
	textParams2.g1 = 10;
	textParams2.b1 = 200;
	textParams2.a1 = 0;
	textParams2.r2 = 250;
	textParams2.g2 = 250;
	textParams2.b2 = 250;
	textParams2.a2 = 0;
	textParams2.fadeinTime = 0.03;
	textParams2.fadeoutTime = 1.0;
	textParams2.holdTime = 255.0;
	textParams2.fxTime = 0.3;
	textParams2.channel = 2;
	
	// Manual: Iterate through all players
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			CustomKeyvalues@ pKVD = pPlayer.GetCustomKeyvalues();
			
			// Get player data
			CustomKeyvalue pre_JoinTime( pKVD.GetKeyvalue( "$f_join_time" ) );
			CustomKeyvalue pre_FinishTime( pKVD.GetKeyvalue( "$f_finish_time" ) );
			float JoinTime = pre_JoinTime.GetFloat();
			float FinishTime = pre_FinishTime.GetFloat();
			float TotalTime = FinishTime - JoinTime;
			float flScore = pPlayer.pev.frags;
			int iDeaths = ( bIsModMap ? 0 : pPlayer.m_iDeaths ); // Don't care about deaths if custom mod map
			string szTeam = pPlayer.pev.targetname;
			
			// Calculate experience modifier
			float expModifier = 0.0;
			
			if ( TotalTime >= 840.0 ) expModifier = 100.0; // 14+ minutes of play
			else if ( TotalTime >= 600.0 ) expModifier = 75.0; // 10-14 minutes of play
			else if ( TotalTime >= 420.0 ) expModifier = 50.0; // 7-10 minutes of play
			else if ( TotalTime >= 300.0 ) expModifier = 25.0; // 5-7 minutes of play
			else if ( TotalTime >= 240.0 ) expModifier = 20.0; // 4 minutes of play
			else if ( TotalTime >= 180.0 ) expModifier = 15.0; // 3 minutes of play
			else if ( TotalTime >= 120.0 ) expModifier = 10.0; // 2 minutes of play
			else if ( TotalTime >= 60.0 ) expModifier = 5.0; // 1 minute of play
			else expModifier = 1.0; // Less than 1 minute of play
			
			// Lower modifier the fewer the kills the player did (it means that the player did not bother in ACTUALLY playing, or just plain bad at it)
			if ( !bIsModMap ) // Don't care about this if custom mod map
			{
				if ( flScore <= 10 ) expModifier -= 1.0;
				else if ( flScore <= 8 ) expModifier -= 2.0;
				else if ( flScore <= 6 ) expModifier -= 4.0;
				else if ( flScore <= 4 ) expModifier -= 7.0;
				else if ( flScore <= 2 ) expModifier -= 11.0;
				else if ( flScore <= 0 ) expModifier -= 16.0;
			}
			
			// Cap it to mininum
			if ( expModifier < 1.0 ) expModifier = 1.0;
			
			// Calculate XP
			// Kills
			int iKillXP = int( ( flScore * ( bIsModMap ? 6.0 : 3.0 ) ) * expModifier / 100.0 );
			
			// Winning team
			int iWinXP = 0;
			if ( szTeam == 'spiral' && score_spiral > score_crimson )
				iWinXP = int( float( score_spiral / ( bIsDoDMap ? 30.0 : ( !bIsModMap ? 1.5 : 0.5 ) ) ) * expModifier / 100.0 );
			else if ( szTeam == 'crimson' && score_crimson > score_spiral )
				iWinXP = int( float( score_crimson / ( bIsDoDMap ? 30.0 : ( !bIsModMap ? 1.5 : 0.5 ) ) ) * expModifier / 100.0 );
			
			// Bonus XP (calculated by secret map-stat)
			int iBonusXP = 0;
			if ( szTeam == 'spiral' && iTeamBonus1 == 1 )
				iBonusXP += int( float( iData1 ) * expModifier / 100.0 );
			else if ( szTeam == 'crimson' && iTeamBonus1 == 2 )
				iBonusXP += int( float( iData1 ) * expModifier / 100.0 );
			if ( szTeam == 'spiral' && iTeamBonus2 == 1 )
				iBonusXP = int( float( iData2 ) * expModifier / 100.0 );
			else if ( szTeam == 'crimson' && iTeamBonus2 == 2 )
				iBonusXP = int( float( iData2 ) * expModifier / 100.0 );
			
			// Penalty XP
			iKillXP -= iDeaths;
			iBonusXP -= iDeaths;
			
			// Don't allow XP to be negative
			if ( iKillXP < 0 ) iKillXP = 0;
			if ( iBonusXP < 0 ) iBonusXP = 0;
			
			// Total XP earned is...
			int iTotalXP = iKillXP + iWinXP + iBonusXP;
			
			// Prepare HUD message
			string szText1 = "Experiencia base: " + AddCommas( iKillXP ) + " EXP\n";
			if ( iWinXP > 0 ) szText1 += "Bonificacion por victoria: " + AddCommas( iWinXP ) + " EXP\n";
			if ( iBonusXP > 0 ) szText1 += "Bonificacion secreta: " + AddCommas( iBonusXP ) + " EXP\n";
			szText1 += "\nTotal experiencia adquirida: " + AddCommas( iTotalXP ) + " EXP\n";
			if ( iLevel[ i ] >= 100 ) szText1 += "Siguiente nivel a: ------ EXP";
			else szText1 += "Siguiente nivel a: " + AddCommas( iRemainingXP[ i ] ) + " EXP";
			
			// Give XP
			g_Scheduler.SetTimeout( "XP_AddLevel", 5.0, i, iTotalXP, iWinXP, iBonusXP );
			
			g_PlayerFuncs.HudMessage( pPlayer, textParams1, szText1 );
		}
	}
	
	g_PlayerFuncs.HudMessageAll( textParams2, "EXPERIENCIA ADQUIRIDA" );
	
	g_Scheduler.SetTimeout( "Finish6", 1.0, iChangelevelTime );
}

void Finish6( int& in iTime )
{
	iTime = iChangelevelTime;
	
	HUDTextParams textParams;
	textParams.x = -1;
	textParams.y = 0.8;
	textParams.effect = 0;
	textParams.r1 = 200;
	textParams.g1 = 10;
	textParams.b1 = 200;
	textParams.a1 = 0;
	textParams.r2 = 200;
	textParams.g2 = 10;
	textParams.b2 = 200;
	textParams.a2 = 0;
	textParams.fadeinTime = 0.0;
	textParams.fadeoutTime = 0.0;
	textParams.holdTime = 255.0;
	textParams.fxTime = 0.0;
	textParams.channel = 4;
	
	string szText = "Cambiando a";
	string szNextMap = g_EngineFuncs.CVarGetString( "mp_nextmap" );
	
	szText += " <" + szNextMap + "> en " + iTime + " segundo(s)";
	
	g_PlayerFuncs.HudMessageAll( textParams, szText );
	
	iTime--;
	iChangelevelTime = iTime;
	
	if ( iTime < 0 )
		g_EngineFuncs.ServerCommand( "changelevel " + szNextMap + "\n" );
	else
		g_Scheduler.SetTimeout( "Finish6", 1.0, iTime );
}

// Quick note: Everything below here is an example of how NOT to code a level system, do not follow my example. -Giegue
void XP_SaveData( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( bLoadData[ index ] )
	{
		string fullpath = "" + PATH_MAIN_DATA + "TDM_" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + ".data";
		fullpath.Replace( ':', '_' );
		File@ thefile = g_FileSystem.OpenFile( fullpath, OpenFile::WRITE );
		
		if ( thefile !is null && thefile.IsOpen() )
		{
			string stuff;
			
			stuff += "" + iRemainingXP[ index ] + "#" + iLevel[ index ];
			stuff += "#" + iMaxColors[ index ] + "#" + iMaxTrails[ index ] + "#" + iMaxHatColors[ index ] + "#" + iMaxWeapons[ index ];
			stuff += "#" + flSpawnProtectionTime[ index ] + "#" + iTeamHPReg[ index ] + "#" + iTeamAPReg[ index ] + "#" + iCriticalResist[ index ] + "#" + iFalldamageResist[ index ] + "#" + iExtraMaxHP[ index ] + "#" + iExtraMaxAP[ index ] + "#" + iExtraStartHP[ index ];
			stuff += "#" + ( bHasCosmeticPack[ index ] ? "1" : "0" ) + "#" + iCPGlowColors[ index ] + "#" + ( bCPTrail[ index ] ? "1" : "0" ) + "#" + iCPTrailSprite[ index ] + "#" + iCPTrailLong[ index ] + "#" + iCPTrailSize[ index ] + "#" + ( szCPHatName[ index ].Length() > 0 ? szCPHatName[ index ] : "NULL" ) + "#" + iCPHatGlowColors[ index ];
			
			// I will regret this...
			stuff += "#" + int( vecCPGlowColor[ index ][ 0 ].x ) + "-" + int( vecCPGlowColor[ index ][ 0 ].y ) + "-" + int( vecCPGlowColor[ index ][ 0 ].z );
			stuff += "#" + int( vecCPGlowColor[ index ][ 1 ].x ) + "-" + int( vecCPGlowColor[ index ][ 1 ].y ) + "-" + int( vecCPGlowColor[ index ][ 1 ].z );
			stuff += "#" + int( vecCPGlowColor[ index ][ 2 ].x ) + "-" + int( vecCPGlowColor[ index ][ 2 ].y ) + "-" + int( vecCPGlowColor[ index ][ 2 ].z );
			stuff += "#" + int( vecCPGlowColor[ index ][ 3 ].x ) + "-" + int( vecCPGlowColor[ index ][ 3 ].y ) + "-" + int( vecCPGlowColor[ index ][ 3 ].z );
			stuff += "#" + int( vecCPGlowColor[ index ][ 4 ].x ) + "-" + int( vecCPGlowColor[ index ][ 4 ].y ) + "-" + int( vecCPGlowColor[ index ][ 4 ].z );
			stuff += "#" + int( vecCPGlowColor[ index ][ 5 ].x ) + "-" + int( vecCPGlowColor[ index ][ 5 ].y ) + "-" + int( vecCPGlowColor[ index ][ 5 ].z );
			
			stuff += "#" + int( vecCPHatGlowColor[ index ][ 0 ].x ) + "-" + int( vecCPHatGlowColor[ index ][ 0 ].y ) + "-" + int( vecCPHatGlowColor[ index ][ 0 ].z );
			stuff += "#" + int( vecCPHatGlowColor[ index ][ 1 ].x ) + "-" + int( vecCPHatGlowColor[ index ][ 1 ].y ) + "-" + int( vecCPHatGlowColor[ index ][ 1 ].z );
			stuff += "#" + int( vecCPHatGlowColor[ index ][ 2 ].x ) + "-" + int( vecCPHatGlowColor[ index ][ 2 ].y ) + "-" + int( vecCPHatGlowColor[ index ][ 2 ].z );
			stuff += "#" + int( vecCPHatGlowColor[ index ][ 3 ].x ) + "-" + int( vecCPHatGlowColor[ index ][ 3 ].y ) + "-" + int( vecCPHatGlowColor[ index ][ 3 ].z );
			stuff += "#" + int( vecCPHatGlowColor[ index ][ 4 ].x ) + "-" + int( vecCPHatGlowColor[ index ][ 4 ].y ) + "-" + int( vecCPHatGlowColor[ index ][ 4 ].z );
			stuff += "#" + int( vecCPHatGlowColor[ index ][ 5 ].x ) + "-" + int( vecCPHatGlowColor[ index ][ 5 ].y ) + "-" + int( vecCPHatGlowColor[ index ][ 5 ].z );
			
			stuff += "#" + int( vecCPTrailColor[ index ].x ) + "-" + int( vecCPTrailColor[ index ].y ) + "-" + int( vecCPTrailColor[ index ].z );
			
			stuff += "#" + iShopDiscount[ index ] + "#" + iCP[ index ] + "#" + dtFirstPlay[ index ].ToUnixTimestamp();
			
			stuff += "\n";
			
			thefile.Write( stuff );
			thefile.Close();
		}
		else
		{
			// This should never happen!
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* FATAL ERROR! PATH_MATH_DATA is NULL!\n" );
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Esto nunca deberia pasar! Por favor reportar este error de inmediato!\n" );
			
			g_Game.AlertMessage( at_logged, "!!!! FATAL ERROR !!!! PATH_MAIN_DATA is NULL!\n" );
		}
	}
}

void XP_LoadData( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	string fullpath = "" + PATH_MAIN_DATA + "TDM_" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + ".data";
	fullpath.Replace( ':', '_' );
	File@ thefile = g_FileSystem.OpenFile( fullpath, OpenFile::READ );
	
	if ( thefile !is null && thefile.IsOpen() )
	{
		string line;
		
		thefile.ReadLine( line );
		line.Replace( '#', ' ' );
		array< string >@ pre_data = line.Split( ' ' );
		
		pre_data[ 0 ].Trim();
		pre_data[ 1 ].Trim();
		pre_data[ 2 ].Trim();
		pre_data[ 3 ].Trim();
		pre_data[ 4 ].Trim();
		pre_data[ 5 ].Trim();
		pre_data[ 6 ].Trim();
		pre_data[ 7 ].Trim();
		pre_data[ 8 ].Trim();
		pre_data[ 9 ].Trim();
		pre_data[ 10 ].Trim();
		pre_data[ 11 ].Trim();
		pre_data[ 12 ].Trim();
		pre_data[ 13 ].Trim();
		pre_data[ 14 ].Trim();
		pre_data[ 15 ].Trim();
		pre_data[ 16 ].Trim();
		pre_data[ 17 ].Trim();
		pre_data[ 18 ].Trim();
		pre_data[ 19 ].Trim();
		pre_data[ 20 ].Trim();
		pre_data[ 21 ].Trim();
		pre_data[ 22 ].Trim();
		pre_data[ 23 ].Trim();
		pre_data[ 24 ].Trim();
		pre_data[ 25 ].Trim();
		pre_data[ 26 ].Trim();
		pre_data[ 27 ].Trim();
		pre_data[ 28 ].Trim();
		pre_data[ 29 ].Trim();
		pre_data[ 30 ].Trim();
		pre_data[ 31 ].Trim();
		pre_data[ 32 ].Trim();
		pre_data[ 33 ].Trim();
		pre_data[ 34 ].Trim();
		pre_data[ 35 ].Trim();
		pre_data[ 36 ].Trim();
		pre_data[ 37 ].Trim();
		
		iRemainingXP[ index ] = atoi( pre_data[ 0 ] );
		iLevel[ index ] = atoi( pre_data[ 1 ] );
		iMaxColors[ index ] = atoi( pre_data[ 2 ] );
		iMaxTrails[ index ] = atoi( pre_data[ 3 ] );
		iMaxHatColors[ index ] = atoi( pre_data[ 4 ] );
		iMaxWeapons[ index ] = atoi( pre_data[ 5 ] );
		flSpawnProtectionTime[ index ] = atof( pre_data[ 6 ] );
		iTeamHPReg[ index ] = atoi( pre_data[ 7 ] );
		iTeamAPReg[ index ] = atoi( pre_data[ 8 ] );
		iCriticalResist[ index ] = atoi( pre_data[ 9 ] );
		iFalldamageResist[ index ] = atoi( pre_data[ 10 ] );
		iExtraMaxHP[ index ] = atoi( pre_data[ 11 ] );
		iExtraMaxAP[ index ] = atoi( pre_data[ 12 ] );
		iExtraStartHP[ index ] = atoi( pre_data[ 13 ] );
		if ( pre_data[ 14 ] == '1' ) bHasCosmeticPack[ index ] = true;
		iCPGlowColors[ index ] = atoi( pre_data[ 15 ] );
		if ( pre_data[ 16 ] == '1' ) bCPTrail[ index ] = true;
		iCPTrailSprite[ index ] = atoi( pre_data[ 17 ] );
		iCPTrailLong[ index ] = atoui( pre_data[ 18 ] );
		iCPTrailSize[ index ] = atoui( pre_data[ 19 ] );
		if ( pre_data[ 20 ] != 'NULL' ) szCPHatName[ index ] = pre_data[ 20 ];
		iCPHatGlowColors[ index ] = atoi( pre_data[ 21 ] );
		
		// Glow
		array< string >@ pre_vector1_1 = pre_data[ 22 ].Split( '-' );
		vecCPGlowColor[ index ][ 0 ].x = atoi( pre_vector1_1[ 0 ] );
		vecCPGlowColor[ index ][ 0 ].y = atoi( pre_vector1_1[ 1 ] );
		vecCPGlowColor[ index ][ 0 ].z = atoi( pre_vector1_1[ 2 ] );
		array< string >@ pre_vector2_1 = pre_data[ 23 ].Split( '-' );
		vecCPGlowColor[ index ][ 1 ].x = atoi( pre_vector2_1[ 0 ] );
		vecCPGlowColor[ index ][ 1 ].y = atoi( pre_vector2_1[ 1 ] );
		vecCPGlowColor[ index ][ 1 ].z = atoi( pre_vector2_1[ 2 ] );
		array< string >@ pre_vector3_1 = pre_data[ 24 ].Split( '-' );
		vecCPGlowColor[ index ][ 2 ].x = atoi( pre_vector3_1[ 0 ] );
		vecCPGlowColor[ index ][ 2 ].y = atoi( pre_vector3_1[ 1 ] );
		vecCPGlowColor[ index ][ 2 ].z = atoi( pre_vector3_1[ 2 ] );
		array< string >@ pre_vector4_1 = pre_data[ 25 ].Split( '-' );
		vecCPGlowColor[ index ][ 3 ].x = atoi( pre_vector4_1[ 0 ] );
		vecCPGlowColor[ index ][ 3 ].y = atoi( pre_vector4_1[ 1 ] );
		vecCPGlowColor[ index ][ 3 ].z = atoi( pre_vector4_1[ 2 ] );
		array< string >@ pre_vector5_1 = pre_data[ 26 ].Split( '-' );
		vecCPGlowColor[ index ][ 4 ].x = atoi( pre_vector5_1[ 0 ] );
		vecCPGlowColor[ index ][ 4 ].y = atoi( pre_vector5_1[ 1 ] );
		vecCPGlowColor[ index ][ 4 ].z = atoi( pre_vector5_1[ 2 ] );
		array< string >@ pre_vector6_1 = pre_data[ 27 ].Split( '-' );
		vecCPGlowColor[ index ][ 5 ].x = atoi( pre_vector6_1[ 0 ] );
		vecCPGlowColor[ index ][ 5 ].y = atoi( pre_vector6_1[ 1 ] );
		vecCPGlowColor[ index ][ 5 ].z = atoi( pre_vector6_1[ 2 ] );
		
		// Hat Glow
		array< string >@ pre_vector1_2 = pre_data[ 28 ].Split( '-' );
		vecCPHatGlowColor[ index ][ 0 ].x = atoi( pre_vector1_2[ 0 ] );
		vecCPHatGlowColor[ index ][ 0 ].y = atoi( pre_vector1_2[ 1 ] );
		vecCPHatGlowColor[ index ][ 0 ].z = atoi( pre_vector1_2[ 2 ] );
		array< string >@ pre_vector2_2 = pre_data[ 29 ].Split( '-' );
		vecCPHatGlowColor[ index ][ 1 ].x = atoi( pre_vector2_2[ 0 ] );
		vecCPHatGlowColor[ index ][ 1 ].y = atoi( pre_vector2_2[ 1 ] );
		vecCPHatGlowColor[ index ][ 1 ].z = atoi( pre_vector2_2[ 2 ] );
		array< string >@ pre_vector3_2 = pre_data[ 30 ].Split( '-' );
		vecCPHatGlowColor[ index ][ 2 ].x = atoi( pre_vector3_2[ 0 ] );
		vecCPHatGlowColor[ index ][ 2 ].y = atoi( pre_vector3_2[ 1 ] );
		vecCPHatGlowColor[ index ][ 2 ].z = atoi( pre_vector3_2[ 2 ] );
		array< string >@ pre_vector4_2 = pre_data[ 31 ].Split( '-' );
		vecCPHatGlowColor[ index ][ 3 ].x = atoi( pre_vector4_2[ 0 ] );
		vecCPHatGlowColor[ index ][ 3 ].y = atoi( pre_vector4_2[ 1 ] );
		vecCPHatGlowColor[ index ][ 3 ].z = atoi( pre_vector4_2[ 2 ] );
		array< string >@ pre_vector5_2 = pre_data[ 32 ].Split( '-' );
		vecCPHatGlowColor[ index ][ 4 ].x = atoi( pre_vector5_2[ 0 ] );
		vecCPHatGlowColor[ index ][ 4 ].y = atoi( pre_vector5_2[ 1 ] );
		vecCPHatGlowColor[ index ][ 4 ].z = atoi( pre_vector5_2[ 2 ] );
		array< string >@ pre_vector6_2 = pre_data[ 33 ].Split( '-' );
		vecCPHatGlowColor[ index ][ 5 ].x = atoi( pre_vector6_2[ 0 ] );
		vecCPHatGlowColor[ index ][ 5 ].y = atoi( pre_vector6_2[ 1 ] );
		vecCPHatGlowColor[ index ][ 5 ].z = atoi( pre_vector6_2[ 2 ] );
		
		// Trail
		array< string >@ pre_vector1_3 = pre_data[ 34 ].Split( '-' );
		vecCPTrailColor[ index ].x = atoi( pre_vector1_3[ 0 ] );
		vecCPTrailColor[ index ].y = atoi( pre_vector1_3[ 1 ] );
		vecCPTrailColor[ index ].z = atoi( pre_vector1_3[ 2 ] );
		
		iShopDiscount[ index ] = atoi( pre_data[ 35 ] );
		iCP[ index ] = atoi( pre_data[ 36 ] );
		dtFirstPlay[ index ].SetUnixTimestamp( atoi( pre_data[ 37 ] ) );
		
		thefile.Close();
	}
	else
	{
		// No data, load empty values
		iLevel[ index ] = 1;
		iRemainingXP[ index ] = XP_CalcNeeded( index );
		dtFirstPlay[ index ] = UnixTimestamp();
	}
	
	bLoadData[ index ] = true;
}

int XP_CalcNeeded( const int& in index )
{
	// ( 3 * level ) + ( level * level )
	return ( ( 3 * iLevel[ index ] ) + ( iLevel[ index ] * iLevel[ index ] ) );
}

void XP_AddLevel( const int& in index, int& in iTotalXP, const int& in iWinXP, const int& in iBonusXP )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null && pPlayer.IsConnected() )
	{
		HUDTextParams textParams;
		textParams.x = -1;
		textParams.y = 0.4;
		textParams.effect = 0;
		textParams.r1 = 250;
		textParams.g1 = 200;
		textParams.b1 = 10;
		textParams.a1 = 0;
		textParams.r2 = 250;
		textParams.g2 = 250;
		textParams.b2 = 250;
		textParams.a2 = 0;
		textParams.fadeinTime = 0.0;
		textParams.fadeoutTime = 0.0;
		textParams.holdTime = 255.0;
		textParams.fxTime = 0.3;
		textParams.channel = 1;
		
		// Maximum level reached. Forget about it!
		if ( iLevel[ index ] >= 100 )
			iTotalXP = 0;
		
		// Add XP
		if ( iTotalXP > 0 )
		{
			iRemainingXP[ index ]--;
			iTotalXP--;
			
			// Update HUD message
			if ( iRemainingXP[ index ] > 0 )
			{
				// No level up yet
				string szText = " \n";
				if ( iWinXP > 0 ) szText += " \n";
				if ( iBonusXP > 0 ) szText += " \n";
				szText += "\nTotal experiencia adquirida: " + AddCommas( iTotalXP ) + " EXP\n";
				szText += "Siguiente nivel a: " + AddCommas( iRemainingXP[ index ] ) + " EXP";
				
				// Sound
				g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_STATIC, "ecsc/tpvp/xp.ogg", 0.7, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, index );
				
				g_Scheduler.SetTimeout( "XP_AddLevel", 0.01, index, iTotalXP, iWinXP, iBonusXP );
				g_PlayerFuncs.HudMessage( pPlayer, textParams, szText );
			}
			else
			{
				// Level up!
				textParams.effect = 1;
				
				string szText = " \n";
				if ( iWinXP > 0 ) szText += " \n";
				if ( iBonusXP > 0 ) szText += " \n";
				szText += "\nTotal experiencia adquirida: " + AddCommas( iTotalXP ) + " EXP\n";
				szText += "LEVEL UP!";
				
				iLevel[ index ]++;
				iRemainingXP[ index ] = XP_CalcNeeded( index );
				XP_LevelUp( index );
				
				// In the event that the map is changed before all XP is given, save the data as soon as a level up is made
				// This will minimize the damage and at least keep a player level up(s)
				XP_SaveData( index );
				
				// Sound
				g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, "ecsc/tpvp/levelup.ogg", 0.9, ATTN_NONE, SND_SKIP_ORIGIN_USE_ENT, PITCH_NORM, index );
				
				g_Scheduler.SetTimeout( "XP_AddLevel", 1.15, index, iTotalXP, iWinXP, iBonusXP );
				g_PlayerFuncs.HudMessage( pPlayer, textParams, szText );
				
				// For each player that levels up, delay the mapchange by 1 second
				iChangelevelTime++;
			}
		}
		else
		{
			// Done giving XP
			string szText = " \n";
			if ( iWinXP > 0 ) szText += " \n";
			if ( iBonusXP > 0 ) szText += " \n";
			szText += "\nTotal experiencia adquirida: 0 EXP\n";
			if ( iLevel[ index ] >= 100 ) szText += "Siguiente nivel a: ------ EXP";
			else szText += "Siguiente nivel a: " + AddCommas( iRemainingXP[ index ] ) + " EXP";
			
			XP_SaveData( index );
			
			g_PlayerFuncs.HudMessage( pPlayer, textParams, szText );
		}
	}
}

void XP_LevelUp( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, Dummy_CB );
	
	string szTitle = "Subiste al Nivel " + iLevel[ index ] + "!\n\n";
	
	// LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONG hardcoded (AGAIN) list
	if ( iLevel[ index ] == 2 )
		szTitle += "Ahora puedes comprar Glows!\n";
	else if ( iLevel[ index ] == 3 )
		szTitle += "Ahora puedes comprar Trails!\n";
	else if ( iLevel[ index ] == 4 )
		szTitle += "Ahora puedes comprar Hats!\n";
	else if ( iLevel[ index ] == 5 )
		szTitle += "Ahora puedes comprar Armas!\n";
	else if ( iLevel[ index ] == 6 )
		szTitle += "Ahora puedes darle Glow a tus Hats!\n";
	else if ( iLevel[ index ] == 7 )
		szTitle += "Ahora puedes configurar tus Trails!\n";
	else if ( iLevel[ index ] == 8 || iLevel[ index ] == 13 || iLevel[ index ] == 18 || iLevel[ index ] == 24 || iLevel[ index ] == 31 )
	{
		szTitle += "Cantidad de colores de Glow aumentado en 1!\n";
		iMaxColors[ index ]++;
	}
	else if ( iLevel[ index ] == 9 || iLevel[ index ] == 14 || iLevel[ index ] == 19 || iLevel[ index ] == 25 || iLevel[ index ] == 32 || iLevel[ index ] == 38 || iLevel[ index ] == 44 || iLevel[ index ] == 47 || iLevel[ index ] == 49 || iLevel[ index ] == 51 || iLevel[ index ] == 53 || iLevel[ index ] == 55 || iLevel[ index ] == 57 || iLevel[ index ] == 59 || iLevel[ index ] == 61 || iLevel[ index ] == 63 || iLevel[ index ] == 65 || iLevel[ index ] == 67 ) // THAT'S SURELY A HUGE LINE NO?
	{
		szTitle += "Nuevo tipo de Trail adquirido!\n";
		iMaxTrails[ index ]++;
	}
	else if ( iLevel[ index ] == 10 || iLevel[ index ] == 28 || iLevel[ index ] == 43 || iLevel[ index ] == 56 || iLevel[ index ] == 75 || iLevel[ index ] == 85 || iLevel[ index ] == 92 || iLevel[ index ] == 95 || iLevel[ index ] == 97 || iLevel[ index ] == 99 )
	{
		szTitle += "Resistencia a las caidas aumentado en 1%!\n";
		iFalldamageResist[ index ]++;
	}
	else if ( iLevel[ index ] == 11 || iLevel[ index ] == 29 || iLevel[ index ] == 52 || iLevel[ index ] == 71 )
	{
		szTitle += "Armas Auto-Comprables aumentado en 1!\n";
		iMaxWeapons[ index ]++;
	}
	else if ( iLevel[ index ] == 12 || iLevel[ index ] == 35 || iLevel[ index ] == 54 || iLevel[ index ] == 74 || iLevel[ index ] == 84 || iLevel[ index ] == 91 )
	{
		szTitle += "Proteccion de Spawn aumentado en 0.2 segundos!\n";
		flSpawnProtectionTime[ index ] += 0.2;
	}
	else if ( iLevel[ index ] == 15 || iLevel[ index ] == 30 || iLevel[ index ] == 46 || iLevel[ index ] == 60 || iLevel[ index ] == 77 )
	{
		szTitle += "Descuento en la Tienda aumentado en 2%!\n";
		iShopDiscount[ index ] += 2;
	}
	else if ( iLevel[ index ] == 16 || iLevel[ index ] == 36 || iLevel[ index ] == 66 || iLevel[ index ] == 80 || iLevel[ index ] == 87 )
	{
		szTitle += "EquipoRegeneracion de Vida aumentado en 2%!\n";
		iTeamHPReg[ index ] += 2;
	}
	else if ( iLevel[ index ] == 17 || iLevel[ index ] == 37 || iLevel[ index ] == 68 || iLevel[ index ] == 81 || iLevel[ index ] == 88 )
	{
		szTitle += "EquipoRegeneracion de Armadura aumentado en 1%!\n";
		iTeamAPReg[ index ]++;
	}
	else if ( iLevel[ index ] == 20 || iLevel[ index ] == 26 || iLevel[ index ] == 33 || iLevel[ index ] == 40 || iLevel[ index ] == 45 )
	{
		szTitle += "Cantidad de colores de Hat Glow aumentado en 1!\n";
		iMaxHatColors[ index ]++;
	}
	else if ( iLevel[ index ] == 21 || iLevel[ index ] == 39 || iLevel[ index ] == 58 || iLevel[ index ] == 76 || iLevel[ index ] == 86 )
	{
		szTitle += "Resistencia Critica aumentada en 1%!\n";
		iCriticalResist[ index ]++;
	}
	else if ( iLevel[ index ] == 22 || iLevel[ index ] == 41 || iLevel[ index ] == 62 || iLevel[ index ] == 78 )
		szTitle += "Velocidad de Bomba C4 aumentada en 2%!\n";
	else if ( iLevel[ index ] == 23 || iLevel[ index ] == 42 || iLevel[ index ] == 64 || iLevel[ index ] == 79 )
		szTitle += "Velocidad de Captura aumentada en 2%!\n";
	else if ( iLevel[ index ] == 27 || iLevel[ index ] == 48 || iLevel[ index ] == 72 || iLevel[ index ] == 82 || iLevel[ index ] == 89 || iLevel[ index ] == 93 || iLevel[ index ] == 96 )
	{
		szTitle += "Vida Maxima aumentada en 1!\n";
		iExtraMaxHP[ index ]++;
	}
	else if ( iLevel[ index ] == 34 || iLevel[ index ] == 50 || iLevel[ index ] == 73 || iLevel[ index ] == 83 || iLevel[ index ] == 90 || iLevel[ index ] == 94 || iLevel[ index ] == 98 )
	{
		szTitle += "Armadura Maxima aumentada en 1!\n";
		iExtraMaxAP[ index ]++;
	}
	else if ( iLevel[ index ] == 69 )
		szTitle += "Ahora puedes comprar un Paquete Cosmetico!\n";
	else if ( iLevel[ index ] == 70 )
		szTitle += "Ahora puedes comprar Vision Nocturna!\n";
	else if ( iLevel[ index ] == 100 )
	{
		szTitle += "Vida Inicial aumentada en 1!\n";
		iExtraStartHP[ index ]++;
	}
	
	state.menu.SetTitle( szTitle );
	state.menu.AddItem( "OK", any( "item1" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void XP_SetBoost( const int& in index )
{
	// Boosting is disabled, don't
	if ( !bAllowBoost )
		return;
	
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
	{
		if ( flSpawnProtectionTime[ index ] > 0.0 )
		{
			pPlayer.pev.flags |= FL_GODMODE;
			g_Scheduler.SetTimeout( "XP_GodmodeOFF", flSpawnProtectionTime[ index ], index );
		}
		
		pPlayer.pev.max_health += float( iExtraMaxHP[ index ] );
		pPlayer.pev.armortype += float( iExtraMaxAP[ index ] );
		pPlayer.pev.health += float( iExtraStartHP[ index ] );
		
		// Locate nearby players for TeamRegeneration
		CBaseEntity@ pOther = null;
		while( ( @pOther = g_EntityFuncs.FindEntityByClassname( pOther, "player" ) ) !is null )
		{
			if ( cast< CBasePlayer@ >( pOther ).IsConnected() )
			{
				if ( ( pPlayer.pev.origin - pOther.pev.origin ).Length() <= 128.0 )
				{
					float flMaxHealth = pOther.pev.max_health;
					float flMaxArmor = pOther.pev.armortype;
					
					pOther.pev.health += ( flMaxHealth * float( iTeamHPReg[ index ] ) / 100.0 );
					pOther.pev.armorvalue += ( flMaxArmor * float( iTeamAPReg[ index ] ) / 100.0 );
				}
			}
		}
	}
}

void XP_GodmodeOFF( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
		pPlayer.pev.flags &= ~FL_GODMODE;
}

void Dummy_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	// Dummy callback
}

void CP_Think()
{
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			// Player glow
			if ( bGlow[ i ][ 0 ] && iGlowAlternate[ i ] == 1 )
			{
				pPlayer.pev.renderfx = kRenderFxGlowShell;
				pPlayer.pev.renderamt = 3;
				pPlayer.pev.rendercolor = vecGlowColor[ i ][ 0 ];
				
				if ( bGlow[ i ][ 1 ] )
					iGlowAlternate[ i ] = 2;
				else
					iGlowAlternate[ i ] = 1;
			}
			else if ( bGlow[ i ][ 1 ] && iGlowAlternate[ i ] == 2 )
			{
				pPlayer.pev.renderfx = kRenderFxGlowShell;
				pPlayer.pev.renderamt = 3;
				pPlayer.pev.rendercolor = vecGlowColor[ i ][ 1 ];
				
				if ( bGlow[ i ][ 2 ] )
					iGlowAlternate[ i ] = 3;
				else
					iGlowAlternate[ i ] = 1;
			}
			else if ( bGlow[ i ][ 2 ] && iGlowAlternate[ i ] == 3 )
			{
				pPlayer.pev.renderfx = kRenderFxGlowShell;
				pPlayer.pev.renderamt = 3;
				pPlayer.pev.rendercolor = vecGlowColor[ i ][ 2 ];
				
				if ( bGlow[ i ][ 3 ] )
					iGlowAlternate[ i ] = 4;
				else
					iGlowAlternate[ i ] = 1;
			}
			else if ( bGlow[ i ][ 3 ] && iGlowAlternate[ i ] == 4 )
			{
				pPlayer.pev.renderfx = kRenderFxGlowShell;
				pPlayer.pev.renderamt = 3;
				pPlayer.pev.rendercolor = vecGlowColor[ i ][ 3 ];
				
				if ( bGlow[ i ][ 4 ] )
					iGlowAlternate[ i ] = 5;
				else
					iGlowAlternate[ i ] = 1;
			}
			else if ( bGlow[ i ][ 4 ] && iGlowAlternate[ i ] == 5 )
			{
				pPlayer.pev.renderfx = kRenderFxGlowShell;
				pPlayer.pev.renderamt = 3;
				pPlayer.pev.rendercolor = vecGlowColor[ i ][ 4 ];
				
				if ( bGlow[ i ][ 5 ] )
					iGlowAlternate[ i ] = 6;
				else
					iGlowAlternate[ i ] = 1;
			}
			else if ( bGlow[ i ][ 5 ] && iGlowAlternate[ i ] == 6 )
			{
				pPlayer.pev.renderfx = kRenderFxGlowShell;
				pPlayer.pev.renderamt = 3;
				pPlayer.pev.rendercolor = vecGlowColor[ i ][ 5 ];
				
				iGlowAlternate[ i ] = 1;
			}
			
			// Trail
			if ( bTrail[ i ] && !bTrailActive[ i ] && pPlayer.pev.velocity.Length() >= 2 )
			{
				bTrailActive[ i ] = true;
				if ( vecTrailColor[ i ] != g_vecZero )
				{
					uint8 r = int( vecTrailColor[ i ].x );
					uint8 g = int( vecTrailColor[ i ].y );
					uint8 b = int( vecTrailColor[ i ].z );
					
					NetworkMessage restarter( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
					restarter.WriteByte( TE_KILLBEAM );
					restarter.WriteShort( pPlayer.entindex() );
					restarter.End();
					
					NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
					message.WriteByte( TE_BEAMFOLLOW );
					message.WriteShort( pPlayer.entindex() );
					message.WriteShort( iTrailSpriteIndex[ iTrailSprite[ i ] ] );
					message.WriteByte( iTrailLong[ i ] );
					message.WriteByte( iTrailSize[ i ] );
					message.WriteByte( r );
					message.WriteByte( g );
					message.WriteByte( b );
					message.WriteByte( 200 );
					message.End();
				}
			}
			else if ( bTrailActive[ i ] && pPlayer.pev.velocity.Length() == 0 )
				bTrailActive[ i ] = false;
			
			// Hat glow
			CBaseEntity@ pHat = hatEntity[ i ].GetEntity();
			if ( pHat !is null )
			{
				if ( bHatGlow[ i ][ 0 ] && iHatGlowAlternate[ i ] == 1 )
				{
					pHat.pev.renderfx = kRenderFxGlowShell;
					pHat.pev.renderamt = 3;
					pHat.pev.rendercolor = vecHatGlowColor[ i ][ 0 ];
					
					if ( bHatGlow[ i ][ 1 ] )
						iHatGlowAlternate[ i ] = 2;
					else
						iHatGlowAlternate[ i ] = 1;
				}
				else if ( bHatGlow[ i ][ 1 ] && iHatGlowAlternate[ i ] == 2 )
				{
					pHat.pev.renderfx = kRenderFxGlowShell;
					pHat.pev.renderamt = 3;
					pHat.pev.rendercolor = vecHatGlowColor[ i ][ 1 ];
					
					if ( bHatGlow[ i ][ 2 ] )
						iHatGlowAlternate[ i ] = 3;
					else
						iHatGlowAlternate[ i ] = 1;
				}
				else if ( bHatGlow[ i ][ 2 ] && iHatGlowAlternate[ i ] == 3 )
				{
					pHat.pev.renderfx = kRenderFxGlowShell;
					pHat.pev.renderamt = 3;
					pHat.pev.rendercolor = vecHatGlowColor[ i ][ 2 ];
					
					if ( bHatGlow[ i ][ 3 ] )
						iHatGlowAlternate[ i ] = 4;
					else
						iHatGlowAlternate[ i ] = 1;
				}
				else if ( bHatGlow[ i ][ 3 ] && iHatGlowAlternate[ i ] == 4 )
				{
					pHat.pev.renderfx = kRenderFxGlowShell;
					pHat.pev.renderamt = 3;
					pHat.pev.rendercolor = vecHatGlowColor[ i ][ 3 ];
					
					if ( bHatGlow[ i ][ 4 ] )
						iHatGlowAlternate[ i ] = 5;
					else
						iHatGlowAlternate[ i ] = 1;
				}
				else if ( bHatGlow[ i ][ 4 ] && iHatGlowAlternate[ i ] == 5 )
				{
					pHat.pev.renderfx = kRenderFxGlowShell;
					pHat.pev.renderamt = 3;
					pHat.pev.rendercolor = vecHatGlowColor[ i ][ 4 ];
					
					if ( bHatGlow[ i ][ 5 ] )
						iHatGlowAlternate[ i ] = 6;
					else
						iHatGlowAlternate[ i ] = 1;
				}
				else if ( bHatGlow[ i ][ 5 ] && iHatGlowAlternate[ i ] == 6 )
				{
					pHat.pev.renderfx = kRenderFxGlowShell;
					pHat.pev.renderamt = 3;
					pHat.pev.rendercolor = vecHatGlowColor[ i ][ 5 ];
					
					iHatGlowAlternate[ i ] = 1;
				}
			}
		}
	}
}

void GlowCommand( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	int index = pPlayer.entindex();
	
	if ( bIsCPActive[ index ] )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero apaga tu Paquete Cosmetico\n" );
		return;
	}
	
	const CCommand@ args = pParams.GetArguments();
	
	if ( args.ArgC() > 1 )
	{
		if ( args[ 1 ].ToLowercase() == 'menu' ) // Open menu
		{
			g_Scheduler.SetTimeout( "CP_Glows", 0.01, index );
			return;
		}
		else if ( args[ 1 ].ToLowercase() == 'off' ) // Turn off glow
		{
			g_Scheduler.SetTimeout( "CP_Glows_Remove", 0.01, index );
			return;
		}
		
		// Get arguments and cost
		int iArguments = args.ArgC() - 1; if ( iArguments > iMaxColors[ index ] ) iArguments = iMaxColors[ index ];
		int iCost = 264;
		switch ( iArguments )
		{
			case 1: iCost = 240; break;
			case 2: iCost = 432; break;
			case 3: iCost = 576; break;
			case 4: iCost = 672; break;
			case 5: iCost = 720; break;
			case 6: iCost = 744; break;
		}
		
		// Enough CP?
		if ( iCP[ index ] >= GetShopDiscount( index, iCost ) )
		{
			// Reset!
			for ( int i = 0; i < 6; i++ )
			{
				bGlow[ index ][ i ] = false;
				vecGlowColor[ index ][ i ] = g_vecZero;
			}
			
			int iColor1 = -1;
			int iColor2 = -1;
			int iColor3 = -1;
			int iColor4 = -1;
			int iColor5 = -1;
			int iColor6 = -1;
			
			// Color 1
			iColor1 = _ColorNames.find( args[ 1 ].ToLowercase() ); // Find color
			if ( iColor1 >= 0 )
			{
				// Using a 2nd color?
				if ( iArguments >= 2 )
				{
					iColor2 = _ColorNames.find( args[ 2 ].ToLowercase() ); // Find color
					if ( iColor2 >= 0 )
					{
						// Using a 3rd color?
						if ( iArguments >= 3 )
						{
							iColor3 = _ColorNames.find( args[ 3 ].ToLowercase() ); // Find color
							if ( iColor3 >= 0 )
							{
								// Using a 4th color?
								if ( iArguments >= 4 )
								{
									iColor4 = _ColorNames.find( args[ 4 ].ToLowercase() ); // Find color
									if ( iColor4 >= 0 )
									{
										// Using a 5th color?
										if ( iArguments >= 5 )
										{
											iColor5 = _ColorNames.find( args[ 5 ].ToLowercase() ); // Find color
											if ( iColor5 >= 0 )
											{
												// Using a 6th color?
												if ( iArguments >= 6 )
												{
													iColor6 = _ColorNames.find( args[ 6 ].ToLowercase() ); // Find color
													if ( iColor6 >= 0 )
													{
														// Apply color
														bGlow[ index ][ 5 ] = true;
														vecGlowColor[ index ][ 5 ] = _ColorCodes[ iColor6 ];
													}
													else
													{
														g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 6 ].ToLowercase() + "\n" );
														return;
													}
												}
												
												// Apply color
												bGlow[ index ][ 4 ] = true;
												vecGlowColor[ index ][ 4 ] = _ColorCodes[ iColor5 ];
											}
											else
											{
												g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 5 ].ToLowercase() + "\n" );
												return;
											}
										}
										
										// Apply color
										bGlow[ index ][ 3 ] = true;
										vecGlowColor[ index ][ 3 ] = _ColorCodes[ iColor4 ];
									}
									else
									{
										g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 4 ].ToLowercase() + "\n" );
										return;
									}
								}
								
								// Apply color
								bGlow[ index ][ 2 ] = true;
								vecGlowColor[ index ][ 2 ] = _ColorCodes[ iColor3 ];
							}
							else
							{
								g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 3 ].ToLowercase() + "\n" );
								return;
							}
						}
						
						// Apply color
						bGlow[ index ][ 1 ] = true;
						vecGlowColor[ index ][ 1 ] = _ColorCodes[ iColor2 ];
					}
					else
					{
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 2 ].ToLowercase() + "\n" );
						return;
					}
				}
				
				// Apply color
				bGlow[ index ][ 0 ] = true;
				vecGlowColor[ index ][ 0 ] = _ColorCodes[ iColor1 ];
				
				iCP[ index ] -= GetShopDiscount( index, iCost );
				
				string szColor1 = _ColorNames[ iColor1 ];
				string szColor2 = ""; if ( iArguments >= 2 ) szColor2 = _ColorNames[ iColor2 ];
				string szColor3 = ""; if ( iArguments >= 3 ) szColor3 = _ColorNames[ iColor3 ];
				string szColor4 = ""; if ( iArguments >= 4 ) szColor4 = _ColorNames[ iColor4 ];
				string szColor5 = ""; if ( iArguments >= 5 ) szColor5 = _ColorNames[ iColor5 ];
				string szColor6 = ""; if ( iArguments >= 6 ) szColor6 = _ColorNames[ iColor6 ];
				
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tu glow ahora es: " + szColor1 + " " + szColor2 + " " + szColor3 + " " + szColor4 + " " + szColor5 + " " + szColor6 + "\n" );
			}
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 1 ].ToLowercase() + "\n" );
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes (Necesitas: " + GetShopDiscount( index, iCost ) + " C)\n" );
	}
	else
		g_Scheduler.SetTimeout( "CP_Glows", 0.01, index );
}

void TrailCommand( SayParameters@ pParams )
{
	pParams.ShouldHide = true;
	
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	int index = pPlayer.entindex();
	
	if ( bIsCPActive[ index ] )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero apaga tu Paquete Cosmetico\n" );
		return;
	}
	
	const CCommand@ args = pParams.GetArguments();
	
	if ( args.ArgC() > 1 )
	{
		if ( args[ 1 ].ToLowercase() == 'menu' ) // Open menu
		{
			g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
			return;
		}
		else if ( args[ 1 ].ToLowercase() == 'off' ) // Turn off trail
		{
			g_Scheduler.SetTimeout( "CP_Trails_Remove", 0.01, index );
			return;
		}
		
		// Store arguments
		uint8 iType = 0;
		uint8 iLong = 20;
		uint8 iSize = 8;
		if ( ( args.ArgC() - 1 ) >= 2 )
		{
			// Type check
			if ( args[ 2 ].ToUppercase() == 'A' ) iType = 0;
			else if ( args[ 2 ].ToUppercase() == 'B' ) iType = 1;
			else if ( args[ 2 ].ToUppercase() == 'C' ) iType = 2;
			else if ( args[ 2 ].ToUppercase() == 'D' ) iType = 3;
			else if ( args[ 2 ].ToUppercase() == 'E' ) iType = 4;
			else if ( args[ 2 ].ToUppercase() == 'F' ) iType = 5;
			else if ( args[ 2 ].ToUppercase() == 'G' ) iType = 6;
			else if ( args[ 2 ].ToUppercase() == 'H' ) iType = 7;
			else if ( args[ 2 ].ToUppercase() == 'I' ) iType = 8;
			else if ( args[ 2 ].ToUppercase() == 'J' ) iType = 9;
			else if ( args[ 2 ].ToUppercase() == 'K' ) iType = 10;
			else if ( args[ 2 ].ToUppercase() == 'L' ) iType = 11;
			else if ( args[ 2 ].ToUppercase() == 'M' ) iType = 12;
			else if ( args[ 2 ].ToUppercase() == 'N' ) iType = 13;
			else if ( args[ 2 ].ToUppercase() == 'O' ) iType = 14;
			else if ( args[ 2 ].ToUppercase() == 'P' ) iType = 15;
			else if ( args[ 2 ].ToUppercase() == 'Q' ) iType = 16;
			else if ( args[ 2 ].ToUppercase() == 'R' ) iType = 17;
			else if ( args[ 2 ].ToUppercase() == 'S' ) iType = 18;
			else
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Tipo de Trail fuera de rango o incorrecta\n" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Solo se permiten letras desde la \"A\" hasta la \"S\"\n" );
				return;
			}
			
			// Level check
			if ( ( iType + 1 ) > uint8( iMaxTrails[ index ] ) )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Ese tipo de Trail esta fuera de tus limites (" + args[ 2 ] + ")\n" );
				return;
			}
		}
		if ( ( args.ArgC() - 1 ) >= 3 ) iLong = atoui( args[ 3 ] );
		if ( ( args.ArgC() - 1 ) >= 4 ) iSize = atoui( args[ 4 ] );
		
		// If we do not have access to trail settings, force reset them to default values
		if ( iLevel[ index ] < 7 )
		{
			iType = 0;
			iLong = 20;
			iSize = 8;
		}
		
		// Long check
		if ( iLong > 50 || iLong < 10 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Longitud del trail fuera de rango\n" );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Solo se permiten numeros entre 10 y 50\n" );
			return;
		}
		
		// Size check
		if ( iSize > 20 || iLong < 4 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Anchura del trail fuera de rango\n" );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Solo se permiten numeros entre 4 y 20\n" );
			return;
		}
		
		// Enough CP?
		if ( iCP[ index ] >= GetShopDiscount( index, 280 ) )
		{
			int iColor = _ColorNames.find( args[ 1 ].ToLowercase() ); // Find color
			if ( iColor >= 0 )
			{
				// Apply color
				bTrail[ index ] = true;
				vecTrailColor[ index ] = _ColorCodes[ iColor ];
				
				iCP[ index ] -= GetShopDiscount( index, 280 );
				
				// Set trail arguments, if they have
				iTrailSprite[ index ] = iType;
				iTrailLong[ index ] = iLong;
				iTrailSize[ index ] = iSize;
				
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Trail de color: " + _ColorNames[ iColor ] + "\n" );
			}
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color desconocido: " + args[ 1 ].ToLowercase() + "\n" );
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes (Necesitas: " + GetShopDiscount( index, 280 ) + " C)\n" );
	}
	else
		g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
}

void CPMenu( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CPMenu_CB );
	state.menu.SetTitle( "Tienda\n\nTienes " + AddCommas( iCP[ index ] ) + " Creditos\n\n" );
	
	if ( iLevel[ index ] >= 2 ) state.menu.AddItem( "Glows\n", any( "item1" ) );
	if ( iLevel[ index ] >= 3 ) state.menu.AddItem( "Trails\n", any( "item2" ) );
	if ( iLevel[ index ] >= 4 ) state.menu.AddItem( "Hats\n", any( "item3" ) );
	if ( iLevel[ index ] >= 5 ) state.menu.AddItem( "Armas\n", any( "item4" ) );
	state.menu.AddItem( "Otros\n", any( "item5" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CPMenu_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( bIsCPActive[ index ] )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero apaga tu Paquete Cosmetico\n" );
			g_Scheduler.SetTimeout( "CPMenu", 0.01, index );
		}
		else
			g_Scheduler.SetTimeout( "CP_Glows", 0.01, index );
	}
	else if ( selection == 'item2' )
	{
		if ( bIsCPActive[ index ] )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero apaga tu Paquete Cosmetico\n" );
			g_Scheduler.SetTimeout( "CPMenu", 0.01, index );
		}
		else
			g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
	}
	else if ( selection == 'item3' )
	{
		if ( bIsCPActive[ index ] )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero apaga tu Paquete Cosmetico\n" );
			g_Scheduler.SetTimeout( "CPMenu", 0.01, index );
		}
		else
			g_Scheduler.SetTimeout( "CP_Hats", 0.01, index );
	}
	else if ( selection == 'item4' )
		g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
	else if ( selection == 'item5' )
		g_Scheduler.SetTimeout( "CP_Other", 0.01, index );
}

void CP_Glows( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Glows_CB );
	state.menu.SetTitle( "Glows\n\nTienes: " + AddCommas( iCP[ index ] ) + " C\n\n" );
	
	state.menu.AddItem( "Comprar glow\n", any( "item1" ) );
	state.menu.AddItem( "Quitar glow\n\n", any( "item2" ) );
	
	string szItem3 = "Cantidad de colores: " + iSelectedColors[ index ] + "\n";
	state.menu.AddItem( szItem3, any( "item3" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Glows_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		int iCost = 0;
		switch ( iSelectedColors[ index ] )
		{
			case 1: iCost = 240; break;
			case 2: iCost = 432; break;
			case 3: iCost = 576; break;
			case 4: iCost = 672; break;
			case 5: iCost = 720; break;
			case 6: iCost = 744; break;
		}
		
		if ( iCP[ index ] >= GetShopDiscount( index, iCost ) )
		{
			iChoosenColors[ index ] = 0;
			if ( bGlow[ index ][ 0 ] ) bShouldUpdate[ index ] = true;
			
			g_Scheduler.SetTimeout( "CP_Glows_Default", 0.01, index );
		}
		else
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes (Necesitas: " + GetShopDiscount( index, iCost ) + " C)\n" );
			g_Scheduler.SetTimeout( "CP_Glows", 0.01, index );
		}
	}
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Glows_Remove", 0.01, index );
	else if ( selection == 'item3' )
	{
		iSelectedColors[ index ]++;
		if ( iSelectedColors[ index ] > iMaxColors[ index ] )
			iSelectedColors[ index ] = 1;
		
		g_Scheduler.SetTimeout( "CP_Glows", 0.01, index );
	}
}

void CP_Glows_Default( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Glows_Default_CB );
	
	string szCost = "Costo total: ";
	switch ( iSelectedColors[ index ] )
	{
		case 1: szCost += string( GetShopDiscount( index, 240 ) ) + " C"; break;
		case 2: szCost += string( GetShopDiscount( index, 432 ) ) + " C"; break;
		case 3: szCost += string( GetShopDiscount( index, 576 ) ) + " C"; break;
		case 4: szCost += string( GetShopDiscount( index, 672 ) ) + " C"; break;
		case 5: szCost += string( GetShopDiscount( index, 720 ) ) + " C"; break;
		case 6: szCost += string( GetShopDiscount( index, 744 ) ) + " C"; break;
	}
	string szTitle = "Comprar glow\n\nTienes: " + AddCommas( iCP[ index ] ) + " C\n" + szCost + "\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _ColorNames.length(); i++ )
	{
		state.menu.AddItem( _ColorNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Glows_Default_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Glows", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iColor = atoi( selection );
	
	if ( !bShouldUpdate[ index ] )
		vecGlowColor[ index ][ iChoosenColors[ index ] ] = _ColorCodes[ iColor ];
	else
		vecGlowUpdate[ index ][ iChoosenColors[ index ] ] = _ColorCodes[ iColor ];
	
	iChoosenColors[ index ]++;
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color " + iChoosenColors[ index ] + ": " + _ColorNames[ iColor ] + "\n" );
	
	if ( iChoosenColors[ index ] == iSelectedColors[ index ] )
	{
		bGlow[ index ][ 0 ] = false;
		bGlow[ index ][ 1 ] = false;
		bGlow[ index ][ 2 ] = false;
		bGlow[ index ][ 3 ] = false;
		bGlow[ index ][ 4 ] = false;
		bGlow[ index ][ 5 ] = false;
		
		for( int i = 0; i < iSelectedColors[ index ]; i++ )
		{
			switch ( iMaxColors[ index ] )
			{
				case 1: iCP[ index ] -= GetShopDiscount( index, 240 ); break;
				case 2: iCP[ index ] -= GetShopDiscount( index, 216 ); break;
				case 3: iCP[ index ] -= GetShopDiscount( index, 192 ); break;
				case 4: iCP[ index ] -= GetShopDiscount( index, 168 ); break;
				case 5: iCP[ index ] -= GetShopDiscount( index, 144 ); break;
				case 6: iCP[ index ] -= GetShopDiscount( index, 124 ); break;
			}
			bGlow[ index ][ i ] = true;
			
			if ( bShouldUpdate[ index ] )
				vecGlowColor[ index ][ i ] = vecGlowUpdate[ index ][ i ];
		}
		
		bShouldUpdate[ index ] = false;
	}
	else
		g_Scheduler.SetTimeout( "CP_Glows_Default", 0.01, index );
	
	return;
}

void CP_Glows_Remove( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	for ( int i = 0; i < 6; i++ )
	{
		bGlow[ index ][ i ] = false;
		vecGlowColor[ index ][ i ] = g_vecZero;
	}
	iGlowAlternate[ index ] = 1;
	
	pPlayer.pev.renderfx = 0;
	pPlayer.pev.renderamt = 0;
	pPlayer.pev.rendercolor = g_vecZero;
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Te quitaste el glow\n" );
}

void CP_Trails( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Trails_CB );
	state.menu.SetTitle( "Trails\n\nTienes " + AddCommas( iCP[ index ] ) + " C\n\n" );
	
	state.menu.AddItem( "Comprar trail\n", any( "item1" ) );
	state.menu.AddItem( "Quitar trail\n\n", any( "item2" ) );
	
	if ( iLevel[ index ] >= 7 )
	{
		string szItem3 = "Longitud del trail: ";
		switch ( ( !bTrail[ index ] ? iTrailLong[ index ] : iTrailNewLong[ index ] ) )
		{
			case 10: szItem3 += "Pequenia\n"; break;
			case 20: szItem3 += "Mediana\n"; break;
			case 30: szItem3 += "Grande\n"; break;
			case 40: szItem3 += "Muy grande\n"; break;
			case 50: szItem3 += "Excesiva\n"; break;
		}
		state.menu.AddItem( szItem3, any( "item3" ) );
		
		string szItem4 = "Anchura del trail: ";
		switch ( ( !bTrail[ index ] ? iTrailSize[ index ] : iTrailNewSize[ index ] ) )
		{
			case 4: szItem4 += "Pequenia\n"; break;
			case 8: szItem4 += "Mediana\n"; break;
			case 12: szItem4 += "Grande\n"; break;
			case 16: szItem4 += "Muy grande\n"; break;
			case 20: szItem4 += "Excesiva\n"; break;
		}
		state.menu.AddItem( szItem4, any( "item4" ) );
		
		string szItem5 = "Trail de Tipo ";
		switch ( ( !bTrail[ index ] ? iTrailSprite[ index ] : iTrailNewSprite[ index ] ) )
		{
			case 0: szItem5 += "A"; break;
			case 1: szItem5 += "B"; break;
			case 2: szItem5 += "C"; break;
			case 3: szItem5 += "D"; break;
			case 4: szItem5 += "E"; break;
			case 5: szItem5 += "F"; break;
			case 6: szItem5 += "G"; break;
			case 7: szItem5 += "H"; break;
			case 8: szItem5 += "I"; break;
			case 9: szItem5 += "J"; break;
			case 10: szItem5 += "K"; break;
			case 11: szItem5 += "L"; break;
			case 12: szItem5 += "M"; break;
			case 13: szItem5 += "N"; break;
			case 14: szItem5 += "O"; break;
			case 15: szItem5 += "P"; break;
			case 16: szItem5 += "Q"; break;
			case 17: szItem5 += "R"; break;
			case 18: szItem5 += "S"; break;
		}
		state.menu.AddItem( szItem5, any( "item5" ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Trails_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( iCP[ index ] >= GetShopDiscount( index, 280 ) )
		{
			if ( bTrail[ index ] ) bShouldUpdate[ index ] = true;
			g_Scheduler.SetTimeout( "CP_Trails_Default", 0.01, index );
		}
		else
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes (Necesitas: " + GetShopDiscount( index, 280 ) + " C)\n" );
			g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
		}
	}
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Trails_Remove", 0.01, index );
	else if ( selection == 'item3' )
	{
		if ( !bTrail[ index ] )
		{
			iTrailLong[ index ] += 10;
			if ( iTrailLong[ index ] > 50 )
				iTrailLong[ index ] = 10;
		}
		else
		{
			iTrailNewLong[ index ] += 10;
			if ( iTrailNewLong[ index ] > 50 )
				iTrailNewLong[ index ] = 10;
		}
		
		g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
	}
	else if ( selection == 'item4' )
	{
		if ( !bTrail[ index ] )
		{
			iTrailSize[ index ] += 4;
			if ( iTrailSize[ index ] > 20 )
				iTrailSize[ index ] = 4;
		}
		else
		{
			iTrailNewSize[ index ] += 4;
			if ( iTrailNewSize[ index ] > 20 )
				iTrailNewSize[ index ] = 4;
		}
		
		g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
	}
	else if ( selection == 'item5' )
	{
		if ( !bTrail[ index ] )
		{
			iTrailSprite[ index ]++;
			if ( iTrailSprite[ index ] > 18 || ( iTrailSprite[ index ] + 1 ) > iMaxTrails[ index ] )
				iTrailSprite[ index ] = 0;
		}
		else
		{
			iTrailNewSprite[ index ]++;
			if ( iTrailNewSprite[ index ] > 18 || ( iTrailNewSprite[ index ] + 1 ) > iMaxTrails[ index ] )
				iTrailNewSprite[ index ] = 0;
		}
		
		g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
	}
}

void CP_Trails_Default( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Trails_Default_CB );
	
	string szTitle = "Comprar trail\n\nTienes: " + iCP[ index ] + " C\nCosto: " + GetShopDiscount( index, 280 ) + " C\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _ColorNames.length(); i++ )
	{
		state.menu.AddItem( _ColorNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Trails_Default_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Trails", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iColor = atoi( selection );
	
	if ( !bShouldUpdate[ index ] )
		vecTrailColor[ index ] = _ColorCodes[ iColor ];
	else
		vecTrailUpdate[ index ] = _ColorCodes[ iColor ];
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color del trail: " + _ColorNames[ iColor ] + "\n" );
	
	bTrail[ index ] = true;
	iCP[ index ] -= GetShopDiscount( index, 280 );
	
	if ( bShouldUpdate[ index ] )
	{
		vecTrailColor[ index ] = vecTrailUpdate[ index ];
		iTrailSprite[ index ] = iTrailNewSprite[ index ];
		iTrailLong[ index ] = iTrailNewLong[ index ];
		iTrailSize[ index ] = iTrailNewSize[ index ];
	}
	
	bShouldUpdate[ index ] = false;
	
	return;
}

void CP_Trails_Remove( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	bTrail[ index ] = false;
	vecTrailColor[ index ] = g_vecZero;
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Te quitaste el trail\n" );
}

void CP_Hats( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Hats_CB );
	state.menu.SetTitle( "Hats\n\nTienes " + AddCommas( iCP[ index ] ) + " C\n\n" );
	
	state.menu.AddItem( "Elegir hat\n", any( "item1" ) );
	state.menu.AddItem( "Quitar hat\n\n", any( "item2" ) );
	
	if ( iLevel[ index ] >= 6 )
	{
		string szItem3 = "Hat Glow: ";
		if ( iHatSelectedColors[ index ] == 0 )
			szItem3 += "[ NO ]";
		else if ( iHatSelectedColors[ index ] == 1 )
			szItem3 += "1 color\n";
		else
			szItem3 += "" + iHatSelectedColors[ index ] + " colores\n";
		state.menu.AddItem( szItem3, any( "item3" ) );
		
		if ( iHatSelectedColors[ index ] > 0 )
			state.menu.AddItem( "Elegir colores", any( "item4" ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Hats_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		int iCost = 232;
		switch ( iHatSelectedColors[ index ] )
		{
			case 0: iCost += 0; break;
			case 1: iCost += 24; break;
			case 2: iCost += 43; break;
			case 3: iCost += 58; break;
			case 4: iCost += 67; break;
			case 5: iCost += 72; break;
			case 6: iCost += 75; break;
		}
		
		if ( iCP[ index ] >= GetShopDiscount( index, iCost ) )
			g_Scheduler.SetTimeout( "CP_Hats_Select", 0.01, index );
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes (Necesitas: " + GetShopDiscount( index, iCost ) + " C)\n" );
	}
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Hats_Remove", 0.01, index );
	else if ( selection == 'item3' )
	{
		iHatSelectedColors[ index ]++;
		if ( iHatSelectedColors[ index ] > iMaxHatColors[ index ] )
			iHatSelectedColors[ index ] = 0;
		
		g_Scheduler.SetTimeout( "CP_Hats", 0.01, index );
	}
	else if ( selection == 'item4' )
	{
		iHatChoosenColors[ index ] = 0;
		if ( bHatGlow[ index ][ 0 ] ) bShouldUpdate[ index ] = true;
		
		g_Scheduler.SetTimeout( "CP_Hats_Color", 0.01, index );
	}
}

void CP_Hats_Select( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Hats_Select_CB );
	
	int iCost = 232;
	switch ( iHatSelectedColors[ index ] )
	{
		case 0: iCost += 0; break;
		case 1: iCost += 24; break;
		case 2: iCost += 43; break;
		case 3: iCost += 58; break;
		case 4: iCost += 67; break;
		case 5: iCost += 72; break;
		case 6: iCost += 75; break;
	}
	
	string szTitle = "Elegir hat\n\nTienes: " + AddCommas( iCP[ index ] ) + " C\nCosto: " + GetShopDiscount( index, iCost ) + " C\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _HatsNames.length(); i++ )
	{
		state.menu.AddItem( _HatsNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Hats_Select_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Hats", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iHat = atoi( selection );
	
	if ( bHatGlow[ index ][ 0 ] && vecHatGlowColor[ index ][ 0 ] == g_vecZero && iHatSelectedColors[ index ] > 0 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Primero debes elegir los colores del glow de tu hat\n" );
		g_Scheduler.SetTimeout( "CP_Hats", 0.01, index );
		return;
	}
	
	if ( hatEntity[ index ].GetEntity() is null )
	{
		// Creation (first time)
		CBaseEntity@ pEntity = g_EntityFuncs.Create( "info_target", g_vecZero, g_vecZero, false );
		pEntity.pev.movetype = MOVETYPE_FOLLOW;
		@pEntity.pev.aiment = pPlayer.edict();
		
		// Model
		string szModel = "models/hats/" + _HatsNames[ iHat ] + ".mdl";
		g_EntityFuncs.SetModel( pEntity, szModel );
		
		// CP_Think will take care of rendering
		
		hatEntity[ index ] = pEntity;
	}
	else
	{
		CBaseEntity@ pEntity = hatEntity[ index ].GetEntity();
		
		// Model
		string szModel = "models/hats/" + _HatsNames[ iHat ] + ".mdl";
		g_EntityFuncs.SetModel( pEntity, szModel );
		
		// CP_Think will take care of rendering
		
		pEntity.pev.effects &= ~EF_NODRAW;
	}
	
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Hat \"" + _HatsNames[ iHat ] + "\" elegido\n" );
	
	int iCost = 232;
	switch ( iHatSelectedColors[ index ] )
	{
		case 0: iCost += 0; break;
		case 1: iCost += 24; break;
		case 2: iCost += 43; break;
		case 3: iCost += 58; break;
		case 4: iCost += 67; break;
		case 5: iCost += 72; break;
		case 6: iCost += 75; break;
	}
	iCP[ index ] -= GetShopDiscount( index, iCost );
	
	return;
}

void CP_Hats_Remove( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( hatEntity[ index ].GetEntity() !is null )
	{
		CBaseEntity@ pEntity = hatEntity[ index ].GetEntity();
		pEntity.pev.renderfx = kRenderFxNone;
		pEntity.pev.renderamt = 0;
		pEntity.pev.rendercolor = g_vecZero;
		pEntity.pev.effects |= EF_NODRAW;
		
		for ( int i = 0; i < 6; i++ )
		{
			bHatGlow[ index ][ i ] = false;
			vecHatGlowColor[ index ][ i ] = g_vecZero;
		}
		iHatGlowAlternate[ index ] = 1;
		iHatSelectedColors[ index ] = 0;
	}
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Te quitaste el hat\n" );
}

void CP_Hats_Color( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Hats_Color_CB );
	
	string szTitle = "Elegir colores\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _ColorNames.length(); i++ )
	{
		state.menu.AddItem( _ColorNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Hats_Color_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Hats", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iColor = atoi( selection );
	
	if ( !bShouldUpdate[ index ] )
		vecHatGlowColor[ index ][ iHatChoosenColors[ index ] ] = _ColorCodes[ iColor ];
	else
		vecHatGlowUpdate[ index ][ iHatChoosenColors[ index ] ] = _ColorCodes[ iColor ];
	
	iHatChoosenColors[ index ]++;
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color " + iChoosenColors[ index ] + ": " + _ColorNames[ iColor ] + "\n" );
	
	if ( iHatChoosenColors[ index ] == iHatSelectedColors[ index ] )
	{
		bHatGlow[ index ][ 0 ] = false;
		bHatGlow[ index ][ 1 ] = false;
		bHatGlow[ index ][ 2 ] = false;
		bHatGlow[ index ][ 3 ] = false;
		bHatGlow[ index ][ 4 ] = false;
		bHatGlow[ index ][ 5 ] = false;
		
		for( int i = 0; i < iHatSelectedColors[ index ]; i++ )
		{
			bHatGlow[ index ][ i ] = true;
			
			if ( bShouldUpdate[ index ] )
				vecHatGlowColor[ index ][ i ] = vecHatGlowUpdate[ index ][ i ];
		}
		
		bShouldUpdate[ index ] = false;
		
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Colores listos. Ahora puedes elegir un hat\n" );
		g_Scheduler.SetTimeout( "CP_Hats", 0.01, index );
	}
	else
		g_Scheduler.SetTimeout( "CP_Hats_Color", 0.01, index );
	
	return;
}

void CP_Weapons( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( szMapName[ 0 ] == 'f' && szMapName[ 1 ] == 'u' && szMapName[ 2 ] == 'n' )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No puedes comprar armas en este mapa\n" );
		g_Scheduler.SetTimeout( "CPMenu", 0.01, index );
		return;
	}
	
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Weapons_CB );
	state.menu.SetTitle( "Armas\n\nTienes " + AddCommas( iCP[ index ] ) + " C\n\n" );
	
	state.menu.AddItem( "Comunes\n", any( "item1" ) );
	state.menu.AddItem( "Especiales\n\n", any( "item2" ) );
	
	if ( iMaxWeapons[ index ] > 0 )
	{
		if ( iAutoBuy[ index ] > 0 )
		{
			state.menu.AddItem( "Compra automatica de armas? [ SI ]\n", any( "item3" ) );
			
			string szItem4 = "Cantidad de armas: " + iBuyWeapons[ index ] + "\n";
			state.menu.AddItem( szItem4, any( "item4" ) );
		}
		else
			state.menu.AddItem( "Compra automatica de armas? [ NO ]\n", any( "item3" ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Weapons_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( iAutoBuy[ index ] > 0 )
			iWeaponSelected[ index ] = 0;
		
		g_Scheduler.SetTimeout( "CP_Weapons_Default", 0.01, index );
	}
	else if ( selection == 'item2' )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* En este momento, no hay armas especiales a la venta\n" );
		g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
		//g_Scheduler.SetTimeout( "CP_Weapons_Special", 0.01, index );
	}
	else if ( selection == 'item3' )
	{
		if ( iAutoBuy[ index ] == 0 )
			iAutoBuy[ index ] = 1;
		else
		{
			// Reset
			szAutoWeapon[ index ][ 0 ] = "";
			szAutoWeapon[ index ][ 1 ] = "";
			szAutoWeapon[ index ][ 2 ] = "";
			szAutoWeapon[ index ][ 3 ] = "";
			
			iAutoBuy[ index ] = 0;
		}
		
		g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
	}
	else if ( selection == 'item4' )
	{
		iBuyWeapons[ index ]++;
		if ( iBuyWeapons[ index ] > iMaxWeapons[ index ] )
			iBuyWeapons[ index ] = 1;
		
		g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
	}
}


void CP_Weapons_Default( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Weapons_Default_CB );
	
	string szTitle = "Comunes\n\n\nTienes " + AddCommas( iCP[ index ] ) + " C\n\n";
	
	if ( iAutoBuy[ index ] == 0 )
		szTitle += "Puedes comprar la misma arma multiples\nveces para recargar tus balas\n\n";
	
	state.menu.SetTitle( szTitle );
	
	if ( szMapName[ 0 ] == 'h' && szMapName[ 1 ] == 'l' )
	{
		string szItem = "";
		for( int i = 0; i < 4; i++ )
		{
			szItem = _NormalWeaponNames[ i ] + " [ " + GetShopDiscount( index, _NormalWeaponCosts[ i ] ) + " C ]";
			state.menu.AddItem( szItem, any( string( i ) ) );
		}
	}
	else if ( szMapName[ 0 ] == 'c' && szMapName[ 1 ] == 's' )
	{
		string szItem = "";
		for( int i = 4; i < 8; i++ )
		{
			szItem = _NormalWeaponNames[ i ] + " [ " + GetShopDiscount( index, _NormalWeaponCosts[ i ] ) + " C ]";
			state.menu.AddItem( szItem, any( string( i ) ) );
		}
	}
	else if ( szMapName[ 0 ] == 'd' && szMapName[ 1 ] == 'm' && szMapName[ 2 ] == 'c' )
	{
		string szItem = "";
		for( int i = 8; i < 12; i++ )
		{
			szItem = _NormalWeaponNames[ i ] + " [ " + GetShopDiscount( index, _NormalWeaponCosts[ i ] ) + " C ]";
			state.menu.AddItem( szItem, any( string( i ) ) );
		}
	}
	else if ( szMapName[ 0 ] == 'd' && szMapName[ 1 ] == 'o' && szMapName[ 2 ] == 'd' )
	{
		string szItem = "";
		for( int i = 12; i < 16; i++ )
		{
			szItem = _NormalWeaponNames[ i ] + " [ " + GetShopDiscount( index, _NormalWeaponCosts[ i ] ) + " C ]";
			state.menu.AddItem( szItem, any( string( i ) ) );
		}
	}
	
	string szSCItem = "";
	for( int i = 16; i < 20; i++ )
	{
		szSCItem = _NormalWeaponNames[ i ] + " [ " + GetShopDiscount( index, _NormalWeaponCosts[ i ] ) + " C ]";
		state.menu.AddItem( szSCItem, any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Weapons_Default_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iWeapon = atoi( selection );
	int iCost = _NormalWeaponCosts[ iWeapon ];
	
	if ( iAutoBuy[ index ] > 0 )
	{
		iAutoBuy[ index ] = 1;
		
		for ( int i = 0; i < 4; i++ )
		{
			if ( szAutoWeapon[ index ][ i ] == _NormalWeaponClassnames[ iWeapon ] )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Ya has elegido esta arma\n" );
				g_Scheduler.SetTimeout( "CP_Weapons_Default", 0.01, index );
				return;
			}
		}
		
		szAutoWeapon[ index ][ iWeaponSelected[ index ] ] = _NormalWeaponClassnames[ iWeapon ];
		iWeaponSelected[ index ]++;
		
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Arma " + iWeaponSelected[ index ] + ": " + _NormalWeaponNames[ iWeapon ] + "\n" );
		
		if ( iWeaponSelected[ index ] == iBuyWeapons[ index ] )
			g_Scheduler.SetTimeout( "CP_AutoBuy_Confirm", 0.01, index );
		else
			g_Scheduler.SetTimeout( "CP_Weapons_Default", 0.01, index );
	}
	else
	{
		if ( iWeaponCooldown[ index ] > 0 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Debes esperar " + iWeaponCooldown[ index ] + " segundo(s) antes de poder comprar otra arma\n" );
			g_Scheduler.SetTimeout( "CP_Weapons_Default", 0.01, index );
			return;
		}
		
		if ( iCP[ index ] >= GetShopDiscount( index, iCost ) )
		{
			iCP[ index ] -= GetShopDiscount( index, iCost );
			pPlayer.GiveNamedItem( _NormalWeaponClassnames[ iWeapon ] );
			iWeaponCooldown[ index ] = 45;
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes\n" );
		
		g_Scheduler.SetTimeout( "CP_Weapons_Default", 0.01, index );
	}
	
	return;
}

void CP_AutoBuy_Confirm( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_AutoBuy_Confirm_CB );
	
	string szTitle = "Auto-Compra de armas\n\n";
	
	iAutoCost[ index ] = 0;
	for ( int i = 0; i < iBuyWeapons[ index ]; i++ )
	{
		int iClassname = _NormalWeaponClassnames.find( szAutoWeapon[ index ][ i ] );
		string szWeaponName = _NormalWeaponNames[ iClassname ];
		int iCost = GetShopDiscount( index, _NormalWeaponCosts[ iClassname ] );
		
		szTitle += "Arma " + ( i + 1 ) + ": " + szWeaponName + " [ " + iCost + " C ]\n\n";
		
		iAutoCost[ index ] += iCost;
	}
	
	szTitle += "Tienes: " + AddCommas( iCP[ index ] ) + " C\n";
	szTitle += "Costo por cada spawn: " + AddCommas( iAutoCost[ index ] ) + " C\n\n";
	
	int iTotalTimes = iCP[ index ] / iAutoCost[ index ];
	szTitle += "Esto alcanza para comprar las armas\nelegidas un total de " + iTotalTimes + ( iTotalTimes == 1 ? " vez" : " veces" ) + "\n\n";
	
	szTitle += "Activar compra automatica de armas?\n";
	
	state.menu.SetTitle( szTitle );
	
	state.menu.AddItem( "Si\n", any( "item1" ) );
	state.menu.AddItem( "No", any( "item2" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_AutoBuy_Confirm_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( iCP[ index ] >= iAutoCost[ index ] )
		{
			iAutoBuy[ index ] == 2;
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Compra automatica de armas activada\n" );
		}
		else
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes\n" );
			g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
		}
	}
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Weapons", 0.01, index );
}

void CP_Other( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Other_CB );
	state.menu.SetTitle( "Otros\n\nTienes: " + AddCommas( iCP[ index ] ) + " C\n\n" );
	
	if ( iLevel[ index ] < 69 )
		state.menu.AddItem( "<vacio>\n", any( "item99" ) );
	
	if ( iLevel[ index ] >= 69 && !bHasCosmeticPack[ index ] )
		state.menu.AddItem( "Paquete Cosmetico [ " + AddCommas( GetShopDiscount( index, 20000 ) ) + " C ]\n", any( "item1" ) );
	if ( iLevel[ index ] >= 70 )
		state.menu.AddItem( "Vision Nocturna [ " + GetShopDiscount( index, 160 ) + " C ]\n", any( "item2" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Other_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( iCP[ index ] >= GetShopDiscount( index, 20000 ) )
		{
			iCP[ index ] -= GetShopDiscount( index, 20000 );
			bHasCosmeticPack[ index ] = true;
			
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Compraste un Paquete Cosmetico. Configuralo desde el Menu Principal\n" );
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes\n" );
		
		g_Scheduler.SetTimeout( "CP_Other", 0.01, index );
	}
	else if ( selection == 'item2' )
	{
		if ( iCP[ index ] >= GetShopDiscount( index, 160 ) )
		{
			if ( !bHasNightvision[ index ] )
			{
				iCP[ index ] -= GetShopDiscount( index, 160 );
				bHasNightvision[ index ] = true;
				
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Compraste Vision Nocturna. Activala/Desactivala con el comando /nv\n" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Si mueres, deberas volver a comprar la Vision Nocturna\n" );
			}
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Ya tienes Vision Nocturna\n" );
		}
		else
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Creditos insuficientes\n" );
		
		g_Scheduler.SetTimeout( "CP_Other", 0.01, index );
	}
	else if ( selection == 'item99' )
		g_Scheduler.SetTimeout( "CP_Other", 0.01, index );
}

void CP_Pack_Main( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Main_CB );
	state.menu.SetTitle( "Paquete Cosmetico\n\nActivar o Desactivar con el comando /cp\n\n" );
	
	state.menu.AddItem( "Configurar Glow\n", any( "item1" ) );
	state.menu.AddItem( "Configurar Trail\n", any( "item2" ) );
	state.menu.AddItem( "Configurar Hat\n", any( "item3" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Main_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
		g_Scheduler.SetTimeout( "CP_Pack_Glow", 0.01, index );
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
	else if ( selection == 'item3' )
		g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
}

void CP_Pack_Glow( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Glow_CB );
	state.menu.SetTitle( "Configurar Glow\n\n" );
	
	string szItem1 = "Usar Glow? ";
	if ( iCPGlowColors[ index ] > 0 ) szItem1 += "[ SI ]\n\n";
	else szItem1 += "[ NO ]\n\n";
	state.menu.AddItem( szItem1, any( "item1" ) );
	
	if ( iCPGlowColors[ index ] > 0 )
	{
		string szItem2 = "Cantidad de colores: " + iCPGlowColors[ index ] + "\n\n";
		state.menu.AddItem( szItem2, any( "item2" ) );
		
		// Attempt to extract color names
		array< string > szSelectedColor( 6 );
		for ( int i = 0; i < 6; i++ )
		{
			for ( uint j = 0; j < _ColorCodes.length(); j++ )
			{
				// Default
				if ( vecCPGlowColor[ index ][ i ].x == _ColorCodes[ j ].x && vecCPGlowColor[ index ][ i ].y == _ColorCodes[ j ].y && vecCPGlowColor[ index ][ i ].z == _ColorCodes[ j ].z )
				{
					szSelectedColor[ i ] = _ColorNames[ j ];
					break;
				}
				else
					szSelectedColor[ i ] = "";
			}
		}
		
		string szColor1 = "Color 1: " + szSelectedColor[ 0 ] + "\n";
		state.menu.AddItem( szColor1, any( "item3" ) );
	
		if ( iCPGlowColors[ index ] >= 2 )
		{
			string szColor2 = "Color 2: " + szSelectedColor[ 1 ] + "\n";
			state.menu.AddItem( szColor2, any( "item4" ) );
		}
		if ( iCPGlowColors[ index ] >= 3 )
		{
			string szColor3 = "Color 3: " + szSelectedColor[ 2 ] + "\n";
			state.menu.AddItem( szColor3, any( "item5" ) );
		}
		if ( iCPGlowColors[ index ] >= 4 )
		{
			string szColor4 = "Color 4: " + szSelectedColor[ 3 ] + "\n";
			state.menu.AddItem( szColor4, any( "item6" ) );
		}
		if ( iCPGlowColors[ index ] >= 5 )
		{
			string szColor5 = "Color 5: " + szSelectedColor[ 4 ] + "\n";
			state.menu.AddItem( szColor5, any( "item7" ) );
		}
		if ( iCPGlowColors[ index ] == 6 )
		{
			string szColor6 = "Color 6: " + szSelectedColor[ 5 ] + "\n";
			state.menu.AddItem( szColor6, any( "item8" ) );
		}
	}
	
	state.menu.AddItem( "Guardar configuracion", any( "item9" ) );
	
	iCPAux[ index ] = 0;
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Glow_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( iCPGlowColors[ index ] > 0 )
			iCPGlowColors[ index ] = 0;
		else
			iCPGlowColors[ index ] = 1;
		
		g_Scheduler.SetTimeout( "CP_Pack_Glow", 0.01, index );
	}
	else if ( selection == 'item2' )
	{
		iCPGlowColors[ index ]++;
		if ( iCPGlowColors[ index ] > 6 )
			iCPGlowColors[ index ] = 1;
		
		g_Scheduler.SetTimeout( "CP_Pack_Glow", 0.01, index );
	}
	else if ( selection == 'item3' )
	{
		iCPAux[ index ] = 1;
		g_Scheduler.SetTimeout( "CP_Pack_Glow_Edit", 0.01, index );
	}
	else if ( selection == 'item4' )
	{
		iCPAux[ index ] = 2;
		g_Scheduler.SetTimeout( "CP_Pack_Glow_Edit", 0.01, index );
	}
	else if ( selection == 'item5' )
	{
		iCPAux[ index ] = 3;
		g_Scheduler.SetTimeout( "CP_Pack_Glow_Edit", 0.01, index );
	}
	else if ( selection == 'item6' )
	{
		iCPAux[ index ] = 4;
		g_Scheduler.SetTimeout( "CP_Pack_Glow_Edit", 0.01, index );
	}
	else if ( selection == 'item7' )
	{
		iCPAux[ index ] = 5;
		g_Scheduler.SetTimeout( "CP_Pack_Glow_Edit", 0.01, index );
	}
	else if ( selection == 'item8' )
	{
		iCPAux[ index ] = 6;
		g_Scheduler.SetTimeout( "CP_Pack_Glow_Edit", 0.01, index );
	}
	else if ( selection == 'item9' )
	{
		if ( iCPGlowColors[ index ] > 0 )
		{
			for( int i = 0; i < iCPGlowColors[ index ]; i++ )
			{
				if ( vecCPGlowColor[ index ][ i ] == g_vecZero )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Aun quedan colores por elegir\n" );
					g_Scheduler.SetTimeout( "CP_Pack_Glow", 0.01, index );
					return;
				}
			}
		}
		
		// Server might crash before map end, causing the configuration data to be lost. Save now
		XP_SaveData( index );
		
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Configuracion guardada\n" );
		g_Scheduler.SetTimeout( "CP_Pack_Main", 0.01, index );
	}
}

void CP_Pack_Glow_Edit( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Glow_Edit_CB );
	
	string szTitle = "Elige color\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _ColorNames.length(); i++ )
	{
		state.menu.AddItem( _ColorNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Glow_Edit_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Pack_Glow", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iColor = atoi( selection );
	
	vecCPGlowColor[ index ][ iCPAux[ index ] - 1 ] = _ColorCodes[ iColor ];
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color " + iCPAux[ index ] + ": " + _ColorNames[ iColor ] + "\n" );
	
	g_Scheduler.SetTimeout( "CP_Pack_Glow", 0.01, index );
}

void CP_Pack_Trail( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Trail_CB );
	state.menu.SetTitle( "Configurar Trail\n\n" );
	
	string szItem1 = "Usar Trail? ";
	if ( bCPTrail[ index ] ) szItem1 += "[ SI ]\n\n";
	else szItem1 += "[ NO ]\n\n";
	state.menu.AddItem( szItem1, any( "item1" ) );
	
	if ( bCPTrail[ index ] )
	{
		// Attempt to extract color name
		string szSelectedColor = "";
		for ( uint j = 0; j < _ColorCodes.length(); j++ )
		{
			// Default
			if ( vecCPTrailColor[ index ].x == _ColorCodes[ j ].x && vecCPTrailColor[ index ].y == _ColorCodes[ j ].y && vecCPTrailColor[ index ].z == _ColorCodes[ j ].z )
			{
				szSelectedColor = _ColorNames[ j ];
				break;
			}
		}
		
		string szColor = "Color de trail: " + szSelectedColor + "\n";
		state.menu.AddItem( szColor, any( "item2" ) );
		
		string szItem3 = "Longitud del trail: ";
		switch ( iCPTrailLong[ index ] )
		{
			case 10: szItem3 += "Pequenia\n"; break;
			case 20: szItem3 += "Mediana\n"; break;
			case 30: szItem3 += "Grande\n"; break;
			case 40: szItem3 += "Muy grande\n"; break;
			case 50: szItem3 += "Excesiva\n"; break;
		}
		state.menu.AddItem( szItem3, any( "item3" ) );
		
		string szItem4 = "Anchura del trail: ";
		switch ( iCPTrailSize[ index ] )
		{
			case 4: szItem4 += "Pequenia\n"; break;
			case 8: szItem4 += "Mediana\n"; break;
			case 12: szItem4 += "Grande\n"; break;
			case 16: szItem4 += "Muy grande\n"; break;
			case 20: szItem4 += "Excesiva\n"; break;
		}
		state.menu.AddItem( szItem4, any( "item4" ) );
		
		string szItem5 = "Trail de Tipo ";
		switch ( iCPTrailSprite[ index ] )
		{
			case 0: szItem5 += "A"; break;
			case 1: szItem5 += "B"; break;
			case 2: szItem5 += "C"; break;
			case 3: szItem5 += "D"; break;
			case 4: szItem5 += "E"; break;
			case 5: szItem5 += "F"; break;
			case 6: szItem5 += "G"; break;
			case 7: szItem5 += "H"; break;
			case 8: szItem5 += "I"; break;
			case 9: szItem5 += "J"; break;
			case 10: szItem5 += "K"; break;
			case 11: szItem5 += "L"; break;
			case 12: szItem5 += "M"; break;
			case 13: szItem5 += "N"; break;
			case 14: szItem5 += "O"; break;
			case 15: szItem5 += "P"; break;
			case 16: szItem5 += "Q"; break;
			case 17: szItem5 += "R"; break;
			case 18: szItem5 += "S"; break;
		}
		state.menu.AddItem( szItem5, any( "item5" ) );
	}
	
	state.menu.AddItem( "Guardar configuracion", any( "item6" ) );
	
	iCPAux[ index ] = 0;
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Trail_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( !bCPTrail[ index ] )
			bCPTrail[ index ] = true;
		else
			bCPTrail[ index ] = false;
		
		g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
	}
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Pack_Trail_Color", 0.01, index );
	else if ( selection == 'item3' )
	{
		iCPTrailLong[ index ] += 10;
		if ( iCPTrailLong[ index ] > 50 )
			iCPTrailLong[ index ] = 10;
		
		g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
	}
	else if ( selection == 'item4' )
	{
		iCPTrailSize[ index ] += 4;
		if ( iCPTrailSize[ index ] > 20 )
			iCPTrailSize[ index ] = 4;
		
		g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
	}
	else if ( selection == 'item5' )
	{
		iCPTrailSprite[ index ]++;
		if ( iCPTrailSprite[ index ] > 18 )
			iCPTrailSprite[ index ] = 0;
		
		g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
	}
	else if ( selection == 'item6' )
	{
		if ( bCPTrail[ index ] )
		{
			if ( vecCPTrailColor[ index ] == g_vecZero )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Elige el color de tu Trail\n" );
				g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
				return;
			}
		}
		
		// Server might crash before map end, causing the configuration data to be lost. Save now
		XP_SaveData( index );
		
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Configuracion guardada\n" );
		g_Scheduler.SetTimeout( "CP_Pack_Main", 0.01, index );
	}
}

void CP_Pack_Trail_Color( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Trail_Color_CB );
	
	string szTitle = "Elige color\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _ColorNames.length(); i++ )
	{
		state.menu.AddItem( _ColorNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Trail_Color_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iColor = atoi( selection );
	
	vecCPTrailColor[ index ] = _ColorCodes[ iColor ];
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color de trail: " + _ColorNames[ iColor ] + "\n" );
	
	g_Scheduler.SetTimeout( "CP_Pack_Trail", 0.01, index );
}

void CP_Pack_Hat( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Hat_CB );
	state.menu.SetTitle( "Configurar Hat\n\n" );
	
	string szItem1 = "Usar Hat? ";
	if ( szCPHatName[ index ].Length() > 0 ) szItem1 += "[ SI ]\n\n";
	else szItem1 += "[ NO ]\n\n";
	state.menu.AddItem( szItem1, any( "item1" ) );
	
	if ( szCPHatName[ index ].Length() > 0 )
	{
		string szItem2 = "Hat: " + szCPHatName[ index ] + "\n";
		state.menu.AddItem( szItem2, any( "item2" ) );
		
		string szItem3 = "Hat Glow: ";
		if ( iCPHatGlowColors[ index ] == 0 )
			szItem3 += "[ NO ]";
		else if ( iCPHatGlowColors[ index ] == 1 )
			szItem3 += "1 color\n";
		else
			szItem3 += "" + iCPHatGlowColors[ index ] + " colores\n";
		state.menu.AddItem( szItem3, any( "item3" ) );
		
		// Attempt to extract color names
		array< string > szSelectedColor( 6 );
		for ( int i = 0; i < 6; i++ )
		{
			for ( uint j = 0; j < _ColorCodes.length(); j++ )
			{
				// Default
				if ( vecCPHatGlowColor[ index ][ i ].x == _ColorCodes[ j ].x && vecCPHatGlowColor[ index ][ i ].y == _ColorCodes[ j ].y && vecCPHatGlowColor[ index ][ i ].z == _ColorCodes[ j ].z )
				{
					szSelectedColor[ i ] = _ColorNames[ j ];
					break;
				}
				else
					szSelectedColor[ i ] = "";
			}
		}
		
		if ( iCPHatGlowColors[ index ] >= 1 )
		{
			string szColor2 = "Color 1: " + szSelectedColor[ 0 ] + "\n";
			state.menu.AddItem( szColor2, any( "item4" ) );
		}
		if ( iCPHatGlowColors[ index ] >= 2 )
		{
			string szColor2 = "Color 2: " + szSelectedColor[ 1 ] + "\n";
			state.menu.AddItem( szColor2, any( "item5" ) );
		}
		if ( iCPHatGlowColors[ index ] >= 3 )
		{
			string szColor3 = "Color 3: " + szSelectedColor[ 2 ] + "\n";
			state.menu.AddItem( szColor3, any( "item6" ) );
		}
		if ( iCPHatGlowColors[ index ] >= 4 )
		{
			string szColor4 = "Color 4: " + szSelectedColor[ 3 ] + "\n";
			state.menu.AddItem( szColor4, any( "item7" ) );
		}
		if ( iCPHatGlowColors[ index ] >= 5 )
		{
			string szColor5 = "Color 5: " + szSelectedColor[ 4 ] + "\n";
			state.menu.AddItem( szColor5, any( "item8" ) );
		}
		if ( iCPHatGlowColors[ index ] == 6 )
		{
			string szColor6 = "Color 6: " + szSelectedColor[ 5 ] + "\n";
			state.menu.AddItem( szColor6, any( "item9" ) );
		}
	}
	
	state.menu.AddItem( "Guardar configuracion", any( "item10" ) );
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Hat_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 ) return;
	
	string selection;
	item.m_pUserData.retrieve( selection );
	if ( selection == 'item1' )
	{
		if ( szCPHatName[ index ].Length() > 0 )
			szCPHatName[ index ] = "";
		else
			szCPHatName[ index ] = _HatsNames[ 0 ]; // Dummy
		
		g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
	}
	else if ( selection == 'item2' )
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Select", 0.01, index );
	else if ( selection == 'item3' )
	{
		iCPHatGlowColors[ index ]++;
		if ( iCPHatGlowColors[ index ] > 6 )
			iCPHatGlowColors[ index ] = 0;
		
		g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
	}
	else if ( selection == 'item4' )
	{
		iCPAux[ index ] = 1;
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Glow", 0.01, index );
	}
	else if ( selection == 'item5' )
	{
		iCPAux[ index ] = 2;
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Glow", 0.01, index );
	}
	else if ( selection == 'item6' )
	{
		iCPAux[ index ] = 3;
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Glow", 0.01, index );
	}
	else if ( selection == 'item7' )
	{
		iCPAux[ index ] = 4;
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Glow", 0.01, index );
	}
	else if ( selection == 'item8' )
	{
		iCPAux[ index ] = 5;
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Glow", 0.01, index );
	}
	else if ( selection == 'item9' )
	{
		iCPAux[ index ] = 6;
		g_Scheduler.SetTimeout( "CP_Pack_Hat_Glow", 0.01, index );
	}
	else if ( selection == 'item10' )
	{
		if ( iCPHatGlowColors[ index ] > 0 )
		{
			for( int i = 0; i < iCPHatGlowColors[ index ]; i++ )
			{
				if ( vecCPHatGlowColor[ index ][ i ] == g_vecZero )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Aun quedan colores por elegir\n" );
					g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
					return;
				}
			}
		}
		
		// Server might crash before map end, causing the configuration data to be lost. Save now
		XP_SaveData( index );
		
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Configuracion guardada\n" );
		g_Scheduler.SetTimeout( "CP_Pack_Main", 0.01, index );
	}
}

void CP_Pack_Hat_Select( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Hat_Select_CB );
	
	string szTitle = "Elegir hat\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _HatsNames.length(); i++ )
	{
		state.menu.AddItem( _HatsNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Hat_Select_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iHat = atoi( selection );
	
	szCPHatName[ index ] = _HatsNames[ iHat ];
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Hat \"" + _HatsNames[ iHat ] + "\" elegido\n" );
	
	g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
}

void CP_Pack_Hat_Glow( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	MenuHandler@ state = MenuGetPlayer( pPlayer );
	
	state.InitMenu( pPlayer, CP_Pack_Hat_Glow_CB );
	
	string szTitle = "Elegir color\n\n";
	
	state.menu.SetTitle( szTitle );
	
	for( uint i = 0; i < _ColorNames.length(); i++ )
	{
		state.menu.AddItem( _ColorNames[ i ], any( string( i ) ) );
	}
	
	state.OpenMenu( pPlayer, 0, 0 );
}

void CP_Pack_Hat_Glow_CB( CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item )
{
	int index = pPlayer.entindex();
	if ( page == 10 )
	{
		g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
		return;
	}
	
	string selection;
	item.m_pUserData.retrieve( selection );
	int iColor = atoi( selection );
	
	vecCPHatGlowColor[ index ][ iCPAux[ index ] - 1 ] = _ColorCodes[ iColor ];
	g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Color " + iCPAux[ index ] + ": " + _ColorNames[ iColor ] + "\n" );
	
	g_Scheduler.SetTimeout( "CP_Pack_Hat", 0.01, index );
}

void CP_Pack_Toggle( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	// Turn off EVERYTHING first
	
	// Glow
	for ( int i = 0; i < 6; i++ )
	{
		bGlow[ index ][ i ] = false;
		vecGlowColor[ index ][ i ] = g_vecZero;
	}
	iGlowAlternate[ index ] = 1;
	
	pPlayer.pev.renderfx = 0;
	pPlayer.pev.renderamt = 0;
	pPlayer.pev.rendercolor = g_vecZero;
	
	// Trail
	bTrail[ index ] = false;
	vecTrailColor[ index ] = g_vecZero;
	
	// Hat
	if ( hatEntity[ index ].GetEntity() !is null )
	{
		CBaseEntity@ pEntity = hatEntity[ index ].GetEntity();
		pEntity.pev.renderfx = kRenderFxNone;
		pEntity.pev.renderamt = 0;
		pEntity.pev.rendercolor = g_vecZero;
		pEntity.pev.effects |= EF_NODRAW;
		
		for ( int i = 0; i < 6; i++ )
		{
			bHatGlow[ index ][ i ] = false;
			vecHatGlowColor[ index ][ i ] = g_vecZero;
		}
		iHatGlowAlternate[ index ] = 1;
		iHatSelectedColors[ index ] = 0;
	}
	
	if ( !bIsCPActive[ index ] )
	{
		// Glow
		if ( iCPGlowColors[ index ] > 0 )
		{
			for( int i = 0; i < iCPGlowColors[ index ]; i++ )
			{
				bGlow[ index ][ i ] = true;
				vecGlowColor[ index ][ i ] = vecCPGlowColor[ index ][ i ];
			}
		}
		
		// Trail
		if ( bCPTrail[ index ] )
		{
			bTrail[ index ] = true;
			
			vecTrailColor[ index ] = vecCPTrailColor[ index ];
			iTrailSprite[ index ] = iCPTrailSprite[ index ];
			iTrailLong[ index ] = iCPTrailLong[ index ];
			iTrailSize[ index ] = iCPTrailSize[ index ];
		}
		
		// Hat
		if ( szCPHatName[ index ].Length() > 0 )
		{
			if ( iCPHatGlowColors[ index ] > 0 )
			{
				for( int i = 0; i < iCPHatGlowColors[ index ]; i++ )
				{
					bHatGlow[ index ][ i ] = true;
					vecHatGlowColor[ index ][ i ] = vecCPHatGlowColor[ index ][ i ];
				}
			}
			
			if ( hatEntity[ index ].GetEntity() is null )
			{
				// Creation (first time)
				CBaseEntity@ pEntity = g_EntityFuncs.Create( "info_target", g_vecZero, g_vecZero, false );
				pEntity.pev.movetype = MOVETYPE_FOLLOW;
				@pEntity.pev.aiment = pPlayer.edict();
				
				// Model
				string szModel = "models/hats/" + szCPHatName[ index ] + ".mdl";
				g_EntityFuncs.SetModel( pEntity, szModel );
				
				// CP_Think will take care of rendering
				
				hatEntity[ index ] = pEntity;
			}
			else
			{
				CBaseEntity@ pEntity = hatEntity[ index ].GetEntity();
				
				// Model
				string szModel = "models/hats/" + szCPHatName[ index ] + ".mdl";
				g_EntityFuncs.SetModel( pEntity, szModel );
				
				// CP_Think will take care of rendering
				
				pEntity.pev.effects &= ~EF_NODRAW;
			}
		}
		
		bIsCPActive[ index ] = true;
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Paquete Cosmetico activado\n" );
	}
	else
	{
		bIsCPActive[ index ] = false;
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Paquete Cosmetico desactivado\n" );
	}
}

void NV_Think( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
	{
		if ( bHasNightvision[ index ] && bIsNightvisionOn[ index ] )
		{
			// This constant ScreenFade should be not needed, but any other env_fade might overwrite the nightvision one
			g_PlayerFuncs.ScreenFade( pPlayer, Vector( 0, 250, 0 ), 0.0, 0.20, 64, ( FFADE_IN | FFADE_STAYOUT ) );
			
			// Attempt to locate player "eye" position
			Vector vecPosition = pPlayer.EyePosition();
			
			// Emit light
			NetworkMessage nvMsg( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, vecPosition, pPlayer.edict() );
			nvMsg.WriteByte( TE_DLIGHT );
			nvMsg.WriteCoord( vecPosition.x );
			nvMsg.WriteCoord( vecPosition.y );
			nvMsg.WriteCoord( vecPosition.z );
			nvMsg.WriteByte( 64 ); // Brightness/Radius
			nvMsg.WriteByte( 250 );
			nvMsg.WriteByte( 250 );
			nvMsg.WriteByte( 250 );
			nvMsg.WriteByte( 2 ); // Duration
			nvMsg.WriteByte( 1 ); // Decay Rate
			nvMsg.End();
			
			g_Scheduler.SetTimeout( "NV_Think", 0.1, index );
		}
	}
}

int GetShopDiscount( const int& in index, const int& in iCost )
{
	return int( float( iCost ) * ( 100.0 - float( iShopDiscount[ index ] ) ) / 100.0 );
}

/* Add commas to integers */
string AddCommas( int& in iNum )
{
	string szOutput;
	string szTmp;
	uint iOutputPos = 0;
	uint iNumPos = 0;
	uint iNumLen;
	
	szTmp = string( iNum );
	iNumLen = szTmp.Length();
	
	if ( iNumLen <= 3 )
	{
		szOutput = szTmp;
	}
	else
	{
		szOutput = "????????????";
		while ( ( iNumPos < iNumLen ) ) 
		{
			szOutput.SetCharAt( iOutputPos++, char( szTmp[ iNumPos++ ] ) );
			
			if( ( iNumLen - iNumPos ) != 0 && !( ( ( iNumLen - iNumPos ) % 3 ) != 0 ) ) 
				szOutput.SetCharAt( iOutputPos++, char( "," ) );
		}
		szOutput.Replace( "?", "" );
	}
	
	return szOutput;
}

/* Shows a MOTD message to the player */
void ShowMOTD( CBasePlayer@ pPlayer, const string& in szTitle, const string& in szMessage )
{
	if ( pPlayer is null )
		return;
	
	NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
	title.WriteString( szTitle );
	title.End();
	
	uint iChars = 0;
	string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
	
	for ( uint uChars = 0; uChars < szMessage.Length(); uChars++ )
	{
		szSplitMsg.SetCharAt( iChars, char( szMessage[ uChars ] ) );
		iChars++;
		if ( iChars == 32 )
		{
			NetworkMessage message( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
			message.WriteByte( 0 );
			message.WriteString( szSplitMsg );
			message.End();
			
			iChars = 0;
		}
	}
	
	// If we reached the end, send the last letters of the message
	if ( iChars > 0 )
	{
		szSplitMsg.Truncate( iChars );
		
		NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
		fix.WriteByte( 0 );
		fix.WriteString( szSplitMsg );
		fix.End();
	}
	
	NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
	endMOTD.WriteByte( 1 );
	endMOTD.WriteString( "\n" );
	endMOTD.End();
	
	NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
	restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
	restore.End();
}

/* Converts a float value to a string, with a maximum of 2 decimals */
string fl2Decimals( const float& in value )
{
	// Convert float to string
	string original = "" + value;
	
	// Split string using decimal point
	array< string >@ pre_convert = original.Split( '.' );
	
	string decimals = "";
	
	// Check if our value has any decimal places
	if ( pre_convert.length() > 1 )
	{
		// It has at least one. Use it
		decimals += pre_convert[ 1 ][ 0 ];
		
		// Does it have a second decimal?
		if ( isdigit( pre_convert[ 1 ][ 1 ] ) )
		{
			// Yep, add it
			decimals += pre_convert[ 1 ][ 1 ];
		}
		else
		{
			// Does not. Add a zero manually
			decimals += "0";
		}
	}
	else
	{
		// No decimals, add zeros manually
		decimals += "00";
	}
	
	// Copy integer part
	string number = "" + pre_convert[ 0 ];
	
	// Now, build the full string
	string convert = "" + number + "." + decimals;
	
	return convert;
}

/* Returns the day specified, in spanish language */
string GetSpanishDate( DateTime& in dtTime )
{
	int year = dtTime.GetYear();
	int month = dtTime.GetMonth();
	int day = dtTime.GetDayOfMonth();
	
	string szMonth;
	switch( month )
	{
		case 1: szMonth = "Enero"; break;
		case 2: szMonth = "Febrero"; break;
		case 3: szMonth = "Marzo"; break;
		case 4: szMonth = "Abril"; break;
		case 5: szMonth = "Mayo"; break;
		case 6: szMonth = "Junio"; break;
		case 7: szMonth = "Julio"; break;
		case 8: szMonth = "Agosto"; break;
		case 9: szMonth = "Septiembre"; break;
		case 10: szMonth = "Octubre"; break;
		case 11: szMonth = "Noviembre"; break;
		case 12: szMonth = "Diciembre"; break;
	}
	
	return "" + day + " de " + szMonth + " de " + year;
}

/* Helper function to find a player by name without being "exact" */
CBasePlayer@ FindPlayer( const string& in szName, bool& out bMultiple = false )
{
	CBasePlayer@ pTarget = null;
	int iTargets = 0;
	
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( iPlayer !is null && iPlayer.IsConnected() )
		{
			string szCheck = iPlayer.pev.netname;
			uint iCheck = szCheck.Find( szName, 0, String::CaseInsensitive );
			if ( iCheck == 0 )
			{
				iTargets++;
				@pTarget = iPlayer;
			}
		}
	}
	
	if ( iTargets == 1 )
		return pTarget;
	else if ( iTargets >= 2 )
		bMultiple = true;
	
	return null;
}

/* Whenever this map should consider the grenade entities as a CS Grenade */
bool IsCSGrenadeMap( const string& in szMapName )
{
	if ( szMapName == 'fun_big_city' )
		return true;
	else if ( szMapName == 'fun_big_city2' )
		return true;
	else if ( szMapName == 'aim_city_cz' )
		return true;
	else if ( szMapName == 'aim_glock_map' )
		return true;
	else if ( szMapName == 'fun_glass' )
		return true;
	else if ( szMapName == 'fun_supercrazycar2' )
		return true;
	
	return false;
}

/* Whenever this map should consider the grenade entities as a SC Grenade */
bool IsSCGrenadeMap( const string& in szMapName )
{
	if ( szMapName == 'fun_darkmines' )
		return true;
	
	return false;
}
