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

extends Node

const index_seek_max_tries = 50			# how many enemies to check when seeking awake one

var enemies : Array
var current = -1

const MAX_PROCESS_PER_FRAME = 6

func register_ai(var node):
	if !enemies:
		enemies = []
		enemies.push_back(node)
		current = 0
	else:
		enemies.push_back(node)

func clear_registrations():
	current = -1
	enemies.clear()

func _physics_process(delta):
	for _i in range(0, MAX_PROCESS_PER_FRAME):
		seek_and_process(delta)

func increase_index():
	current = (current + 1)%enemies.size()

func seek_and_process(var delta):
	if current > -1:
		var seek_tries = 0
		while not enemies[current].is_inside_tree() or enemies[current].current_state < EnemyAI.States.DYING:
			increase_index()
			seek_tries += 1
			if seek_tries > index_seek_max_tries:
				return

		enemies[current]._managed_process(delta)

		increase_index()
