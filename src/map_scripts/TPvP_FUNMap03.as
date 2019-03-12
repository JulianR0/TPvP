// Style 03 of 99 allowed (fun_clue_3)

#include "UTIL_GetDefaultShellInfo"

#include "hl_weapons/weapon_hlcrowbar"
#include "hl_weapons/weapon_hl357"

#include "cs16/Util"
#include "cs16/weapon_csknife"
#include "cs16/weapon_usp"
#include "cs16/weapon_fiveseven"
#include "cs16/weapon_p228"
#include "cs16/weapon_ump45"
#include "cs16/weapon_p90" // Not used but needed for ammo type to register (P228)
#include "cs16/weapon_mac10"

#include "dod_weapons/ShellEject"
#include "dod_weapons/weapon_webley"

bool bGameStart;
bool bRoundStart;
bool bCheckAssassin;
bool bLights;
bool bRestart;
int iAliveSpirals;
int iAliveCrimsons;
int iRoundTime;

CScheduledFunction@ gAssassinTask = null;

void MapInit()
{
	RegisterHLCrowbar();
	RegisterHL357();
	
	RegisterSIG357Box();
	RegisterFN57Box();
	RegisterUSPAmmoBox();
	
	RegisterMAC10();
	RegisterP228();
	RegisterFIVESEVEN();
	RegisterUSP();
	RegisterUMP45();
	
	RegisterWEBLEY();
	
	bGameStart = false;
	bRoundStart = false;
	bCheckAssassin = false;
	bLights = true;
	bRestart = false;
	iAliveSpirals = 0;
	iAliveCrimsons = 0;
	iRoundTime = 0;
	
	// Start game after 50 seconds of map start
	g_Scheduler.SetTimeout( "StartGame", 1.0, 50 );
	
	g_Scheduler.SetInterval( "RoundCheck", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
}

void StartGame( int iWarmUp )
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return;
	
	iWarmUp--;
	if ( iWarmUp < 0 )
	{
		DeadChatOFF();
		TeamsOFF();
		
		bGameStart = true;
		iRoundTime = 35;
		CallSpawnOnLiving();
		g_Scheduler.SetTimeout( "CallRespawn", 0.05 );
		
		g_Scheduler.SetTimeout( "NewAssassin", 0.15 );
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
	
	if ( g_PlayerFuncs.GetNumPlayers() < 3 )
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

void ToggleLights()
{
	g_EntityFuncs.FireTargets( "l", null, null, USE_TOGGLE );
	
	if ( bLights )
		bLights = false;
	else
		bLights = true;
	
	if ( bLights )
	{
		CBaseEntity@ ent2 = null;
		while( ( @ent2 = g_EntityFuncs.FindEntityByTargetname( ent2, "thewall" ) ) !is null )
		{
			ent2.pev.renderamt = 200;
		}
	}
	else
	{
		CBaseEntity@ ent2 = null;
		while( ( @ent2 = g_EntityFuncs.FindEntityByTargetname( ent2, "thewall" ) ) !is null )
		{
			ent2.pev.renderamt = 80;
		}
	}
}

void CheatON( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( pPlayer !is null )
	{
		pPlayer.pev.flags |= FL_GODMODE;
	}
}

void CheatOFF()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		ent.pev.flags &= ~FL_GODMODE;
	}
}

void CheatOFFSingle( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( pPlayer !is null )
	{
		pPlayer.pev.flags &= ~FL_GODMODE;
	}
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

void HurtAssassin()
{
	// Using the sys_game entity will cause the system to consider it as a team change
	// Instead, we are going to create a temporary entity for this
	CBaseEntity@ pTempEnt = g_EntityFuncs.Create( "info_target", g_vecZero, g_vecZero, false );
	pTempEnt.pev.targetname = "temp_hurt";
	
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityByTargetname( ent, "spiral" ) ) !is null )
	{
		ent.TakeDamage( pTempEnt.pev, pTempEnt.pev, 1000.0, DMG_ALWAYSGIB );
	}
	
	g_EntityFuncs.Remove( pTempEnt );
}

