#    Copyright (C) 2024 Jakub Miksa
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This prograsm is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

extends Node
class_name EnemyAI

enum AwakeMovementStates {
	IDLE,
	MOVE_RANDOM
}
enum CombatMovementStates {
	IDLE,
	MOVE_CHARGE,
	MOVE_RANDOM
}

enum States {
	DEAD,				# 0  # not processing
	IDLE,				# 1  # not processing
	DYING,				# 2
	AWAKE,				# 3
	MOVE_CHARGE,		# 4
	MOVE_CHASE,			# 5
	MOVE_RANDOM,		# 6
	ATTACK_MELEE,		# 7
	ATTACK_MELEE_BEGIN,	# 8
	ATTACK_MELEE_END,	# 9
	ATTACK_BEGIN,		# 10
	ATTACK_END,			# 11
	BOOMERANG_WAIT,		# 12
	BOOMERANG_CATCH		# 13
}

##############################################################
## SETTINGS:

# animation names, override
var ANIM_IDLE = ""
var ANIM_MOVE = ""
var ANIM_DIE = ""
var ANIM_ATTACK_MELEE = []
var ANIM_ATTACK_MELEE_BEGIN = ""
var ANIM_ATTACK_MELEE_END = ""
var ANIM_ATTACK_END = ""
var ANIM_ATTACK_BEGIN = ""
var ANIM_ATTACK_HOLD = ""
var ANIM_EXTRA = ""

var health = 50.0						# how much damage enemy can take

var movement_speed = 8.0				# how fast it should move when engaging player
var movement_speed_wandering = 4.0		# how fast to move when not engaging player
var wander_single_time = 5.0			# for how long (seconds) to move in random direction when wandering / searching
										# also applies to chasing

var awake_movement = AwakeMovementStates.IDLE		# which movement to use when ai is awake but doesn't see the player
var combat_movement = CombatMovementStates.IDLE		# which movement to use when ai sees the player

var allow_chasing = false				# should ai go towards last player's position when loses direct line of sight
										# broken, if not going directly at player when it kicks in (?)

var uses_melee_attack = false			# allows performing melee attack (requires "melee" animation state machine node)
var direct_damage = 5.0					# how much damage to deal in MeleeArea (def 5)
var distance_to_melee = 10.0			# distance to player to go to melee state (def 10.0)

var targeting_height_offset = 0.25		# how high above player cords to aim projectile (def 0.25)
var missile_spawn_z_offset = 2.0		# how far ahead from spawner to spawn missile (def 2.0)
var missile_spawn_cords: Spatial		# where to spawn missile
var projectile: PackedScene				# if set, will try to perform ranged attack with this projectile scene

var uses_raycast_attack = false			# can use raycast attack?
var allow_attack_cancelling = false		# shoult attack telegraph be stopped if player leaves los

var los_check_player_height = 2.5      				# how high to offset line-of-sight TO
var los_check_self_offset = Vector3(0, 2.5, 0)		# where to cast line-of-sight FROM

var audio_callouts = []					# random audio 'grunts'
var audio_death: AudioStream			# plays when die
var audio_attack_begin: AudioStream 	# plays when attacking begins

var gib_effect: PackedScene				# scene that holds gib effect

var is_dynamic = false					#allow de-spawning after death
var disable_face_target = false			#look_at player when attacking
var DEBUG_set_awake = false

var kill_immediate_resources = {		# resources to give() player after kill
	"s_leveled_score" : 100,
	"r_time_freeze" : 1.0,
	"s_kills" : 1
}

var dynamic_self_poison = 2.0				# how much damage take when awake and is dynamic

## END OF SETTINGS
#######################################################

var current_melee_anim
var current_wander_time = 0.0
var anim_player : AnimationPlayer
const wander_max_distance = 30.0
var wander_total_delta = 0.0
var current_state = States.IDLE
var last_player_pos
var visible_player = false
var last_simuated_pos
var current_move_vector = Vector3.ZERO

var audio_stream_player

var wander_timer : Timer
var ranged_attack_freq_timer : Timer
var ranged_attack_tele_timer : Timer
var audio_callouts_timer : Timer

const MAX_LOS_DISTANCE = 60

var parent_node

