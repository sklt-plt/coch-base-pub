extends Spatial
class_name MapGenerator
tool

var DBG_SKIP_DOORS = false

export (bool) var generate = false
var hide_after_generation = false

export (String) var gen_seed = ""

export (String) var _detail_tileset_path = "/Maps/Tiles/TilesEp0.tres"

export (Array) var locked_doors =  [{"path" : "/Ent/Interactable/LockedDoor/LockedDoorNew4x4.tscn"},		# needs to be sorted from tallest to lowest
		{"path" : "/Ent/Interactable/LockedDoor/LockedDoorNew4x2.tscn"},
		{"path" : "/Ent/Interactable/LockedDoor/LockedDoorNew3x3.tscn"},
		{"path" : "/Ent/Interactable/LockedDoor/LockedDoorNew3x2.tscn"},
		{"path" : "/Ent/Interactable/LockedDoor/LockedDoorNew2x2.tscn"}]

const HIDE_ORIGIN = Vector3(-10000, -10000, -10000)

var _rooms_data_generator : RoomsDataGenerator
var _walls_generator : RoomWallsGenerator
var _random_walks_interior_generator : RandomWalksInteriorGenerator
var _furnished_interior_generator: FurnishedInteriorGenerator
var _furnished_arena_generator: FurnishedArenaGenerator
var _entity_generator : EntityGroupsGenerator
var _arena_generator : ArenaGenerator
var _door_generator: LinkDoorsGenerator
var _side_furniture_generator: FurnitureGenerator
var _path_furniture_generator: FurnitureGenerator

var _generated_tree_root
var _owner
var _rng

func _ready():
	flush_old_map()

	if not Engine.is_editor_hint():
		generate = true
		hide_after_generation = true

func flush_old_map():
	var oldMap = get_parent().find_node("generated_map*")
	if oldMap:
		oldMap.queue_free()

func clear_refs():
	pass

func is_generating():
	return generate

func _process(_delta):
	var t = OS.get_ticks_msec()

	if generate:
		flush_old_map()
		initialize_subsystems()

		var maybe_overrides = self.get_node_or_null("GeneratorOverrides")

		if maybe_overrides:
			if not maybe_overrides.done:
				return
			else:
				maybe_overrides.apply()

		if (prepare_subsystems()):
			_generated_tree_root = _rooms_data_generator.generate_design_tree()

			if not Engine.is_editor_hint():
				$"/root/Player".get_map_container().create_map(_generated_tree_root.get_node("starting_room"))

			generate_pass_one(_generated_tree_root)

			generate_pass_two(_generated_tree_root)

			_generated_tree_root.transform = _generated_tree_root.transform.scaled(Vector3(2,2,2))
			get_node(_generated_tree_root.get_node("starting_room").geometry).toggle_collisions(true)

			if hide_after_generation:
				hide_rooms(_generated_tree_root)

			teleport_player_to_entrance()

			if not Engine.is_editor_hint():
				$"/root/Player".refresh_shaders()

			generate = false

		print("Generation done in ", OS.get_ticks_msec()-t , " msec")

func prepare_subsystems():
	_entity_generator.prepare()
	_walls_generator.prepare()
	_rooms_data_generator.prepare()

	return true

func teleport_player_to_entrance():
	var starting_room_geometry = get_node(get_node(String(_generated_tree_root.get_path())+"/starting_room").geometry)
	var entrance_link = starting_room_geometry.get_link_to_outside()
	var player_spawn_translation = entrance_link["origin"]*2

	var offset
	var offset_rot = 0
	match entrance_link["direction"]:
		0:
			offset = Vector3(2, 0, 2)
			offset_rot = 180
		1:
			offset = Vector3(2, 0, -2)
		2:
			offset = Vector3(2, 0, 2)
			offset_rot = -90
		3:
			offset = Vector3(-2, 0, 2)
			offset_rot = 90

	player_spawn_translation += offset

	if not Engine.is_editor_hint():
		var tele = ManualPlayerSpawn.new()
		tele.name = "PlayerSpawn"
		tele.translation = player_spawn_translation
		tele.rotation_degrees.y = offset_rot
		get_parent().add_child(tele)

