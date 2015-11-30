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
#include <left4downtown> // min v0.5.7
#include <readyup>

enum L4D2Team
{
	L4D2Team_None = 0,
	L4D2Team_Spectator,
	L4D2Team_Survivor,
	L4D2Team_Infected
};

public Plugin:myinfo =
{
	name = "L4D2 Caster Addons Manager",
	author = "Visor, darkid",
	description = "Allows casters to join the server with their addons on",
	version = "1.3",
	url = "https://github.com/Attano/Equilibrium"
};

new Handle:sv_cheats;

public OnPluginStart()
{
	sv_cheats = FindConVar("sv_cheats");
	HookEvent("player_team", OnTeamChange);
}

public Action:L4D2_OnClientDisableAddons(const String:SteamID[])
{
	return IsIDCaster(SteamID) ? Plugin_Handled : Plugin_Continue;
}

public OnTeamChange(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0 || client > MaxClients) return;
	if (!IsClientInGame(client)) return;
	if (IsFakeClient(client)) return;
	if (IsClientCaster(client)) {
		if (L4D2Team:GetEventInt(event, "team") != L4D2Team_Spectator) {
			CreateTimer(1.0, SpecClient, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		SendConVarValue(client, sv_cheats, "1");
	} else {
		SendConVarValue(client, sv_cheats, "0");
	}
}

public OnPluginEnd() {
	for (new client=1; client<=MaxClients; client++) {
		if (!IsClientInGame(client)) continue;
		if (IsFakeClient(client)) return;
		SendConVarValue(client, sv_cheats, "0");
	}
}

public Action:SpecClient(Handle:timer, any:client)
{
	PrintToChat(client, "\x01<\x05Cast\x01> Unregister from casting first before playing.");
	PrintToChat(client, "\x01<\x05Cast\x01> Use \x04!notcasting");
	ChangeClientTeam(client, _:L4D2Team_Spectator);
}
