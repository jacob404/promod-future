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
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <readyup>

new bool:LiveDistance = false;
new Handle:distance_reset_time;
new Float:ResetTime = 8.0;

public Plugin:myinfo = 
{
    name = "Live Distance Points",
    author = "Jacob",
    description = "Resets distance points periodically to give more accurate scoring.",
    version = "1.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("door_close", Event_DoorClose);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_death", Event_PlayerDeath);
    distance_reset_time = CreateConVar("distance_reset_time", "5.0", "How often should we reset distance points? Min 1, Max 30", FCVAR_PLUGIN, true, 1.0, true, 30.0);
}

public OnRoundIsLive()
{
    ResetTime = GetConVarFloat(distance_reset_time);
    LiveDistance = true;
    CreateTimer(ResetTime, ResetDistance);
}

public Action:ResetDistance(Handle:timer)
{
    if(LiveDistance == true)
    {
        for (new i = 0; i < 4; i++)
        {
            GameRules_SetProp("m_iVersusDistancePerSurvivor", 0, _, i + 4 * GameRules_GetProp("m_bAreTeamsFlipped"));
        }
        CreateTimer(ResetTime, ResetDistance);
    }
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event,"userid"));
    if(GetClientTeam(client) == 2) LiveDistance = false;
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    LiveDistance = false;
}

public Action:Event_DoorClose(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(GetEventBool(event, "checkpoint")) LiveDistance = false;
}
