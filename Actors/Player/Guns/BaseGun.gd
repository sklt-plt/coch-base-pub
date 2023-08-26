extends Spatial
class_name BaseGun

signal AltFire
signal Reloaded

export (PackedScene) var projectile_scene				# projectile to spawn, leave empty to use raycast
export var bullet_damage = 5							# damage to deal per bullet
export var bullet_push_force = 1						# how much to push kinematic actor per bullet
export var bullets_at_once = 1							# number of bullets to calculate when firing, unrelated to magazine size
export var gun_inaccuracy = 0.017						# bullet spread when firing in normal mode
export var gun_inaccuracy_aim_mode = 0.005				# spread in alt mode
export var magazine_size = 6							# number of shots player can perform before reloading
export var instant_reload = false						# skip reload animation
export var automatic_reload = false						# reload without needing player interaction when magazine is empty
export var automatic = false							#if true gun will fire when holding down the fire button
export (String) var ammo_type = "change_me"				#resource name to take from player when firing

export (Array, String) var anims_idle = ["", ""]		#animation pairs
export (Array, String) var anims_fire = ["", ""]		#element 0 is gun animation name
export (Array, String) var anims_aim_prep = ["", ""]	#element 1 is hands animation name
export (Array, String) var anims_aim_fire = ["", ""]
export (Array, String) var anims_reload = ["", ""]

export (AudioStream) var audio_fire						# audio to play when firing in normal mode
export (AudioStream) var audio_reload					# audio to play when reloading

export (bool) var use_muzzle_flash = true

var rng : RandomNumberGenerator
var anim_player : AnimationPlayer
var anim_player_hands : AnimationPlayer
var current_magazine : int
var firing_timer : Timer
var reloading_timer : Timer

var in_aim_mode = false
var current_inaccuracy : float

func _ready():
	if !rng:
		rng = RandomNumberGenerator.new()
	rng.randomize()
	anim_player = $"Model/AnimationPlayer"
	anim_player_hands = $"../Hands/AnimationPlayer"
	current_magazine = magazine_size
	firing_timer = $"FiringTimer"
	reloading_timer = $"ReloadingTimer"
	current_inaccuracy = gun_inaccuracy

func fire():
	if current_magazine != 0 and are_all_timers_stopped() and $"/root/Player".take(ammo_type, 1):
		current_magazine -= 1

		if use_muzzle_flash:
			$"MuzzleFlash".show()

		if projectile_scene:
			var pr = projectile_scene.instance()
			get_tree().current_scene.add_child(pr)
			pr.global_rotation = $"../../WorldCamera".global_rotation
			pr.global_translation = self.global_translation

			if pr is ExplosiveProjectile:
				if self.connect("AltFire", pr, "detonate_explosive", [null]) != OK:
					print("Warn: couldn't connect signal AltFire to detonate projectile mid-air")
				var expl = pr.get_node("Explosive") as Explosive

				if self.connect("AltFire", expl, "explode", []) != OK:
					print("Warn: couldn't connect signal AltFire to detonate explosive")
		else:
			var any_hit = false
			for _i in range(0,bullets_at_once):
				if deal_damage_by_ray(construct_ray(current_inaccuracy)):
					any_hit = true

			if any_hit:
				$"/root/Player".give("s_shots_hit", 1)

		if not in_aim_mode:
			play_anim_pair(anims_fire)
		else:
			play_anim_pair(anims_aim_fire)

		if audio_fire:
				play_audio(audio_fire)

		$"/root/Player".give("s_shots_fired", 1)
		firing_timer.start()

	elif current_magazine == 0:
		reload()

func play_audio(var audio : AudioStream):
	if audio:
		if audio != audio_reload:
			$"/root/Player/SFXPlayer2".stream = audio
			$"/root/Player/SFXPlayer2".play()
		else:
			#we want to play reloading on different streamer so firing won't get cut-off
			$"/root/Player/SFXPlayer3".stream = audio
			$"/root/Player/SFXPlayer3".play()

func switch_aim_mode():
	if not in_aim_mode and are_all_timers_stopped():
		begin_aim()
	elif in_aim_mode and are_all_timers_stopped():
		end_aim()

