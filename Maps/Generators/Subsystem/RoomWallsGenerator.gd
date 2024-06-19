#    Copyright (C) 2024 Jakub Miksa
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This prograsm is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

extends Node
class_name RoomWallsGenerator
tool

export (Array, String) var floor_material_paths = ["/Maps/Materials/ep0/ground.tres"]
var _floor_materials = []

export (Array, String) var wall_material_paths = ["/Maps/Materials/ep0/walls.tres"]
var _wall_materials = []

export (Array, String) var ceiling_material_paths = ["/Maps/Materials/ep0/walls.tres"]
var _ceiling_materials = []

export (bool) var _make_ceilings = false

export (bool) var _links_on_floor = true

export (int) var _force_exit_direction = -1
export (int) var _exit_extra_margin = 0

export (int) var _link_max_height = 9999

var _rng
var _mesh_library
var _locked_doors

const _voxel_size = 1.00
const GRID_CEIL = 0
const GRID_FLOOR = 1
const GRID_WEST = 2
const GRID_EAST = 3
const GRID_SOUTH = 4
const GRID_NORTH = 5
const GRID_CUBE = 6

const WALL_ID_NORTH = 0
const WALL_ID_SOUTH = 1
const WALL_ID_WEST = 2
const WALL_ID_EAST = 3

func reset(var rng, var locked_doors):
		_rng = rng
		_locked_doors = locked_doors

func prepare():
	# load materials
	_floor_materials.clear()
	for mS in floor_material_paths:
		_floor_materials.push_back(load(Globals.content_pack_path + mS))

	_wall_materials.clear()
	for mS in wall_material_paths:
		_wall_materials.push_back(load(Globals.content_pack_path + mS))

	_ceiling_materials.clear()
	for mS in ceiling_material_paths:
		_ceiling_materials.push_back(load(Globals.content_pack_path + mS))

func prepare_room_geometry(var room_data, var root):
	var parent = RoomGeometry.new()
	parent.size = room_data.size
	parent.tree_ref = room_data.get_path()

	root.add_child(parent)
	parent.set_owner(owner)

	return parent

func make_walls(var room_data, var parent):
	add_floor(parent)
	if _make_ceilings:
		add_ceiling(parent)

	var walls_material = _wall_materials[_rng.randi()%_wall_materials.size()]

	add_north_wall(parent, walls_material)
	add_south_wall(parent, walls_material)
	add_west_wall(parent, walls_material)
	add_east_wall(parent, walls_material)

	room_data.geometry = parent.get_path()

func find_exits_origin(var room_geometry: RoomGeometry, var wall_id: int, var link_size: Vector2):
	var maybeDetailMap = room_geometry.get_node_or_null("DetailMap")
	if maybeDetailMap:
		return find_exits_origin_prefab(maybeDetailMap, wall_id)
	else:
		return find_exits_origin_random(room_geometry, wall_id, link_size)

func find_exits_origin_prefab(var detailMap : GridMap, var wall_id : int):
	var all_tiles = detailMap.get_used_cells()
	var relevant_tiles = []
	match wall_id:
		WALL_ID_NORTH:
			for t in all_tiles:
				if detailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_NORTH_EXIT_ID:
					relevant_tiles.push_back(t)
		WALL_ID_SOUTH:
			for t in all_tiles:
				if detailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_SOUTH_EXIT_ID:
					relevant_tiles.push_back(t)
		WALL_ID_WEST:
			for t in all_tiles:
				if detailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_WEST_EXIT_ID:
					relevant_tiles.push_back(t)
		WALL_ID_EAST:
			for t in all_tiles:
				if detailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_EAST_EXIT_ID:
					relevant_tiles.push_back(t)

	return relevant_tiles[_rng.randi()%relevant_tiles.size()]

