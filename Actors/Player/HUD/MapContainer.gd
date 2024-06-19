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

extends PauseScreen

var layers : Array
var node_refs : Dictionary

const NODE_X_MARGIN = 120
const NODE_Y_MARGIN = 60
const NODE_MIN_SIZE = 50

export (Color) var COLOR_UNEXPLORED = Color(0.5, 0.5, 0.5)
export (Color) var COLOR_EXPLORED = Color(0.25, 0.59, 0.75)
export (Color) var COLOR_TREASURE = Color(0.93, 0.470, 0.098)
export (Color) var COLOR_KEY = Color(0.88, 0.91, 0.42)
export (Color) var COLOR_PLAYER = Color(0.73, 0.16, 0.16)
export (Color) var COLOR_GOAL = Color(0.19, 0.70, 0.06)
export (Color) var COLOR_LINK = Color(0.4, 0.4, 0.4)

export (Texture) var IMAGE_CLEAR
export (Texture) var IMAGE_KEY
export (Texture) var IMAGE_TREASURE
export (Texture) var IMAGE_PLAYER
export (Texture) var IMAGE_EXIT
const ICON_MARGIN = 15

const MINI_X_SCALE = 0.15
const MINI_Y_SCALE = 0.2
const MINI_MASK_WIDTH = 512

const MAP_X_SCALE = 0.6

const MAP_MOVE_SPEED_X = 0.15
const MAP_MOVE_SPEED_Y = MAP_MOVE_SPEED_X * 1.777
const MAP_SCALE_SPEED = 0.2

const CONTROLS_TEXT = "Map controls:\n {KEY_FWD} / {KEY_BWD} / {KEY_LEFT} / {KEY_RIGHT} - move\n{KEY_RUN} / {KEY_CRAWL} - scale\n {KEY_QMELEE} - reset\n {KEY_MAP} - close"

const DBG_CREATE_LABELS = false

enum MODE {
	HIDDEN,
	FULLSCREEN,
	MINI
}

var current_players_node
var node_material

var current_mode
var last_resolution_x

func _ready():
	$"%UnexploredColorLegend".color = COLOR_UNEXPLORED
	$"%ExploredColorLegend".color = COLOR_EXPLORED
	$"%TreasureColorLegend".color = COLOR_TREASURE
	$"%KeyColorLegend".color = COLOR_KEY
	$"%PlayerColorLegend".color = COLOR_PLAYER
	$"%ExitColorLegend".color = COLOR_GOAL

	$"%TextureRectExplored".texture = IMAGE_CLEAR
	$"%TextureRectTreasure".texture = IMAGE_TREASURE
	$"%TextureRectKey".texture = IMAGE_KEY
	$"%TextureRectPlayer".texture = IMAGE_PLAYER
	$"%TextureRectGoal".texture = IMAGE_EXIT

	node_material = CanvasItemMaterial.new()
	node_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	node_material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY

	$ControlsMC/RichTextLabel.text = CONTROLS_TEXT.format(InputHelper.get_input_string_formatting())

func create_map(var map_root):
	reset_mask_position()

	last_resolution_x = OS.window_size.x

	flush_old_map()

	self.to_mini()

	create_nodes(map_root, 0)

	trim_layers()

	arrange_layers()

	connect_the_fuckers()

	current_players_node = layers[0][0]
	current_players_node.color = COLOR_PLAYER

func reset_mask_position():
	$Light2DMM.position = Vector2(OS.window_size.x / 2, OS.window_size.y / 2)
	$Light2DMM.scale = Vector2(OS.window_size.x / (MINI_MASK_WIDTH / 2), OS.window_size.y / (MINI_MASK_WIDTH / 2))

func flush_old_map():
	var new_lines_container = recreate_lines_container()
	var new_root = recreate_node_root()

	new_root.anchor_right = 1
	new_root.anchor_bottom = 1

	node_refs = {}
	layers = []
	layers.resize(50)

	yield(get_tree(), "idle_frame")

func recreate_lines_container():
	$GenCont/LinesContainer.free()
	var new_lines_container = Node2D.new()
	$GenCont.add_child(new_lines_container)
	new_lines_container.owner = self.owner
	new_lines_container.name = "LinesContainer"
	return new_lines_container

func recreate_node_root():
	$GenCont/Root.free()
	var new_root = Control.new()
	$GenCont.add_child(new_root)
	new_root.owner = self.owner
	new_root.name = "Root"
	return new_root

