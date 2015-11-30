4.5
- Blocked audio lines and captions for when a survivor sees a hunter, to prevent sneaky hunters being exposed.
- Fixed tanks dealing self-damage with hittables.
- Added AutoPause: Game automatically pauses when a player crashes. If an infected player crashes, their spawn timer is restored upon rejoining.
- Fixed various double-getups.
- Fixed a bug where punching a player who was jockeyed would not give them a getup.
- When a player is rocked and then punched, they will undergo a punch getup animation after the rock animation ends.
- Witches now deal continuous damage like Hunters and Jockeys. This makes the damage more accurate to her animations.
- Tanks no longer go AI after third pass, instead they are set on fire. Current burn time is 30 seconds.
- After the tank fight, the infected team will now see damage dealt to health bonus, rather than damage dealt to tank. Spectators see both.
- Votes can now be called 40s after map change or once 6 players have loaded.
- Survivors can no longer shove other survivors, which slowed them and shook their screen.
- Survivors now have infinite ammo during readyup, meaning they can no longer run out of ammo pregame on dead center or hard rain.
- The bunny-hopping window as jockey has been extended by .05 seconds.
- Survivors are no longer slowed / held in place after being cleared from a smoker, they can now instantly move at full speed.
- Tank slowdown is now proportional based on weapon and distance: Uzis deal 80% slowdown, shotguns deal 50%. When an uzi deals 1 damage, it provides <1% slowdown to the tank.
- Survivors will now take a maximum of 30 fall damage if they are pounced or jockeyed while on the no mercy 3 sewer ladder.
- Updates to spechud:
-- Health Bonus / Damage Bonus is now visible
-- Changed 'P', 'DP', 'M', and 'DE' to 'Pistol', 'Dual Pistols', 'Melee', and 'Deagle' respectively
-- Added health for ghost infected
- Who will become tank is now printed to casters on round start.
- Spawns out of saferoom can now be checked manually by all players by typing !spawns (sm_spawns). They will still be automatically printed to the survivors on round start.
- Fixed a bug where spectators could !unready and cancel countdown.
- Added red flash when a tank gets melee'd (from EQ)
- You can change from boomer to spitter (and back) while tank is up by right-clicking.
- Fixed a bug where spitter limit didn't get reset if tank disconnected, was sm_kicked, or level was changed via changelevel or sm_map.
- Pistol fire rate is now capped: 0.1 seconds for dual pistols, 0.2 seconds for single, and 0.3 while incapped.
- Dual pistols can be autofired by holding mouse1 at 0.3 seconds per shot.
- Special infected no longer deal damage to witches. Scratch away!
- Health bonus now correctly handles incapped and ledge-hung survivors.
- Health bonus can no longer be manipulated by passing pills.
- Made another attempt to fix silent jockeys. If you have any recorded evidence (demo, cast) of this taking place, please tell us!

4.4.2
- Fixed some unbreakable doors becoming breakable on round start.
- Fixed fire, again. (Molotovs have not been re-added yet)
- Fixed a way that infected were still able to skip their death cams.
- Fixed all survivors being warped when only one attempted to leave saferoom during readyup.
- Fixed !cast. Please ensure that when using sm_add_caster_id (such as in confogl_personalize.cfg), you always use STEAM_1 ids rather than STEAM_0.
- Usage of !cast: If a user has been added as a caster, they can type !cast (sm_cast) to self-register. Admins can type !caster <username> (sm_caster <username>) to explicitly add someone.
- Casters now have access to sv_cheats commands, such as fog_enable, mat_fullbright, or mat_postprocess_enable. Cheat cvars will be reset upon joining a team.

4.4.1
- Fixed some instances of survivors dropping their weapons when punched by tank on high tick rate servers.
- Removed molotovs since tanks are still being lit. I will re-add them when I am certain they are working.
- Enabled upgraded weapons in some start saferooms. (c1m4, c2m3, c3m4, c4m2, c5m1, c5m5)
- Lowered boomer horde call per survivor from 18 to 13. Max is still 30 (AKA Boomer Horde scale changed from: 18/30/30/30 to 13/26/30/30)

