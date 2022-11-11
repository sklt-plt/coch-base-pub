extends Node
class_name LinkDoorsGenerator
tool

export (Material) var link_door_material
export (PackedScene) var gate_side_l
export (PackedScene) var gate_side_r
export (PackedScene) var gate_corner_r
export (PackedScene) var gate_corner_l
export (PackedScene) var gate_top

enum DOOR_VARIANT {
	L, R, CENTER
}

func make_doors(var room: GeneratedRoom):
	var geometry = get_node(room.geometry) as RoomGeometry

	var links = geometry.used_exits()

	for l in links:
		if l["target"] == "outside":
			continue

		var gate_models_exist = gate_side_l and gate_side_r and gate_corner_r and gate_corner_l and gate_top

		if gate_models_exist and l["size"].x > 2:
			make_single_door(geometry, l, DOOR_VARIANT.L)
			make_single_door(geometry, l, DOOR_VARIANT.R)
			make_door_frame(geometry, l)
		elif gate_models_exist and l["size"].x <=2:
			var l_dup = l.duplicate()
			l_dup["size"].x *= 2
			make_single_door(geometry, l_dup, DOOR_VARIANT.L)
			make_door_frame(geometry, l)
		else:
			make_single_door(geometry, l, DOOR_VARIANT.CENTER)

func make_door_frame(var geometry: RoomGeometry, var link):
	var parent = Spatial.new()
	parent.name = "DoorFrame"
	geometry.add_child(parent)
	parent.owner = geometry.owner
	parent.translation = link["origin"]
	# probably align
	match link["direction"]:
		1:
			parent.translation += Vector3(link["size"].x, 0, 0)
			parent.rotation_degrees.y = 180
		2:
			parent.rotation_degrees.y = 90
			parent.translation += Vector3(0, 0, link["size"].x)
		3:
			parent.rotation_degrees.y = -90

	for y in range(0, link["size"].y):
		var element_left = gate_side_l.instance()
		parent.add_child(element_left)
		element_left.owner = parent.owner
		element_left.translation = Vector3(-1, y, 0)

		var element_right = gate_side_r.instance()
		parent.add_child(element_right)
		element_right.owner = parent.owner
		element_right.translation = Vector3(link["size"].x, y, 0)

	var corner_left = gate_corner_l.instance()
	parent.add_child(corner_left)
	corner_left.owner = parent.owner
	corner_left.translation = Vector3(-1, link["size"].y, 0)

	var corner_right = gate_corner_r.instance()
	parent.add_child(corner_right)
	corner_right.owner = parent.owner
	corner_right.translation = Vector3(link["size"].x, link["size"].y, 0)

	for x in range(0, link["size"].x):
		var element = gate_top.instance()
		parent.add_child(element)
		element.owner = parent.owner
		element.translation = Vector3(x, link["size"].y, 0)

func make_single_door(var geometry: RoomGeometry, var link, var variant : int):
	#prepare
	var meshInst = MeshInstance.new()

	meshInst.material_override = link_door_material

	var mesh = CubeMesh.new()
	mesh.size.x = link["size"].x if variant == DOOR_VARIANT.CENTER else link["size"].x/2
	mesh.size.y = link["size"].y
	mesh.size.z = 0.5

	meshInst.mesh = mesh

	var offset_vec = Vector3.ZERO
	offset_vec.y = link["size"].y/2

	var door = LinkDoor.new(variant, link["direction"], meshInst)

	door.name = "LinkDoor"
	door.translation = link["origin"]

	#create
	geometry.add_child(door)
	door.set_owner(geometry.owner)
	door.add_child(meshInst)
	meshInst.set_owner(door.owner)

	#align
	door.translation = link["origin"]
	match link["direction"]:
		0:
			if variant == DOOR_VARIANT.R:
				door.translate_object_local(Vector3(link["size"].x,0,-1))
			else:
				door.translate_object_local(Vector3(0,0,-1))
		1:
			meshInst.rotation_degrees.y = 180
			if variant == DOOR_VARIANT.R:
				door.translate_object_local(Vector3(link["size"].x,0,0))
			#door.translate_object_local(Vector3(0,0,1))
		2:
			meshInst.rotation_degrees.y = 90
			#door.translate_object_local(Vector3(-1,0,0))
			if variant == DOOR_VARIANT.R:
				door.translate_object_local(Vector3(0,0,link["size"].x))
		3:
			meshInst.rotation_degrees.y = -90
			if variant == DOOR_VARIANT.R:
				door.translate_object_local(Vector3(1,0,link["size"].x))
			else:
				door.translate_object_local(Vector3(1,0,0))

	match variant:
		DOOR_VARIANT.CENTER:
			if link["direction"] == 0 or link["direction"] == 3:
				offset_vec.x = link["size"].x/2
			else:
				offset_vec.x = -link["size"].x/2
		DOOR_VARIANT.L:
			if link["direction"] == 0 or link["direction"] == 3:
				offset_vec.x = link["size"].x/4
			else:
				offset_vec.x = -link["size"].x/4
		DOOR_VARIANT.R:
			if link["direction"] == 0 or link["direction"] == 3:
				offset_vec.x = -link["size"].x/4
			else:
				offset_vec.x = link["size"].x/4

	meshInst.translate_object_local(offset_vec)
