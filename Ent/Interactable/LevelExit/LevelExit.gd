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

extends Interactable
class_name LevelExit

func activate():
	if $"/root/EpisodeManager".is_custom_episode_playing():
		$"/root/Player/GameOverStats".reason = "Finish!"
		$"/root/Player/GameOverStats".show()
		AchievementHelper.increment_stat(AchievementHelper.STATS.TOTAL_CUSTOM_MAPS, 1)
	else:
		var settings = get_tree().current_scene.get_node_or_null("ExtraSettings")
		if (settings and settings.require_score and not $"/root/Player".is_full("r_progress")):
			$"/root/EpisodeManager".restart_current_map()
		else:
			$"/root/EpisodeManager".next_map()
