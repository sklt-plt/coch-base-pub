extends Area
class_name MeleeArea

func is_attacking():
	return $"../AI".current_state == EnemyAI.States.ATTACK_MELEE

func get_direct_damage():
	return $"../AI".direct_damage
