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
	if $"../AI".current_state == EnemyAI.States.DEAD:
		self.set_process(false)
		self.visible = false
		return

	var visible_player = $"../AI".visible_player
	var targeting_point = $"../AI".last_player_pos if not $"../AI".visible_player else $"/root/Player".global_translation
	var last_player_pos = $"../AI".last_player_pos

	if !targeting_point:
		self.visible = false
		return

	self.visible = true
	var targeting_offset = $"../AI".los_check_player_height + PLAYER_STANDING_TARGETING_OFFSET + (PLAYER_CROUCHING_TARGETING_OFFSET * float($"/root/Player".is_crawling()))
	self.look_at(targeting_point + Vector3(0, targeting_offset, 0), Vector3.UP)

	var distance = self.get_collision_point().distance_to(self.global_translation)
	for mesh in mesh_insts:
		if visible_player:
			distance += PLAYER_WIDTH

		mesh.mesh.size.y = distance
		mesh.mesh.center_offset.z = -0.5 * distance

	var tween = shader.get_shader_param("tween")

	if $"../AI".current_state == EnemyAI.States.ATTACK_BEGIN:
		tween += delta * SHADER_TWEEN_SPEED
	else:
		tween -= delta * SHADER_TWEEN_SPEED

	tween = clamp(tween, 0.0, 1.0)

	shader.set_shader_param("tween", tween)
