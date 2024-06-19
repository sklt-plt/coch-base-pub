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

extends Camera

func flash_cache_objects():
	#flash objects infront of player to compile shaders
	var cache = get_node_or_null("/root/ObjectCache")
	if not cache:
		print("Warning: not found node '/root/ObjectCache', can't precompile shaders")
		hide_loading()
		return

	get_tree().paused = true

	#borrow it from root
	for c in cache.children_cache:
		self.add_child(c)

	yield(get_tree(), "idle_frame")

	for c in cache.children_cache:
		self.remove_child(c)

	hide_loading()

func hide_loading():
	get_tree().paused = false
	$"/root/Player".hide_loading()

