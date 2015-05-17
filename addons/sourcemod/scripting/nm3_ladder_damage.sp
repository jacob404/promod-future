#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))

new bool:g_bIsCapped[MAXCLIENTS + 1] = false;
new bool:g_bIsSewers = false;

public Plugin:myinfo = 
{
    name = "No Mercy 3 Ladder Sponge",
    author = "Jacob",
    description = "Blocks players getting incapped from full hp on the ladder.",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	HookEvent("pounce_stopped", Event_PounceEnd);
	HookEvent("lunge_pounce", Event_SurvivorPounced);
	HookEvent("jockey_ride_end", Event_RideEnd);
	HookEvent("jockey_ride", Event_SurvivorRode);
	HookEvent("charger_carry_start", Event_SurvivorCharged);
	HookEvent("charger_carry_end", Event_ChargeEnd);
	HookEvent("charger_pummel_start", Event_ChargeEnd2);
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c8m3_sewers"))
    {
        g_bIsSewers = true;
    }
    else
    {
        g_bIsSewers = false;
    }
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(g_bIsSewers && IS_VALID_SURVIVOR(victim) && damage > 30.0)
	{
		if(g_bIsCapped(victim) && damagetype == DMG_FALL || damagetype == DMG_GENERIC)
		{
			damage = 30.0;
			return Plugin_Changed;
		}
	}
}

public Event_SurvivorPounced(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = true;
}

public Event_PounceEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = false;
}

public Event_SurvivorRode(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = true;
}

public Event_RideEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = false;
}

public Event_SurvivorCharged(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = true;
}

public Event_ChargeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = false;
}

public Event_ChargeEnd2(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bIsCapped[victim] = false;
}