extends StaticBody

func deal_damage(var _amount, var _push_force, var _direction, var source_node):
	if !$CollisionShape.disabled:
		$CollisionShape.disabled = true
		get_parent().activate()
