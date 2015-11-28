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

/* This is the "safe zone" around the tank spawn */
#define MIN_BOSS_VARIANCE (0.2)
#define DEBUG 0

#include <sourcemod>
#include <sdktools>
#include <l4d2_direct>
#include <l4d2lib>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>
#include <left4downtown>

public Plugin:myinfo =
{
	name = "Witch and Tankifier!",
	author = "CanadaRox",
	version = "1",
	description = "Sets a tank and witch spawn point on every map with a 0.2 safety zone around tank",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
};

new Handle:g_hVsBossBuffer;
new Handle:g_hVsBossFlowMax;
new Handle:g_hVsBossFlowMin;
new Handle:hStaticTankMaps;
new Handle:hStaticWitchMaps;

public OnPluginStart()
{
	g_hVsBossBuffer = FindConVar("versus_boss_buffer");
	g_hVsBossFlowMax = FindConVar("versus_boss_flow_max");
	g_hVsBossFlowMin = FindConVar("versus_boss_flow_min");

	hStaticTankMaps = CreateTrie();
	hStaticWitchMaps = CreateTrie();

#if !DEBUG
	HookEvent("round_start", RoundStartEvent, EventHookMode_PostNoCopy);
#endif

	RegServerCmd("static_witch_map", StaticWitch_Command);
	RegServerCmd("static_tank_map", StaticTank_Command);
	RegServerCmd("reset_static_maps", Reset_Command);

	RegAdminCmd("sm_setwitch", SetWitch_Command, ADMFLAG_BAN);
	RegAdminCmd("sm_settank", SetTank_Command, ADMFLAG_BAN);

#if DEBUG
	RegConsoleCmd("sm_doshit", DoShit_Cmd);
#endif
}

public Action:StaticWitch_Command(args)
{
	decl String:mapname[64];
	GetCmdArg(1, mapname, sizeof(mapname));
	SetTrieValue(hStaticWitchMaps, mapname, true);
#if DEBUG
	PrintToChatAll("Added %s", mapname);
#endif
}

public Action:StaticTank_Command(args)
{
	decl String:mapname[64];
	GetCmdArg(1, mapname, sizeof(mapname));
	SetTrieValue(hStaticTankMaps, mapname, true);
#if DEBUG
	PrintToChatAll("Added %s", mapname);
#endif
}

public Action:Reset_Command(args)
{
	ClearTrie(hStaticWitchMaps);
	ClearTrie(hStaticTankMaps);
}

#if !DEBUG
public RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(0.5, AdjustBossFlow);
}
#endif

#if DEBUG
public Action:DoShit_Cmd(client, args)
{
	PrintToChatAll("Doing shit!");
	CreateTimer(0.5, AdjustBossFlow);
}
#endif

public Action:SetWitch_Command(client, args)
{
	decl String:buffer[8];
	GetCmdArg(1, buffer, sizeof(buffer));
	new Float:fWitchFlow = StringToFloat(buffer);
	L4D2Direct_SetVSWitchFlowPercent(0, fWitchFlow);
	L4D2Direct_SetVSWitchFlowPercent(1, fWitchFlow);
	PrintToChatAll("[SM] Witch Spawn forced to %f by %N", fWitchFlow, client);
}

public Action:SetTank_Command(client, args)
{
	decl String:buffer[8];
	GetCmdArg(1, buffer, sizeof(buffer));
	new Float:fTankFlow = StringToFloat(buffer);
	L4D2Direct_SetVSTankFlowPercent(0, fTankFlow);
	L4D2Direct_SetVSTankFlowPercent(1, fTankFlow);
	PrintToChatAll("[SM] Tank Spawn forced to %f by %N", fTankFlow, client);
}

