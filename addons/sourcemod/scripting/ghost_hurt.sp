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
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

new Handle:ghost_hurt_type;
new bool:g_bReadyUpAvailable = false;

public Plugin:myinfo = 
{
    name = "Ghost Hurt Management",
    author = "Jacob",
    description = "Allows for modifications of trigger_hurt_ghost",
    version = "1.4",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    ghost_hurt_type = CreateConVar("ghost_hurt_type", "0", "When should trigger_hurt_ghost be enabled? 0 = Never, 1 = On Round Start", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    HookEvent("round_start", Event_Round_Start, EventHookMode_PostNoCopy);
    RegServerCmd("sm_reset_ghost_hurt", ResetGhostHurt_Cmd, "Used to reset trigger_hurt_ghost between matches.  This should be in confogl_off.cfg or equivalent for your system");
}

public OnAllPluginsLoaded()
{
    g_bReadyUpAvailable = LibraryExists("readyup");
}
public OnLibraryRemoved(const String:name[])
{
    if ( StrEqual(name, "readyup") ) { g_bReadyUpAvailable = false; }
}
public OnLibraryAdded(const String:name[])
{
    if ( StrEqual(name, "readyup") ) { g_bReadyUpAvailable = true; }
}

public OnRoundIsLive()
{
    if(GetConVarBool(ghost_hurt_type) == true)
    {
        ModifyEntity("Enable");
    }
}

public Action: L4D_OnFirstSurvivorLeftSafeArea( client )
{   
    if (!g_bReadyUpAvailable && GetConVarBool(ghost_hurt_type) == true)
    {
        ModifyEntity("Enable");
    }
}

public Event_Round_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
    ModifyEntity("Disable");
}

public Action:ResetGhostHurt_Cmd(args)
{
    ModifyEntity("Enable");
}

ModifyEntity(String:inputName[])
{ 
    new iEntity;

    while ( (iEntity = FindEntityByClassname(iEntity, "trigger_hurt_ghost")) != -1 )
    {
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) )
        {
            continue;
        }
        AcceptEntityInput(iEntity, inputName);
    }
}
