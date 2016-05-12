#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin:myinfo =
{
    name = "L4D2 Melee and Shove Shenanigans",
    author = "Sir",
    description = "Stops Shoves slowing the Tank",
    version = "",
    url = ""
}

public Action:L4D_OnShovedBySurvivor(shover, shovee, const Float:vector[3])
{
    if (!IsSurvivor(shover) || !IsInfected(shovee)) return Plugin_Continue;
    if (IsTankOrCharger(shovee)) return Plugin_Handled;
    return Plugin_Continue;
}
 
public Action:L4D2_OnEntityShoved(shover, shovee_ent, weapon, Float:vector[3], bool:bIsHunterDeadstop)
{
    if (!IsSurvivor(shover) || !IsInfected(shovee_ent)) return Plugin_Continue;
    if (IsTankOrCharger(shovee_ent)) return Plugin_Handled;
    return Plugin_Continue;
}
 
stock bool:IsSurvivor(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}
 
stock bool:IsInfected(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3;
}

bool:IsTankOrCharger(client)  
{
    if (!IsPlayerAlive(client))
        return false;
 
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 8)
        return true;
 
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 6)
        return true;
 
    return false;
}