4.4
- Players are no longer able to skip their death cam as infected to manipulate their spawn time and sac order. (Pro Mod and Reflux only)
- Spawn timers reduced by 2 seconds in Pro Mod and Reflux.
- Removed custom bonesaw effects. (I got more complaints about them than expected, contact me if you wanna talk about it)
- Doors and breakable props can no longer be broken during readyup.
- Updated readyup so that only the survivor who attempts to leave saferoom will be warped back, rather than the whole team.
- Fixed melee weapons not being limited to 0 in Reflux.
- Common infected will no longer fight each other.
- Removed "Found x in x team. Moved him back to spec team." print.
- Removed "<TankPunchStuck> Found x stuck after a punch. Warped him to a valid position" print.
- Survivors will no longer have a forced delay between melee swings after being punched.
- Survivors will now be forced to pull out their primary weapon (if they have ammo available) when punched by tank.
- Survivors will no longer "slide" if they are stumbled while in a get-up animation. Boomers are an exception and will still push survivors.
- Potentially fixed Swamp Fever finale bugging out for the 2nd team if the 1st team wipes before starting the finale.
- Fixed Autocommunicator getting stuck on "Spit on this!"
- Fixed a bug where infected wouldn't be extinguished when lit on fire.
- By default, all saferooms will now have the unsilenced uzi and pump shotgun. We will be enabling the upgraded weapons based on map balance going into the future.


4.3.1
General-

- Fixed some instances where tanks could be lit on fire.
- Fixed a bug where you would pull your melee out slower when switching from your primary weapon.
- Fixed shotgun spread not being properly adjusted to 3.5

Reflux-

- Fixed spitters spawning in Reflux.
- Fixed hunter limit not being set to 2 in Reflux.
- Fixed shotguns not being limited to 3 in Reflux.

Map Changes-