func _ready():
	parent_node = get_parent()
	anim_player = parent_node.get_node("Model/AnimationPlayer")
	audio_stream_player = parent_node.get_node("AudioStreamPlayer3D")

	if parent_node is KinematicEnemy:
		wander_timer = parent_node.get_node("WanderTimer")

	ranged_attack_freq_timer = parent_node.get_node("RangedAttackFrequency")
	ranged_attack_tele_timer = parent_node.get_node("RangedAttackTelegraph")
	audio_callouts_timer = parent_node.get_node("AudioCalloutsTimer")

	if projectile:
		missile_spawn_cords = parent_node.get_node("MissileSpawnCords")

	if not audio_callouts.empty():
		audio_callouts_timer.wait_time = audio_callouts[0].get_length() + 2.0 + rand_range(-0.75, 0.75)

	set_awake(DEBUG_set_awake)

	if not is_dynamic:
		if health != INF:
			$"/root/Player".give("s_kills_possible", 1)
		audio_stream_player.stream_paused = true
		if parent_node is KinematicEnemy:
			parent_node.simulate_movement = false

		parent_node.get_node("CollisionShape").disabled = true
		set_physics_process(false)
		parent_node.visible = false
		$"/root/AIManager".register_ai(self)

func _physics_process(delta):
	if is_dynamic:
		_managed_process(delta)
		health -= dynamic_self_poison * delta

	if parent_node is KinematicEnemy:
		parent_node.move_and_slide(current_move_vector, Vector3.ZERO, false, 4, 0.785398, false)
		parent_node._physics_process(delta)

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
				begin_state(States.ATTACK_MELEE_BEGIN)
		elif (visible_player and (not is_player_in_range(distance_to_melee)
			or not uses_melee_attack)):

			if (projectile or uses_raycast_attack) and ranged_attack_freq_timer.is_stopped():
				ranged_attack_freq_timer.start()
			begin_state(get_combat_movement())

		elif not visible_player and last_player_pos and allow_chasing:
			ranged_attack_freq_timer.stop()
			begin_state(States.MOVE_CHASE)
		else:
			ranged_attack_freq_timer.stop()
			if (awake_movement == AwakeMovementStates.IDLE):
				play_animation(ANIM_IDLE)
				current_move_vector = Vector3.ZERO
			begin_state(get_awake_movement())

func process_current_state(var delta):
	match current_state:
		States.DYING:
			if (parent_node is StaticEnemy or (parent_node is KinematicEnemy and parent_node.is_move_modif_neglible())):
				begin_state(States.DEAD)

		States.ATTACK_MELEE:
			if anim_player.current_animation != current_melee_anim: # ughhhhh
				if is_player_in_range(distance_to_melee):
					#continue melee attacks
					play_random_melee_anim()
				else:
					begin_state(States.ATTACK_MELEE_END)
				return

			# player should detect collision themselves

			if not is_at_target(last_player_pos):
				face_target(last_player_pos)

			if parent_node is KinematicEnemy:
				current_move_vector = parent_node.transform.basis.xform(Vector3(0,-1,-1))* movement_speed

		States.ATTACK_MELEE_BEGIN:
			if ANIM_ATTACK_MELEE_BEGIN == "" or anim_player.current_animation != ANIM_ATTACK_MELEE_BEGIN: # ughhhhh
				begin_state(States.ATTACK_MELEE)
				return

			if !visible_player and allow_attack_cancelling:
				begin_state(States.AWAKE)

			face_target(last_player_pos)

		States.ATTACK_BEGIN:
			if !visible_player and allow_attack_cancelling:
				ranged_attack_tele_timer.stop()
				begin_state(States.AWAKE)

			current_move_vector = Vector3.ZERO
			face_target(last_player_pos)

		States.MOVE_CHARGE:
			if visible_player and not is_player_in_range(distance_to_melee):
				face_target(last_player_pos)
				current_move_vector = parent_node.transform.basis.xform(Vector3(0,-1,-1))* movement_speed
			else:
				begin_state(States.AWAKE)
				current_move_vector = Vector3.ZERO

		States.MOVE_CHASE:
			if not visible_player and wander_total_delta < wander_single_time:
				wander_total_delta += delta
				current_move_vector = parent_node.transform.basis.xform(Vector3(0,-1,-1))* movement_speed
			else:
				visible_player = false
				begin_state(States.AWAKE)
				current_move_vector = Vector3.ZERO

		States.BOOMERANG_CATCH:
			current_move_vector = Vector3.ZERO
			if anim_player.current_animation != ANIM_EXTRA:
				if not audio_callouts.empty():
					audio_callouts_timer.start()
				begin_state(States.AWAKE)

		States.ATTACK_END:
			current_move_vector = Vector3.ZERO
			if anim_player.current_animation != ANIM_ATTACK_END:
				if projectile and projectile.instance() is Boomerang:
					begin_state(States.BOOMERANG_WAIT)
				else:
					if not audio_callouts.empty():
						audio_callouts_timer.start()
					begin_state(States.AWAKE)

		States.ATTACK_MELEE_END:
			if ANIM_ATTACK_MELEE_END == "" or anim_player.current_animation != ANIM_ATTACK_MELEE_END:
				if not audio_callouts.empty():
					audio_callouts_timer.start()
				begin_state(States.AWAKE)

		States.MOVE_RANDOM:
			if ((visible_player and combat_movement != CombatMovementStates.MOVE_RANDOM)
				or (!visible_player and last_player_pos and allow_chasing)):
				wander_timer.stop()
				begin_state(States.AWAKE)
				return

			current_move_vector = parent_node.transform.basis.xform(Vector3(0,-1,-1))* movement_speed_wandering

