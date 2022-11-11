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
