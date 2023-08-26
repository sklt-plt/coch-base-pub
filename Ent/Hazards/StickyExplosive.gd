extends ExplosiveProjectile

export var hit_damage = 10.0
export var push_force = 10.0

func hit_target(var col : KinematicCollision):
	if (col.collider is HitProjectile):
		$Explosive.explode()
		queue_free()
		return

	if col.collider.has_method("deal_damage") and not col.collider is ExplosiveBarrel:
		col.collider.deal_damage(hit_damage, push_force, self.global_translation, null)

	var explosive = $Explosive

	var expl_tr= explosive.global_transform
	self.remove_child(explosive)
	col.collider.add_child(explosive)
	explosive.owner = col.collider.owner
	explosive.get_node("Timer").start()
	explosive.global_transform = expl_tr
	explosive.get_node("OmniLight/AnimationPlayer").play("blink")

	self.queue_free()

func detonate_explosive(var _collider):
	queue_free()