func find_exits_origin_random(var room_geometry: RoomGeometry, var wall_id: int, var link_size: Vector2):
	var x_offset
	var y_offset
	var z_offset

	if room_geometry.size.x <= 4 or room_geometry.size.z <= 4:
		match wall_id:
			WALL_ID_NORTH:
				x_offset = 1
				z_offset = 0
			WALL_ID_SOUTH:
				x_offset = 1
				z_offset = room_geometry.size.z
			WALL_ID_WEST:
				x_offset = 0
				z_offset = 1
			WALL_ID_EAST:
				x_offset = room_geometry.size.x
				z_offset = 1
	else:
		match wall_id:
			WALL_ID_NORTH:
				x_offset = _rng.randi_range(
					min(1+_exit_extra_margin, room_geometry.size.x/2),
					max(2, room_geometry.size.x-1-link_size.x-_exit_extra_margin))
				z_offset = 0
			WALL_ID_SOUTH:
				x_offset = _rng.randi_range(
					min(1+_exit_extra_margin, room_geometry.size.x/2),
					max(2, room_geometry.size.x-1-link_size.x-_exit_extra_margin))
				z_offset = room_geometry.size.z
			WALL_ID_WEST:
				x_offset = 0
				z_offset = _rng.randi_range(
					min(1+_exit_extra_margin, room_geometry.size.z/2),
					max(2, room_geometry.size.z-1-link_size.x-_exit_extra_margin))
			WALL_ID_EAST:
				x_offset = room_geometry.size.x
				z_offset = _rng.randi_range(
					min(1+_exit_extra_margin, room_geometry.size.z/2),
					max(2, room_geometry.size.z-1-link_size.x-_exit_extra_margin))

	if room_geometry.size.y > 2 and not _links_on_floor :
		y_offset = _rng.randi()%(int(room_geometry.size.y-2))
	else:
		y_offset = 0

	return Vector3(x_offset, y_offset, z_offset)

func make_holed_wall(var room_geometry, var named, var make_corridor):
	#remove wall
	var original_material = room_geometry.get_node(named).material
	room_geometry.get_node(named).queue_free()
	#make holed wall
	var wall_total_width
	var desired_link
	var link_x_0
	var link_x_1
	var link_y_0
	var link_y_1

	var combiner = CSGCombiner.new()
	combiner.name = named+"Combiner"
	room_geometry.add_child(combiner)
	combiner.owner = room_geometry.owner
	combiner.use_collision = true

	# translate link's 3d coords to wall's 2d coordinates
	match[named]:
		["NorthWall"]:
			desired_link = room_geometry.north_link
			wall_total_width = room_geometry.size.x
			link_x_0 = desired_link["origin"].x
			link_x_1 = desired_link["origin"].x + desired_link["size"].x
		["SouthWall"]:
			desired_link = room_geometry.south_link
			combiner.transform.origin.z = room_geometry.size.z
			wall_total_width = room_geometry.size.x
			link_x_0 = desired_link["origin"].x
			link_x_1 = desired_link["origin"].x + desired_link["size"].x
		["WestWall"]:
			desired_link = room_geometry.west_link
			combiner.rotate_y(deg2rad(-90))
			wall_total_width = room_geometry.size.z
			link_x_0 = desired_link["origin"].z
			link_x_1 = desired_link["origin"].z + desired_link["size"].x
		["EastWall"]:
			desired_link = room_geometry.east_link
			combiner.rotate_y(deg2rad(-90))
			combiner.transform.origin.x = room_geometry.size.x
			wall_total_width = room_geometry.size.z
			link_x_0 = desired_link["origin"].z
			link_x_1 = desired_link["origin"].z + desired_link["size"].x

	link_y_0 = desired_link["origin"].y
	link_y_1 = desired_link["origin"].y + desired_link["size"].y

	var desired_height = room_geometry.size.y
	# override if adjecent room has highier walls, in outdoor maps
	if not _make_ceilings:
		var target = get_node_or_null(desired_link["target"])
		if target and room_geometry.size.y < target.size.y:
			desired_height = target.size.y

	# left
	if link_x_0 != 0:
		var sub_wall0 = make_wall(combiner, link_x_0, desired_height, original_material, named)
		sub_wall0.transform.origin = Vector3(link_x_0/2, desired_height/2, 0)

	# right
	if link_x_1 != wall_total_width:
		var sub_wall1 = make_wall(combiner, wall_total_width - link_x_1, desired_height, original_material, named)
		sub_wall1.transform.origin = Vector3(link_x_1 + (wall_total_width - link_x_1)/2, desired_height/2, 0)

	# bottom
	if link_y_0 != 0:
		var sub_wall2 = make_wall(combiner, desired_link["size"].x, link_y_0, original_material, named)
		sub_wall2.transform.origin = Vector3(link_x_0 + desired_link["size"].x/2, link_y_0/2, 0)

	var has_top_piece = false
	# top
	if link_y_1 != desired_height:
		var sub_wall3 = make_wall(combiner, desired_link["size"].x, desired_height - link_y_1, original_material, named)
		sub_wall3.transform.origin = Vector3(link_x_0 + desired_link["size"].x/2, link_y_1 + (desired_height - link_y_1)/2, 0)
		has_top_piece = true

	configure_hit_effect(combiner, original_material)

	if make_corridor:
		var corridor_combiner = CSGCombiner.new()
		corridor_combiner.name = named+"CorridorCombiner"
		room_geometry.add_child(corridor_combiner)
		corridor_combiner.owner = room_geometry.owner
		corridor_combiner.transform = combiner.transform
		corridor_combiner.use_collision = true

		# floor
		var sub_wall4 = make_wall(corridor_combiner, desired_link["size"].x+0.1, 1.01, original_material, named)
		sub_wall4.transform.origin = Vector3(link_x_0 + desired_link["size"].x/2, link_y_0, -0.5)
		sub_wall4.rotate_x(deg2rad(-90))

		# ceiling
		if _make_ceilings or has_top_piece:
			var sub_wall5 = make_wall(corridor_combiner, desired_link["size"].x+0.1, 1.01, original_material, named)
			sub_wall5.transform.origin = Vector3(link_x_0 + desired_link["size"].x/2, link_y_1, -0.5)
			sub_wall5.rotate_x(deg2rad(-90))

		# right
		var sub_wall6 = make_wall(corridor_combiner, 1.01, desired_link["size"].y+0.1, original_material, named)
		sub_wall6.transform.origin = Vector3(link_x_0, link_y_0 + desired_link["size"].y/2, -0.5)
		sub_wall6.rotate_y(deg2rad(-90))

		# left
		var sub_wall7 = make_wall(corridor_combiner, 1.01, desired_link["size"].y+0.1, original_material, named)
		sub_wall7.transform.origin = Vector3(link_x_1, link_y_0 + desired_link["size"].y/2, -0.5)
		sub_wall7.rotate_y(deg2rad(-90))

		configure_hit_effect(corridor_combiner, original_material)


