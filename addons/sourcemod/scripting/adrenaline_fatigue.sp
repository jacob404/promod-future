#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))

public Plugin:myinfo = 
{
    name = "adren",
    author = "Jacob",
    description = ".",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	HookEvent("adrenaline_use", Event_AdrenalineUsed);
	adren_buff_duration = CreateConVar("adren_buff_duration", "10", "How long does the adrenaline buff last?");
	adren_debuff_duration = CreateConVar("adren_debuff_duration", "10", "How long should the adrenaline debuff last?");
}

public Event_AdrenalineUsed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Float:BuffDuration = GetConVarFloat("adren_buff_duration");
	new client = GetClientOfUserId("userid");
	CreateTimer(BuffDuration, ApplyDebuff, client);
}

public Action:ApplyDebuff(Handle:timer, any:client)
{
	new Float:DebuffDuration = GetConVarFloat("adren_debuff_duration");
	Reduce move speed
	Increase fatigue
	CreateTimer(DebuffDuration, RemoveDebuff, client);
}

public Action:RemoveDebuff(Handle:timer, any:client)
{
	new CurrentHealth = GetClientHealth(client);
	if(CurrentHealth == 1)
	{
	80
	}
	else if(CurrentHealth > 1 && < 40)
	{
	150
	}
	else
	{
	220
	}
}
