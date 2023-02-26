extends Spatial

enum States {
	Idle,
	Begin,
	Awake,
	Rising_With_Snipers,
	Following_With_Snipers,
	Stagger,
	Retreating_For_Bombs
}

const STARTING_HEALTH = 50.0
var health = STARTING_HEALTH

var current_state = States.Idle

const MOVEMENT_SPEED = 10
const RISING_SPEED = 17
const FLOAT_HEIGHT = 50
const DISTANCE_TO_KEEP = 45

func _physics_process(delta):
	match current_state:
		States.Idle:
			return;

		States.Begin:
			begin_state(States.Awake)

		States.Awake:
			#decide what to do
			if health < STARTING_HEALTH * 0.7:
				begin_state(States.Retreating_For_Bombs)
			elif is_equal_approx(health, STARTING_HEALTH):
				begin_state(States.Rising_With_Snipers)

		States.Stagger:
			if $AnimationPlayer.current_animation != "Stagger":
				begin_state(States.Awake)

		States.Rising_With_Snipers:
			if self.global_translation.y < $"/root/Player".global_translation.y + FLOAT_HEIGHT:
				self.translate(Vector3(0, RISING_SPEED, 0) * delta)
			else:
				begin_state(States.Following_With_Snipers)

		States.Following_With_Snipers:
			var my_xz_translation = Vector3(self.global_translation.x, 0, self.global_translation.z)
			var player_xz_translation = Vector3($"/root/Player".global_translation.x, 0, $"/root/Player".global_translation.z)

			if my_xz_translation.distance_to(player_xz_translation) > DISTANCE_TO_KEEP:
				self.translate((player_xz_translation - my_xz_translation).normalized() * MOVEMENT_SPEED * delta)
			elif my_xz_translation.distance_to(player_xz_translation) < DISTANCE_TO_KEEP:
				self.translate((my_xz_translation - player_xz_translation).normalized() * MOVEMENT_SPEED * delta)

			if self.health < STARTING_HEALTH * 0.7:
				begin_state(States.Stagger)
				$"%SniperBoner/AI".health = 0
				$"%SniperBoner2/AI".health = 0


func begin_state(var state):
	match state:
		States.Begin:
			$"/root/Player/HUD".register_boss_health(self, "Boss Bat")
			$"/root/Player".give("s_kills_possible", 1)
			$"%SniperBoner".set_awake(true)
			$"%SniperBoner2".set_awake(true)

		States.Stagger:
			$AnimationPlayer.play("Stagger")

		States.Retreating_For_Bombs:
			print("aa")

	current_state = state

func _on_BossBat_tree_exiting():
	$"/root/Player/HUD".deregister_boss_health()

func _on_HurtboxSkeleton_deal_damage(damage, push_force, from_direction, from_ent):
	self.health -= damage
