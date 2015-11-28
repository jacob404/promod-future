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

new Handle:hCvarMotdTitle;
new Handle:hCvarMotdUrl;
new Handle:hCvarCfgName;
new Handle:hInfoTimer;

public Plugin:myinfo =
{
	name = "Config Description",
	author = "Visor",
	description = "Displays a descriptive MOTD on desire",
	version = "0.2",
	url = "https://github.com/Attano/smplugins"
};

public OnPluginStart()
{
    hCvarMotdTitle = CreateConVar("sm_cfgmotd_title", "Confogl Nexus", "Custom MOTD title", FCVAR_PLUGIN);
    hCvarMotdUrl = CreateConVar("sm_cfgmotd_url", "http://shantisbitches.ru/confogl-nexus/", "Custom MOTD url", FCVAR_PLUGIN);
    hCvarCfgName = FindConVar("sbhm_cfgname");

    RegConsoleCmd("sm_cfg", ShowMOTD, "Show a MOTD describing the current config", FCVAR_PLUGIN);

    HookEvent("round_start", RoundStartEvent, EventHookMode_PostNoCopy);
}

public Action:RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (hInfoTimer == INVALID_HANDLE)
		hInfoTimer = CreateTimer(90.0, InfoTimer, _, TIMER_REPEAT);
}
    
public OnRoundIsLive() 
{
	if (hInfoTimer != INVALID_HANDLE)
    {
        KillTimer(hInfoTimer);
        hInfoTimer = INVALID_HANDLE;
    }
}

public Action:InfoTimer(Handle:timer)
{
    decl String:config[64];
    if (hCvarCfgName != INVALID_HANDLE)
        GetConVarString(hCvarCfgName, config, sizeof(config));
    else 
        GetConVarString(FindConVar("l4d_ready_cfg_name"), config, sizeof(config));

    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i))
        {
            PrintToChat(i, "\x04[Info]\x01 Type \x03!cfg\x01 in chat to view details about \x05%s\x01.", config);
        }
    }
}

public Action:ShowMOTD(client, args) 
{
    decl String:title[64], String:url[192];
    
    GetConVarString(hCvarMotdTitle, title, sizeof(title));
    GetConVarString(hCvarMotdUrl, url, sizeof(url));
    
    ShowMOTDPanel(client, title, url, MOTDPANEL_TYPE_URL);
}
