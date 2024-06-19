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

extends RigidBody
class_name ExplosiveBarrel

var exploded = false

func _ready():
	$Explosive.is_from_barrel = true

func _enter_tree():
	mode = RigidBody.MODE_STATIC

func disable_collisions():
	var children = get_children()
	for c in children:
		if c is CollisionShape:
			c.disabled = true

func deal_damage(var amount, var push_force, var from_dir, var _from_ent):
	if is_zero_approx(amount):
		# basically kick
		apply_central_impulse((self.global_translation-from_dir).normalized() * push_force*20)
		$Explosive.was_barrel_and_kicked = true

	elif not exploded:
		exploded = true
		self.mode = MODE_STATIC
		disable_collisions()
		$Model.visible = false
		$AudioStreamPlayer3D.play()
		$Explosive.explode()
