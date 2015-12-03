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
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>



#define SEQ_COACH_NICK    		  630
#define SEQ_ELLIS				  635
#define SEQ_ROCHELLE     		  638
#define SEQ_BILL_LOUIS	  	      538
#define SEQ_FRANCIS               541
#define SEQ_ZOEY                  547


new lastAnimSequence[MAXPLAYERS + 1];
//Should initialise array as all false
new bool:giveWeapon[MAXPLAYERS + 1];             
new 	i = 0;

public Plugin:myinfo =
{
    name = "L4D2 Melee and Shove Shenanigans",
    author = "Sir, High Cookie and Standalone",
    description = "Stops Shoves slowing the Tank and stops survivors keeping melee out after tank punch",
    version = "1.ʕ•ᴥ•ʔ",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

public OnPluginStart()
{
    HookEvent("player_hurt", PlayerHit);
}
 
public Action:PlayerHit(Handle:event, String:event_name[], bool:dontBroadcast)
{
    new PlayerID = GetClientOfUserId(GetEventInt(event, "userid"));
    new String:Weapon[256];  
    GetEventString(event, "weapon", Weapon, 256);
    if (IsSurvivor(PlayerID) && StrEqual(Weapon, "tank_claw"))
    {
        new activeweapon = GetEntPropEnt(PlayerID, Prop_Send, "m_hActiveWeapon");
        if (!IsValidEdict(activeweapon)) return;
 
        decl String:weaponname[64];
        GetEdictClassname(activeweapon, weaponname, sizeof(weaponname));
        if (!StrEqual(weaponname, "weapon_melee", false)) return;		
		if (GetPlayerWeaponSlot(PlayerID, 0) != -1)
		{
			SDKHook(PlayerID, SDKHook_PostThink, OnThink);
		}
		return;
    }
}

public OnThink(client)
{
	if(i > 300)
		{ 
		i = 0;
		SDKUnhook(client, SDKHook_PostThink, OnThink);
		}
	i = 1 + i;
	
    new sequence = GetEntProp(client, Prop_Send, "m_nSequence");
    
    if (!giveWeapon[client])
    {
        if ((lastAnimSequence[client] == SEQ_COACH_NICK && sequence != SEQ_COACH_NICK) || (lastAnimSequence[client] == SEQ_ELLIS && sequence != SEQ_ELLIS) || (lastAnimSequence[client] == SEQ_ROCHELLE   && sequence != SEQ_ROCHELLE)|| (lastAnimSequence[client] == SEQ_BILL_LOUIS   && sequence != SEQ_BILL_LOUIS)|| (lastAnimSequence[client] == SEQ_FRANCIS   && sequence != SEQ_FRANCIS)|| (lastAnimSequence[client] == SEQ_ZOEY   && sequence != SEQ_ZOEY))
        {
            giveWeapon[client] = true;
        }
    }
    else
    {
        SwapToGun(client)
        giveWeapon[client] = false;
		i = 0;
        SDKUnhook(client, SDKHook_PostThink, OnThink);
    }
	lastAnimSequence[client] = sequence;
}

public Action: SwapToGun(any:client)
{
	//New method for swapping guns, should fix the dropping a copy of the gun issue
	new String:primaryWeaponName[256];
	new primaryWeapon = GetPlayerWeaponSlot(client, 0);
	GetEdictClassname(primaryWeapon, primaryWeaponName, sizeof(primaryWeaponName));

	new primaryAmmoClip = GetEntProp(primaryWeapon, Prop_Data, "m_iClip1");
	new primaryAmmoType = GetEntProp(primaryWeapon, Prop_Data, "m_iPrimaryAmmoType");
	new primaryAmmoReserve = GetReserveAmmoOfType(client, primaryAmmoType);

	new newPrimaryWeapon = CreateEntityByName(primaryWeaponName);
	if (IsValidEntity(newPrimaryWeapon))
	{
		AcceptEntityInput(primaryWeapon, "kill");
		
		DispatchSpawn(newPrimaryWeapon);

		EquipPlayerWeapon(client, newPrimaryWeapon);
		
		SetEntProp(newPrimaryWeapon, Prop_Send, "m_iClip1", primaryAmmoClip);
		SetReserveAmmoOfType(client, primaryAmmoType, primaryAmmoReserve);
	}

	return
}
 
public Action:L4D_OnShovedBySurvivor(shover, shovee, const Float:vector[3])
{
    if (!IsSurvivor(shover) || !IsInfected(shovee)) return Plugin_Continue;
    if (IsTankOrCharger(shovee)) return Plugin_Handled;
    return Plugin_Continue;
}
 
public Action:L4D2_OnEntityShoved(shover, shovee_ent, weapon, Float:vector[3], bool:bIsHunterDeadstop)
{
    if (!IsSurvivor(shover) || !IsInfected(shovee_ent)) return Plugin_Continue;
    if (IsTankOrCharger(shovee_ent)) return Plugin_Handled;
    return Plugin_Continue;
}
 
stock bool:IsSurvivor(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}
 
stock bool:IsInfected(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3;
}

stock SetReserveAmmoOfType(client, type, ammo)
{
	new ammoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	return SetEntData(client, ammoOffset+(type*4), ammo);
}

stock GetReserveAmmoOfType(client, type)
{
    new ammoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
    return GetEntData(client, ammoOffset+(type*4));
}
 
bool:IsTankOrCharger(client)  
{
    if (!IsPlayerAlive(client))
        return false;
 
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 8)
        return true;
 
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 6)
        return true;
 
    return false;
}
