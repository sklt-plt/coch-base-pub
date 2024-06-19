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

func _ready():
	var rbs = get_children()
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for rb in rbs:
		if rb is RigidBody:
			rb.apply_impulse(Vector3.ZERO, Vector3(rng.randf_range(-2.0, 2.0), rng.randf_range(3.0, 6.0), rng.randf_range(-2.0, 2.0)))


func _on_Timer_timeout():
	self.queue_free()
