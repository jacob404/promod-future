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
#include <l4d2_direct>
#include <l4d2lib>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>
#include <left4downtown>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))

new TankPercent[16];
new TankChance[16];
new g_iCustomTanksThisRound;
new WitchPercent[16];
new WitchChance[16];
new g_iCustomWitchesThisRound;
new g_iTankPercent;
new g_vTankPosition[3];
new g_iWitchPercent;
new g_vWitchPosition[3];

public Plugin:myinfo = 
{
    name = "Custom Boss Spawns",
    author = "Jacob",
    description = "Allows for fully customizable boss spawns.",
    version = "0.1",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}
public OnPluginStart()
{
    g_hCvarKeyValuesPath = CreateConVar(
            "sm_boss_configpath",
            "configs/bosscontrol.txt",
            "The path to the bosscontrol.txt with keyvalues for per-map boss spawn settings.",
            FCVAR_PLUGIN
        );
    
    HookConVarChange(g_hCvarKeyValuesPath, ConvarChange_KeyValuesPath);
    aTankPos = CreateArray(32);
	aWitchPos = CreateArray(32);
}

public OnPluginEnd()
{
    KV_Close();
}

public OnConfigsExecuted()
{
    KV_Load();
}

public ConvarChange_KeyValuesPath(Handle:convar, const String:oldValue[], const String:newValue[])
{
    // reload the keyvalues file
    if (g_kHIData != INVALID_HANDLE) {
        KV_Close();
    }

    KV_Load();
    KV_UpdateBossSpawnInfo();
}


public OnMapEnd()
{   
    if ( g_kBSData != INVALID_HANDLE )
    {
        KvRewind(g_kBSData);
    }
}

public OnMapStart()
{
	KV_UpdateBossSpawnInfo();
	
	if(g_iCustomTankThisRound != 0)
	{
		block vanilla tank spawns
		CreateTankEntity();
	}
	
	if(g_iCustomWitchThisRound != 0)
	{
		block vanilla witch spawns
		CreateWitchEntity();
	}
}

public CreateTankEntity()
{
	new TankEntity = CreateEntityByName("info_zombie_spawn");
	decl Float:pos[3] = g_vTankPosition;
	TeleportEntity(TankEntity, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(TankEntity, "targetname", "zombie_tank");
	DispatchKeyValue(TankEntity, "population", "tank");
	DispatchKeyValue(TankEntity, "offer_tank", "1");
	DispatchKeyValue(TankEntity, "angles", "0 0 0");
	DispatchSpawn(TankEntity);
	ActivateEntity(TankEntity);
}

public CreateWitchEntity()
{

}

public SpawnTank()
{
	AcceptEntityInput(TankEntity, "activate");
}


KV_Close()
{
    if ( g_kBSData == INVALID_HANDLE ) { return; }
    CloseHandle(g_kBSData);
    g_kBSData = INVALID_HANDLE;
}

KV_Load()
{
    decl String:sNameBuff[PLATFORM_MAX_PATH];
    GetConVarString( g_hCvarKeyValuesPath, sNameBuff, sizeof(sNameBuff) );
    BuildPath(Path_SM, sNameBuff, sizeof(sNameBuff), sNameBuff);
    
    g_kBSData = CreateKeyValues("BossSpawns");
    
    if ( !FileToKeyValues(g_kBSData, sNameBuff) )
    {
        LogError("Couldn't load CustomBossSpawn data! (file: %s)", sNameBuff);
        KV_Close();
        return;
    }
}

bool: KV_UpdateBossSpawnInfo()
{
	ClearArray(aTankPos);
	ClearArray(aWitchPos);
	g_iCustomTanksThisRound = 0;
	g_iCustomWitchesThisRound = 0;
	
	if (g_kBSData == INVALID_HANDLE) {return false;}
    
	new String: mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
    
	if (KvJumpToKey(g_kBSData, mapname))
	{
		g_iCustomTanksThisRound = KvGetNum(g_kBSData, "customtanks", 0);
		g_iCustomWitchesThisRound = KvGetNum(g_kBSData, "customwitches", 0);
		
		new TankChanceTotal;
		new TankSelection = GetRandomInt(1, 100);
		new WitchChanceTotal;
		new WitchSelection = GetRandomInt(1, 100);
		
		// TANKS
		for(new i = 1, i++, i <= g_iCustomTanksThisRound){
			new arnum = i - 1;
		
			new String:posholder[16] = "tankpos";
			StrCat(posholder, sizeOf(posholder), IntToString(i));
			new posvec[3] = KvGetVector(g_kBSData, posholder, 0 0 0);
			SetArrayArray(aTankPos, arnum, posvec);
			
			new String:percentholder[16] = "tankpercent";
			StrCat(percentholder, sizeOf(percentholder), IntToString(i));
			TankPercent[i] = KvGetNum(g_kBSData, percentholder, 0);
			
			new String:chanceholder[16] = "tankchance";
			StrCat(chanceholder, sizeOf(chanceholder), IntToString(i));
			TankChance[i] = KvGetNum(g_kBSData, chanceholder, 0);
			
			TankChanceTotal += TankChance[i];
		}
		
		if(TankChanceTotal > 100){
			PrintToServer("Tank chance greater than 100. Something is wrong!");
		}
		
		else if(TankChanceTotal < 100){
			PrintToServer("Tank chance less than 100. Something is wrong!");
			new missingnum = 100 - TankChanceTotal;
			TankChance[1] += missingnum;
		}

		for(new i = 1, i++, i <= g_iCustomTanksThisRound){
			new arnum = i - 1;
			if(TankSelection <= TankChance[i]){
				g_iTankPercent = TankPercent[i];
				GetArrayArray(aTankPos, arnum, g_vTankPosition);
			}
			TankChance[i] += TankChance[arnum];
		}
		
		
		// WITCHES
		for(new i = 1, i++, i <= g_iCustomWitchesThisRound){
			new arnum = i - 1;
		
			new String:posholder[16] = "witchpos";
			StrCat(posholder, sizeOf(posholder), IntToString(i));
			new posvec[3] = KvGetVector(g_kBSData, posholder, 0 0 0);
			SetArrayArray(aWitchPos, arnum, posvec);
			
			new String:percentholder[16] = "witchpercent";
			StrCat(percentholder, sizeOf(percentholder), IntToString(i));
			WitchPercent[i] = KvGetNum(g_kBSData, percentholder, 0);
			
			new String:chanceholder[16] = "witchchance";
			StrCat(chanceholder, sizeOf(chanceholder), IntToString(i));
			WitchChance[i] = KvGetNum(g_kBSData, chanceholder, 0);
			
			WitchChanceTotal += WitchChance[i];
		}
		
		if(WitchChanceTotal > 100){
			PrintToServer("Witch chance greater than 100. Something is wrong!");
		}
		
		else if(WitchChanceTotal < 100){
			PrintToServer("Witch chance less than 100. Something is wrong!");
			new missingnum = 100 - WitchChanceTotal;
			WitchChance[1] += missingnum;
		}

		for(new i = 1, i++, i <= g_iCustomWitchesThisRound){
			new arnum = i - 1;
			if(WitchSelection <= WitchChance[i]){
				g_iWitchPercent = WitchPercent[i];
				GetArrayArray(aWitchPos, arnum, g_vWitchPosition);
			}
			WitchChance[i] += WitchChance[arnum];
		}
		
		return true;
	}
	
	return false;
}
