extends Node
class_name GunController

var guns = []
var current_gun : BaseGun
var current_gun_idx = 0

var in_fire = false
var in_fire_just_pressed = false
var in_alt_just_pressed = false
var in_alt_just_released = false
var in_qmelee = false
var in_select = false
var in_select_ind
var in_select_next = false
var in_select_prev = false

var is_switching = false

func _ready():
	var maybe_guns = get_children()
	for mg in maybe_guns:
		if mg is BaseGun:
			guns.push_back(mg)

	if not guns.empty():
		hide_all_guns_except(0)

func process_inputs():
	if $"/root/Player/PlayerMovement".on_ladder and not $"/root/Player".is_on_floor():
		self.visible = false
		return
	else:
		self.visible = true

	if current_gun:
		if ((in_fire_just_pressed or (in_fire && current_gun.automatic)) and not is_switching):
			current_gun.fire()

		if (in_alt_just_pressed) and not is_switching:
			if Globals.user_settings["toggle_aim"]:
				current_gun.switch_aim_mode()
			else:
				current_gun.begin_aim()

		if (in_alt_just_released and !Globals.user_settings["toggle_aim"]) and not is_switching:
			current_gun.end_aim()

	if in_qmelee:
		guns[0].visible = true
		guns[0].fire()

	if in_select:
		switch_guns(in_select_ind)

	if in_select_next:
		var i = current_gun_idx + 1
		i = i % guns.size()
		while i != current_gun_idx and not switch_guns(i):
			i += 1
			i = i % guns.size()

	if in_select_prev:
		var i = current_gun_idx - 1
		if i < 0: i = guns.size() - 1
		while i != current_gun_idx and not switch_guns(i):
			i -= 1
			if i < 0: i = guns.size() - 1

func switch_guns(var index: int, var show_on_hud = true):
	if not current_gun.firing_timer.is_stopped():
		return false

	match index:
		0:
			if not $"/root/Player".has("e_melee_level", 1):
				return false
		1:
			if not $"/root/Player".has("e_pistol_level", 1):
				return false
		2:
			if not $"/root/Player".has("e_double_barrel_level", 1):
				return false
		3:
			if not $"/root/Player".has("e_crossbow_level", 1):
				return false
		_:
			return false

	is_switching = true
	current_gun.interrupt_reload()

	$"/root/Player/PlayerAnimations"._on_switch_input()

	if show_on_hud:
		$"/root/Player/HUD/Guns".show_guns(index)
	$"/root/Player/HUD".update_gun_index(index)

	$SwitchingTimer.switching_idx = index
	$SwitchingTimer.start()

	return true # switched

func finish_switching(var index):
	current_gun_idx = index
	hide_all_guns_except(index)
	is_switching = false

func hide_all_guns_except(var index : int):
	current_gun = guns[index]
	for i in range(0, guns.size()):
		if guns[i] is BaseGun:
			if i == index:
				guns[i].show()
			else:
				guns[i].visible = false
