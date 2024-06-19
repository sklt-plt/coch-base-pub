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

extends RandomWalksInteriorGenerator
class_name FurnishedInteriorGenerator
tool

export (int) var path_furniture_margin = 2
export (float) var max_path_objects_percent = 0.02

var _side_furniture_generator
var _path_furniture_generator

func generate(var room_geometry : RoomGeometry):
	var gmap = GridMapHelper.configure_gridmap(room_geometry, _tiles) as GridMap
	place_paths(room_geometry, gmap)

	TilesOutlineHelper.make_tile_outiline([GeneratorConstants.TILE_RESERVED_PATH_ID, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID],
		GridMap.INVALID_CELL_ITEM, GeneratorConstants.TILE_ITEM_ID, gmap)

	place_side_objects(room_geometry, gmap, _side_furniture_generator)

	place_path_objects(room_geometry, gmap, _path_furniture_generator)


func place_path_objects(var room_geometry: RoomGeometry, var gmap: GridMap,
	var generator: FurnitureGenerator):

	var usable_tiles = []
	for t in gmap.get_used_cells():
		if (gmap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_RESERVED_PATH_ID
			or gmap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_RESERVED_SUB_PATH_ID):

			usable_tiles.push_back(t)

	if usable_tiles.empty():
		return

	var attempts = usable_tiles.size() * max_path_objects_percent

	for i in range(0, attempts):
		if usable_tiles.empty():
			return

		var target_tile = usable_tiles[_rng.randi()%usable_tiles.size()]

		var target_direction = _rng.randi()%4

		var sizes = generator.get_furniture_sizes()
		var target_id = _rng.randi()%sizes.size()
		var target_size = sizes[target_id]

		var corners = find_objects_corners(target_tile, target_direction, target_size, path_furniture_margin)
		var real_corners = find_objects_corners(target_tile, target_direction, target_size)

		if (object_collides_with_tiles(corners, gmap, false)
			or object_collides_with_room_bounds(corners, room_geometry.size)):
			continue

		var target_dict = generator.get_randomized_furniture(target_id)

		add_and_align_object_in_room(target_dict["root"], target_tile, target_direction, room_geometry)

		spawn_entities_in_room(target_dict["entities"], room_geometry)

		mark_used_spaces(corners, gmap)
		remove_floor_tiles(real_corners, gmap)
		update_available_pool(usable_tiles, corners)

func remove_floor_tiles(corners, gmap):
	for x in range(corners["x1"], corners["x2"]+1):
		for z in range(corners["y1"], corners["y2"]+1):
			gmap.set_cell_item(x, 0, z, GridMap.INVALID_CELL_ITEM)

func place_side_objects(var room_geometry: RoomGeometry, var gmap: GridMap,
	var generator: FurnitureGenerator):

	var outline_tiles = []
	for t in gmap.get_used_cells():
		if gmap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_ITEM_ID:
			outline_tiles.push_back(t)

	if outline_tiles.empty():
		print("uhhhh, no room to place anything, this shouldn't happen")
		return

	for i in range(0, outline_tiles.size()):
		if not outline_tiles[i]:
			continue

		var target_tile = outline_tiles[i]

		var target_direction = find_outline_to_path_direction(target_tile, gmap)
		if target_direction == -1:
			continue

		var sizes = generator.get_furniture_sizes()
		var target_id = _rng.randi()%sizes.size()
		var target_size = sizes[target_id]

		var corners = find_objects_corners(target_tile, target_direction, target_size)

		if (object_collides_with_tiles(corners, gmap)
			or object_collides_with_room_bounds(corners, room_geometry.size)):
			continue

		var target_dict = generator.get_randomized_furniture(target_id)

		add_and_align_object_in_room(target_dict["root"], target_tile, target_direction, room_geometry)

		spawn_entities_in_room(target_dict["entities"], room_geometry)

		mark_used_spaces(corners, gmap)

func spawn_entities_in_room(var entity_spawns: Array, var room_geometry: RoomGeometry):
	for ent_spawn in entity_spawns:
		var ent = ent_spawn.ref
		room_geometry.add_child(ent)
		ent.owner = room_geometry.owner

		ent.rotation = ent_spawn.rotation
		ent.global_translation = ent_spawn.global_translation

func update_available_pool(var outline_tiles, var object_corners: Dictionary):
	for x in range(object_corners["x1"], object_corners["x2"]+1):
		for z in range(object_corners["y1"], object_corners["y2"]+1):
			outline_tiles.erase(Vector3(x, 0, z))

