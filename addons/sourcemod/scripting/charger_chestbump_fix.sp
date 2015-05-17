#pragma semicolon 1

#include <sourcemod>
#include <left4downtown>

#define JBE_REL8_OPCODE 0x76

// NOP; JMP (rel32)
new PATCH_REPLACEMENT_LINUX[2] = {0x90, 0xE9};
new PATCH_REPLACEMENT_WINDOWS = 0xE9;
new ORIGINAL_BYTES_LINUX[2];
new Address:g_pPatchTarget;
new bool:g_bIsPatched;
new bool:g_bIsLinux;

public Plugin:myinfo =
{
	name = "Charger Chest Bump Fix",
	author = "Jacob",
	description = "Fixes chargers getting random stumbles when attempting to charge a survivor",
	version = "1.0",
	url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	new Handle:hGamedata = LoadGameConfigFile("charger_chestbump");
	if (!hGamedata)
		SetFailState("Gamedata 'charger_chestbump.txt' missing or corrupt");

	g_pPatchTarget = FindPatchTarget(hGamedata);
	CloseHandle(hGamedata);
	
	new Handle:cvar = CreateConVar("l4d2_charger_chestbump_fix", "0", "Fix chargers stumbling when charging too close to a survivor");
	HookConVarChange(cvar, OnCvarChange);
	CheckCvarAndPatch(cvar);
}

public OnPluginEnd()
{
	Unpatch();
}

public OnCvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	CheckCvarAndPatch(convar);
}

CheckCvarAndPatch(Handle:convar)
{
	if(GetConVarBool(convar))
	{
		Patch();
	}
	else 
	{
		Unpatch();
	}
}

bool:IsPatched()
{
	return g_bIsPatched;
}

Patch()
{
	if(!IsPatched())
	{
		if(g_bIsLinux)
		{
			for(new i =0; i < sizeof(PATCH_REPLACEMENT_LINUX); i++)
			{
				StoreToAddress(g_pPatchTarget + Address:i, PATCH_REPLACEMENT_LINUX[i], NumberType_Int8);
			}
		}
		else
		{
			StoreToAddress(g_pPatchTarget, PATCH_REPLACEMENT_WINDOWS, NumberType_Int8);
		}
		g_bIsPatched = true;
	}
}

Unpatch()
{
	if(IsPatched())
	{
		if(g_bIsLinux)
		{
			for(new i =0; i < sizeof(ORIGINAL_BYTES_LINUX); i++)
			{
				StoreToAddress(g_pPatchTarget + Address:i, ORIGINAL_BYTES_LINUX[i], NumberType_Int8);
			}
		}
		else
		{
			StoreToAddress(g_pPatchTarget, JBE_REL8_OPCODE, NumberType_Int8);
		}
		g_bIsPatched = false;
	}
}

Address:FindPatchTarget(Handle:hGamedata)
{
	new Address:pTarget = GameConfGetAddress(hGamedata, "ChargerCollision_Sig");
	if (!pTarget)
		SetFailState("Couldn't find the 'ChargerCollision_Sig' address");
	
	new iOffset = GameConfGetOffset(hGamedata, "HandleCustomCollision_TooShortCheck");
	
	pTarget = pTarget + (Address:iOffset);
	
	new FirstByte = LoadFromAddress(pTarget, NumberType_Int8);
	
	switch(FirstByte)
	{
		case 0x0F: //Linux
		{
			for(new i =0; i < sizeof(ORIGINAL_BYTES_LINUX); i++)
			{
				ORIGINAL_BYTES_LINUX[i] = LoadFromAddress(pTarget + Address:i, NumberType_Int8);
			}
			g_bIsLinux = true;
		}
		case 0x76: //Windows
		{
			g_bIsLinux = false;
		}
		default:
		{
			SetFailState("Charger Chest Bump Offset or signature seems incorrect");
		}
	}
	return pTarget;
}

public Action:L4D2_OnEntityShoved(client, entity, weapon, Float:vector[3], bool:bIsHunterDeadstop)
{
	if(IsValidPlayer(entity) && GetEntProp(entity, Prop_Send, "m_zombieClass") == 6) return Plugin_Handled;
	return Plugin_Continue;
}

bool:IsValidPlayer(client)
{
        if (client <= 0 || client > MaxClients) return false;
        if (!IsClientInGame(client)) return false;
        return true;
}