extends Node
class_name LinkDoorsGenerator

func make_doors(var room: GeneratedRoom, var mat: Material):
	var geometry = get_node(room.geometry) as RoomGeometry

	var links = geometry.used_exits()

	for l in links:
		if l["target"] == "outside":
			continue

		var door = LinkDoor.new()

		door.material_override = mat

		var mesh = CubeMesh.new()
		mesh.size.x = l["size"].x
		mesh.size.y = l["size"].y
		mesh.size.z = 0.5

		door.mesh = mesh

		door.translation = l["origin"]

		door.direction = l["direction"]

		var offset_vec = Vector3(0, 0, -0.25)
		offset_vec.y = l["size"].y/2
		match l["direction"]:
			0:
				offset_vec.x = l["size"].x/2
			1:
				offset_vec.x = -l["size"].x/2
				door.rotation_degrees.y = 180
			2:
				offset_vec.x = -l["size"].x/2
				door.rotation_degrees.y = 90
			3:
				offset_vec.x = l["size"].x/2
				door.rotation_degrees.y = -90

		door.translate_object_local(offset_vec)

		door.name = "LinkDoor"
		geometry.add_child(door)
		door.set_owner(self.owner)

