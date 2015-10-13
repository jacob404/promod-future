#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <left4downtown>

// Force %0 to be between %1 and %2.
#define CLAMP(%0,%1,%2) (((%0) > (%2)) ? (%2) : (((%0) < (%1)) ? (%1) : (%0)))
// Linear scale %0 between %1 and %2.
#define SCALE(%0,%1,%2) CLAMP((%0-%1)/(%2-%1), 0.0, 1.0)
// Quadratic scale %0 between %1 and %2
#define SCALE2(%0,%1,%2) SCALE(%0*%0, %1*%1, %2*%2)

new Handle:hCvarSdPistolMod;
new Handle:hCvarSdDeagleMod;
new Handle:hCvarSdUziMod;
new Handle:hCvarSdMacMod;
new Handle:hCvarSdAkMod;
new Handle:hCvarSdM4Mod;
new Handle:hCvarSdScarMod;
new Handle:hCvarSdPumpMod;
new Handle:hCvarSdChromeMod;
new Handle:hCvarSdAutoMod;
new Handle:hCvarSdRifleMod;
new Handle:hCvarSdScoutMod;
new Handle:hCvarSdMilitaryMod;

new Handle:hCvarSdGunfireSi;
new Handle:hCvarSdGunfireTank;
new Handle:hCvarSdInwaterTank;
new Handle:hCvarSdInwaterSurvivor;
new Handle:hCvarSdInwaterDuringTank;
new Handle:hCvarSurvivorLimpspeed;

new bool:tankInPlay;

public Plugin:myinfo =
{
    name = "L4D2 Slowdown Control",
    author = "Visor, Sir, darkid",
    version = "2.4",
    description = "Manages the water/gunfire slowdown for both teams",
	url = "https://github.com/ConfoglTeam/ProMod"
};