func begin_state(var desired_state):
	if desired_state != current_state:
		match desired_state:
			States.DEAD:
				current_state = States.DEAD
				if parent_node is KinematicEnemy:
					parent_node.simulate_movement = false
				set_physics_process(false)
				parent_node.set_physics_process(false)
				parent_node.get_node("CollisionShape").disabled = true
			States.DYING:
				current_state = States.DYING

				if parent_node is KinematicActor:
					parent_node.reduce_modifier_time = 1

				if wander_timer:
					wander_timer.stop()

				ranged_attack_tele_timer.stop()
				ranged_attack_freq_timer.stop()
				audio_callouts_timer.stop()
				if ANIM_DIE != "":
					play_animation(ANIM_DIE)
				elif gib_effect:
					parent_node.get_node("Model").visible = false
					var gib_instance = gib_effect.instance()
					gib_instance.global_transform = parent_node.global_transform
					gib_instance.scale = Vector3(2,2,2)  # map scale haxxs
					get_tree().current_scene.add_child(gib_instance)

					begin_state(States.DEAD)

				play_audio(audio_death)

				if (is_dynamic):
					yield(get_tree().create_timer(3.0, false), "timeout")
					queue_free()
				else:
					#don't give score for respawning enemies
					for r in kill_immediate_resources:
						$"/root/Player".give(r, kill_immediate_resources[r])

					$"/root/Player".give("r_progress", 1)

			States.AWAKE:
				parent_node.visible = true
				play_animation(ANIM_IDLE)
				parent_node.get_node("CollisionShape").disabled = false
				set_physics_process(true)
				if parent_node is KinematicEnemy:
					parent_node.simulate_movement = true
				if not last_simuated_pos:
					last_simuated_pos = parent_node.translation
				audio_stream_player.stream_paused = false
				if not audio_callouts.empty():
					audio_callouts_timer.start()
				current_state = States.AWAKE
			States.MOVE_CHASE:
				play_animation(ANIM_MOVE)
				reset_delta_search()
				face_target(last_player_pos)
				current_state = States.MOVE_CHASE
			States.MOVE_CHARGE:
				play_animation(ANIM_MOVE)
				current_state = States.MOVE_CHARGE
			States.ATTACK_MELEE:
				#play audio by animation
				play_random_melee_anim()
				current_state = States.ATTACK_MELEE
			States.ATTACK_BEGIN:
				audio_callouts_timer.stop()
				play_audio(audio_attack_begin)
				play_animation(ANIM_ATTACK_BEGIN)
				ranged_attack_freq_timer.stop()
				ranged_attack_tele_timer.start()
				current_state = States.ATTACK_BEGIN
			States.ATTACK_MELEE_BEGIN:
				play_audio(audio_attack_begin)
				audio_callouts_timer.stop()
				if ANIM_ATTACK_MELEE_BEGIN != "":
					play_animation(ANIM_ATTACK_MELEE_BEGIN)
				current_state = States.ATTACK_MELEE_BEGIN
			States.ATTACK_END:
				play_animation(ANIM_ATTACK_END)
				current_state = States.ATTACK_END
			States.ATTACK_MELEE_END:
				if ANIM_ATTACK_MELEE_END != "":
					play_animation(ANIM_ATTACK_MELEE_END)
				current_state = States.ATTACK_MELEE_END
			States.MOVE_RANDOM:
				play_animation(ANIM_MOVE)
				visible_player = false
				if wander_timer:
					wander_timer.start(rand_range(wander_single_time/2.0, wander_single_time))
				face_target(find_random_point_to_wander_to())
				current_state = States.MOVE_RANDOM
			States.BOOMERANG_WAIT:
				if wander_timer:
					wander_timer.stop()
				play_animation(ANIM_ATTACK_HOLD)
				current_state = States.BOOMERANG_WAIT
			States.BOOMERANG_CATCH:
				play_animation(ANIM_EXTRA)
				current_state = States.BOOMERANG_CATCH
			States.IDLE:
				parent_node.visible = false
				set_physics_process(false)
				parent_node.get_node("CollisionShape").disabled = true
				teleport_to_spawn()
				if parent_node is KinematicEnemy:
					parent_node.simulate_movement = false
					wander_timer.stop()
				audio_callouts_timer.stop()
				ranged_attack_freq_timer.stop()
				audio_stream_player.stream_paused = true
				current_state = States.IDLE
			_:
				print("Unknown state: ", desired_state)

