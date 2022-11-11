extends Node
class_name PrefabHelper

const EXITS_OFFSET = 1

static func create_prefab_room(var room : GeneratedRoom, var room_geometry : RoomGeometry,
	var rng : RandomNumberGenerator):
	var prefab_gridmap = room.prefab_room.instance()
	var rotated_gridmap = rotate_gridmap(room.prefab_rotation, prefab_gridmap)
	room_geometry.add_child(rotated_gridmap)
	rotated_gridmap.owner = room_geometry.get_parent().get_parent()
	rotate_and_add_children(room.prefab_rotation, prefab_gridmap, rotated_gridmap, room.size)
	GridMapHelper.configure_surface_type(rotated_gridmap)

static func rotate_and_add_children(var direction: int, var prefab_gridmap: GridMap,
	var rotated_gridmap: GridMap, var room_size: Vector3):
	var children = prefab_gridmap.get_children()
	var new_parent = Spatial.new()
	rotated_gridmap.add_child(new_parent)
	new_parent.name = "ObjectsParent"
	new_parent.owner = rotated_gridmap.owner
	new_parent.rotate_y(deg2rad(-90*direction))
	match direction:
		1:
			new_parent.translation = Vector3(room_size.x, 0, 0)
		2:
			new_parent.translation = Vector3(room_size.x, 0, room_size.z)
		3:
			new_parent.translation = Vector3(0, 0, room_size.z)

	for c in children:
		if c is Spatial:
			prefab_gridmap.remove_child(c)
			new_parent.add_child(c)
			c.owner = new_parent.owner

static func rotate_gridmap(var direction: int, var gridmap: GridMap):
	if direction > 0:
		var rotated = GridMap.new()
		copy_params(rotated, gridmap)

		#rotate gridmap
		var max_xyz = find_max_xyz(gridmap)

		for y in range(0, max_xyz["y"] + 1):
			for x in range(0, max_xyz["x"] + 1):
				for z in range(0, max_xyz["z"] + 1):
					var source_tile = gridmap.get_cell_item(x, y, z)

					if source_tile == GeneratorConstants.TILE_NORTH_EXIT_ID:
						rotated.set_cell_item(max_xyz["z"] - z, y, x, GeneratorConstants.TILE_EAST_EXIT_ID)
					elif source_tile == GeneratorConstants.TILE_EAST_EXIT_ID:
						rotated.set_cell_item(max_xyz["z"] - z - EXITS_OFFSET, y, x, GeneratorConstants.TILE_SOUTH_EXIT_ID)
					elif source_tile == GeneratorConstants.TILE_SOUTH_EXIT_ID:
						rotated.set_cell_item(max_xyz["z"] - z, y, x, GeneratorConstants.TILE_WEST_EXIT_ID)
					elif source_tile == GeneratorConstants.TILE_WEST_EXIT_ID:
						rotated.set_cell_item(max_xyz["z"] - z - EXITS_OFFSET, y, x, GeneratorConstants.TILE_NORTH_EXIT_ID)
					elif source_tile != -1:
						rotated.set_cell_item(max_xyz["z"] - z, y, x, source_tile)

		return rotate_gridmap(direction-1, rotated)
	else:
		return gridmap

static func copy_params(var new: GridMap, var oryginal: GridMap):
	new.name = oryginal.name
	new.cell_size = oryginal.cell_size
	new.cell_octant_size = oryginal.cell_octant_size
	new.cell_scale = oryginal.cell_scale
	new.collision_layer = oryginal.collision_layer
	new.collision_mask = oryginal.collision_mask
	new.cell_center_x = oryginal.cell_center_x
	new.cell_center_y = oryginal.cell_center_y
	new.cell_center_z = oryginal.cell_center_z
	new.mesh_library = oryginal.mesh_library

static func find_max_xyz(var gridmap: GridMap):
	var ret = {"x": 0, "y": 0, "z": 0}

	var all_cells = gridmap.get_used_cells()

	for c in all_cells:
		if c.x > ret["x"]:
			ret["x"] = c.x
		if c.y > ret["y"]:
			ret["y"] = c.y
		if c.z > ret["z"]:
			ret["z"] = c.z

	return ret
