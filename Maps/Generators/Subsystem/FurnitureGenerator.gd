extends Node
class_name FurnitureGenerator
tool

export (PackedScene) var _randomizable_objects

var _rando_objects : Spatial
var _rng : RandomNumberGenerator

var _entities_collection = []

func reset(var rng: RandomNumberGenerator):
	if _randomizable_objects:
		_rando_objects = _randomizable_objects.instance()

	_rng = rng

func get_furniture_sizes():
	#look over all children of rando_objects
	var sizes = []

	for c in _rando_objects.get_children():
		sizes.push_back(c.size)

	return sizes

func get_randomized_furniture(var child_id: int):
	if _rando_objects:
		var ret = {"root": get_elements(_rando_objects.get_child(child_id)), "entities" : _entities_collection.duplicate()}
		_entities_collection = []
		return ret
	else:
		print("No randomizable objects provided!")
		return null

func get_elements(var root):
	var parent
	# assumptions:
	# furniture object = root of roots
	# CollisionObject = take whole with children
	# FurnitureElements = take one
	# MeshInstance or Spatial = copy and iterate over children
	if root is FurnitureObject:
		parent = FurnitureObject.new()
		parent.size = root.size
	elif root is KinematicEnemy or root is TreasureChest:
		parent = FurnitureEntitySpawn.new()
		parent.translation = root.translation
		parent.rotation = root.rotation
		parent.ref = root.duplicate()
		_entities_collection.push_back(parent)
		return parent
	elif root is CollisionObject:
		parent = root.duplicate()
		return parent
		parent.translation = root.translation
		parent.rotation = root.rotation
	elif root is MeshInstance:
		parent = MeshInstance.new()
		parent.mesh = root.mesh
		parent.translation = root.translation
		parent.rotation = root.rotation
		parent.scale = root.scale
	elif root is Spatial:
		parent = Spatial.new()
		parent.translation = root.translation
		parent.rotation = root.rotation
		parent.scale = root.scale

	parent.name = root.name

	var children = root.get_children()

	if root is FurnitureElements:
		# take one
		parent.add_child(get_elements(children[_rng.randi()%children.size()]))
	else:
		# take all
		for child in children:
			if child.get_child_count() > 0:
				parent.add_child(get_elements(child))
			else:
				parent.add_child(child.duplicate())

	return parent
