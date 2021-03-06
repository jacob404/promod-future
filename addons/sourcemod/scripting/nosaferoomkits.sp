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
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "0.1.1"

new Float:SurvivorStart[3]

public Plugin:myinfo = 
{
	name = "No Safe Room Medkits",
	author = "Blade",
	description = "Removes Safe Room Medkits",
	version = PLUGIN_VERSION,
	url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart()
{
	CreateConVar("nokits_version", PLUGIN_VERSION,"No Safe Room Medkits Version",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY)
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post)
	//Look up what game we're running,
	decl String:game[64]
	GetGameFolderName(game, sizeof(game))
	//and don't load if it's not L4D2.
	if (!StrEqual(game, "left4dead2", false)) SetFailState("Plugin supports Left 4 Dead 2 only.")
}

//On every round,
public Action:Event_RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	//if we're running a versus game,
	new String:GameMode[32]
	GetConVarString(FindConVar("mp_gamemode"), GameMode, 32)
	if (StrContains(GameMode, "versus", false) != -1)
	{
		//find where the survivors start so we know which medkits to replace,
		FindSurvivorStart()
		//and replace the medkits with pills.
		ReplaceMedkits()
	}
}

public FindSurvivorStart()
{
	new EntityCount = GetEntityCount()
	new String:EdictClassName[128]
	new Float:Location[3]
	//Search entities for either a locked saferoom door,
	for (new i = 0; i <= EntityCount; i++)
	{
		if (IsValidEntity(i))
		{
			GetEdictClassname(i, EdictClassName, sizeof(EdictClassName))
			if ((StrContains(EdictClassName, "prop_door_rotating_checkpoint", false) != -1) && (GetEntProp(i, Prop_Send, "m_bLocked")==1))
			{
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", Location)
				SurvivorStart = Location
				return
			}
		}
	}
	//or a survivor start point.
	for (new i = 0; i <= EntityCount; i++)
	{
		if (IsValidEntity(i))
		{
			GetEdictClassname(i, EdictClassName, sizeof(EdictClassName))
			if (StrContains(EdictClassName, "info_survivor_position", false) != -1)
			{
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", Location)
				SurvivorStart = Location
				return
			}
		}
	}
}

public ReplaceMedkits()
{
	new EntityCount = GetEntityCount()
	new String:EdictClassName[128]
	new Float:NearestMedkit[3]
	new Float:Location[3]
	//Look for the nearest medkit from where the survivors start,
	for (new i = 0; i <= EntityCount; i++)
	{
		if (IsValidEntity(i))
		{
			GetEdictClassname(i, EdictClassName, sizeof(EdictClassName))
			if (StrContains(EdictClassName, "weapon_first_aid_kit", false) != -1)
			{
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", Location)
				//If NearestMedkit is zero, then this must be the first medkit we found.
				if ((NearestMedkit[0] + NearestMedkit[1] + NearestMedkit[2]) == 0.0)
				{
					NearestMedkit = Location
					continue
				}
				//If this medkit is closer than the last medkit, record its location.
				if (GetVectorDistance(SurvivorStart, Location, false) < GetVectorDistance(SurvivorStart, NearestMedkit, false)) NearestMedkit = Location
			}
		}
	}
	//then remove the kits
	for (new i = 0; i <= EntityCount; i++)
	{
		if (IsValidEntity(i))
		{
			GetEdictClassname(i, EdictClassName, sizeof(EdictClassName))
			if (StrContains(EdictClassName, "weapon_first_aid_kit", false) != -1)
			{
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", Location)
				if (GetVectorDistance(NearestMedkit, Location, false) < 400)
				{			
					AcceptEntityInput(i, "Kill")
				}
			}
		}
	}
}
