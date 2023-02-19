extends Control
class_name PauseScreen

func show():
	#temporarily hide minimap
	if self.name != "MapContainer":
		$"../MapContainer".visible = false

	self.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide():
	#restore minimap
	if self.name != "MapContainer":
		$"../MapContainer".restore()

	self.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