func create_nodes(var map_node, var layer_idx):
	if layers.size() == layer_idx:
		layers.resize(layers.size()+50)  # shouldn't be needed but still...

	var node = ColorRect.new()
	node.color = COLOR_UNEXPLORED

	node_refs[map_node.get_path()] = node

	$GenCont/Root.add_child(node)

	if layers[layer_idx] == null:
		layers[layer_idx] = []

	layers[layer_idx].push_back(node)

	node.size_flags_horizontal = SIZE_EXPAND_FILL
	node.size_flags_vertical = SIZE_EXPAND_FILL
	node.owner = $GenCont/Root.owner

	node.name = "color_rect_for_"+map_node.name
	node.material = node_material

	if DBG_CREATE_LABELS:
		var label = Label.new()
		label.text = map_node.name
		label.size_flags_vertical = SIZE_EXPAND_FILL
		node.add_child(label)
		label.owner = node.owner
		label.material = node_material

	var margin = MarginContainer.new()
	margin.name = "MC"
	margin.set("custom_constants/margin_right", ICON_MARGIN)
	margin.set("custom_constants/margin_top", ICON_MARGIN)
	margin.set("custom_constants/margin_left", ICON_MARGIN)
	margin.set("custom_constants/margin_bottom", ICON_MARGIN)
	margin.size_flags_vertical = SIZE_EXPAND_FILL
	margin.size_flags_horizontal = SIZE_EXPAND_FILL

	node.add_child(margin)
	margin.anchor_right = 1
	margin.anchor_bottom = 1
	margin.owner = node.owner

	var texture_rect = TextureRect.new()
	texture_rect.name = "TR"
	texture_rect.size_flags_vertical = SIZE_EXPAND_FILL
	texture_rect.size_flags_horizontal = SIZE_EXPAND_FILL
	texture_rect.expand = true
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	margin.add_child(texture_rect)
	texture_rect.owner = margin.owner

	var children = map_node.get_children()

	#for c in children:
	for i in range (0, children.size()):
		create_nodes(children[i], layer_idx + 1)

func trim_layers():
	for i in range(0, layers.size()):
		if layers[i] == null:
			layers.resize(i)
			return

func arrange_layers():
	reset_node_size($GenCont/Root, $GenCont/LinesContainer)

	for y in range(0, layers.size()):
		var x_offset = $GenCont/Root.rect_size.x / 2
		x_offset = $GenCont/Root.rect_size.x / (layers[y].size() + 1)

		var y_offset = $GenCont/Root.rect_size.y / 2
		y_offset = $GenCont/Root.rect_size.y / (layers.size() + 1)

		for x in range(0, layers[y].size()):
			layers[y][x].rect_position = Vector2(x_offset * (x+1) - NODE_X_MARGIN / 2, y_offset * (y+1) - NODE_Y_MARGIN / 2)

func reset_node_size(var root_node, var lines_node):
	#return
	var max_nodes_in_layer = 0
	for layer in layers:
		max_nodes_in_layer = max(layer.size(), max_nodes_in_layer)

	var max_node_width = max($GenCont/Root.rect_size.x / (max_nodes_in_layer + 3), NODE_MIN_SIZE)
	var max_node_height = max($GenCont/Root.rect_size.y / (layers.size() + 3), NODE_MIN_SIZE)

	for node_key in node_refs.keys():
		node_refs[node_key].margin_left = -max_node_width / 2
		node_refs[node_key].margin_right = max_node_width / 2
		node_refs[node_key].margin_top = -max_node_height / 2
		node_refs[node_key].margin_bottom = max_node_height / 2

func reset_node_position_scale():
	$GenCont/Root.rect_position = Vector2.ZERO
	$GenCont/LinesContainer.position = Vector2.ZERO
	$GenCont/Root.rect_scale = Vector2.ONE
	$GenCont/LinesContainer.scale = Vector2.ONE
	for node_key in node_refs.keys():
		node_refs[node_key].rect_scale = Vector2.ONE

func connect_the_fuckers():
	for key in node_refs.keys():
		var node_a = node_refs[key]
		var point_a = Vector2(
			(node_a.margin_left + node_a.margin_right) / 2,
			(node_a.margin_top + node_a.margin_bottom) / 2)

		var as_string = String(key)
		var point_a_parent = as_string.substr(0, as_string.rfind("/"))

		if point_a_parent.find("starting_room") == -1:
			continue

		var node_b = node_refs[NodePath(point_a_parent)]
		var point_b = Vector2(
			(node_b.margin_left + node_b.margin_right) / 2,
			(node_b.margin_top + node_b.margin_bottom) / 2)

		var line = Line2D.new()
		line.points = [point_a, point_b]

		$GenCont/LinesContainer.add_child(line)
		line.owner = $GenCont/LinesContainer.owner
		line.default_color = COLOR_LINK
		line.material = node_material

func update_map(var new_players_node : RoomGeometry, var now_visible_nodes : Array):
	# color previoud node
	current_players_node.color = COLOR_EXPLORED
	current_players_node.get_node("MC/TR").texture = IMAGE_CLEAR

	# color neighbour nodes
	for node in now_visible_nodes:
		if node == new_players_node:
			continue

		for child in node.children:
			if is_instance_valid(child):
				if is_key_and_active(child):
					node_refs[node.tree_ref].color = COLOR_KEY
					node_refs[node.tree_ref].get_node("MC/TR").texture = IMAGE_KEY

				elif is_treasure_chest_and_active(child):
					node_refs[node.tree_ref].color = COLOR_TREASURE
					node_refs[node.tree_ref].get_node("MC/TR").texture = IMAGE_TREASURE

				elif child is LevelExit or child is FakeExit:
					node_refs[node.tree_ref].color = COLOR_GOAL
					node_refs[node.tree_ref].get_node("MC/TR").texture = IMAGE_EXIT

	# color current node
	current_players_node = node_refs[new_players_node.tree_ref]
	current_players_node.color = COLOR_PLAYER
	current_players_node.get_node("MC/TR").texture = IMAGE_PLAYER

