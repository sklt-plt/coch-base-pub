extends Node
class_name EntityGroupsGenerator
tool

export (Dictionary) var stat_objects = {
	"level_entrance" : {"path" : "/Ent/Static/LevelEntrance/LevelEntrance.tscn"}
}

# interactable objects to load
export (Dictionary) var int_objects = {
	"level_gate" : {"path" : "/Ent/Interactable/LevelExit/LevelExit.tscn"},
	"key" : {"path" : "/Ent/Interactable/Pickups/Key/Key.tscn"},
	"treasure_chest" : {"path" : "/Ent/Interactable/TreasureChest/TreasureChest.tscn"},
	"explosive_barrel" : {"path": "/Ent/Interactable/ExplosiveBarrel/ExplosiveBarrel.tscn"},
	"hint_board" : {"path": "/Ent/Interactable/HintBoard/HintBoard.tscn"}
}

# enemies paths to load from, their per-room cost and player resource recompensation
# note: at least one enemy MUST HAVE a cost of non-zero
export (Array, Dictionary) var monster_paths_and_costs = [
	{"path": "/Actors/Enemies/Projectiles/enemy.tscn", "spawn_cost": 1.0, "spawn_max_group": 3},
	{"path": "/Actors/Enemies/Melee/enemy.tscn", "spawn_cost": 2.5, "spawn_max_group": 2},
	{"path": "/Actors/Enemies/Boomerangs/enemy.tscn", "spawn_cost": 1.5, "spawn_max_group": 3}]

# pickups to load, their contents are taken from inside their scripts
# note: each group needs to be sorted by strongest
export (Dictionary) var pickups = {
	"r_crossbow_ammo" : [
		{"path": "/Ent/Interactable/Pickups/Ammo/AmmoCrossbowPickup.tscn"}],
	"r_shotgun_ammo" : [
		{"path": "/Ent/Interactable/Pickups/Ammo/AmmoShotgunPickup.tscn"}],
	"r_pistol_ammo" : [
		{"path": "/Ent/Interactable/Pickups/Ammo/AmmoPistolPickup.tscn"}],
	"r_health" : [
		{"path": "/Ent/Interactable/Pickups/Health/HealthPickupL.tscn"},
		{"path": "/Ent/Interactable/Pickups/Health/HealthPickupM.tscn"},
		{"path": "/Ent/Interactable/Pickups/Health/HealthPickupS.tscn"}],
	"r_armor" : [
		{"path": "/Ent/Interactable/Pickups/Armor/ArmorPickupL.tscn"},
		{"path": "/Ent/Interactable/Pickups/Armor/ArmorPickupM.tscn"},
		{"path": "/Ent/Interactable/Pickups/Armor/ArmorPickupS.tscn"}]
}

var _locked_doors
var _rng

func reset(var rng: RandomNumberGenerator, var locked_doors : Array):
		_rng = rng
		_locked_doors = locked_doors

func prepare():
	# load static props
	stat_objects["level_entrance"]["ref"] = load(Globals.content_pack_path + stat_objects["level_entrance"]["path"])

	# load interactables
	int_objects["level_gate"]["ref"] = load(Globals.content_pack_path + int_objects["level_gate"]["path"])
	int_objects["key"]["ref"] = load(Globals.content_pack_path + int_objects["key"]["path"])

	int_objects["treasure_chest"]["ref"] = load(Globals.content_pack_path + int_objects["treasure_chest"]["path"])
	int_objects["explosive_barrel"]["ref"] = load(Globals.content_pack_path + int_objects["explosive_barrel"]["path"])
	int_objects["hint_board"]["ref"] = load(Globals.content_pack_path + int_objects["hint_board"]["path"])

	# load monster refs
	for m in monster_paths_and_costs:
		m["ref"] = load(Globals.content_pack_path + m["path"])

	# load pickups
	for pickup_type in pickups:
		for pickup in pickups[pickup_type]:
			pickup["ref"] = load(Globals.content_pack_path + pickup["path"])
			var temp = pickup["ref"].instance()
			pickup["contents"] = temp.get("contents").duplicate()

func generate(var room_geometry: RoomGeometry):
	var tree_ref = get_node(room_geometry.tree_ref)
	var entities = generate_entity_groups(room_geometry, tree_ref)
	var gmap = room_geometry.get_node_or_null("DetailMap")
	place_entities(entities, room_geometry, gmap)

func add_resources_needed_by_monster(var player_resource_costs : Dictionary, var room_resources : Dictionary):
	var player = get_node_or_null("/root/Player")

	for c in player_resource_costs:
		# determine if player has equipment that uses resource 'c'
		# if 'c' is ammo for weapon player doesn't have, give x3 the pistol ammo instead
		if not Engine.editor_hint and\
			((c == "r_shotgun_ammo" and not player.has("e_double_barrel_level", 1))\
			or (c == "r_crossbow_ammo" and not player.has("e_crossbow_level", 1))):
				room_resources["r_pistol_ammo"] += player_resource_costs[c] * 3
		else:
			# otherwise just append what's needed
			room_resources[c] += player_resource_costs[c]

