extends BasePowerup

func activate():
	.activate()
	$"/root/Player".give("e_crossbow_level", 1)

	.playSfx()

	self.queue_free()
