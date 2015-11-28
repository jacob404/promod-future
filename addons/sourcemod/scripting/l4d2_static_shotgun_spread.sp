/*
	SourcePawn is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2015 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#pragma semicolon 1

#include <code_patcher>

new Handle:hRing1BulletsCvar;
new Handle:hRing1FactorCvar;
new Handle:hCenterPelletCvar;

new g_BulletOffsets[] = { 0x11, 0x1c, 0x29, 0x3d };
new g_FactorOffset = 0x2e;
new g_CenterPelletOffset = -0x31;

public Plugin:myinfo = 
{
    name = "L4D2 Static Shotgun Spread",
    author = "Jahze, Visor",
    version = "1.1",
    description = "^",
	url = "https://github.com/Attano"
};

public OnPluginStart()
{
	hRing1BulletsCvar = CreateConVar("sgspread_ring1_bullets", "3");
	hRing1FactorCvar = CreateConVar("sgspread_ring1_factor", "2");
	hCenterPelletCvar = CreateConVar("sgspread_center_pellet", "1", "0 : center pellet off; 1 : on", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	HookConVarChange(hRing1BulletsCvar, OnRing1BulletsChange);
	HookConVarChange(hRing1FactorCvar, OnRing1FactorChange);
	HookConVarChange(hCenterPelletCvar, OnCenterPelletChange);
}

static HotPatchCenterPellet(newValue)
{
	if (IsPlatformWindows())
	{
		LogMessage("Static shotgun spread not supported on windows");
		return;
	}

	new Address:addr = GetPatchAddress("sgspread");
	
	new currentValue = LoadFromAddress(addr + Address:g_CenterPelletOffset, NumberType_Int8);
	if (currentValue == newValue)
	{
		return;
	}
	
	StoreToAddress(addr + Address:g_CenterPelletOffset, newValue, NumberType_Int8);
}

static HotPatchBullets(nBullets)
{
	if (IsPlatformWindows())
	{
		LogMessage("Static shotgun spread not supported on windows");
		return;
	}

	new Address:addr = GetPatchAddress("sgspread");

	StoreToAddress(addr + Address:g_BulletOffsets[0], nBullets + 1, NumberType_Int8);
	StoreToAddress(addr + Address:g_BulletOffsets[1], nBullets + 2, NumberType_Int8);
	StoreToAddress(addr + Address:g_BulletOffsets[2], nBullets + 2, NumberType_Int8);

	new Float:degree = 360.0 / (2.0*float(nBullets));

	StoreToAddress(addr + Address:g_BulletOffsets[3], _:degree, NumberType_Int32);
}

static HotPatchFactor(factor)
{
	if (IsPlatformWindows())
	{
		LogMessage("Static shotgun spread not supported on windows");
		return;
	}

	new Address:addr = GetPatchAddress("sgspread");

	StoreToAddress(addr + Address:g_FactorOffset, factor, NumberType_Int32);
}

public OnRing1BulletsChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new nBullets = StringToInt(newVal);

	if (IsPatchApplied("sgspread"))
		HotPatchBullets(nBullets);
}

public OnRing1FactorChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new factor = StringToInt(newVal);

	if (IsPatchApplied("sgspread"))
		HotPatchFactor(factor);
}

public OnCenterPelletChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new value = StringToInt(newVal);

	if (IsPatchApplied("sgspread"))
		HotPatchCenterPellet(value);
}

public OnPatchApplied(const String:name[])
{
	if (StrEqual("sgspread", name))
	{
		HotPatchBullets(GetConVarInt(hRing1BulletsCvar));
		HotPatchFactor(GetConVarInt(hRing1FactorCvar));
		HotPatchCenterPellet(GetConVarInt(hCenterPelletCvar));
	}
}
