extends BaseProjectile
class_name ExplosiveProjectile

func hit_target(var _col):
	detonate_explosive(null)

func detonate_explosive(var collider):
	var explosive = get_node_or_null("Explosive")
	if explosive:
		explosive.explode([self, collider])
	else:
		print("WRN: ExplosiveProjectile ", name, "doesn't have Explosive node")
	queue_free()

func deal_damage(var _amount, var _push_force, var _direction, var _from_node):
	detonate_explosive(null)

func _on_DecayTimer_timeout():
	detonate_explosive(null)
