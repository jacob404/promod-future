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

new Handle:hCanRespawnTime;

public Plugin:myinfo =
{
        name = "Scavenge Gascan Respawn Fix",
        author = "Jacob",
        description = "Sets cans to not respawn other than on scavenge finales.",
        version = "1.0",
        url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart()
{
	hCanRespawnTime = FindConVar("scavenge_item_respawn_delay");
}

public OnMapStart()
{
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	if(StrEqual(mapname, "c6m3_port"))
	{
		SetConVarInt(hCanRespawnTime, 20);
	}
	else if(StrEqual(mapname, "c1m4_atrium"))
	{
		SetConVarInt(hCanRespawnTime, 20);
	}
	else
	{
		SetConVarInt(hCanRespawnTime, 9999);
	}
}

public OnPluginEnd()
{
	ResetConVar(hCanRespawnTime);
}
