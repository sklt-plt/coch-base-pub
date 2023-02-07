extends Camera

func flash_cache_objects():
	#flash objects infront of player to compile shaders
	var cache = get_node_or_null("/root/ObjectCache")
	if not cache:
		print("Warning: not found node '/root/ObjectCache', can't precompile shaders")
		hide_loading()
		return

	get_tree().paused = true

	#borrow it from root
	for c in cache.children_cache:
		self.add_child(c)

	yield(get_tree(), "idle_frame")

	for c in cache.children_cache:
		self.remove_child(c)

	hide_loading()

func hide_loading():
	#get_tree().paused = false
	$"/root/Player".hide_loading()