Dead Center 1:
- You will no longer be pushed by the fire on the bottom floor.
- Removed dressers blocking the window deathcharge at the beginning of the map.
- Fixed a prop being nonsolid near the end of the map.
Dark Carnival 2:
- Blocked an out of bounds spot near the warehouse.
- Repositioned hittable forklift at the start to be in a less awkward position.
- Removed 2 green trash cans near forklift.
- Revamped bush props on elevated area near the start. They should now go around the entire perimeter, take up less space, and will no longer block the infected ladders.
- Added a way Special Infected can get onto the building in the corner near the warehouse.
Dark Carnival 3:
- Fixed pill cabinet having more than 2 pills.
- Blocked an exploit where you could stand on a small corner in the one way drop hole to avoid falling down.
- Blocked a stuck spot near the event button building at the end of the map.
- Blocked an exploit to skip the coaster ramp drop choke.
Dark Carnival 4:
- Blocked a stuck spot under an awning on the barn rooftop.
Swamp Fever 1:
- Blocked a stuck spot next to the white tank next to the gas station at the start.
- Blocked Survivors from getting punched onto the above white tank.
Hard Rain 1:
- Fixed Survivors being able to be punched onto the bushes near the end.
- Blocked a god spot on an edge of the Burger Tank sign.
- Made alarm car spawning logic match campaign mode.
Hard Rain 2 & 3:
- Removed Valve clips in the ramp drop building that would prevent you from jumping in certain areas. Replaced with remade clips of the correct sizes.
- Fixed getting stuck between an angled pipe on the ground and a walkway above near the ramp drop. Added a small prop as a visual indicator.
Hard Rain 4:
- Fixed Survivors being able to be punched onto the bushes near the beginning.
- Fixed items sometimes spawni!mng in the map 5 Burger Tank area.
- Removed a prop accidentally left in.
- Made alarm car spawning logic match campaign mode.
Hard Rain 5:
- Blocked a god spot on an edge of the Burger Tank sign.
The Parish 1:
- Blocked a stuck spot on a roof near the alley choke.
- Blocked a stuck spot on a roof near the end saferoom.
- Added a path to a tall awning in the right alley at the start.
- Fixed Survivors getting punched over a wall and out of bounds near the start.
The Parish 2:
- Blocked a stuck spot on a roof near the beginning.
- Removed a melee weapon that could spawn out of bounds near the start.
The Parish 3:
- Fixed a stuck spot next to the bridge semi truck.
- Readded fire on the burning car at the end of the bridge.
- Removed two pill spawns that could spawn very far off the main path in the graveyard.
- Removed pill spawns right next to the end saferoom.
The Parish 4:
- Fixed a plant prop in the event area having ice-like attributes when walking on it.
Death Toll 5:
- Fixed Hunters being unable to pounce in the water.
- Added a rock next to the dock to nerf camping there.
- You will now start with a Chrome Shotgun and Silenced SMG.
Dead Air 3:
- Added some minor detail props on the ramp at the start.
Dead Air 4:
- Removed the second event triggered by walking through the metal detector.
- Added a few props to the final stretch to compensate for difficulty change.
- Removed all doors from the map.
- Removed some annoying trash can debris props.
- Allowed Tank to spawn at any point in the map.
- Blocked a stuck spot in the collapsed ceiling at the start.
Cold Stream 1:
- Removed ash particle effects.
- Removed slowdown on log.
- The bunker door now opens 400% faster.
- Banned Tanks from spawning after the one way drop from the cabin.
Cold Stream 2
- Removed ash particle effects.
- Removed static Tank.
- Tanks can now spawn anywhere in the map.
- Tank will now lose rage in the saferoom.
- Removed the event (shooting the exploding barrels will still trigger a horde).
- Reduced the intensity of the bright sun particle effect at the beginning.
Cold Stream 3:
- Blocked death charges off the ladder choke at the start.
- Tweaked ladder choke in a similar manner to Parish 3.
- Blocked 6 stuck spots in tree clusters at the start.
- Banned Tank spawns until after Survivors leave the sewer.
- Nerfed death charges after the exploding tanker event.
- Banned Tanks spawning after the exploding tanker event until Survivors reach the water below.
- Added a path onto end saferoom roof for SI.
- Added a way out of a stuck spot near the end.
Cold Stream 4:
- Now plays like a normal map:
- Finale horde removed.
- Removed static 4 pills on the boat near the waterfall drop, as they are no longer necessary.
- Removed ash particle effects.
- Added a bush spawn outside the exit to the first building.
- Removed hittable log near the end of the river.
- Nerfed ladder choke leading to helicopter by adding boxes to see above the ladder.
Haunted Forest 1:
- Removed rock cluster in the right path where the path splits.  This was originally added in CCT1, but this will reduce 1 choke point from the map.
Haunted Forest 2:
- Added additional piping near the ladder choke in the beginning of the map.  The ladder is now nerfed comparable to the sewer choke on Parish 3.
- Added wooden boards leading to the mountain top above the broken SI ladder just before the alarm car area.  This should add more spawn capabilities and may lead to interesting rock tanks.  Note: The props added here are not enjoyable to walk on, but they're something.
- Removed all hittables from the map except for the alarm car.
Haunted Forest 3:
- Reduced Map Distance Score from 700 to 600
- A burst of horde no longer spawns with the piano tank
- Promod tank is forced to spawn after the 65% mark as to reward teams who kill the piano tank
Haunted Forest 4:
- No more early Promod tanks will spawn
- All brown shotguns and unsilenced uzis are replaced with chrome shotguns and silenced uzis
- The pile of rocks near the railings that enables deathpulls over the railings has been removed.
Dead Before Dawn 1:
- Survivors no longer spawn in the air in the beginning safe room
- Made many hittables non-hittable.
- Infected can now spawn behind the various hedges in the map
- The crazy driver in the beginning will no longer appear (the guy who hit Xbyes tank with his car)
Dead Before Dawn 2:
- Infected can now scratch through the doors throughout the map (allowing for more diverse tank spawns)
- Infected can now scratch through the delivery truck backdoor near the event.
- Survivors now bypass the crank-scavenge event. All areas that were accessible for the crank-scavenge are still accessible.
Dead Before Dawn 3:
- The gun shop is now accessible without a keycard
- The god room no longer insta-kills infected when they enter it
Dead Before Dawn 4:
- The forklift event no longer runs infinitely
- Infected ghosts no longer fall through the floor on the second floor of the mall near the gun shop
- The red propane tank near the end is already in place and ready to be blown, skipping the propane-scavenge portion of the map.
Dead Before Dawn 5:
- There will now always be an early tank again
- Fixed an issue where the second tank would not spawn
- Added more exploit blockers
Carried Off 2:
- Removed shelf prop in the warehouse that was blocking an infected ladder
Detour Ahead 2:
- Made 3 hittable cars, not hittable in the main road before the event
Detour Ahead 4:
- Significantly nerfed the train ladder choke
Detour Ahead 5:
- Reduced Map Distance from 700 to 600 (Vanilla map distance is 800)

