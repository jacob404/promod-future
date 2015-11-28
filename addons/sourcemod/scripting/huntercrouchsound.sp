#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <l4d2_direct>

#define HUNTER       3
#define MAX_HUNTERSOUND         6
#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == 3)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_INFECTED(%1)   (IS_VALID_INGAME(%1) && IS_INFECTED(%1))

new const String: sHunterSound[MAX_HUNTERSOUND + 1][] =
{
  "player/hunter/voice/idle/hunter_stalk_01.wav",
	"player/hunter/voice/idle/hunter_stalk_04.wav",
	"player/hunter/voice/idle/hunter_stalk_05.wav",
	"player/hunter/voice/idle/hunter_stalk_06.wav",
	"player/hunter/voice/idle/hunter_stalk_07.wav",
	"player/hunter/voice/idle/hunter_stalk_08.wav",
	"player/hunter/voice/idle/hunter_stalk_09.wav"
};

new bool:isHunter[MAXPLAYERS];

public Plugin:myinfo = 
{
    name = "Hunter Crouch Sounds",
    author = "High Cookie",
    description = "Forces silent but crouched hunters to emitt sounds",
    version = "",
    url = ""
};

public OnPluginStart()
{
   HookEvent("player_spawn",Event_PlayerSpawn,              EventHookMode_Post);
   HookEvent("player_death", Event_PlayerDeath);
   HookEvent("bot_player_replace", Event_BotPlayerReplace);
}

public OnMapStart()
{
    for (new i = 0; i <= MAX_HUNTERSOUND; i++)
    {
        PrefetchSound(sHunterSound[i]);
        PrecacheSound(sHunterSound[i], true);
    }
}

public Action: Event_PlayerSpawn( Handle:event, const String:name[], bool:dontBroadcast )
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( !IS_VALID_INFECTED(client) ) { return Plugin_Continue; }
    
    new zClass = GetEntProp(client, Prop_Send, "m_zombieClass");
    if (zClass == HUNTER)
	{
		isHunter[client] = true;
		CreateTimer(2.0, HunterCrouchTracking, client, TIMER_REPEAT);
	}
	return Plugin_Continue;
}

public Action:HunterCrouchTracking(Handle:timer, any:client) 
{
	if (GetClientButtons(client) == IN_DUCK){ return Plugin_Continue; }
	new ducked = GetEntProp(client, Prop_Send, "m_bDucked");
	if (ducked)
	{
		new rndPick = GetRandomInt(0, MAX_HUNTERSOUND);
		EmitSoundToAll(sHunterSound[rndPick], client, SNDCHAN_VOICE);
	}
	if (!isHunter[client]) {return Plugin_Stop;}
	return Plugin_Continue;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new victim = GetEventInt(event, "userid");
	new client = GetClientOfUserId(victim);
	isHunter[client] = false;
}

public Action:Event_BotPlayerReplace(Handle:event, const String:name[], bool:dontBroadcast) 
{
    	new player = GetEventInt(event, "player");
	new client = GetClientOfUserId(player);
	isHunter[client] = false;
}
