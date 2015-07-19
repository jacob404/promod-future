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

new TankPercent[5];

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
	
	if(g_bCustomTankThisRound)
	{
		block vanilla tank spawns
		CreateTankEntity();
	}
	
	else if(g_bCustomWitchThisRound)
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
	if (g_kBSData == INVALID_HANDLE) {return false;}
    
	new String: mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
    
	if (KvJumpToKey(g_kBSData, mapname))
	{
		// TONS OF DATA
		g_bCustomTankThisRound = bool: (KvGetNum(g_kBSData, "customtank", 0));
		g_bCustomWitchThisRound = bool: (KvGetNum(g_kBSData, "customwitch", 0));
		
		new TankPos1 = KvGetVector(g_kBSData, "tankpos1", 0 0 0);
		new TankPercent1 = KvGetNum(g_kBSData, "tankpercent1", 0);
		new TankChance1 = KvGetNum(g_kBSData, "tankchance1", 0);
		
		new TankPos2 = KvGetVector(g_kBSData, "tankpos2", 0 0 0);
		new TankPercent2 = KvGetNum(g_kBSData, "tankpercent2", 0);
		new TankChance2 = KvGetNum(g_kBSData, "tankchance2", 0);
		
		new TankPos3 = KvGetVector(g_kBSData, "tankpos3", 0 0 0);
		new TankPercent3 = KvGetNum(g_kBSData, "tankpercent3", 0);
		new TankChance3 = KvGetNum(g_kBSData, "tankchance3", 0);
		
		new TankPos4 = KvGetVector(g_kBSData, "tankpos4", 0 0 0);
		new TankPercent4 = KvGetNum(g_kBSData, "tankpercent4", 0);
		new TankChance4 = KvGetNum(g_kBSData, "tankchance4", 0);
		
		new TankPos5 = KvGetVector(g_kBSData, "tankpos5", 0 0 0);
		new TankPercent5 = KvGetNum(g_kBSData, "tankpercent5", 0);
		new TankChance5 = KvGetNum(g_kBSData, "tankchance5", 0);
		
		new WitchPos1 = KvGetVector(g_kBSData, "witchpos1", 0 0 0);
		new WitchPercent1 = KvGetNum(g_kBSData, "witchpercent1", 0);
		new WitchChance1 = KvGetNum(g_kBSData, "witchchance1", 0);
		
		new WitchPos2 = KvGetVector(g_kBSData, "witchpos2", 0 0 0);
		new WitchPercent2 = KvGetNum(g_kBSData, "witchpercent2", 0);
		new WitchChance2 = KvGetNum(g_kBSData, "witchchance2", 0);
		
		new WitchPos3 = KvGetVector(g_kBSData, "witchpos3", 0 0 0);
		new WitchPercent3 = KvGetNum(g_kBSData, "witchpercent3", 0);
		new WitchChance3 = KvGetNum(g_kBSData, "witchchance3", 0);
		
		new WitchPos4 = KvGetVector(g_kBSData, "witchpos4", 0 0 0);
		new WitchPercent4 = KvGetNum(g_kBSData, "witchpercent4", 0);
		new WitchChance4 = KvGetNum(g_kBSData, "witchchance4", 0);
		
		new WitchPos5 = KvGetVector(g_kBSData, "witchpos5", 0 0 0);
		new WitchPercent5 = KvGetNum(g_kBSData, "witchpercent5", 0);
		new WitchChance5 = KvGetNum(g_kBSData, "witchchance5", 0);
		
		for(new i = 1, i++, i<=5){
			new String:posholder[8] = "tankpos";
			StrCat(posholder, sizeOf(posholder), IntToString(i));
			array = KvGetVector(g_kBSData, posholder, 0 0 0);
			
			new String:percentholder[8] = "tankpercent";
			StrCat(percentholder, sizeOf(percentholder), IntToString(i));
			TankPercent[i] = KvGetNum(g_kBSData, percentholder, 0);
		}
		
		new TankChanceTotal = (TankChance1 + TankChance2 + TankChance3 + TankChance4 + TankChance5);
		new WitchChanceTotal = (WitchChance1 + WitchChance2 + WitchChance3 + WitchChance4 + WitchChance5);
        
		if (g_bCustomTankThisRound)
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
		
		if (g_bCustomWitchThisRound)
		{
			
		}

		return true;
	}
    
	return false;
}
