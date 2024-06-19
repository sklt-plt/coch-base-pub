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

extends Area

var colliders = []

const BASE_KINEMATIC_ACTOR_PUSH_FORCE = 100.0

func _physics_process(delta):
	for c in colliders:
		push_away(c, delta) # push

func push_away(var body: KinematicEnemy, var mul: float):
	var direction = (self.global_transform.origin - body.global_transform.origin) + (body.get_current_move_vector())
	#assumming parent is rigidbody
	get_parent().apply_impulse(Vector3(0.0, 0.25, 0.0), direction*BASE_KINEMATIC_ACTOR_PUSH_FORCE*mul)

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicEnemy and not colliders.has(body):
		push_away(body, 0.75) # kick
		colliders.push_back(body)

func _on_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicEnemy and colliders.has(body):
		colliders.erase(body)
