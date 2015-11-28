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
#include <left4downtown>

new bool:blockStumble = false;

public Plugin:myinfo = 
{
    name = "Tank Rock Stumble Block",
    author = "Jacob",
    description = "Fixes rocks disappearing if tank gets stumbled while throwing.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public Action:L4D_OnCThrowActivate()
{
    blockStumble = true;
    CreateTimer(2.0, UnblockStumble);
}

public Action:UnblockStumble(Handle:timer)
{
    blockStumble = false;
}

public Action:L4D2_OnStagger(target, source)
{
    if (GetClientTeam(target) != 3) return Plugin_Continue;
    if (GetInfectedClass(target) != 8 || !blockStumble) return Plugin_Continue;
    return Plugin_Handled;
}

GetInfectedClass(client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        return GetEntProp(client, Prop_Send, "m_zombieClass");
    }
    return -1;
}
