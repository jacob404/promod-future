#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4downtown>
#include <l4d2util>

new bool:isSurvivorStaggerBlocked[8];

//Courtesy of the l4d2_getupfix plugin
new const getUpAnimations[SurvivorCharacter][5] = {    
    // 0: Coach, 1: Nick, 2: Rochelle, 3: Ellis
    //[][4] = Flying animation from being hit by a tank
    {621, 656, 660, 661, 629}, {620, 667, 671, 672, 629}, {629, 674, 678, 679, 637}, {625, 671, 675, 676, 634},
    // 4: Louis, 5: Zoey, 6: Bill, 7: Francis
    {528, 759, 763, 764, 537}, {537, 819, 823, 824, 546}, {528, 759, 763, 764, 537}, {531, 762, 766, 767, 540}
};

public Plugin:myinfo =
{
    name        = "Stagger Blocker",
    author      = "Standalone (aka Manu)",
    description = "Block players from being staggered for a time while getting up from a Hunter pounce or a Charger pummel",
    version     = "",
    url         = ""
}

public OnPluginStart() 
{
    HookEvent("pounce_stopped", Event_PounceChargeEnd); //There's also a pounce_end event, will have to check what the difference is, pounce end does some wierd shit D:
    HookEvent("charger_pummel_end", Event_PounceChargeEnd);
    HookEvent("charger_carry_end", Event_PounceChargeEnd);
    HookEvent("player_bot_replace", Event_PlayerBotReplace);
    HookEvent("bot_player_replace", Event_BotPlayerReplace);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    
    PrintToChatAll("[StaggerBlock] Loaded");
    PrintToServer("[StaggerBlock] Loaded");
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    ResetStaggerBlocked();
    PrintToChatAll("[StaggerBlock] Reset stagger array, Round End");
    PrintToServer("[StaggerBlock] Reset stagger array, Round End");
}

public OnMapEnd()
{
    ResetStaggerBlocked();
    PrintToChatAll("[StaggerBlock] Reset stagger array, End of Map");
    PrintToServer("[StaggerBlock] Reset stagger array, End of Map");
}

//Called when a Player replaces a Bot
public Action:Event_BotPlayerReplace(Handle:event, const String:name[], bool:dontBroadcast) 
{
    new player = GetClientOfUserId(GetEventInt(event, "player"));
    new SurvivorCharacter:charIndex = IdentifySurvivor(player);
    if (charIndex == SC_NONE) return;
    
    if (isSurvivorStaggerBlocked[charIndex])
    {
        //Not really necessary since it should on next tick unhook as the survivor will immediately get up, but doesn't hurt and might change in the future.
        SDKHook(player, SDKHook_PostThink, OnThink);
    }
    
    PrintToChatAll("[StaggerBlock] %i was just replaced by a player", charIndex);
    PrintToServer("[StaggerBlock] %i was just replaced by a player", charIndex);
}

//Called when a Bot replaces a Player
public Action:Event_PlayerBotReplace(Handle:event, const String:name[], bool:dontBroadcast) 
{
    new bot = GetClientOfUserId(GetEventInt(event, "bot"));
    new SurvivorCharacter:charIndex = IdentifySurvivor(bot);
    if (charIndex == SC_NONE) return;
    
    if (isSurvivorStaggerBlocked[charIndex])
    {
        //Not really necessary since it should on next tick unhook as the survivor will immediately get up, but doesn't hurt and might change in the future.
        SDKHook(bot, SDKHook_PostThink, OnThink);
    }
    
    PrintToChatAll("[StaggerBlock] %i was just replaced by a bot", charIndex);
    PrintToServer("[StaggerBlock] %i was just replaced by a bot", charIndex);
}

//Only odd thing that happens is that when a charger knocks a survivor up against a wall and is then immediately cleared, the player will still have to get up
//but the pummel does not begin so there is no call to charger_pummel_end, this is why we're including the charger_carry_end and then checking .2 seconds later
//if they are in getup animation or if they are still being pummelled
public Action:Event_PounceChargeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "victim"));
    new SurvivorCharacter:charIndex = IdentifySurvivor(client);
    if (charIndex == SC_NONE) return;
    
    //May change this so charger_carry_end has a timer before being added into the array as a stagger blocked player, to stop the rare occasion where the player is stagger blocked between a long charge and a pummel
    CreateTimer(0.2, HookOnThink, client);
    isSurvivorStaggerBlocked[charIndex] = true;
    
    PrintToChatAll("[StaggerBlock] %i has been stagger blocked", charIndex);
    PrintToServer("[StaggerBlock] %i has been stagger blocked", charIndex);
}

//possible issue if player disconnects during the 0.1 second timer?
//If player disconnects during the 0.1 second timer then hook won't be called and they'll be vulnerable to staggers, BUT
//when a player leaves or joins the bot/player immediately completes the getup animation
public Action:HookOnThink(Handle:timer, any:client)
{
    //check to see if valid client due to above reasons
    if (client && IsClientInGame(client) && IsSurvivor(client))
    {
        SDKHook(client, SDKHook_PostThink, OnThink);
    }
    
}

//Using on think think because of possible pauses, must automatically unhook when player disconnects, did tests this seems to be the case
//Could make a timer that runs for the length of time that the animation runs for, (pause/disconnect/connect issues?)
//Timers would be too strict on what I can do I think
public OnThink(client)
{
    new SurvivorCharacter:charIndex = IdentifySurvivor(client);
    if (charIndex == SC_NONE) return;
    
    new sequence = GetEntProp(client, Prop_Send, "m_nSequence");
    if (sequence != getUpAnimations[charIndex][0] && sequence != getUpAnimations[charIndex][1] && sequence != getUpAnimations[charIndex][2] && sequence != getUpAnimations[charIndex][3]&& sequence != getUpAnimations[charIndex][4])
    {
        isSurvivorStaggerBlocked[charIndex] = false;
        SDKUnhook(client, SDKHook_PostThink, OnThink);
        
        PrintToChatAll("[StaggerBlock] %i is no longer stagger blocked", charIndex);
        PrintToServer("[StaggerBlock] %i is no longer stagger blocked", charIndex);
    }
}

public Action:L4D2_OnStagger(target, source) 
{
    if (source != 0 && IsInfected(source))
    {
        new L4D2_Infected:sourceClass = GetInfectedClass(source);
        
        if ((sourceClass == L4D2Infected_Hunter || sourceClass == L4D2Infected_Jockey))
        {
            new SurvivorCharacter:charIndex = IdentifySurvivor(target);
            if (charIndex == SC_NONE) return Plugin_Continue;
            
            if (isSurvivorStaggerBlocked[charIndex])
            {
            
                PrintToChatAll("[StaggerBlock] %i has had a stagger blocked", charIndex);
                PrintToServer("[StaggerBlock] %i has had a stagger blocked", charIndex);
                
                return Plugin_Handled;
            }
        }
    }

    return Plugin_Continue;
}

public ResetStaggerBlocked()
{
    for (new i = 0; i < 8; i++)
    {
        isSurvivorStaggerBlocked[i] = false;
    }
}