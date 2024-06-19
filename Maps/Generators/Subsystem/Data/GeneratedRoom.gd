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
class_name GeneratedRoom

enum ROOM_TRAITS {
	##ROOM TYPES
	STARTING,
	NORMAL_CORRIDORS,
	ARENA,
	FURNISHED,
	FURNISHED_ARENA,
	##GENERATORS META
	MAIN,
	END_MAIN,
	SUB,
	END_SUB,
	##OBJECTS
	KEY,
	TREASURE,
	KEY_AND_TREASURE,
	#TRAPPED_TREASURE,
	LOCKED_DOOR,
	EXIT_DOOR
}

export (NodePath) var geometry

var size

var difficulty : float

var prefab_room

var prefab_rotation

export (Array, ROOM_TRAITS) var traits
