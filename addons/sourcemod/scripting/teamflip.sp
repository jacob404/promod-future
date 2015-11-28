/*
	SourcePawn is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2015 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
/*    
		Teamflip

   by purpletreefactory
   Credit for the idea goes to Fig
   This version was made out of convenience
   
 */
 
#include <sourcemod>
#include <sdktools>

new result_int;
new String:client_name[32]; // Used to store the client_name of the player who calls teamflip
new previous_timeC = 0; // Used for teamflip
new current_timeC = 0; // Used for teamflip
new Handle:delay_time; // Handle for the teamflip_delay cvar

public Plugin:myinfo =
{
	name = "Teamflip",
	author = "purpletreefactory, epilimic",
	description = "coinflip, but for teams!",
	version = "1.0.1.0.1.0",
	url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}
 
public OnPluginStart()
{
	delay_time = CreateConVar("teamflip_delay","-1", "Time delay in seconds between allowed teamflips. Set at -1 if no delay at all is desired.");

	RegConsoleCmd("sm_teamflip", Command_teamflip);
	RegConsoleCmd("sm_tf", Command_teamflip);
}

public Action:Command_teamflip(client, args)
{
	current_timeC = GetTime();
	
	if((current_timeC - previous_timeC) > GetConVarInt(delay_time)) // Only perform a teamflip if enough time has passed since the last one. This prevents spamming.
	{
		result_int = GetURandomInt() % 2; // Gets a random integer and checks to see whether it's odd or even
		GetClientName(client, client_name, sizeof(client_name)); // Gets the client_name of the person using the command
		
		if(result_int == 0)
			PrintToChatAll("\x01[\x05Teamflip\x01] \x03%s\x01 flipped a team and is on the \x03Survivor \x01team!", client_name); // Here {green} is actually yellow
		else
			PrintToChatAll("\x01[\x05Teamflip\x01] \x03%s\x01 flipped a team and is on the \x03Infected \x01team!", client_name);
		
		previous_timeC = current_timeC; // Update the previous time
	}
	else
	{
		PrintToConsole(client, "[Teamflip] Whoa there buddy, slow down. Wait at least %d seconds.", GetConVarInt(delay_time));
	}
	
	return Plugin_Handled;
}
