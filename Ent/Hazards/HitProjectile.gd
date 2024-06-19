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

extends BaseProjectile
class_name HitProjectile

export var projectile_damage = 20.0
export var projectile_push_force = 20.0

func hit_target(var col):
	if col.collider.has_method("deal_damage"):
		col.collider.deal_damage(projectile_damage, projectile_push_force, .get_global_transform().origin , null)

	queue_free()

func deal_damage(var _amount, var _push_force, var _direction, var _from_node):
	queue_free()

func _on_DecayTimer_timeout():
	queue_free()
