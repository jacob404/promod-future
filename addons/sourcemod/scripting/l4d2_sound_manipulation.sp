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
#include <sdktools> // For sound hooks
// #include <crc32> // To convert sound strings into closed caption hashes

public Plugin:myinfo =
{
	name = "Sound Manipulation",
	// Everyone who was in one of these plugins: hunter_callout_blocker, l4d_inaudible_ghosts, l4d2_sound_manipulation, l4d2_unsilent_jockey
	author = "Sir, AtomicStryker, DieTeeTasse, ProdigySim, High Cookie, darkid",
	description = "Blocks certain sounds, replaces others, creates more.",
	version = "2.0",
	url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

// It would appear to be impossible to fix the coach melee sound bug, since SoundHook doesn't ever trigger for it.

new const String:jockeySounds[10][] =
{
	"player/jockey/voice/idle/jockey_spotprey_01.wav",
	"player/jockey/voice/idle/jockey_spotprey_02.wav",
	"player/jockey/voice/idle/jockey_lurk01.wav",
	"player/jockey/voice/attack/jockey_lurk02.wav",
	// "player/jockey/voice/idle/jockey_lurk03.wav", // Kinda quiet
	"player/jockey/voice/idle/jockey_lurk04.wav",
	"player/jockey/voice/idle/jockey_lurk05.wav",
	"player/jockey/voice/idle/jockey_lurk06.wav",
	"player/jockey/voice/idle/jockey_lurk07.wav",
	"player/jockey/voice/idle/jockey_lurk09.wav",
	"player/jockey/voice/idle/jockey_lurk11.wav"
};

new Handle:blockHBSound;
new isGhostOffset;
new Handle:soundHashes;
new Float:lastJockeySound;
new Float:lastSurvivorVoiceCommand[2048];

public OnPluginStart()
{
	blockHBSound = CreateConVar("sound_block_heartbeat", "0", "Block the Heartbeat Sound, very useful for 1v1 matchmodes");

	soundHashes = CreateArray();

	isGhostOffset = FindSendPropInfo("CTerrorPlayer", "m_isGhost");

	// Used to detect jockey spawns.
	HookEvent("player_spawn", PlayerSpawn);

	// Used to block sounds from being played
	AddNormalSoundHook(NormalSHook:SoundHook);
	// Used to block CCs from being played
	HookUserMessage(GetUserMessageId("CloseCaption"), CloseCaptionHook, true);
}

public OnMapStart() {
	PreloadSounds(jockeySounds, sizeof(jockeySounds));
}

PreloadSounds(const String:sounds[][], size) {
	for (new i=0; i<size; i++) {
		PrefetchSound(sounds[i]);
		PrecacheSound(sounds[i], true);
		// I'll use this when I'm sure crc32 hashing works. Until then, we have a fixed array.
		// new hash = Hash(sounds[i]);
		// PushArrayCell(soundHashes, hash);
	}
	if (GetArraySize(soundHashes) > 0) return;
	// Coach
	PushArrayCell(soundHashes, -1789308882);
	PushArrayCell(soundHashes, -497131336);
	PushArrayCell(soundHashes, 2069311746);
	// Rochelle
	PushArrayCell(soundHashes, -1927922847);
	PushArrayCell(soundHashes, 337603291);
	PushArrayCell(soundHashes, 1662540365);
	// Nick
	PushArrayCell(soundHashes, -2055529376);
	PushArrayCell(soundHashes, -183375633);
	PushArrayCell(soundHashes, 455051715);
	PushArrayCell(soundHashes, 1813559637);
	// Ellis
	PushArrayCell(soundHashes, -1362875844);
	PushArrayCell(soundHashes, -641525078);
	PushArrayCell(soundHashes, 815841183);
	PushArrayCell(soundHashes, 1086999312);
	// Francis
	PushArrayCell(soundHashes, -2116245366);
	PushArrayCell(soundHashes, -153380836);
	PushArrayCell(soundHashes, 1876085158);
	// Louis
	PushArrayCell(soundHashes, -1990306432);
	PushArrayCell(soundHashes, -27695850);
	PushArrayCell(soundHashes, 1733309612);
	// Zoey
	PushArrayCell(soundHashes, -2008231496);
	PushArrayCell(soundHashes, -11804370);
	PushArrayCell(soundHashes, 1715646612);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0 || client > MaxClients) return;
	if (!IsClientInGame(client)) return;
	if (GetGameTime() - lastJockeySound < 0.1) return;
	lastJockeySound = GetGameTime();
	EmitRandomSound(jockeySounds, sizeof(jockeySounds), client);
}

