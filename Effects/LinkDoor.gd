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

extends Spatial
class_name LinkDoor

var variant_
var direction_
var mesh_

var closed_pos
var open_pos
var is_open = false

const SPEED_MOVE = 15.0
const SPEED_ROT = 200.0

enum DOOR_VARIANT {
	L, R, CENTER
}

func _init(var variant : int, var direction: int, var meshInst: MeshInstance):
	direction_ = direction
	variant_ = variant
	mesh_ = meshInst.mesh

func _ready():
	match variant_:
		DOOR_VARIANT.CENTER:
			open_pos = self.translation.y - mesh_.size.y + 0.1
			closed_pos = self.translation.y
		DOOR_VARIANT.L:
			open_pos = 170
			closed_pos = 0
		DOOR_VARIANT.R:
			open_pos = -170
			closed_pos = 0

func _physics_process(delta):
	match variant_:
		DOOR_VARIANT.CENTER:
			if is_open and self.translation.y > open_pos:
				self.translation.y = max(self.translation.y - SPEED_MOVE * delta, open_pos)

			elif not is_open and self.translation.y < closed_pos:
				self.translation.y = closed_pos

		DOOR_VARIANT.L:
			if is_open and self.rotation_degrees.y < open_pos:
				self.rotation_degrees.y = min(self.rotation_degrees.y + SPEED_ROT * delta, open_pos)

			elif not is_open and self.rotation_degrees.y > closed_pos:
				self.rotation_degrees.y = closed_pos

		DOOR_VARIANT.R:
			if is_open and self.rotation_degrees.y > open_pos:
				self.rotation_degrees.y = max(self.rotation_degrees.y - SPEED_ROT * delta, open_pos)

			elif not is_open and self.rotation_degrees.y < closed_pos:
				self.rotation_degrees.y = closed_pos

func open():
	is_open = true

func close():
	is_open = false
