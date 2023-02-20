extends Control

signal exited

var display_mode_option : OptionButton
var resolution_label : Label
var resolution_spin_box : SpinBox
var vsync_button : CheckButton
var max_fps_label : Label
var max_fps_slider : Slider
var aa_option : OptionButton
var sharpening_label : Label
var sharpening_slider : Slider
var shadows_button : CheckButton
var shadows_warning : TextureRect
var ao_button : CheckButton
var fov_label : Label
var fov_slider : Slider

#audio
var master_volume_label : Label
var master_volume_slider : Slider
var music_volume_label : Label
var music_volume_slider : Slider
var effects_volume_label : Label
var effects_volume_slider : Slider

#player controls
var mouse_sens_spin_box : SpinBox
var invert_mouse_box: CheckBox
var toggle_aim_check_box : CheckBox
var toggle_run_check_box : CheckBox
var invert_run_label : Label
var invert_run_check_box : CheckBox

var move_forward_button : Button
var move_backwards_button : Button
var strafe_left_button : Button
var strafe_right_button : Button
var interact_button : Button
var jump_button : Button
var crawl_button : Button
var run_button : Button
var fire_button : Button
var alt_fire_button : Button
var qmelee_button: Button
var srevolver_button : Button
var sshotgun_button : Button
var scrossbow_button : Button
var smelee_button : Button
var snext_button : Button
var sprev_button : Button
var map_button : Button

#misc
var legacy_campaign_cb: Button

func _ready():
	#get control nodes
	display_mode_option = $"TC/Video/SC/GC/DisplayModeOption"
	resolution_spin_box = $"TC/Video/SC/GC/ResolutionScaleSpinBox"
	resolution_label = $"TC/Video/SC/GC/ResolutionScaleLabel"
	vsync_button = $"TC/Video/SC/GC/VSyncButton"
	max_fps_label = $"TC/Video/SC/GC/MaxFPSHBox/CurrentLabel"
	max_fps_slider = $"TC/Video/SC/GC/MaxFPSHBox/MaxFPSSlider"
	aa_option = $"TC/Video/SC/GC/AntialiasingOption"
	sharpening_label = $"TC/Video/SC/GC/SharpenGC/SharpenVal"
	sharpening_slider = $"TC/Video/SC/GC/SharpenGC/SharpenSlider"
	shadows_button = $"TC/Video/SC/GC/ShadowsButton"
	shadows_warning = $"TC/Video/SC/GC/ShadowsWarning"
	ao_button = $"TC/Video/SC/GC/AOButton"
	fov_label = $"TC/Video/SC/GC/FOVHBox/CurrentLabel"
	fov_slider = $"TC/Video/SC/GC/FOVHBox/FOVSlider"

	master_volume_label = $"TC/Audio/SC/GC/MasterVolumeVal"
	master_volume_slider = $"TC/Audio/SC/GC/MasterVolumeSlider"
	music_volume_label = $"TC/Audio/SC/GC/MusicVolumeVal"
	music_volume_slider = $"TC/Audio/SC/GC/MusicVolumeSlider"
	effects_volume_label = $"TC/Audio/SC/GC/EffectsVolumeVal"
	effects_volume_slider = $"TC/Audio/SC/GC/EffectsVolumeSlider"

	mouse_sens_spin_box = $"TC/Controls/SC/GC/MouseSensSpinBox"
	invert_mouse_box = $"TC/Controls/SC/GC/InvertMouseBox"
	toggle_aim_check_box = $"TC/Controls/SC/GC/ToggleAimBox"
	toggle_run_check_box = $"TC/Controls/SC/GC/ToggleRunBox"
	invert_run_label = $"TC/Controls/SC/GC/InvertRunLabel"
	invert_run_check_box = $"TC/Controls/SC/GC/InvertRunBox"

	move_forward_button = $"TC/Controls/SC/GC/MoveForwardButton"
	move_backwards_button = $"TC/Controls/SC/GC/MoveBackwardsButton"
	strafe_left_button = $"TC/Controls/SC/GC/StrafeLeftButton"
	strafe_right_button = $"TC/Controls/SC/GC/StrafeRightButton"
	interact_button = $"TC/Controls/SC/GC/InteractButton"
	jump_button = $"TC/Controls/SC/GC/JumpButton"
	crawl_button = $"TC/Controls/SC/GC/CrawlButton"
	run_button = $"TC/Controls/SC/GC/RunButton"
	fire_button = $"TC/Controls/SC/GC/FireButton"
	alt_fire_button = $"TC/Controls/SC/GC/AltFireButton"
	qmelee_button = $"TC/Controls/SC/GC/QMeleeButton"
	srevolver_button = $"TC/Controls/SC/GC/SRevolverButton"
	sshotgun_button = $"TC/Controls/SC/GC/SShotgunButton"
	scrossbow_button = $"TC/Controls/SC/GC/SCrossbowButton"
	smelee_button = $"TC/Controls/SC/GC/SMeleeButton"
	snext_button = $"TC/Controls/SC/GC/SNextButton"
	sprev_button = $"TC/Controls/SC/GC/SPrevButton"
	map_button = $"TC/Controls/SC/GC/MapButton"

	legacy_campaign_cb = $"TC/Misc/SC/GC/LegacyCampaignCB"

