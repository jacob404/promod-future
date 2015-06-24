#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>

#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3
 
#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == 3)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_VALID_INFECTED(%1)   (IS_VALID_INGAME(%1) && IS_INFECTED(%1))
 
new infectedDamageGiven[MAXPLAYERS + 1];
new preTankPerm[MAXPLAYERS + 1];
new postTankPerm[MAXPLAYERS + 1];
new bool:isTankInPlay = false;
 
public Plugin:myinfo =
{
        name = "Damage During Tank",
        author = "Error",
        description = "Announce damage dealt to survivors by infected during tanks",
        version = "0.1"
};
 
public OnPluginStart()
{
        HookEvent("round_end", Event_RoundEnd);
        HookEvent("tank_spawn", Event_TankSpawn);
        HookEvent("player_death", Event_PlayerDeath);
}
 
public OnClientPutInServer(client)
{
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
 
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damageType)
{
        new incap = GetEntProp(victim, Prop_Send, "m_isIncapacitated");
        if(!isTankInPlay) return Plugin_Continue;
        if(!IS_SURVIVOR(victim)) return Plugin_Continue;
        if(incap != 0) return Plugin_Continue;
		
        infectedDamageGiven[victim] += RoundFloat(damage);
        return Plugin_Continue;
}
 
public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
        if(isTankInPlay == true)
        {
          PrintInfectedDamage();
        }
        isTankInPlay = false;
        ResetClientTracking();
}
 
public Event_TankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
        isTankInPlay = true;
        for(new client = 1; client <= MaxClients; client++)
        {
                if(IS_SURVIVOR(client))
                {
                        preTankPerm[client] = GetClientHealth(client);
                }
        }
}

ResetClientTracking()
{
        for (new client = 1; client <= MaxClients; client++)
        {
                infectedDamageGiven[client] = 0;
                preTankPerm[client] = 0;
                postTankPerm[client] = 0;
        }
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (isTankInPlay)
	{
		new String:sVictimName[8];
		GetEventString(event, "victimname", sVictimName, sizeof(sVictimName));
		if (StrEqual(sVictimName, "Tank")){
			isTankInPlay = false;
			PrintInfectedDamage();
		}
	}
}
 
PrintInfectedDamage()
{
        CPrintToChatAll("Damage dealt to survivors:");
        for(new client = 1; client <= MaxClients; client++)
        {
                if(IS_SURVIVOR(client))
                {
                        postTankPerm[client] = GetClientHealth(client);
                        new tempPerm = preTankPerm[client] - postTankPerm[client];
                        new tempDmg = infectedDamageGiven[client];
                        CPrintToChatAll("{olive}%i {default}[{green}%i perm{default}]: {lightgreen}%N", tempDmg, tempPerm, client);
                }
        }
}

/*
stock PrintToInfected(const String:Message[], any:... )
{
    decl String:sPrint[256];
    VFormat(sPrint, sizeof(sPrint), Message, 2);
 
    for (new i = 1; i <= MaxClients; i++) {
        if (!IS_VALID_INFECTED(i)) { continue; }
 
        CPrintToChat(i, "\x01%s", sPrint);
    }
}
*/