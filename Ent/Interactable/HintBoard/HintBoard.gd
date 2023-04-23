extends Spatial
class_name HintBoard

var hints = {
	1:
	[
		"Use {KEY_FWD} {KEY_BWD} {KEY_LEFT} {KEY_RIGHT} to move\n\n Move mouse to look around\n\n Use {KEY_FIRE} to shoot\n\n Walk through the gate when ready...",
		"Running ({KEY_RUN}) makes it easier to avoid attacks. Can be toggled in options menu.",
		"Hold ({KEY_ALTFIRE}) for more precise shots with the revolver \n\n You can switch between toggle and hold aiming in options menu.",
		"You have a shotgun!\n\n Use ({KEY_ALTFIRE}) to reload earlier\n\n Use {KEY_SELN} and {KEY_SELP} to switch between weapons.",
		"Map shows you which rooms were explored, which still have treasure and which are yet to be discovered\n You can toggle map modes with ({KEY_MAP})",
		"Red barrels explode when shot.\n\nNo, really."
	],
	2:
	[
		"Press ({KEY_QMELEE}) to kick barrels towards enemies",
		"Crossbow time!\n\n Bolts explode shortly after hitting the target and when you press {KEY_ALTFIRE}!",
		"You have plenty of time to get out Sniper's line of sight. Sort of"
	]
}

func _ready():
	var current_ep = $"/root/EpisodeManager".current_ep
	var current_level_idx = $"/root/EpisodeManager".current_level_idx
	if hints.has(current_ep) and hints[current_ep].size() > current_level_idx and hints[current_ep][current_level_idx] != "":
		$Label3D.text = hints[current_ep][current_level_idx].format(InputHelper.get_input_string_formatting())
	else:
		queue_free()