4.3
- Melee weapons will spawn less often, and further apart from eachother
- Chrome shotgun spread increased by 16% (3.0 -> 3.5)
- Added molotovs back (Max 1 per map)
- Molotov burn duration reduced to 5 seconds
- Molotov max spread reduced by 20%
- Lighting a witch on fire will now trigger her normally, but will not do any damage.
- Survivors can no longer get a melee off on tank between punches when cornered.
- Chargers and tanks will no longer be slowed down by m2s.
- Removed charger chestbump plugin.
- Fixed some Pro Mod features not carrying over to Reflux.
- You now bleed out normally in Reflux.
- Fixed quad caps not working in Reflux.
- Fixed 25 damage pounces not working in 1v1s.


4.2.2
General-

- Fixed melee weapons standing straight up.
- Fixed bile bombs spawning in places they shouldn't
- Reverted the melee weapon reduction change.
- Players can now easily communicate some game events using !autocom. (This is an early version of this feature, much more will be added later)
- Disabling lag compensation is no longer allowed in Pro Mod. (Temporary fix to an exploit. In the future you will just not be allowed to toggle it.)
- Added caster addons support and improved camera control for spectators.
- Added custom bonesaw effects for a few players.
- Updated l4d2lib, fixing some error spams.

Map Changes-

Dark Carnival 3:
- Blocked god spot underneath the first ramp of the coaster.
- Blocked several shortcuts on the coaster.
- Pill cabinet max pills reduced from 4 to 2.
- Added 2 possible pill spawns to the coaster.
- Added a melee weapon at the bottom of the coaster.
No Mercy 3:
- The metal door after the event will now open 20 seconds after pressing the button, instead of never opening.


4.2.1
General-

- The 2014 Pro Mod Winter Event has come to an end. Don't be sad though, Spring is just around the corner!
- Updated Tank Rock Stumble Block plugin.
- Fixed local mute plugin not loading due to missing translation files.
- Changed local mute commands from !mute and !unmute to !smute and !sunmute to avoid conflicts.
- Updated GeoIP Database.
- Updated dozens of outdated retro stripper files.

Map Changes-

Dark Carnival 1:
- Blocked a stuck spot on top of the bridge semi truck.
- Added an ammo pile spawn in the corner motel room near the police car.
- Made the path to the motel roof spawn require less jumping.
Dark Carnival 2:
- Fixed Chargers getting stuck on the lip of the ramp charge-off at the ladder choke.
- Blocked witches from spawning during the event.
Dark Carnival 3:
- Blocked Suvivors from getting on the shelves in the room after the swan maintenence room, as common cannot path there.
Dark Carnival 4:
- Blocked Survivors from getting on top of the tents before the end saferoom, as common cannot path there.
- Fixed not always being able to charge, jockey, and pull survivors off the lower barn roof sections without getting blocked.
- Blocked witches from spawning during the event.
Dark Carnival 5:
- Fixed sometimes getting Tank-punch-stuck in ceiling clips in the stadium.
- Reduced the volume of overhead fireworks.
The Parish 2:
- Improved clipping on new wall on the right side of the park.
- Fixed getting stuck on an awning while climbing up an SI ladder during the event.
- Lowered witch max spawn % to 95% to prevent witches spawning in saferoom.
The Parish 5:
- Blocked Survivors from jumping onto the semi at the start.
- Fixed Survivors getting Tank punched onto the tall concrete blocks at the start.
- Fixed the 2nd finale tank never spawning.


4.2

- Fixed some incorrect hittable interactions.
- Updated Diescraper Redux files to support latest version.
- Removed a broken witch spawn on Hard Rain 3.
- Removed a broken witch spawn on Swamp Fever 2.
- Boomer hordes will now always be the same size.
- Fixed witches still taking damage from SI.
- Tank can no longer be stumbled while throwing a rock. (This fixes the ghost rock bug)
- You can now locally mute a player with !mute (!unmute to unmute them)
- Updated list of what will be displayed by the Skill Detect plugin.
- Improved a few aspects of infected AI.
- Fixed escape tanks still spawning on Parish 5. (Using a short term fix, looking for a long term alternative.)
- Removed clips around Parish 1 start saferoom.
- Jockeys will now play their bacteria sound upon spawning.
- You will now find less melee weapons throughout maps, and more deagles / pistols in their place.
- Removed the center pellet from the static shotgun spread.
- Fixed chargers chest bumping against survivors if they attempted to charge from too close.
- Fixed some instances where infected would not be be immune to being lit on fire.
- Added custom bonesaw effects for CCT3 winners.
- Added some holiday cheer to servers across the world.


