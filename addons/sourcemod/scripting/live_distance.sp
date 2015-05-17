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