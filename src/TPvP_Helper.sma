/*
	Team Player vs Player: Auxilliary Scripts
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

#pragma semicolon 1

#include <amxmodx>
#include <engine>
#include <hamsandwich>

new msgSVC_TEMPENTITY;

public plugin_init()
{
	register_plugin( "TPvP Helper", "1.0", "Giegue" );
	
	msgSVC_TEMPENTITY = 23; // get_user_msgid( "SVC_TEMPENTITY" );
	
	register_clcmd( "medic", "BlockCMD" );
	register_clcmd( "grenade", "BlockCMD" );
	register_message( msgSVC_TEMPENTITY, "CustomArmorInfo" );
	
	new szMap[ 32 ];
	get_mapname( szMap, charsmax( szMap ) );
	
	if ( equali( szMap, "dmc_", 4 ) )
		RegisterHam( Ham_Player_Duck, "player", "BlockCrouch" );
}

public BlockCMD( player )
{
	// Block this command
	return PLUGIN_HANDLED;
}

public BlockCrouch( player )
{
	// Attempt to block +duck. Disable crouching
	entity_set_int( player, EV_INT_oldbuttons, entity_get_int( player, EV_INT_oldbuttons ) | IN_DUCK );
}

public CustomArmorInfo( msg_id, msg_dest, msg_entity )
{
	// Hook TE_TEXTMESSAGE's.
	if ( get_msg_arg_int( 1 ) == TE_TEXTMESSAGE )
	{
		// Monster/Player info has exactly 17 arguments, so go there
		if ( get_msg_args() == 17 )
		{
			static szMessage[ 128 ];
			get_msg_arg_string( 17, szMessage, charsmax( szMessage ) );
			
			// We need to find out if we are aiming at a player
			if ( contain( szMessage, "Player:  " ) != -1 )
			{
				// Cut out the remaining text and leave only the player name
				static szSearch[ 32 ];
				
				// Reset the var
				for ( new cursor = 0; cursor < 32; cursor++ )
				{
					szSearch[ cursor ] = 0;
				}
				
				// Now, cut out...
				for ( new cursor = 9; cursor < 42; cursor++ )
				{
					if ( szMessage[ cursor ] == '^n' )
						break;
					szSearch[ cursor - 9 ] = szMessage[ cursor ];
				}
				
				// Attempt to find client index
				static target;
				target = find_player_ex( FindPlayer_MatchName, szSearch );
				if ( target )
				{
					// FOUND IT!
					// Show custom armor on HUD info, if applicable
					if ( entity_get_float( target, EV_FL_armortype ) == 0.0 )
					{
						static szReplace[ 13 ], iArmorValue;
						
						// Get current armor level (retrieved from AS)
						iArmorValue = floatround( entity_get_float( target, EV_FL_fuser1 ), floatround_tozero );
						
						// Replace armor message
						formatex( szReplace, charsmax( szReplace ), "Armor:  %i", iArmorValue );
						replace_string( szMessage, charsmax( szMessage ), "Armor:  0", szReplace );
						
						// Send the new message
						set_msg_arg_string( 17, szMessage );
					}
				}
				else
				{
					// LOL FAIL
					format( szMessage, charsmax( szMessage ), "%s^nERR_BAD_FORMATTING", szMessage );
					set_msg_arg_string( 17, szMessage );
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}