public OnPluginStart()
{
    // Each of these damage values corresponds to the same amount of slowdown, from that given weapon.
    hCvarSdPistolMod = CreateConVar("l4d2_slowdown_pistol_percent", "0.0", "Pistols cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdDeagleMod = CreateConVar("l4d2_slowdown_deagle_percent", "0.1", "Deagles cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdUziMod = CreateConVar("l4d2_slowdown_uzi_percent", "0.8", "Unsilenced uzis cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdMacMod = CreateConVar("l4d2_slowdown_mac_percent", "0.8", "Silenced Uzis cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdAkMod = CreateConVar("l4d2_slowdown_ak_percent", "0.8", "AKs cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdM4Mod = CreateConVar("l4d2_slowdown_m4_percent", "0.8", "M4s cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdScarMod = CreateConVar("l4d2_slowdown_scar_percent", "0.8", "Scars cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdPumpMod = CreateConVar("l4d2_slowdown_pump_percent", "0.5", "Pump Shotguns cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdChromeMod = CreateConVar("l4d2_slowdown_chrome_percent", "0.5", "Chrome Shotguns cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdAutoMod = CreateConVar("l4d2_slowdown_auto_percent", "0.5", "Auto Shotguns cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdRifleMod = CreateConVar("l4d2_slowdown_rifle_percent", "0.1", "Hunting Rifles cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdScoutMod = CreateConVar("l4d2_slowdown_scout_percent", "0.1", "Scouts cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");
    hCvarSdMilitaryMod = CreateConVar("l4d2_slowdown_military_percent", "0.1", "Military Rifles cause this much slowdown * l4d2_slowdown_gunfire at maximum damage.");

    hCvarSdGunfireSi = CreateConVar("l4d2_slowdown_gunfire_si", "0.0", "Maxmium slowdown from gunfire for SI (-1: native slowdown; 0.0: No slowdown, 0.01-1.0: 1%%-100%% slowdown)", FCVAR_PLUGIN, true, -1.0, true, 1.0);
    hCvarSdGunfireTank = CreateConVar("l4d2_slowdown_gunfire_tank", "0.2", "Maxmium slowdown from gunfire for the Tank (-1: native slowdown; 0.0: No slowdown, 0.01-1.0: 1%%-100%% slowdown)", FCVAR_PLUGIN, true, -1.0, true, 1.0);
    hCvarSdInwaterTank = CreateConVar("l4d2_slowdown_water_tank", "-1", "Maxmium slowdown in the water for the Tank (-1: native slowdown; 0.0: No slowdown, 0.01-1.0: 1%%-100%% slowdown)", FCVAR_PLUGIN, true, -1.0, true, 1.0);
    hCvarSdInwaterSurvivor = CreateConVar("l4d2_slowdown_water_survivors", "-1", "Maxmium slowdown in the water for the Survivors (-1: native slowdown; 0.0: No slowdown, 0.01-1.0: 1%%-100%% slowdown)", FCVAR_PLUGIN, true, -1.0, true, 1.0);
    hCvarSdInwaterDuringTank = CreateConVar("l4d2_no_slowdown_during_tank", "1", "If set to 0, there will be slowdown in water during tank.");

    hCvarSurvivorLimpspeed = FindConVar("survivor_limp_health");

    HookEvent("player_hurt", PlayerHurt);
    HookEvent("tank_spawn", TankSpawn);
    HookEvent("player_death", TankDeath);
    HookEvent("round_end", RoundEnd);
    tankInPlay = false;
}

public L4D2_OnWaterMove(client) {
    if (GetEntityFlags(client) & FL_INWATER) { // L4D2_OnWaterMove can trigger while in noclip.
        if (IsSurvivor(client) && !IsLimping(client)) {
            if (GetConVarBool(hCvarSdInwaterDuringTank) && tankInPlay) {
                ApplySlowdown(client, 0.0);
            } else {
                ApplySlowdown(client, GetConVarFloat(hCvarSdInwaterSurvivor));
            }
        } else if (IsInfected(client) && IsTank(client)) {
            ApplySlowdown(client, GetConVarFloat(hCvarSdInwaterTank));
        }
    }
}

public TankSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
    if (tankInPlay) return;
    tankInPlay = true;
    if (GetConVarBool(hCvarSdInwaterDuringTank)) {
        PrintToChatAll("\x05Water Slowdown\x01 has been reduced while Tank is in play.");
    }
}
public TankDeath(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (IsInfected(client) && IsTank(client)) {
        tankInPlay = false;
        if (GetConVarBool(hCvarSdInwaterDuringTank)) {
            PrintToChatAll("\x05Water Slowdown\x01 has been restored to normal.");
        }
    }
}
public RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
    tankInPlay = false;
}

public PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!IsInfected(client)) return;
    new damage = GetEventInt(event, "dmg_health");
    decl String:weapon[64];
    GetEventString(event, "weapon", weapon, sizeof(weapon));
    new Float:scale = 1.0;
    new Float:modifier = 0.0;
    // Weapon  | Max | Min
    // Pistol  | 32  | 9
    // Deagle  | 78  | 19
    // Uzi     | 19  | 9
    // Mac     | 24  | 0 <- Deals no damage at long range.
    // AK      | 57  | 0 <- Deals no damage at long range.
    // M4      | 32  | 0
    // Scar    | 43  | 1
    // Pump    | 13  | 2
    // Chrome  | 15  | 2
    // Auto    | 19  | 2
    // Spas    | 23  | 3
    // HR      | 90  | 90 <- No fall-off
    // Scout   | 90  | 90 <- No fall-off
    // Military| 90  | 90 <- No fall-off
    // SMGs and Shotguns are using quadratic scaling, meaning that shooting long ranged is punished more harshly.
    if (strcmp(weapon, "melee") == 0) {
        // Melee damage scales with tank health, so don't bother handling it here.
    } else if (strcmp(weapon, "pistol") == 0) {
        scale = SCALE(damage, 9.0, 32.0);
        modifier = GetConVarFloat(hCvarSdPistolMod);
    } else if (strcmp(weapon, "pistol_magnum") == 0) {
        scale = SCALE(damage, 19.0, 78.0);
        modifier = GetConVarFloat(hCvarSdDeagleMod);
    } else if (strcmp(weapon, "smg") == 0) {
        scale = SCALE2(damage, 9.0, 19.0);
        modifier = GetConVarFloat(hCvarSdUziMod);
    } else if (strcmp(weapon, "smg_silenced") == 0) {
        scale = SCALE2(damage, 0.0, 24.0);
        modifier = GetConVarFloat(hCvarSdMacMod);
    } else if (strcmp(weapon, "rifle_ak47") == 0) {
        scale = SCALE2(damage, 0.0, 57.0);
        modifier = GetConVarFloat(hCvarSdAkMod);
    } else if (strcmp(weapon, "rifle") == 0) {
        scale = SCALE2(damage, 0.0, 32.0);
        modifier = GetConVarFloat(hCvarSdM4Mod);
    } else if (strcmp(weapon, "rifle_desert") == 0) {
        scale = SCALE2(damage, 1.0, 43.0);
        modifier = GetConVarFloat(hCvarSdScarMod);
    } else if (strcmp(weapon, "pumpshotgun") == 0) {
        scale = SCALE2(damage, 2.0, 13.0);
        modifier = GetConVarFloat(hCvarSdPumpMod);
    } else if (strcmp(weapon, "shotgun_chrome") == 0) {
        scale = SCALE2(damage, 2.0, 15.0);
        modifier = GetConVarFloat(hCvarSdChromeMod);
    } else if (strcmp(weapon, "autoshotgun") == 0) {
        scale = SCALE2(damage, 2.0, 19.0);
        modifier = GetConVarFloat(hCvarSdAutoMod);
    } else if (strcmp(weapon, "shotgun_spas") == 0) {
        scale = SCALE2(damage, 3.0, 23.0);
        modifier = GetConVarFloat(hCvarSdAutoMod);
    } else if (strcmp(weapon, "hunting_rifle") == 0) {
        scale = SCALE(damage, 90.0, 90.0);
        modifier = GetConVarFloat(hCvarSdRifleMod);
    } else if (strcmp(weapon, "sniper_scout") == 0) {
        scale = SCALE(damage, 90.0, 90.0);
        modifier = GetConVarFloat(hCvarSdScoutMod);
    } else if (strcmp(weapon, "sniper_military") == 0) {
        scale = SCALE(damage, 90.0, 90.0);
        modifier = GetConVarFloat(Handle:hCvarSdMilitaryMod);
    }
    // If max slowdown is 20%, and tank takes 10 damage from a chrome shotgun shell, they recieve:
    //// 1 - .5 * 0.434 * .2 = 0.9566 -> 95.6% base speed, or 4.4% slowdown.
    // If max slowdown is 20%, and tank takes 6 damage from a silenced uzi bullet, they recieve:
    //// 1 - .8 * 0.0625 * .2 = 0.99 -> 99% base speed, or 1% slowdown.
    decl Float:slowdown;
    if (IsTank(client)) {
        slowdown = 1-modifier*scale*GetConVarFloat(hCvarSdGunfireTank);
    } else {
        slowdown = 1-modifier*scale*GetConVarFloat(hCvarSdGunfireSi);
    }
    if (slowdown <= 1.0) { // If the cvar is set to -1, then the slowdown is > 1, and we should take no action.
        ApplySlowdown(client, slowdown);
    }
}

ApplySlowdown(client, Float:value) {
    if (value == -1.0) return;
    SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", value);
}

stock bool:IsSurvivor(client) {
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}

stock bool:IsInfected(client) {
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3;
}

stock bool:IsTank(client) {
    return GetEntProp(client, Prop_Send, "m_zombieClass") == 8;
}

stock bool:IsLimping(client) {
    //Assume Clientchecks and the like have been done already

    new PermHealth = GetClientHealth(client);

    new Float:buffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
    new Float:bleedTime = GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime");
    new Float:decay = GetConVarFloat(FindConVar("pain_pills_decay_rate"));

    new Float:TempHealth = CLAMP(buffer - (bleedTime * decay), 0.0, 100.0); // buffer may be negative, also if pills bleed out then bleedTime may be too large.

    return RoundToFloor(PermHealth + TempHealth) < GetConVarInt(hCvarSurvivorLimpspeed);
}