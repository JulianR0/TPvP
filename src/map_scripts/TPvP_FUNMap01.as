// Style 01 of 99 allowed (fun_hide_n_seek)

#include "UTIL_GetDefaultShellInfo"

#include "hl_weapons/weapon_hlcrowbar"
#include "hl_weapons/weapon_hl357"
#include "hl_weapons/weapon_hlcrossbow"

#include "cs16/Util"
#include "cs16/weapon_m4a1"
#include "cs16/weapon_usp"
#include "cs16/weapon_tmp"
#include "cs16/weapon_scout"

bool bGameStart;
bool bRoundStart;
bool bShouldShuffleTeams;
int iAliveSpirals;
int iAliveCrimsons;
int iRoundTime;
int iRoundNumber;
int iSpiralWins;
int iCrimsonWins;

CScheduledFunction@ gDrawTask = null;

void MapInit()
{
	RegisterHLCrowbar();
	RegisterHL357();
	RegisterHLCrossbow();
	
	RegisterAmmo556NatoBox();
	RegisterUSPAmmoBox();
	
	RegisterTMP();
	RegisterUSP();
	RegisterSCOUT();
	RegisterM4A1();
	
	bGameStart = false;
	bRoundStart = false;
	bShouldShuffleTeams = false;
	iAliveSpirals = 0;
	iAliveCrimsons = 0;
	iRoundTime = 0;
	iRoundNumber = 0;
	iSpiralWins = 0;
	iCrimsonWins = 0;
	
	// Start game after 50 seconds of map start
	g_Scheduler.SetTimeout( "StartGame", 1.0, 50 );
	
	g_Scheduler.SetInterval( "RoundCheck", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
	if ( g_Engine.mapname == 'fun_hide_n_seek2' ) g_Scheduler.SetTimeout( "FixLightning", 1.0 );
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
}

void FixLightning()
{
	g_EngineFuncs.LightStyle( 0, "g" );
}

void StartGame( int iWarmUp )
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return;
	
	iWarmUp--;
	if ( iWarmUp < 0 )
	{
		bGameStart = true;
		bShouldShuffleTeams = true;
		iRoundTime = 20;
		iRoundNumber++;
		CallSpawnOnLiving();
		g_Scheduler.SetTimeout( "CallRespawn", 0.05 );
		g_Scheduler.SetTimeout( "NewTeams", 0.10 );
		DeadChatOFF();
		TeamsOFF();
		FootstepsOFF();
		return;
	}
	
	HUDTextParams warmup;
	warmup.x = -1;
	warmup.y = 0.85;
	warmup.effect = 0;
	warmup.r1 = 0;
	warmup.g1 = 128;
	warmup.b1 = 255;
	warmup.a1 = 250;
	warmup.r2 = 0;
	warmup.g2 = 128;
	warmup.b2 = 255;
	warmup.a2 = 250;
	warmup.fadeinTime = 0.0;
	warmup.fadeoutTime = 0.0;
	warmup.holdTime = 255.0;
	warmup.fxTime = 0.0;
	warmup.channel = 2;
	
	if ( g_PlayerFuncs.GetNumPlayers() < 2 )
	{
		iWarmUp = 50;
		g_PlayerFuncs.HudMessageAll( warmup, "No hay suficientes jugadores para comenzar la partida\n" );
	}
	else
		g_PlayerFuncs.HudMessageAll( warmup, "La partida comienza en " + iWarmUp + " segundos\n" );
	
	g_Scheduler.SetTimeout( "StartGame", 1.0, iWarmUp );
}

void SpawnOFF()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "info_player_deathmatch" ) ) !is null )
	{
		ent.Use( null, null, USE_OFF, 0.0 );
	}
}

void SpawnON()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "info_player_deathmatch" ) ) !is null )
	{
		ent.Use( null, null, USE_ON, 0.0 );
	}
}

void CheatON( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( pPlayer !is null )
	{
		pPlayer.pev.effects |= EF_NODRAW;
		pPlayer.pev.flags |= FL_GODMODE;
		pPlayer.pev.solid = SOLID_NOT;
	}
}

void CheatOFF()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		ent.pev.effects &= ~EF_NODRAW;
		ent.pev.flags &= ~FL_GODMODE;
		ent.pev.solid = SOLID_SLIDEBOX;
	}
}

