extends MeshInstance
class_name LinkDoor

var direction
var closed_pos
var open_pos
var open = false

const SPEED = 15.0

func _ready():
	closed_pos = self.translation.y
	open_pos = self.translation.y - (mesh.size.y + 0.1)

func _physics_process(delta):
	if open and self.translation.y > open_pos:
		self.translation.y = max(self.translation.y - SPEED * delta, open_pos)

	elif not open and self.translation.y < closed_pos:
		self.translation.y = min(self.translation.y + SPEED * delta, closed_pos)

func open():
	open = true

func close():
	open = false
