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
class_name ProjectileSpawnHelper

static func spawn_projectile(
	var projectile_scene: PackedScene,
	var parent : Node,
	var start_pos : Vector3,
	var target_pos : Vector3):

		var p = projectile_scene.instance()

		#fire projectile
		parent.add_child(p)
		p.global_transform.origin = start_pos

		p.look_at(target_pos, Vector3.UP)

		return p
