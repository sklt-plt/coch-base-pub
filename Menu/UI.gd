extends Control

signal unsetup_menu
signal focus_camera (target_node)

export (String) var readme_dir = "/README"
export (String) var feedback_url = ""

var selected_ep = -1

var difficulty_descriptions = []

func _ready():
	$"LevelSelect/Ep2Button".disabled = false
	$"LevelSelect/Ep3Button".disabled = true#!Globals.player_progress["2"]
	$"Options".visible = false
	$"LevelSelectEp1".visible = false
	$"LevelSelectEp2".visible = false
	$"CampaignSeed".visible = false
	$"LevelSelect".visible = false
	$"CampaignSetup".visible = false
	difficulty_descriptions = $CampaignSetup/DifficultyDescrCont.get_children()

func show_ep_clear_notif():
	$"MainMenu".visible = false
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionMain")
	$"LevelSelectEp1".visible = false
	$"LevelSelectEp2".visible = false
	$"Options".visible = false
	$"EpClearNotif".build_text_and_show()

func show_main_menu():
	$"MainMenu".visible = true
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionMain")
	$"LevelSelectEp1".visible = false
	$"Options".visible = false
	$"EpClearNotif".visible = false

func show_options():
	$"MainMenu".visible = false
	$"Options".visible = true

func show_level_select():
	$"LevelSelectEp1/PlayEp1Endless".disabled = !Globals.player_progress["1"]
	$"LevelSelectEp1/PlayEp1Custom".disabled = !Globals.player_progress["1"]
	$"LevelSelectEp2/PlayEp2Endless".disabled = !Globals.player_progress["2"]
	$"LevelSelectEp2/PlayEp2Custom".disabled = !Globals.player_progress["2"]

	$"MainMenu".visible = false
	$"LevelSelect".visible = true
	$"LevelSelectEp1".visible = false
	$"LevelSelectEp2".visible = false
	$"EpClearNotif".visible = false
	$"CampaignSeed".visible = false
	emit_signal("focus_camera", "CameraPositionMain")

func show_ep1():
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionEp1")
	$"LevelSelectEp1".visible = true
func show_ep2():
	$"LevelSelect".visible = false
	emit_signal("focus_camera", "CameraPositionEp2")
	$"LevelSelectEp2".visible = true

func show_campaign_setup():
	$"LevelSelectEp1".visible = false
	$"LevelSelectEp2".visible = false

	#$"%CampaignSeedLE".text = Globals.campaign_difficulties[Globals.CAMPAIGN_DIFFICULTY_ID.CUSTOM]["campaign_seed"]
	$"%DifficultyOption".selected = Globals.campaign_difficulty_idx
	show_difficulty_description(Globals.campaign_difficulty_idx)

	$"CampaignSetup".visible = true

func show_difficulty_description(var index):
	for desc in difficulty_descriptions:
		desc.visible = false

	difficulty_descriptions[index].visible = true

	# if this is custom, align sliders to current settings
	$"%EFSlider".value = Globals.campaign_difficulties[Globals.CAMPAIGN_DIFFICULTY_ID.CUSTOM]["enemy_firepower_scale"]
	set_custom_setting_label_text($"%EFValue", "enemy_firepower_scale", $"%EFSlider".value)

	$"%PFSlider".value = Globals.campaign_difficulties[Globals.CAMPAIGN_DIFFICULTY_ID.CUSTOM]["player_firepower_scale"]
	set_custom_setting_label_text($"%PFValue", "player_firepower_scale", $"%PFSlider".value)

func _on_LSBackButton_button_up():
	show_main_menu()

func _on_ContinueButton_button_up():
	show_level_select()

func _on_PlayEp1_button_up():
	selected_ep = 1
	show_campaign_setup()

func _on_PlayEp1Endless_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(101)

func _on_PlayEp1Custom_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(201)

func _on_Ep1Button_button_up():
	show_ep1()

func _on_LSE1BackButton_button_up():
	show_level_select()

func _on_PlayEp2_button_up():
	selected_ep = 2
	show_campaign_setup()

func _on_PlayEp2Endless_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(102)

func _on_PlayEp2Custom_button_up():
	self.visible = false
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(202)

func _on_Ep2Button_button_up():
	show_ep2()

func _on_LSE2BackButton_button_up():
	show_level_select()

func _on_PlayCampaign_button_up():
	self.visible = false
	Globals.save_user_difficulty()
	emit_signal("unsetup_menu")
	EpisodeManager.start_episode(selected_ep)

func _on_QuitButton_button_up():
	get_tree().quit()

func _on_OptionsButton_button_up():
	show_options()

func _on_Options_exited():
	show_main_menu()

func _on_ManualButton_button_up():
	if readme_dir != "":
		if OS.shell_open(OS.get_executable_path().get_base_dir().plus_file(ProjectSettings.globalize_path(Globals.content_pack_path) + readme_dir)) != OK:
			print("Can't open manual directory.")

func _on_EpClearOkButton_button_up():
	show_level_select()

func _on_Button_button_up():
	if readme_dir != "":
		if OS.shell_open(feedback_url) != OK:
			print("Can't open feedback url")

func _on_CampaignSeedLE_text_changed(var new_text):
	pass
	#Globals.custom_difficulty["campaign_seed"] = new_text

func _on_CSBack_button_up():
	$"CampaignSetup".visible = false
	Globals.save_user_difficulty()

	match selected_ep:
		1:
			show_ep1()
		2:
			show_ep2()

func _on_DifficultyButton_item_selected(index):
	Globals.campaign_difficulty_idx = index
	show_difficulty_description(index)

func set_custom_setting_label_text(var node, var setting_name, var value):
	var base_value = Globals.campaign_difficulties[Globals.CAMPAIGN_DIFFICULTY_ID.NORMAL][setting_name]
	node.text = String(floor((value*100) / base_value)) + "%"

func _on_EFSlider_value_changed(new_value):
	Globals.campaign_difficulties[Globals.CAMPAIGN_DIFFICULTY_ID.CUSTOM]["enemy_firepower_scale"] = new_value
	set_custom_setting_label_text($"%EFValue", "enemy_firepower_scale", new_value)

func _on_PFSlider_value_changed(new_value):
	Globals.campaign_difficulties[Globals.CAMPAIGN_DIFFICULTY_ID.CUSTOM]["player_firepower_scale"] = new_value
	set_custom_setting_label_text($"%PFValue", "player_firepower_scale", new_value)
