extends Control

func show():
	$"../MapContainer".visible = false
	self.visible = true

func hide():
	$"../MapContainer".restore()
	self.visible = false