void KillAllWeapons()
{
	CBaseEntity@ ent = null;
	while( ( @ent = g_EntityFuncs.FindEntityInSphere( ent, g_vecZero, 4096.0, "*", "classname" ) ) !is null ) // I shouldn't...
	{
		string cname = ent.pev.classname;
		if ( cname[ 0 ] == 'w' && cname[ 1 ] == 'e' && cname[ 2 ] == 'a' && cname[ 3 ] == 'p' && cname[ 4 ] == 'o' && cname[ 5 ] == 'n' && cname[ 6 ] == '_' )
		{
			CBaseEntity@ pOwner = g_EntityFuncs.Instance( ent.pev.owner );
			if ( pOwner is null )
			{
				// No owner means this weapon has NOT been picked up
				g_EntityFuncs.Remove( ent );
			}
		}
	}
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
	}
	else if ( szTeam == 'crimson' )
	{
		pCustom.SetKeyvalue( "$i_extra_crimson", 1 );
	}
	
	// Reset Round
	ToggleLights();
	SpawnON();
	iRoundTime = 35;
	CallSpawnOnLiving();
	g_Scheduler.SetTimeout( "CallRespawn", 0.05 );
	g_Scheduler.SetTimeout( "NewAssassin", 0.15 );
}

// Fully reset the system. Used when there used to be insufficient players
void FullReset()
{
	CheatOFF();
	CallSpawnOnLiving();
	g_Scheduler.SetTimeout( "CallRespawn", 0.05 );
	g_Scheduler.SetTimeout( "KillAllWeapons", 0.10 );
	g_Scheduler.SetTimeout( "NewAssassin", 0.15 );
}

// Set's a new assassin (Spiral)
void NewAssassin()
{
	iAliveSpirals = 0;
	iAliveCrimsons = 0;
	bool bFound = false;
	
	CBaseEntity@ ent = null;
	while ( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		// Set everyone a temporary name for selection
		ent.pev.targetname = "itsarng";
		
		// Set alive hostages
		iAliveCrimsons++;
	}
	
	// Okay, now select a random player
	CBasePlayer@ pPlayer = cast< CBasePlayer@ >( g_EntityFuncs.RandomTargetname( "itsarng" ) );
	if ( pPlayer !is null && pPlayer.IsConnected() )
	{
		// WINNER! This is our new assassin
		pPlayer.pev.targetname = "spiral";
		pPlayer.KeyValue( "classify", "4" );
		bFound = true;
		
		CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_spiral" );
		eModel.Use( pPlayer, pPlayer, USE_TOGGLE );
		
		iAliveSpirals = 1;
		iAliveCrimsons--;
		InitAssassin( pPlayer.entindex() );
	}
	
	// Everyone else is to be put on hostage
	@ent = null;
	while ( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, "player" ) ) !is null )
	{
		if ( ent.pev.targetname != 'spiral' )
		{
			ent.pev.targetname = "crimson";
			ent.KeyValue( "classify", "5" );
			
			CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname( null, "sys_mdl_crimson" );
			eModel.Use( ent, ent, USE_TOGGLE );
		}
	}
	
	// No assassin? Retry the iteration as many times needed
	if ( !bFound )
		NewAssassin();
}

// Prepare stuff for our new assassin
void InitAssassin( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( pPlayer !is null )
	{
		// Move to limbo
		pPlayer.SetOrigin( Vector( 8192.0, 8192.0, 8192.0 ) );
		
		// Fade his screen
		g_PlayerFuncs.ScreenFade( pPlayer, g_vecZero, 0.1, 30.0, 255, FFADE_STAYOUT );
		
		// Notify him of his role
		HUDTextParams mission;
		mission.x = -1;
		mission.y = 0.7;
		mission.effect = 2;
		mission.r1 = 200;
		mission.g1 = 200;
		mission.b1 = 0;
		mission.a1 = 250;
		mission.r2 = 200;
		mission.g2 = 200;
		mission.b2 = 0;
		mission.a2 = 250;
		mission.fadeinTime = 0.04;
		mission.fadeoutTime = 0.5;
		mission.holdTime = 2.0;
		mission.fxTime = 0.25;
		mission.channel = 1;
		
		// We should notify the spirals, first
		g_PlayerFuncs.HudMessageAll( mission, "Eres un rehen, escondete y evita ser asesinado. Puedes encontrar\narmas para defenderte, pero no te fies mucho de ellas" );
		
		// Overlap this one for the assassin
		g_PlayerFuncs.HudMessage( pPlayer, mission, "Eres el asesino, busca a tus rehenes y matalos uno por uno\nPierdes la ronda si se te acaban las balas o si mueres en el intento" );
		
		// Spawn him at round start
		@gAssassinTask = @g_Scheduler.SetTimeout( "AssassinSpawn", 35.5, pPlayer.entindex() );
		g_Scheduler.SetTimeout( "WeaponSpawn", 0.20 );
	}
}

