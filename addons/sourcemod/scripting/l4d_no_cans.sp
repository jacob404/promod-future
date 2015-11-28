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
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new bool:bNoCans;
new bool:bNoPropane;
new bool:bNoOxygen;
new bool:bNoFireworks;

new Handle:cvar_noCans;
new Handle:cvar_noPropane;
new Handle:cvar_noOxygen;
new Handle:cvar_noFireworks;

static const String:CAN_GASCAN[]   = "models/props_junk/gascan001a.mdl";
static const String:CAN_PROPANE[]   = "models/props_junk/propanecanister001a.mdl";
static const String:CAN_OXYGEN[]   = "models/props_equipment/oxygentank01.mdl";
static const String:CAN_FIREWORKS[]   = "models/props_junk/explosive_box001.mdl";

public Plugin:myinfo =
{
    name        = "L4D2 Remove Cans",
    author      = "Jahze, Sir",
    version     = "0.3",
    description = "Provides the ability to remove Gascans, Propane, Oxygen Tanks and Fireworks",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart() {
    cvar_noCans = CreateConVar("l4d_no_cans", "1", "Remove Gascans?", FCVAR_PLUGIN);
    cvar_noPropane = CreateConVar("l4d_no_propane", "1", "Remove Propane Tanks?", FCVAR_PLUGIN);
    cvar_noOxygen = CreateConVar("l4d_no_oxygen", "1", "Remove Oxygen Tanks?", FCVAR_PLUGIN);
    cvar_noFireworks = CreateConVar("l4d_no_fireworks", "1", "Remove Fireworks?", FCVAR_PLUGIN);
    HookConVarChange(cvar_noCans, NoCansChange);
    HookConVarChange(cvar_noPropane, NoPropaneChange);
    HookConVarChange(cvar_noOxygen, NoOxygenChange);
    HookConVarChange(cvar_noFireworks, NoFireworksChange);
}

IsCan(iEntity) 
{
    decl String:sModelName[128];
    GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
    
    if (bool:GetEntProp(iEntity, Prop_Send, "m_isCarryable", 1))
    {
        if (StrEqual(sModelName, CAN_GASCAN, false) && bNoCans) return true;
        if (StrEqual(sModelName, CAN_PROPANE, false) && bNoPropane) return true;
        if (StrEqual(sModelName, CAN_OXYGEN, false) && bNoOxygen) return true;
        if (StrEqual(sModelName, CAN_FIREWORKS, false) && bNoFireworks) return true;
    }
    return false;
}

public Action:RoundStartHook( Handle:event, const String:name[], bool:dontBroadcast ) 
{
    CreateTimer(1.0, RoundStartNoCans);
}

public NoCansChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if (StringToInt(newValue) == 0) bNoCans = false;
    else bNoCans = true;
}

public NoPropaneChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if (StringToInt(newValue) == 0) bNoPropane = false;
    else bNoPropane = true;
}

public NoOxygenChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if (StringToInt(newValue) == 0) bNoOxygen = false;
    else bNoOxygen = true;
}

public NoFireworksChange( Handle:cvar, const String:oldValue[], const String:newValue[] ) {
    if (StringToInt(newValue) == 0) bNoFireworks = false;
    else bNoFireworks = true;
}

public Action:RoundStartNoCans( Handle:timer ) 
{
    new iEntity;
    
    while ( (iEntity = FindEntityByClassname(iEntity, "prop_physics")) != -1 ) {
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) ) {
            continue;
        }
        
        // Let's see what we got here!
        if (IsCan(iEntity)) 
        {
            AcceptEntityInput(iEntity, "Kill");
        }
    }
}
