extends Area

var attackers = []

func _physics_process(_delta):
	for a in attackers:
		if a.is_attacking():
			get_parent().deal_damage(a.get_direct_damage(), a.get_direct_damage(), a.global_transform.origin, a)

func _on_MeleeDetector_area_entered(area):
	if area is MeleeArea and not attackers.has(area):
		attackers.push_back(area)

func _on_MeleeDetector_area_exited(area):
	if attackers.has(area):
		attackers.erase(area)
