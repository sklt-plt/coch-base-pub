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

extends Particles

const light_flash_speed = 3

func _ready():
	one_shot = true

func _physics_process(delta):
	var light = get_node_or_null("OmniLight")
	if light and light.light_energy > 0.01:
		light.light_energy -= delta * light_flash_speed

	if not self.emitting and not $AudioStreamPlayer3D.stream_paused and light.light_energy < 0.011:
		queue_free()
