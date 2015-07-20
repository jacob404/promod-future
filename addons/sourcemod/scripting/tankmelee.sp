#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
 
public Plugin:myinfo =
{
    name = "L4D2 Melee and Shove Shenanigans",
    author = "Sir",
    description = "Stops Shoves slowing the Tank and Charger Down and Survivors getting melee hits on Tanks between punches.",
    version = "1.fun",
    url = ""
}

public OnPluginStart()
{
    HookEvent("player_hurt", PlayerHit);
	CreateTimer(5.0, SwitchWeapon);
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
        ///g_fStoredNext[PlayerID] = 0.0;
		
		if (GetPlayerWeaponSlot(PlayerID, 1) != -1)
		{
			PrintToChatAll("TIME FOR SOME COOL TIMING");
			CreateTimer(5.0, SwitchWeapon, PlayerID);
		

			
		}
		return;
		
		
    }
}
public Action:SwitchWeapon(Handle:timer, any:client)
{
	
	PrintToChatAll("TIMING DONE!");
	decl String:weaponname[64];
    new weaponindex = GetPlayerWeaponSlot(client, 0)
	GetEdictClassname(weaponindex, weaponname, sizeof(weaponname));
	new extraammo = GetEntProp(weaponindex, Prop_Send, "m_iExtraPrimaryAmmo");
	PrintToChatAll("Extra Ammo %i", extraammo);
	extraammo = GetEntProp(weaponindex, Prop_Send, "m_iClip1");
	PrintToChatAll("Extra Ammo %i", extraammo);
	extraammo = GetEntProp(client, Prop_Send, "m_iAmmo");
	PrintToChatAll("Extra Ammo %i", extraammo);
	EquipPlayerWeapon(client, weaponindex)
	
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