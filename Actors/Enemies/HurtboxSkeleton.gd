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

extends Skeleton

signal deal_damage(damage, push_force, from_direction, from_ent)

func _ready():
	# connect all hurtboxes
	var skeleton_children = get_children()
	for skeleton_child in skeleton_children:
		if skeleton_child is BoneAttachment:
			var bone_children = skeleton_child.get_children()
			for bone_child in bone_children:
				if bone_child is Hurtbox:
					bone_child.connect("deal_damage", self, "deal_damage", [])

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	emit_signal("deal_damage", damage, push_force, from_direction, from_ent)
