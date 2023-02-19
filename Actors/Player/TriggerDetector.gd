extends Area

var visible_last = []

func flush_cache():
	visible_last = []

func get_and_show_neighbour(var target, var current_room):
	var visible_neighbour = get_node(target)
	visible_neighbour.move_to_offset()
	visible_neighbour.open_doors_except_to(current_room)
	return visible_neighbour

func _on_TriggerDetector_area_entered(area):
	var parent = area.get_parent()

	if parent is RoomGeometry:
		var mg = get_tree().get_current_scene().find_node("MapGenerator")
		if mg.is_generating():
			return

		var visible_now = []
		parent.open_doors()
		visible_now.push_back(parent)

		var links = parent.used_exits()

		for l in links:
			if l.has("target") and l["target"] != "outside":
				visible_now.push_back(get_and_show_neighbour(l["target"], parent))

		for i in range(0, visible_last.size()):
			if not visible_now.has(visible_last[i]):
				visible_last[i].move_away()

		visible_last = visible_now
		$"../".get_map_container().update_map(parent, visible_now)
