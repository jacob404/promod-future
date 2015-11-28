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

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))

public Plugin:myinfo = 
{
    name = "adren",
    author = "Jacob",
    description = ".",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	HookEvent("adrenaline_use", Event_AdrenalineUsed);
	adren_buff_duration = CreateConVar("adren_buff_duration", "10", "How long does the adrenaline buff last?");
	adren_debuff_duration = CreateConVar("adren_debuff_duration", "10", "How long should the adrenaline debuff last?");
}

public Event_AdrenalineUsed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Float:BuffDuration = GetConVarFloat("adren_buff_duration");
	new client = GetClientOfUserId("userid");
	CreateTimer(BuffDuration, ApplyDebuff, client);
}

public Action:ApplyDebuff(Handle:timer, any:client)
{
	new Float:DebuffDuration = GetConVarFloat("adren_debuff_duration");
	Reduce move speed
	Increase fatigue
	CreateTimer(DebuffDuration, RemoveDebuff, client);
}

public Action:RemoveDebuff(Handle:timer, any:client)
{
	new CurrentHealth = GetClientHealth(client);
	if(CurrentHealth == 1)
	{
	80
	}
	else if(CurrentHealth > 1 && < 40)
	{
	150
	}
	else
	{
	220
	}
}