func _input(event):
	if $"../InputProxy".is_locked:
		return

	if current_mode == MODE.HIDDEN and event.is_action_pressed("Show Map"):
		to_fullscreen()

	elif current_mode == MODE.FULLSCREEN and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("Show Map")):
		to_mini()

	elif current_mode == MODE.MINI and event.is_action_pressed("Show Map"):
		to_hidden()

func _process(delta):
	if current_mode == MODE.FULLSCREEN:
		if Input.is_action_pressed("Forward") or Input.is_action_pressed("ui_up"):
			$GenCont/Root.rect_position.y -= OS.window_size.y * MAP_MOVE_SPEED_Y * delta
			$GenCont/LinesContainer.position.y -= OS.window_size.y * MAP_MOVE_SPEED_Y * delta
		if Input.is_action_pressed("Backwards") or Input.is_action_pressed("ui_down"):
			$GenCont/Root.rect_position.y += OS.window_size.y * MAP_MOVE_SPEED_Y * delta
			$GenCont/LinesContainer.position.y += OS.window_size.y * MAP_MOVE_SPEED_Y * delta
		if Input.is_action_pressed("Strafe Left") or Input.is_action_pressed("ui_left"):
			$GenCont/Root.rect_position.x -= OS.window_size.x * MAP_MOVE_SPEED_X * delta
			$GenCont/LinesContainer.position.x -= OS.window_size.x * MAP_MOVE_SPEED_X * delta
		if Input.is_action_pressed("Strafe Right") or Input.is_action_pressed("ui_right"):
			$GenCont/Root.rect_position.x += OS.window_size.x * MAP_MOVE_SPEED_X * delta
			$GenCont/LinesContainer.position.x += OS.window_size.x * MAP_MOVE_SPEED_X * delta
		if Input.is_action_pressed("Run"):
			scale_nodes(MAP_SCALE_SPEED, delta)
		if Input.is_action_pressed("Crawl"):
			scale_nodes(-MAP_SCALE_SPEED, delta)
		if Input.is_action_just_pressed("Quick Melee"):
			reset_node_position_scale()

func scale_nodes(var direction, var delta):
	for node_key in node_refs.keys():
		node_refs[node_key].rect_scale.x -= direction * delta
		node_refs[node_key].rect_scale.y -= direction * delta
	$GenCont/Root.rect_scale.x += direction * delta
	$GenCont/Root.rect_scale.y += direction * delta
	$GenCont/LinesContainer.scale.x += direction * delta
	$GenCont/LinesContainer.scale.y += direction * delta

func is_key_and_active(var maybe_key):
	return maybe_key is ResourcePickup and maybe_key.visible and maybe_key.contents.has("r_keys")

func is_treasure_chest_and_active(var maybe_chest):
	return maybe_chest is TreasureChest and not maybe_chest.is_open

func to_fullscreen():
	self.show()
	current_mode = MODE.FULLSCREEN
	$BG1.visible = true
	node_material.light_mode = CanvasItemMaterial.LIGHT_MODE_NORMAL
	$ControlsMC/RichTextLabel.visible = true

	$BG2.visible = false

	$LegendMC.visible = true
	self.rect_position = Vector2.ZERO
	self.rect_scale = Vector2.ONE
	self.show()
	get_tree().set_input_as_handled()

func to_mini():
	# unlock controls
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = true

	# modify
	current_mode = MODE.MINI
	var x_offset = self.rect_size.x - self.rect_size.x*MINI_X_SCALE
	var y_offset = self.rect_size.y / 2 - self.rect_size.y*MINI_Y_SCALE
	self.rect_position = Vector2(x_offset, y_offset)
	self.rect_scale = Vector2(MINI_X_SCALE, MINI_Y_SCALE)

	$BG1.visible = false
	node_material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	$ControlsMC/RichTextLabel.visible = false

	$BG2.visible = true

	$LegendMC.visible = false
	get_tree().set_input_as_handled()

func to_hidden():
	self.visible = false
	current_mode = MODE.HIDDEN

func restore():
	if current_mode == MODE.MINI:
		if not is_equal_approx(OS.window_size.x, last_resolution_x):
			last_resolution_x = OS.window_size.x
			var lc = recreate_lines_container()
			var root = $GenCont/Root
			$GenCont.remove_child(root)
			$GenCont.add_child(root)
			reset_node_position_scale()
			reset_mask_position()
			arrange_layers()
			connect_the_fuckers()

		to_mini()
