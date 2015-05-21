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
#define IS_TANK

new bool:g_bMapHasCustomSpawns = false;
new Float:g_TankPosition[3];
new Float:g_WitchPosition[3];

public Plugin:myinfo = 
{
    name = "Custom Boss Spawns",
    author = "Jacob",
    description = "Allows for fully customizable boss spawns.",
    version = "0.1",
    url = "zzz"
}

public OnMapStart()
{
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	if(g_bMapHasCustomSpawns)
	{
		block vanilla tank spawns
		ChooseCustomSpawn(mapname);
		
	}
}

public ChooseCustomSpawn()
{
	new iTank = GetRandomInt;
	new iWitch = GetRandomInt;
	g_TankPosition = getvaluefromfile(iTank);
	g_WitchPosition = getvaluefromfile(iWitch);
}

public CreateTankEntity()
{
	new TankEntity = CreateEntityByName("info_zombie_spawn");
	decl Float:pos[3] = g_TankPosition;
	TeleportEntity(TankEntity, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(TankEntity, "targetname", "zombie_tank");
	DispatchKeyValue(TankEntity, "population", "tank");
	DispatchKeyValue(TankEntity, "offer_tank", "1");
	DispatchKeyValue(TankEntity, "angles", "0 0 0");
	DispatchSpawn(TankEntity);
	ActivateEntity(TankEntity);
	AcceptEntityInput(TankEntity, "activate");
	
}

public CreateWitchEntity()
{

}

new Float:proximity = GetMaxSurvivorCompletion() + (GetConVarFloat(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance());
new boss_proximity = RoundToNearest(GetBossProximity() * 100.0);
(proximity > 1.0 ? 1.0 : proximity);
