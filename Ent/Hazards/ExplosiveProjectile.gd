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
class_name ExplosiveProjectile

func hit_target(var _col):
	detonate_explosive(null)

func detonate_explosive(var collider):
	var explosive = get_node_or_null("Explosive")
	if explosive:
		explosive.explode([self, collider])
	else:
		print("WRN: ExplosiveProjectile ", name, "doesn't have Explosive node")
	queue_free()

func deal_damage(var _amount, var _push_force, var _direction, var _from_node):
	detonate_explosive(null)

func _on_DecayTimer_timeout():
	detonate_explosive(null)
