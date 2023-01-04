extends Control

func build_text_and_show():
	var label = $Panel/Label

	match $"/root/EpisodeManager".episode_clear_idx:
		1:
			label.text = "Congratulations! \n You've unlocked: \n \n Episode 2 \n Episode 1 Arcade Mode \n Episode 1 Custom Mode"
		2:
			label.text = "Congratulations! \n You've unlocked: \n \n Episode 2 Arcade Mode \n Episode 2 Custom Mode"
		_:
			return

	$"/root/EpisodeManager".episode_clear_idx = -1

	self.visible = true