func begin_aim():
	if reloading_timer.is_stopped():
		play_anim_pair(anims_aim_prep)
		in_aim_mode = true
		$"/root/Player/PlayerAnimations".zoom_fov()
		current_inaccuracy = gun_inaccuracy_aim_mode

func end_aim():
	play_anim_pair(anims_idle)
	$"/root/Player/PlayerAnimations".unzoom_fov()
	current_inaccuracy = gun_inaccuracy
	in_aim_mode = false

func finish_firing():
	if automatic_reload and current_magazine == 0:
		reload()

func reload():
	#can reload?
	if (are_all_timers_stopped()
		and not current_magazine == magazine_size
		and $"/root/Player".has(ammo_type, 1)):

			#how to reload
			if instant_reload:
				finish_reload()
			else:
				play_anim_pair(anims_reload)
				play_audio(audio_reload)
				reloading_timer.start()

func finish_reload():
	get_parent()._on_AnyGun_Reloaded()

func reassing_ammo():
	if $"/root/Player".check(ammo_type) >= magazine_size:
		current_magazine = magazine_size
	else:
		current_magazine = $"/root/Player".check(ammo_type)

func show():
	self.visible = true
	play_anim_pair(anims_idle)
	if instant_reload:
		reassing_ammo()
	elif current_magazine == 0:
		reload()

func are_all_timers_stopped():
	return firing_timer.is_stopped() and reloading_timer.is_stopped()

func interrupt_reload():
	play_anim_pair(anims_idle)
	reloading_timer.stop()

func can_switch():
	return are_all_timers_stopped()

func play_gun_anim(var anim_name: String):
	if anim_name != "":
		anim_player.stop()
		anim_player.play(anim_name)
	else:
		print("Gun animation not provided")

func play_hands_anim(var anim_name: String):
	if anim_name != "":
		anim_player_hands.play(anim_name)
	else:
		print("Hands animation not provided")

func play_anim_pair(var anim_pair: Array):
	if not anim_player:
		print("Missing AnimationPlayer for gun")
		return

	play_gun_anim(anim_pair[0])

	if not anim_player_hands:
		print("Missing AnimationPlayer for hands")
		return

	play_hands_anim(anim_pair[1])

func deal_damage_to_body(var body):
	if body.has_method("deal_damage"):
		body.deal_damage(bullet_damage, bullet_push_force, get_global_transform().origin, find_parent("Player*"))
		$"/root/Player".give("s_damage_dealt", bullet_damage)
		return true

func spawn_hit_effect(var body, var ray_dict):
	var type_node = body.get_node_or_null("SurfaceHitEffectType")
	var new_effect
	if type_node:
		if Effects.SURFACE_EFFECTS.has(type_node.effect):
			new_effect = load(Effects.SURFACE_EFFECTS[type_node.effect]).instance()		# resource should be loaded in objects cache already
		else:
			print("Warning: Incorrect surface effect: ", type_node.effect)
			new_effect = load(Effects.SURFACE_EFFECTS[0]).instance()
	else:
		new_effect = load(Effects.SURFACE_EFFECTS[0]).instance()

	get_tree().get_root().add_child(new_effect)
	new_effect.translation = ray_dict["position"]
	new_effect.look_at(get_global_transform().origin, Vector3.UP)

func deal_damage_by_ray(var ray_dict : Dictionary):
	if not ray_dict.empty():
		var body = ray_dict["collider"]

		deal_damage_to_body(body)
		spawn_hit_effect(body, ray_dict)
		return true
	return false

func construct_ray(var max_offset: float):
	var camera = get_viewport().get_camera()
	var midpoint = OS.window_size * 0.5
	var final_max_offset = OS.window_size * Vector2(rng.randf_range(-max_offset, max_offset), rng.randf_range(-max_offset, max_offset))
	var ray_origin = midpoint + final_max_offset

	var from = camera.project_ray_origin(ray_origin)
	var to = from + camera.project_ray_normal(ray_origin) * 1000

	return get_world().direct_space_state.intersect_ray(from, to, [], 0x7FFFFFFF - 128)
