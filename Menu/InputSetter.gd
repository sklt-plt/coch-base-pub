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

extends Control

signal set_action(action)

var current_action = ""

func _input(event):
	if visible and current_action != "":
		if event is InputEventKey and event.physical_scancode == KEY_ESCAPE:
			visible = false
			return

		if event is InputEventKey or event is InputEventMouseButton:
			InputHelper.set_input(current_action, event)

			visible = false
			emit_signal("set_action", current_action)
			current_action = ""

func listen(var action_name : String):
	current_action = action_name
	visible = true

func _on_MoveForwardButton_button_up():
	listen("Forward")

func _on_MoveBackwardsButton_button_up():
	listen("Backwards")

func _on_StrafeLeftButton_button_up():
	listen("Strafe Left")

func _on_StrafeRightButton_button_up():
	listen("Strafe Right")

func _on_JumpButton_button_up():
	listen("Jump")

func _on_CrawlButton_button_up():
	listen("Crawl")

func _on_RunButton_button_up():
	listen("Run")

func _on_FireButton_button_up():
	listen("Fire")

func _on_AltFireButton_button_up():
	listen("Aim")

func _on_QMeleeButton_button_up():
	listen("Quick Melee")

func _on_SRevolverButton_button_up():
	listen("Select Revolver")

func _on_SShotgunButton_button_up():
	listen("Select Shotgun")

func _on_SCrossbowButton_button_up():
	listen("Select Crossbow")

func _on_SMeleeButton_button_up():
	listen("Select Melee")

func _on_InteractButton_button_up():
	listen("Interact")

func _on_SNextButton_button_up():
	listen("Select Next")

func _on_SPrevButton_button_up():
	listen("Select Prev")

func _on_MapButton_button_up():
	listen("Show Map")
