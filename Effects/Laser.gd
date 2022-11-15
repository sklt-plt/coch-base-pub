extends RayCast

export (ShaderMaterial) var shader : ShaderMaterial;

const PLAYER_STANDING_TARGETING_OFFSET = 0.175
const PLAYER_CROUCHING_TARGETING_OFFSET = -0.9
const PLAYER_WIDTH = 0.95
const SHADER_TWEEN_SPEED = 0.7
var mesh_insts

func _ready():
	shader = shader.duplicate()

	mesh_insts = get_children()
	for mesh in mesh_insts:
		mesh.mesh = mesh.mesh.duplicate()
		mesh.material_override = shader

func _process(delta):
	if get_parent().current_state == KinematicEnemy.States.DEAD:
		self.set_process(false)
		self.visible = false
		return

	var visible_player = get_parent().visible_player
	var targeting_point = get_parent().last_player_pos if not get_parent().visible_player else $"/root/Player".global_translation
	var last_player_pos = get_parent().last_player_pos

	if !targeting_point:
		self.visible = false
		return

	self.visible = true
	var targeting_offset = get_parent().los_check_player_height + PLAYER_STANDING_TARGETING_OFFSET + (PLAYER_CROUCHING_TARGETING_OFFSET * float($"/root/Player".is_crawling()))
	self.look_at(targeting_point + Vector3(0, targeting_offset, 0), Vector3.UP)

	var distance = self.get_collision_point().distance_to(self.global_translation)
	for mesh in mesh_insts:
		if visible_player:
			distance += PLAYER_WIDTH

		mesh.mesh.size.y = distance
		mesh.mesh.center_offset.z = -0.5 * distance

	var tween = shader.get_shader_param("tween")

	if get_parent().current_state == KinematicEnemy.States.ATTACK_BEGIN:
		tween += delta * SHADER_TWEEN_SPEED
	else:
		tween = 0

	tween = clamp(tween, 0.0, 1.0)

	shader.set_shader_param("tween", tween)