func _on_Options_visibility_changed():
	if self.visible:
		#get globals here
		var user_settings = $"/root/Globals".user_settings

		#update boxes and values
		display_mode_option.selected = user_settings["screen_mode"]
		resolution_label.text = "Resolution Scale" if user_settings["screen_mode"] == 0 else "Window Size Scale"
		resolution_spin_box.value = user_settings["resolution"]
		vsync_button.pressed = user_settings["vsync"]
		max_fps_label.text = "Max" if user_settings["max_fps"] == 0 else String(user_settings["max_fps"])
		max_fps_slider.value = user_settings["max_fps"]
		aa_option.selected = user_settings["antialiasing"]
		sharpening_label.text = String(user_settings["sharpening"])
		sharpening_slider.value = user_settings["sharpening"]
		shadows_button.pressed = user_settings["shadows"]
		shadows_warning.set_h_size_flags(SIZE_FILL*int(user_settings["shadows"])+SIZE_EXPAND)
		ao_button.pressed = user_settings["ao"]
		fov_label.text = String(user_settings["fov"])
		fov_slider.value = user_settings["fov"]

		master_volume_label.text = String(user_settings["master_volume"]*100)
		master_volume_slider.value = user_settings["master_volume"]
		music_volume_label.text = String(user_settings["music_volume"]*100)
		music_volume_slider.value = user_settings["music_volume"]
		effects_volume_label.text = String(user_settings["effects_volume"]*100)
		effects_volume_slider.value = user_settings["effects_volume"]

		mouse_sens_spin_box.value = user_settings["mouse_sensitivity"]
		invert_mouse_box.pressed = user_settings["invert_mouse_y"]
		toggle_aim_check_box.pressed = user_settings["toggle_aim"]
		toggle_run_check_box.pressed = user_settings["toggle_run"]

		invert_run_check_box.pressed = user_settings["invert_run"]
		invert_run_check_box.visible = not toggle_run_check_box.pressed
		invert_run_label.visible = not toggle_run_check_box.pressed

		legacy_campaign_cb.pressed = user_settings["legacy_campaign"]

		set_all_input_buttons_texts()

func set_all_input_buttons_texts():
	move_forward_button.text = InputHelper.get_input_buttons_text("Forward")
	move_backwards_button.text = InputHelper.get_input_buttons_text("Backwards")
	strafe_left_button.text = InputHelper.get_input_buttons_text("Strafe Left")
	strafe_right_button.text = InputHelper.get_input_buttons_text("Strafe Right")
	interact_button.text = InputHelper.get_input_buttons_text("Interact")
	jump_button.text = InputHelper.get_input_buttons_text("Jump")
	crawl_button.text = InputHelper.get_input_buttons_text("Crawl")
	run_button.text = InputHelper.get_input_buttons_text("Run")
	fire_button.text = InputHelper.get_input_buttons_text("Fire")
	alt_fire_button.text = InputHelper.get_input_buttons_text("Aim")
	qmelee_button.text = InputHelper.get_input_buttons_text("Quick Melee")
	srevolver_button.text = InputHelper.get_input_buttons_text("Select Revolver")
	sshotgun_button.text = InputHelper.get_input_buttons_text("Select Shotgun")
	scrossbow_button.text = InputHelper.get_input_buttons_text("Select Crossbow")
	smelee_button.text = InputHelper.get_input_buttons_text("Select Melee")
	snext_button.text = InputHelper.get_input_buttons_text("Select Next")
	sprev_button.text = InputHelper.get_input_buttons_text("Select Prev")
	map_button.text = InputHelper.get_input_buttons_text("Show Map")

