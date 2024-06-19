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

extends Viewport

var camera
var world_camera
const FMOD_VAL = 10.0 # idk why this value works

func _ready():
	world_camera = $"/root".get_camera()

	self.size = $"/root".size / 2

	camera = get_node("Camera")
	camera.fov = world_camera.fov

func _process(delta):
	camera.global_transform.origin = world_camera.global_transform.origin + Vector3(0, 10000, 0)
	camera.global_transform.origin.x = fmod(camera.global_transform.origin.x, FMOD_VAL)
	camera.global_transform.origin.z = fmod(camera.global_transform.origin.z, FMOD_VAL)
	camera.global_transform.basis = world_camera.global_transform.basis
