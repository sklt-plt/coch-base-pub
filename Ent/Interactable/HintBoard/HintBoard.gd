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
		$Label3D.text = hints[current_ep][current_level_idx].format(InputHelper.get_input_string_formatting())
	else:
		queue_free()
