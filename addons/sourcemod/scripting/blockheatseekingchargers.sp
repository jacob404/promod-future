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
/* -------------------CHANGELOG--------------------
 1.2
 - Implemented new method of blocking charger`s auto-aim, now it just continues charging instead of stopping the attack (thanks to dcx2)

 1.1
 - Fixed possible non-changer infected detecting as heatseeking charger

 1.0
 - Initial release
^^^^^^^^^^^^^^^^^^^^CHANGELOG^^^^^^^^^^^^^^^^^^^^ */



#include <sourcemod>
new IsInCharge[MAXPLAYERS + 1] = false;

#define PL_VERSION "1.2"

public Plugin:myinfo =
{
	name = "Blocks heatseeking chargers",
	version = PL_VERSION,
	author = "sheo",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart()
{
	HookEvent("player_bot_replace", BotReplacesPlayer);
	HookEvent("charger_charge_start", Event_ChargeStart);
	HookEvent("charger_charge_end", Event_ChargeEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	CreateConVar("l4d2_block_heatseeking_chargers_version", PL_VERSION, "Block heatseeking chargers fix version", FCVAR_PLUGIN | FCVAR_NOTIFY);
}

public Event_ChargeStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    IsInCharge[GetClientOfUserId(GetEventInt(event, "userid"))] = true;
}

public Event_ChargeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    IsInCharge[GetClientOfUserId(GetEventInt(event, "userid"))] = false;
}

public Action:BotReplacesPlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "player"));
	if (IsInCharge[client])
	{
		//SetEntityMoveType(GetClientOfUserId(GetEventInt(event, "bot")), MOVETYPE_NONE); //Old method, by me
		new bot = GetClientOfUserId(GetEventInt(event, "bot"));
		SetEntProp(bot, Prop_Send, "m_fFlags", GetEntProp(bot, Prop_Send, "m_fFlags") | FL_FROZEN); //New method, by dcx2
		IsInCharge[client] = false;
	}
}

public Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	IsInCharge[GetClientOfUserId(GetEventInt(event, "userid"))] = false;
}

public Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	IsInCharge[GetClientOfUserId(GetEventInt(event, "userid"))] = false;
}