func randomize_seed():
	_rng.randomize()
	gen_seed = String(_rng.randi())
	print("Generating with seed: ", gen_seed)
	_rng.set_seed(gen_seed.hash())

func initialize_subsystems():
	# clear ai cache
	if not Engine.is_editor_hint():
		$"/root/AIManager".clear_registrations()

	for door in locked_doors:
		door["ref"] = load(Globals.content_pack_path + door["path"])

	# prepare rng
	_rng = RandomNumberGenerator.new()

	if not Engine.is_editor_hint():
		if ((EpisodeManager.is_normal_episode_playing() and Globals.user_settings["legacy_campaign"] and not gen_seed.empty()) or
			EpisodeManager.is_custom_episode_playing() and not gen_seed.empty()):
			_rng.set_seed(gen_seed.hash())
		else:
			randomize_seed()
	else:
		if gen_seed.empty():
			randomize_seed()
		else:
			_rng.set_seed(gen_seed.hash())

	# needed for every new node?
	_owner = get_parent()


	# create helper objects
	_rooms_data_generator = get_parent().find_node("rooms_data_generator*")
	if not _rooms_data_generator:
		_rooms_data_generator = RoomsDataGenerator.new()

		get_parent().add_child(_rooms_data_generator)
		_rooms_data_generator.owner = _owner
		_rooms_data_generator.set_name("rooms_data_generator")

	_rooms_data_generator.reset(_rng)

	_walls_generator = get_parent().find_node("walls_generator*")
	if not _walls_generator:
		_walls_generator = RoomWallsGenerator.new()
		_walls_generator.set_name("walls_generator")
		get_parent().add_child(_walls_generator)
		_walls_generator.owner = _owner

	_walls_generator.reset(_rng, locked_doors)

	_random_walks_interior_generator = get_parent().find_node("random_walks_interior_generator*")
	if not _random_walks_interior_generator:
		_random_walks_interior_generator = RandomWalksInteriorGenerator.new()
		_random_walks_interior_generator.set_name("random_walks_interior_generator")
		get_parent().add_child(_random_walks_interior_generator)
		_random_walks_interior_generator.owner = _owner

	_random_walks_interior_generator.reset(_detail_tileset_path, _rng)

	_side_furniture_generator = get_parent().find_node("side_furniture_generator*")

	if not _side_furniture_generator:
		_side_furniture_generator = FurnitureGenerator.new()

		_side_furniture_generator.set_name("side_furniture_generator")

		get_parent().add_child(_side_furniture_generator)

		_side_furniture_generator.owner = _owner

	_side_furniture_generator.reset(_rng)

	_path_furniture_generator = get_parent().find_node("path_furniture_generator*")

	if not _path_furniture_generator:
		_path_furniture_generator = FurnitureGenerator.new()

		_path_furniture_generator.set_name("path_furniture_generator")

		get_parent().add_child(_path_furniture_generator)

		_path_furniture_generator.owner = _owner

	_path_furniture_generator.reset(_rng)

	_furnished_interior_generator = get_parent().find_node("furnished_interior_generator*")
	if not _furnished_interior_generator:
		_furnished_interior_generator = FurnishedInteriorGenerator.new()

		_furnished_interior_generator.set_name("furnished_interior_generator")

		get_parent().add_child(_furnished_interior_generator)
		_furnished_interior_generator.owner = _owner

	_furnished_interior_generator.reset(_detail_tileset_path, _rng)

	_furnished_interior_generator._side_furniture_generator = _side_furniture_generator
	_furnished_interior_generator._path_furniture_generator = _path_furniture_generator

	_furnished_arena_generator = get_parent().find_node("furnished_arena_generator*")
	if not _furnished_arena_generator:
		_furnished_arena_generator = FurnishedArenaGenerator.new()

		_furnished_arena_generator.set_name("furnished_arena_generator")

		get_parent().add_child(_furnished_arena_generator)
		_furnished_arena_generator.owner = _owner

	_furnished_arena_generator.reset(_detail_tileset_path, _rng)

	_furnished_arena_generator._side_furniture_generator = _side_furniture_generator
	_furnished_arena_generator._path_furniture_generator = _path_furniture_generator

	_arena_generator = get_parent().find_node("arena_interior_generator*")
	if not _arena_generator:
		_arena_generator = ArenaGenerator.new()
		_arena_generator.set_name("arena_interior_generator")
		get_parent().add_child(_arena_generator)
		_arena_generator.owner = _owner

	_arena_generator.reset(_detail_tileset_path, _rng)

	_door_generator = get_parent().find_node("link_door_generator*")
	if not _door_generator:
		_door_generator = LinkDoorsGenerator.new()
		_door_generator.set_name("link_door_generator")
		get_parent().add_child(_door_generator)
		_door_generator.owner = _owner

	_entity_generator = get_parent().find_node("entity_groups_generator*")
	if not _entity_generator:
		_entity_generator = EntityGroupsGenerator.new()
		_entity_generator.set_name("entity_groups_generator")
		get_parent().add_child(_entity_generator)
		_entity_generator.owner = _owner

	_entity_generator.reset(_rng, locked_doors)

	return true

