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
class_name InWorldButton

export (NodePath) var targetPath
export (String) var parameter = ""
export (int) var on_value = 1
export (int) var off_value = 0
export (bool) var one_shot = true

var activated = false
var target

func _ready():
	target = get_node(targetPath)

func activate():
	if not one_shot or not activated and target != null and parameter != "":
		if activated == true:
			target.set(parameter,on_value)
		else:
			target.set(parameter,off_value)

		activated = !activated
		if target.has_method("on_button_pushed"):
			target.on_button_pushed()

		print("Pushed a button")

func on_button_body_entered(body):
	if body.is_in_group("PlayerTeam"):
		$CollisionShape/MeshInstance/AnimationPlayer.play("push")
		activate()
