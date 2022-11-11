extends FurnishedInteriorGenerator
class_name FurnishedArenaGenerator
tool

func generate(var room_geometry : RoomGeometry):
	var gmap = GridMapHelper.configure_gridmap(room_geometry, _tiles)

	fill_gmap_with_reserved_tiles(room_geometry, gmap)

	.place_path_objects(room_geometry, gmap, _side_furniture_generator)

	TilesOutlineHelper.make_tile_outiline([GeneratorConstants.TILE_RESERVED_PATH_ID, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID],
		GridMap.INVALID_CELL_ITEM, GeneratorConstants.TILE_ITEM_ID, gmap)

	.place_path_objects(room_geometry, gmap, _path_furniture_generator)

func fill_gmap_with_reserved_tiles(var room_geometry: RoomGeometry, var gmap: GridMap):
	var is_main_path_room = get_node(room_geometry.tree_ref).traits.has(GeneratedRoom.ROOM_TRAITS.MAIN)

	for x in range(1, room_geometry.size.x):
		for z in range(1, room_geometry.size.z):
			if is_main_path_room:
				gmap.set_cell_item(x, 0, z, GeneratorConstants.TILE_RESERVED_PATH_ID)
			else:
				gmap.set_cell_item(x, 0, z, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID)
