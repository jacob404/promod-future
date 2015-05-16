#pragma semicolon 1

#include <sourcemod>
#include <left4downtown>
#include <l4d2_direct>
#include <readyup>
#include <pause>
#include <sdkhooks>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

#define DEBUG 0

enum L4D2SI 
{
    ZC_None,
    ZC_Smoker,
    ZC_Boomer,
    ZC_Hunter,
    ZC_Spitter,
    ZC_Jockey,
    ZC_Charger,
    ZC_Witch,
    ZC_Tank,
	ZC_InvalidTeam
};

new Handle:hCvarTimerStartDelay;
new Handle:hCvarHordeCountdown;
new Handle:hCvarMinProgressThreshold;

new Float:timerStartDelay;
new Float:hordeCountdown;
new Float:minProgress;
new Float:aliveSince[MAXPLAYERS + 1];
new Float:startingSurvivorCompletion;

new z_max_player_zombies;
new hordeDelayChecks;

new L4D2SI:zombieclass[MAXPLAYERS + 1];

public Plugin:myinfo = 
{
	name = "L4D2 Antibaiter",
	author = "Visor",
	description = "Makes you think twice before attempting to bait that shit",
	version = "1.2",
	url = "https://github.com/ConfoglTeam/ProMod"
};

public OnPluginStart()
{
	hCvarTimerStartDelay = CreateConVar("l4d2_antibaiter_delay", "20", "Delay in seconds before the antibait algorithm kicks in", FCVAR_PLUGIN);
	hCvarHordeCountdown = CreateConVar("l4d2_antibaiter_horde_timer", "60", "Countdown in seconds to the panic horde", FCVAR_PLUGIN);
	hCvarMinProgressThreshold = CreateConVar("l4d2_antibaiter_progress", "0.03", "Minimum progress the survivors must make to reset the antibaiter timer", FCVAR_PLUGIN);

	CreateTimer(1.0, AntibaiterThink, _, TIMER_REPEAT);

#if DEBUG
	RegConsoleCmd("sm_regsi", RegisterSI);
#endif
}

#if DEBUG
public Action:RegisterSI(client, args)
{
	OnRoundIsLive();
}
#endif

public OnConfigsExecuted()
{
	z_max_player_zombies = GetConVarInt(FindConVar("z_max_player_zombies"));
	timerStartDelay = GetConVarFloat(hCvarTimerStartDelay);
	hordeCountdown = GetConVarFloat(hCvarHordeCountdown);
	minProgress = GetConVarFloat(hCvarMinProgressThreshold);
}

public OnRoundIsLive()
{
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (!IsInfected(i)) continue;
		if (IsPlayerAlive(i))
		{
			zombieclass[i] = GetZombieClass(i);
			aliveSince[i] = GetGameTime();
		}
	}
}
	
public Action:AntibaiterThink(Handle:timer) 
{
	if (IsInReady() || IsInPause() || IsPanicEventInProgress() || L4D2Direct_GetTankCount() > 0)
	{
	#if DEBUG
		PrintToChatAll("\x03[Antibaiter DEBUG] \x04ReadyUp: \x05%d\x01, \x04Pause: \x05%d\x01, \x04active panic event: \x05%d\x01/312 %d/316 %d, \x04Tank count: \x05%d\x01", IsInReady(), IsInPause(), IsPanicEventInProgress(), LoadFromAddress(L4D2_GetCDirectorScriptedEventManager() + Address:312, NumberType_Int8), LoadFromAddress(L4D2_GetCDirectorScriptedEventManager() + Address:316, NumberType_Int8), L4D2Direct_GetTankCount());
	#endif
        return Plugin_Handled;
	}

	new eligibleZombies;
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (!IsInfected(i) || IsFakeClient(i)) continue;
		if (IsPlayerAlive(i))
		{
			zombieclass[i] = GetZombieClass(i);
			if (zombieclass[i] > ZC_None && zombieclass[i] < ZC_Witch
				&& aliveSince[i] != -1.0 && GetGameTime() - aliveSince[i] >= timerStartDelay)
			{
			#if DEBUG
				PrintToChatAll("\x03[Antibaiter DEBUG] Eligible player \x04%N\x01 is a zombieclass \x05%d\x01 alive for \x05%fs\x01", i, _:zombieclass[i], GetGameTime() - aliveSince[i]);
			#endif
				eligibleZombies++;
			}
		}
		else
		{
			aliveSince[i] = -1.0;
			hordeDelayChecks = 0;
			HideCountdown();
			StopCountdown();
		}
	}

	// 5th SI / spectator bug workaround
	if (eligibleZombies > z_max_player_zombies)
	{
	#if DEBUG
		PrintToChatAll("\x03[Antibaiter DEBUG] Spectator bug detected: \x04eligibleZombies\x01=\x05%d\x01, \x04z_max_player_zombies\x01=\x05%d\x01", eligibleZombies, z_max_player_zombies);
	#endif
		return Plugin_Continue;
	}

	if (eligibleZombies == z_max_player_zombies)
	{
		new Float:survivorCompletion = GetMaxSurvivorCompletion();
		new Float:progress = Float:survivorCompletion - Float:startingSurvivorCompletion;
		if (progress <= minProgress
			&& hordeDelayChecks >= RoundToNearest(timerStartDelay))
		{
		#if DEBUG
			PrintToChatAll("\x03[Antibaiter DEBUG] Minimum progress unsatisfied during \x05%d\x01 checks: \x04initial\x01=\x05%f\x01, \x04current\x01=\x05%f\x01, \x04progress\x01=\x05%f\x01", hordeDelayChecks, startingSurvivorCompletion, survivorCompletion, progress);
		#endif
			if (IsCountdownRunning())
			{
			#if DEBUG
				PrintToChatAll("\x03[Antibaiter DEBUG] Countdown is \x05running\x01");
			#endif
				if (HasCountdownElapsed())
				{
				#if DEBUG
					PrintToChatAll("\x03[Antibaiter DEBUG] Countdown has \x04elapsed\x01! Launching horde and resetting checks counter");
				#endif
					HideCountdown();
					LaunchHorde();
					hordeDelayChecks = 0;
				}
			}
			else
			{
			#if DEBUG
				PrintToChatAll("\x03[Antibaiter DEBUG] Countdown is \x05not running\x01. Initiating it...");
			#endif
				InitiateCountdown();
			}
		}
		else
		{
			if (hordeDelayChecks == 0)
			{
				startingSurvivorCompletion = survivorCompletion;
			}
			if (progress > minProgress)
			{
			#if DEBUG
				PrintToChatAll("\x03[Antibaiter DEBUG] Survivor progress has \x05increased\x01 beyond the minimum threshold. Resetting the algorithm...");
			#endif
				startingSurvivorCompletion = survivorCompletion;
				hordeDelayChecks = 0;
			}

			hordeDelayChecks++;
			HideCountdown();
			StopCountdown();
		}
	}
	return Plugin_Handled;
}