void FIX_GiveAmmo( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( pPlayer !is null )
	{
		CBasePlayerItem@ pItem = cast< CBasePlayerItem@ >( pPlayer.m_hActiveItem.GetEntity() );
		CBasePlayerWeapon@ pWeapon = pItem.GetWeaponPtr();
		pPlayer.m_rgAmmo( pWeapon.m_iPrimaryAmmoType, 12 );
	}
}

// Hunting time!
void AssassinSpawn( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	
	if ( pPlayer !is null )
	{
		g_PlayerFuncs.RespawnPlayer( pPlayer, true, false );
		g_PlayerFuncs.ScreenFade( pPlayer, g_vecZero, 1.0, 0.1, 255, FFADE_IN );
		
		// WEPON
		pPlayer.GiveNamedItem( "weapon_webley" );
		
		// Give ammo
		g_Scheduler.SetTimeout( "FIX_GiveAmmo", 0.075, pPlayer.entindex() );
		
		// Give health
		//pPlayer.TakeHealth( 100.0, DMG_GENERIC, 100 );
		pPlayer.pev.health = 100;
		
		// Godmode, to prevent spawnkill
		g_Scheduler.SetTimeout( "CheatON", 0.1, pPlayer.entindex() );
		g_Scheduler.SetTimeout( "CheatOFFSingle", 2.1, pPlayer.entindex() );
		
		// Kill other weapons that may be spawned
		KillAllWeapons();
		
		// Start!
		ToggleLights();
		bCheckAssassin = true;
		SpawnOFF();
	}
}

