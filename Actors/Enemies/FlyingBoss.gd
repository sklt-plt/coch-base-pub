extends Spatial

enum States {
	Idle
	Rising,
	Following
}

var health = 50

var current_state = States.Idle

const MOVEMENT_SPEED = 15
const FLOAT_HEIGHT = 65

func _physics_process(delta):
	match current_state:
		States.Idle:
			return;

		States.Rising:
			if self.global_translation.y < $"/root/Player".global_translation.y + FLOAT_HEIGHT:
				self.translate(Vector3(0, MOVEMENT_SPEED, 0) * delta)
			else:
				current_state = States.Following

func begin_state(var state):
	match state:
		States.Rising:
			$"/root/Player/HUD".register_boss_health(self, "Boss Bat")
			$"/root/Player".give("s_kills_possible", 1)
			$SniperBoner.set_awake(true)
			$SniperBoner2.set_awake(true)

	current_state = state

func _on_BossBat_tree_exiting():
	$"/root/Player/HUD".deregister_boss_health()
