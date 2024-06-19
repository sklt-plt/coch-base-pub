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

extends Timer

func _on_FalloutCheckerTimer_timeout():
	var td_visible = $"../TriggerDetector".visible_last
	var player = $"/root/Player"
	if not td_visible.empty() and player.global_transform.origin.y < td_visible[0].global_transform.origin.y - 500:

		var starting_room_geometry = get_node(get_tree().current_scene.find_node("starting_room").geometry) as RoomGeometry
		starting_room_geometry.move_to_offset()

		var spawn_point = get_tree().current_scene.get_node("PlayerSpawn")
		spawn_point._ready()  # recall player