void RoundCheck()
{
	CBaseEntity@ gData = g_EntityFuncs.FindEntityByTargetname( null, "sys_game" );
	if ( gData is null )
		return;
	
	if ( !bGameStart )
		return;
	
	if ( bCheckAssassin ) // Ammo check
	{
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
			
			if ( pPlayer !is null && pPlayer.IsConnected() )
			{
				CBasePlayerItem@ pItem = cast< CBasePlayerItem@ >( pPlayer.m_hActiveItem.GetEntity() );
				
				if ( pItem !is null )
				{
					CBasePlayerWeapon@ pWeapon = pItem.GetWeaponPtr();
					string tname = string( pPlayer.pev.targetname );
					
					if ( tname == 'spiral' )
					{
						int pAmmo = pPlayer.m_rgAmmo( pWeapon.m_iPrimaryAmmoType );
						int iClip = pWeapon.m_iClip;
						
						if ( pAmmo == 0 && iClip == 0 )
						{
							g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* El asesino se quedo sin balas!\n" );
							g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "El asesino se quedo sin balas!\n" );
						
							HurtAssassin();
						}
					}
					else if ( tname == 'crimson' )
					{
						// No "extra" ammo allowed
						if ( pWeapon.m_iPrimaryAmmoType != WEAPON_NOCLIP )
							pPlayer.m_rgAmmo( pWeapon.m_iPrimaryAmmoType, 0 );
					}
				}
			}
		}
	}
	
	if ( !bRoundStart && iRoundTime >= 0 )
	{
		iRoundTime--;
		if ( iRoundTime < 0 )
		{
			iRoundTime = 90;
			bRoundStart = true;
			CheatOFF();
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
		
		if ( g_PlayerFuncs.GetNumPlayers() < 3 )
		{
			bRestart = true;
			iRoundTime = 35;
			g_PlayerFuncs.HudMessageAll( startup, "No hay suficientes jugadores para comenzar la ronda\n" );
			
			if ( gAssassinTask !is null )
			{
				g_Scheduler.RemoveTimer( gAssassinTask );
				@gAssassinTask = @null;
			}
		}
		else if ( bRestart )
		{
			bRestart = false;
			g_Scheduler.SetTimeout( "FullReset", 0.5 );
		}
		else
			g_PlayerFuncs.HudMessageAll( startup, "" + szTime1 + szTime2 + "\n" );
	}
	else if ( bRoundStart && iRoundTime >= 0 )
	{
		iRoundTime--;
		if ( iRoundTime < 0 )
		{
			// End round
			bRoundStart = false;
			bCheckAssassin = false;
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
			
			// Added for lulz.
			HurtAssassin();
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
		bCheckAssassin = false;
		iRoundTime = -1;
		
		HUDTextParams score1;
		score1.x = -1;
		score1.y = 0.6;
		score1.effect = 0;
		score1.r1 = 10;
		score1.g1 = 200;
		score1.b1 = 200;
		score1.a1 = 250;
		score1.r2 = 10;
		score1.g2 = 200;
		score1.b2 = 200;
		score1.a2 = 250;
		score1.fadeinTime = 1.0;
		score1.fadeoutTime = 1.0;
		score1.holdTime = 3.0;
		score1.fxTime = 0.0;
		score1.channel = 1;
		
		g_PlayerFuncs.HudMessageAll( score1, "Ganan los Spiral!" );
		g_Scheduler.SetTimeout( "AddScore", 4.5, "spiral" );
		
		// The assassin won the round! Give bonus for the gameend
		CBaseEntity@ pAssassin = g_EntityFuncs.FindEntityByTargetname( null, "spiral" );
		CustomKeyvalues@ pCustom = pAssassin.GetCustomKeyvalues();
		CustomKeyvalue pre_iWinTimes( pCustom.GetKeyvalue( "$i_secret_wins" ) );
		int iWinTimes = pre_iWinTimes.GetInteger();
		pCustom.SetKeyvalue( "$i_secret_wins", ++iWinTimes );
	}
	else if ( iAliveSpirals == 0 && bRoundStart && bGameStart )
	{
		// End round
		bRoundStart = false;
		bCheckAssassin = false;
		iRoundTime = -1;
		
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
	else if ( iAliveSpirals == 0 && !bRoundStart && bGameStart && g_PlayerFuncs.GetNumPlayers() > 2 ) // We can restart with less than 3
	{
		// Oh, okay. Round actually ended
		if ( iRoundTime != -1 )
		{
			// Checking suicide
			CBaseEntity@ pSpiral = g_EntityFuncs.FindEntityByTargetname( null, "spiral" );
			if ( pSpiral is null )
			{
				// Who's EVEN MORE idiot to leave the server while waiting as an assassin?
				if ( gAssassinTask !is null )
				{
					g_Scheduler.RemoveTimer( gAssassinTask );
					@gAssassinTask = @null;
				}
				
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* El asesino se retiro antes de haber comenzado la ronda. Reiniciando...\n" );
				FullReset();
				iRoundTime = 35;
			}
		}
	}
	
	return HOOK_CONTINUE;
}

// Weapon spawning
void WeaponSpawn()
{
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon01 = g_EntityFuncs.Create( "weapon_hlcrowbar", Vector( 360, -568, 60 ), g_vecZero, false, null );
		Weapon01.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon02 = g_EntityFuncs.Create( "weapon_pipewrench", Vector( 32, -568, 60 ), g_vecZero, false, null );
		Weapon02.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon03 = g_EntityFuncs.Create( "weapon_9mmhandgun", Vector( 626, 480, 166 ), g_vecZero, false, null );
		Weapon03.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon04 = g_EntityFuncs.Create( "weapon_usp", Vector( 730, -32, 36 ), g_vecZero, false, null );
		Weapon04.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon05 = g_EntityFuncs.Create( "weapon_ump45", Vector( 542, -590, 36 ), g_vecZero, false, null );
		Weapon05.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon06 = g_EntityFuncs.Create( "weapon_fiveseven", Vector( -290, -416, 36 ), g_vecZero, false, null );
		Weapon06.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon07 = g_EntityFuncs.Create( "weapon_mac10", Vector( -48, 680, 76 ), g_vecZero, false, null );
		Weapon07.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon08 = g_EntityFuncs.Create( "weapon_p228", Vector( 174, 914, 160 ), g_vecZero, false, null );
		Weapon08.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon09 = g_EntityFuncs.Create( "weapon_hl357", Vector( 790, -356, 236 ), g_vecZero, false, null );
		Weapon09.pev.spawnflags |= SF_NORESPAWN;
	}
	
	if ( Math.RandomLong( 1, 100 ) <= 45 )
	{
		CBaseEntity@ Weapon10 = g_EntityFuncs.Create( "weapon_mp5", Vector( 782, 400, 236 ), g_vecZero, false, null );
		Weapon10.pev.spawnflags |= SF_NORESPAWN;
	}
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	// Game did not begin or a round already started
	if ( !bGameStart || bRoundStart )
		return HOOK_CONTINUE;
	
	// Strip player weapons, he may be still alive after last round
	pPlayer.RemoveAllItems( false ); // false means DON'T strip suit
	
	// Set the player invulnerable
	g_Scheduler.SetTimeout( "CheatON", 0.1, pPlayer.entindex() );
	
	// Set player health
	pPlayer.pev.health = 50.0;
	
	return HOOK_CONTINUE;
}

void ROFLRevive( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
	{
		// Revive him
		g_PlayerFuncs.RespawnPlayer( pPlayer, true, true );
		
		// Reset
		pPlayer.SetOrigin( Vector( 8192.0, 8192.0, 8192.0 ) );
		g_PlayerFuncs.ScreenFade( pPlayer, g_vecZero, 0.1, 30.0, 255, FFADE_STAYOUT );
		
		// Respawning deletes all HUD messages, so re-notify on a later time
		g_Scheduler.SetTimeout( "ROFLMessage", 0.25, index );
	}
}

void ROFLMessage( const int& in index )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( index );
	if ( pPlayer !is null )
	{
		HUDTextParams mission;
		mission.x = -1;
		mission.y = 0.7;
		mission.effect = 2;
		mission.r1 = 200;
		mission.g1 = 200;
		mission.b1 = 0;
		mission.a1 = 250;
		mission.r2 = 200;
		mission.g2 = 200;
		mission.b2 = 0;
		mission.a2 = 250;
		mission.fadeinTime = 0.04;
		mission.fadeoutTime = 0.5;
		mission.holdTime = 2.0;
		mission.fxTime = 0.25;
		mission.channel = 1;
		
		g_PlayerFuncs.HudMessage( pPlayer, mission, "Eres el asesino, busca a tus rehenes y matalos uno por uno\nPierdes la ronda si se te acaban las balas o si mueres en el intento" );
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "* No tienes nada mejor que hacer?\n" );
	}
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
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
		
		// Who's idiot enough to commit suicide while waiting as an assassin?
		if ( !bRoundStart && bGameStart && iRoundTime != -1 )
		{
			g_Scheduler.SetTimeout( "ROFLRevive", 0.25, pPlayer.entindex() );
			iAliveSpirals++;
		}
		
		if ( pPlayer !is pAttacker && pAttacker.IsPlayer() )
		{
			pAttacker.TakeArmor( 8.0, DMG_GENERIC );
		}
	}
	else if ( szTeam == 'crimson' )
	{
		pCustom.SetKeyvalue( "$i_extra_spiral", -1 );
		
		if ( pPlayer !is pAttacker && pAttacker.IsPlayer() )
		{
			pAttacker.TakeHealth( 8.0, DMG_GENERIC );
			pAttacker.TakeArmor( 4.0, DMG_GENERIC );
			
			CBasePlayer@ CBPAttacker = g_PlayerFuncs.FindPlayerByIndex( pAttacker.entindex() );
			CBasePlayerItem@ pItem = cast< CBasePlayerItem@ >( CBPAttacker.m_hActiveItem.GetEntity() );
			CBasePlayerWeapon@ pWeapon = pItem.GetWeaponPtr();
			
			int pAmmo = CBPAttacker.m_rgAmmo( pWeapon.m_iPrimaryAmmoType );
			if ( pAmmo < 36 )
				CBPAttacker.GiveNamedItem( "ammo_357" );
			
			iRoundTime += 35;
		}
	}
	
	// We are better off just checking this from a reset
	ClientDisconnect( pPlayer );
	
	return HOOK_CONTINUE;
}
