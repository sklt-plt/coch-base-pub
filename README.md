# Procedural FPS Library (from game "The Creature of Chaos")

## What is this?
This is the source code of most of my game, "The Creature of Chaos", in "library" form, licensed under LGPL v3. Contains classes and definitions designed to build a roguelike first-person shooter. Compatible with Godot 3.5.

You can check out the game utilizing this on [Steam](https://store.steampowered.com/app/1912460/The_Creature_of_Chaos/) and [Itch.io](https://pkcat.itch.io/the-creature-of-chaos), as well as [The "template" project](https://github.com/sklt-plt/creature-of-chaos-source)

## About Content Packs:
 The project was designed with loading swappable "content pack" folders. Think Quake's mission packs or Doom's WADs. These are subfolders under the "content" directory. By design, classes from this library will try to load assets from there. Currently used path is defined in Base/System/_Globals.gd as `content_pack_path`. This also means that defining file paths for Base classes should be done in format relative to `content_pack_path`.
 For example, for MapGenerator to load floor material from file "Content/example/floor.tres" you need to set
  - in _Globals.gd `content_pack_path = "res://Content/example"`
  and
  - in MapGenerator `floor_material_paths = ["/floor.tres"]`

## Stuff included:
### Player:
 - KinematicActor: pushable kinematic node depending on external forces (getting pushed by damage, standing on platform, etc.). Common handling for Player and Enemies
 - First-person player movement: running, walking, jumping, crouching, swimming, climbing ladders, mouse look, teleporting on command, and when the player falls out of the map
 - PlayerResources: keeping track of player's variables, taking and giving resources, resource limits and upgrades, optional time-limit, and progress variable tracking
 - PlayerStats: keeping track of player score and stats (time taken, number of kills, treasures, etc.)
 - Player hud displaying resources, score, and time remaining
 - PlayerAnimations: misc effects like "gun bobbing"
 - GunBase: customizable "hitscan" and projectile gun script: shooting, alt functions (reloading, aiming (toggle / hold), rocket detonation), tracking of ammo in current magazine, handling hands and gun animations, automatic / semiautomatic modes, and melee swing attacks
 - GunController: handle player gun switching and independent melee attack firing
 - Crosshair: automatically resizing crosshairs depending on gun accuracy
 - StickyExplosive: a class for handling explosive arrows that "stick" to enemies
 - PlayerStartingEquipment: ensure player has minimal amount of resources / equipment when level starts
 - MapContainer: a script and for dungeon map drawing
 - InputProxy: class for passing input to player's subclasses; also handles cheats
### Map Generator:
 - MapGenerator: manage sub-generators flow and generation settings
 - RoomsDataGenerator: generate high-level map design (room relations, sizes, difficulty, side-paths, treasures, interior type)
 - RoomWallsGenerator: generate wall meshes and corridors to adjacent rooms
 - RandomWalksInteriorGenerator: generate "corridor" rooms connecting exits and some dead-ends, differentiate floor tiles between main and sub paths
 - ArenaGenerator: generate "arena" rooms containing random obstacles and open design
 - FurnitureObject and FurnitureElements: helper classes for building randomizable object scenes
 - FurnitureGenerator: class for creating and instancing objects made out of the above
 - FurnishedInterior/Arena Generator: analogical to the above RandomWalks and Arena generators but utilizing Furniture objects
 - Prefab Rooms: allows use of manually prefabricated room interiors, with optional procedural enemy and item placement
 - EntityGroupsGenerator: place enemies and items on designated tiles
 - LinkDoorsGenerator: class for generating correct-sized LinkDoors
 - LinkDoor: class acting like doors between rooms, handles opening and closing animations
 - GeneratorOverrides: randomize MapGenerator's variables or use provided by OverridesUI
 - OverridesUI: allow players to manually set some MapGenerator's variables
### Interactable Objects:
 - Explosive Barrels (pushable by player and enemies)
 - Keys and Locked Doors
 - LevelExit: handling level transition
 - Resource Pickup Object: define resource to be given to player
 - Powerup Object: define resource to be powered up on interact
 - TreasureChest: Spawn random resource powerup or gun powerup if the player doesn't own it
 - Interactable: base class for all things requiring pressing the "Interact" key
 - "Water" and "Ladder" triggers
 - ObjectCache: define objects to be loaded on start, and cache shaders
 - HintBoard: a "tutorial" object, displaying hints in-game world
### Menus:
 - Pause / Game Over Menu
 - Difficulty selection and customization menu
 - Options Menu: graphics settings (window / fullscreen display, resolution scale, vsync, antialiasing mode, sharpening strength, toggling dynamic shadows, toggling ambient occlusion, setting player's field-of-view), audio (master / music / sfx volume), 
 - Control customization menu allowing setting keybinding for most in-game functions
 - Saving and loading: player's progress, player's settings, player's controls, player's "custom map" mode settings
### Enemies:
 - EnemyAI: customizable AI state machine script; movement depending on if player is in line-of-sight, 3 movement options (standing, wandering, chasing player), attacking using selected means (melee / projectiles / 'boomerangs'), playing sfx, spawning 'gibs', giving player resources on defeat
 - KinematicEnemy: interface and base scene for moving enemies
 - Static Enemy: same as above but for static "turret" enemies
 - AI Manager: handling time-slicing of enemies AI
 - Projectile types: collision-based, area-of-effect based, enemy spawning
 - Melee Area: trigger for enemy melee attacks
 - GibEffect: physics-based rigidbody launcher
 - PlayerResourceCosts: control for amount of resources (health, ammunition, etc.) for player to compensate per enemy instance
 - "Drone" enemies: flying along 3DCurves and shooting projectiles
 - "DroneBoss" enemy: behavior for stationary enemy with Drone children, showing health on player's hud
 - "FlyingBoss" enemy: behavior for moving enemy over GeneratedRoom, with 3 attack phases
 - "Fake" enemy: class holding only PlayerResourceCosts, for spawning pickups on map without enemies
 - Hurtbox skeleton: handling hitbox-based damage
 - Boss Spawner: helper for instancing enemies not bound by GeneratedRooms
 - Laser shader for sniper-like enemies
### Misc:
 - Basic modding support (see "About 'ContentPacks'")
 - EpisodeManager: track and handle level transition
 - Initializer: loads globals from ContentPacks
 - Globals: apply and keep user settings and progress
 - FontCache: keep font references for resizing 
 - Music Controller: play music and handle transitions (time-based / crossfade)
 - SoundtrackShuffle: change songs randomly on level transition
 - HittableMaterial: define effect on hit to be spawned when shooting objects
 - WorldCamera: a helper triggering shader cache
 - AchievementHelper: a helper class for triggering Steam achievements, requires additional plugin
