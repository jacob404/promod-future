// Possible getups:
// Charger clear which still incaps
// Smoker pull on a Hunter getup
// Insta-clear hunter during any getup
// Tank rock on a charger getup
// Tank punch on a charger getup
// Tank rock on a multi-charger getup
// Tank punch on a multi-charge getup

// Test:
// Charger getup -> Tank rock -> incap (off rock) -> getup when revived

#include <sourcemod>
#include <sdkhooks>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util>
#include <l4d2_direct>
new const bool:DEBUG = true;
new Handle:rockPunchFix;
#pragma semicolon 1

public Plugin:myinfo =
{
    name = "L4D2 Get-Up Fix",
    author = "Darkid",
    description = "Fixes the problem when, after completing a getup animation, you have another one.",
    version = "3.6",
    url = "https://github.com/jbzdarkid/Double-Getup"
}

public OnPluginStart() {
    rockPunchFix = CreateConVar("rock_punch_fix", "1", "When a tank punches someone who is getting up from a rock, cause them to have an extra getup.", FCVAR_PLUGIN);
    
    HookEvent("round_start", round_start);
    HookEvent("tongue_grab", smoker_land);
    HookEvent("tongue_release", smoker_clear);
    HookEvent("pounce_stopped", hunter_clear);
    HookEvent("charger_impact", multi_charge);
    HookEvent("charger_carry_end", charger_land_instant);
    HookEvent("charger_pummel_start", charger_land);
    HookEvent("charger_pummel_end", charger_clear);
    HookEvent("player_incapacitated", player_incap);
    HookEvent("revive_success", player_revive);
    InitSurvivorModelTrie(); // Not necessary, but speeds up IdentifySurvivor() calls.
}

// Coach, Nick, Rochelle, Ellis, Louis, Zoey, Bill, Francis
new tankGetupAnim[8] = {630, 630, 638, 635, 538, 547, 538, 541};

enum PlayerState {
    UPRIGHT = 0,
    INCAPPED,
    SMOKED,
    HUNTER_GETUP,
    INSTACHARGED,
    CHARGED, // 5
    CHARGER_GETUP,
    MULTI_CHARGED,
    TANK_PUNCH_FLY,
    TANK_PUNCH_GETUP,
    TANK_PUNCH_FIX, // 10
    TANK_ROCK_GETUP,
}

new pendingGetups[8] = 0; // This is used to track the number of pending getups. The collective opinion is that you should have at most 1.
new interrupt[8] = false; // If the player was getting up, and that getup is interrupted. This alows us to break out of the GetupTimer loop.
new currentSequence[8] = 0; // Kept to track when a player changes sequences, i.e. changes animations.
new PlayerState:playerState[8] = PlayerState:UPRIGHT; // Since there are multiple sequences for each animation, this acts as a simpler way to track a player's state.

// If the player is in any of the getup states.
public bool:isGettingUp(any:survivor) {
    switch (playerState[survivor]) {
    case (PlayerState:HUNTER_GETUP):
        return true;
    case (PlayerState:CHARGER_GETUP):
        return true;
    case (PlayerState:MULTI_CHARGED):
        return true;
    case (PlayerState:TANK_PUNCH_GETUP):
        return true;
    case (PlayerState:TANK_ROCK_GETUP):
        return true;
    }
    return false;
}

// Used to check for tank rocks on players getting up from a charge.
public OnClientPostAdminCheck(client) {
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public round_start(Handle:event, const String:name[], bool:dontBroadcast) {
    for (new survivor=0; survivor<8; survivor++) {
        playerState[survivor] = PlayerState:UPRIGHT;
    }
}

// If a player is smoked while getting up from a hunter, the getup is interrupted.
public smoker_land(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "victim"));
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return;
    if (playerState[survivor] == PlayerState:HUNTER_GETUP) {
        interrupt[survivor] = true;
    }
}

// If a player is cleared from a smoker, they should not have a getup.
public smoker_clear(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "victim"));
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return;
    if (playerState[survivor] == PlayerState:INCAPPED) return;
    playerState[survivor] = PlayerState:UPRIGHT;
    _CancelGetup(client);
}

// If a player is cleared from a hunter, they should have 1 getup.
public hunter_clear(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "victim"));
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return;
    if (playerState[survivor] == PlayerState:INCAPPED) return;
    // If someone gets cleared WHILE they are otherwise getting up, they double-getup.
    if (isGettingUp(survivor)) {
        pendingGetups[survivor]++;
        return;
    }
    playerState[survivor] = PlayerState:HUNTER_GETUP;
    _GetupTimer(client);
}

// If a player is impacted during a charged, they should have 1 getup.
public multi_charge(Handle:event, const String:name[], bool:dontBroadcast) {
    new SurvivorCharacter:survivor = IdentifySurvivor(GetClientOfUserId(GetEventInt(event, "victim")));
    if (survivor == SC_NONE) return;
    if (playerState[survivor] == PlayerState:INCAPPED) return;
    playerState[survivor] = PlayerState:MULTI_CHARGED;
}

// If a player is cleared from a charger, they should have 1 getup.
public charger_land_instant(Handle:event, const String:name[], bool:dontBroadcast) {
    new SurvivorCharacter:survivor = IdentifySurvivor(GetClientOfUserId(GetEventInt(event, "victim")));
    if (survivor == SC_NONE) return;
    // If the player is incapped when the charger lands, they will getup after being revived.
    if (playerState[survivor] == PlayerState:INCAPPED) {
        pendingGetups[survivor]++;
    }
    playerState[survivor] = PlayerState:INSTACHARGED;
}

