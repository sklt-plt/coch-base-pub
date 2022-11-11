extends Node
class_name LinkPortalGenerator

func make_portals(var room: GeneratedRoom):
	var geometry = get_node(room.geometry) as RoomGeometry

	var links = geometry.used_exits()

	for l in links:
		if l["target"] == "outside":
			continue

		var mesh_inst = PortalWindow.new()

		mesh_inst.mesh = QuadMesh.new()
		mesh_inst.mesh.size = l["size"]

		mesh_inst.translation = l["origin"]

		var offset_vec = Vector3.ZERO
		offset_vec.y = l["size"].y/2
		match l["direction"]:
			0:
				offset_vec.x = l["size"].x/2
			1:
				offset_vec.x = -l["size"].x/2
				mesh_inst.rotation_degrees.y = 180
			2:
				offset_vec.x = -l["size"].x/2
				mesh_inst.rotation_degrees.y = 90
			3:
				offset_vec.x = l["size"].x/2
				mesh_inst.rotation_degrees.y = -90

		mesh_inst.translate_object_local(offset_vec)

		mesh_inst.name = "Portal"
		geometry.add_child(mesh_inst)
		mesh_inst.set_owner(self.owner)

