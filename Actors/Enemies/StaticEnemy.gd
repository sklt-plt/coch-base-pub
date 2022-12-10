extends StaticBody
class_name StaticEnemy

enum States {
	DEAD,				# 0  # not processing
	IDLE,				# 1  # not processing
	DYING,				# 2
	AWAKE,				# 3
	ATTACK_MELEE,		# 7
	ATTACK_BEGIN,		# 8
	ATTACK_END,			# 9
	BOOMERANG_WAIT,		# 10
	BOOMERANG_CATCH		# 11
}

var ANIM_IDLE = "" # override these
var ANIM_DIE = ""
var ANIM_ATTACK_MELEE = ""
var ANIM_ATTACK_END = ""
var ANIM_ATTACK_BEGIN = ""
var ANIM_ATTACK_HOLD = ""
var ANIM_EXTRA = ""

export (float) var health = 50.0                 # how much damage enemy can take

export (bool) var uses_melee_attack              # allows performing melee attack (requires "melee" animation state machine node)
export (float) var direct_damage = 5.0            # how much damage to deal in MeleeArea (def 5)
export (float) var distance_to_melee = 10.0      # distance to player to perform melee (def 10.0)
export (float) var distance_to_melee_hit = 5.0   # distance to player to perform melee (def 10.0)

export (float) var targeting_height_offset          # how high above player cords to aim projectile (def 0.25)
export (float) var missile_spawn_z_offset           # how far ahead from spawner to spawn missile (def 2.0)
var missile_spawn_cords
export (PackedScene) var projectile              # if set, will try to perform ranged attack with this projectile scene

export (bool) var uses_raycast_attack            # unused yet
export (bool) var allow_attack_cancelling = false  # shoult attack telegraph be stopped if player leaves los

export (float) var los_check_player_height = 2.5      # height offset for line-of-sight cheking
export (Vector3) var los_check_self_offset = Vector3(0, 2.5, 0)

export (Array, AudioStream) var audio_callouts
export (AudioStream) var audio_death
export (AudioStream) var audio_attack

export (PackedScene) var gib_effect

export (bool) var is_dynamic = false				#allow de-spawning after death
export (bool) var DEBUG_set_awake = false

export (Dictionary) var kill_immediate_resources = {
	"s_leveled_score" : 100,
	"r_time_freeze" : 1.0,
	"s_kills" : 1
}

export (Dictionary) var player_resource_costs = {
	"r_health": 2,
	"r_armor" : 2,
	"r_pistol_ammo" : 2,
	"r_shotgun_ammo": 2,
	"r_crossbow_ammo": 2
}

export (float) var dynamic_self_poison = 2.0

var anim_player : AnimationPlayer
var current_state = States.IDLE
var last_player_pos
var visible_player = false
var last_simuated_pos

var audio_stream_player

var ranged_attack_freq_timer : Timer
var ranged_attack_tele_timer : Timer
var audio_callouts_timer : Timer

const MAX_LOS_DISTANCE = 60

func _ready():
	anim_player = $Model/AnimationPlayer
	audio_stream_player = $AudioStreamPlayer3D

	ranged_attack_freq_timer = $RangedAttackFrequency
	ranged_attack_tele_timer = $RangedAttackTelegraph
	audio_callouts_timer = $AudioCalloutsTimer

	if projectile:
		missile_spawn_cords = get_node("MissileSpawnCords")

	if not audio_callouts.empty():
		$AudioCalloutsTimer.wait_time = audio_callouts[0].get_length() + 2.0 + rand_range(-0.75, 0.75)

	set_awake(DEBUG_set_awake)

	if not is_dynamic:
		$"/root/Player".give("s_kills_possible", 1)
		audio_stream_player.stream_paused = true
		$CollisionShape.disabled = true
		set_physics_process(false)
		self.visible = false
		$"/root/AIManager".register_ai(self)

func _physics_process(delta):
	if is_dynamic:
		_managed_process(delta)
		health -= dynamic_self_poison * delta

func _managed_process(var delta):
	check_line_of_sight()

	update_current_state()

	process_current_state(delta)

