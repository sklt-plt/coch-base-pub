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

var current_ep = -1
var episode_levels
var current_level_idx
var episode_clear_idx = -1

func reset_episode_cache():
	current_ep = -1
	episode_levels = []
	current_level_idx = -1

func next_map_in_ep():
	current_level_idx += 1
	var path = Globals.content_pack_path + "/Maps/Levels/ep" + String(current_ep) + "/map" + String(current_level_idx) + ".tscn"
	return change_map(path)

func next_map():
	$"/root/Player".give("s_level", 1)

	if current_ep <= 100:
		next_map_in_ep()
	elif current_ep > 100 and current_ep <= 200:
		restart_current_map()
	elif current_ep > 200:
		next_map_in_ep()

func restart_episode():
	start_episode(current_ep)

func restart_current_map():
	current_level_idx -= 1
	next_map_in_ep()

func change_map(var map_path: String):
	#flush caches
	$"/root/AIManager".clear_registrations()
	$"/root/Player".get_node("TriggerDetector").flush_cache()
	$"/root/Player".show_loading()
	yield(get_tree().create_timer(0.05), "timeout")

	if get_tree().change_scene(map_path) != OK:
		if is_normal_episode_playing():
			$"/root/Player".hide_loading()

			if not Globals.player_progress[String(current_ep)] :
				Globals.set_ep_completed(current_ep, true)
				episode_clear_idx = current_ep

			$"/root/Player/GameOverStats".show()
			AchievementHelper.give_clear_ep_achievements(current_ep)

		print("Can't load level: ", map_path)
		return false

	return true

func quit_to_menu():
	get_tree().paused = false
	$"/root/Player".reset()
	$"/root/Player".hide_loading()
	$"/root/Player/PauseMenu".visible = false
	$"/root/Player/GameOver".visible = false
	$"/root/Player".get_map_container().to_hidden()
	$"/root/Player/MusicController".crossfade_next_list([])
	$"/root/Player".get_node("TriggerDetector").flush_cache()
	$"/root/AIManager".clear_registrations()
	if get_tree().change_scene(Globals.content_pack_path + "/MainMenu/MainMenu.tscn") != OK:
		print("Can't load: ", Globals.content_pack_path + "/MainMenu/MainMenu.tscn")

func load_object_cache(var ep_idx: int):
	var cache_filename = Globals.content_pack_path + "/Ent/ObjectCacheEp" + String(ep_idx%100) + ".tscn"
	var object_cache = load(cache_filename)
	if object_cache:
		$"/root".call_deferred("add_child", object_cache.instance())
	else:
		print("Cannot load: ", cache_filename)

func start_episode(var ep_idx: int):
	reset_episode_cache()
	load_object_cache(ep_idx)
	current_ep = ep_idx

	$"/root/Player".reset()

	if is_endless_episode_playing():
		$"/root/Player".setup_arcade_mode()

	elif is_normal_episode_playing():
		$"/root/Player".setup_campaign_mode(Globals.get_difficulty_field("score_req"))

	next_map_in_ep()

func is_normal_episode_playing():
	return current_ep < 100

func is_endless_episode_playing():
	return current_ep >= 100 and current_ep < 200

func is_custom_episode_playing():
	return current_ep >= 200
