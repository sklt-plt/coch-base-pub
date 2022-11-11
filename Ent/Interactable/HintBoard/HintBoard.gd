extends Spatial
class_name HintBoard

var hints = {
	1:
	[
		"Use {KEY_FWD} {KEY_BWD} {KEY_LEFT} {KEY_RIGHT} to move\n\n Move mouse to look around\n\n Use {KEY_FIRE} to shoot\n\n Find the exit!",
		"Pull hammer ({KEY_ALTFIRE}) for more precise shots with the revolver \n\n You can switch between toggle and hold aiming in options menu.",
		"Running ({KEY_RUN}) makes it easier to avoid attacks. Can be toggled in options menu.",
		"You have a shotgun!\n\n Use ({KEY_ALTFIRE}) to reload manually\n\n Use {KEY_SELN} and {KEY_SELP} to switch between weapons.",
		"Crouch ({KEY_CRAWL}) and jump ({KEY_JUMP}) to avoid enemy projectiles.",
		"Red barrels explode when shot.\n\nNo, really."
	],
	2:
	[
		"Crossbow bolts explode shortly after hitting the target,\n alternatively use {KEY_ALTFIRE} to detonate them mid-flight!"
	]
}

func _ready():
	var current_ep = $"/root/EpisodeManager".current_ep
	var current_level_idx = $"/root/EpisodeManager".current_level_idx
	if hints.has(current_ep) and hints[current_ep].size() > current_level_idx and hints[current_ep][current_level_idx] != "":

		var input_formatting = {
			"KEY_FWD": InputHelper.get_input_buttons_text("Forward").to_upper(),
			"KEY_BWD": InputHelper.get_input_buttons_text("Backwards").to_upper(),
			"KEY_LEFT": InputHelper.get_input_buttons_text("Strafe Left").to_upper(),
			"KEY_RIGHT": InputHelper.get_input_buttons_text("Strafe Right").to_upper(),
			"KEY_USE": InputHelper.get_input_buttons_text("Interact").to_upper(),
			"KEY_JUMP": InputHelper.get_input_buttons_text("Jump").to_upper(),
			"KEY_CRAWL": InputHelper.get_input_buttons_text("Crawl").to_upper(),
			"KEY_RUN": InputHelper.get_input_buttons_text("Run").to_upper(),
			"KEY_FIRE": InputHelper.get_input_buttons_text("Fire").to_upper(),
			"KEY_ALTFIRE": InputHelper.get_input_buttons_text("Aim").to_upper(),
			"KEY_QMELEE": InputHelper.get_input_buttons_text("Quick Melee").to_upper(),
			"KEY_SEL0": InputHelper.get_input_buttons_text("Select Melee").to_upper(),
			"KEY_SEL1": InputHelper.get_input_buttons_text("Select Revolver").to_upper(),
			"KEY_SEL2": InputHelper.get_input_buttons_text("Select Shotgun").to_upper(),
			"KEY_SEL3": InputHelper.get_input_buttons_text("Select Crossbow").to_upper(),
			"KEY_SELN": InputHelper.get_input_buttons_text("Select Next").to_upper(),
			"KEY_SELP": InputHelper.get_input_buttons_text("Select Prev").to_upper()
		}

		$Label3D.text = hints[current_ep][current_level_idx].format(input_formatting)
	else:
		queue_free()
