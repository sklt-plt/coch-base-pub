tool
extends Node

const EDITOR_DIFFICULTY = 1

enum CAMPAIGN_DIFFICULTY_ID {
	EASY = 0,
	NORMAL = 1,
	HARD = 2,
	HARD_OHKO = 3,
	HARD_IRON = 4,
	CUSTOM = 5
}

#var content_pack_path = "res://Content/default"
var content_pack_path = "res://Content/custom"

var player_progress = {
	"1" : false,
	"2" : false,
	"3" : false
}

var applying_setings = false
var first_setup = true

var user_settings = {
	#video
	"screen_mode": 1,
	"resolution": 1.0,
	"vsync": true,
	"max_fps": 0,
	"antialiasing": 0,
	"sharpening": 0,
	"shadows": false,
	"ao": true,
	"fov": 90,
	#audio
	"master_volume": 0.5,
	"music_volume": 0.5,
	"effects_volume": 1.0,
	#controls
	"mouse_sensitivity": 0.225,
	"invert_mouse_y": false,
	"toggle_aim": false,
	"toggle_run": false,
	"invert_run": false,
	#misc
}

var campaign_difficulty_idx = 1

var campaign_difficulties = [
	#Easy
	{
		"enemy_firepower_scale": 0.3,
		"player_firepower_scale": 2,
		"enemy_am_scale": 0.6,
		"item_am_scale": 2,
		"campaign_seed": "",
		"level_main_path_scale": 0.5,
		"level_sub_path_scale": 0.5,
		"level_sub_path_amount": 0.5,
		"score_req": [0, 0],
		"one_hit_ko": false,
		"ironman": false,
	},
	#Normal
	{
		"enemy_firepower_scale": 0.6,
		"player_firepower_scale": 1,
		"enemy_am_scale": 1,
		"item_am_scale": 1,
		"campaign_seed": "",
		"level_main_path_scale": 1,
		"level_sub_path_scale": 1,
		"level_sub_path_amount": 1,
		"score_req": [300, 300],
		"one_hit_ko": false,
		"ironman": false,
	},
	#Hard
	{
		"enemy_firepower_scale": 1.2,
		"player_firepower_scale": 1,
		"enemy_am_scale": 2,
		"item_am_scale": 1,
		"campaign_seed": "",
		"level_main_path_scale": 1,
		"level_sub_path_scale": 1.75,
		"level_sub_path_amount": 1,
		"score_req": [900, 900],
		"one_hit_ko": false,
		"ironman": false,
	},
	#Hard Iron
	{
		"enemy_firepower_scale": 1.2,
		"player_firepower_scale": 1,
		"enemy_am_scale": 2,
		"item_am_scale": 1,
		"campaign_seed": "",
		"level_main_path_scale": 1,
		"level_sub_path_scale": 1.75,
		"level_sub_path_amount": 1,
		"score_req": [900, 900],
		"one_hit_ko": false,
		"ironman": true,
	},
	#Hard OHKO
	{
		"enemy_firepower_scale": 1.2,
		"player_firepower_scale": 1,
		"enemy_am_scale": 2,
		"item_am_scale": 1,
		"campaign_seed": "",
		"level_main_path_scale": 1,
		"level_sub_path_scale": 1.75,
		"level_sub_path_amount": 1,
		"score_req": [900, 900],
		"one_hit_ko": true,
		"ironman": false,
	},
	#Custom
	{
		"enemy_firepower_scale": 100,
		"player_firepower_scale": 100,
		"enemy_am_scale": 0,
		"item_am_scale": 0,
		"campaign_seed": "a",
		"level_main_path_scale": 1,
		"level_sub_path_scale": 0.5,
		"level_sub_path_amount": 1,
		"score_req": [0, 0],
		"one_hit_ko": false,
		"ironman": false,
	}
]

const player_input_settings = {"Aim" : "", "Quick Melee" : "", "Backwards" : "", "Crawl" : "", "Fire" : "", "Forward" : "", "Interact" : "",
	"Jump" : "", "Run" : "", "Select Revolver" : "", "Select Shotgun" : "", "Select Crossbow" : "", "Select Melee" : "", "Strafe Left" : "", "Strafe Right" : "",
	"Select Prev" : "", "Select Next" : "", "Show Map" : ""}

const USER_INPUT_FILENAME = "user://user_input.cfg"
const USER_SETTINGS_FILENAME = "user://user_settings.cfg"
const USER_PROGRESS_FILENAME = "user://user_progress.sav"
const USER_DIFFICULTY_FILENAME = "user://user_difficulty.cfg"

func set_ep_completed(var episode_idx: int, var value : bool):
	player_progress[String(episode_idx)] = value
	save_user_progress()

func load_user_progress():
	if not FileHelper.load_file(USER_PROGRESS_FILENAME, player_progress):
		save_user_progress()

func load_user_difficulty():
	if not FileHelper.load_file(USER_DIFFICULTY_FILENAME, campaign_difficulties[CAMPAIGN_DIFFICULTY_ID.CUSTOM]):
		save_user_difficulty()

func save_user_difficulty():
	FileHelper.save_file(USER_DIFFICULTY_FILENAME, campaign_difficulties[CAMPAIGN_DIFFICULTY_ID.CUSTOM])

func save_user_progress():
	FileHelper.save_file(USER_PROGRESS_FILENAME, player_progress)

