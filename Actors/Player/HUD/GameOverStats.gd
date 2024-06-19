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

extends GameOver

var reason = "You Died"
var stats_labels

func _ready():
	stats_labels = $"StatsSC/GC".get_children()

func reset():
	reason = "You Died"
	$"Control/RestartB".visible = true
	$"Control/QuitB".text = "Quit"

func _on_RestartB_button_up():
	hide()
	$"/root/Player".reset()
	$"/root/EpisodeManager".restart_episode()

func show():
	$"DelayT".stop()
	.show()

	$"Label".text = reason

	var player = $"/root/Player"

	if $"/root/EpisodeManager".is_endless_episode_playing():
		$"StatsSC/GC/LevelL".visible = true
		$"StatsSC/GC/LevelVal".visible = true
		$"StatsSC/GC/LevelVal".text = String(player.check("s_level"))
		AchievementHelper.try_give_arcade_achievements()
	else:
		$"StatsSC/GC/LevelL".visible = false
		$"StatsSC/GC/LevelVal".visible = false

	$"StatsSC/GC/TimeVal".text = TimeHelper.float_to_min_sec_msec_str(player.check("s_time_total"))

	var kills = player.check("s_kills")
	var kills_possible = player.check("s_kills_possible")
	var kills_text = String(kills) + " out of " + String(kills_possible)

	$"StatsSC/GC/KillsVal".text = kills_text
	if kills_possible > 0:
		$"StatsSC/GC/KillsPVal".text = String(kills*100 / kills_possible) + " %"

	# shots hit can be > shots fired, because of explosion chaining so...
	var shots_hit = min(player.check("s_shots_hit"), player.check("s_shots_fired"))
	var shots_total = player.check("s_shots_fired")
	var shots_text = String(shots_hit) + " out of " + String(shots_total)

	$"StatsSC/GC/ShotsHVal".text = shots_text
	if shots_total > 0:
		$"StatsSC/GC/AccuracyVal".text = String((shots_hit*100 / shots_total)) + " %"
	else:
		$"StatsSC/GC/AccuracyVal".text = "0 %"

	var treasure = player.check("s_treasure_open")
	var treasure_possible = player.check("s_treasure_possible")
	var treasure_text = String(treasure) + " out of " + String(treasure_possible)

	$"StatsSC/GC/TreasVal".text = treasure_text

	$"StatsSC/GC/DamageDVal".text = String(player.check("s_damage_dealt"))
	$"StatsSC/GC/DamageTVal".text = String(player.check("s_damage_taken"))

	if $"/root/EpisodeManager".is_normal_episode_playing():
		$"Label".text = "Episode Complete!"
		$"Control/RestartB".visible = false
		$"Control/QuitB".text = "Continue"
		$"StatsSC/GC/DeathsVal".text = String(player.check("s_deaths"))
		$"StatsSC/GC/DeathsVal".visible = true
		$"StatsSC/GC/DeathsL".visible = true
	else:
		$"StatsSC/GC/DeathsVal".visible = false
		$"StatsSC/GC/DeathsL".visible = false

	$"StatsSC/GC/ScoreVal".text = String(player.check("s_score"))
