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
class_name TilesOutlineHelper

static func make_tile_outiline(var possible_tile_ids: Array,
	var trigger_tile: int, var outline_tile_id:int, var gmap: GridMap):

	var tiles = gmap.get_used_cells()
	var floor_tiles = []

	for t in tiles:
		for p in possible_tile_ids:
			if gmap.get_cell_item(t.x, t.y, t.z) == p:
				floor_tiles.append(t)

	for ft in floor_tiles:
		if (gmap.get_cell_item(ft.x+1, ft.y, ft.z) == trigger_tile
			or gmap.get_cell_item(ft.x+1, ft.y, ft.z+1) == trigger_tile
			or gmap.get_cell_item(ft.x, ft.y, ft.z+1) == trigger_tile
			or gmap.get_cell_item(ft.x-1, ft.y, ft.z+1) == trigger_tile
			or gmap.get_cell_item(ft.x-1, ft.y, ft.z) == trigger_tile
			or gmap.get_cell_item(ft.x-1, ft.y, ft.z-1) == trigger_tile
			or gmap.get_cell_item(ft.x, ft.y, ft.z-1) == trigger_tile
			or gmap.get_cell_item(ft.x+1, ft.y, ft.z-1) == trigger_tile
		):
			gmap.set_cell_item(ft.x, ft.y, ft.z, outline_tile_id)
