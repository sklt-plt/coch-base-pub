extends Viewport

var camera
var world_camera
const FMOD_VAL = 10.0 # idk why this value works

func _ready():
	world_camera = $"/root".get_camera()

	self.size = $"/root".size / 2

	camera = get_node("Camera")
	camera.fov = world_camera.fov

func _process(delta):
	camera.global_transform.origin = world_camera.global_transform.origin + Vector3(0, 10000, 0)
	camera.global_transform.origin.x = fmod(camera.global_transform.origin.x, FMOD_VAL)
	camera.global_transform.origin.z = fmod(camera.global_transform.origin.z, FMOD_VAL)
	camera.global_transform.basis = world_camera.global_transform.basis
