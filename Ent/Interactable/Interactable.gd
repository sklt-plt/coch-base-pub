extends Spatial
class_name Interactable

export (String) var prompt_text_suffix = ""
export (AudioStream) var audio_effect

func _ready():
	set_process_input(false)

func activate():
	pass  # override

func playSfx():
	if audio_effect:
		$"/root/Player/SFXPlayer".stream = audio_effect
		$"/root/Player/SFXPlayer".play()

func _input(event):
	if event.is_action_pressed("Interact"):
		activate()

func _on_Trigger_body_entered(body):
	if body == $"/root/Player":
		$"/root/Player/HUD".display_dialog(make_prompt_text())
		set_process_input(true)

func _on_Trigger_body_exited(body):
	if body == $"/root/Player":
		$"/root/Player/HUD".hide_dialog(make_prompt_text())
		set_process_input(false)

func make_prompt_text():
	return "Press " + InputHelper.get_input_buttons_text("Interact") + " " + prompt_text_suffix
