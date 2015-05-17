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