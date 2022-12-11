extends Interactable
class_name LockedDoor

const LOCK_LAUNCH_MAX_FORCE = 1.0
const LOCK_LAUNCH_MAX_OFFSET = 0.5

export (Vector2) var size = Vector2(2,2)
export (PackedScene) var padlock

var needs_key = true

func _ready():
	#construct padlock unless this is first normal room
	if (get_node(get_parent().tree_ref).get_parent().traits.has(GeneratedRoom.ROOM_TRAITS.STARTING)):
		needs_key = false

	elif padlock:
		var lock_inst = padlock.instance()
		lock_inst.name = "Padlock"
		self.add_child(lock_inst)

		lock_inst.translation = Vector3(size.x / 2, 1, -0.4)
		lock_inst.rotate(Vector3.UP, deg2rad(180))

func activate():
	if not $StaticBody/CollisionShape.disabled and (not needs_key or $"/root/Player".take("r_keys", 1)):
		$Trigger/CollisionShape.disabled = true
		$StaticBody/CollisionShape.disabled = true
		$"/root/Player/HUD".hide_dialog(.make_prompt_text())
		var animation_player = get_node_or_null("Model/AnimationPlayer") as AnimationPlayer
		if animation_player:
			animation_player.play(animation_player.get_animation_list()[0])
		else:
			$Model.visible = false

	var padlock = get_node_or_null("Padlock")
	if padlock:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		padlock.launch(rng, LOCK_LAUNCH_MAX_OFFSET, LOCK_LAUNCH_MAX_FORCE)

func _on_Trigger_body_entered(body):
	if body == $"/root/Player":
		if $"/root/Player".has("r_keys", 1) or not needs_key:
			$"/root/Player/HUD".display_dialog(.make_prompt_text())
			set_process_input(true)
		else:
			$"/root/Player/HUD".display_dialog(make_prompt_text_locked())

func _on_Trigger_body_exited(body):
	if body == $"/root/Player":
		if $"/root/Player".has("r_keys", 1) or not needs_key:
			$"/root/Player/HUD".hide_dialog(.make_prompt_text())
		else:
			$"/root/Player/HUD".hide_dialog(make_prompt_text_locked())
		set_process_input(false)

func make_prompt_text_locked():
	return "You need a key"
