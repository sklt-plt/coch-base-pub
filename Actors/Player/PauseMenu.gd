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

extends PauseScreen

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		$Options.visible = false
		hide()

func _on_ResumeButton_button_up():
	hide()

func _on_QuitButton_button_up():
	$"/root/EpisodeManager".quit_to_menu()

func _on_OptionsButton_button_up():
	$Options.visible = true
