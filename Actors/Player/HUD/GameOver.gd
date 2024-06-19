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
class_name GameOver

const IRONMAN_MAX_DEATHS = 4

func show_delayed():
	$"DelayT".start()

func show():
	$"DelayT".stop()

	if Globals.get_difficulty_field("ironman") and $"/root/Player".check("s_deaths") >= IRONMAN_MAX_DEATHS:
		$"Control/RestartB".visible = false
	else:
		$"Control/RestartB".visible = true

	.show()

func _on_RestartB_button_up():
	$"/root/Player".revive()
	hide()
	$"/root/EpisodeManager".restart_current_map()

func _on_QuitB_button_up():
	hide()
	$"/root/EpisodeManager".quit_to_menu()

func _on_DelayT_timeout():
	show()