public charger_land(Handle:event, const String:name[], bool:dontBroadcast) {
    new SurvivorCharacter:survivor = IdentifySurvivor(GetClientOfUserId(GetEventInt(event, "victim")));
    if (survivor == SC_NONE) return;
    if (playerState[survivor] == PlayerState:INCAPPED) return;
    playerState[survivor] = PlayerState:CHARGED;
}

// If a player is cleared from a charger, they should have 1 getup.
public charger_clear(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "victim"));
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return;
    if (playerState[survivor] == PlayerState:INCAPPED) return;
    playerState[survivor] = PlayerState:CHARGER_GETUP;
    _GetupTimer(client);
}

// If a player is incapped, mark that down. This will interrupt their animations, if they have any.
public player_incap(Handle:event, const String:name[], bool:dontBroadcast) {
    new SurvivorCharacter:survivor = IdentifySurvivor(GetClientOfUserId(GetEventInt(event, "userid")));
    if (survivor == SC_NONE) return;
    // If the player is incapped when the charger lands, they will getup after being revived.
    if (playerState[survivor] == PlayerState:INSTACHARGED) {
        pendingGetups[survivor]++;
    }
    playerState[survivor] = PlayerState:INCAPPED;
}

// When a player is picked up, they should have 0 getups.
public player_revive(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "subject"));
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return;
    playerState[survivor] = PlayerState:UPRIGHT;
    _CancelGetup(client);
}

// A catch-all to handle damage that is not associated with an event. I use this over player_hurt because it ignores godframes.
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
    new SurvivorCharacter:survivor = IdentifySurvivor(victim);
    if (survivor == SC_NONE) return;
    decl String:weapon[32];
    GetEdictClassname(inflictor, weapon, sizeof(weapon));
    if (strcmp(weapon, "weapon_tank_claw") == 0) {
        if (playerState[survivor] == PlayerState:CHARGER_GETUP) {
            interrupt[survivor] = true;
        } else if (playerState[survivor] == PlayerState:MULTI_CHARGED) {
            pendingGetups[survivor]++;
        }
        
        if (playerState[survivor] == PlayerState:TANK_ROCK_GETUP) {
            playerState[survivor] = PlayerState:TANK_PUNCH_FIX;
        } else {
            playerState[survivor] = PlayerState:TANK_PUNCH_FLY;
            // Watches and waits for the survivor to enter their getup animation. It is possible to skip the fly animation, so this can't be tracked by state-based logic.
            CreateTimer(0.04, TankGetupTimer, victim, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        }
    } else if (strcmp(weapon, "tank_rock") == 0) {
        if (playerState[survivor] == PlayerState:CHARGER_GETUP) {
            interrupt[survivor] = true;
        } else if (playerState[survivor] == PlayerState:MULTI_CHARGED) {
            pendingGetups[survivor]++;
        }
        playerState[survivor] = PlayerState:TANK_ROCK_GETUP;
        _GetupTimer(victim);
    }
    return;
}

public Action:TankGetupTimer(Handle:timer, any:client) {
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return Plugin_Stop;
    if (playerState[survivor] != PlayerState:TANK_PUNCH_FLY) return Plugin_Stop;
    if (GetEntProp(client, Prop_Send, "m_nSequence") != tankGetupAnim[survivor]) return Plugin_Continue;
    playerState[survivor] = PlayerState:TANK_PUNCH_GETUP;
    _GetupTimer(client);
    return Plugin_Stop;
}

_GetupTimer(client) {
    CreateTimer(0.04, GetupTimer, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}
public Action:GetupTimer(Handle:timer, any:client) {
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return Plugin_Stop;
    if (currentSequence[survivor] == 0) {
        if (DEBUG) PrintToChatAll("[Getup] Player %d is getting up...", survivor);
        currentSequence[survivor] = GetEntProp(client, Prop_Send, "m_nSequence");
        pendingGetups[survivor]++;
        return Plugin_Continue;
    } else if (interrupt[survivor]) {
        if (DEBUG) PrintToChatAll("[Getup] Player %d's getup was interrupted!", survivor);
        interrupt[survivor] = false;
        currentSequence[survivor] = 0;
        return Plugin_Stop;
    }
    
    if (currentSequence[survivor] == GetEntProp(client, Prop_Send, "m_nSequence")) {
        return Plugin_Continue;
    } else if (playerState[survivor] == PlayerState:TANK_PUNCH_FIX && GetConVarBool(rockPunchFix)) {
        if (DEBUG) PrintToChatAll("[Getup] Rock-Punch fix: Gave player %d an extra getup.", survivor);
        L4D2Direct_DoAnimationEvent(client, 96);
        playerState[survivor] = PlayerState:TANK_PUNCH_GETUP;
        currentSequence[survivor] = 0;
        return Plugin_Continue;
    } else {
        if (DEBUG) PrintToChatAll("[Getup] Player %d finished getting up.", survivor);
        playerState[survivor] = PlayerState:UPRIGHT;
        pendingGetups[survivor]--;
        // After a player finishes getting up, cancel any remaining getups.
        _CancelGetup(client);
        return Plugin_Stop;
    }
}

_CancelGetup(client) {
    CreateTimer(0.04, CancelGetup, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}
public Action:CancelGetup(Handle:timer, any:client) {
    new SurvivorCharacter:survivor = IdentifySurvivor(client);
    if (survivor == SC_NONE) return Plugin_Stop;
    if (pendingGetups[survivor] <= 0) {
        pendingGetups[survivor] = 0;
        currentSequence[survivor] = 0;
        return Plugin_Stop;
    }
    if (DEBUG) LogMessage("[Getup] Canceled extra getup for player %d.", survivor);
    pendingGetups[survivor]--;
    SetEntPropFloat(client, Prop_Send, "m_flCycle", 1000.0); // Jumps to frame 1000 in the animation, effectively skipping it.
    return Plugin_Continue;
}
