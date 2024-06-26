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

class_name AutomaticDoor

export (bool) var unlocked
export (float) var stayOpenTime

func on_button_pushed():
	unlocked = true
	openIfAPlayerIsNearby()

func openIfAPlayerIsNearby():
	var bodies = $CollisionShape/MotionDetectorArea.get_overlapping_bodies()

	for player in get_tree().get_nodes_in_group("PlayerTeam"):
		if bodies.has(player):
			open()
			break

func on_MotionDetectorArea_body_entered(body):
	if unlocked and body.is_in_group("PlayerTeam"):
		open()

func open():
	$CollisionShape/MeshInstance/AnimationPlayer.play("open")
	if stayOpenTime > 0:
		$AutoCloseTimer.start(stayOpenTime)

func on_AutoCloseTimer_timeout():
	$CollisionShape/MeshInstance/AnimationPlayer.play_backwards("open")
