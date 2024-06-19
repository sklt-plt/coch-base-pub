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

const DEBUG_DEMO_EP = -1

func _ready():
	# load content pack
	if not ProjectSettings.load_resource_pack(Globals.content_pack_path + ".pck"):
		print("Cannot load resource pack: ", Globals.content_pack_path, ".pck, will attempt to use folder structure")

	#load stuff from active content pack
	#load fonts
	var font_scene = load(Globals.content_pack_path + "/UI/FontCache.tscn")
	if font_scene:
		$"/root".call_deferred("add_child", font_scene.instance())
	else:
		print("Cannot load: ", Globals.content_pack_path + "/UI/FontCache.tscn")

	# load player
	var player_scene = load(Globals.content_pack_path + "/Actors/Player/Player.tscn")

	if player_scene:
		$"/root".call_deferred("add_child", player_scene.instance())
	else:
		print("Cannot load: ", Globals.content_pack_path, "/Actors/Player/Player.tscn")

func on_player_ready():
	$"/root/Globals".load_user_settings()
	$"/root/Globals".load_user_inputs()
	$"/root/Globals".load_user_progress()
	$"/root/Globals".load_user_difficulty()

	#debug load demo
	if DEBUG_DEMO_EP > 0:
		$"/root/Player/HUD".visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$"/root/EpisodeManager".start_episode(DEBUG_DEMO_EP)
	else:
		# finally load main menu
		if get_tree().change_scene(Globals.content_pack_path + "/MainMenu/MainMenu.tscn") != OK:
			print("Can't load: ", Globals.content_pack_path + "/MainMenu/MainMenu.tscn")
