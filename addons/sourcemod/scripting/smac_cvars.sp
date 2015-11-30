/*
    SourceMod Anti-Cheat
    Copyright (C) 2011-2013 SMAC Development Team <https://bitbucket.org/anticheat/smac/wiki/Credits>
    Copyright (C) 2007-2011 CodingDirect LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma semicolon 1

/* SM Includes */
#include <sourcemod>
#include <smac>
#undef REQUIRE_PLUGIN
#include <basecomm>
#tryinclude <updater>
#include <readyup>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC ConVar Checker",
	author = SMAC_AUTHOR,
	description = "Checks for players using exploitative cvars",
	version = SMAC_VERSION,
	url = SMAC_URL
};

/* Globals */
#define UPDATE_URL	"http://anticheat.co/smac/smac_cvars.txt"

#define MAX_CVAR_NAME_LEN 64
#define MAX_CVAR_VALUE_LEN 64
#define MAX_REQUERY_ATTEMPTS 4

enum {
	CELL_HANDLE = 0,
	CELL_NAME,
	CELL_COMPTYPE,
	CELL_ACTION,
	CELL_VALUE,
	CELL_VALUE2,
	CELL_PRIORITY,
	CELL_REPLICATING,
}

enum {
	ACTION_WARN = 0,
	ACTION_MUTE,
	ACTION_KICK,
	ACTION_BAN,
	ACTION_BAN_IF_NOT_CASTER,
}

enum {
	COMP_EQUAL = 0,
	COMP_GREATER,
	COMP_LESS,
	COMP_BOUND,
	COMP_STRING,
	COMP_NONEXIST
}

enum CVarPriority {
	Priority_High = 0,
	Priority_Medium,
	Priority_Low
}

new const String:g_sQueryResult[][] = {"Okay", "Not found", "Not valid", "Protected"};

new Handle:g_hCVarADT = INVALID_HANDLE;
new Handle:g_hCVarTrie = INVALID_HANDLE;

new Handle:g_hTimer[MAXPLAYERS+1];

new Handle:g_hCurCVarData[MAXPLAYERS+1];
new g_iADTIndex[MAXPLAYERS+1];
new g_iRequeryAttempts[MAXPLAYERS+1];

new g_iADTSize;

new bool:g_bLateLoad;
new bool:g_bPluginInit;

new bool:g_bReadyUpAvailable;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	g_bLateLoad = late;
	return APLRes_Success;
}

