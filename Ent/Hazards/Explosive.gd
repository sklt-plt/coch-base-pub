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

extends Area
class_name Explosive

export (float) var expl_damage = 10.0

export (PackedScene) var effect

var is_from_barrel = false
var was_barrel_and_kicked = false

func explode(var to_ignore : Array = []):
	#add effect
	if not self.is_inside_tree():
		return

	if effect != null:
		var n_effect = effect.instance()
		get_tree().current_scene.add_child(n_effect)
		n_effect.global_translation = self.global_translation

	var hit_any = false
	#deal damage directly if possible
	var parent = get_parent()
	if parent.has_method("deal_damage"):
		hit_any = true

		parent.deal_damage(expl_damage, 0, parent.global_translation, null)

	#deal damage indirectly in radius
	var in_blast = get_overlapping_bodies()

	#get physics space_state for raycasting
	var space_state = get_world().direct_space_state

	var barrel_kills = 0

	for body in in_blast:
		#check direct line of sight except for to_ignore (directly hit & missile parent)
		to_ignore.append(self)
		to_ignore.append(get_parent())
		var result = space_state.intersect_ray(get_global_transform().origin, body.get_global_transform().origin, to_ignore, collision_mask)

		if result and result.collider == body:
			if body.has_method("deal_damage"):
				#how much of a fraction of damage to give to body
				var my_global_t = get_global_transform().origin
				var distance_to = my_global_t.distance_to(result.position)
				var mul
				mul = 1/($BlastRadius.shape.radius + (distance_to - $BlastRadius.shape.radius))  # linear faloff
				var final_dmg = expl_damage*mul

				hit_any = true

				body.deal_damage(final_dmg, final_dmg*2, get_global_transform().origin , null)#/2, get_global_transform().origin , null)

				if parent is ExplosiveBarrel and body is KinematicEnemy or body is StaticEnemy and body.get_node("AI").health < 0:
					barrel_kills += 1

					if was_barrel_and_kicked:
						AchievementHelper.set_achievemenet(AchievementHelper.ACHIEVEMENTS.BARREL_LAUNCH)

				$"/root/Player".give("s_damage_dealt", expl_damage*mul)

	if hit_any and not is_from_barrel:
		$"/root/Player".give("s_shots_hit", 1)

	if barrel_kills != 0:
		AchievementHelper.increment_stat(AchievementHelper.STATS.TOTAL_BARREL_KILLS, barrel_kills)

	#remove explosive
	self.queue_free()

func deal_damage(var _amount, var _push_force, var _from_dir, var _from_node):
	explode([])

func _on_Timer_timeout():
	explode([])