func save_user_inputs():
	var to_save = {}
	for i in player_input_settings:
		var event = InputMap.get_action_list(i)[0]
		var as_text

		if event is InputEventMouseButton:
			as_text = "m"+String(event.button_index)
		elif event is InputEventKey:
			as_text = InputMap.get_action_list(i)[0].scancode

		to_save[i] = as_text

	FileHelper.save_file(USER_INPUT_FILENAME, to_save)

func load_user_inputs():
	#load game settings from file

	if not FileHelper.load_file(USER_INPUT_FILENAME, player_input_settings):
		save_user_inputs()
		return

	for setting in player_input_settings:
		var event
		if player_input_settings[setting] is String and player_input_settings[setting].begins_with("m"):
			event = InputEventMouseButton.new()
			event.button_index = int(player_input_settings[setting].substr(1))
		else:
			event = InputEventKey.new()
			event.scancode = int(player_input_settings[setting])

		InputHelper.set_input(setting, event)

func apply_user_difficulty(var new_settings : Dictionary):
	#chaos control
	if applying_setings:
		return

	applying_setings = true

	for setting in new_settings:
		#compare if anything changed
		if first_setup or new_settings[setting] != user_settings[setting]:
			user_settings[setting] = new_settings[setting]

	applying_setings = false

func apply_user_settings(var new_settings : Dictionary):
	#chaos control
	if applying_setings:
		return

	applying_setings = true

	for setting in new_settings:
		#compare if anything changed
		if first_setup or new_settings[setting] != user_settings[setting]:

			user_settings[setting] = new_settings[setting]

			#finally apply 'setting' that have changed
			#Lights handled when loading scene
			if setting == "screen_mode" or setting == "resolution":
				match int(user_settings["screen_mode"]):
					0:
						OS.window_fullscreen = true
					1:
						OS.window_fullscreen = false
						OS.window_borderless = false
					2:
						OS.window_fullscreen = false
						OS.window_borderless = true

				# if we try immediately apply resolution after switching screen mode, godot will override it
				yield(get_tree(), "idle_frame")
				yield(get_tree(), "idle_frame")
				yield(get_tree(), "idle_frame")

				if OS.window_fullscreen:
					$"/root".size.x = user_settings["resolution"]*OS.window_size.x
					$"/root".size.y = user_settings["resolution"]*OS.window_size.y
				else:
					OS.window_size.x = OS.get_screen_size().x * 0.5 * user_settings["resolution"]
					OS.window_size.y = OS.get_screen_size().y * 0.5 * user_settings["resolution"]
					OS.center_window()

				var font_cache = get_node_or_null("/root/FontCache")
				if font_cache:
					for i in range(0, font_cache.font_default_sizes.size()):
						font_cache.font_resources[i].size = font_cache.font_default_sizes[i]*OS.window_size.y / 1000

			if setting == "vsync":
				OS.vsync_enabled = user_settings["vsync"]

			# no effect?
			if setting == "max_fps":
				ProjectSettings.set("application/run/frame_delay_msec", user_settings["max_fps"])

			if setting == "antialiasing":
				match int(user_settings["antialiasing"]):
					0:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_DISABLED
					1:
						get_viewport().fxaa = true
						get_viewport().msaa = Viewport.MSAA_DISABLED
					2:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_2X
					3:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_4X
					4:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_8X
					5:
						get_viewport().fxaa = false
						get_viewport().msaa = Viewport.MSAA_16X

			if setting == "sharpening":
				get_viewport().sharpen_intensity = user_settings["sharpening"]

			if setting == "shadows" or setting == "ao":
				var envs = get_tree().get_nodes_in_group("environment")
				for e in envs:
					e.update_to_settings()

			if setting == "fov":
				$"/root/Player".set_fov(user_settings["fov"])
				$"/root/Player/PlayerAnimations".base_fov = user_settings["fov"]

			if setting == "master_volume":
				AudioServer.set_bus_volume_db(0, linear2db(user_settings["master_volume"]))

			if setting == "music_volume":
				AudioServer.set_bus_volume_db(1, linear2db(user_settings["music_volume"]))

			if setting == "effects_volume":
				AudioServer.set_bus_volume_db(2, linear2db(user_settings["effects_volume"]))

			if setting == "mouse_sensitivity":
				$"/root/Player/PlayerMovement".mouse_sensitivity = user_settings["mouse_sensitivity"]
				$"/root/Player/PlayerAnimations".base_sensitivity = user_settings["mouse_sensitivity"]

			# handled elsewhere:
			# toggle_aim, invert_mouse_y, toggle_run, invert_run

	applying_setings = false
	first_setup = false

func load_user_settings():
	#load game settings from file if possible
	var loaded_settings = user_settings.duplicate()

	if FileHelper.load_file(USER_SETTINGS_FILENAME, loaded_settings):
		apply_user_settings(loaded_settings)

	#if not, setup defaults
	else:
		apply_user_settings(user_settings)
		save_user_settings()

func save_user_settings():
	FileHelper.save_file(USER_SETTINGS_FILENAME, user_settings)

func get_difficulty_field(var field: String):
	if Engine.editor_hint:
		return campaign_difficulties[EDITOR_DIFFICULTY][field]

	if $"/root/EpisodeManager".is_normal_episode_playing():
		return campaign_difficulties[campaign_difficulty_idx][field]
	else:
		return campaign_difficulties[1][field]