public OnPluginStart()
{
	LoadTranslations("smac.phrases");

	g_hCVarADT = CreateArray(64);
	g_hCVarTrie = CreateTrie();

	//- High Priority -//  Note: We kick them out before hand because we don't want to have to ban them.
	AddCVarToList("0penscript",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("aim_bot",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("aim_fov",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("bat_version", 		COMP_NONEXIST, 	ACTION_KICK, 	"0.0",	0.0, 	Priority_High);
	AddCVarToList("beetlesmod_version", 	COMP_NONEXIST,  ACTION_KICK, 	"0.0",  0.0, 	Priority_High);
	AddCVarToList("est_version", 		COMP_NONEXIST, 	ACTION_KICK, 	"0.0", 	0.0, 	Priority_High);
	AddCVarToList("eventscripts_ver", 	COMP_NONEXIST, 	ACTION_KICK, 	"0.0", 	0.0, 	Priority_High);
	AddCVarToList("fm_attackmode",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("lua_open",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("Lua-Engine",		COMP_NONEXIST, 	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("mani_admin_plugin_version", COMP_NONEXIST, ACTION_KICK, 	"0.0", 	0.0, 	Priority_High);
	AddCVarToList("ManiAdminHacker",	COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("ManiAdminTakeOver",	COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("metamod_version", 	COMP_NONEXIST, 	ACTION_KICK, 	"0.0", 	0.0, 	Priority_High);
	AddCVarToList("openscript",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("openscript_version",	COMP_NONEXIST,	ACTION_BAN, 	"0.0",	0.0,	Priority_High);
	AddCVarToList("runnscript",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("SmAdminTakeover", 	COMP_NONEXIST, 	ACTION_BAN,	"0.0", 	0.0,	Priority_High);
	AddCVarToList("sourcemod_version", 	COMP_NONEXIST, 	ACTION_KICK, 	"0.0", 	0.0, 	Priority_High);
	AddCVarToList("tb_enabled",		COMP_NONEXIST,	ACTION_BAN,	"0.0",	0.0,	Priority_High);
	AddCVarToList("zb_version", 		COMP_NONEXIST, 	ACTION_KICK, 	"0.0", 	0.0, 	Priority_High);

	//- Medium Priority -// Note: Now the client should be clean of any third party server side plugins.  Now we can start really checking.
	AddCVarToList("sv_cheats", 		COMP_EQUAL, 	ACTION_BAN_IF_NOT_CASTER, 	"0.0", 	0.0, 	Priority_Medium);
	//AddCVarToList("sv_gravity", 		COMP_EQUAL, 	ACTION_BAN, 	"800.0", 0.0, 	Priority_Medium);
	AddCVarToList("r_drawothermodels", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Medium);

	// Consistency check has been reworked in some engines.
	new EngineVersion:iEngineVersion = GetEngineVersion();

	if (iEngineVersion != Engine_CSS &&
		iEngineVersion != Engine_DODS &&
		iEngineVersion != Engine_HL2DM &&
		iEngineVersion != Engine_TF2)
	{
		AddCVarToList("sv_consistency", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Medium);
	}

	//- Normal Priority -//
	AddCVarToList("cl_clock_correction", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("cl_leveloverview", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("cl_overdraw_test", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("cl_phys_timescale", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("cl_showevents", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);

	if (SMAC_GetGameType() == Game_INSMOD)
	{
		AddCVarToList("fog_enable", 		COMP_EQUAL, 	ACTION_KICK, 	"1.0", 	0.0, 	Priority_Low);
	}
	else
	{
		AddCVarToList("fog_enable", 		COMP_EQUAL, 	ACTION_BAN_IF_NOT_CASTER, 	"1.0", 	0.0, 	Priority_Low);
	}

	// This doesn't exist on FoF
	if (SMAC_GetGameType() == Game_FOF)
	{
		AddCVarToList("host_timescale", 	COMP_NONEXIST, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_High);
	}
	else
	{
		AddCVarToList("host_timescale", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	}

	AddCVarToList("mat_dxlevel", 		COMP_GREATER, 	ACTION_KICK, 	"80.0", 0.0, 	Priority_Low);
	AddCVarToList("mat_fillrate", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("mat_measurefillrate",	COMP_EQUAL,	ACTION_BAN,	"0.0", 	0.0,	Priority_Low);
	AddCVarToList("mat_proxy", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("mat_showlowresimage",	COMP_EQUAL, 	ACTION_BAN,	"0.0",	0.0,	Priority_Low);
	AddCVarToList("mat_wireframe", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("mem_force_flush", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("snd_show", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("snd_visualize", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_aspectratio", 		COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_colorstaticprops", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_DispWalkable", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_DrawBeams", 		COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawbrushmodels", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawclipbrushes", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawdecals", 		COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawentities", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawmodelstatsoverlay",COMP_EQUAL,	ACTION_BAN,	"0.0",	0.0,	Priority_Low);
	AddCVarToList("r_drawopaqueworld", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawparticles", 	COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawrenderboxes", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawskybox",		COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_drawtranslucentworld", COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_shadowwireframe", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_skybox", 		COMP_EQUAL, 	ACTION_BAN, 	"1.0", 	0.0, 	Priority_Low);
	AddCVarToList("r_visocclusion", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);
	AddCVarToList("vcollide_wireframe", 	COMP_EQUAL, 	ACTION_BAN, 	"0.0", 	0.0, 	Priority_Low);

	//- Replication Protection -//
	decl String:sName[MAX_CVAR_NAME_LEN], bool:bIsCommand, iFlags, Handle:hCVar;
	new Handle:hConCommand = FindFirstConCommand(sName, sizeof(sName), bIsCommand, iFlags);

	if (hConCommand == INVALID_HANDLE)
	{
		SetFailState("Failed getting first ConVar");
	}

	do
	{
		if (bIsCommand)
			continue;

		if (!(iFlags & FCVAR_REPLICATED))
			continue;

		// SMAC will not always be the first to load and many plugins (mistakenly) put
		//  FCVAR_REPLICATED on their version cvar (in addition to FCVAR_PLUGIN or FCVAR_SPONLY)
		if (iFlags & (FCVAR_PLUGIN|FCVAR_SPONLY))
			continue;

		// ToDo: Check if replicate code is needed at all on L4D+ engines.
		if (SMAC_GetGameType() == Game_L4D2 && StrEqual(sName, "mp_gamemode"))
			continue;

		if ((hCVar = FindConVar(sName)) == INVALID_HANDLE)
			continue;

		ReplicateCVarToAll(hCVar);
		HookConVarChange(hCVar, OnCVarChange);

	} while (FindNextConCommand(hConCommand, sName, sizeof(sName), bIsCommand, iFlags));

	CloseHandle(hConCommand);

	// Commands.
	RegAdminCmd("smac_addcvar",      Command_AddCVar,  ADMFLAG_ROOT,    "Adds a CVar to the check list.");
	RegAdminCmd("smac_removecvar",   Command_RemCVar,  ADMFLAG_ROOT,    "Removes a CVar from the check list.");
	RegAdminCmd("smac_cvars_status", Command_Status,  ADMFLAG_GENERIC,  "Shows the status of all in-game clients.");

	// Scramble default CVars.
	if (g_iADTSize)
	{
		ScrambleCVars();
	}

	// Start on all clients.
	if (g_bLateLoad)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsClientAuthorized(i))
			{
				OnClientPostAdminCheck(i);
			}
		}
	}

	g_bPluginInit = true;

#if defined _updater_included
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
	g_bReadyUpAvailable = LibraryExists("readyup");
}

public OnLibraryRemoved(const String:name[]) {
	if (StrEqual(name, "readyup")) {
		g_bReadyUpAvailable = false;
	}
}

public OnLibraryAdded(const String:name[])
{
#if defined _updater_included
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
 	if (StrEqual(name, "readyup")) {
 		g_bReadyUpAvailable = true;
	}
}

public OnClientPostAdminCheck(client)
{
	if (!IsFakeClient(client))
	{
		SetTimer(g_hTimer[client], CreateTimer(0.1, Timer_QueryNextCVar, client, TIMER_REPEAT));
	}
}

public OnClientDisconnect(client)
{
	g_hCurCVarData[client] = INVALID_HANDLE;
	g_iADTIndex[client] = 0;
	g_iRequeryAttempts[client] = 0;

	SetTimer(g_hTimer[client], INVALID_HANDLE);
}

public Action:Command_Status(client, args)
{
	if (!g_iADTSize)
	{
		ReplyToCommand(client, "No CVars being checked.");
		return Plugin_Handled;
	}

	decl String:sAuth[MAX_AUTHID_LENGTH], String:sName[MAX_CVAR_NAME_LEN];

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientAuthString(i, sAuth, sizeof(sAuth), false))
		{
			if (g_hTimer[i] == INVALID_HANDLE)
			{
				g_hTimer[i] = CreateTimer(0.1, Timer_QueryNextCVar, client, TIMER_REPEAT);
				ReplyToCommand(client, "%N (%s) had no active timers.", i, sAuth);
				continue;
			}

			if (g_hCurCVarData[i] == INVALID_HANDLE)
			{
				GetArrayString(GetArrayCell(g_hCVarADT, g_iADTIndex[client]), CELL_NAME, sName, sizeof(sName));
				ReplyToCommand(client, "%N (%s) is preparing to query %s. ADTIndex: %d", i, sAuth, sName, g_iADTIndex[i]);
			}
			else
			{
				GetArrayString(g_hCurCVarData[i], CELL_NAME, sName, sizeof(sName));
				ReplyToCommand(client, "%N (%s) is querying %s. ADTIndex: %d | Retries: %d", i, sAuth, sName, g_iADTIndex[i], g_iRequeryAttempts[i]);
			}
		}
	}

	return Plugin_Handled;
}

public Action:Command_AddCVar(client, args)
{
	if (args != 4 && args != 5)
	{
		ReplyToCommand(client, "Usage: smac_addcvar <cvar name> <comparison type> <action> <value> <value2 if bound>");
		return Plugin_Handled;
	}

	decl String:sName[MAX_CVAR_NAME_LEN];
	GetCmdArg(1, sName, sizeof(sName));

	if (!IsValidName(sName))
	{
		ReplyToCommand(client, "The ConVar name \"%s\" is invalid and cannot be used.", sName);
		return Plugin_Handled;
	}

	decl String:sBuffer[64], iCompType, iAction;
	GetCmdArg(2, sBuffer, sizeof(sBuffer));

	if (StrEqual(sBuffer, "equal"))
		iCompType = COMP_EQUAL;
	else if (StrEqual(sBuffer, "greater"))
		iCompType = COMP_GREATER;
	else if (StrEqual(sBuffer, "less"))
		iCompType = COMP_LESS;
	else if (StrEqual(sBuffer, "between"))
		iCompType = COMP_BOUND;
	else if (StrEqual(sBuffer, "strequal"))
		iCompType = COMP_STRING;
	else if (StrEqual(sBuffer, "nonexist"))
		iCompType = COMP_NONEXIST;
	else
	{
		ReplyToCommand(client, "Unrecognized comparison type \"%s\", acceptable values: \"equal\", \"greater\", \"less\", \"between\", \"strequal\", or \"nonexist\".", sBuffer);
		return Plugin_Handled;
	}

	if (iCompType == COMP_BOUND && args < 5)
	{
		ReplyToCommand(client, "Bound comparison type needs two values to compare with.");
		return Plugin_Handled;
	}

	GetCmdArg(3, sBuffer, sizeof(sBuffer));

	if (StrEqual(sBuffer, "warn"))
		iAction = ACTION_WARN;
	else if (StrEqual(sBuffer, "mute"))
 		iAction = ACTION_MUTE;
	else if (StrEqual(sBuffer, "kick"))
		iAction = ACTION_KICK;
	else if (StrEqual(sBuffer, "ban"))
		iAction = ACTION_BAN;
	else
	{
		ReplyToCommand(client, "Unrecognized action type \"%s\", acceptable values: \"warn\", \"mute\", \"kick\", or \"ban\".", sBuffer);
		return Plugin_Handled;
	}

	decl String:sValue[MAX_CVAR_VALUE_LEN], Float:fValue2;
	GetCmdArg(4, sValue, sizeof(sValue));

	if (iCompType == COMP_BOUND)
	{
		GetCmdArg(5, sBuffer, sizeof(sBuffer));
		fValue2 = StringToFloat(sBuffer);
	}

	if (AddCVarToList(sName, iCompType, iAction, sValue, fValue2, Priority_Low))
	{
		if (IS_CLIENT(client))
		{
			SMAC_LogAction(client, "added convar %s to the check list.", sName);
		}

		ReplyToCommand(client, "Successfully added ConVar %s to the check list.", sName);
	}
	else
	{
		ReplyToCommand(client, "Failed to add ConVar %s to the check list.", sName);
	}

	return Plugin_Handled;
}

bool:AddCVarToList(String:sName[], iCompType, iAction, const String:sValue[], Float:fValue2, CVarPriority:iPriority)
{
	StringToLower(sName);

	new Handle:hCVar = FindConVar(sName);

	if (hCVar != INVALID_HANDLE && (GetConVarFlags(hCVar) & FCVAR_REPLICATED) && (iCompType == COMP_EQUAL || iCompType == COMP_STRING))
	{
		iCompType = COMP_EQUAL;
	}
	else
	{
		hCVar = INVALID_HANDLE;
	}

	decl Handle:hCVarData;

	if (GetTrieValue(g_hCVarTrie, sName, hCVarData))
	{
		SetArrayCell(hCVarData, CELL_HANDLE, hCVar);
		SetArrayString(hCVarData, CELL_NAME, sName);
		SetArrayCell(hCVarData, CELL_COMPTYPE, iCompType);
		SetArrayCell(hCVarData, CELL_ACTION, iAction);
		SetArrayString(hCVarData, CELL_VALUE, sValue);
		SetArrayCell(hCVarData, CELL_VALUE2, fValue2);
		// No need to update CELL_PRIORITY and CELL_REPLICATING.
	}
	else
	{
		hCVarData = CreateArray(64);
		PushArrayCell(hCVarData, hCVar);
		PushArrayString(hCVarData, sName);
		PushArrayCell(hCVarData, iCompType);
		PushArrayCell(hCVarData, iAction);
		PushArrayString(hCVarData, sValue);
		PushArrayCell(hCVarData, fValue2);
		PushArrayCell(hCVarData, iPriority);
		PushArrayCell(hCVarData, INVALID_HANDLE);

		if (!SetTrieValue(g_hCVarTrie, sName, hCVarData))
		{
			CloseHandle(hCVarData);
			SMAC_Log("Unable to add convar to Trie link list %s.", sName);
			return false;
		}

		PushArrayCell(g_hCVarADT, hCVarData);
		g_iADTSize = GetArraySize(g_hCVarADT);

		if (g_bPluginInit && iPriority != Priority_Low)
		{
			ScrambleCVars();
		}
	}

	return true;
}

public Action:Command_RemCVar(client, args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "Usage: smac_removecvar <cvar name>");
		return Plugin_Handled;
	}

	decl String:sName[MAX_CVAR_NAME_LEN];
	GetCmdArg(1, sName, sizeof(sName));

	if (RemoveCVarFromList(sName))
	{
		if (IS_CLIENT(client))
		{
			SMAC_LogAction(client, "removed convar %s from the check list.", sName);
		}
		else
		{
			SMAC_Log("Console removed convar %s from the check list.", sName);
		}

		ReplyToCommand(client, "ConVar %s was successfully removed from the check list.", sName);
	}
	else
	{
		ReplyToCommand(client, "Unable to find ConVar %s in the check list.", sName);
	}

	return Plugin_Handled;
}

bool:RemoveCVarFromList(String:sName[])
{
	decl Handle:hCVarData;

	if (!GetTrieValue(g_hCVarTrie, sName, hCVarData))
		return false;

	new iADTIndex = FindValueInArray(g_hCVarADT, hCVarData);

	if (iADTIndex == -1)
		return false;

	RemoveFromArray(g_hCVarADT, iADTIndex);
	RemoveFromTrie(g_hCVarTrie, sName);
	g_iADTSize = GetArraySize(g_hCVarADT);

	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_iADTIndex[i] >= g_iADTSize)
			g_iADTIndex[i] = 0;

		if (g_hCurCVarData[i] == hCVarData)
		{
			g_hCurCVarData[i] = INVALID_HANDLE;

			// They have 15 seconds to reply to old queries.
			SetTimer(g_hTimer[i], CreateTimer(15.0, Timer_QueryNextCVar, i, TIMER_REPEAT));
		}
	}

	CloseHandle(hCVarData);
	return true;
}

public Action:Timer_QueryNextCVar(Handle:timer, any:client)
{
	// No CVars to check.
	if (!g_iADTSize)
		return Plugin_Continue;

	new Handle:hCVarData = GetArrayCell(g_hCVarADT, g_iADTIndex[client]);

	if (++g_iADTIndex[client] >= g_iADTSize)
		g_iADTIndex[client] = 0;

	// Skip CVars being replicated.
	if (GetArrayCell(hCVarData, CELL_REPLICATING) != INVALID_HANDLE)
		return Plugin_Continue;

	decl String:sName[MAX_CVAR_NAME_LEN];
	GetArrayString(hCVarData, CELL_NAME, sName, sizeof(sName));

	if (QueryClientConVar(client, sName, Query_CVarCallback, GetClientUserId(client)) == QUERYCOOKIE_FAILED)
		return Plugin_Continue;

	g_hCurCVarData[client] = hCVarData;
	g_hTimer[client] = CreateTimer(30.0, Timer_RequeryCVar, client);
	return Plugin_Stop;
}

public Action:Timer_RequeryCVar(Handle:timer, any:client)
{
	if (++g_iRequeryAttempts[client] > MAX_REQUERY_ATTEMPTS)
	{
		g_hTimer[client] = INVALID_HANDLE;
		KickClient(client, "%t", "SMAC_FailedToReply");
		return Plugin_Stop;
	}

	if (GetArrayCell(g_hCurCVarData[client], CELL_REPLICATING) == INVALID_HANDLE)
	{
		decl String:sName[MAX_CVAR_NAME_LEN];
		GetArrayString(g_hCurCVarData[client], CELL_NAME, sName, sizeof(sName));

		if (QueryClientConVar(client, sName, Query_CVarCallback, GetClientUserId(client)) != QUERYCOOKIE_FAILED)
		{
			g_hTimer[client] = CreateTimer(15.0, Timer_RequeryCVar, client);
			return Plugin_Stop;
		}
	}

	g_hTimer[client] = CreateTimer(0.1, Timer_QueryNextCVar, client, TIMER_REPEAT);
	return Plugin_Stop;
}

public Query_CVarCallback(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[], any:userid)
{
	if (GetClientOfUserId(userid) != client)
		return;

	decl Handle:hCVarData;

	if (!GetTrieValue(g_hCVarTrie, cvarName, hCVarData))
	{
		// The CVar was recently removed.
		if (g_hCurCVarData[client] == INVALID_HANDLE)
			return;

		KickClient(client, "%t", "SMAC_ClientCorrupt");
		return;
	}

	// Are you the CVar we're expecting?
	if (hCVarData == g_hCurCVarData[client])
	{
		g_hCurCVarData[client] = INVALID_HANDLE;
		g_iRequeryAttempts[client] = 0;
		SetTimer(g_hTimer[client], CreateTimer(MT_GetRandomFloat(1.0, 3.0), Timer_QueryNextCVar, client, TIMER_REPEAT));
	}

	new iCompType = GetArrayCell(hCVarData, CELL_COMPTYPE);
	new iAction = GetArrayCell(hCVarData, CELL_ACTION);

	if (iCompType == COMP_NONEXIST)
	{
		if (result == ConVarQuery_NotFound)
			return;

		new Handle:info = CreateKeyValues("");
		KvSetString(info, "cvar", cvarName);
		KvSetString(info, "value", cvarValue);
		KvSetString(info, "query", g_sQueryResult[result]);

		if (SMAC_CheatDetected(client, Detection_CvarPlugin, info) == Plugin_Continue)
		{
			SMAC_PrintAdminNotice("%t", "SMAC_HasPlugin", client, cvarName);

			switch (iAction)
			{
				case ACTION_MUTE:
				{
					PrintToChatAll("%t%t", "SMAC_Tag", "SMAC_Muted", client);
					BaseComm_SetClientMute(client, true);
				}
				case ACTION_KICK:
				{
					SMAC_LogAction(client, "was kicked for returning with plugin convar \"%s\" (value \"%s\", return %s).", cvarName, cvarValue, g_sQueryResult[result]);
					KickClient(client, "%t", "SMAC_RemovePlugins");
				}
				case ACTION_BAN:
				{
					SMAC_LogAction(client, "has convar \"%s\" (value \"%s\", return %s) when it shouldn't exist.", cvarName, cvarValue, g_sQueryResult[result]);
					SMAC_Ban(client, "ConVar %s violation", cvarName);
				}
				case ACTION_BAN_IF_NOT_CASTER:
				{
					if (g_bReadyUpAvailable && IsClientCaster(client)) return;
					SMAC_LogAction(client, "has convar \"%s\" (value \"%s\", return %s) when it shouldn't exist.", cvarName, cvarValue, g_sQueryResult[result]);
					SMAC_Ban(client, "ConVar %s violation", cvarName);
				}

			}
		}

		CloseHandle(info);
		return;
	}

	if (result != ConVarQuery_Okay)
	{
		SMAC_LogAction(client, "returned query result \"%s\" (expected Okay) on convar \"%s\" (value \"%s\").", g_sQueryResult[result], cvarName, cvarValue);
		SMAC_Ban(client, "ConVar %s violation (bad query result)", cvarName);
		return;
	}

	// Skip CVars being replicated.
	if (GetArrayCell(hCVarData, CELL_REPLICATING) != INVALID_HANDLE)
		return;

	decl String:sValue[MAX_CVAR_VALUE_LEN];
	new Handle:hCVar = GetArrayCell(hCVarData, CELL_HANDLE);

	// Only replicated CVars have their handle stored.
	if (hCVar != INVALID_HANDLE)
	{
		GetConVarString(hCVar, sValue, sizeof(sValue));
	}
	else
	{
		GetArrayString(hCVarData, CELL_VALUE, sValue, sizeof(sValue));
	}

	if (iCompType != COMP_STRING)
	{
		new iLength = strlen(cvarValue);

		for (new i = 0; i < iLength; i++)
		{
			if (!IsCharNumeric(cvarValue[i]) && cvarValue[i] != '.')
			{
				SMAC_LogAction(client, "was kicked for returning a corrupted value on %s, value set at \"%s\" (expected \"%s\").", cvarName, cvarValue, sValue);
				KickClient(client, "%t", "SMAC_ClientCorrupt");
				return;
			}
		}
	}

	new Handle:info = CreateKeyValues("");
	KvSetString(info, "cvar", cvarName);
	KvSetString(info, "value", cvarValue);
	KvSetString(info, "expected", sValue);

	switch (iCompType)
	{
		case COMP_EQUAL:
		{
			if (StringToFloat(sValue) != StringToFloat(cvarValue) && SMAC_CheatDetected(client, Detection_CvarNotEqual, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_HasNotEqual", client, cvarName, cvarValue, sValue);

				switch (iAction)
				{
					case ACTION_MUTE:
					{
						PrintToChatAll("%t%t", "SMAC_Tag", "SMAC_Muted", client);
						BaseComm_SetClientMute(client, true);
					}
					case ACTION_KICK:
					{
						SMAC_LogAction(client, "was kicked for returning with convar \"%s\" set to value \"%s\" when it should be \"%s\".", cvarName, cvarValue, sValue);
						KickClient(client, "\n%t", "SMAC_ShouldEqual", cvarName, sValue, cvarValue);
					}
					case ACTION_BAN:
					{
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should equal.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
					case ACTION_BAN_IF_NOT_CASTER:
					{
						if (g_bReadyUpAvailable && IsClientCaster(client)) return;
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should equal.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
				}
			}
		}
		case COMP_GREATER:
		{
			if (StringToFloat(sValue) > StringToFloat(cvarValue) && SMAC_CheatDetected(client, Detection_CvarNotGreater, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_HasNotGreater", client, cvarName, cvarValue, sValue);

				switch (iAction)
				{
					case ACTION_MUTE:
					{
						PrintToChatAll("%t%t", "SMAC_Tag", "SMAC_Muted", client);
						BaseComm_SetClientMute(client, true);
					}
					case ACTION_KICK:
					{
						SMAC_LogAction(client, "was kicked for returning with convar \"%s\" set to value \"%s\" when it should be greater than or equal to \"%s\".", cvarName, cvarValue, sValue);
						KickClient(client, "\n%t", "SMAC_ShouldBeGreater", cvarName, sValue, cvarValue);
					}
					case ACTION_BAN:
					{
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should greater than or equal to.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
					case ACTION_BAN_IF_NOT_CASTER:
					{
						if (g_bReadyUpAvailable && IsClientCaster(client)) return;
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should greater than or equal to.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
				}
			}
		}
		case COMP_LESS:
		{
			if (StringToFloat(sValue) < StringToFloat(cvarValue) && SMAC_CheatDetected(client, Detection_CvarNotLess, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_HasNotLess", client, cvarName, cvarValue, sValue);

				switch (iAction)
				{
					case ACTION_MUTE:
					{
						PrintToChatAll("%t%t", "SMAC_Tag", "SMAC_Muted", client);
						BaseComm_SetClientMute(client, true);
					}
					case ACTION_KICK:
					{
						SMAC_LogAction(client, "was kicked for returning with convar \"%s\" set to value \"%s\" when it should be less than or equal to \"%s\".", cvarName, cvarValue, sValue);
						KickClient(client, "\n%t", "SMAC_ShouldBeLess", cvarName, sValue, cvarValue);
					}
					case ACTION_BAN:
					{
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should be less than or equal to.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
					case ACTION_BAN_IF_NOT_CASTER:
					{
						if (g_bReadyUpAvailable && IsClientCaster(client)) return;
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should be less than or equal to.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
				}
			}
		}
		case COMP_BOUND:
		{
			new Float:fValue2 = GetArrayCell(hCVarData, CELL_VALUE2);

			if (StringToFloat(cvarValue) < StringToFloat(sValue) || StringToFloat(cvarValue) > fValue2 && SMAC_CheatDetected(client, Detection_CvarNotBound, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_HasNotBound", client, cvarName, cvarValue, sValue, fValue2);

				switch (iAction)
				{
					case ACTION_MUTE:
					{
						PrintToChatAll("%t%t", "SMAC_Tag", "SMAC_Muted", client);
						BaseComm_SetClientMute(client, true);
					}
					case ACTION_KICK:
					{
						SMAC_LogAction(client, "was kicked for returning with convar \"%s\" set to value \"%s\" when it should be between \"%s\" and \"%f\".", cvarName, cvarValue, sValue, fValue2);
						KickClient(client, "\n%t", "SMAC_ShouldBound", cvarName, sValue, fValue2, cvarValue);
					}
					case ACTION_BAN:
					{
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" when it should be between \"%s\" and \"%f\".", cvarName, cvarValue, sValue, fValue2);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
					case ACTION_BAN_IF_NOT_CASTER:
					{
						if (g_bReadyUpAvailable && IsClientCaster(client)) return;
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" when it should be between \"%s\" and \"%f\".", cvarName, cvarValue, sValue, fValue2);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
				}
			}
		}
		case COMP_STRING:
		{
			if (!StrEqual(sValue, cvarValue) && SMAC_CheatDetected(client, Detection_CvarNotEqual, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_HasNotEqual", client, cvarName, cvarValue, sValue);

				switch (iAction)
				{
					case ACTION_MUTE:
					{
						PrintToChatAll("%t%t", "SMAC_Tag", "SMAC_Muted", client);
						BaseComm_SetClientMute(client, true);
					}
					case ACTION_KICK:
					{
						SMAC_LogAction(client, "was kicked for returning with convar \"%s\" set to value \"%s\" when it should be \"%s\".", cvarName, cvarValue, sValue);
						KickClient(client, "\n%t", "SMAC_ShouldEqual", cvarName, sValue, cvarValue);
					}
					case ACTION_BAN:
					{
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should equal.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
					case ACTION_BAN_IF_NOT_CASTER:
					{
						if (g_bReadyUpAvailable && IsClientCaster(client)) return;
						SMAC_LogAction(client, "has convar \"%s\" set to value \"%s\" (should be \"%s\") when it should equal.", cvarName, cvarValue, sValue);
						SMAC_Ban(client, "ConVar %s violation", cvarName);
					}
				}
			}
		}
	}

	CloseHandle(info);
}

public OnCVarChange(Handle:convar, const String:oldvalue[], const String:newvalue[])
{
	// Delayed so nothing interferes with replication.
	CreateTimer(0.1, Timer_ReplicateCVar, convar);

	decl String:sName[MAX_CVAR_NAME_LEN], Handle:hCVarData;
	GetConVarName(convar, sName, sizeof(sName));

	if (GetTrieValue(g_hCVarTrie, sName, hCVarData))
	{
		new Handle:hTimer = GetArrayCell(hCVarData, CELL_REPLICATING);

		SetTimer(hTimer, CreateTimer(30.0, Timer_ReplicatedCVar, hCVarData));
		SetArrayCell(hCVarData, CELL_REPLICATING, hTimer);
	}
}

public Action:Timer_ReplicateCVar(Handle:timer, any:hCVar)
{
	decl String:sName[MAX_CVAR_NAME_LEN];
	GetConVarName(hCVar, sName, sizeof(sName));

	if (StrEqual(sName, "sv_cheats") && GetConVarInt(hCVar) != 0)
	{
		SetConVarInt(hCVar, 0);
	}

	ReplicateCVarToAll(hCVar);
	return Plugin_Stop;
}

public Action:Timer_ReplicatedCVar(Handle:timer, any:hCVarData)
{
	SetArrayCell(hCVarData, CELL_REPLICATING, INVALID_HANDLE);
	return Plugin_Stop;
}

ReplicateCVarToAll(Handle:hCVar)
{
	decl String:sValue[MAX_CVAR_VALUE_LEN];
	GetConVarString(hCVar, sValue, sizeof(sValue));

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, hCVar, sValue);
		}
	}
}

bool:IsValidName(const String:sName[])
{
	if (sName[0] == '\0')
		return false;

	new iLength = strlen(sName);

	for (new i = 0; i < iLength; i++)
	{
		if (!IsValidConVarChar(sName[i]))
		{
			return false;
		}
	}

	return true;
}

ScrambleCVars()
{
	decl Handle:hCVarADTs[_:CVarPriority][g_iADTSize], Handle:hCVarData, iPriority;
	new iADTIndex[_:CVarPriority];

	for (new i = 0; i < g_iADTSize; i++)
	{
		hCVarData = GetArrayCell(g_hCVarADT, i);
		iPriority = GetArrayCell(hCVarData, CELL_PRIORITY);

		hCVarADTs[iPriority][iADTIndex[iPriority]++] = hCVarData;
	}

	ClearArray(g_hCVarADT);

	for (new i = 0; i < _:CVarPriority; i++)
	{
		if (iADTIndex[i] > 0)
		{
			SortIntegers(_:hCVarADTs[i], iADTIndex[i], Sort_Random);

			for (new j = 0; j < iADTIndex[i]; j++)
			{
				PushArrayCell(g_hCVarADT, hCVarADTs[i][j]);
			}
		}
	}
}

SetTimer(&Handle:hTimer, Handle:hNewTimer=INVALID_HANDLE)
{
	new Handle:hTemp = hTimer;
	hTimer = hNewTimer;

	if (hTemp != INVALID_HANDLE)
	{
		CloseHandle(hTemp);
	}
}
