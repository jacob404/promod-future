#include <sourcemod>
#include <sdkhooks>

public Plugin:myinfo =
{
    name = "L4D2 Infected Friendly Fire Disable",
    author = "ProdigySim, Don, Visor",
    description = "Disables friendly fire between infected players.",
    version = "1.3"
}

new Handle:cvar_ffblock;
new Handle:cvar_allow_tank_ff;
new Handle:cvar_block_witch_ff;

new bool:lateLoad;

public OnPluginStart()
{
    cvar_ffblock=CreateConVar("l4d2_block_infected_ff", "1", "Disable SI->SI friendly fire");
    cvar_allow_tank_ff=CreateConVar("l4d2_infected_ff_allow_tank", "0", "Do not disable friendly fire for tanks on other SI");
    cvar_block_witch_ff=CreateConVar("l4d2_infected_ff_block_witch", "0", "Disable FF towards witches");

    if(lateLoad)
    {
        for(new cl=1; cl <= MaxClients; cl++)
        {
            if(IsClientInGame(cl))
            {
                SDKHook(cl, SDKHook_OnTakeDamage, OnTakeDamage);
            }
        }
    }
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    lateLoad=late;
    return APLRes_Success;
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnEntityCreated(entity, const String:classname[])
{
    if (strcmp(classname, "witch") == 0) {
        SDKHook(entity, SDKHook_OnTakeDamage, OnWitchTakeDamage);
    }
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
    if (!GetConVarBool(cvar_ffblock)) return Plugin_Continue;
    if (!IsClientAndInGame(attacker)) return Plugin_Continue;
    if (!IsClientAndInGame(victim)) return Plugin_Continue;
    if (GetClientTeam(attacker) != 3) return Plugin_Continue;
    if (GetClientTeam(victim) != 3) return Plugin_Continue;

    if (GetConVarBool(cvar_allow_tank_ff) && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 8) {
        return Plugin_Continue;
    }
    return Plugin_Handled;
}

public Action:OnWitchTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
    if (!GetConVarBool(cvar_block_witch_ff)) return Plugin_Continue;
    if (!IsClientAndInGame(attacker)) return Plugin_Continue;
    if (GetClientTeam(attacker) != 3) return Plugin_Continue;
    return Plugin_Handled;
}

bool:IsClientAndInGame(index)
{
    return (index > 0 && index <= MaxClients && IsClientInGame(index));
}