void FootstepsOFF()
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue( "$i_disable_footsteps", 1 );
}

void FootstepsON()
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue( "$i_disable_footsteps", 0 );
}

void DeadChatOFF()
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue( "$i_disable_deadchat", 1 );
}

void TeamsOFF()
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
	
	pCustom.SetKeyvalue( "$i_disable_teambalance", 1 );
	pCustom.SetKeyvalue( "$i_disable_boosting", 1 );
}

void NewTeams()
{
	// Should we?
	if ( !bShouldShuffleTeams )
	{
		// No, check if we should shuffle on the next round
		if ( iRoundNumber > 10 && iSpiralWins != iCrimsonWins )
		{
			HUDTextParams notice;
			notice.x = -1;
			notice.y = 0.45;
			notice.effect = 0;
			notice.r1 = 200;
			notice.g1 = 200;
			notice.b1 = 0;
			notice.a1 = 0;
			notice.r2 = 200;
			notice.g2 = 200;
			notice.b2 = 0;
			notice.a2 = 0;
			notice.fadeinTime = 1.0;
			notice.fadeoutTime = 1.0;
			notice.holdTime = 5.0;
			notice.fxTime = 0.0;
			notice.channel = 4;
			
			g_PlayerFuncs.HudMessageAll( notice, "LOS EQUIPOS SERAN CAMBIADOS EN LA PROXIMA RONDA\n" );
			bShouldShuffleTeams = true;
			
			// Secret: Give extra XP at the end for each round that happened beyond 10+ without a swap
			int iAddSecret = iRoundNumber - 10;
			if ( iAddSecret > 0 )
			{
				for ( int i = 1; i <= g_Engine.maxClients; i++ )
				{
					CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
					
					if ( iPlayer !is null && iPlayer.IsConnected() )
					{
						CustomKeyvalues@ pKVD = iPlayer.GetCustomKeyvalues();
						CustomKeyvalue pre_iTotalRounds( pKVD.GetKeyvalue( "$i_secret_rounds" ) );
						int iTotalRounds = pre_iTotalRounds.GetInteger();
						iTotalRounds += iAddSecret;
						pKVD.SetKeyvalue( "$i_secret_rounds", iTotalRounds );
					}
				}
			}
		}
		return;
	}
	
	// Randomize teams
	bool bUneven = false;
	int iSpiral = 0;
	int iCrimson = 0;
	
	// Total amount of players is uneven
	if ( ( g_PlayerFuncs.GetNumPlayers() % 2 ) == 1 )
		bUneven = true;
	
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		// Set everyone a temporary name for selection
		ent.pev.targetname = "itsarng";
		
		// !!!! GAME BUG !!!!
		// It's once again counting disconnected players when it should return NULL!
		// Set alive spirals
		//iSpiral++;
	}
	
	// Temp fix
	iSpiral = g_PlayerFuncs.GetNumPlayers();
	
	// Select random players.
	while ( iSpiral != iCrimson )
	{
		CBasePlayer@ pPlayer = cast< CBasePlayer@ >( g_EntityFuncs.RandomTargetname( "itsarng" ) );
		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			// Set them on crimson
			pPlayer.pev.targetname = "crimson";
			pPlayer.KeyValue( "classify", "5" );
			g_PlayerFuncs.ClientPrint( cast< CBasePlayer@ >( pPlayer ), HUD_PRINTTALK, "* Estas jugando para el equipo Crimson\n" );
			g_EngineFuncs.ClientPrintf( cast< CBasePlayer@ >( pPlayer ), print_center, "Estas jugando para el equipo Crimson\n" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
			eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
			
			iCrimson++;
			iSpiral--;
		}
		
		// If we are uneven this will iterate endlessly, resulting in a server freeze
		// Break loop as soon as Crimsons surpasses Spirals
		if ( iCrimson > iSpiral && bUneven ) break;
	}
	
	// Okay. Now, check if we are uneven
	if ( bUneven )
	{
		// We are, choose a random crimson player
		CBaseEntity@ pPlayer = g_EntityFuncs.RandomTargetname( "crimson" );
		if ( pPlayer !is null )
		{
			// Should this player remain on crimson or spiral?
			if ( Math.RandomLong( 1, 100 ) <= 50 )
			{
				// Spiral
				pPlayer.pev.targetname = "spiral";
				pPlayer.KeyValue( "classify", "4" );
				g_PlayerFuncs.ClientPrint( cast< CBasePlayer@ >( pPlayer ), HUD_PRINTTALK, "* Estas jugando para el equipo Spiral\n" );
				g_EngineFuncs.ClientPrintf( cast< CBasePlayer@ >( pPlayer ), print_center, "Estas jugando para el equipo Spiral\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
			}
		}
	}
	
	CBaseEntity@ pSpiral = null;
	while ( ( @pSpiral = g_EntityFuncs.FindEntityByTargetname( ent, "itsarng" ) ) !is null )
	{
		if ( cast< CBasePlayer@ >( pSpiral ).IsConnected() )
		{
			// Now, any remaining unselected player will become spiral
			pSpiral.pev.targetname = "spiral";
			pSpiral.KeyValue( "classify", "4" );
			g_PlayerFuncs.ClientPrint( cast< CBasePlayer@ >( pSpiral ), HUD_PRINTTALK, "* Estas jugando para el equipo Spiral\n" );
			g_EngineFuncs.ClientPrintf( cast< CBasePlayer@ >( pSpiral ), print_center, "Estas jugando para el equipo Spiral\n" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
			eModel.Use( pSpiral, pSpiral, USE_TOGGLE );
		}
	}
	
	// End
	bShouldShuffleTeams = false;
	iRoundNumber = 1;
	iSpiralWins = 0;
	iCrimsonWins = 0;
}

void HurtAllPlayers()
{
	// Using the sys_game entity will cause the system to consider it as a team change
	// Instead, we are going to create a temporary entity for this
	CBaseEntity@ pTempEnt = g_EntityFuncs.Create( "info_target", g_vecZero, g_vecZero, false );
	pTempEnt.pev.targetname = "temp_hurt";
	
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		ent.pev.armorvalue = 0.0; // Also take away any armor
		ent.TakeDamage( pTempEnt.pev, pTempEnt.pev, 2.0, DMG_CLUB );
	}
	
	g_EntityFuncs.Remove( pTempEnt );
}

