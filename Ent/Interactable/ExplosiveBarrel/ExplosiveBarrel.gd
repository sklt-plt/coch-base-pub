extends RigidBody
class_name ExplosiveBarrel

var exploded = false

func _enter_tree():
	mode = RigidBody.MODE_STATIC

func disable_collisions():
	var children = get_children()
	for c in children:
		if c is CollisionShape:
			c.disabled = true

func deal_damage(var amount, var push_force, var from_dir, var _from_ent):
	if is_zero_approx(amount):
		# basically kick
		apply_central_impulse((self.global_translation-from_dir).normalized() * push_force*20)
	elif not exploded:
		exploded = true
		self.mode = MODE_STATIC
		disable_collisions()
		$Model.visible = false
		$AudioStreamPlayer3D.play()
		$Explosive.explode()
