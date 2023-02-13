extends Control

var layers : Array
var node_refs : Dictionary

const NODE_X_SIZE = 150
const NODE_Y_SIZE = 60

const COLOR_UNEXPLORED = Color(0.35, 0.35, 0.35)
const COLOR_EXPLORED = Color(0.25, 0.59, 0.75)
const COLOR_TREASURE = Color(0.88, 0.91, 0.42)
const COLOR_PLAYER = Color(0.73, 0.16, 0.16)
const COLOR_LINK = Color(0.25, 0.25, 0.25)

func _ready():
	$"%UnexploredColorLegend".color = COLOR_UNEXPLORED
	$"%ExploredColorLegend".color = COLOR_EXPLORED
	$"%TreasureColorLegend".color = COLOR_TREASURE
	$"%PlayerColorLegend".color = COLOR_PLAYER

func create_map(var map_root):
	node_refs = {}
	layers = []
	layers.resize(50)

	self.visible = true

	create_nodes(map_root, 0)

	trim_layers()

	arrange_layers()

	connect_the_fuckers()

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

	var label = Label.new()
	label.text = map_node.name
	label.size_flags_vertical = SIZE_EXPAND_FILL
	node.add_child(label)
	label.owner = node.owner

	var children = map_node.get_children()

	#for c in children:
	for i in range (0, children.size()):
		create_nodes(children[i], layer_idx + 1)

func show():
	self.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide():
	self.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
