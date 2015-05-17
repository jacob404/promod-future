#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new bool:blockSpam[MAXPLAYERS + 1] = false;

public Plugin:myinfo = 
{
    name = "Death Cam Skip Fix",
    author = "Jacob",
    description = "Blocks players skipping their death cam",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event,"userid"));
    blockSpam[client] = true;
    CreateTimer(8.0, RemoveSpamBlock, client);
}

public Action:RemoveSpamBlock(Handle:timer, any:client)
{
    blockSpam[client] = false;
    PrintToChatAll("Spam block ended.");
}

bool:OnPlayerRunCmd(client, buttons)
{
    if(!IsValidClient(client) || (GetClientTeam(client) != 3)){return false;}
    if(!(buttons & IN_JUMP) || !(buttons & IN_ATTACK)){return false;}
    if(!blockSpam[client]){return false;}
    SpammerinoBlockerino(client, 0);
    return true;
}

SpammerinoBlockerino(client, char)
{
    PrintToChatAll("Spam blocked.");
    return Plugin_Handled;
}

stock bool:IsValidClient(client, bool:nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}