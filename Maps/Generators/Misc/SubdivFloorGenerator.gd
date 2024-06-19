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
class_name SubdivFloorGenerator

func generate(var room_geometry: RoomGeometry, var _owner):
	var st = SurfaceTool.new()
	var arr_mesh = ArrayMesh.new()

	for x in range(0, 4):
		for y in range(0, 4):
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			st.add_uv(Vector2(1, 1))
			st.add_tangent(Plane(Vector3.UP, 1))
			st.add_normal(Vector3.UP)
			st.set_material(load("res://Content/custom/Maps/Materials/ep2/walls.tres"))
			st.add_vertex(Vector3(x, 0, y))
			st.add_vertex(Vector3(x+1, 0, y))
			st.add_vertex(Vector3(x, 0, y+1))

			arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays())
			st.clear()

			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			st.add_uv(Vector2(1, 1))
			st.add_tangent(Plane(Vector3.UP, 1))
			st.add_normal(Vector3.UP)
			st.set_material(load("res://Content/custom/Maps/Materials/ep2/walls.tres"))
			st.add_vertex(Vector3(x+1, 0, y+1))
			st.add_vertex(Vector3(x, 0, y+1))
			st.add_vertex(Vector3(x+1, 0, y))

			arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays())
			st.clear()

	var child = MeshInstance.new()
	child.mesh = arr_mesh
	room_geometry.add_child(child)
	child.owner = _owner
