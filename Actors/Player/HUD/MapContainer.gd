extends PauseScreen

var layers : Array
var node_refs : Dictionary

const NODE_X_SIZE = 150
const NODE_Y_SIZE = 60

const COLOR_UNEXPLORED = Color(0.5, 0.5, 0.5)
const COLOR_EXPLORED = Color(0.25, 0.59, 0.75)
const COLOR_TREASURE = Color(0.88, 0.91, 0.42)
const COLOR_PLAYER = Color(0.73, 0.16, 0.16)
const COLOR_GOAL = Color(0.19, 0.70, 0.06)
const COLOR_LINK = Color(0.4, 0.4, 0.4)

const MINI_X_SCALE = 0.15
const MINI_Y_SCALE = 0.25
const MINI_MASK_WIDTH = 512

const DBG_CREATE_LABELS = false

enum MODE {
	HIDDEN,
	FULLSCREEN,
	MINI
}

var current_players_node
var node_material

var current_mode

func _ready():
	$"%UnexploredColorLegend".color = COLOR_UNEXPLORED
	$"%ExploredColorLegend".color = COLOR_EXPLORED
	$"%TreasureColorLegend".color = COLOR_TREASURE
	$"%PlayerColorLegend".color = COLOR_PLAYER

	node_material = CanvasItemMaterial.new()
	node_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	node_material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY

func update_map(var new_players_node : RoomGeometry, var now_visible_nodes : Array):
	# color previoud node
	current_players_node.color = COLOR_EXPLORED

	# color neighbour nodes
	for node in now_visible_nodes:
		if node == new_players_node:
			continue

		for child in node.children:
			if is_instance_valid(child):
				if is_key_and_active(child) or is_treasure_chest_and_active(child):
					node_refs[node.tree_ref].color = COLOR_TREASURE

				elif child is LevelExit or child is FakeExit:
					node_refs[node.tree_ref].color = COLOR_GOAL

	# color current node
	current_players_node = node_refs[new_players_node.tree_ref]
	current_players_node.color = COLOR_PLAYER

func is_key_and_active(var maybe_key):
	return maybe_key is ResourcePickup and maybe_key.visible and maybe_key.contents.has("r_keys")

func is_treasure_chest_and_active(var maybe_chest):
	return maybe_chest is TreasureChest and not maybe_chest.is_open

func _input(event):
	if current_mode == MODE.HIDDEN and event.is_action_pressed("ShowMap"):
		to_fullscreen()

	elif current_mode == MODE.FULLSCREEN and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ShowMap")):
		to_mini()

	elif current_mode == MODE.MINI and event.is_action_pressed("ShowMap"):
		to_hidden()

func to_fullscreen():
	self.show()
	current_mode = MODE.FULLSCREEN
	$BG1.visible = true
	node_material.light_mode = CanvasItemMaterial.LIGHT_MODE_NORMAL

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

	$BG2.visible = true

	$LegendMC.visible = false
	get_tree().set_input_as_handled()

func to_hidden():
	self.visible = false
	current_mode = MODE.HIDDEN

func create_map(var map_root):
	#center mask
	$Light2DMM.position = Vector2(OS.window_size.x / 2, OS.window_size.y / 2)
	$Light2DMM.scale = Vector2(OS.window_size.x / (MINI_MASK_WIDTH / 2), OS.window_size.y / (MINI_MASK_WIDTH / 2))

	flush_old_map()

	self.to_mini()

	create_nodes(map_root, 0)

	trim_layers()

	arrange_layers()

	connect_the_fuckers()

	current_players_node = layers[0][0]
	current_players_node.color = COLOR_PLAYER

func flush_old_map():
	$LinesContainer.free()
	var new_lines_container = Node2D.new()
	self.add_child(new_lines_container)
	new_lines_container.owner = self.owner
	new_lines_container.name = "LinesContainer"

	$Root.free()
	var new_root = Control.new()
	self.add_child(new_root)
	new_root.owner = self.owner
	new_root.name = "Root"

	new_root.anchor_right = 1
	new_root.anchor_bottom = 1

	node_refs = {}
	layers = []
	layers.resize(50)

	yield(get_tree(), "idle_frame")

func connect_the_fuckers():
	for key in node_refs.keys():
		var point_a = node_refs[key].rect_position + Vector2(NODE_X_SIZE/2, NODE_Y_SIZE/2)

		var as_string = String(key)
		var point_a_parent = as_string.substr(0, as_string.rfind("/"))

		if point_a_parent.find("starting_room") == -1:
			continue

		var point_b = node_refs[NodePath(point_a_parent)].rect_position + Vector2(NODE_X_SIZE/2, NODE_Y_SIZE/2)

		var line = Line2D.new()
		line.points = [point_a, point_b]

		$LinesContainer.add_child(line)
		line.owner = $LinesContainer.owner
		line.default_color = COLOR_LINK
		line.material = node_material

func arrange_layers():
	for y in range(0, layers.size()):
		var x_offset = $Root.rect_size.x / 2
		x_offset = $Root.rect_size.x / (layers[y].size() + 1)

		for x in range(0, layers[y].size()):
			layers[y][x].rect_position = Vector2(x_offset * (x+1) - NODE_X_SIZE / 2, NODE_Y_SIZE * 1.5 * (y+1))

func trim_layers():
	for i in range(0, layers.size()):
		if layers[i] == null:
			layers.resize(i)
			return

func create_nodes(var map_node, var layer_idx):
	if layers.size() == layer_idx:
		layers.resize(layers.size()+50)  # shouldn't be needed but still...

	var node = ColorRect.new()
	node.color = COLOR_UNEXPLORED

	node_refs[map_node.get_path()] = node

	$Root.add_child(node)

	if layers[layer_idx] == null:
		layers[layer_idx] = []

	layers[layer_idx].push_back(node)

	node.size_flags_horizontal = SIZE_EXPAND_FILL
	node.size_flags_vertical = SIZE_EXPAND_FILL
	node.owner = $Root.owner

	node.margin_left = -NODE_X_SIZE / 2
	node.margin_right = NODE_X_SIZE / 2
	node.margin_top = -NODE_Y_SIZE / 2
	node.margin_bottom = NODE_Y_SIZE / 2
	node.name = "color_rect_for_"+map_node.name
	node.material = node_material

	if DBG_CREATE_LABELS:
		var label = Label.new()
		label.text = map_node.name
		label.size_flags_vertical = SIZE_EXPAND_FILL
		node.add_child(label)
		label.owner = node.owner
		label.material = node_material

	var children = map_node.get_children()

	#for c in children:
	for i in range (0, children.size()):
		create_nodes(children[i], layer_idx + 1)

func restore():
	if current_mode != MODE.HIDDEN:
		self.visible = true