func make_level_exit(var from_room):
	make_exit(from_room, null)

func make_level_entrance(var to_room):
	make_exit(null, to_room)

func find_possible_exits(var from_geometry, var to_geometry):
	var avail_exits = []

	#take first's room exits if it's a prefab or next isn't a prefab
	if from_geometry and not (to_geometry and to_geometry.get_node_or_null("DetailMap")):
		avail_exits = from_geometry.available_exits()
	else:
		#take from prefab
		avail_exits = to_geometry.available_exits()
		#invert avail_exits, since we determine directions in from_room first
		for i in range(0, avail_exits.size()):
			match avail_exits[i]:
				0:
					avail_exits[i] = 1
				1:
					avail_exits[i] = 0
				2:
					avail_exits[i] = 3
				3:
					avail_exits[i] = 2

		#discard exits already used in from_geometry
		if from_geometry:
			var unavailable_exits = from_geometry.used_exits_identifiers()
			for u in unavailable_exits:
				avail_exits.erase(u)  # will it throw if element is not found?

	return avail_exits

func generate_link_size(var from_geometry: RoomGeometry, var to_geometry: RoomGeometry,
	var wall_id: int):

	var ret = Vector2(2,2) # minimal safe link size

	if from_geometry and to_geometry:
		# special case - if one of rooms is prefab room, count exit tiles (TODO)
		if (from_geometry.get_node_or_null("DetailMap") or
			to_geometry.get_node_or_null("DetailMap")):
				return ret;

		var max_y
		if not _make_ceilings:
			# special case - if we won't have ceilings, the link needs to reach top of higier wall
			if from_geometry.size.y < to_geometry.size.y:
				max_y = min(to_geometry.size.y, _link_max_height)
			else:
				max_y = min(from_geometry.size.y, _link_max_height)
		else:
			if from_geometry.size.y < to_geometry.size.y:
				max_y = min(from_geometry.size.y, _link_max_height)
			else:
				max_y = min(to_geometry.size.y, _link_max_height)

		var max_x

		# choose random size up to smaller wall capacity
		if wall_id == WALL_ID_NORTH or wall_id == WALL_ID_SOUTH:
			if from_geometry.size.x > to_geometry.size.x:
				max_x = max(2, to_geometry.size.x-2-(2*_exit_extra_margin))
			else:
				max_x = max(2, from_geometry.size.x-2-(2*_exit_extra_margin))
		else:
			if from_geometry.size.z > to_geometry.size.z:
				max_x = max(2, to_geometry.size.z-2-(2*_exit_extra_margin))
			else:
				max_x = max(2, from_geometry.size.z-2-(2*_exit_extra_margin))

		# special case #2: does this link have locked door?
		var from_geom_data = get_node(from_geometry.tree_ref) as GeneratedRoom
		var to_geom_data = get_node(to_geometry.tree_ref) as GeneratedRoom
		# does to_geom has locked door and from_geom is parent?
		if (to_geom_data.traits.has(GeneratedRoom.ROOM_TRAITS.LOCKED_DOOR) and
			from_geom_data.get_children().has(to_geom_data)):
				# get size from available door entities?
				var available_sizes = []
				for door in _locked_doors:
					var inst = door["ref"].instance()
					available_sizes.push_back(Vector2(inst.size.x, inst.size.y))

				var filtered_sizes = []
				for available in available_sizes:
					if available.x <= max_x and available.y <= max_y:
						filtered_sizes.push_back(available)

				var pick = filtered_sizes[_rng.randi()%filtered_sizes.size()]
				ret.x = pick.x
				ret.y = pick.y

		else:
			#unconstrained random hole
			ret.x = _rng.randi_range(2, max_x)
			if not _make_ceilings:
				ret.y = max_y
			else:
				ret.y = _rng.randi_range(2, max_y)
	return ret

