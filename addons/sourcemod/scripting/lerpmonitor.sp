#pragma semicolon 1
#include <sourcemod>

#define CVAR_FLAGS 			FCVAR_PLUGIN
#define PLUGIN_VERSION 		"1.0"

#define STEAMID_SIZE 		32
#define L4D_TEAM_SPECTATE 1

static const ARRAY_STEAMID = 0;
static const ARRAY_LERP = 1;
static const ARRAY_CHANGES = 2;
static const ARRAY_COUNT = 3;

static Handle:arrayLerps;
static Handle:cVarReadyUpLerpChanges;
static Handle:cVarAllowedLerpChanges;
static Handle:cVarLerpChangeSpec;
static Handle:cVarMinLerp;
static Handle:cVarMaxLerp;

static Handle:cVarMinUpdateRate;
static Handle:cVarMaxUpdateRate;
static Handle:cVarMinInterpRatio;
static Handle:cVarMaxInterpRatio;

static bool:isFirstHalf = true;
static bool:isMatchLife = true;
static Handle:cvarL4DReadyEnabled = INVALID_HANDLE;
static Handle:cvarL4DReadyBothHalves = INVALID_HANDLE;

public Plugin:myinfo = {
	name = "LerpMonitor++",
	author = "ProdigySim, Die Teetasse, vintik",
	description = "Keep track of players' lerp settings",
	version = PLUGIN_VERSION,
	url = "https://bitbucket.org/vintik/various-plugins"
};

public OnPluginStart() {

	cVarMinUpdateRate = FindConVar("sv_minupdaterate");
	cVarMaxUpdateRate = FindConVar("sv_maxupdaterate");
	cVarMinInterpRatio = FindConVar("sv_client_min_interp_ratio");
	cVarMaxInterpRatio = FindConVar("sv_client_max_interp_ratio");

	
	cvarL4DReadyEnabled = FindConVar("l4d_ready_enabled");
	cvarL4DReadyBothHalves = FindConVar("l4d_ready_both_halves");
	
	cVarAllowedLerpChanges = CreateConVar("sm_allowed_lerp_changes", "1", "Allowed number of lerp changes for a half", CVAR_FLAGS);
	cVarLerpChangeSpec = CreateConVar("sm_lerp_change_spec", "1", "Move to spectators on exceeding lerp changes count?", CVAR_FLAGS);
	cVarReadyUpLerpChanges = CreateConVar("sm_readyup_lerp_changes", "1", "Allow lerp changes during ready-up", CVAR_FLAGS);
	cVarMinLerp = CreateConVar("sm_min_lerp", "0.000", "Minimum allowed lerp value", CVAR_FLAGS);
	cVarMaxLerp = CreateConVar("sm_max_lerp", "0.067", "Maximum allowed lerp value", CVAR_FLAGS);
	
	RegConsoleCmd("sm_lerps", Lerps_Cmd, "List the Lerps of all players in game", CVAR_FLAGS);
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_team", OnTeamChange);
	
	// create array
	arrayLerps = CreateArray(ByteCountToCells(STEAMID_SIZE));
	// process current players
	for (new client = 1; client < MaxClients+1; client++) {	
		if (!IsClientInGame(client) || IsFakeClient(client)) continue;
		ProcessPlayerLerp(client);
	}
}

public OnMapStart() {
	if ((cvarL4DReadyEnabled!=INVALID_HANDLE) && (GetConVarBool(cvarL4DReadyEnabled))) {
		isMatchLife = false;
	}
	else {
		isMatchLife = true;
	}
}

public OnMapEnd() {
	isFirstHalf = true;
	ClearArray(arrayLerps);
}

public OnClientSettingsChanged(client) {
	if (IsValidEntity(client) && !IsFakeClient(client)) {
		ProcessPlayerLerp(client);
	}
}


