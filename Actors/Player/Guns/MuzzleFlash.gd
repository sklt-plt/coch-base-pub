extends Spatial

const SHOW_NUM_FRAMES = 3

var cor

func show():
	cor = show_corroutine()

func show_corroutine():
	self.visible = true
	var yee = max(1, SHOW_NUM_FRAMES*Performance.get_monitor(Performance.TIME_FPS)/60)
	for _i in range (0, yee):
		yield(get_tree(), "idle_frame")
	self.visible = false