public L4D_OnEnterGhostState(client)
{
	zombieclass[client] = GetZombieClass(client);
	aliveSince[client] = GetGameTime();
}

/*******************************/
/** Horde/countdown functions **/
/*******************************/

InitiateCountdown()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			ShowVGUIPanel(i, "ready_countdown", _, true);
		}
	}

	CTimer_Start(CountdownPointer(), hordeCountdown);
}

bool:IsCountdownRunning()
{
	return CTimer_HasStarted(CountdownPointer());
}

bool:HasCountdownElapsed()
{
	return CTimer_IsElapsed(CountdownPointer());
}

StopCountdown()
{
	CTimer_Invalidate(CountdownPointer());
}

HideCountdown()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			ShowVGUIPanel(i, "ready_countdown", _, false);
		}
	}
}

LaunchHorde()
{
	new client = -1;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			client = i;
			break;
		}
	}
	if (client != -1)
	{
		new String:command[] = "director_force_panic_event";
		new flags = GetCommandFlags(command);
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);
		FakeClientCommand(client, command);
		SetCommandFlags(command, flags);
	}
}

CountdownTimer:CountdownPointer()
{
	return L4D2Direct_GetScavengeRoundSetupTimer();
}

/************/
/** Stocks **/
/************/

Float:GetMaxSurvivorCompletion()
{
	new Float:flow = 0.0;
	for (new i = 1; i <= MaxClients; i++)
	{
		// Prevent rushers from convoluting the logic
		if (IsSurvivor(i) && IsPlayerAlive(i) && !IsIncapped(i))
		{
			flow = MAX(flow, L4D2Direct_GetFlowDistance(i));
		}
	}
	return (flow / L4D2Direct_GetMapMaxFlowDistance());
}

bool:IsSurvivor(client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}

bool:IsInfected(client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3;
}

L4D2SI:GetZombieClass(client)
{
	return L4D2SI:GetEntProp(client, Prop_Send, "m_zombieClass");
}

bool:IsIncapped(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

// director_force_panic_event & car alarms etc.
bool:IsPanicEventInProgress()
{
	new CountdownTimer:pPanicCountdown = CountdownTimer:(L4D2_GetCDirectorScriptedEventManager() + Address:300);
	if (!CTimer_IsElapsed(pPanicCountdown))
	{
		return true;
	}
	
	if (CTimer_HasStarted(L4D2Direct_GetMobSpawnTimer()))
	{
		return RoundFloat(CTimer_GetRemainingTime(L4D2Direct_GetMobSpawnTimer())) <= 10;
	}
	
	return false;
}

stock Address:L4D2_GetCDirectorScriptedEventManager()
{
	static Address:pScriptedEventManager = Address_Null;
	if (pScriptedEventManager == Address_Null)
	{
		new offs = GameConfGetOffset(L4D2Direct_GetGameConf(), "CDirectorScriptedEventManager");
		if(offs == -1) return Address_Null;
		pScriptedEventManager = L4D2Direct_GetCDirector() + Address:offs;
		pScriptedEventManager = Address:LoadFromAddress(pScriptedEventManager , NumberType_Int32);
	}
	return pScriptedEventManager;
}