public OnTeamChange(Handle:event, String:name[], bool:dontBroadcast)
{
    if (GetEventInt(event, "team") != L4D_TEAM_SPECTATE)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (client > 0)
		{
			if (IsClientInGame(client) && !IsFakeClient(client))
			{
				CreateTimer(0.1, OnTeamChangeDelay, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
    }
}

public Action:OnTeamChangeDelay(Handle:timer, any:client)
{
	ProcessPlayerLerp(client);
	return Plugin_Handled;
}

public Action:OnRoundIsLive() {
	isMatchLife = true;
}
 
public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	// little delay for other round end used modules
	CreateTimer(0.5, Timer_RoundEndDelay);
}

public Action:Timer_RoundEndDelay(Handle:timer) {
	isFirstHalf = false;
	
	if ((cvarL4DReadyBothHalves!=INVALID_HANDLE) && (GetConVarBool(cvarL4DReadyBothHalves))) {
		isMatchLife = false;
	}
}

stock bool:IsFirstHalf() {
	return isFirstHalf;
}

stock bool:IsMatchLife() {
	return isMatchLife;
}

stock GetClientBySteamID(const String:steamID[]) {
	decl String:tempSteamID[STEAMID_SIZE];
	
	for (new client = 1; client < MaxClients+1; client++) {
		if (!IsClientInGame(client)) continue;
		GetClientAuthString(client, tempSteamID, STEAMID_SIZE);
		
		if (StrEqual(steamID, tempSteamID)) {
			return client;
		}
	}
	
	return -1;
}

public Action:Lerps_Cmd(client, args) {
	new clientID, index;
	decl Float:lerp;
	decl String:steamID[STEAMID_SIZE];
	
	for (new i = 0; i < (GetArraySize(arrayLerps) / ARRAY_COUNT); i++) {
		index = (i * ARRAY_COUNT);
		
		GetArrayString(arrayLerps, index + ARRAY_STEAMID, steamID, STEAMID_SIZE);
		clientID = GetClientBySteamID(steamID);
		lerp = GetArrayCell(arrayLerps, index + ARRAY_LERP);
		
		if (clientID != -1 && GetClientTeam(clientID) != L4D_TEAM_SPECTATE) {
			ReplyToCommand(client, "%N [%s]: %.01f", clientID, steamID, lerp*1000);
		}
	}
	
	return Plugin_Handled;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	// delete change count for second half
	if (!IsFirstHalf()) {
		for (new i = 0; i < (GetArraySize(arrayLerps) / ARRAY_COUNT); i++) {
			SetArrayCell(arrayLerps, (i * ARRAY_COUNT) + ARRAY_CHANGES, 0);
		}
	}
}

ProcessPlayerLerp(client) {	
	// get lerp
	new Float:newLerpTime = GetLerpTime(client);
	// set lerp for fixing differences between server and client with cl_inter_ratio 0
	SetEntPropFloat(client, Prop_Data, "m_fLerpTime", newLerpTime);
	// check lerp first
	if (GetClientTeam(client) == L4D_TEAM_SPECTATE) return;
		
	if ((FloatCompare(newLerpTime, GetConVarFloat(cVarMinLerp)) == -1) || (FloatCompare(newLerpTime, GetConVarFloat(cVarMaxLerp)) == 1)) {
		
		//PrintToChatAll("%N's lerp changed to %.01f", client, newLerpTime*1000);
		PrintToChatAll("%N was moved to spectators for lerp %.01f!", client, newLerpTime*1000);
		ChangeClientTeam(client, L4D_TEAM_SPECTATE);
		PrintToChat(client, "Illegal lerp value (min: %.01f, max: %.01f)",
					GetConVarFloat(cVarMinLerp)*1000, GetConVarFloat(cVarMaxLerp)*1000);
		// nothing else to do
		return;
	}
	// Get steamid and index
	decl String:steamID[STEAMID_SIZE];
	GetClientAuthString(client, steamID, STEAMID_SIZE);
	new index = FindStringInArray(arrayLerps, steamID);
	
	if (index != -1) {
		new Float:currentLerpTime = GetArrayCell(arrayLerps, index + ARRAY_LERP);
	
		// no change?
		if (currentLerpTime == newLerpTime) return;
		
		// Midgame?
		if (IsMatchLife() || !GetConVarBool(cVarReadyUpLerpChanges)) {
			new count = GetArrayCell(arrayLerps, index + ARRAY_CHANGES)+1;
			new max = GetConVarInt(cVarAllowedLerpChanges);
			PrintToChatAll("\x01%N's lerp changed from %.01f to %.01f [%s%d\x01/%d changes]", client, currentLerpTime*1000, newLerpTime*1000, ((count > max)?"\x04":""), count, max);
		
			if (GetConVarBool(cVarLerpChangeSpec) && (count > max)) {
				
				PrintToChatAll("%N was moved to spectators (illegal lerp change)!", client);
				ChangeClientTeam(client, L4D_TEAM_SPECTATE);
				PrintToChat(client, "Illegal change of the lerp midgame! Change it back to %.01f", currentLerpTime*1000);
				// no lerp update
				return;
			}
			
			// update changes
			SetArrayCell(arrayLerps, index + ARRAY_CHANGES, count);
		}
		else {
			PrintToChatAll("%N's lerp changed from %.01f to %.01f", client, currentLerpTime*1000, newLerpTime*1000);
		}
		
		// update lerp
		SetArrayCell(arrayLerps, index + ARRAY_LERP, newLerpTime);
	}
	else {
		PrintToChatAll("%N's lerp set to %.01f", client, newLerpTime*1000);
		
		// add to array
		PushArrayString(arrayLerps, steamID);
		PushArrayCell(arrayLerps, newLerpTime);
		PushArrayCell(arrayLerps, 0);
	}
}

Float:GetLerpTime(client) {
	decl String:buffer[64];
	
	if (!GetClientInfo(client, "cl_updaterate", buffer, sizeof(buffer))) buffer = "";
	new updateRate = StringToInt(buffer);
	updateRate = RoundFloat(clamp(float(updateRate), GetConVarFloat(cVarMinUpdateRate), GetConVarFloat(cVarMaxUpdateRate)));
	
	if (!GetClientInfo(client, "cl_interp_ratio", buffer, sizeof(buffer))) buffer = "";
	new Float:flLerpRatio = StringToFloat(buffer);
	
	if (!GetClientInfo(client, "cl_interp", buffer, sizeof(buffer))) buffer = "";
	new Float:flLerpAmount = StringToFloat(buffer);	
	
	if (cVarMinInterpRatio != INVALID_HANDLE && cVarMaxInterpRatio != INVALID_HANDLE && GetConVarFloat(cVarMinInterpRatio) != -1.0 ) {
		flLerpRatio = clamp(flLerpRatio, GetConVarFloat(cVarMinInterpRatio), GetConVarFloat(cVarMaxInterpRatio) );
	}
	
	return maximum(flLerpAmount, flLerpRatio / updateRate);
}

Float:clamp(Float:in, Float:low, Float:high) {
	return in > high ? high : (in < low ? low : in);
}

Float:maximum(Float:a, Float:b) {
	return a > b ? a : b;
}