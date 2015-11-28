/*
	SourcePawn is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2015 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <sourcemod>
#include <l4d2_scoremod>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util>
#pragma semicolon 1

new damageToTank[9];
new String:playerNames[9][128];
new Handle:printTankName;
new Handle:printTankDamage;
new Handle:printPlayerHB;
new bool:tankInPlay;
new tankHealth;
new lastTankHealth;
new preTankHB;
new incapOffset;

public Plugin:myinfo = {
    name = "Damage During Tank",
    author = "darkid",
    description = "Announce damage dealt during tanks",
    version = "1.4",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart() {
    HookEvent("round_start", round_start);
    HookEvent("tank_spawn", tank_spawn);
    HookEvent("player_hurt", player_hurt);
    HookEvent("player_death", tank_death);
    HookEvent("round_end", round_end);

    printTankDamage = CreateConVar("tankdamage_print", "1", "Announce damage done to tank when it dies, or on round end. If set to 2, will also print to the infected.");
    printTankName = CreateConVar("tankdamage_print_name", "1", "Print the name of the tank when it dies.");
    printPlayerHB = CreateConVar("tankdamage_print_survivor_hb", "1", "Announce damage done to survivor health bonus when the tank dies.");

    playerNames[8] = "Self";
    tankInPlay = false;
    incapOffset = FindSendPropInfo("Tank", "m_isIncapacitated");
    InitSurvivorModelTrie(); // Not necessary, but speeds up IdentifySurvivor() calls.
}

public round_start(Handle:event, const String:name[], bool:dontBroadcast) {
    for (new i=0; i<8; i++) {
        damageToTank[i] = 0;
    }
}

public tank_spawn(Handle:event, const String:name[], bool:dontBroadcast) {
    tankInPlay = true;
    tankHealth = GetConVarInt(FindConVar("z_tank_health"))*3/2; // Valve are stupid and multiple tank health by 1.5 in versus.
    lastTankHealth = tankHealth;
    preTankHB = HealthBonus();
}

public player_hurt(Handle:event, const String:name[], bool:dontBroadcast) {
    if (!tankInPlay) return;
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8 && !GetEntData(victim, incapOffset)) { // Tanks while incapped (dying animation) can still "take damage", which calls this.
        new SurvivorCharacter:survivor = IdentifySurvivor(attacker);
        if (survivor != SC_NONE) {
            damageToTank[survivor] += GetEventInt(event, "dmg_health");
        } else if (victim == attacker) {
            damageToTank[8] += GetEventInt(event, "dmg_health");
        }
        lastTankHealth = GetEventInt(event, "health");
    }
}

public tank_death(Handle:event, const String:name[], bool:dontBroadcast) {
    new tank = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!IsClientInGame(tank)) return;
    if (GetEntProp(tank, Prop_Send, "m_zombieClass") != 8) return;
    TryPrintTankDamage(tank);
}

public round_end(Handle:event, const String:name[], bool:dontBroadcast) {
    decl tank;
    for (new client=1; client<=MaxClients; client++) {
        if (!IsClientInGame(client)) continue;
        if (GetEntProp(client, Prop_Send, "m_zombieClass") == 8) {
            tank = client;
            break;
        }
    }
    TryPrintTankDamage(tank);
}

public sortTankDamage(e1, e2, const array[], Handle:handle) {
    if (damageToTank[e1] > damageToTank[e2]) {
        return -1;
    } else if (damageToTank[e1] == damageToTank[e2]) {
        return 0;
    } else /*if (damageToTank[e1] < damageToTank[e2])*/ {
        return 1;
    }
}

public TryPrintTankDamage(tank) {
    if (!tankInPlay) return;
    tankInPlay = false;

    new sortArray[sizeof(damageToTank)];
    for (new i=0; i<sizeof(sortArray); i++) {
        sortArray[i] = i;
    }

    SortCustom1D(sortArray, sizeof(sortArray), sortTankDamage);

    for (new client=1; client<MaxClients; client++) {
        if (!IsClientInGame(client)) continue;
        new SurvivorCharacter:survivor = IdentifySurvivor(client);
        if (survivor == SC_NONE) continue;
        decl String:playerName[128];
        GetClientName(client, playerName, sizeof(playerName));
        playerNames[survivor] = playerName;
    }

    if (GetConVarBool(printTankDamage)) {
        PrintDamageDealtToTank(tank, sortArray);
    }

    if (GetConVarBool(printPlayerHB)) {
        PrintHBDamageDealtToSurvivors(HealthBonus());
    }
}

PrintDamageDealtToTank(tank, sortArray[]) {
    new bool:isTankDead = (lastTankHealth <= 0);
    for (new client=1; client<=MaxClients; client++) {
        if (!IsClientInGame(client)) continue;
        if (GetConVarInt(printTankDamage) !=2 && GetClientTeam(client) == 3) continue; // Don't print survivor damage to tank to the infected team.
        if (isTankDead) {
            if (GetConVarBool(printTankName)) {
                PrintToChat(client, "[SM] Tank (\x03%N\x01) had \x05%d\x01 health remaining", tank, lastTankHealth);
            } else {
                PrintToChat(client, "[SM] Tank had \x05%d\x01 health remaining", lastTankHealth);
            }
        } else {
            if (GetConVarBool(printTankName)) {
                PrintToChat(client, "[SM] Damage dealt to tank (\x03%N\x01):", tank);
            } else {
                PrintToChat(client, "[SM] Damage dealt to tank:");
            }
        }
        for (new i=0; i<sizeof(damageToTank); i++) {
            new j = sortArray[i];
            if (damageToTank[j] == 0) continue;
            PrintToChat(client, "\x05%4d\x01 [\x04%.02f%%\x01]:\t\x03%s\x01", damageToTank[j], damageToTank[j]*100.0/tankHealth, playerNames[j]);
        }
    }
}

PrintHBDamageDealtToSurvivors(postTankHB) {
    for (new client=1; client<=MaxClients; client++) {
        if (!IsClientInGame(client)) continue;
        if (GetClientTeam(client) == 2) continue; // Don't print health bonus damage to tank to the survivor team.
        PrintToChat(client, "[SM] Damage dealt to health bonus:\t\x05%4d\x01", preTankHB-postTankHB);
    }
}
