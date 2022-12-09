extends RigidBody
class_name RBLaunchEffect

var effect_coroutine

func launch(var rng: RandomNumberGenerator, var max_offset: float, var max_force: float):
	self.mode = RigidBody.MODE_RIGID
	self.apply_impulse(Vector3.ZERO+Vector3(rng.randf_range(-max_offset, max_offset), rng.randf_range(-max_offset, max_offset), rng.randf_range(-max_offset, max_offset)),
		Vector3.UP+Vector3(rng.randf_range(-max_force, max_force), rng.randf_range(-max_force, max_force), rng.randf_range(-max_force, max_force)))

	#animate material
	effect_coroutine = dissapear()

	#animate model
	var anim_player = get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.play(anim_player.get_animation_list()[0])

func dissapear():
	var model = $model.get_child(0)
	var new_material = model.get("material/0").duplicate()
	model.material_override = new_material
	new_material.flags_transparent = true

	while(new_material.albedo_color.a > 0.001):
		new_material.albedo_color.a -= 0.01
		if not self.is_inside_tree():
			new_material.albedo_color.a = 0.0
			break
		yield(get_tree(), "idle_frame")

	self.mode = RigidBody.MODE_STATIC
	self.collision_layer = 0
	self.collision_mask = 0