func update_current_state():
	if health <= 0:
		begin_state(States.DYING)

	if current_state == States.AWAKE:
		if (visible_player and uses_melee_attack
			and is_player_in_range(distance_to_melee)):
				ranged_attack_freq_timer.stop()
				begin_state(States.ATTACK_MELEE)
		elif (visible_player and (not is_player_in_range(distance_to_melee)
			or not uses_melee_attack)):

			if (projectile or uses_raycast_attack) and ranged_attack_freq_timer.is_stopped():
				ranged_attack_freq_timer.start()
			begin_state(States.AWAKE)

		else:
			ranged_attack_freq_timer.stop()
			play_animation(ANIM_IDLE)
			begin_state(States.AWAKE)

func process_current_state(var delta):
	match current_state:
		States.DYING:
			begin_state(States.DEAD)

		States.ATTACK_MELEE:
			if anim_player.current_animation != ANIM_ATTACK_MELEE: # ughhhhh
				begin_state(States.AWAKE)
				return

			# player should detect collision themselves

			if not is_at_target(last_player_pos):
				face_target(last_player_pos)

		States.ATTACK_BEGIN:
			if !visible_player and allow_attack_cancelling:
				ranged_attack_tele_timer.stop()
				begin_state(States.AWAKE)

			face_target(last_player_pos)

		States.BOOMERANG_CATCH:
			if anim_player.current_animation != ANIM_EXTRA:
				if not audio_callouts.empty():
					audio_callouts_timer.start()
				begin_state(States.AWAKE)

		States.ATTACK_END:
			if anim_player.current_animation != ANIM_ATTACK_END:
				if projectile and projectile.instance() is Boomerang:
					begin_state(States.BOOMERANG_WAIT)
				else:
					if not audio_callouts.empty():
						audio_callouts_timer.start()
					begin_state(States.AWAKE)


func begin_state(var desired_state):
	if desired_state != current_state:
		match desired_state:
			States.DEAD:
				current_state = States.DEAD
				$CollisionShape.disabled = true
				set_physics_process(false)
			States.DYING:
				current_state = States.DYING

				ranged_attack_tele_timer.stop()
				ranged_attack_freq_timer.stop()
				audio_callouts_timer.stop()
				if ANIM_DIE != "":
					play_animation(ANIM_DIE)
				elif gib_effect:
					get_node("Model").visible = false
					self.add_child(gib_effect.instance())
					begin_state(States.DEAD)

				play_audio(audio_death)

				if (is_dynamic):
					yield(get_tree().create_timer(3.0, false), "timeout")
					queue_free()
				else:
					#don't give score for respawning enemies
					for r in kill_immediate_resources:
						$"/root/Player".give(r, kill_immediate_resources[r])

			States.AWAKE:
				self.visible = true
				play_animation(ANIM_IDLE)
				$CollisionShape.disabled = false
				set_physics_process(true)
				if not last_simuated_pos:
					last_simuated_pos = translation
				audio_stream_player.stream_paused = false
				if not audio_callouts.empty():
					audio_callouts_timer.start()
				current_state = States.AWAKE
			States.ATTACK_MELEE:
				play_audio(audio_attack)
				play_animation(ANIM_ATTACK_MELEE)
				current_state = States.ATTACK_MELEE
			States.ATTACK_BEGIN:
				audio_callouts_timer.stop()
				play_audio(audio_attack)
				play_animation(ANIM_ATTACK_BEGIN)
				ranged_attack_freq_timer.stop()
				ranged_attack_tele_timer.start()
				current_state = States.ATTACK_BEGIN
			States.ATTACK_END:
				play_animation(ANIM_ATTACK_END)
				current_state = States.ATTACK_END
			States.BOOMERANG_WAIT:
				play_animation(ANIM_ATTACK_HOLD)
				current_state = States.BOOMERANG_WAIT
			States.BOOMERANG_CATCH:
				play_animation(ANIM_EXTRA)
				current_state = States.BOOMERANG_CATCH
			States.IDLE:
				self.visible = false
				set_physics_process(false)
				$CollisionShape.disabled = true
				teleport_to_spawn()
				audio_callouts_timer.stop()
				ranged_attack_freq_timer.stop()
				audio_stream_player.stream_paused = true
				current_state = States.IDLE
			_:
				print("Unknown state: ", desired_state)

