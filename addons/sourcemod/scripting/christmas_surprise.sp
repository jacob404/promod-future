#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <colors>

new bool:AllowJingle = true;
new bool:JingleCooldown = false;
new bool:SurvivorSnow = false;
new bool:InfectedSnow = false;

public Plugin:myinfo =
{
	name = "Christmas Surprise",
	author = "Jacob",
	description = "Happy Holidays",
	version = "1.0",
	url = "https://github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	RegConsoleCmd("sm_jingle", PlayMusic_Cmd, "Starts a christmas jingle.");
	RegConsoleCmd("sm_unjingle", StopMusic_Cmd, "Stops music clientside.");
	RegConsoleCmd("sm_nosnow", KillSnow_Cmd, "Calls a vote to disable snow.");
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public OnMapStart()
{
	PrecacheSound("music/flu/jukebox/all_i_want_for_xmas.wav");
	CreateTimer(0.5, MakeSnow);
}

public Action:MakeSnow(Handle:timer)
{
	new iSnow = -1;
	while ((iSnow = FindEntityByClassname(iSnow , "func_precipitation")) != INVALID_ENT_REFERENCE) AcceptEntityInput(iSnow, "Kill");
	iSnow = -1;
	iSnow = CreateEntityByName("func_precipitation");
	if (iSnow != -1)
	{
		decl String:sMap[64], Float:vMins[3], Float:vMax[3], Float:vBuff[3];
		GetCurrentMap(sMap, 64);
		Format(sMap, sizeof(sMap), "maps/%s.bsp", sMap);
		PrecacheModel(sMap, true);
		DispatchKeyValue(iSnow, "model", sMap);
		DispatchKeyValue(iSnow, "preciptype", "3");
		GetEntPropVector(0, Prop_Data, "m_WorldMaxs", vMax);
		GetEntPropVector(0, Prop_Data, "m_WorldMins", vMins);
		SetEntPropVector(iSnow, Prop_Send, "m_vecMins", vMins);
		SetEntPropVector(iSnow, Prop_Send, "m_vecMaxs", vMax);
		vBuff[0] = vMins[0] + vMax[0];
		vBuff[1] = vMins[1] + vMax[1];
		vBuff[2] = vMins[2] + vMax[2];
		TeleportEntity(iSnow, vBuff, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iSnow);
		ActivateEntity(iSnow);
	}
}

public OnRoundIsLive()
{
	for (new i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && !IsFakeClient(i))
	StopSound(i, SNDCHAN_AUTO, "music/flu/jukebox/all_i_want_for_xmas.wav");
	AllowJingle = false;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	AllowJingle = true;
	CreateTimer(0.7, MakeSnow);
	SurvivorSnow = false;
	InfectedSnow = false;	
}

public Action:MusicTimer(Handle:timer)
{
	JingleCooldown = false;
}

public Action:PlayMusic_Cmd(client, args)
{
	if(AllowJingle && !JingleCooldown)
	{
		EmitSoundToAll("music/flu/jukebox/all_i_want_for_xmas.wav", _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
		PrintToChatAll("Happy Holidays. Music will stop when round goes live. You can use !unjingle to stop it locally any time.");
		CreateTimer(212.0, MusicTimer);
		JingleCooldown = true;
	}
}

public Action:StopMusic_Cmd(client, args)
{
	StopSound(client, SNDCHAN_AUTO, "music/flu/jukebox/all_i_want_for_xmas.wav");
}

public Action:KillSnow_Cmd(client, args)
{
	new Team = GetClientTeam(client);
	if(Team == 2 && SurvivorSnow == false)
	{
		SurvivorSnow = true;
		if(InfectedSnow == false)
		{
			CPrintToChatAll("Survivors have voted to disable snow. Infected must use !nosnow to confirm.");
		}
	}
	else if(Team == 3 && InfectedSnow == false)
	{
		InfectedSnow = true;
		if(SurvivorSnow == false)
		{
			CPrintToChatAll("Infected have voted to disable snow. Survivors must use !nosnow to confirm.");
		}
	}
	else if(Team == 1)
	{
		PrintToChat(client, "Spectators do not have a say in holiday affairs!");
	}
	if(SurvivorSnow == true && InfectedSnow == true)
	{
		new iSnow = -1;
		while ((iSnow = FindEntityByClassname(iSnow , "func_precipitation")) != INVALID_ENT_REFERENCE) AcceptEntityInput(iSnow, "Kill");
	}
}