func make_exit(var from_room, var to_room):
	var from_geometry
	var to_geometry

	if from_room:
		from_geometry = get_node(from_room.geometry)
	if to_room:
		to_geometry = get_node(to_room.geometry)

	var avail_exits = find_possible_exits(from_geometry, to_geometry)

	var new_exit = avail_exits[_rng.randi()%avail_exits.size()]

	# debug
	if _force_exit_direction != -1:
		new_exit = _force_exit_direction

	match [new_exit]:
		[WALL_ID_NORTH]: #exit from north to south
			#make exit in from_geometry
			var from_offsets
			var link_size = generate_link_size(from_geometry, to_geometry, WALL_ID_NORTH)

			if from_geometry:
				from_geometry.north_link["size"] = link_size
				from_geometry.north_link["used"] = true

				from_offsets = find_exits_origin(from_geometry, WALL_ID_NORTH, link_size)

				from_geometry.north_link["origin"] = Vector3(from_offsets.x, from_offsets.y, from_offsets.z)

				if to_geometry:
					from_geometry.north_link["target"] = to_geometry.get_path()
				else:
					from_geometry.north_link["target"] = "outside"

				make_holed_wall(from_geometry, "NorthWall", true)

			#make entrance in to_geometry
			var to_offsets

			if to_geometry:
				to_geometry.south_link["size"] = link_size
				to_geometry.south_link["used"] = true

				to_offsets = find_exits_origin(to_geometry, WALL_ID_SOUTH, link_size)

				to_geometry.south_link["origin"] = Vector3(to_offsets.x, to_offsets.y, to_offsets.z)

				if from_geometry:
					to_geometry.south_link["target"] = from_geometry.get_path()
				else:
					to_geometry.south_link["target"] = "outside"

				make_holed_wall(to_geometry, "SouthWall", false)

			#connect the fuckers
			if from_geometry && to_geometry:
				var parent_translation = from_geometry.transform.origin
				to_geometry.parent_offset = Vector3((from_offsets.x-to_offsets.x)*_voxel_size, (from_offsets.y-to_offsets.y)*_voxel_size, (-to_geometry.size.z-1)*_voxel_size) + parent_translation
				to_geometry.translation = to_geometry.parent_offset

		[WALL_ID_SOUTH]:
			var from_offsets
			var link_size = generate_link_size(from_geometry, to_geometry, WALL_ID_SOUTH)

			if from_geometry:
				from_geometry.south_link["size"] = link_size
				from_geometry.south_link["used"] = true

				from_offsets = find_exits_origin(from_geometry, WALL_ID_SOUTH, link_size)

				from_geometry.south_link["origin"] = Vector3(from_offsets.x, from_offsets.y, from_offsets.z)
				if to_geometry:
					from_geometry.south_link["target"] = to_geometry.get_path()
				else:
					from_geometry.south_link["target"] = "outside"

				make_holed_wall(from_geometry, "SouthWall", false)

			var to_offsets

			if to_geometry:
				to_geometry.north_link["size"] = link_size
				to_geometry.north_link["used"] = true

				to_offsets = find_exits_origin(to_geometry, WALL_ID_NORTH, link_size)

				to_geometry.north_link["origin"] = Vector3(to_offsets.x, to_offsets.y, to_offsets.z)
				if from_geometry:
					to_geometry.north_link["target"] = from_geometry.get_path()
				else:
					to_geometry.north_link["target"] = "outside"
				make_holed_wall(to_geometry, "NorthWall", true)

			#connect the fuckers
			if from_geometry && to_geometry:
				var parent_translation = from_geometry.transform.origin
				to_geometry.parent_offset = Vector3((from_offsets.x-to_offsets.x)*_voxel_size, (from_offsets.y-to_offsets.y)*_voxel_size, (from_geometry.size.z+1)*_voxel_size) + parent_translation
				to_geometry.translation = to_geometry.parent_offset
		[WALL_ID_WEST]:
			var from_offsets
			var link_size = generate_link_size(from_geometry, to_geometry, WALL_ID_WEST)

			if from_geometry:
				from_geometry.west_link["size"] = link_size
				from_geometry.west_link["used"] = true

				from_offsets = find_exits_origin(from_geometry, WALL_ID_WEST, link_size)

				from_geometry.west_link["origin"] = Vector3(from_offsets.x, from_offsets.y, from_offsets.z)
				if to_geometry:
					from_geometry.west_link["target"] = to_geometry.get_path()
				else:
					from_geometry.west_link["target"] = "outside"

				make_holed_wall(from_geometry, "WestWall", false)

			var to_offsets

			if to_geometry:
				to_geometry.east_link["size"] = link_size
				to_geometry.east_link["used"] = true

				to_offsets = find_exits_origin(to_geometry, WALL_ID_EAST, link_size)

				to_geometry.east_link["origin"] = Vector3(to_offsets.x, to_offsets.y, to_offsets.z)
				if from_geometry:
					to_geometry.east_link["target"] = from_geometry.get_path()
				else:
					to_geometry.east_link["target"] = "outside"

				make_holed_wall(to_geometry, "EastWall", true)

			#connect the fuckers
			if from_geometry && to_geometry:
				var parent_translation = from_geometry.transform.origin
				to_geometry.parent_offset = Vector3((-to_geometry.size.x-1)*_voxel_size, (from_offsets.y-to_offsets.y)*_voxel_size, (from_offsets.z-to_offsets.z)*_voxel_size) + parent_translation
				to_geometry.translation = to_geometry.parent_offset
		[WALL_ID_EAST]:
			var from_offsets
			var link_size = generate_link_size(from_geometry, to_geometry, WALL_ID_EAST)

			if from_geometry:
				from_geometry.east_link["size"] = link_size
				from_geometry.east_link["used"] = true

				from_offsets = find_exits_origin(from_geometry, WALL_ID_EAST, link_size)

				from_geometry.east_link["origin"] = Vector3(from_offsets.x, from_offsets.y, from_offsets.z)
				if to_geometry:
					from_geometry.east_link["target"] = to_geometry.get_path()
				else:
					from_geometry.east_link["target"] = "outside"

				make_holed_wall(from_geometry, "EastWall", true)

			var to_offsets

			if to_geometry:
				to_geometry.west_link["size"] = link_size
				to_geometry.west_link["used"] = true

				to_offsets = find_exits_origin(to_geometry, WALL_ID_WEST, link_size)

				to_geometry.west_link["origin"] = Vector3(to_offsets.x, to_offsets.y, to_offsets.z)
				if from_geometry:
					to_geometry.west_link["target"] = from_geometry.get_path()
				else:
					to_geometry.west_link["target"] = "outside"

				make_holed_wall(to_geometry, "WestWall", false)

			#connect the fuckers
			if from_geometry && to_geometry:
				var parent_translation = from_geometry.transform.origin
				to_geometry.parent_offset = Vector3((from_geometry.size.x+1)*_voxel_size, (from_offsets.y-to_offsets.y)*_voxel_size, (from_offsets.z-to_offsets.z)*_voxel_size) + parent_translation
				to_geometry.translation = to_geometry.parent_offset

