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

extends Interactable
class_name TreasureChest

const LID_LAUNCH_MAX_FORCE = 2.0

var is_open = false
export (bool) var give_weapon = false

export (Array, Dictionary) var powerups = [
	{"path": "/Ent/Interactable/Powerups/HealthPowerup.tscn", "resource_name": "r_health"},
	{"path": "/Ent/Interactable/Powerups/ArmorPowerup.tscn", "resource_name": "r_armor"},
	{"path": "/Ent/Interactable/Powerups/AmmoPowerup.tscn", "resource_name": "ammo_bonus_cap"}
]

export (Array, Dictionary) var gun_powerups = [
	{"path": "/Ent/Interactable/Powerups/ShotgunPowerup.tscn", "resource_name": "e_double_barrel_level"},
	{"path": "/Ent/Interactable/Powerups/CrossbowPowerup.tscn", "resource_name": "e_crossbow_level"}
]

var spawn_pos

func _ready():
	spawn_pos = get_node("ItemSpawnPos")

	for i in range(0, powerups.size()):
		powerups[i]["ref"] = load(Globals.content_pack_path + powerups[i]["path"])
	for i in range(0, gun_powerups.size()):
		gun_powerups[i]["ref"] = load(Globals.content_pack_path + gun_powerups[i]["path"])

	$"/root/Player".give("s_treasure_possible", 1)

func activate():
	is_open = true
	#"animate" lid with physics
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$Lid.launch(rng, LID_LAUNCH_MAX_FORCE, LID_LAUNCH_MAX_FORCE)

	#delete user prompt
	$Trigger.collision_layer = 0
	$Trigger.collision_mask = 0
	$HitTrig.collision_layer = 0
	$HitTrig.collision_mask = 0

	#delete light
	$OmniLight.queue_free()

	#collect only legal powerups for spawning
	var allowed_powerups = []

	if give_weapon:
		for p in gun_powerups:
			if $"/root/Player".check(p["resource_name"]) == 0:
				allowed_powerups.append(p["ref"])

		if allowed_powerups.empty():
			allowed_powerups = gather_powerups() # player has all guns, lets collect normally
	else:
		allowed_powerups = gather_powerups()

	#spawn goodies
	if allowed_powerups.empty():
		return  # give something else maybe...?

	var new_powerup = allowed_powerups[rng.randi()%allowed_powerups.size()].instance()
	spawn_pos.add_child(new_powerup)

	$"/root/Player".give("s_treasure_open", 1)

func gather_powerups():
	#collect powerup to pool if possible and player has weapon to upgrade

	var allowed_powerups = []
	for p in powerups:
		if $"/root/Player/PlayerResources".check_limit(p["resource_name"]) < $"/root/Player/PlayerResources".resource_max_upgrades[p["resource_name"]]:
			allowed_powerups.append(p["ref"])

	for p in gun_powerups:
		if ($"/root/Player".check(p["resource_name"]) > 0 and
			$"/root/Player".check(p["resource_name"]) < $"/root/Player".check_limit(p["resource_name"])):
			allowed_powerups.append(p["ref"])

	return allowed_powerups