4.1
General-

Witches:
- Witches no longer follow the same spawning limitations as tanks, allowing for a wider range of possible spawns
- Blocked infected friendly fire against witch, excluding tank
- Witch no longer respawns when killed by tank
- Survivors will now receive points if witch is killed by tank
- Witch bonus will no longer print to chat

Tanks:
- Fixed an exploit which allowed Tank to kill incapacitated survivors with random props that aren't supposed to do damage
- Reduced the possibility of hittables doing more than 1 damage instance per tank hit (This means that it's less likely for a log to roll on you and instantly kill you after only 1 tank hit)
- Infected bots will now be kicked 10 seconds after tank spawns if they are not capping a survivor
- Removed water slowdown change prints
- Added an audio cue for tank spawns
- Added a new print for tank spawns: "Tank is now in play"

Survivors:
- All melee weapon spawns are now single pickup
- You now receive your starting pills when the round goes live, rather than when you leave saferoom
- Shoving a special infected will now increase your fatigue by 1
- Restored hunter shove FOV to 30.
- Added static shotgun spread. Values are based off RedTown. (We will continue to look to improve it)
- Fixed all survivors using coach's grunt noise when using melee weapons

Special Infected:
- Infected ghost hurt is now enabled after the round goes live
- Infected ghost warp rebound from Mouse 2 to Reload
- Despawning a special infected will now give you half of your missing HP back (This does not mean half of your max hp)
- Infected can no longer be lit on fire (They will however still take damage while standing in fire)
- Fixed hunters being able to instantly repounce after being shoved

Miscellaneous:
- Removed triggers that forced players to crouch near vents/holes
- Remade stripper path to better cater to side configs using unique stripper folders
- Pro Mod no longer uses the Entity Remover module from confogl (All functions have been replaced by better options)


Map Changes-

Dark Carnival 1:
- Unlocked the motel rooftop for SI
- Blocked the motel rooftop for Survivors
- Added two paths onto the rooftop
- Added some "no entry" markers for SI, to specify where unremovable rooftop clips still remain
- Removed tree before the hill drop
- Blocked the top of a bush next to the campsite hill drop
Dark Carnival 2:
- Blocked the tops of the five porta potties after you leave the warehouse
- Blocked the tops of the two hedges after you leave the warehouse
- Removed sandbags at the start, replaced with an SI ladder (yellow pole)
- Added a ladder choke nerf similar to Parish 3 in hunters configs
Dark Carnival 3:
- The coaster will no longer collide with or damage players and NPCs
- Blocked an exploit to skip the event
- Removed a Valve invisible wall in the swan room
- Added a second shelf above the first to block a spot that commons cannot path to
- Improved clipping on the sides of the shelves in the swan room
- Blocked an unteleportably stuck spot in the swan room
- Improved clip alignment over the hanging fence in the tunnel
- Added a prop to cover up a broken infected ladder
- Blocked players from entering the vent alt path in hunters configs
Dark Carnival 4:
- You can now charge, jockey, and pull survivors off the lower barn roof sections without getting blocked. Removed plank props as they are no longer necessary
- Blocked Survivors from getting on the tops of the bushes after you leave the barns
- Added props to cover up a broken infected ladder
Dark Carnival 5:
- Blocked Survivors from getting hit onto the 9 metal support beams underneath the stadium roof
- Blocked the tops of the 5 upright soda machines around the usual camping spot
- Improved clipping around a trash bin at the top of the stadium
- Blocked an event camping spots under the open tents in hunters configs
Swamp Fever 3:
- Blocked witch spawns during the event as they were often far from the intended path
- Tank will now lose rage normally while survivors are in the saferoom on Swamp Fever 3
Swamp Fever 4:
- Removed a Valve invisible wall near the upstairs event camping area, giving SI access to a breakable wall
- Fixed custom max distance printing despite the distance being default
Hard Rain 1 and 4:
- Improved clipping on a fence near the 2nd floor one way drop on map 4
- Added a minor prop for detail
- Removed a few of the orange cones around map 1 end saferoom/map 4 opening saferoom
- Blocked the top of the fence for Survivors right outside map 1 end saferoom/map 4 end saferoom
Hard Rain 3:
- Blocked a witch spawn at the top of the elevator which could be killed before the door opened.
The Parish 1:
- Fixed pistol sometimes still falling into the water
- Removed a Valve invisible wall that partially blocked access to the end saferoom rooftop
- Added a prop to allow SI to access the end saferoom rooftop
- Added a prop to get out of an unteleportably stuck spot behind a fence
The Parish 2:
- Removed concrete wall props in the open area after the bus station
- Added a wall opposite the one in front of the restrooms in the park
- Additional tree in the park is now slimmer and harder to use as an LOS/juking spot
- Park will continue to be revamped and tweaked based on feedback
The Parish 3:
- Blocked a high tickrate jump onto a tall green fence before the 2nd story drop
- Fixed Survivors getting caught on an unclipped infected ladder
- Blocked early witch spawns that were prone to glitching out
The Parish 4:
- Blocked an event camping spot underneath the stairs in hunters configs
The Parish 5:
- Added an intro tank that will spawn when survivors hit the radio
- Tank will now lose rage while survivors are in the saferoom on Parish 5
- Removed all of the reduced damage cars from the "tank arena" portion of the bridge
- Added a full damage hittable car to the "tank arena" portion of the bridge
- Increased pill count in tank arena from 2 to 4
- Removed the maze of balance after the bridge
- Removed escape tanks
- Increased map distance to 600
Death Toll 1:
- Added a static ammo pile near the end of the tunnel
Death Toll 2:
- Blocked an event camping spot in the rescue closet in hunters configs
Death Toll 3:
- Blocked a high tickrate shortcut to skip the train choke
Death Toll 4:
- Removed 4 pointless pill spawns at the very end
- Fixed pills spawning in the end saferoom
- Blocked a bunch of god-spot shelves in the warehouse behind the convienience store
Dead Air 3:
- Blocked an event camping spot under the pipes in hunters configs
- Blocked an event camping spot in the rescue closet in hunters configs
Dead Air 4:
- Fixed too many commons spawning during the event in 1v1 configs
- Blocked an event camping spot under some stairs in hunter configs
- You will no longer get pushed by the moving event van
Blood Harvest 3:
- Fixed too many commons spawning during the event in 1v1 configs
Blood Harvest 4:
- Removed a pointless invisible wall after exiting the warehouse
- Removed all props except one near end saferoom
Hard Rain: Downpour:
- Fixed stripper file being named incorrectly
- Fixed multiple Witches sometimes spawning


Side Configs-

1v1s:
- Replaced all pumpshotguns with chromes and smgs with silenced uzis
- Hunters can now pounce and scratch through doors instantly
- Common will now instantly destroy doors
- Gas can pour time reduced from 0.7 to 0.5
Reflux:
- Reflux now uses a modified version of Pro Mod's stripper files, rather than Retro's
Hunters:
- All hunter exclusive configs now share a unique stripper folder
Redtown:
- Pro Mod Redtown is now included in the Pro Mod package


4.0.4e
Blocked an out of map stuck spot on Undead Zone finale.
Increased Parish 1 map distance to 400.
Fixed players getting stuck after loading in during a pause.


4.0.4d
The !current command will now be much more accurate relative to tank spawns.
Fixed spawn timers not being properly set in 1v1 configs.
Fixed witches spawning in 1v1s.
Fixed people getting stuck on invis walls in the tunnel of love. (Dark Carnival 3)
Fixed "Fixing Waiting For Finale to Start issue for all infected" printing every round.
Unblocked an early tank spawn on Dark Blood map 2.
Tank will still lose rage while survivors are in saferoom on Dark Blood Map 2.
Blocked tank spawning while survivors are underwater on Dark Blood map 2.
Any tank that spawns after survivors have rode the lift up on Dark Blood map 2 will be spawned near the end saferoom, to give survivors breathing room.
Re-blocked early tanks on Dark Blood map 3.
Unblocked event tanks on Dark Blood 3.
Any tank that spawns after survivors have started the event on Dark Blood map 3 will be spawned at the end saferoom, to give survivors breathing room.
Made it much easier for tank to get out of a "stuck spot" on Dark Blood finale.
Removed all fireworks from Arena Of The Dead.
Removed an unbreakable freezer door from Urban Flight 1.
Made a few (interior) panes of glass breakable on Diescraper Redux Finale.
Fixed a tank stuck spot on Undead Zone finale.


4.0.4c
General-
- Fixed gascans spawning on some peoples servers.
- Vote kick ban time reduced from 5 minutes to 1 in all Pro Mod configs.
- Added support for a shared plugins file. All Pro Mod configs will read from "sharedplugins.cfg" in your left4dead2/cfg/ folder.
- Improved shadowing on a lot of props.
- Cleaned up stripper files.

Map Changes-
Swamp Fever 2:
- Added a spawn near the usual event camping area
- Reduced props near the shack after event
Swamp Fever 4:
- Improved clipping on fallen log that leads to a rooftop (you will no longer get stuck on it)
- Fixed a stuck spot under the planks that lead to the roof
- Blocked Survivors from getting on some bushes near where you enter the town
- Blocked Survivors from climbing the barrel stack intended for SI
- Removed an unecessary prop in the town
- Blocked Survivors from getting punched onto a tall bush in the plantation backyard
- There will now always be a Chrome Shotgun and Silenced SMG in the mansion
- Added an ammo pile and a propane spawn in the plantation backyard
Hard Rain 1 and 5:
- Removed unbreakable porta potty door
Dark Carnival 3:
- You will no longer get stuck inside swans in the Tunnel of Love
- Blocked a high-tickrate-only shortcut that would let you jump to the second level in the swan room from the ground level (not the generator shortcut)
- Blocked Survivors from getting punched onto a water tank in the swan room
Dark Carnival 4:
- Improved clipping on white fences surrounding saferoom
- Removed unbreakable porta potty doors
- Reduced viability of fighting Tank in the saferoom
- Tank will now lose rage normally while survivors are in the saferoom
- Moustachio horde can no longer be triggered by tank

Side configs-
- Updated all side configs to have the most recent CCT changes.
- Pro Mod 1v1 and 1v1 Hunters no longer have witches. (Deadman still has both witches and tanks.)
- Common limit reduced from 7 to 6 in all 1v1 configs.
- Mega Mob size reduced from 12 to 10 in all 1v1 configs.
- Gascan pour time reduced to 0.7 in all 1v1 configs.
- Deadstop field of view reduced to 15 in all 1v1 configs.
- Fixed Deadman not having proper spawn timers and damage per pounce.
- Reduced Jockey HP in Pro Mod 1v1 to 250.
- Added chargers to Pro Mod 1v1. They have 450 hp, 6 second cooldown on charge, 0 damage on the first scratch, and 5 damage on any scratches after that.

CCT-
- Survivors can no longer fall out the side of the lift on Arena of the Dead map 3.
- Removed all color correction from Undead Zone.
- Fixed error prop not being properly hidden on Undead Zone 1.
- Removed 2nd event from Undead Zone 1.
- Blocked survivors getting punched over a fence that they couldn't get back from on Undead Zone 2.
- Fixed weird shadowing of a prop on Undead Zone 3.
- Blocked survivors climbing on the metal rail we added for SI on Undead Zone 3.
- Flickering lights on Undead Zone 4 are now constant to improve FPS.
- Blocked instant tank spawn on Undead Zone 4.
- Fixed infected being unable to spawn on 2nd half of Urban Flight Finale.
- Removed an extra pill spawn from Urban Flight Finale.
- Fixed a broken ladder on Urban Flight Finale.
- Unblocked early tanks on Dark Blood map 3.
- Blocked event tanks on Dark Blood map 3.
- Survivors no longer have to climb the ladder of doom on Dark Blood Finale. The gascans have been moved to more reasonable places.
- Fixed infected not being able to spawn behind some bushes on Open Road 2.
- Fixed infected not being able to spawn behind some bushes on Open Road 4.
- Fixed the shadows of some props on Open Road 4.


4.0.4b
Undocumented 1v1 config update for a tourney. Properly documented under 4.0.4c


4.0.4a
Opened an alternate path on Urban Flight 2 which should shorten the length of the map by a bit.
Removed extra gascans from Urban Flight finale.
Removed some possible extra pill spawns from Urban Flight finale.
Removed endless horde on Undead Zone 2.
Added a way for infected to get out of a stuck spot on Undead Zone finale.
Added an ammo pile in the hangar where pills are on Undead Zone finale.
Removed possible medkit spawns from Diescraper 3 start saferoom.
Reduced Diescraper 3 max distance to 700.
Added 2nd finale tank to Diescraper Finale.
Tank will now lose rage while survivors are in Arena of the Dead 2 map 2 saferoom.
Slightly nerfed the insane ladder choke on Dark Blood 2 finale.
Added melee weapons to Open Road 3 alarmed gun room.
Added more spawns to open plane area of Undead Zone map 3.
Added an ammo pile on Undead Zone map 3.
Reduced votekick ban duration from 5 minutes to 1 minute.


4.0.4
Added support for the final 2 CCT maps.
Added a print for maps where tank loses rage while survivors are in saferoom.
Enabled tank rage tickdown in Open Road 2 saferoom.
Increased Open Road 3 map distance to 600.
Fixed a couple spit blocks being missing.
Fixed Dark Blood 2 map 3's stripper file not working properly causing the map to be unplayable.
Increased bile duration vs infected to 8. (From 5)
Finished cleaning up configs, a documentation file will be added in the near future.


4.0.3
All configs included in the pro mod package now support the first 4 CCT3 maps.
Made several improvements / fixes to the CCT maps. (Full list here: http://pastebin.com/e6WNsd9y)
Added support for Hard Rain Downpour.
Significantly cleaned up some of the configs. (Will finish this in next update)
Godframe indicator is now enabled by default.
Reduced charger and hunter godframes to 1.8 (From 2.1)
Reduced smoker and jockey spit extra time to 0.5 (From 0.7)
Spit godframe ticks increased from 4 to 6. (Vanilla is 8)
Reduced AOE on survivor self bile to match AOE of regular use.
Hunters now do continuous damage ticks. (Similar to how jockeys do damage.)
Unblocked very early tanks on No Mercy 1. (10-25%)
Tanks will now lose rage normally in the following saferooms:
Dead Center 1, Hard Rain 2, No Mercy 1, No Mercy 5, Death Toll 1, Blood Harvest 2


4.0.2
Removed natural hordes.


4.0.1
Fixed smokers not having spit godframes.
Removed hittables weight change.
Increased Natural Horde timer to 100 seconds.
Increased Natural Horde common count from 25 to 27.


4.0
Side Config Clean Up:
Removed unused / outdated cvars from Retro.
Hunters and Jockeys now do 25 damage (+pounce damage) per pounce in 1v1 configs.
Spawn timers reduced to 1 second in 1v1 configs.
AI tanks will now be instantly killed in 2v2 and 3v3 configs.
Fixed quadcaps not working in Reflux.
Removed Pro Mod HR from the package.

Main Changes:
Hunter godframes increased to 2.1*
Charger godframes increased to 2.1*
Smokers spit immunity godframe increased to 0.7*
Jockey spit immunity godframe increased to 0.7*
Spit damage increased from 2 damage per tick to 3.*
Added back 1 bile bomb.**
Bile bombs duration vs player controlled infected reduced to 5. (Default 20)**
Bile bombs duration reduced to 10 seconds. (Default 20)**
Bile bombs can now affect survivors in the same way they would an infected. 10 second duration; 150 AOE. (Careful where you throw it!)**
Natural Horde timer reduced from 3600 to 70.**
Natural Horde timer will be reset every time a boom lands, or a boomer gets popped.**
Deagle limit increased to 2.*
Tanks no longer get slowed by punching an incapped survivor.
Increased Tank ban on No Mercy 3 from 42% to 55%.
Removed hittables from warehouse after event on No Mercy 3.
Survivors can no longer open the metal door after the event on No Mercy 3.
Blocked tank from 0-55% on No Mercy 5.
No Mercy 5 Saferoom will now always contain a Silenced SMG and Chrome Shotgun.
Added 2 melee weapons to No Mercy 5 saferoom.
Added an ammo pile to map room on Dead Center 1 to encourage teams to push out of saferoom for early tanks.
Removed the cop car at the bottom of the first hill on Dead Center 2.
Moved cola to the side closet (and removed the doors) on Dead Center 2 event.
Removed an inaccessible pill spawn from Hard Rain 2 and 3.
Removed 4 inaccessible pill spawns on Hard Rain 4.
Enabled "Fun Skill Prints" by default. (Jacob skeeted Grizz. Jacob Leveled Hib. Etc.)

*Only applies to Pro Mod.
**Only applies to Pro Mod and Reflux.