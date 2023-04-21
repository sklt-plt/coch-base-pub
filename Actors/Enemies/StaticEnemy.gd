extends StaticBody
class_name StaticEnemy

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	var ai_node = get_node_or_null("AI")
	if ai_node:
		ai_node.deal_damage(damage, push_force, from_direction, from_ent)

func set_awake(var to_awake):
	$AI.set_awake(to_awake)

func get_player_resource_costs():
	return $PlayerResourceCosts.player_resource_costs

func get_current_move_vector():
	return Vector3.ZERO

func get_current_state():
	return $AI.current_state

func get_direct_damage():
	return $AI.direct_damage

func set_dynamic(var value: bool):
	$AI.is_dynamic = value

func get_dynamic():
	return $AI.is_dynamic

func teleport_to_spawn():
	$AI.teleport_to_spawn()
