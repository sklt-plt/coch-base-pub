extends BaseGun

const MELEE_RAYCAST_HIT_DISTANCE = 2.9

func fire():
	if are_all_timers_stopped():
		if deal_damage_by_ray(construct_ray(current_inaccuracy)):
			play_gun_anim(anims_fire[0])
		else:
			play_gun_anim(anims_aim_fire[0])

		if audio_fire:
			play_audio(audio_fire)

		$"/root/Player".give("s_shots_fired", bullets_at_once)
		firing_timer.start()

func begin_aim():
	pass

func end_aim():
	pass

func deal_damage_to_body(var body):
	if body is ExplosiveBarrel:
		body.deal_damage(0, bullet_push_force, get_global_transform().origin, find_parent("Player*"))
	elif body.has_method("deal_damage"):
		body.deal_damage(bullet_damage, bullet_push_force, get_global_transform().origin, find_parent("Player*"))
		$"/root/Player".give("s_shots_hit", 1)
		$"/root/Player".give("s_damage_dealt", bullet_damage)

func construct_ray(var _max_offset: float):
	var result
	for i in range(0, 4):
		var camera = get_viewport().get_camera()
		var midpoint = OS.window_size * Vector2(0.5, 0.5 + 0.117 * i)
		var ray_origin = midpoint

		var from = camera.project_ray_origin(ray_origin)
		var to = from + camera.project_ray_normal(ray_origin) * MELEE_RAYCAST_HIT_DISTANCE

		result = get_world().direct_space_state.intersect_ray(from, to)
		if result:
			break

	return result