func generate_pass_one(var root):
	var rooms = root.get_children()

	for r in rooms:
		if r is GeneratedRoom:
			var new_room_geometry = _walls_generator.prepare_room_geometry(r, _generated_tree_root)

			if r.prefab_room:
				PrefabHelper.create_prefab_room(r, new_room_geometry, _rng)

			_walls_generator.make_walls(r, new_room_geometry)

			create_room_boundary(r, 0)

		if r.get_child_count() > 0:
			generate_pass_one(r)

func generate_pass_two(var root):
	var nodes = root.get_children()

	for node in nodes:
		if node is RoomGeometry:
			# what room interior to make
			var gen_room = get_node(node.tree_ref)

			if not gen_room.prefab_room:
				if gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.NORMAL_CORRIDORS):
					_random_walks_interior_generator.generate(node)

				elif gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.ARENA):
					_arena_generator.generate(node)

				elif gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.FURNISHED_ARENA):
					_furnished_arena_generator.generate(node)

				elif gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.FURNISHED):
					_furnished_interior_generator.generate(node)

			_entity_generator.generate(node)

		if node is GeneratedRoom:
			if node.traits.has(GeneratedRoom.ROOM_TRAITS.STARTING):
				_walls_generator.make_level_entrance(node)

			var childRooms = node.get_children()
			for c in childRooms:
				if c is GeneratedRoom:
					_walls_generator.make_exit(node, c)

			if not DBG_SKIP_DOORS:
				_door_generator.make_doors(node)

			if node.get_child_count() > 0:
				generate_pass_two(node)

			if node.traits.has(GeneratedRoom.ROOM_TRAITS.END_MAIN):
				_walls_generator.make_level_exit(node)

func create_room_boundary(var room, var boundary_margin):
	# crate area collider
	var a = Area.new()
	a.monitoring = false
	var rg = get_node(room.geometry)
	rg.add_child(a)
	a.set_owner(_owner)
	a.add_to_group("RoomBoundaries")

	var center = Vector3(rg.size.x/2, rg.size.y/2, rg.size.z/2)
	a.translate(center)

	# create collision shape
	var cs = CollisionShape.new()
	a.add_child(cs)
	cs.set_owner(_owner)

	# create shape
	var bs = BoxShape.new()
	bs.extents = Vector3((rg.size.x+boundary_margin)/2, (rg.size.y+boundary_margin)/2, (rg.size.z+boundary_margin)/2)
	cs.shape = bs

func hide_rooms(var root):
	var rooms = root.get_children()

	for r in rooms:
		var childRooms = r.get_children()

		for c in childRooms:
			if c is GeneratedRoom and not c.traits.has(GeneratedRoom.ROOM_TRAITS.STARTING):
				var g = get_node(c.geometry)
				if not Engine.is_editor_hint():
					g.move_away()
				else:
					g.move_away_editor()

		if r.get_child_count() > 0:
			hide_rooms(r)
