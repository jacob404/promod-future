#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <l4d2_skill_detect>
#include <readyup>

new Handle:g_hTankWipeCookie;
new Handle:g_hMapsMadeCookie;
new Handle:g_hMapsPlayedCookie;
new Handle:g_hBoomersPoppedCookie;

new bool:g_bIsRoundLive = true;
new bool:g_bIsTankAlive = false;
new bool:g_bIsPlayerAlive[MAXPLAYERS+1] = true;

public Plugin:myinfo =
{
	name = "Stat plugin name tbd",
	author = "Jacob",
	description = "...",
	version = "0.1",
	url = "zzz",
}

public OnPluginStart()
{
	RegConsoleCmd("sm_myaverages", ClientAverages_Cmd, "Prints some average stats to the client.");
	g_hTankWipeCookie = RegClientCookie("css_tankwipes", "xxxstats TankWipes", CookieAccess_Private);
	g_hMapsMadeCookie = RegClientCookie("css_mapsmade", "xxxstats MapsMade", CookieAccess_Private);
	g_hMapsPlayedCookie = RegClientCookie("css_mapsplayed", "xxxstats MapsPlayed", CookieAccess_Private);
	g_hBoomersPoppedCookie = RegClientCookie("css_boomerspopped", "xxxstats BoomersPopped", CookieAccess_Private);

	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("round_start", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("tank_killed", Event_TankKilled);
	HookEvent("tank_spawn", Event_TankSpawn);
	HookEvent("door_close", Event_DoorClose);
	HookEvent("finale_vehicle_leaving", Event_FinaleEscape, EventHookMode_PostNoCopy);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bIsRoundLive = true;
	for(new client = 1; client <= MAXPLAYERS; client++)
	{
		g_bIsPlayerAlive[client] = true;
	}
}

public OnRoundIsLive()
{
	for(new client = 1; client <= MAXPLAYERS; client++)
	{
		if(GetClientTeam(client) == 2)
		{
			decl String:sMapsPlayedCookie[3];
			GetClientCookie(client, g_hMapsPlayedCookie, sMapsPlayedCookie, sizeof(sMapsPlayedCookie));
			new iMapsPlayed = StringToInt(sMapsPlayedCookie);
			iMapsPlayed++;
			IntToString(iMapsPlayed, sMapsPlayedCookie, sizeof(sMapsPlayedCookie));
			SetClientCookie(client, g_hMapsPlayedCookie, sMapsPlayedCookie);
		}
	}
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bIsRoundLive = false;
	if(g_bIsTankAlive)
	{
		for (new client = 1; client <= MAXPLAYERS; client++)
		{
			if (GetEntProp(client, Prop_Send, "m_zombieClass") == 8)
			{
				decl String:sTankWipeCookie[3];
				GetClientCookie(client, g_hTankWipeCookie, sTankWipeCookie, sizeof(sTankWipeCookie));
				new iWipeCount = StringToInt(sTankWipeCookie);
				iWipeCount++;
				IntToString(iWipeCount, sTankWipeCookie, sizeof(sTankWipeCookie));
				SetClientCookie(client, g_hTankWipeCookie, sTankWipeCookie);
			}
		}
	}
}

public Event_TankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bIsTankAlive = true;
}

public Event_TankKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bIsTankAlive = false;
	new tank = GetClientOfUserId(GetEventInt(event, "userid"));
	new iWipeCount;
	if(g_bIsRoundLive)
	{
		decl String:sTankWipeCookie[3];
		iWipeCount = 0;
		IntToString(iWipeCount, sTankWipeCookie, sizeof(sTankWipeCookie));
		SetClientCookie(tank, g_hTankWipeCookie, sTankWipeCookie);
	}
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_bIsPlayerAlive[client] = false;
	if(GetClientTeam(client) == 2)
	{
		decl String:sMapsMadeCookie[3];
		new iMapsMade = 0;
		IntToString(iMapsMade, sMapsMadeCookie, sizeof(sMapsMadeCookie));
		SetClientCookie(client, g_hMapsMadeCookie, sMapsMadeCookie);
	}
}

public Action:Event_DoorClose(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(GetEventBool(event, "checkpoint") && !g_bIsRoundLive)
	{
		for (new client = 1; client <= MAXPLAYERS; client++)
		{
			if(GetClientTeam(client) == 2 && g_bIsPlayerAlive[client])
			{
				decl String:sMapsMadeCookie[3];
				GetClientCookie(client, g_hMapsMadeCookie, sMapsMadeCookie, sizeof(sMapsMadeCookie));
				new iMapsMade = StringToInt(sMapsMadeCookie);
				iMapsMade++;
				IntToString(iMapsMade, sMapsMadeCookie, sizeof(sMapsMadeCookie));
				SetClientCookie(client, g_hMapsMadeCookie, sMapsMadeCookie);
			}
		}
	}
}

public Action:Event_FinaleEscape(Handle:event, const String:name[], bool:dontBroadcast)
{
	for (new client = 1; client <= MAXPLAYERS; client++)
	{
		if(GetClientTeam(client) == 2 && g_bIsPlayerAlive[client])
		{
			decl String:sMapsMadeCookie[3];
			GetClientCookie(client, g_hMapsMadeCookie, sMapsMadeCookie, sizeof(sMapsMadeCookie));
			new iMapsMade = StringToInt(sMapsMadeCookie);
			iMapsMade++;
			IntToString(iMapsMade, sMapsMadeCookie, sizeof(sMapsMadeCookie));
			SetClientCookie(client, g_hMapsMadeCookie, sMapsMadeCookie);
		}
	}
}

public OnBoomerPop(survivor, boomer, shoveCount, Float:timeAlive)
{
	decl String:sBoomersPoppedCookie[3];
	GetClientCookie(survivor, g_hBoomersPoppedCookie, sBoomersPoppedCookie, sizeof(sBoomersPoppedCookie));
	new iBoomersPopped = StringToInt(sBoomersPoppedCookie);
	iBoomersPopped++;
	IntToString(iBoomersPopped, sBoomersPoppedCookie, sizeof(sBoomersPoppedCookie));
	SetClientCookie(survivor, g_hBoomersPoppedCookie, sBoomersPoppedCookie);
}

/*public OnSkeet()
{

}*/

public Action:ClientAverages_Cmd(client, args)
{
	decl String:sMapsPlayedCookie[3];
	GetClientCookie(client, g_hMapsPlayedCookie, sMapsPlayedCookie, sizeof(sMapsPlayedCookie));
	new iMapsPlayed = StringToInt(sMapsPlayedCookie);
	
	decl String:sMapsMadeCookie[3];
	GetClientCookie(client, g_hMapsMadeCookie, sMapsMadeCookie, sizeof(sMapsMadeCookie));
	new iMapsMade = StringToInt(sMapsMadeCookie);

	decl String:sBoomersPoppedCookie[3];
	GetClientCookie(client, g_hBoomersPoppedCookie, sBoomersPoppedCookie, sizeof(sBoomersPoppedCookie));
	new iBoomersPopped = StringToInt(sBoomersPoppedCookie);
	
	new iCompletionPercent = RoundToNearest(Float:float(iMapsMade / iMapsPlayed) * 100);
	new Float:fAveragePops = Float:float(iBoomersPopped / iMapsPlayed);

	PrintToChat(client, "You have made %i%% of the maps you have played. More stats are available in console.", iCompletionPercent);
	PrintToConsole(client, "You average %d boomer pops per map.", fAveragePops);
}
