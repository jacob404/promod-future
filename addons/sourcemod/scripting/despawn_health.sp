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

#include <sourcemod>
#include <sdktools>
#include <left4downtown>

new Handle:si_restore_ratio;

public Plugin:myinfo = 
{
    name = "Despawn Health",
    author = "Jacob",
    description = "Gives Special Infected health back when they despawn.",
    version = "1.3",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    si_restore_ratio = CreateConVar("si_restore_ratio", "0.5", "How much of the clients missing HP should be restored? 1.0 = Full HP", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public L4D_OnEnterGhostState(client)
{
    new CurrentHealth = GetClientHealth(client);
    new MaxHealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
    if (CurrentHealth != MaxHealth)
    {
        new MissingHealth = MaxHealth - CurrentHealth;
        new NewHP = RoundFloat(MissingHealth * GetConVarFloat(si_restore_ratio)) + CurrentHealth;
        SetEntityHealth(client, NewHP);
    }
}
