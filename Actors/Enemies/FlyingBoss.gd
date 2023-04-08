extends Spatial

enum States {
	Idle,
	Begin,
	Awake,
	Rising_With_Snipers,
	Following_With_Snipers,
	Stagger,
	Retreating_For_Bombs,
	Rising_With_Bombs,
	Bombing_Prep,
	Bombing,
	Retreating_For_Two_Snipers,
	Rising_With_Two_Snipers,
	Following_With_Two_Snipers
}

var health = STARTING_HEALTH
var last_health
var current_state = States.Idle
var retreat_xz
var bombing_direction
var bombing_destination
var model_node

const STARTING_HEALTH = 50.0

const MOVEMENT_SPEED = 25
const RETREATING_SPEED = 50
const RISING_SPEED = 25
const BOMBING_SPEED = 32

const FLOAT_HEIGHT = 25
const DISTANCE_TO_KEEP = 30
const DISTANCE_TO_HIDE = 8
const HIDE_OFFSET = 100
const LOS_OFFSET = Vector3(0, 2.65, 0)

func _physics_process(delta):
	match current_state:
		States.Idle:
			return;

		States.Begin:
			begin_state(States.Rising_With_Snipers)

		States.Stagger:
			if $AnimationPlayer.current_animation != "Stagger":
				#decide next phase
				if health < STARTING_HEALTH * 0.33:
					begin_state(States.Retreating_For_Two_Snipers)
				elif health < STARTING_HEALTH * 0.7:
					begin_state(States.Retreating_For_Bombs)

		States.Rising_With_Snipers:
			if self.global_translation.y < $"/root/Player".global_translation.y + FLOAT_HEIGHT:
				self.translate(Vector3(0, RISING_SPEED, 0) * delta)
			else:
				begin_state(States.Following_With_Snipers)

		States.Following_With_Snipers:
			follow_with_snipers(delta)

		States.Retreating_For_Bombs:
			model_node.look_at(retreat_xz, Vector3.UP)

			if self.global_translation.distance_to(retreat_xz) > DISTANCE_TO_HIDE:
				move_to_target(retreat_xz, self.global_translation, delta, RETREATING_SPEED)

			else:
				begin_state(States.Rising_With_Bombs)

		States.Rising_With_Bombs:
			if self.global_translation.y < $"/root/Player".global_translation.y + FLOAT_HEIGHT:
				self.translate(Vector3(0, RISING_SPEED, 0) * delta)
			else:
				begin_state(States.Bombing_Prep)

		States.Bombing_Prep:
			var my_xz_translation = find_own_xz_translation()
			var target_xz = find_player_xz_translation()
			model_node.look_at(target_xz, Vector3.UP)

			if my_xz_translation.distance_to(target_xz) > DISTANCE_TO_KEEP:
				move_to_target(target_xz, my_xz_translation, delta, MOVEMENT_SPEED)

			else:
				begin_state(States.Bombing)

		States.Bombing:
			model_node.look_at(bombing_destination, Vector3.UP)

			if self.global_translation.distance_to(bombing_destination) > 1.0:
				self.translate(bombing_direction * delta * BOMBING_SPEED)
			else:
				begin_state(States.Bombing_Prep)

		States.Retreating_For_Two_Snipers:
			model_node.look_at(retreat_xz, Vector3.UP)

			if self.global_translation.distance_to(retreat_xz) > DISTANCE_TO_HIDE:
				move_to_target(retreat_xz, self.global_translation, delta, RETREATING_SPEED)

			else:
				begin_state(States.Rising_With_Two_Snipers)

		States.Rising_With_Two_Snipers:
			if self.global_translation.y < $"/root/Player".global_translation.y + FLOAT_HEIGHT:
				self.translate(Vector3(0, RISING_SPEED, 0) * delta)
			else:
				begin_state(States.Following_With_Two_Snipers)

		States.Following_With_Two_Snipers:
			follow_with_snipers(delta)

func begin_state(var state):
	match state:
		States.Begin:
			$"/root/Player/HUD".register_boss_health(self, "Boss Bat")
			$"/root/Player".give("s_kills_possible", 1)
			$"%SniperBoner".set_awake(true)
			set_retreat_xz()
			model_node = $Skeleton
			last_health = health

		States.Stagger:
			$AnimationPlayer.play("Stagger")

		States.Bombing:
			bombing_direction = (find_player_xz_translation() - find_own_xz_translation())
			bombing_destination = (Vector3(self.global_translation.x, 0, self.global_translation.z) + bombing_direction * 2) + Vector3(0, FLOAT_HEIGHT, 0)
			bombing_direction = bombing_direction.normalized()

		States.Rising_With_Two_Snipers:
			$"%SniperBoner2".set_awake(true)
			$"%SniperBoner3".set_awake(true)

	current_state = state
	print("Current State: ",state)

func follow_with_snipers(var delta):
	var player_node = $"/root/Player"

	var my_xz_translation = find_own_xz_translation()
	var target_xz = find_player_xz_translation()
	model_node.look_at(target_xz, Vector3.UP)

	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(self.global_translation, player_node.global_translation + LOS_OFFSET, [self])

	# can we see player?
	# if so let's find spot we can see them from
	if !result or (result and result.collider != player_node):
		target_xz = find_visible_spot_above_player(space_state, player_node)
		if my_xz_translation.distance_to(target_xz) > 1.0:
			move_to_target(target_xz, my_xz_translation, delta, MOVEMENT_SPEED)
			#self.translate((target_xz - my_xz_translation).normalized() * MOVEMENT_SPEED * delta)

	# otherwise just chase
	elif my_xz_translation.distance_to(target_xz) > DISTANCE_TO_KEEP:
		move_to_target(target_xz, my_xz_translation, delta, MOVEMENT_SPEED)

func set_retreat_xz():
	retreat_xz = self.global_translation

func find_own_xz_translation():
	return Vector3(self.global_translation.x, FLOAT_HEIGHT, self.global_translation.z)

func find_player_xz_translation():
	return Vector3($"/root/Player".global_translation.x, FLOAT_HEIGHT, $"/root/Player".global_translation.z)

func move_to_target(var target_xz, var my_xz_translation, var delta, var speed):
	self.translate((target_xz - my_xz_translation).normalized() * speed * delta)

func find_visible_spot_above_player(var space_state, var player_node):
	var offset = Vector3(DISTANCE_TO_KEEP, FLOAT_HEIGHT, 0)
	for rot in range(0, 120):
		var test = player_node.global_translation + offset.rotated(Vector3.UP, deg2rad(rot * 3))
		var test_result = space_state.intersect_ray(test, player_node.global_translation + LOS_OFFSET, [self])
		if test_result and test_result.collider == player_node:
			return Vector3(test.x, FLOAT_HEIGHT, test.z)

	return Vector3(player_node.global_translation.x, FLOAT_HEIGHT, player_node.global_translation.z)

func _on_BossBat_tree_exiting():
	$"/root/Player/HUD".deregister_boss_health()

func _on_HurtboxSkeleton_deal_damage(damage, _push_force, _from_direction, _from_ent):
	self.health -= damage

	if last_health > STARTING_HEALTH * 0.7 and health < STARTING_HEALTH * 0.7:
		$"%SniperBoner/AI".health = 0
		begin_state(States.Stagger)

	if last_health > STARTING_HEALTH * 0.33 and health < STARTING_HEALTH * 0.33:
		begin_state(States.Stagger)

	if health < 0.0:
		begin_state(States.Stagger)
		$"%SniperBoner2/AI".health = 0
		$"%SniperBoner3/AI".health = 0

	last_health = health
