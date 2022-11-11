extends Interactable
class_name LevelExit

func activate():
	if $"/root/EpisodeManager".is_custom_episode_playing():
		$"/root/Player/GameOverStats".reason = "Finish!"
		$"/root/Player/GameOverStats".show()
	else:
		$"/root/EpisodeManager".next_map()
