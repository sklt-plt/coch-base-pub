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
