extends Spatial
class_name BossSpawn
tool

enum Variants {
	Static,
	Flying
}

export (PackedScene) var boss_scene
export (Variants) var variant = 0

var spawned = false
var spawn_translation

func _ready():
	if variant == Variants.Static:
		spawn_static_boss()

func spawn_static_boss():
	#spawn static scene instance aligned to (and facing) center of the room
	var instance = boss_scene.instance() as Spatial

	get_parent().get_parent().add_child(instance)
	instance.owner = get_parent().get_parent().owner

	var room_geometry = get_parent()

	instance.global_transform.origin = room_geometry.global_transform.origin + Vector3((room_geometry.size.x/2), 0, (room_geometry.size.z/2))

	#find entrance to rotate instance towards to
	var exits = room_geometry.used_exits()
	var dir = -1

	for e in exits:
		if e["target"] == get_node(room_geometry.tree_ref).get_parent().geometry:
			dir = e["direction"]

	if dir == -1:
		return

	match dir:
		0:
			instance.translate_object_local(Vector3(0,0,room_geometry.size.z/2))
		1:
			instance.rotation_degrees.y += 180
			instance.translate_object_local(Vector3(0,0,room_geometry.size.z/2))
		2:
			instance.rotation_degrees.y += 90
			instance.translate_object_local(Vector3(0,0,room_geometry.size.x/2))
		3:
			instance.rotation_degrees.y -= 90
			instance.translate_object_local(Vector3(0,0,room_geometry.size.x/2))

	instance.scale = Vector3(24,24,24)

func on_room_cull_in():
	if variant == Variants.Static:
		return  # nothing to do

	spawn_translation = self.global_translation
	$VisibilityCheckTimer.start()

func _on_VisibilityCheckTimer_timeout():
	if self.is_inside_tree() and variant == Variants.Flying:
		spawn_flying_boss()

func spawn_flying_boss():
	if spawned:
		return

	spawned = true
	var boss = boss_scene.instance()
	boss.name = "boss"
	get_tree().current_scene.add_child(boss)
	boss.global_translation = spawn_translation
	boss.owner = self.owner
	boss.begin_state(1)
