extends Area

func _on_FalloutCatcher_body_entered(body):
	if body is KinematicEnemy:
		if body.get_dynamic():
			body.queue_free()
		else:
			body.teleport_to_spawn()