func mark_used_spaces(var corners: Dictionary, var gmap: GridMap):
	for x in range(corners["x1"],corners["x2"]+1):
		for y in range(corners["y1"],corners["y2"]+1):
			gmap.set_cell_item(x, -1, y, GeneratorConstants.TILE_OBSTACLE_ID)

func add_and_align_object_in_room(var target_instance, var target_origin, var target_direction, var parent):
	parent.add_child(target_instance)
	target_instance.owner = parent.owner

	target_instance.translate(target_origin+Vector3(-0.5,0,0.5))
	match target_direction:
		0:
			target_instance.rotation_degrees.y = 180
			if target_instance is FurnitureObject:
				target_instance.translate_object_local(Vector3(-target_instance.size.x, 0, 0))
		1:
			target_instance.translate_object_local(Vector3(0, 0, -1))
		2:
			target_instance.rotation_degrees.y = -90
			target_instance.translate_object_local(Vector3(-1, 0, -1))
		3:
			target_instance.rotation_degrees.y = 90

func object_collides_with_room_bounds(var corners: Dictionary, var bounds: Vector3):
	if corners["x1"] < 1 or corners["y1"] < 1 or corners["x2"] >= bounds.x or corners["y2"] >= bounds.z:
		return true

	return false

func object_collides_with_tiles(var corners: Dictionary, var gmap: GridMap, var off_path = true):
	for x in range(corners["x1"],corners["x2"]+1):
		for y in range(corners["y1"],corners["y2"]+1):
			if off_path:
				if (gmap.get_cell_item(x, 0, y) != GridMap.INVALID_CELL_ITEM        # collision with paths / item tiles
					or gmap.get_cell_item(x, -1, y) != GridMap.INVALID_CELL_ITEM):  # collision with other objects

					return true
			else:
				if (gmap.get_cell_item(x, 0, y) == GeneratorConstants.TILE_ITEM_ID   # collision with path outline
					or gmap.get_cell_item(x, -1, y) != GridMap.INVALID_CELL_ITEM):  # collision with other objects

					return true

	return false

func find_objects_corners(var target_tile: Vector3, var target_direction: int, var target_size: Vector3, var margin: int = 0):
	var corners = {
		"x1" : -1,
		"x2" : -1,
		"y1" : -1,
		"y2" : -1}

	match target_direction:
		0:
			corners["x1"] = target_tile.x
			corners["x2"] = corners["x1"] + target_size.x-1
			corners["y1"] = target_tile.z +1
			corners["y2"] = corners["y1"] + target_size.z-1
		1:
			corners["x1"] = target_tile.x
			corners["x2"] = corners["x1"] + target_size.x -1
			corners["y1"] = target_tile.z - target_size.z
			corners["y2"] = target_tile.z -1
		2:
			corners["x1"] = target_tile.x +1
			corners["x2"] = corners["x1"] + target_size.z-1
			corners["y1"] = target_tile.z
			corners["y2"] = corners["y1"] + target_size.x-1
		3:
			corners["x1"] = target_tile.x - target_size.z
			corners["x2"] = target_tile.x -1
			corners["y1"] = target_tile.z - target_size.x +1
			corners["y2"] = target_tile.z

	corners["x1"] -= margin
	corners["x2"] += margin
	corners["y1"] -= margin
	corners["y2"] += margin

	return corners

func find_outline_to_path_direction(var tile_coords: Vector3, var gmap: GridMap):
	var north = gmap.get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z-1)
	var south = gmap.get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z+1)
	var west = gmap.get_cell_item(tile_coords.x-1, tile_coords.y, tile_coords.z)
	var east = gmap.get_cell_item(tile_coords.x+1, tile_coords.y, tile_coords.z)

	# corners are invalid!
	if ((is_tile_a_path(north) and is_tile_a_path(west))
		or (is_tile_a_path(north) and is_tile_a_path(east))
		or (is_tile_a_path(south) and is_tile_a_path(west))
		or (is_tile_a_path(south) and is_tile_a_path(east))):
			return -1
	elif is_tile_a_path(north):
		return 0
	elif is_tile_a_path(south):
		return 1
	elif is_tile_a_path(west):
		return 2
	elif is_tile_a_path(east):
		return 3
	else:
		return -1

func is_tile_a_path(var tileId: int):
	if (tileId == GeneratorConstants.TILE_RESERVED_PATH_ID
		or tileId == GeneratorConstants.TILE_RESERVED_SUB_PATH_ID):

		return true
	else:
		return false

func draw_walls(var real_x1, var real_x2, var real_z1, var real_z2, var wall_height, var gmap):
	return
