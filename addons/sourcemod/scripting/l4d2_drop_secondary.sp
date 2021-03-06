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
#include <sdkhooks>
#include <l4d2_weapon_stocks>

new g_PlayerSecondaryWeapons[MAXPLAYERS + 1];

public Plugin:myinfo =
{
	name        = "L4D2 Drop Secondary",
	author      = "Jahze, Visor",
	version     = "2.0",
	description = "Survivor players will drop their secondary weapon when they die",
	url         = "https://github.com/Attano/Equilibrium"
};

public OnPluginStart() 
{
	HookEvent("round_start", EventHook:OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_use", OnPlayerUse, EventHookMode_Post);
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
}

public OnRoundStart() 
{
	for (new i = 0; i <= MAXPLAYERS; i++) 
	{
		g_PlayerSecondaryWeapons[i] = -1;
	}
}

public Action:OnPlayerUse(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndex(client)) 
	{
		new weapon = GetPlayerWeaponSlot(client, _:L4D2WeaponSlot_Secondary);
		if (IsSecondary(weapon))
		{
			g_PlayerSecondaryWeapons[client] = (weapon == -1 ? weapon : EntIndexToEntRef(weapon));
		}
	}
	return Plugin_Continue;
}

public Action:OnBotSwap(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new bot = GetClientOfUserId(GetEventInt(event, "bot"));
	new player = GetClientOfUserId(GetEventInt(event, "player"));
	if (IsClientIndex(bot) && IsClientIndex(player)) 
	{
		if (StrEqual(name, "player_bot_replace")) 
		{
			g_PlayerSecondaryWeapons[bot] = g_PlayerSecondaryWeapons[player];
			g_PlayerSecondaryWeapons[player] = -1;
		}
		else 
		{
			g_PlayerSecondaryWeapons[player] = g_PlayerSecondaryWeapons[bot];
			g_PlayerSecondaryWeapons[bot] = -1;
		}
	}
	return Plugin_Continue;
}

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsSurvivor(client)) 
	{
		new weapon = EntRefToEntIndex(g_PlayerSecondaryWeapons[client]);
		if (IdentifyWeapon(weapon) != WEPID_NONE && client == GetWeaponOwner(weapon)) 
		{
			SDKHooks_DropWeapon(client, weapon);
		}
	}
	return Plugin_Continue;
}

bool:IsSecondary(weapon)
{
	new WeaponId:wepid = IdentifyWeapon(weapon);
	return (wepid == WEPID_PISTOL || wepid == WEPID_PISTOL_MAGNUM || wepid == WEPID_MELEE);
}

GetWeaponOwner(weapon)
{
	return GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
}

bool:IsClientIndex(client)
{
	return (client > 0 && client <= MaxClients);
}

bool:IsSurvivor(client)
{
	return (IsClientIndex(client) && IsClientInGame(client) && GetClientTeam(client) == 2);
}
