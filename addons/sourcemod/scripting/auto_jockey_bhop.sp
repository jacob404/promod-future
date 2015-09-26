#include <sourcemod>
#include <l4d2util>

#define CVAR_FLAGS			FCVAR_PLUGIN|FCVAR_NOTIFY

public Plugin:myinfo = 
{
    name = "Jockey Bunny Hop Grace Period",
    author = "Standalone (aka Manu)",
    description = "Extends the window where a Jockey can bunny hop",
    version = "1.0",
    url = ""
};

new Handle:autoBunnyCooldown        = INVALID_HANDLE;
new Handle:autoBunnyDuration        = INVALID_HANDLE;
new Handle:autoBunnyGhostEnabled    = INVALID_HANDLE;
new Handle:autoBunnyEnabled         = INVALID_HANDLE;

new bool:jumpButtonDown[MAXPLAYERS + 1];
new Float:lastAutoBunnyTime[MAXPLAYERS + 1];

public OnPluginStart()
{
    autoBunnyCooldown = CreateConVar("jockey_bunny_cooldown", "0.5", "Time between auto bunny hop grace periods", CVAR_FLAGS, true, 0.0);
    autoBunnyDuration = CreateConVar("jockey_bunny_duration", "0.1", "Time allowed for automatic bunny hop periods", CVAR_FLAGS, true, 0.0);
    autoBunnyGhostEnabled  = CreateConVar("jockey_bunny_ghost_enabled", "1.0", "Set whether auto Jockey bunny hops are enabled while in ghost mode. 1 = Enabled", CVAR_FLAGS);
    autoBunnyEnabled  = CreateConVar("jockey_bunny_enabled", "1.0", "Set whether auto Jockey bunny hops are enabled. 1 = Enabled", CVAR_FLAGS);
    
    HookEvent("round_start", Event_RoundStart);
}

public OnPluginEnd()
{
    PrintToChatAll("Disposing of CVAR Handles");
    CloseHandle(autoBunnyCooldown);
    CloseHandle(autoBunnyDuration);
    CloseHandle(autoBunnyGhostEnabled);
    CloseHandle(autoBunnyEnabled);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
    if (GetConVarBool(autoBunnyEnabled))
    {
        //If client is infected and a Jockey
        if (IsInfected(client) && GetInfectedClass(client) == L4D2Infected_Jockey)
        {
            //If jockey is currently ghosted and ghosted bunny hops are disabled then return
            if (!GetConVarBool(autoBunnyGhostEnabled) && IsInfectedGhost(client))
                return;
                
            new Float:cooldown = GetConVarFloat(autoBunnyCooldown);
            new Float:duration = GetConVarFloat(autoBunnyDuration);
            new Float:currentTime = GetGameTime();
            
            //Keep track of when the jump button is initially pressed down
            if (buttons & IN_JUMP)
            {
                //On Jump Button Down
                if (jumpButtonDown[client] == false)
                {
                    jumpButtonDown[client] = true;
                    //If we are out of the auto bunny cooldown time, update the last auto bunny period
                    if (currentTime > lastAutoBunnyTime[client] + cooldown)
                    {
                        lastAutoBunnyTime[client] = currentTime;
                    }
                }
            } 
            else
            {
                jumpButtonDown[client] = false;
            }
            
            //Do auto bunny hop if in grace period
            if (currentTime < lastAutoBunnyTime[client] + duration)
            {
                //if currently holding the jump button down
                if (buttons & IN_JUMP)
                { 
                    //if player is currently in the air
                    //slight issue here if you jump straight onto a ladder while holding down jump, since it's removing IN_JUMP from the input, as soon as you hit the ladder your jump input goes through and you jump off the ladder
                    if (!(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
                    {
                        //remove IN_JUMP from the buttons pressed
                        buttons &= ~IN_JUMP;
                    }
                }
                else //if jump button not held down
                {
                    //if player lands on the ground during the grace period and the jump button is not held, add IN_JUMP to the buttons
                    if ((GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
                    {
                        buttons = buttons + IN_JUMP;
                    }
                }
            }
        }
    }
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
    for (new i = 0; i < MAXPLAYERS + 1; i++)
    {
        jumpButtonDown[i] = false;
        lastAutoBunnyTime[i] = 0.0;
    }
}