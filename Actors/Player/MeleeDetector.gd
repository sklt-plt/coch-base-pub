extends Area

const PUSH_FORCE_MUL = 3.75

var attackers = []
var iframe_timer : Timer

func _ready():
	iframe_timer = $IFrameTimer

func _physics_process(_delta):
	if not iframe_timer.is_stopped():
		return

	for a in attackers:
		if a.is_attacking():
			get_parent().deal_damage(a.get_direct_damage(), a.get_direct_damage()*PUSH_FORCE_MUL, a.global_transform.origin, a)
			iframe_timer.start()
			return

func _on_MeleeDetector_area_entered(area):
	if area is MeleeArea and not attackers.has(area):
		attackers.push_back(area)

func _on_MeleeDetector_area_exited(area):
	if attackers.has(area):
		attackers.erase(area)
