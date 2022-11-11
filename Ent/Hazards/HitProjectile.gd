extends BaseProjectile
class_name HitProjectile

export var projectile_damage = 20.0
export var projectile_push_force = 20.0

func hit_target(var col):
	if col.collider.has_method("deal_damage"):
		col.collider.deal_damage(projectile_damage, projectile_push_force, .get_global_transform().origin , null)

	queue_free()

func deal_damage(var _amount, var _push_force, var _direction, var _from_node):
	queue_free()

func _on_DecayTimer_timeout():
	queue_free()
