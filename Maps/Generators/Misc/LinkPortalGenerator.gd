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

