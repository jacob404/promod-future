#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))

new bool:g_bIsSewers = false;

public Plugin:myinfo = 
{
    name = "No Mercy 3 Ladder Fix",
    author = "Jacob",
    description = "Blocks players getting incapped from full hp on the ladder.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
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
	new iPounceVictim = GetEntProp(victim, Prop_Send, "m_pounceAttacker");
	new iJockeyVictim = GetEntProp(victim, Prop_Send, "m_jockeyAttacker");
	
	if(iPounceVictim <= 0 && iJockeyVictim <= 0) {
		return Plugin_Continue;
	}
	
	if(!g_bIsSewers){
		return Plugin_Continue;
	}
	
	if(IS_VALID_SURVIVOR(victim) && damage > 30.0 && damagetype == DMG_FALL)
	{
		damage = 30.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}