extends Node
class_name InputProxy

var is_locked = false

var player_movement_node
var player_animation_node
var gun_controller_node

func _ready():
	player_movement_node = get_parent().get_node("PlayerMovement")
	player_animation_node = get_parent().get_node("PlayerAnimations")
	gun_controller_node = get_parent().get_node("BodyCollision/LookHeight/LookDirection/GunController")

func _unhandled_input(_event):
	#cheats :
	if (Input.is_action_just_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
		&& get_tree().get_current_scene().get_name() != "MainMenu"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif Input.is_action_just_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if $"../PlayerResources".check("r_health") > 0.0:
			$"../PauseMenu".show()

	if $"../PlayerResources".check("r_health") <= 0.0 and Input.is_action_pressed("Jump"):
		if $"/root/EpisodeManager".is_normal_episode_playing():
			$"../GameOver".show()
		else:
			$"../GameOverStats".show()

	if Input.is_action_pressed("DBG_ENABLE"):
		if Input.is_action_just_pressed("DBG_1"):
			if not $"../PlayerMovement".is_flying:
				get_node("/root/Player").start_flying()
				get_node("/root/Player/BodyCollision").disabled = true
				print("Noclip on")
			else:
				get_node("/root/Player").stop_flying()
				get_node("/root/Player/BodyCollision").disabled = false
				print("Noclip off")

		if Input.is_action_just_pressed("DBG_2"):
			if not get_tree().paused:
				$"/root/Player".pause_mode = Node.PAUSE_MODE_PROCESS
				$"/root/Player".visible = false
				$"/root/Player/HUD".visible = false
				$"/root/Player/MapContainer".visible = false
				get_tree().paused = true
			else:
				$"/root/Player".pause_mode = Node.PAUSE_MODE_INHERIT
				$"/root/Player".visible = true
				$"/root/Player/HUD".visible = true
				$"/root/Player/MapContainer".visible = true
				get_tree().paused = false

		if Input.is_action_just_pressed("DBG_3"):
			Globals.set_ep_completed(1, not Globals.player_progress["1"])
			Globals.set_ep_completed(2, not Globals.player_progress["2"])
			EpisodeManager.change_map(Globals.content_pack_path + "/MainMenu/MainMenu.tscn")
			$"/root/Player".hide_loading()

		if Input.is_action_just_pressed("DBG_4"):
			$"/root/Player".give("e_double_barrel_level", 1)
			$"/root/Player".give("e_crossbow_level", 1)
			$"/root/Player".give("r_pistol_ammo", 100)
			$"/root/Player".give("r_shotgun_ammo", 100)
			$"/root/Player".give("r_crossbow_ammo", 100)
			$"/root/Player".give("r_health", 100)
			$"/root/Player".give("r_armor", 100)
			$"/root/Player".give("r_keys", 1)

		if Input.is_action_just_pressed("DBG_5"):
			if $"/root/EpisodeManager".is_custom_episode_playing():
				$"/root/EpisodeManager".current_level_idx = -1
			EpisodeManager.next_map()

		if Input.is_action_just_pressed("DBG_6"):
			EpisodeManager.change_map("res://Content/custom/Maps/TestMap.tscn")
			$"/root/Player".hide_loading()
			$"/root/Player".reset()

		if Input.is_action_just_pressed("DBG_7"):
			$"/root/Player/HUD".visible = false
			$"/root/Player/MapContainer".visible = false
			$"/root/Player/PlayerResources".r_health = INF
			$"/root/Player/PlayerResources".resources_limits = {
				"r_health" : 99999, #100
				"r_armor"  : 99999,
				"r_pistol_ammo" : 99999,
				"r_shotgun_ammo" : 99999,
				"r_crossbow_ammo" : 99999,
				"r_keys" : 100,
				"e_melee_level" : 1,
				"e_pistol_level" : 1,
				"e_double_barrel_level" : 1,
				"e_crossbow_level" : 1,
				"r_time_left" : 1,
				"r_time_freeze": 1.04
			}
			$"/root/Player/PlayerResources".r_health = 99999
			$"/root/Player/PlayerResources".r_armor = 99999
			$"/root/Player/PlayerResources".r_pistol_ammo = 99999
			$"/root/Player/PlayerResources".r_shotgun_ammo = 99999
			$"/root/Player/PlayerResources".r_crossbow_ammo = 99999

		if Input.is_action_just_pressed("DBG_9"):
			if Engine.time_scale < 1:
				Engine.time_scale = 1
			else:
				Engine.time_scale = 0.5

func _process(delta):
	if not is_locked:
		var proxy_joy = Vector2()
		var proxy_fire
		var proxy_just_fired
		var proxy_alt_fire_just_pressed
		var proxy_alt_fire_just_released
		var proxy_qmelee
		var proxy_select
		var proxy_select_ind = 0
		var proxy_select_next
		var proxy_select_prev
		var proxy_run
		var proxy_jump
		var proxy_crawl

		#mouse wheel workaround
		#find which events mouse wheel is bound to
		#then "fix" by forcing that action press / release
		var all_actions = InputMap.get_actions()
		for action in all_actions:
			var event = InputEventMouseButton.new()
			event.button_index = BUTTON_WHEEL_DOWN
			if event.is_action(action) and action != "WheelDownProxy":
				if Input.is_action_just_released("WheelDownProxy"):
					Input.action_press(action)
				else:
					Input.action_release(action)
			event.button_index = BUTTON_WHEEL_UP
			if event.is_action(action) and action != "WheelUpProxy":
				if Input.is_action_just_released("WheelUpProxy"):
					Input.action_press(action)
				else:
					Input.action_release(action)

		#set actual buttons
		proxy_select_next = Input.is_action_just_pressed("Select Next")
		proxy_select_prev = Input.is_action_just_pressed("Select Prev")

		proxy_jump = Input.is_action_pressed("Jump")
		proxy_crawl = Input.is_action_pressed("Crawl")

		proxy_run = Input.is_action_pressed("Run")
		if Input.is_action_just_pressed("Run") and $"/root/Globals".user_settings["toggle_run"]:
			$"/root/Globals".user_settings["invert_run"] = !$"/root/Globals".user_settings["invert_run"]

		proxy_fire = Input.is_action_pressed("Fire")
		proxy_just_fired = Input.is_action_just_pressed("Fire")
		proxy_alt_fire_just_pressed = Input.is_action_just_pressed("Aim")
		proxy_alt_fire_just_released = Input.is_action_just_released("Aim")
		proxy_qmelee = Input.is_action_pressed("Quick Melee")

		proxy_select = Input.is_action_just_pressed("Select Melee") \
			or Input.is_action_just_pressed("Select Revolver") \
			or Input.is_action_just_pressed("Select Shotgun") \
			or Input.is_action_just_pressed("Select Crossbow")

		if Input.is_action_just_pressed("Select Melee"):
			proxy_select_ind = 0
		if Input.is_action_just_pressed("Select Revolver"):
			proxy_select_ind = 1
		if Input.is_action_just_pressed("Select Shotgun"):
			proxy_select_ind = 2
		if Input.is_action_just_pressed("Select Crossbow"):
			proxy_select_ind = 3

		proxy_joy = Vector2(fake_axis("Strafe Right", "Strafe Left"), fake_axis("Forward", "Backwards"))
		player_movement_node.joy_input = proxy_joy.normalized()
		player_animation_node.joy_input = proxy_joy.normalized()

		gun_controller_node.in_fire = proxy_fire
		gun_controller_node.in_fire_just_pressed = proxy_just_fired
		gun_controller_node.in_alt_just_pressed = proxy_alt_fire_just_pressed
		gun_controller_node.in_alt_just_released = proxy_alt_fire_just_released
		gun_controller_node.in_qmelee = proxy_qmelee
		gun_controller_node.in_select = proxy_select
		gun_controller_node.in_select_ind = proxy_select_ind
		gun_controller_node.in_select_next = proxy_select_next
		gun_controller_node.in_select_prev = proxy_select_prev
		gun_controller_node.process_inputs()

		player_movement_node.run_input = proxy_run
		player_movement_node.crawl_input = proxy_crawl
		player_movement_node.jump_input = proxy_jump
		player_movement_node.process_inputs(delta)

	else:
		player_movement_node.joy_input = Vector2(0.0, 0.0)
		gun_controller_node.in_fire = false
		gun_controller_node.in_fire_just_pressed = false
		gun_controller_node.in_qmelee = false
		gun_controller_node.process_inputs()

		player_movement_node.run_input = false
		player_movement_node.crawl_input = false
		player_movement_node.jump_input = false
		player_movement_node.process_inputs(delta)

func fake_axis(var positive, var negative):
	var ret = 0
	if Input.is_action_pressed(positive):
		ret += 1
	if Input.is_action_pressed(negative):
		ret -= 1
	return ret
