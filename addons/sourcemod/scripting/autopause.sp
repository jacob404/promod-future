#include <sourcemod>
#include <l4d2_direct>
#include <l4d2d_timers>

public Plugin:myinfo =
{
    name = "L4D2 Auto-pause",
    author = "Darkid, Griffin",
    description = "When a player disconnects due to crash, automatically pause the game. When they rejoin, give them a correct spawn timer.",
    version = "1.9",
    url = "https://github.com/jbzdarkid/AutoPause"
}

new Handle:enabled;
new Handle:force;
new Handle:apdebug;
new Handle:crashedPlayers;
new Handle:infectedPlayers;

public OnPluginStart() {
    // Suggestion by Nati: Disable for any 1v1
    enabled = CreateConVar("autopause_enable", "1", "Whether or not to automatically pause when a player crashes.");
    force = CreateConVar("autopause_force", "0", "Whether or not to force pause when a player crashes.");
    apdebug = CreateConVar("autopause_apdebug", "1", "Whether or not to debug information.");

    crashedPlayers = CreateTrie();
    infectedPlayers = CreateArray(64);

    HookEvent("round_start", round_start);
    HookEvent("player_team", playerTeam);
    HookEvent("player_disconnect", playerDisconnect, EventHookMode_Pre);
}


public round_start(Handle:event, const String:name[], bool:dontBroadcast) {
    ClearTrie(crashedPlayers);
    ClearArray(infectedPlayers);
}

// Handles players leaving and joining the infected team.
public playerTeam(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || client > MaxClients) return;
    decl String:steamId[64];
    GetClientAuthString(client, steamId, sizeof(steamId));
    if (strcmp(steamId, "BOT") == 0) return;
    new oldTeam = GetEventInt(event, "oldteam");
    new newTeam = GetEventInt(event, "team");

    new index = FindStringInArray(infectedPlayers, steamId);
    if (oldTeam == 3) {
        if (index != -1) RemoveFromArray(infectedPlayers, index);
        if (GetConVarBool(apdebug)) LogMessage("[AutoPause] Removed player %s from infected team.", steamId);
    }
    if (newTeam == 3) {
        decl Float:spawnTime;
        if (GetTrieValue(crashedPlayers, steamId, spawnTime)) {
            new CountdownTimer:spawnTimer = L4D2Direct_GetSpawnTimer(client);
            CTimer_Start(spawnTimer, spawnTime);
            RemoveFromTrie(crashedPlayers, steamId);
            LogMessage("[AutoPause] Player %s rejoined, set spawn timer to %f.", steamId, spawnTime);
        } else if (index == -1) {
            PushArrayString(infectedPlayers, steamId);
            if (GetConVarBool(apdebug)) LogMessage("[AutoPause] Added player %s to infected team.", steamId);
        }
    }
}

public playerDisconnect(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || client > MaxClients) return;
    decl String:steamId[64];
    GetClientAuthString(client, steamId, sizeof(steamId));
    if (strcmp(steamId, "BOT") == 0) return;

    decl String:reason[128];
    GetEventString(event, "reason", reason, sizeof(reason));
    decl String:playerName[128];
    GetEventString(event, "name", playerName, sizeof(playerName));
    decl String:timedOut[256];
    Format(timedOut, sizeof(timedOut), "%s timed out", playerName);

    if (GetConVarBool(apdebug)) LogMessage("[AutoPause] Player %s (%s) left the game: %s", playerName, steamId, reason);

    // If the leaving player crashed, pause.
    if (strcmp(reason, timedOut) == 0 || strcmp(reason, "No Steam logon") == 0) {
        if (GetConVarBool(enabled)) {
            if (GetConVarBool(force)) {
                ServerCommand("sm_forcepause");
            } else {
                FakeClientCommand(client, "sm_pause");
            }
            PrintToChatAll("[AutoPause] Player %s crashed.", playerName);
        }
    }

    // If the leaving player was on infected, save their spawn timer.
    if (FindStringInArray(infectedPlayers, steamId) != -1) {
        decl Float:timeLeft;
        new CountdownTimer:spawnTimer = L4D2Direct_GetSpawnTimer(client);
        if (spawnTimer != CTimer_Null) {
            timeLeft = CTimer_GetRemainingTime(spawnTimer);
            LogMessage("[AutoPause] Player %s left the game with %f time until spawn.", steamId, timeLeft);
            SetTrieValue(crashedPlayers, steamId, timeLeft);
        }
    }
}
