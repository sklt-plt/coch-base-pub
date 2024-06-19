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

extends Spatial
class_name GridMapHelper

static func configure_surface_type(var gmap : GridMap):
	var maybe_tile = gmap.mesh_library.get_item_mesh(0)
	if !maybe_tile:
		return

	if !maybe_tile.surface_get_material(0):
		return

	var effect = maybe_tile.surface_get_material(0).get("hit_effect")
	if effect:
		var type_node = SurfaceHitEffectType.new()
		type_node.effect = effect
		type_node.name = "SurfaceHitEffectType"

		gmap.add_child(type_node)
		type_node.owner = gmap.owner
		return

	print("Warning: not found surface type for mesh library: ", gmap.mesh_library.resource_path)

static func configure_gridmap(var room_geometry: RoomGeometry, var tiles: MeshLibrary):
	#make & configure gridmap
	var gmap_cell_size = 1
	var gmap_scale = 1

	var gmap = GridMap.new()
	gmap.mesh_library = tiles
	gmap.cell_center_x = false
	gmap.cell_center_y = false
	gmap.cell_center_z = false
	gmap.cell_size = Vector3(gmap_cell_size,gmap_cell_size,gmap_cell_size)
	gmap.cell_scale = gmap_scale
	gmap.cell_octant_size = 2048
	gmap.name = "DetailMap"

	room_geometry.add_child(gmap)
	gmap.owner = room_geometry.owner

	configure_surface_type(gmap)

	return gmap