public Action:AdjustBossFlow(Handle:timer)
{
	if (InSecondHalfOfRound()) return;

	decl String:sCurMap[64];
	decl dummy;
	GetCurrentMap(sCurMap, sizeof(sCurMap));

	new Float:fCvarMinFlow = GetConVarFloat(g_hVsBossFlowMin);
	new Float:fCvarMaxFlow = GetConVarFloat(g_hVsBossFlowMax);

	new Float:fTankFlow = -1.0;

	if (!GetTrieValue(hStaticTankMaps, sCurMap, dummy))
	{
#if DEBUG
		PrintToChatAll("Not static tank map");
#endif
		new Float:fMinBanFlow = L4D2_GetMapValueInt("tank_ban_flow_min", -1) / 100.0;
		new Float:fMaxBanFlow = L4D2_GetMapValueInt("tank_ban_flow_max", -1) / 100.0;
		new Float:fBanRange = fMaxBanFlow - fMinBanFlow;
		if (fMinBanFlow > 0 && fMinBanFlow < fCvarMinFlow)
		{
			fBanRange -= (fCvarMinFlow - fMinBanFlow);
		}

		fTankFlow = GetRandomFloat(fCvarMinFlow, fCvarMaxFlow - fBanRange);
#if DEBUG
		PrintToChatAll("fTankFlow_pre: %f", fTankFlow);
#endif
		if (fTankFlow > fMinBanFlow)
		{
			fTankFlow += fBanRange;
		}
#if DEBUG
		PrintToChatAll("fTankFlow_post: %f", fTankFlow);
#endif
		L4D2Direct_SetVSTankToSpawnThisRound(0, true);
		L4D2Direct_SetVSTankToSpawnThisRound(1, true);
		L4D2Direct_SetVSTankFlowPercent(0, fTankFlow);
		L4D2Direct_SetVSTankFlowPercent(1, fTankFlow);
	}
	else
	{
		L4D2Direct_SetVSTankToSpawnThisRound(0, false);
		L4D2Direct_SetVSTankToSpawnThisRound(1, false);
#if DEBUG
		PrintToChatAll("Static tank map");
#endif
	}

	if (!GetTrieValue(hStaticWitchMaps, sCurMap, dummy))
	{
#if DEBUG
		PrintToChatAll("Not static witch map");
#endif
		new iMinWitchFlow = L4D2_GetMapValueInt("witch_flow_min", -1);
		new iMaxWitchFlow = L4D2_GetMapValueInt("witch_flow_max", -1);
		new Float:fMinWitchFlow = iMinWitchFlow == -1 ? fCvarMinFlow : iMinWitchFlow / 100.0;
		new Float:fMaxWitchFlow = iMaxWitchFlow == -1 ? fCvarMaxFlow : iMaxWitchFlow / 100.0;
		new Float:witchFlowRange = fMaxWitchFlow - fMinWitchFlow;
		new bool:adjustFlow = fTankFlow > 0 && fTankFlow > fMinWitchFlow && fTankFlow < fMaxWitchFlow;
		if (adjustFlow)
		{
			witchFlowRange -= MIN_BOSS_VARIANCE;
		}
		new Float:fWitchFlow = GetRandomFloat(fMinWitchFlow, fMinWitchFlow + witchFlowRange);
#if DEBUG
		PrintToChatAll("fWitchFlow_pre: %f", fWitchFlow);
#endif
		if (adjustFlow && (fTankFlow - MIN_BOSS_VARIANCE/2) < fWitchFlow)
		{
			fWitchFlow += MIN_BOSS_VARIANCE;
		}
#if DEBUG
		PrintToChatAll("fWitchFlow_post: %f", fWitchFlow);
#endif
		L4D2Direct_SetVSWitchToSpawnThisRound(0, true);
		L4D2Direct_SetVSWitchToSpawnThisRound(1, true);
		L4D2Direct_SetVSWitchFlowPercent(0, fWitchFlow);
		L4D2Direct_SetVSWitchFlowPercent(1, fWitchFlow);
	}
	else
	{
		L4D2Direct_SetVSWitchToSpawnThisRound(0, false);
		L4D2Direct_SetVSWitchToSpawnThisRound(1, false);
#if DEBUG
		PrintToChatAll("Static witch map");
#endif
	}
}

stock Float:GetTankFlow(round)
{
	return L4D2Direct_GetVSTankFlowPercent(round) - Float:GetConVarInt(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance();
}

stock Float:GetWitchFlow(round)
{
	return L4D2Direct_GetVSWitchFlowPercent(round) - Float:GetConVarInt(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance();
}
