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

public Plugin:myinfo = 
{
    name = "Custom Boss Spawns",
    author = "Jacob",
    description = "Allows for fully customizable boss spawns.",
    version = "0.1",
    url = "zzz"
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
	
	else if(g_iCustomWitchThisRound != 0)
	{
		block vanilla witch spawns
		CreateWitchEntity();
	}
}

public CreateTankEntity()
{
	new TankEntity = CreateEntityByName("info_zombie_spawn");
	decl Float:pos[3] = g_vTankPos;
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
	g_iCustomTanksThisRound = 0;
	g_iCustomWitchesThisRound = 0;
	
	if (g_kBSData == INVALID_HANDLE) {return false;}
    
	new String: mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
    
	if (KvJumpToKey(g_kBSData, mapname))
	{
		// TONS OF DATA
		g_iCustomTanksThisRound = KvGetNum(g_kBSData, "customtanks", 0);
		g_iCustomWitchesThisRound = KvGetNum(g_kBSData, "customwitches", 0);
		
		new TankChanceTotal;
		
		for(new i = 1, i++, i <= g_iCustomTanksThisRound){
			new String:posholder[16] = "tankpos";
			StrCat(posholder, sizeOf(posholder), IntToString(i));
			array = KvGetVector(g_kBSData, posholder, 0 0 0);
			
			new String:percentholder[16] = "tankpercent";
			StrCat(percentholder, sizeOf(percentholder), IntToString(i));
			TankPercent[i] = KvGetNum(g_kBSData, percentholder, 0);
			
			new String:chanceholder[16] = "tankchance";
			StrCat(chanceholder, sizeOf(chanceholder), IntToString(i));
			TankChance[i] = KvGetNum(g_kBSData, chanceholder, 0);
			
			TankChanceTotal += TankChance[i];
		}
		
		new WitchChanceTotal;
		
		for(new i = 1, i++, i <= g_iCustomWitchesThisRound){
			new String:posholder[16] = "witchpos";
			StrCat(posholder, sizeOf(posholder), IntToString(i));
			array = KvGetVector(g_kBSData, posholder, 0 0 0);
			
			new String:percentholder[16] = "witchpercent";
			StrCat(percentholder, sizeOf(percentholder), IntToString(i));
			WitchPercent[i] = KvGetNum(g_kBSData, percentholder, 0);
			
			new String:chanceholder[16] = "witchchance";
			StrCat(chanceholder, sizeOf(chanceholder), IntToString(i));
			WitchChance[i] = KvGetNum(g_kBSData, chanceholder, 0);
			
			WitchChanceTotal += WitchChance[i];
		}
		
        
		if (g_iCustomTanksThisRound != 0)
		{
			if(TankChanceTotal == 100){
				new tankselection = GetRandomInt(1, 100);
				new temptankchance2 = TankChance1 + TankChance2;
				new temptankchance3 = temptankchance2 + TankChance3;
				new temptankchance4 = temptankchance3 + TankChance4;
				new temptankchance5 = temptankchance4 + TankChance5;
				
				if(tankselection <= TankChance1){
					g_iTankPercent = TankPercent1;
					g_vTankPos = TankPos1;
				}
				
				else if(tankselection <= temptankchance2){
					g_iTankPercent = TankPercent2;
					g_vTankPos = TankPos2;
				}
				
				else if(tankselection <= temptankchance3){
					g_iTankPercent = TankPercent3;
					g_vTankPos = TankPos3;
				}
				
				else if(tankselection <= temptankchance4){
					g_iTankPercent = TankPercent4;
					g_vTankPos = TankPos4;
				}
				
				else if(tankselection <= temptankchance5){
					g_iTankPercent = TankPercent5;
					g_vTankPos = TankPos5;
				}
			}
			
			else if(TankChanceTotal > 100){
				PrintToServer("Tank chance greater than 100! Someone messed up!");
			}
			
			else{
				new tempnum = 100;
				new missingnum = tempnum - TankChanceTotal;
				TankChance1 += missingnum;
				PrintToServer("Tank chance less than 100! Adding missing chance to tank 1");
			}
			
        }
		
		if (g_iCustomWitchesThisRound != 0)
		{
			
		}

		return true;
	}
    
	return false;
}
