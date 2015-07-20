#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#undef REQUIRE_PLUGIN
#include <pause>

new Handle:hStaggerBlockedClients = INVALID_HANDLE;
new Handle:hCvarStaggerBlockTime = INVALID_HANDLE;
new Float:lastPauseTime;

new bool:testdebug = true;

//Not using Sourcemod timers because pausing the game with the pause plugin does not stop the server ticks.
//Need to see what pounce things get called when a boomer esplodes next to a pounced survivor

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
    HookEvent("pounce_stopped", Event_PounceStopped); //There's also a pounce_end event, will have to check what the difference is
    HookEvent("charger_pummel_end", Event_PummelEnd);

    //Called when a Bot replaces a Player. (Disconnects?)
    HookEvent("player_bot_replace", Event_PlayerBotReplace);
    //Called when a Player replaces a Bot. (Connection?)
    HookEvent("bot_player_replace", Event_BotPlayerReplace)
    
    HookEvent("versus_round_start", Event_VersusRoundStart);
    HookEvent("player_death", Event_PlayerDeath);
    
    hCvarStaggerBlockTime = CreateConVar("stagger_block_time", "1.2", "How long are survivors immune to stagger?", FCVAR_PLUGIN, true, 0.0);
    hStaggerBlockedClients = CreateTrie();
}


//Will deal with pauses and unpauses later once everything else is working
public OnUnpause()
{
    //Do stuff for unpause
}

public OnPause()
{
    //Do stuff for pause
}


public Action:Event_VersusRoundStart (Handle:event, const String:name[], bool:dontBroadcast)
{
    ClearTrie(hStaggerBlockedClients);
}

public Action:Event_PlayerDeath (Handle:event, const String:name[], bool:dontBroadcast)
{
    new userid = GetEventInt(event, "userid");
    
    if (IsStaggerBlocked(userid)) 
    {
        RemoveFromStaggerBlocked(userid);
    }
}

//Called when a Bot replaces a Player. (Disconnects?)
public Action:Event_PlayerBotReplace (Handle:event, const String:name[], bool:dontBroadcast)
{
    /*
    if player being replaced is in trie
        remove the entry with the player id as the key
        add entry with bot id as key, and use previous immuneUntil time
    */
}

//Called when a Player replaces a Bot. (Connection?)
public Action:Event_BotPlayerReplace (Handle:event, const String:name[], bool:dontBroadcast)
{
    /*
    if bot being replaced is in trie
        remove the entry with the bot id as the key
        add entry with player id as key, and use previous immuneUntil time
    */
}

public Action:Event_PounceStopped (Handle:event, const String:name[], bool:dontBroadcast)
{
    //Put a check here to see if the player is actually incapped, in which case we don't want to add them to stagger blocked
    //Doesnt really matter but I still want it there.
    
    if (testdebug)
        PrintToChatAll("Pounce stopped");
    
    new victimid = GetEventInt(event, "victim");
    AddToStaggerBlocked(victimid);
}

public Action:Event_PummelEnd (Handle:event, const String:name[], bool:dontBroadcast)
{
    //Put a check here to see if the player is actually incapped, in which case we don't want to add them to stagger blocked
    //Doesnt really matter but I still want it there.
        
    new victimid = GetEventInt(event, "victim");
    AddToStaggerBlocked(victimid);
}

//Maybe instead of checking on think, just check OnStagger and if it's been more than 1.2 seconds since last stagger then remove from Trie
//and on pounce/charge clear just update the time at which they were incapped
public Action:L4D2_OnStagger(target, source) 
{
    //if source is infected (hunter/jockey)
        if (IsSurvivor(target))
        {
            //If we use a Trie
            decl String:strClient[10];
            IntToString(target, strClient, sizeof(strClient));
            new Float:immuneUntil;
            new Float:currentTime;
            new Float:staggerBlockTime;
            
            if (GetTrieValue(hStaggerBlockedClients, strClient, immuneUntil))
            {   
                if (testdebug)
                        PrintToChatAll("%i is in the trie", target);
                staggerBlockTime = GetConVarFloat(hCvarStaggerBlockTime);
                immuneUntil += staggerBlockTime;
                currentTime = GetGameTime();
                
                if (testdebug)
                        PrintToChatAll("%i is immuneUntil %f", target, immuneUntil);
                
                if (immuneUntil >= currentTime)
                {
                    if (testdebug)
                        PrintToChatAll("Blocking stagger for %i", target);
                    return Plugin_Handled; //Block the Stagger
                }
                else 
                {
                    if (testdebug)
                        PrintToChatAll("Removing %i from the trie", target);
                    //Not sure if there's any point in removing them here other than to keep the trie small which is always good
                    RemoveFromStaggerBlocked(target);
                }
            } else {
                if (testdebug)
                    PrintToChatAll("Staggering %i", target);
            }
        }

            //If we use an adt_array
            //probably won't
    
    return Plugin_Continue;
}

/*
public Float:GetImmuneTime(userid)
{
    new client = GetClientOfUserId(userid);
    decl String:strClient[10];
    IntToString(client, strClient, sizeof(strClient));
    new Float:value;
    
    if (GetTrieValue(hStaggerBlockedClients, strClient, value))
    {
        return value;
    } 
    else 
    {
        return -1.0;
    }
}
*/

public GetClientId(userid)
{
    new client = userid;
    
    if (userid > MaxClients) 
    {
        client = GetClientOfUserId(userid);
    } 
    
    return client;
}

public bool:IsStaggerBlocked(userid) 
{
    decl String:strClient[10];
    new client = GetClientId(userid);
    IntToString(client, strClient, sizeof(strClient));
        
    new Float:value;
    
    return GetTrieValue(hStaggerBlockedClients, strClient, value);
}

public RemoveFromStaggerBlocked(userid)
{
    decl String:strClient[10];
    new client = GetClientId(userid);
    IntToString(client, strClient, sizeof(strClient));
    
    RemoveFromTrie(hStaggerBlockedClients, strClient);
}

public AddToStaggerBlocked(userid)
{
    decl String:strClient[10];
    new client = GetClientId(userid);
    IntToString(client, strClient, sizeof(strClient));
    new Float:currentTime = GetGameTime() //Game time increases while paused, fix the values in the OnUnpause
    
    SetTrieValue(hStaggerBlockedClients, strClient, currentTime);
    
    if (testdebug)
        PrintToChatAll("%s id was added to hStaggerBlocked with current time %f", strClient, currentTime);
}