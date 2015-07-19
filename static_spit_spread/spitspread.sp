#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>

#define	MAX_SPIT_PUDDLES		9

#define	DEVIATION				65.0
#define	HYPOTENUSE_MIDDLE(%0)	((SquareRoot((((%0)*(%0)) + ((%0)*(%0))))) / 2.0)

new puddles = 0;
new Float:spitSpot[3];

public Plugin:myinfo =
{
	name = "Test",
	author = "Visor",
	description = "",
	version = "1.3", //cvar dat shit
	url = "https://github.com/Attano/L4D2-Competitive-Framework"
};

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "insect_swarm"))
	{
		puddles = 0;
	}
}

public Action:L4D2_OnSpitSpread(spitter, projectile, &Float:x, &Float:y, &Float:z)
{
	// Death puddle
	if (GetSpitLifetime(projectile) <= 2)
	{
		return Plugin_Continue;
	}
	
	// Overdue logic
	if (puddles == -1 || puddles >= MAX_SPIT_PUDDLES)
	{
		SetSpitLifetime(projectile, 0);
		return Plugin_Handled;
	}
	
	if (puddles == 0)
	{
		PrintToChatAll("\x01hyptoenuse: \x05%f\x01", HYPOTENUSE_MIDDLE(DEVIATION));
		SetSpitLifetime(projectile, 100);
		GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", spitSpot);
	}
	
	switch (puddles)
	{
		case 0:
		{
			x = spitSpot[0];
			y = spitSpot[1];
			CreateSpitParticles(x, y, z, 7.0);
		}
		case 1:
		{
			x = spitSpot[0] + DEVIATION;
			y = spitSpot[1];
			CreateSpitParticles(x, y, z, 6.9);
		}
		case 2:
		{
			x = spitSpot[0] - DEVIATION;
			y = spitSpot[1];
			CreateSpitParticles(x, y, z, 6.8);
		}
		case 3:
		{
			x = spitSpot[0];
			y = spitSpot[1] + DEVIATION;
			CreateSpitParticles(x, y, z, 6.7);
		}
		case 4:
		{
			x = spitSpot[0];
			y = spitSpot[1] - DEVIATION;
			CreateSpitParticles(x, y, z, 6.6);
		}
		case 5:
		{
			x = spitSpot[0] + HYPOTENUSE_MIDDLE(DEVIATION);
			y = spitSpot[1] + HYPOTENUSE_MIDDLE(DEVIATION);
			CreateSpitParticles(x, y, z, 6.5);
		}
		case 6:
		{
			x = spitSpot[0] + HYPOTENUSE_MIDDLE(DEVIATION);
			y = spitSpot[1] - HYPOTENUSE_MIDDLE(DEVIATION);
			CreateSpitParticles(x, y, z, 6.4);
		}
		case 7:
		{
			x = spitSpot[0] - HYPOTENUSE_MIDDLE(DEVIATION);
			y = spitSpot[1] + HYPOTENUSE_MIDDLE(DEVIATION);
			CreateSpitParticles(x, y, z, 6.3);
		}
		case 8:
		{
			x = spitSpot[0] - HYPOTENUSE_MIDDLE(DEVIATION);
			y = spitSpot[1] - HYPOTENUSE_MIDDLE(DEVIATION);
			CreateSpitParticles(x, y, z, 6.2);
		}
		default:
		{
			return Plugin_Continue;
		}
	}
	
	PrintToChatAll("\x01Returning values: \x05%d\x01 \x05%d\x01 \x05%d\x01", RoundFloat(x), RoundFloat(y), RoundFloat(z));
	puddles++;
	return Plugin_Continue;
}

CreateSpitParticles(Float:x, Float:y, Float:z, Float:lifetime)
{
	// decl Float:origin[3];
	// origin[0] = x;
	// origin[1] = y;
	// origin[2] = z;
	// new particle = CreateEntityByName("info_particle_system");
	// TeleportEntity(particle, origin, NULL_VECTOR, NULL_VECTOR);
	// DispatchKeyValue(particle, "effect_name", "spitter_slime_spot");
	// DispatchKeyValue(particle, "targetname", "particle");
	// DispatchSpawn(particle);
	// ActivateEntity(particle);
	// AcceptEntityInput(particle, "start");
	// CreateTimer(lifetime, DestroyParticle, particle, TIMER_FLAG_NO_MAPCHANGE);
}

// public Action:DestroyParticle(Handle:timer, any:entity)
// {
	// if (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity))
	// {
		// AcceptEntityInput(entity, "Kill");
	// }
// }

GetSpitLifetime(projectile)
{
	return GetEntData(projectile, 2980);
}

SetSpitLifetime(projectile, iterations)
{
	SetEntData(projectile, 2980, iterations);
	if (iterations == 0)
	{
		puddles = -1;
	}
}