func generate_entity_groups(var room_geometry : RoomGeometry, var tree_ref : GeneratedRoom):
	var difficulty_pool = tree_ref.difficulty
	var room_monsters = []
	var room_items = []
	var room_specials = []
	var room_resources = {
		"r_health": 0,
		"r_shotgun_ammo": 0,
		"r_pistol_ammo": 0,
		"r_crossbow_ammo": 0,
		"r_armor" : 0}

	# get resource costs from enemies spawned by buildings / furniture
	var room_children = room_geometry.get_children()
	for c in room_children:
		if c is KinematicEnemy or c is StaticEnemy:
			for res in c.player_resource_costs:
				room_resources[res] += c.player_resource_costs[res]

	# random cherry-pick algo for enemies
	# until we exhaust pool
	while difficulty_pool > 0.01:
		var dup_pool = monster_paths_and_costs.duplicate()
		# filter out too expensive monsters
		for monster in monster_paths_and_costs:
			if monster["spawn_cost"] > difficulty_pool:
				dup_pool.erase(monster)

		if dup_pool.empty():
			#not enough pool left for any monster
			break

		# pick a monster
		var potential_monster = dup_pool[_rng.randi()%dup_pool.size()]

		difficulty_pool -= potential_monster["spawn_cost"]
		# remember other costs
		var player_resource_costs = potential_monster["ref"].instance().player_resource_costs
		add_resources_needed_by_monster(player_resource_costs, room_resources)

		var new_group = []
		new_group.push_back(potential_monster["ref"])

		# let's have random chance of placing barrel next to it
		if _rng.randf_range(0.0, 1.0) < 0.25:
			new_group.push_back(int_objects["explosive_barrel"]["ref"])

		room_monsters.push_back(new_group)

	# naive backpack algo for items
	for pickup_type in pickups:
		var weakest_pickup
		for pickup in pickups[pickup_type]:
			# remember what is weakest pickup for rounding up impossible remainder
			if not weakest_pickup or pickup["contents"][pickup_type] < weakest_pickup["contents"][pickup_type]:
				weakest_pickup = pickup

			# can we put at least one?
			if (pickup["contents"][pickup_type] > room_resources[pickup_type]):
				continue

			var room_limit = floor(room_resources[pickup_type] / pickup["contents"][pickup_type])

			for _i in range(0, room_limit):
				room_items.push_back([pickup["ref"]])

			room_resources[pickup_type] -= pickup["contents"][pickup_type]*room_limit

		var remainder = float(room_resources[pickup_type])/float(weakest_pickup["contents"][pickup_type])

		if remainder > 0.0 and remainder < 1.0:
			room_items.push_back([weakest_pickup["ref"]])

	# add extra contents like keys
	for t in tree_ref.traits:
		match t:
			GeneratedRoom.ROOM_TRAITS.KEY:
				room_specials.push_back(int_objects["key"]["ref"])
			GeneratedRoom.ROOM_TRAITS.LOCKED_DOOR:
				for door in _locked_doors:
					room_specials.push_back(door["ref"])
			GeneratedRoom.ROOM_TRAITS.EXIT_DOOR:
				room_specials.push_back(int_objects["level_gate"]["ref"])
			GeneratedRoom.ROOM_TRAITS.TREASURE:
				room_specials.push_back(int_objects["treasure_chest"]["ref"])
			GeneratedRoom.ROOM_TRAITS.KEY_AND_TREASURE:
				room_specials.push_back(int_objects["treasure_chest"]["ref"])
				room_specials.push_back(int_objects["key"]["ref"])
			GeneratedRoom.ROOM_TRAITS.STARTING:
				room_specials.push_back(stat_objects["level_entrance"]["ref"])
				room_specials.push_back(int_objects["hint_board"]["ref"])

	return {"monsters" : room_monsters, "items" : room_items, "specials" : room_specials}

# old
func get_group_ent_offset(var i: int):
	match i:
		0:
			return Vector3.ZERO
		1:
			return Vector3.LEFT
		2:
			return Vector3.RIGHT
		3:
			return Vector3.FORWARD
		4:
			return Vector3.BACK
		5:
			return Vector3.LEFT+Vector3.FORWARD
		6:
			return Vector3.RIGHT+Vector3.FORWARD
		7:
			return Vector3.LEFT+Vector3.BACK
		8:
			return Vector3.RIGHT+Vector3.BACK
		_:
			return get_group_ent_offset(i-8)*2

func align_door_to_hole(var door, var exit: Dictionary):
	match exit["direction"]:
		1:
			door.rotate_y(deg2rad(180))
			door.translate(Vector3(-exit["size"].x, 0, 0))
		2:
			door.rotate_y(deg2rad(90))
			door.translate(Vector3(-exit["size"].x, 0, 0))
		3:
			door.rotate_y(deg2rad(-90))

func tile_is_not_by_walls(var room_geometry: RoomGeometry, var tile_coords: Vector3):
	return (tile_coords.x != 1 and tile_coords.x != room_geometry.size.x - 1 and
			tile_coords.z != 1 and tile_coords.z != room_geometry.size.z - 1)

