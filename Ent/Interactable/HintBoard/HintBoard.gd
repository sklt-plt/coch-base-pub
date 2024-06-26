#    Copyright (C) 2024 Jakub Miksa
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This prograsm is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
		"Press ({KEY_QMELEE}) to kick barrels towards enemies\n\n Red barrels explode when shot\n No, really"
	],
	2:
	[
		"You can climb some buildings\n And there is no fall damage, trust me",
		"Crossbow time!\n\n Bolts explode shortly after hitting the target and when you press {KEY_ALTFIRE}!",
		"You have plenty of time to get out Sniper's line of sight. Sort of"#,
		#"Backpack weapon reloading is totally intended",
	],
	199:
	[
		"Arcade rules:\n\n - Defeat enemies to score\n - Score multiplier increases each level\n - You have 3 minutes but killing enemies and picking up items freezes timer\n\n Good luck! \n P.S. The timer is already started"
	]
}

func _ready():
	var current_ep = $"/root/EpisodeManager".current_ep
	var current_level_idx = $"/root/EpisodeManager".current_level_idx
	if current_ep > 100 and current_ep < 200 and $"/root/Player".check("s_level") == 1:
		$Label3D.text = hints[199][0]
		return

	if hints.has(current_ep) and hints[current_ep].size() > current_level_idx and hints[current_ep][current_level_idx] != "":
		$Label3D.text = hints[current_ep][current_level_idx].format(InputHelper.get_input_string_formatting())
		return

	queue_free()
