extends Interactable
class_name LevelExit

func activate():
	if $"/root/EpisodeManager".is_custom_episode_playing():
		$"/root/Player/GameOverStats".reason = "Finish!"
		$"/root/Player/GameOverStats".show()
	else:
		var settings = get_tree().current_scene.get_node_or_null("ExtraSettings")
		if (settings and settings.require_score and not $"/root/Player".is_full("r_progress")):
			$"/root/EpisodeManager".restart_current_map()
		else:
			$"/root/EpisodeManager".next_map()
