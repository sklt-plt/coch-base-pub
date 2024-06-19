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

func build_text_and_show():
	var label = $Panel/Label

	match $"/root/EpisodeManager".episode_clear_idx:
		1:
			label.text = "Congratulations! \n You've unlocked: \n \n Episode 1 Arcade Mode \n Episode 1 Custom Mode"
		2:
			label.text = "Congratulations! \n You've unlocked: \n \n Episode 2 Arcade Mode \n Episode 2 Custom Mode"
		_:
			return

	$"/root/EpisodeManager".episode_clear_idx = -1

	self.visible = true