void CallSpawnOnLiving()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		if ( ent.IsAlive() )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( ent.entindex() );
			PlayerSpawn( pPlayer );
		}
	}
}

void CallRespawn()
{
	g_PlayerFuncs.RespawnAllPlayers( true, true );
}

void AddScore( const string& in szTeam )
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
	
	if ( szTeam == 'spiral' )
	{
		pCustom.SetKeyvalue( "$i_extra_spiral", 1 );
		iSpiralWins++;
	}
	else if ( szTeam == 'crimson' )
	{
		pCustom.SetKeyvalue( "$i_extra_crimson", 1 );
		iCrimsonWins++;
	}
	
	// Reset Round
	iAliveSpirals = 0;
	iAliveCrimsons = 0;
	SpawnON();
	FootstepsOFF();
	iRoundTime = 20;
	iRoundNumber++;
	CallSpawnOnLiving();
	g_Scheduler.SetTimeout( "CallRespawn", 0.05 );
	g_Scheduler.SetTimeout( "NewTeams", 0.10 );
}

void RoundCheck()
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return;
	
	if ( !bGameStart )
		return;
	
	if ( !bRoundStart && iRoundTime >= 0 )
	{
		iRoundTime--;
		if ( iRoundTime < 0 )
		{
			iRoundTime = 120;
			bRoundStart = true;
			CheatOFF();
			SpawnOFF();
			FootstepsON();
			return;
		}
		
		HUDTextParams startup;
		startup.x = -1;
		startup.y = 0.85;
		startup.effect = 0;
		startup.r1 = 200;
		startup.g1 = 200;
		startup.b1 = 0;
		startup.a1 = 250;
		startup.r2 = 200;
		startup.g2 = 200;
		startup.b2 = 0;
		startup.a2 = 250;
		startup.fadeinTime = 0.0;
		startup.fadeoutTime = 0.0;
		startup.holdTime = 255.0;
		startup.fxTime = 0.0;
		startup.channel = 2;
		
		int seconds = iRoundTime;
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
		
		if ( g_PlayerFuncs.GetNumPlayers() < 2 )
		{
			iRoundTime = 20;
			g_PlayerFuncs.HudMessageAll( startup, "No hay suficientes jugadores para comenzar la ronda\n" );
		}
		else
			g_PlayerFuncs.HudMessageAll( startup, "" + szTime1 + szTime2 + "\n" );
	}
	else if ( bRoundStart && iRoundTime >= 0 )
	{
		iRoundTime--;
		if ( iRoundTime < 0 )
		{
			if ( iAliveSpirals == iAliveCrimsons )
			{
				HUDTextParams sdeath;
				sdeath.x = -1;
				sdeath.y = 0.85;
				sdeath.effect = 1;
				sdeath.r1 = 250;
				sdeath.g1 = 0;
				sdeath.b1 = 0;
				sdeath.a1 = 250;
				sdeath.r2 = 250;
				sdeath.g2 = 250;
				sdeath.b2 = 250;
				sdeath.a2 = 250;
				sdeath.fadeinTime = 0.0;
				sdeath.fadeoutTime = 0.0;
				sdeath.holdTime = 255.0;
				sdeath.fxTime = 0.0;
				sdeath.channel = 2;
				
				iRoundTime++;
				g_PlayerFuncs.HudMessageAll( sdeath, "MUERTE SUBITA" );
				HurtAllPlayers();
			}
			else
			{
				// End round
				bRoundStart = false;
				iRoundTime = -1;
				
				HUDTextParams score2;
				score2.x = -1;
				score2.y = 0.6;
				score2.effect = 0;
				score2.r1 = 200;
				score2.g1 = 200;
				score2.b1 = 200;
				score2.a1 = 0;
				score2.r2 = 200;
				score2.g2 = 200;
				score2.b2 = 200;
				score2.a2 = 0;
				score2.fadeinTime = 1.0;
				score2.fadeoutTime = 1.0;
				score2.holdTime = 3.0;
				score2.fxTime = 0.0;
				score2.channel = 1;
				
				g_PlayerFuncs.HudMessageAll( score2, "No hay ganadores..." );
				g_Scheduler.SetTimeout( "AddScore", 4.5, "neutral" );
			}
		}
		else
		{
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
			rtime.channel = 2;
			
			int seconds = iRoundTime;
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
			
			g_PlayerFuncs.HudMessageAll( rtime, "" + szTime1 + szTime2 + "\n" );
		}
	}
	else
	{
		HUDTextParams empty;
		empty.x = -1;
		empty.y = 0.85;
		empty.effect = 0;
		empty.r1 = 250;
		empty.g1 = 250;
		empty.b1 = 250;
		empty.a1 = 250;
		empty.r2 = 250;
		empty.g2 = 250;
		empty.b2 = 250;
		empty.a2 = 250;
		empty.fadeinTime = 0.0;
		empty.fadeoutTime = 0.0;
		empty.holdTime = 255.0;
		empty.fxTime = 0.0;
		empty.channel = 2;
		
		g_PlayerFuncs.HudMessageAll( empty, " " );
	}
}

