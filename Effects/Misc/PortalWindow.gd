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

extends MeshInstance
class_name PortalWindow

const SHADER = "res://Base/Effects/Portal.gdshader"

func _ready():
	if not Engine.editor_hint:
		configure()

func configure():
	var fake_room = get_node(get_tree().current_scene.get_path()).get_node_or_null("FakeRoomViewport") as Viewport
	if not fake_room:
		print("Warning: not found FakeRoom for portals to draw")
		return

	var mat = ShaderMaterial.new()

	mat.shader = load(SHADER)

	mat.set_shader_param("texture_albedo", fake_room.get_texture())

	self.set("material/0", mat)
