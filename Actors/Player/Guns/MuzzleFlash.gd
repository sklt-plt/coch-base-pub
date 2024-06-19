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

extends Spatial

const SHOW_NUM_FRAMES = 3

var cor

func show():
	cor = show_corroutine()

func show_corroutine():
	self.visible = true
	var yee = max(1, SHOW_NUM_FRAMES*Performance.get_monitor(Performance.TIME_FPS)/60)
	for _i in range (0, yee):
		yield(get_tree(), "idle_frame")
	self.visible = false
