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
class_name GeneratorOverrides

var done = false

var gen_seed = ""
var make_ceilings = false
var links_on_floor = true

var main_path_length = 3
var sub_path_max_length = 3
var num_of_sub_paths = 3

var _min_room_size = 15
var _max_room_size = 15
var _min_room_height = 3
var _max_room_height = 4

var _average_room_difficulty = 0.0
var _average_difficulty_variation = 0

var _max_random_walks = 15
var _random_walks_widths

var _arena_obstacle_per_quadrant = 2
var _arena_obstacle_outline_thickness = 2
var _arena_obstacle_min_size = 1
var _arena_obstacle_max_size = 5

var use_prefabs = true
var _prefabs_on_main = true

const BASE_ROOM_SIZE = 15
const MAX_MAIN_PATH_ROOMS = 10
const MAX_SAFE_SUB_PATHS = 5
const MAX_SAFE_SUB_PATH_LENGHT = 3
const MAX_SAFE_ENEMY_BUDGET = 12
const MAX_SAFE_ROOM_SIZE = 35

func generate_overrides():
	var ui_node = get_node_or_null("OverridesUI")
	if ui_node:
		#player will set values and "done" through ui
		return
	else:
		#randomize overrides and set "done"
		randomize_values()
		done = true

func randomize_values():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var generator = get_parent()

	gen_seed = ""	# will be randomized by Generator

	var player_level_scale = float($"/root/Player".check("s_level")*1.8)
	var desired_difficulty = generator._rooms_data_generator._enemy_difficulty + player_level_scale

	num_of_sub_paths = min(rng.randi_range(player_level_scale/2, player_level_scale-1), MAX_SAFE_SUB_PATHS)
	sub_path_max_length = min(ceil(player_level_scale/3), MAX_SAFE_SUB_PATH_LENGHT)
	main_path_length = min(4+(player_level_scale), MAX_MAIN_PATH_ROOMS)

	_average_room_difficulty = min(desired_difficulty, MAX_SAFE_ENEMY_BUDGET)		#already randomized in generator
	_average_difficulty_variation = round(_average_room_difficulty*0.2)					#already randomized in generator

	var base_min_size = generator._rooms_data_generator._room_min_walls_length
	var base_max_size = generator._rooms_data_generator._room_max_walls_length
	_min_room_size = min(base_min_size + (base_min_size * $"/root/Player".check("s_level")*0.33), MAX_SAFE_ROOM_SIZE)
	_max_room_size = min(base_max_size + (base_max_size * $"/root/Player".check("s_level")*0.33), MAX_SAFE_ROOM_SIZE)

	_min_room_height = 3 + $"/root/Player".check("s_level")/2	#s_level is an integer so it should floor
	_max_room_height = _min_room_height + 2

	_max_random_walks =  round(_min_room_size*0.33)
	_random_walks_widths = rng.randi()%RandomWalksInteriorGenerator.PATH_WIDTHS_TABLES.size()

	_arena_obstacle_per_quadrant = round(rng.randf_range(_min_room_size*0.1, _min_room_size*0.2))
	_arena_obstacle_min_size = round(_min_room_size*0.1)
	_arena_obstacle_max_size = round(_min_room_size*0.5)

	_arena_obstacle_outline_thickness = round(_min_room_size*0.1)

	if (rng.randi()%100) > 70:
		use_prefabs = true
	else:
		use_prefabs = false

	if EpisodeManager.current_ep == 101 and $"/root/Player".check("s_level") == 3:
		$"/root/Player".give("e_double_barrel_level", 1)

	if EpisodeManager.current_ep == 102 and $"/root/Player".check("s_level") == 3:
		$"/root/Player".give("e_crossbow_level", 1)

func apply():
	var generator = get_parent()

	if generator is MapGenerator:
		generator.gen_seed = gen_seed
		generator._walls_generator._make_ceilings = make_ceilings
		generator._walls_generator._links_on_floor = links_on_floor
		generator._rooms_data_generator._main_path_length = main_path_length
		generator._rooms_data_generator._sub_path_length = sub_path_max_length
		generator._rooms_data_generator._num_of_sub_paths = num_of_sub_paths
		generator._rooms_data_generator._room_min_walls_length = _min_room_size
		generator._rooms_data_generator._room_max_walls_length = _max_room_size
		generator._rooms_data_generator._room_min_walls_height = _min_room_height
		generator._rooms_data_generator._room_max_walls_height = _max_room_height
		generator._rooms_data_generator._enemy_difficulty = _average_room_difficulty
		generator._rooms_data_generator._enemy_difficulty_variation = _average_difficulty_variation
		generator._random_walks_interior_generator._num_of_random_paths = _max_random_walks
		#generator._random_walks_interior_generator.side_path_widths = _random_walks_widths  TODO: CHECK
		generator._arena_generator.obstacles_per_quadrant = _arena_obstacle_per_quadrant
		generator._arena_generator.obstacle_outline = _arena_obstacle_outline_thickness
		generator._arena_generator.min_obstacle_length = _arena_obstacle_min_size
		generator._arena_generator.max_obstacle_length = _arena_obstacle_max_size
		if not use_prefabs:
			generator._rooms_data_generator._prefab_rooms = []
		generator._rooms_data_generator._prefabs_on_main = _prefabs_on_main
	else:
		print("This node must be child of MapGenerator")
		return