// Check leavers
HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return HOOK_CONTINUE;
	
	iAliveCrimsons = 0;
	iAliveSpirals = 0;
	string tname;
	
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( iPlayer !is null && iPlayer.IsConnected() && iPlayer.IsAlive() )
		{
			tname = iPlayer.pev.targetname;
			if ( tname == 'crimson' ) iAliveCrimsons++;
			if ( tname == 'spiral' ) iAliveSpirals++;
		}
	}
	
	if ( iAliveCrimsons == 0 && bRoundStart && bGameStart )
	{
		// End round
		bRoundStart = false;
		iRoundTime = -1;
		
		// Wait a liiiiitle while to check if they were killed at the same time (Draw?)
		if ( gDrawTask is null )
			@gDrawTask = @g_Scheduler.SetTimeout( "DrawCheck", 0.1 );
	}
	else if ( iAliveSpirals == 0 && bRoundStart && bGameStart )
	{
		// End round
		bRoundStart = false;
		iRoundTime = -1;
		
		// Wait a liiiiitle while to check if they were killed at the same time (Draw?)
		if ( gDrawTask is null )
			@gDrawTask = @g_Scheduler.SetTimeout( "DrawCheck", 0.1 );
	}
	
	return HOOK_CONTINUE;
}

void DrawCheck()
{
	// Yes, it's literally a copy with minor differences
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return;
	
	iAliveCrimsons = 0;
	iAliveSpirals = 0;
	string tname;
	
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		
		if ( iPlayer !is null && iPlayer.IsConnected() && iPlayer.IsAlive() )
		{
			tname = iPlayer.pev.targetname;
			if ( tname == 'crimson' ) iAliveCrimsons++;
			if ( tname == 'spiral' ) iAliveSpirals++;
		}
	}
	
	if ( iAliveCrimsons == 0 && iAliveSpirals == 0 )
	{
		HUDTextParams score1;
		score1.x = -1;
		score1.y = 0.6;
		score1.effect = 0;
		score1.r1 = 200;
		score1.g1 = 200;
		score1.b1 = 200;
		score1.a1 = 0;
		score1.r2 = 200;
		score1.g2 = 200;
		score1.b2 = 200;
		score1.a2 = 0;
		score1.fadeinTime = 1.0;
		score1.fadeoutTime = 1.0;
		score1.holdTime = 3.0;
		score1.fxTime = 0.0;
		score1.channel = 1;
		
		g_PlayerFuncs.HudMessageAll( score1, "Es un empate!" );
		g_Scheduler.SetTimeout( "AddScore", 4.5, "neutral" );
	}
	else if ( iAliveSpirals == 0 )
	{
		HUDTextParams score2;
		score2.x = -1;
		score2.y = 0.6;
		score2.effect = 0;
		score2.r1 = 200;
		score2.g1 = 100;
		score2.b1 = 10;
		score2.a1 = 250;
		score2.r2 = 200;
		score2.g2 = 100;
		score2.b2 = 10;
		score2.a2 = 250;
		score2.fadeinTime = 1.0;
		score2.fadeoutTime = 1.0;
		score2.holdTime = 3.0;
		score2.fxTime = 0.0;
		score2.channel = 1;
		
		g_PlayerFuncs.HudMessageAll( score2, "Ganan los Crimson!" );
		g_Scheduler.SetTimeout( "AddScore", 4.5, "crimson" );
	}
	else if ( iAliveCrimsons == 0 )
	{
		HUDTextParams score2;
		score2.x = -1;
		score2.y = 0.6;
		score2.effect = 0;
		score2.r1 = 10;
		score2.g1 = 200;
		score2.b1 = 200;
		score2.a1 = 250;
		score2.r2 = 10;
		score2.g2 = 200;
		score2.b2 = 200;
		score2.a2 = 250;
		score2.fadeinTime = 1.0;
		score2.fadeoutTime = 1.0;
		score2.holdTime = 3.0;
		score2.fxTime = 0.0;
		score2.channel = 1;
		
		g_PlayerFuncs.HudMessageAll( score2, "Ganan los Spiral!" );
		g_Scheduler.SetTimeout( "AddScore", 4.5, "spiral" );
	}
	
	@gDrawTask = null;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	// Game did not begin or a round already started
	if ( !bGameStart || bRoundStart )
		return HOOK_CONTINUE;
	
	string szTeam = string( pPlayer.pev.targetname );
	if ( szTeam == 'spiral' ) iAliveSpirals++;
	else if ( szTeam == 'crimson' ) iAliveCrimsons++;
	else
	{
		// This player does not belong to any team, this WILL be the case
		// when a player joins before a round starts.
		
		// So, let's check and assign him/her a team.
		if ( iAliveSpirals == iAliveCrimsons )
		{
			// Even. Randomly select team and send the player there
			if ( Math.RandomLong( 1, 100 ) >= 50 )
			{
				// Crimson
				pPlayer.pev.targetname = "crimson";
				pPlayer.KeyValue( "classify", "5" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Estas jugando para el equipo Crimson\n" );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Crimson\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
				
				iAliveCrimsons++;
			}
			else
			{
				// Spiral
				pPlayer.pev.targetname = "spiral";
				pPlayer.KeyValue( "classify", "4" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Estas jugando para el equipo Spiral\n" );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Spiral\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
				
				iAliveSpirals++;
			}
		}
		else
		{
			// Uneven. Check who has the extra player
			if ( iAliveSpirals > iAliveCrimsons )
			{
				// Spirals have the upper hand, so send him/her to crimson
				pPlayer.pev.targetname = "crimson";
				pPlayer.KeyValue( "classify", "5" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Estas jugando para el equipo Crimson\n" );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Crimson\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
				
				iAliveCrimsons++;
			}
			else
			{
				// Backwards. Crimson has the upper hand, go to spiral
				pPlayer.pev.targetname = "spiral";
				pPlayer.KeyValue( "classify", "4" );
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* Estas jugando para el equipo Spiral\n" );
				g_EngineFuncs.ClientPrintf( pPlayer, print_center, "Estas jugando para el equipo Spiral\n" );
				
				CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
				eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
				
				iAliveSpirals++;
			}
		}
	}
	
	// Strip player weapons, he may be still alive after last round
	pPlayer.RemoveAllItems( false ); // false means DON'T strip suit
	
	// Set the player's invisible, invulnerable, and inmune to bullets
	g_Scheduler.SetTimeout( "CheatON", 0.1, pPlayer.entindex() );
	
	// Randomly give weapons
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_hlcrowbar" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_hl357" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_hlcrossbow" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_tmp" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_usp" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_scout" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_m4a1" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_eagle" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_sniperrifle" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
		pPlayer.GiveNamedItem( "weapon_medkit" );
	if ( Math.RandomLong( 1, 100 ) >= 50 )
	{
		pPlayer.GiveNamedItem( "weapon_handgrenade" );
		pPlayer.GiveNamedItem( "weapon_handgrenade" );
	}
	
	// Give some ammo
	// UNDONE - m_rgAmmo indexes are now dynamic, can't use this. Give ammo manually
	//pPlayer.m_rgAmmo( 5, 36 ); // 5 = AMMO_357
	//pPlayer.m_rgAmmo( 4, 50 ); // 4 = AMMO_CROSSBOW
	//pPlayer.m_rgAmmo( 15, 15 ); // 15 = AMMO_762 (Sniper Rifle)
	
	// This is earrape... I refuse to give everything on one go
	pPlayer.GiveNamedItem( "ammo_357" );
	pPlayer.GiveNamedItem( "ammo_357" );
	pPlayer.GiveNamedItem( "ammo_357" );
	pPlayer.GiveNamedItem( "ammo_crossbow" );
	pPlayer.GiveNamedItem( "ammo_crossbow" );
	pPlayer.GiveNamedItem( "ammo_crossbow" );
	pPlayer.GiveNamedItem( "ammo_crossbow" );
	pPlayer.GiveNamedItem( "ammo_762" );
	pPlayer.GiveNamedItem( "ammo_762" );
	
	// Boost the player
	pPlayer.TakeHealth( 100.0, DMG_GENERIC, 100 );
	pPlayer.TakeArmor( 10.0, DMG_GENERIC, 10 );
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	// Render player invisible so it cannot be revived
	pPlayer.pev.effects |= EF_NODRAW;
	
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return HOOK_CONTINUE;
	
	CustomKeyvalues@ pCustom = gData.GetCustomKeyvalues();
	
	// Prevent team score from increasing after each kill, we will handle our own
	// Also take care of other stuff
	string szTeam = string( pPlayer.pev.targetname );
	if ( szTeam == 'spiral' )
	{
		pCustom.SetKeyvalue( "$i_extra_crimson", -1 );
		iAliveSpirals--;
		
		if ( pPlayer !is pAttacker )
		{
			pAttacker.TakeHealth( 6.0, DMG_GENERIC );
			pAttacker.TakeArmor( 3.0, DMG_GENERIC );
		}
		
		// Extended round time only if sudden death is not active. Also, don't fuck up warm up
		if ( iRoundTime > 1 && bRoundStart ) iRoundTime += 20;
	}
	else if ( szTeam == 'crimson' )
	{
		pCustom.SetKeyvalue( "$i_extra_spiral", -1 );
		iAliveCrimsons--;
		
		if ( pPlayer !is pAttacker )
		{
			pAttacker.TakeHealth( 6.0, DMG_GENERIC );
			pAttacker.TakeArmor( 3.0, DMG_GENERIC );
		}
		
		// Extended round time only if sudden death is not active
		if ( iRoundTime > 1 && bRoundStart ) iRoundTime += 20;
	}
	
	// We are better off just checking this from a reset
	ClientDisconnect( pPlayer );
	
	return HOOK_CONTINUE;
}