EmitRandomSound(const String:sounds[][], size, client) {
	new rand = GetRandomInt(0, size);
	EmitSoundToAll(sounds[rand], client, SNDCHAN_VOICE);
}

public Action:SoundHook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity) {
	if (StrEqual(sample, "player/heartbeatloop.wav")) {
		if (GetConVarBool(blockHBSound)) {
			return Plugin_Handled;
		}
	} else if (StrEqual(sample, "player/jumplanding_zombie.wav")) {
		if (GetEntData(entity, isGhostOffset)) {
			numClients = 0;
			for (new client=1; client<=MaxClients; client++) {
				if (!IsClientInGame(client)) continue;
				if (IsFakeClient(client)) continue;
				if (GetClientTeam(client) == 2) {
					clients[numClients++] = client;
				}
			}
			return Plugin_Changed;
		}
	} else if (StrContains(sample, "WarnHunter") != -1) {
		// These are the hunter callouts. They can be called before the hunter starts crouching, which is bad.
		return Plugin_Handled;
	} else if (StrContains(sample, "jockey/voice") != -1) {
		// Don't spam jockey sounds.
		if (GetGameTime() - lastJockeySound < 0.1) {
			return Plugin_Handled;
		} else {
			lastJockeySound = GetGameTime();
		}
		numClients = 0;
		for (new client=1; client<=MaxClients; client++) {
			if (!IsClientInGame(client)) continue;
			if (IsFakeClient(client)) continue;
			// Play this sound to all real, non-bot clients.
			clients[numClients++] = client;
		}
		return Plugin_Changed;
	} else if (StrContains(sample, "survivor\\voice") != -1) {
		if (!IsClientInGame(entity)) return Plugin_Continue;
		if (GetGameTime() - lastSurvivorVoiceCommand[entity] < 1.0) {
			return Plugin_Handled;
		} else {
			lastSurvivorVoiceCommand[entity] = GetGameTime();
		}
	}
	return Plugin_Continue;
}

public Action:CloseCaptionHook(UserMsg:msg_id, Handle:msg, const players[], playersNum, bool:reliable, bool:init) {
	new hash = BfReadNum(msg);
	if (FindValueInArray(soundHashes, hash) != -1) return Plugin_Handled;
	return Plugin_Continue;
}

// Hash(String:name[]) {
	/* First, a number of things happen within SoundEmitterSystem.cpp [https://github.com/Sandern/aswscratch/blob/master/src/game/shared/SoundEmitterSystem.cpp]:
	 * 0. EmitSoundByHandle() [#L536] gets called from somewhere.
	 * 1. EmitClosedCaption() [#L756] gets called [#L659].
	 * 2. GetCaptionHash() [#L1142] gets called [#L855] or [#L860].
	 * 3. CaptionLookup_t.setHash() gets called [#L1148].
	 * This function is part of captioncompiler.h [https://github.com/Sandern/aswscratch/blob/master/src/public/captioncompiler.h]
	 * CRC32_t.ProcessBuffer() is called [#L51].
	 * As far as I can tell, this is a part of the C++ mux library: [http://frontiermux.com/src/mux2/html/svdhash_8h.html#1f59ad0487ae09edc583bc2f97683cc7]. Regardless, CRC32 is a standard hash, and someone has already implemented it for me.
	*/
//	return crc32_arr(name);
// }
