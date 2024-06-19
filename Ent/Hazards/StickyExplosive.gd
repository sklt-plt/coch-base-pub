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

extends ExplosiveProjectile

export var hit_damage = 10.0
export var push_force = 10.0

func hit_target(var col : KinematicCollision):
	if (col.collider is HitProjectile):
		$Explosive.explode()
		queue_free()
		return

	if col.collider.has_method("deal_damage") and not col.collider is ExplosiveBarrel:
		col.collider.deal_damage(hit_damage, push_force, self.global_translation, null)

	var explosive = $Explosive

	var expl_tr= explosive.global_transform
	self.remove_child(explosive)
	col.collider.add_child(explosive)
	explosive.owner = col.collider.owner
	explosive.get_node("Timer").start()
	explosive.global_transform = expl_tr
	explosive.get_node("OmniLight/AnimationPlayer").play("blink")

	self.queue_free()

func detonate_explosive(var _collider):
	queue_free()
