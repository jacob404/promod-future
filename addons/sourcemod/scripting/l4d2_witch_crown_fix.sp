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
#include <sdkhooks>

#define WITCH_DAMAGE_THRESHOLD 799.0

new Float:inflictedDamage[MAXPLAYERS + 1];

public Plugin:myinfo = 
{
	name = "L4D2 Witch Crown Fix",
	author = "Visor",
	description = "Fixes the Witch not dying from a perfectly aligned shotgun blast due to the random nature of the pellet spread",
	version = "1.2",
	url = "https://github.com/Attano/ProMod"
};

public OnEntityCreated(entity, const String:classname[])
{
    if (StrEqual(classname, "witch"))
    {
        SDKHook(entity, SDKHook_OnTakeDamage, OnWitchTakeDamage);
    }
}

public Action:OnWitchTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damageType, &weapon, Float:damageForce[3], Float:damagePosition[3]) 
{
	if (!IsWitch(victim) || !IsSurvivor(attacker) || IsFakeClient(attacker))
		return Plugin_Continue;

	if (IsT1Shotgun(weapon))
	{
		inflictedDamage[attacker] += damage;
		if (inflictedDamage[attacker] >= WITCH_DAMAGE_THRESHOLD)
		{
			damage = GetConVarFloat(FindConVar("z_witch_health")) - inflictedDamage[attacker] + damage;
			inflictedDamage[attacker] = 0.0;
			return Plugin_Changed;
		}
	}
	CreateTimer(0.1, ResetDamageCounter);
	return Plugin_Continue;
}

public Action:ResetDamageCounter(Handle:timer)
{
    for (new i = 1; i <= MaxClients; i++) 
	{
		inflictedDamage[i] = 0.0;
	}
}

bool:IsSurvivor(client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

bool:IsWitch(entity)
{
    if (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity))
    {
        decl String:strClassName[64];
        GetEdictClassname(entity, strClassName, sizeof(strClassName));
        return StrEqual(strClassName, "witch");
    }
    return false;
}

bool:IsT1Shotgun(weapon)
{
	decl String:classname[64];
	GetEdictClassname(weapon, classname, sizeof(classname));
	return (StrEqual(classname, "weapon_pumpshotgun") || StrEqual(classname, "weapon_shotgun_chrome"));
}