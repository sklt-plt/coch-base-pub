extends KinematicActor
class_name KinematicEnemy

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	$AI.deal_damage(damage, push_force, from_direction, from_ent)

func set_awake(var to_awake):
	$AI.set_awake(to_awake)

func get_player_resource_costs():
	return $AI.player_resource_costs

func get_current_move_vector():
	return $AI.current_move_vector

func get_current_state():
	return $AI.current_state

func get_direct_damage():
	return $AI.direct_damage