func add_north_wall(var room_geometry, var material):
	var north_mesh = make_wall(room_geometry, room_geometry.size.x, room_geometry.size.y, material, "NorthWall")
	north_mesh.transform.origin = Vector3(room_geometry.size.x / 2, room_geometry.size.y / 2, 0)

func add_south_wall(var room_geometry, var material):
	var south_mesh = make_wall(room_geometry, room_geometry.size.x, room_geometry.size.y, material, "SouthWall")
	south_mesh.transform.origin = Vector3(room_geometry.size.x / 2, room_geometry.size.y / 2, room_geometry.size.z)
	south_mesh.rotate_y(deg2rad(180))

func add_west_wall(var room_geometry, var material):
	var west_mesh = make_wall(room_geometry, room_geometry.size.z, room_geometry.size.y, material, "WestWall")
	west_mesh.transform.origin = Vector3(0, room_geometry.size.y / 2, room_geometry.size.z / 2)
	west_mesh.rotate_y(deg2rad(90))

func add_east_wall(var room_geometry, var material):
	var east_mesh = make_wall(room_geometry, room_geometry.size.z, room_geometry.size.y, material, "EastWall")
	east_mesh.transform.origin = Vector3(room_geometry.size.x, room_geometry.size.y / 2, room_geometry.size.z / 2)
	east_mesh.rotate_y(deg2rad(-90))

