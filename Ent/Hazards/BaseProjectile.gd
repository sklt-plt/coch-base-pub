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

extends KinematicBody
class_name BaseProjectile

export (float) var speed = 6.0

func _physics_process(delta):
	var dir = transform.basis.xform(Vector3.FORWARD)
	var col = move_and_collide(dir*speed*delta, false, true, false)

	if col:
		hit_target(col)

func hit_target(var _col : KinematicCollision):
	pass  # override me

func _on_DecayTimer_timeout():
	queue_free()
