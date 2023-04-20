extends Node
class_name PlayerAnimations

export (float) var animation_lerp_speed = 6.0

var joy_input = Vector2()

var animation_tree : AnimationTree
var movement_node : PlayerMovement
var camera_node : Camera

var playing_slowmo = false

#zoom
var zooming_in = false
var base_fov
var base_sensitivity
var start_fov

const SLOWMO_TOTAL_TIME = 2.5
const MAX_FOV_MODIFIER = 0.75
const FOV_MODIF_PER_FRAME = 0.05

func _ready():
	animation_tree = $"../BodyCollision/LookHeight/LookDirection/AnimationTree"
	movement_node = $"../PlayerMovement"
	camera_node = $"../BodyCollision/LookHeight/LookDirection/WorldCamera"
	base_fov = camera_node.fov
	base_sensitivity = movement_node.mouse_sensitivity
	start_fov = camera_node.fov

func _process(delta):
	# blend movement animations
	var animation_input = 0

	if joy_input != Vector2.ZERO:
		animation_input = movement_node.get_desired_speed()

	animation_input = range_lerp(animation_input, 0, movement_node.run_speed, 0.0, 1.0)

	var current_blend_amount = animation_tree.get("parameters/WalkingBlend/blend_amount")

	animation_tree.set("parameters/WalkingBlend/blend_amount", lerp(current_blend_amount, animation_input, delta*animation_lerp_speed))

	# blend camera fov
	var current_walk_zoom_add = animation_tree.get("parameters/WalkZoom/add_amount")

	if zooming_in and not is_equal_approx(current_walk_zoom_add, 0.7):
		camera_node.fov = base_fov*MAX_FOV_MODIFIER
		movement_node.mouse_sensitivity = base_sensitivity*MAX_FOV_MODIFIER

		animation_tree.set("parameters/WalkZoom/add_amount", lerp(current_walk_zoom_add, 0.7, delta*animation_lerp_speed))

	elif not zooming_in and not is_equal_approx(current_walk_zoom_add, 0.0):
		camera_node.fov = base_fov
		movement_node.mouse_sensitivity = base_sensitivity

		animation_tree.set("parameters/WalkZoom/add_amount", lerp(current_walk_zoom_add, 0, delta*animation_lerp_speed))

func zoom_fov():
	zooming_in = true
	start_fov = camera_node.fov

func unzoom_fov():
	zooming_in = false
	start_fov = camera_node.fov

func _on_switch_input():
	# one shot switching animation
	animation_tree.set("parameters/SwitchGun/active", true)

func play_slowmo(var time):
	if not playing_slowmo:
		playing_slowmo = true
		Engine.time_scale = 0.4
		yield(get_tree().create_timer(time), "timeout")
		Engine.time_scale = 1.0
		playing_slowmo = false

