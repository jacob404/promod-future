#pragma semicolon 1

#include <sourcemod>
#include <sdktools>


public Plugin:myinfo = 
{
    name = "Force Credits",
    author = "Jacob",
    description = "Forces the credits / stats to display at the end of a game.",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
        RegAdminCmd("sm_forcecredits", ForceCredits_Cmd, ADMFLAG_BAN, "Forces the outro credits to roll.");
        RegAdminCmd("sm_forcestats", ForceStats_Cmd, ADMFLAG_BAN, "Forces the stats crawl to roll.");
}

public Action:ForceStats_Cmd(client, args)
{
    ModifyEntity("env_outtro_stats", "RollStatsCrawl");
    PrintToChatAll("Stats should be crawling.");
}

public Action:ForceCredits_Cmd(client, args)
{
    ModifyEntity("env_outtro_stats", "RollCredits");
    PrintToChatAll("Credits should be rolling.");
}


ModifyEntity(String:className[], String:inputName[])
{ 
    new iEntity;

    while ( (iEntity = FindEntityByClassname(iEntity, className)) != -1 )
    {
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) )
        {
            continue;
        }
        AcceptEntityInput(iEntity, inputName);
    }
}