func teleport_to_spawn():
	if last_simuated_pos:
		translation = last_simuated_pos
		last_simuated_pos = null

func face_target(var target):
	if target:
		var new_target = Vector3()
		new_target = target
		new_target.y = self.get_global_transform().origin.y

		look_at(new_target, Vector3.UP)

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	if is_physics_processing() and current_state == States.AWAKE:
		if from_ent and not visible_player:
			visible_player = true
		begin_state(States.AWAKE)

	health -= damage

func is_at_target(var target: Vector3):
	return is_in_range(target, 1.0)

func is_in_range(var target: Vector3, var distance):
	var to_target = Vector3(target.x, get_global_transform().origin.y, target.z) - get_global_transform().origin
	return (to_target.length() < distance)

func is_player_in_range(var distance):
	var target_pos = $"/root/Player".get_global_transform().origin
	return is_in_range(target_pos, distance)

func set_awake(var to_awake):
	if current_state != States.DEAD:
		if to_awake and current_state == States.IDLE:
			begin_state(States.AWAKE)
		elif not to_awake:
			begin_state(States.IDLE)

func check_line_of_sight():
	if current_state >= States.AWAKE:
		var player_node = $"/root/Player"

		#do a raycast
		var space_state = get_world().direct_space_state
		var origin = get_global_transform().origin
		origin += los_check_self_offset
		var target
		if player_node.is_crawling():
			target = player_node.get_global_transform().origin + Vector3(0, los_check_player_height - 1, 0)
		else:
			target = player_node.get_global_transform().origin + Vector3(0, los_check_player_height, 0)

		var ray_result = space_state.intersect_ray(origin, target, [self, get_parent()], collision_mask)
		if ray_result and ray_result.collider == player_node and self.global_translation.distance_to(player_node.global_translation) < MAX_LOS_DISTANCE:
			if not player_node.is_dead():
				visible_player = true

			elif player_node.is_dead():
				visible_player = false

		else:
			visible_player = false

	if visible_player:
		last_player_pos = $"/root/Player".get_global_transform().origin

func _on_RangedAttackFrequency_timeout():
	if current_state >= States.AWAKE:
		begin_state(States.ATTACK_BEGIN)

func _on_RangedAttackTelegraph_timeout():
	if current_state == States.ATTACK_BEGIN:
		if projectile:
			var pos = missile_spawn_cords.get_global_transform().translated(
				Vector3(0,0,-missile_spawn_z_offset)).origin

			var p = ProjectileSpawnHelper.spawn_projectile(projectile, get_parent(), pos,
				last_player_pos + Vector3(0.0, targeting_height_offset, 0.0))

			if p is Boomerang:
				if $"/root/Player".is_crawling():
					p.translation.y -= 0.5
				p.look_at(Vector3(last_player_pos.x, p.get_global_transform().origin.y, last_player_pos.z), Vector3.UP)
				p.target = Vector3(last_player_pos + Vector3(0.0, targeting_height_offset, 0.0))
				p.boomerang_owner = self

		elif uses_raycast_attack:
			var player = $"/root/Player"
			player.deal_damage(direct_damage, direct_damage, self.global_translation, self)

		begin_state(States.ATTACK_END)


func _on_returned_boomerang():
	if current_state != States.DEAD:
		begin_state(States.BOOMERANG_CATCH)

func play_animation(var animation_name: String):
	if animation_name != "":
		anim_player.play(animation_name)
		if anim_player.current_animation != animation_name:
			print("Error playing: ", animation_name)

func play_audio(var audio : AudioStream):
	if current_state != States.IDLE:
		audio_stream_player.stream = audio
		audio_stream_player.play()

func _on_AudioCalloutsTimer_timeout():
	#play random callout
	if not audio_callouts.empty() and not audio_stream_player.playing:
		play_audio(audio_callouts[randi()%audio_callouts.size()])
