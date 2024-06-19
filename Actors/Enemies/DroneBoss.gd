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

extends Spatial

export (float) var health = 400.0

export (String) var hud_name = "boss name"
export (String) var anim_idle = ""
export (String) var anim_die = ""

export (AudioStream) var kill_track

var dead = false

export (Dictionary) var kill_immediate_resources = {
	"s_score" : 10000,
	"s_kills" : 1
}

func _ready():
	$Model/AnimationPlayer.play(anim_idle)
	$"/root/Player/HUD".register_boss_health(self, hud_name)
	$"/root/Player".give("s_kills_possible", 1)

func deal_damage(damage, _push_force, _from_direction, _from_ent):
	if health > 0.1:
		health -= damage * Globals.get_difficulty_field("player_firepower_scale")

	if health < 0.01 and not dead:
		dead = true
		$"/root/Player/HUD".deregister_boss_health()

		for r in kill_immediate_resources:
			$"/root/Player".give(r, kill_immediate_resources[r])

		$Model/AnimationPlayer.play(anim_die)
		var minions = get_tree().get_nodes_in_group("enemies")
		for m in minions:
			if m.is_inside_tree():
				m.deal_damage(10000, 0, Vector3.ZERO, null)

		var children = get_children()
		for c in children:
			if c is Drone:
				yield(get_tree().create_timer(0.1), "timeout")
				if is_instance_valid(c):
					c.destroy()

		var dying_time = $"/root/Player/PlayerAnimations".SLOWMO_TOTAL_TIME
		$"/root/Player".play_slowmo_effect(dying_time)
		$"/root/Player/MusicController".play_once_and_finish(kill_track)

		yield(get_tree().create_timer(dying_time), "timeout")
		$"/root/EpisodeManager".next_map()

func _on_Boss_tree_exiting():
	$"/root/Player/HUD".deregister_boss_health()
