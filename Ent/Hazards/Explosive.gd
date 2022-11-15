extends Area
class_name Explosive

export (float) var expl_damage = 10.0

export (PackedScene) var effect

func explode(var to_ignore : Array = []):
	#add effect
	if not self.is_inside_tree():
		return

	if effect != null:
		var n_effect = effect.instance()
		get_tree().current_scene.add_child(n_effect)
		n_effect.global_translation = self.global_translation

	#deal damage directly if possible
	var ent = get_parent()
	if ent.has_method("deal_damage"):
		ent.deal_damage(expl_damage, 0, ent.global_translation, null)

	#deal damage indirectly in radius
	var in_blast = get_overlapping_bodies()

	#get physics space_state for raycasting
	var space_state = get_world().direct_space_state

	for body in in_blast:
		#check direct line of sight except for to_ignore (directly hit & missile parent)
		to_ignore.append(self)
		to_ignore.append(get_parent())
		var result = space_state.intersect_ray(get_global_transform().origin, body.get_global_transform().origin, to_ignore, collision_mask)

		if result and result.collider == body:
			#how much of a fraction of damage to give to body
			var my_global_t = get_global_transform().origin
			var distance_to = my_global_t.distance_to(result.position)
			var mul
			mul = 1/($BlastRadius.shape.radius + (distance_to - $BlastRadius.shape.radius))  # linear faloff
			var final_dmg = expl_damage*mul

			if body.has_method("deal_damage"):
				body.deal_damage(final_dmg, final_dmg*2, get_global_transform().origin , null)#/2, get_global_transform().origin , null)
				$"/root/Player".give("s_damage_dealt", expl_damage*mul)

	#remove explosive
	self.queue_free()

func deal_damage(var _amount, var _push_force, var _from_dir, var _from_node):
	explode([])

func _on_Timer_timeout():
	explode([])
