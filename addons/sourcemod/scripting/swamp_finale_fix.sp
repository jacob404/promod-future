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

new bool:IsPlantation = false;

public Plugin:myinfo =
{
        name = "Swamp Finale Fix",
        author = "Jacob",
        description = "Fix swamp finale breaking for 2nd team",
        version = "0.1",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart()
{
		HookEvent("round_end", Event_RoundEnd);
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c3m4_plantation"))
    {
        IsPlantation = true;
    }
    else
    {
        IsPlantation = false;
    }
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new FinaleEntity;
	while ((FinaleEntity = FindEntityByClassname(FinaleEntity, "trigger_finale")) != -1)
	{
		if(!IsValidEdict(FinaleEntity) || !IsValidEntity(FinaleEntity) || !IsPlantation) continue;
		AcceptEntityInput(FinaleEntity, "ForceFinaleStart");
	}
}
