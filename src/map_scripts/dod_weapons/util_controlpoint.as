class util_controlpoint : ScriptBaseEntity
{
	string szPointName;
	array< CBasePlayer@ > pPlayer( 33 );
	int iSpiralCappers;
	int iCrimsonCappers;
	float flCaptureProgress;
	int iTeam;
	float flNextPoints;
	
	// Targets
	string szSpiralTarget;
	string szNeutralTarget;
	string szCrimsonTarget;
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "point_name" )
		{
			szPointName = szValue;
			return true;
		}
		else if ( szKey == "spiral_target" )
		{
			szSpiralTarget = szValue;
			return true;
		}
		else if ( szKey == "neutral_target" )
		{
			szNeutralTarget = szValue;
			return true;
		}
		else if ( szKey == "crimson_target" )
		{
			szCrimsonTarget = szValue;
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/ecsc/dod_cp.mdl" );
	}
	
	void Spawn()
	{
		Precache();
		
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_TRIGGER;
		
		self.pev.framerate = 1.0f;
		
		self.pev.skin = 2; // 2 = NEUTRAL / NOT CAPPED
		
		g_EntityFuncs.SetModel( self, "models/ecsc/dod_cp.mdl" );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		g_EntityFuncs.SetSize( self.pev, Vector( -64, -64, -64 ), Vector( 64, 64, 64 ) );
		
		SetThink( ThinkFunction( CaptureThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	void Touch( CBaseEntity@ pOther )
	{
		if( !pOther.IsAlive() )
			return;
		
		if ( pOther.pev.targetname == 'spiral' )
		{
			// Spiral is trying to capture point...
			
			// Already touching?
			if ( pOther !is pPlayer[ pOther.entindex() ] )
			{
				// Store player
				@pPlayer[ pOther.entindex() ] = cast< CBasePlayer@ >( pOther );
				
				// Add capper
				iSpiralCappers++;
			}
			
		}
		else if ( pOther.pev.targetname == 'crimson' )
		{
			// Crimson is trying to capture point...
			
			// Already touching?
			if ( pOther !is pPlayer[ pOther.entindex() ] )
			{
				// Store player
				@pPlayer[ pOther.entindex() ] = cast< CBasePlayer@ >( pOther );
				
				// Add capper
				iCrimsonCappers++;
			}
		}
	}
	
	void CaptureThink()
	{
		// Check first if any player is stored. If so, check if it's still touching the entity
		// Otherwise remove them from the list.
		for( int i = 0; i < 33; i++ )
		{
			if ( pPlayer[ i ] !is null )
			{
				// !! FIX !! - Make sure the stored player is STILL alive
				if ( pPlayer[ i ].IsAlive() )
				{
					if ( !pPlayer[ i ].Intersects( self ) )
					{
						if ( pPlayer[ i ].pev.targetname == 'spiral' ) iSpiralCappers--;
						else if ( pPlayer[ i ].pev.targetname == 'crimson' ) iCrimsonCappers--;
						
						@pPlayer[ i ] = null;
					}
					else
					{
						// Use this check to also let the player know capture status
						if ( iTeam == 1 && pPlayer[ i ].pev.targetname == 'spiral' )
							g_PlayerFuncs.ClientPrint( pPlayer[ i ], HUD_PRINTCENTER, "Punto ya capturado\n\nDurabilidad (" + int( flCaptureProgress ) + "%%)\n" );
						else if ( iTeam == 1 && pPlayer[ i ].pev.targetname == 'crimson' )
							g_PlayerFuncs.ClientPrint( pPlayer[ i ], HUD_PRINTCENTER, "Des-Capturando... (" + int( flCaptureProgress ) + "%%)\n" );
						else if ( iTeam == 2 && pPlayer[ i ].pev.targetname == 'crimson' )
							g_PlayerFuncs.ClientPrint( pPlayer[ i ], HUD_PRINTCENTER, "Punto ya capturado\n\nDurabilidad (" + abs( int( flCaptureProgress ) ) + "%%)\n" );
						else if ( iTeam == 2 && pPlayer[ i ].pev.targetname == 'spiral' )
							g_PlayerFuncs.ClientPrint( pPlayer[ i ], HUD_PRINTCENTER, "Des-Capturando... (" + abs( int( flCaptureProgress ) ) + "%%)\n" );
						else if ( iTeam == 0 && pPlayer[ i ].pev.targetname == 'spiral' )
							g_PlayerFuncs.ClientPrint( pPlayer[ i ], HUD_PRINTCENTER, "Capturando... (" + int( flCaptureProgress ) + "%%)\n" );
						else if ( iTeam == 0 && pPlayer[ i ].pev.targetname == 'crimson' )
							g_PlayerFuncs.ClientPrint( pPlayer[ i ], HUD_PRINTCENTER, "Capturando... (" + abs( int( flCaptureProgress ) ) + "%%)\n" );
					}
				}
				else
				{
					// Dead player. Remove
					if ( pPlayer[ i ].pev.targetname == 'spiral' ) iSpiralCappers--;
					else if ( pPlayer[ i ].pev.targetname == 'crimson' ) iCrimsonCappers--;
					
					@pPlayer[ i ] = null;
				}
			}
			else
			{
				// Stored player has disconnected or it's invalid. Remove it
				@pPlayer[ i ] = null;
			}
		}
		
		// Progress should be dependant on how many spirals/crimsons are standing on the point
		// Loop again, a high level player can capture faster
		float flExtraSpeed = 0.0;
		for( int i = 0; i < 33; i++ )
		{
			if ( pPlayer[ i ] !is null )
			{
				CustomKeyvalues@ pKVD = pPlayer[ i ].GetCustomKeyvalues();
				CustomKeyvalue iLevel_pre( pKVD.GetKeyvalue( "$i_player_level" ) );
				int iLevel = iLevel_pre.GetInteger();
				
				if ( iLevel >= 23 ) flExtraSpeed += 0.006;
				if ( iLevel >= 42 ) flExtraSpeed += 0.006;
				if ( iLevel >= 64 ) flExtraSpeed += 0.006;
				if ( iLevel >= 79 ) flExtraSpeed += 0.006;
			}
		}
		flCaptureProgress += ( ( 0.30 + flExtraSpeed ) * iSpiralCappers ) - ( ( 0.30 + flExtraSpeed ) * iCrimsonCappers );
		
		// Not capped?
		if ( iTeam == 0 )
		{
			if ( flCaptureProgress > 100.0 )
			{
				// The spirals successfully capped this point
				iTeam = 1;
				self.pev.skin = 0; // 0 = SPIRAL
				
				// Fire spiral target, if any
				if ( szSpiralTarget.Length() > 0 )
					g_EntityFuncs.FireTargets( szSpiralTarget, self, self, USE_TOGGLE );
				
				// Notify players
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Spirals han capturado el punto de control <" + szPointName + ">!\n" );
				
				// This message should display only to Spirals
				for ( int i = 1; i <= g_Engine.maxClients; i++ )
				{
					CBasePlayer@ mPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
					
					if ( mPlayer !is null && mPlayer.IsConnected() )
					{
						if ( mPlayer.pev.targetname == 'spiral' )
							g_PlayerFuncs.ClientPrint( mPlayer, HUD_PRINTCENTER, "Hemos capturado el punto de control\n\n<" + szPointName + ">\n" );
					}
				}
				
				flCaptureProgress = 100.0; // Clamp it to the max
				
				// Enable point giving
				flNextPoints = g_Engine.time + 7.5;
			}
			else if ( flCaptureProgress < -100.0 )
			{
				// The crimsons successfully capped this point
				iTeam = 2;
				self.pev.skin = 1; // 1 = CRIMSON
				
				// Fire crimson target, if any
				if ( szCrimsonTarget.Length() > 0 )
					g_EntityFuncs.FireTargets( szCrimsonTarget, self, self, USE_TOGGLE );
				
				// Notify players
				g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* Los Crimsons han capturado el punto de control <" + szPointName + ">!\n" );
				
				// This message should display only to Crimsons
				for ( int i = 1; i <= g_Engine.maxClients; i++ )
				{
					CBasePlayer@ mPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
					
					if ( mPlayer !is null && mPlayer.IsConnected() )
					{
						if ( mPlayer.pev.targetname == 'crimson' )
							g_PlayerFuncs.ClientPrint( mPlayer, HUD_PRINTCENTER, "Hemos capturado el punto de control\n\n<" + szPointName + ">\n" );
					}
				}
				
				flCaptureProgress = -100.0; // Clamp it to the max
				
				// Enable point giving
				flNextPoints = g_Engine.time + 7.5;
			}
		}
		else if ( iTeam == 1 )
		{
			// This point already belongs to the spiral's
			if ( flCaptureProgress > 100.0 ) flCaptureProgress = 100.0;
			
			if ( flCaptureProgress < 0.0 )
			{
				// Point lost!
				iTeam = 0;
				self.pev.skin = 2; // 2 = NEUTRAL / NOT CAPPED
				
				// Fire neutral target, if any
				if ( szNeutralTarget.Length() > 0 )
					g_EntityFuncs.FireTargets( szNeutralTarget, self, self, USE_TOGGLE );
				
				// This message should display only to Spirals
				for ( int i = 1; i <= g_Engine.maxClients; i++ )
				{
					CBasePlayer@ mPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
					
					if ( mPlayer !is null && mPlayer.IsConnected() )
					{
						if ( mPlayer.pev.targetname == 'spiral' )
							g_PlayerFuncs.ClientPrint( mPlayer, HUD_PRINTCENTER, "Hemos perdido el punto de control\n\n<" + szPointName + ">\n" );
					}
				}
				
				flCaptureProgress = 0.0; // Min clamp
				
				// Disable point giving
				flNextPoints = -1.0;
			}
		}
		else if ( iTeam == 2 )
		{
			// This point already belongs to the crimsons's
			if ( flCaptureProgress < -100.0 ) flCaptureProgress = -100.0;
			
			if ( flCaptureProgress > 0.0 )
			{
				// Point lost!
				iTeam = 0;
				self.pev.skin = 2; // 2 = NEUTRAL / NOT CAPPED
				
				// Fire neutral target, if any
				if ( szNeutralTarget.Length() > 0 )
					g_EntityFuncs.FireTargets( szNeutralTarget, self, self, USE_TOGGLE );
				
				// This message should display only to Crimsons
				for ( int i = 1; i <= g_Engine.maxClients; i++ )
				{
					CBasePlayer@ mPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
					
					if ( mPlayer !is null && mPlayer.IsConnected() )
					{
						if ( mPlayer.pev.targetname == 'crimson' )
							g_PlayerFuncs.ClientPrint( mPlayer, HUD_PRINTCENTER, "Hemos perdido el punto de control\n\n<" + szPointName + ">\n" );
					}
				}
				
				flCaptureProgress = 0.0; // Min clamp
				
				// Disable point giving
				flNextPoints = -1.0;
			}
		}
		
		// Slowly fade away progress, so it doesn't last forever
		if ( flCaptureProgress < 0.0 ) flCaptureProgress += 0.05;
		if ( flCaptureProgress > 0.0 ) flCaptureProgress -= 0.05;
		
		// Point giving
		if ( flNextPoints != -1.00 && g_Engine.time > flNextPoints )
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
				
				if ( iTeam == 1 ) pCustom.SetKeyvalue( "$i_extra_spiral", iSpiral + 2 );
				else if ( iTeam == 2 ) pCustom.SetKeyvalue( "$i_extra_crimson", iCrimson + 2 );
			}
			
			flNextPoints = g_Engine.time + 7.5;
		}
		
		// Think again
		self.pev.nextthink = g_Engine.time + 0.1;
	}
}

void RegisterControlPoint()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "util_controlpoint", "sys_control_point" );
}