func _on_DisplayModeOption_item_selected(index):
	var new_settings = {"screen_mode" : index}
	resolution_label.text = "Resolution Scale" if index == 0 else "Window Size Scale"
	Globals.apply_user_settings(new_settings)

func _on_ResolutionScaleSpinBox_value_changed(value):
	var new_settings = {"resolution" : value}
	Globals.apply_user_settings(new_settings)

func _on_VSyncButton_toggled(button_pressed):
	var new_settings = {"vsync" : button_pressed}
	Globals.apply_user_settings(new_settings)

func _on_MaxFPSSlider_value_changed(value):
	max_fps_label.text = "Max" if value == 0 else String(value)
	var new_settings = {"max_fps" : value}
	Globals.apply_user_settings(new_settings)

func _on_AntialiasingOption_item_selected(index):
	var new_settings = {"antialiasing" : index}
	Globals.apply_user_settings(new_settings)

func _on_SharpenSlider_value_changed(value):
	sharpening_label.text = String(value)
	var new_settings = {"sharpening" : value}
	Globals.apply_user_settings(new_settings)

func _on_ShadowsButton_toggled(button_pressed):
	shadows_warning.set_h_size_flags(SIZE_FILL*int(button_pressed)+SIZE_EXPAND)
	var new_settings = {"shadows" : button_pressed}
	Globals.apply_user_settings(new_settings)

func _on_AOButton_toggled(button_pressed):
	var new_settings = {"ao" : button_pressed}
	Globals.apply_user_settings(new_settings)

func _on_FOVSlider_value_changed(value):
	fov_label.text = String(value)
	var new_settings = {"fov" : value}
	Globals.apply_user_settings(new_settings)
	$"/root/Player/PlayerAnimations".base_fov = value

func _on_MasterVolumeSlider_value_changed(value):
	master_volume_label.text = String(value*100)
	var new_settings = {"master_volume" : value}
	Globals.apply_user_settings(new_settings)

func _on_MusicVolumeSlider_value_changed(value):
	music_volume_label.text = String(value*100)
	var new_settings = {"music_volume" : value}
	Globals.apply_user_settings(new_settings)

func _on_EffectsVolumeSlider_value_changed(value):
	effects_volume_label.text = String(value*100)
	var new_settings = {"effects_volume" : value}
	Globals.apply_user_settings(new_settings)

func _on_MouseSensSpinBox_value_changed(value):
	var new_settings = {"mouse_sensitivity" : value}
	Globals.apply_user_settings(new_settings)

func _on_InvertMouseBox_toggled(button_pressed):
	var new_settings = {"invert_mouse_y": button_pressed}
	Globals.apply_user_settings(new_settings)

func _on_ToggleAimBox_toggled(button_pressed):
	var new_settings = {"toggle_aim" : button_pressed}
	Globals.apply_user_settings(new_settings)

func _on_ToggleRunBox_toggled(button_pressed):
	var new_settings = {"toggle_run" : button_pressed}
	Globals.apply_user_settings(new_settings)

	invert_run_check_box.visible = not toggle_run_check_box.pressed
	invert_run_label.visible = not toggle_run_check_box.pressed

func _on_InvertRunBox_toggled(button_pressed):
	var new_settings = {"invert_run" : button_pressed}
	Globals.apply_user_settings(new_settings)

func _on_ApplySettingsButton_button_up():
	#save settings
	#not technically apply, but imo it sounds better
	Globals.save_user_settings()
	Globals.save_user_inputs()
	visible = false
	emit_signal("exited")

func _on_DiscardSettingsButton_button_up():
	Globals.load_user_settings()
	Globals.load_user_inputs()
	visible = false
	emit_signal("exited")

func _on_InputSetter_set_action(action):
	set_all_input_buttons_texts()

func _on_LegacyCampaignCB_toggled(button_pressed):
	var new_settings = {"legacy_campaign" : button_pressed}
	Globals.apply_user_settings(new_settings)

