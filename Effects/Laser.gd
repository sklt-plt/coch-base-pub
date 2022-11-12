extends RayCast

export (Material) var miss_material
export (Material) var targeted_material

const PLAYER_HEIGHT_TARGETING_OFFSET = -0.5

var mesh_insts

func _ready():
	mesh_insts = get_children()
	self.translation = get_parent().los_check_self_offset
#	for mesh in mesh_insts:
#		mesh.mesh.size.y = MAX_LASER_DISTANCE
#		mesh.mesh.center_offset.z = -0.5 * MAX_LASER_DISTANCE

func _process(_delta):
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
	var targeting_offset = get_parent().los_check_player_height + PLAYER_HEIGHT_TARGETING_OFFSET
	self.look_at(targeting_point + Vector3(0, targeting_offset, 0), Vector3.UP)

	var distance = self.get_collision_point().distance_to(self.global_translation)
	for mesh in mesh_insts:
		mesh.mesh.size.y = distance
		mesh.mesh.center_offset.z = -0.5 * distance

	if visible_player:
		for mesh in mesh_insts:
			mesh.material_override = targeted_material
	else:
		for mesh in mesh_insts:
			mesh.material_override = miss_material

