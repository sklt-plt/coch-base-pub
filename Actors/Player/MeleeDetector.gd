extends Area

var attackers = []

func _physics_process(_delta):
	for a in attackers:
		get_parent().deal_damage(a.direct_damage, a.direct_damage, a.global_transform.origin, a)

func _on_MeleeDetector_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicEnemy and body.current_state == KinematicEnemy.States.ATTACK_MELEE and not attackers.has(body):
		attackers.push_back(body)

func _on_MeleeDetector_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if attackers.has(body):
		attackers.erase(body)
