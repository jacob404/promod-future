#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new Handle:infected_fire_immunity;
new bool:inWait[MAXPLAYERS + 1] = false;

public Plugin:myinfo = 
{
    name = "SI Fire Immunity",
    author = "Jacob, darkid",
    description = "Special Infected fire damage management.",
    version = "2.2",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	infected_fire_immunity = CreateConVar("infected_fire_immunity", "0", "What type of fire immunity should infected have? 0 = None, 3 = Extinguish burns, 2 = Prevent burns, 1 = Complete immunity", FCVAR_PLUGIN, true, 0.0, true, 3.0);
	HookEvent("player_hurt",SIOnFire);
}

public SIOnFire(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!IsValidClient(client) || !(GetClientTeam(client) == 3)) return;
    
    decl String:weapon[64];
    GetEventString(event, "weapon", weapon, sizeof(weapon));
    new attacker = GetEventInt(event, "attacker");
    
    // Inferno is a molotov or gascan.
    // Attacker=0 means an entity dealt damage, i.e. a fire barrel.
    // entityflame is caused by fire bullets.
    if (strcmp(weapon, "inferno") == 0 || attacker == 0 || strcmp(weapon, "entityflame") == 0) {
        if(GetConVarInt(infected_fire_immunity) == 3) CreateTimer(1.0, Extinguish, client);
    
        if(GetConVarInt(infected_fire_immunity) <= 2) ExtinguishEntity(client);
        
        if(GetConVarInt(infected_fire_immunity) == 1)
        {
            new CurHealth = GetClientHealth(client);
            new DmgDone	= GetEventInt(event,"dmg_health");
            SetEntityHealth(client,(CurHealth + DmgDone));
        }
    }
}
 
public Action:Extinguish(Handle:timer, any:client)
{
    if(IsValidClient(client) && !inWait[client])
    {
        ExtinguishEntity(client);
        inWait[client] = true;
        CreateTimer(1.2, ExtinguishWait, client);
    }
}

public Action:ExtinguishWait(Handle:timer, any:client)
{
   if (IsValidClient(client)) inWait[client] = false;
}

stock bool:IsValidClient(client, bool:nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}
