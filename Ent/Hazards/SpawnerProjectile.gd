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

extends BaseProjectile

export (PackedScene) var spawn : PackedScene
export (String) var spawn_group : String
export (int) var spawn_max_count : int

func _ready():
	#check if we can spawn an entity
	if get_tree().get_nodes_in_group(spawn_group).size() >= spawn_max_count:
		queue_free()

func hit_target(var _col):
	var new_spawn = spawn.instance()

	new_spawn.set_owner(self.owner)

	if new_spawn is KinematicEnemy:
		new_spawn.set_dynamic(true)

	get_tree().current_scene.add_child(new_spawn)
	new_spawn.global_transform.origin = self.global_transform.origin
	new_spawn.add_to_group(spawn_group)

	if new_spawn is KinematicEnemy:
		new_spawn.set_awake(true)

	self.queue_free()
