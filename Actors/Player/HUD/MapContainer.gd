extends Control

var layers
var node_refs

const NODE_X_SIZE = 150
const NODE_Y_SIZE = 60

const COLOR_UNEXPLORED = Color(0.375, 0.372831, 0.343546)

func create_map(var map_root):
	node_refs = []
	layers = []
	layers.resize(50)

	self.visible = true

	create_nodes(map_root, 0)

	trim_layers()

	arrange_layers()

	#connect the fuckers

	for ref in node_refs:
		print(ref)

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

	node_refs.push_back({map_node.get_path() : node})

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
	node.name = "color_rect_for"+map_node.name

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