func add_floor(var room_geometry):
	var floor_mesh = make_wall(room_geometry, room_geometry.size.x, room_geometry.size.z, _floor_materials[_rng.randi()%_floor_materials.size()], "Floor")
	floor_mesh.rotate_x(deg2rad(-90))
	floor_mesh.transform.origin = Vector3((room_geometry.size.x / 2), 0, (room_geometry.size.z / 2))

func add_ceiling(var room_geometry):
	var ceil_mesh = make_wall(room_geometry, room_geometry.size.x, room_geometry.size.z, _ceiling_materials[_rng.randi()%_ceiling_materials.size()], "Ceiling")
	ceil_mesh.rotate_x(deg2rad(90))
	ceil_mesh.transform.origin = Vector3((room_geometry.size.x / 2), room_geometry.size.y, (room_geometry.size.z / 2))

func configure_hit_effect(var parent, var material):
	var effect = material.get("hit_effect")
	if effect:
		var type_node = SurfaceHitEffectType.new()
		type_node.effect = effect
		type_node.name = "SurfaceHitEffectType"

		parent.add_child(type_node)
		type_node.owner = parent.owner

func make_wall(var combiner, var size_x, var size_y, var material, var named):
	var csg_box = CSGBox.new()
	csg_box.name = named
	combiner.add_child(csg_box)
	csg_box.set_owner(combiner.owner)

	csg_box.use_collision = true
	csg_box.width = size_x
	csg_box.height = size_y
	csg_box.depth = 0.01
	csg_box.material = material

	configure_hit_effect(csg_box, material)

	return csg_box
