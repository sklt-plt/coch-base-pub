extends Node
class_name InputHelper

static func get_input_string_formatting():
	var formatting = {
	"KEY_FWD": get_input_buttons_text("Forward").to_upper(),
	"KEY_BWD": get_input_buttons_text("Backwards").to_upper(),
	"KEY_LEFT": get_input_buttons_text("Strafe Left").to_upper(),
	"KEY_RIGHT": get_input_buttons_text("Strafe Right").to_upper(),
	"KEY_USE": get_input_buttons_text("Interact").to_upper(),
	"KEY_JUMP": get_input_buttons_text("Jump").to_upper(),
	"KEY_CRAWL": get_input_buttons_text("Crawl").to_upper(),
	"KEY_RUN": get_input_buttons_text("Run").to_upper(),
	"KEY_FIRE": get_input_buttons_text("Fire").to_upper(),
	"KEY_ALTFIRE": get_input_buttons_text("Aim").to_upper(),
	"KEY_QMELEE": get_input_buttons_text("Quick Melee").to_upper(),
	"KEY_MAP": get_input_buttons_text("Show Map").to_upper(),
	"KEY_SEL0": get_input_buttons_text("Select Melee").to_upper(),
	"KEY_SEL1": get_input_buttons_text("Select Revolver").to_upper(),
	"KEY_SEL2": get_input_buttons_text("Select Shotgun").to_upper(),
	"KEY_SEL3": get_input_buttons_text("Select Crossbow").to_upper(),
	"KEY_SELN": get_input_buttons_text("Select Next").to_upper(),
	"KEY_SELP": get_input_buttons_text("Select Prev").to_upper()}

	return formatting

static func set_input(var action : String, var event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)

static func get_input_buttons_text(var action : String):
	var event = InputMap.get_action_list(action)[0]
	if event is InputEventKey:
		return InputMap.get_action_list(action)[0].as_text()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			return "M. Wheel Down"
		elif event.button_index == BUTTON_WHEEL_UP:
			return "M. Wheel Up"
		else:
			return "Mouse "+String(event.button_index)
	else:
		return ""
