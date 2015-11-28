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
#include <left4downtown>

new bool:isJockey[MAXPLAYERS + 1] = false;

public Plugin:myinfo = 
{
    name = "Musical Jockeys",
    author = "Jacob",
    description = "Prevents jockeys being able to spawn without making any noise.",
    version = "1.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public OnMapStart()
{
	PrecacheSound("music/bacteria/jockeybacterias.wav");
}

public L4D_OnEnterGhostState(client)
{
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 5)
    {
        isJockey[client] = true;
    }
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (IsValidPlayer(client) && GetClientTeam(client) == 3 && isJockey[client])
    {
        EmitSoundToAll("music/bacteria/jockeybacterias.wav", _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
    }
    isJockey[client] = false;
}

bool:IsValidPlayer(client)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    if (IsFakeClient(client)) return false;
    return true;
}
