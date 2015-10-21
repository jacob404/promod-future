#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == 3)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_VALID_INFECTED(%1)   (IS_VALID_INGAME(%1) && IS_INFECTED(%1))

#define MAXSPAWNS               8

new     bool:   g_bReadyUpAvailable     = false;
new     bool:   g_bRoundIsLive          = false;

new const String: g_csSIClassName[][] =
{
    "",
    "Smoker",
    "Boomer",
    "Hunter",
    "Spitter",
    "Jockey",
    "Charger",
    "Witch",
    "Tank"
};


public Plugin:myinfo =
{
    name = "Special Infected Class Announce",
    author = "Tabun",
    description = "Report what SI classes are up when the round starts.",
    version = "0.9.2",
    url = "none"
}

public OnAllPluginsLoaded()
{
    g_bReadyUpAvailable = LibraryExists("readyup");
    g_bRoundIsLive = false;
    RegConsoleCmd("sm_spawns", PrintSpawns);
    HookEvent("player_left_start_area", RoundEnd);
    HookEvent("round_end", RoundEnd);
}
public OnLibraryRemoved(const String:name[])
{
    if ( StrEqual(name, "readyup") ) { g_bReadyUpAvailable = false; }
}
public OnLibraryAdded(const String:name[])
{
    if ( StrEqual(name, "readyup") ) { g_bReadyUpAvailable = true; }
}

public OnRoundIsLive()
{
    // announce SI classes up now
    AnnounceSIClasses(-1);
    g_bRoundIsLive = true;
}

public RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    // if no readyup, use this as the starting event
    if (!g_bReadyUpAvailable) {
        AnnounceSIClasses(-1);
        g_bRoundIsLive = true;
    }
}

public RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    g_bRoundIsLive = false;
}

public Action:PrintSpawns(client, args) {
    if (g_bRoundIsLive) return;
    AnnounceSIClasses(client);
}

// If client = -1, print to all survivors.
stock AnnounceSIClasses(client)
{
    // get currently active SI classes
    new iSpawns;
    new String:spawnList[256] = "\x01Special Infected\x04";

    for (new i = 1; i <= MaxClients && iSpawns < MAXSPAWNS; i++) {
        if (!IS_VALID_INFECTED(i)) { continue; }

        if (iSpawns == 0) {
            Format(spawnList, sizeof(spawnList), "%s: \x04%s\x01", spawnList, g_csSIClassName[GetEntProp(i, Prop_Send, "m_zombieClass")]);
        } else {
            Format(spawnList, sizeof(spawnList), "%s, \x04%s\x01", spawnList, g_csSIClassName[GetEntProp(i, Prop_Send, "m_zombieClass")]);
        }
        iSpawns++;
    }

    if (iSpawns == 0) {
        if (client == -1) {
            PrintToSurvivors("There are no special infected.");
        } else {
            PrintToChat(client, "There are no special infected.");
        }
    } else {
        Format(spawnList, sizeof(spawnList), "%s.", spawnList);
        if (client == -1) {
            PrintToSurvivors(spawnList);
        } else {
            PrintToChat(client, spawnList);
        }
    }
}

stock PrintToSurvivors(const String:Message[], any:... )
{
    decl String:sPrint[256];
    VFormat(sPrint, sizeof(sPrint), Message, 2);

    for (new i = 1; i <= MaxClients; i++) {
        if (!IS_VALID_SURVIVOR(i)) { continue; }

        PrintToChat(i, "\x01%s", sPrint);
    }
}