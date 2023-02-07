extends Control

func create_map(var map_root):
	self.visible = true
	var base_offset = Vector2.ZERO

	var parent = $Root
	traverse_and_map(map_root, parent, base_offset)

func traverse_and_map(var map_node, var parent_control, var base_offset):
	var node = ColorRect.new()
	node.color = Color(0, 0, 0, 0.0)

	parent_control.add_child(node)

	node.size_flags_horizontal = SIZE_EXPAND_FILL
	node.size_flags_vertical = SIZE_EXPAND_FILL
	node.owner = parent_control.owner

	node.margin_left = -150 + base_offset.x
	node.margin_right = 150 + base_offset.x
	node.margin_top = -60 + base_offset.y
	node.margin_bottom = 60 + base_offset.y
	node.name = map_node.name

	var label = Label.new()
	label.text = map_node.name
	label.size_flags_vertical = SIZE_EXPAND_FILL
	node.add_child(label)
	label.owner = node.owner

	var children = map_node.get_children()

	#for c in children:
	for i in range (0, children.size()):
		var new_offset = Vector2.ZERO
		match i:
			0:
				new_offset = Vector2(0, 60)
			1:
				new_offset = Vector2(150, 0)
			2:
				new_offset = Vector2(300, 0)

		traverse_and_map(children[i], parent_control, base_offset + new_offset)

	# adjust whole thing?
	#$Root.rect_position.x = 0

func show():
	self.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide():
	self.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
