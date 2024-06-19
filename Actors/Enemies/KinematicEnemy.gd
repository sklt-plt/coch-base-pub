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

extends KinematicActor
class_name KinematicEnemy
tool

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	var ai_node = get_node_or_null("AI")
	if ai_node:
		ai_node.deal_damage(damage, push_force, from_direction, from_ent)

func set_awake(var to_awake):
	$AI.set_awake(to_awake)

func get_player_resource_costs():
	return $PlayerResourceCosts.player_resource_costs

func get_current_move_vector():
	return $AI.current_move_vector

func get_current_state():
	return $AI.current_state

func get_direct_damage():
	return $AI.direct_damage

func set_dynamic(var value: bool):
	$AI.is_dynamic = value

func get_dynamic():
	return $AI.is_dynamic

func teleport_to_spawn():
	$AI.teleport_to_spawn()
