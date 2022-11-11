extends Node
class_name PlayerStartingEquipment

export var starting_resources = {
	"r_health" : 30,
}

func _ready():
	print("Giving player one key to start the level")
	$"/root/Player".give("r_keys", 1)

	for sr in starting_resources:
		var current_amount = $"/root/Player".check(sr)
		$"/root/Player".give(sr, max(0, starting_resources[sr]-current_amount))
