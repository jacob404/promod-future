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

new bool:g_bIsBridge = false;
new bool:g_bIsRealTank = true;
new g_iTankCount = 0;


public Plugin:myinfo = 
{
    name = "Bridge Escape Fix",
    author = "Jacob",
    description = "Kills the unlimited tank spawns on parish finale.",
    version = "1.3",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("tank_spawn", Event_TankSpawn);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c5m5_bridge"))
    {
        g_bIsBridge = true;
    }
    else
    {
        g_bIsBridge = false;
    }
    g_iTankCount = 0;
}

public Event_TankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new tank = GetClientOfUserId(GetEventInt(event, "userid"));
    if(g_bIsRealTank)
    {
        g_iTankCount++;
        g_bIsRealTank = false;
        CreateTimer(5.0, TankSpawnTimer);
    }
    if(g_bIsBridge && g_iTankCount >= 3) ForcePlayerSuicide(tank);
}

public Action:TankSpawnTimer(Handle:timer)
{
    g_bIsRealTank = true;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    g_iTankCount = 0;
}
