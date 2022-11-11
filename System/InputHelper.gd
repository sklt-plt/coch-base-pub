extends Node
class_name InputHelper

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
