extends Interactable
class_name LockedDoor

export (Vector2) var size = Vector2(2,2)
export (Animation) var anim
const ANIM_NAME = "hide_this"

func activate():
	if not $StaticBody/CollisionShape.disabled and $"/root/Player".take("r_keys", 1):
		$Trigger/CollisionShape.disabled = true
		$StaticBody/CollisionShape.disabled = true
		$"/root/Player/HUD".hide_dialog(.make_prompt_text())
		var animation_player = get_node_or_null("Model/AnimationPlayer") as AnimationPlayer
		if animation_player and anim:
			animation_player.add_animation(ANIM_NAME, anim)
			$Model/AnimationPlayer.play(ANIM_NAME)
		else:
			$Model.visible = false

func _on_Trigger_body_entered(body):
	if body == $"/root/Player":
		if $"/root/Player".has("r_keys", 1):
			$"/root/Player/HUD".display_dialog(.make_prompt_text())
			set_process_input(true)
		else:
			$"/root/Player/HUD".display_dialog(make_prompt_text_locked())

func _on_Trigger_body_exited(body):
	if body == $"/root/Player":
		if $"/root/Player".has("r_keys", 1):
			$"/root/Player/HUD".hide_dialog(.make_prompt_text())
		else:
			$"/root/Player/HUD".hide_dialog(make_prompt_text_locked())
		set_process_input(false)

func make_prompt_text_locked():
	return "You need a key"