func tile_is_walkable_path(var tile_id : int):
	return (tile_id == GeneratorConstants.TILE_RESERVED_PATH_ID or
			tile_id == GeneratorConstants.TILE_RESERVED_SUB_PATH_ID)

func place_entities(var entities: Dictionary, var room_geometry: RoomGeometry, var gmap: GridMap):
	# group tiles
	var monster_available_tiles = []
	var item_available_tiles = []

	if gmap:  # there is no gmap in starting_room
		var all_tiles = gmap.get_used_cells()
		for t in all_tiles:
			if (tile_is_walkable_path(gmap.get_cell_item(t.x, t.y, t.z)) and
				tile_is_not_by_walls(room_geometry, t)):
				monster_available_tiles.append(t)
			if gmap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_ITEM_ID:
				item_available_tiles.append(t)

	for ent in entities["specials"]:
		var ent_inst = ent.instance()
		var exits = room_geometry.used_exits()

		if ent == stat_objects["level_entrance"]["ref"]:
			for e in exits:
				if e["target"] == "outside":
					# Entry Door
					room_geometry.add_child(ent_inst)
					ent_inst.set_owner(owner)

					ent_inst.translate_object_local(e["origin"])

					align_door_to_hole(ent_inst, e)

		elif ent_inst is HintBoard:
			for e in exits:
				if e["target"] == "outside":
					room_geometry.add_child(ent_inst)

					ent_inst.set_owner(owner)

					ent_inst.translate_object_local(e["origin"])

					align_door_to_hole(ent_inst, e)

					ent_inst.translate_object_local(Vector3(0,0,2))

		elif ent_inst is LockedDoor:
			var parent = get_node(room_geometry.tree_ref).get_parent().get_path()
			for e in exits:
				# is this link with locked door that fits?
				if (e["target"] != "outside" and get_node(e["target"]).tree_ref == parent and
					e["size"] == ent_inst.size):
					room_geometry.add_child(ent_inst)
					ent_inst.set_owner(owner)

					ent_inst.translate_object_local(e["origin"])

					align_door_to_hole(ent_inst, e)

		elif ent_inst is LevelExit or ent_inst is BossSpawn:
			# get link location
			for e in exits:
				if e["target"] == "outside":
					room_geometry.add_child(ent_inst)
					ent_inst.set_owner(owner)

					ent_inst.translate_object_local(e["origin"])
					align_door_to_hole(ent_inst, e)

		elif (ent == int_objects["key"]["ref"]
			or ent == int_objects["treasure_chest"]["ref"]):

			if monster_available_tiles.size() < 1 and ent == int_objects["key"]["ref"]:
				print ("No room to place entity 'Key'!")
				if not Engine.is_editor_hint():
					$"/root/Player".give("r_keys", 1)  # let's just sneak it into player's inventory

			if monster_available_tiles.size() > 0:
				var origin_space_id = _rng.randi()%(monster_available_tiles.size())
				var origin_space = monster_available_tiles[origin_space_id]

				room_geometry.add_child(ent_inst)
				ent_inst.transform.origin = monster_available_tiles[origin_space_id]
				ent_inst.scale.x *= 0.5
				ent_inst.scale.y *= 0.5
				ent_inst.scale.z *= 0.5
				ent_inst.set_owner(owner)

				monster_available_tiles.remove(origin_space_id)

	for monster_grp in entities["monsters"]:
		if monster_available_tiles.size() > 0:
			var origin_space_id = _rng.randi()%(monster_available_tiles.size())
			var origin_space = monster_available_tiles[origin_space_id]
			var offset = 0
			for ent in monster_grp:
				if monster_available_tiles.size() > 0:
					var target_space_id = monster_available_tiles.find(origin_space+get_group_ent_offset(offset))
					while target_space_id == -1:
						target_space_id = (origin_space_id+offset)%(monster_available_tiles.size())
						offset += 1

					var new_ent = ent.instance()
					new_ent.rotation_degrees.y = _rng.randi()%360

					room_geometry.add_child(new_ent)
					new_ent.transform.origin = monster_available_tiles[target_space_id]
					if new_ent is RigidBody:
						new_ent.transform.origin.y += 0.5

					new_ent.scale.x *= 0.5
					new_ent.scale.y *= 0.5
					new_ent.scale.z *= 0.5
					new_ent.set_owner(owner)

					monster_available_tiles.remove(target_space_id)
					offset += 1

	for item_grp in entities["items"]:
		if item_available_tiles.size() > 0:
			var origin_space_id = _rng.randi()%(item_available_tiles.size())
			var origin_space = item_available_tiles[origin_space_id]
			var offset = 0
			for ent in item_grp:
				if item_available_tiles.size() > 0:
					var target_space_id = item_available_tiles.find(origin_space+get_group_ent_offset(offset))
					while target_space_id == -1:
						target_space_id = (origin_space_id+offset)%(item_available_tiles.size())
						offset += 1

					var new_ent = ent.instance()

					room_geometry.add_child(new_ent)
					new_ent.transform.origin = item_available_tiles[target_space_id]
					new_ent.set_owner(owner)

					item_available_tiles.remove(target_space_id)
					offset += 1