func teleport_to_spawn():
	if last_simuated_pos:
		parent_node.translation = last_simuated_pos
		last_simuated_pos = null

func get_combat_movement():
	match combat_movement:
		CombatMovementStates.MOVE_CHARGE:
			return States.MOVE_CHARGE
		CombatMovementStates.MOVE_RANDOM:
			return States.MOVE_RANDOM
		CombatMovementStates.IDLE:
			return States.AWAKE

func get_awake_movement():
	match awake_movement:
		AwakeMovementStates.MOVE_RANDOM:
			return States.MOVE_RANDOM
		AwakeMovementStates.IDLE:
			return States.AWAKE

func face_target(var target):
	if disable_face_target:
		return
	if target:
		var new_target = Vector3()
		new_target = target
		new_target.y = parent_node.get_global_transform().origin.y

		if parent_node is KinematicEnemy:
			parent_node.look_at(new_target, Vector3.UP)
		elif parent_node is StaticEnemy:
			var head = get_node_or_null("../Model/Head")
			if head:
				head.look_at(new_target, Vector3.UP)

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	if .is_physics_processing() and current_state == States.AWAKE:
		if from_ent and not visible_player:
			visible_player = true
		begin_state(States.AWAKE)

	health -= damage * Globals.get_difficulty_field("player_firepower_scale")
	if parent_node is KinematicEnemy:
		parent_node.push_linear(from_direction, push_force)

func reset_delta_search():
	wander_total_delta = 0

func is_at_target(var target: Vector3):
	return is_in_range(target, 1.0)

func is_in_range(var target: Vector3, var distance):
	var to_target = Vector3(target.x, parent_node.get_global_transform().origin.y, target.z) - parent_node.get_global_transform().origin
	return (to_target.length() < distance)

func is_player_in_range(var distance):
	var target_pos = $"/root/Player".get_global_transform().origin
	return is_in_range(target_pos, distance)

func find_random_point_to_wander_to():
	var new_target = Vector3()
	new_target.x = parent_node.get_global_transform().origin.x + rand_range(-wander_max_distance, wander_max_distance)
	new_target.z = parent_node.get_global_transform().origin.z + rand_range(-wander_max_distance, wander_max_distance)
	return new_target

func set_awake(var to_awake):
	if current_state != States.DEAD:
		if to_awake and current_state == States.IDLE:
			begin_state(States.AWAKE)
		elif not to_awake:
			begin_state(States.IDLE)

func _on_WanderTimer_timeout():
	if current_state == States.MOVE_RANDOM:
		begin_state(States.AWAKE)

func check_line_of_sight():
	if current_state >= States.AWAKE:
		var player_node = $"/root/Player"

		#do a raycast
		var space_state = parent_node.get_world().direct_space_state
		var origin = parent_node.get_global_transform().origin
		origin += los_check_self_offset
		var target
		if player_node.is_crawling():
			target = player_node.get_global_transform().origin + Vector3(0, los_check_player_height - 1, 0)
		else:
			target = player_node.get_global_transform().origin + Vector3(0, los_check_player_height, 0)

		var ray_result = space_state.intersect_ray(origin, target, [parent_node, parent_node.get_parent()], parent_node.collision_mask)
		if ray_result and ray_result.collider == player_node and parent_node.global_translation.distance_to(player_node.global_translation) < MAX_LOS_DISTANCE:
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

			var p = ProjectileSpawnHelper.spawn_projectile(projectile, get_tree().current_scene, pos,
				last_player_pos + Vector3(0.0, targeting_height_offset, 0.0))

			if p is Boomerang:
				if $"/root/Player".is_crawling():
					p.translation.y -= 0.5
				p.look_at(Vector3(last_player_pos.x, p.get_global_transform().origin.y, last_player_pos.z), Vector3.UP)
				p.target = Vector3(last_player_pos + Vector3(0.0, targeting_height_offset, 0.0))
				p.boomerang_owner = self

		elif uses_raycast_attack:
			var player = $"/root/Player"
			player.deal_damage(direct_damage, direct_damage, parent_node.global_translation, parent_node)

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

func play_random_melee_anim():
	if not ANIM_ATTACK_MELEE.empty():
		var idx = randi()%ANIM_ATTACK_MELEE.size()
		current_melee_anim = ANIM_ATTACK_MELEE[idx]
		play_animation(current_melee_anim)

func _on_AudioCalloutsTimer_timeout():
	#play random callout
	if not audio_callouts.empty() and not audio_stream_player.playing:
		play_audio(audio_callouts[randi()%audio_callouts.size()])
