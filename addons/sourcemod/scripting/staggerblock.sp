#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4downtown>
#include <l4d2util>

/*
Could probably do away with the trie but for now it works
Place client into the trie on the following events
    pounce_stopped
    charger_pummel_end
    charger_carry_end
    SDKHook(OnThink)
*/

/*
OnThink
    if (animation state is getting up)
        do nothing
    else
        remove player from trie, and SDKUnhook(OnThink)
*/

/*
OnStagger
    If target in trie
        if source is hunter/jockey
            cancel stagger
*/

new Handle:hStaggerBlockedTrie = INVALID_HANDLE;

//Courtesy of the l4d2_getupfix plugin
new const getUpAnimations[SurvivorCharacter][4] = {    
    // 0: Coach, 1: Nick, 2: Rochelle, 3: Ellis
    {621, 656, 660, 661}, {620, 667, 671, 672}, {629, 674, 678, 679}, {625, 671, 675, 676},
    // 4: Louis, 5: Zoey, 6: Bill, 7: Francis
    {528, 759, 763, 764}, {537, 819, 823, 824}, {528, 759, 763, 764}, {531, 762, 766, 767}
};

public Plugin:myinfo =
{
    name        = "Stagger Blocker",
    author      = "Standalone (aka Manu)",
    description = "Block players from being staggered for a time while getting up from a Hunter pounce or a Charger pummel",
    version     = "1.0",
    url         = ""
}

public OnPluginStart() 
{
    HookEvent("pounce_stopped", Event_PounceChargeEnd); //There's also a pounce_end event, will have to check what the difference is, pounce end does some wierd shit D:
    HookEvent("charger_pummel_end", Event_PounceChargeEnd);
    HookEvent("charger_carry_end", Event_PounceChargeEnd);
    
    //Don't care about what happens when a bot replaces a player and vice versa, since they immediately get up out of the animation when they join/disconnect
    
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    
    hStaggerBlockedTrie = CreateTrie();
    
    PrintToChatAll("[StaggerBlockv2] Has been loaded");
    PrintToServer("[StaggerBlockv2] Has been loaded");
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    ClearTrie(hStaggerBlockedTrie);
}

public OnMapEnd()
{
    ClearTrie(hStaggerBlockedTrie);
}

public OnPluginEnd()
{
    CloseHandle(hStaggerBlockedTrie);
}

public Action:Event_PounceChargeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "victim"));
    
    new SurvivorCharacter:charIndex = IdentifySurvivor(client);
    if (charIndex == SC_NONE) 
        return;
        
    decl String:charName[8];
    GetSurvivorName(charIndex, charName, sizeof(charName));
        
    SetTrieValue(hStaggerBlockedTrie, charName, true); //Add survivor to stagger blocked
    CreateTimer(0.1, HookOnThink, client); //Wait a moment so they're in getup animation
    
    PrintToChatAll("[StaggerBlockv2] %s is now stagger immune", charName);
    PrintToServer("[StaggerBlockv2] %s is now stagger immune", charName);
}

public Action:HookOnThink(Handle:timer, any:client)
{
    SDKHook(client, SDKHook_PostThink, OnThink);
}

//Using on think think because of possible pauses, must automatically unhook when player disconnects, did tests this seems to be the case
public OnThink(client)
{
    new SurvivorCharacter:charIndex = IdentifySurvivor(client);
    if (charIndex == SC_NONE) 
        return;
    
    decl String:charName[8];
    GetSurvivorName(charIndex, charName, sizeof(charName));
    
    new sequence = GetEntProp(client, Prop_Send, "m_nSequence");
    
    if (sequence != getUpAnimations[charIndex][0] && sequence != getUpAnimations[charIndex][1] && sequence != getUpAnimations[charIndex][2] && sequence != getUpAnimations[charIndex][3])
    {
        PrintToChatAll("[StaggerBlockv2] %s is no longer stagger immune", charName);
        PrintToServer("[StaggerBlockv2] %s is no longer stagger immune", charName);
        RemoveFromTrie(hStaggerBlockedTrie, charName);
        SDKUnhook(client, SDKHook_PostThink, OnThink);
    }
}

public Action:L4D2_OnStagger(target, source) 
{
    if (IsInfected(source))
    {
        new L4D2_Infected:sourceClass = GetInfectedClass(source);
        decl String:className[64];
        GetInfectedClassName(sourceClass, className, sizeof(className));
        
        if (IsInfected(source) && (sourceClass == L4D2Infected_Hunter || sourceClass == L4D2Infected_Jockey)) //Still need to check if Jockey/Hunter
        {
            new SurvivorCharacter:charIndex = IdentifySurvivor(target);
            if (charIndex == SC_NONE) 
                return Plugin_Continue;
            
            decl String:charName[8];
            GetSurvivorName(charIndex, charName, sizeof(charName));
            
            new bool:staggerBlocked = false;
            
            if (GetTrieValue(hStaggerBlockedTrie, charName, staggerBlocked)) 
            {
                PrintToChatAll("[StaggerBlockv2] Blocking stagger on %s, source: %s", charName, className);
                PrintToServer("[StaggerBlockv2] Blocking stagger on %s, source: %s", charName, className);
                return Plugin_Handled;
            }
            else //Not needed, debug purposes
            {
                PrintToChatAll("[StaggerBlockv2] Staggering %s, source: %s", charName, className);
                PrintToServer("[StaggerBlockv2] Staggering %s, source: %s", charName, className);
            }
        }
        else
        {
            new SurvivorCharacter:charIndex = IdentifySurvivor(target);
            if (charIndex == SC_NONE) 
                return Plugin_Continue;
            
            decl String:charName[8];
            GetSurvivorName(charIndex, charName, sizeof(charName));

            PrintToChatAll("[StaggerBlockv2] Staggering %s, source: %s", charName, className);
            PrintToServer("[StaggerBlockv2] Staggering %s, source: %s", charName, className);
        }
    }
    return Plugin_Continue;
}