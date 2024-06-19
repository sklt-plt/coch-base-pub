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

extends Node

const DEBUG = false

const SPEEDRUN_MAX_TIME_TOTAL = 600  # seconds to minutes, 10 minutes total
const BARRELS_MIN_KILLS = 10
const ACCURACY_MIN_PERCENTAGE = 0.9

var is_disqualified = false

func print_dbg(var string):
	if DEBUG:
		print(string)

enum ACHIEVEMENTS {
	CLEAR_EP1_EASY,
	CLEAR_EP1_NORMAL,
	CLEAR_EP1_HARD,
	CLEAR_EP1_HARD_IRON,
	CLEAR_EP1_HARD_OHKO,
	CLEAR_EP2_EASY,
	CLEAR_EP2_NORMAL,
	CLEAR_EP2_HARD,
	CLEAR_EP2_HARD_IRON,
	CLEAR_EP2_HARD_OHKO,
	CLEAR_SPEEDRUN,
	CLEAR_TREASURE_PERCENTAGE,
	CLEAR_HIT_PERCENTAGE,
	BARREL_LAUNCH
}

var ACH_ENUM_TO_STRING = {
	ACHIEVEMENTS.CLEAR_EP1_EASY : "CLEAR_EP1_EASY",
	ACHIEVEMENTS.CLEAR_EP1_NORMAL: "CLEAR_EP1_NORMAL",
	ACHIEVEMENTS.CLEAR_EP1_HARD : "CLEAR_EP1_HARD",
	ACHIEVEMENTS.CLEAR_EP1_HARD_IRON : "CLEAR_EP1_HARD_IRON",
	ACHIEVEMENTS.CLEAR_EP1_HARD_OHKO : "CLEAR_EP1_HARD_OHKO",
	ACHIEVEMENTS.CLEAR_EP2_EASY : "CLEAR_EP2_EASY",
	ACHIEVEMENTS.CLEAR_EP2_NORMAL : "CLEAR_EP2_NORMAL",
	ACHIEVEMENTS.CLEAR_EP2_HARD : "CLEAR_EP2_HARD",
	ACHIEVEMENTS.CLEAR_EP2_HARD_IRON : "CLEAR_EP2_HARD_IRON",
	ACHIEVEMENTS.CLEAR_EP2_HARD_OHKO : "CLEAR_EP2_HARD_OHKO",
	ACHIEVEMENTS.CLEAR_SPEEDRUN : "CLEAR_SPEEDRUN",
	ACHIEVEMENTS.CLEAR_TREASURE_PERCENTAGE : "CLEAR_TREASURE_PERCENTAGE",
	ACHIEVEMENTS.CLEAR_HIT_PERCENTAGE : "CLEAR_HIT_PERCENTAGE",
	ACHIEVEMENTS.BARREL_LAUNCH : "BARREL_LAUNCH"
}

enum STATS {
	TOTAL_DAMAGE,
	TOTAL_CUSTOM_MAPS,
	TOTAL_BARREL_KILLS,
	BEST_ARCADE_SCORE,
	BEST_ARCADE_TIME
}

var STAT_ENUM_TO_STRING = {
	STATS.TOTAL_DAMAGE : "TOTAL_DAMAGE",
	STATS.TOTAL_CUSTOM_MAPS : "TOTAL_CUSTOM_MAPS",
	STATS.TOTAL_BARREL_KILLS : "TOTAL_BARREL_KILLS",
	STATS.BEST_ARCADE_SCORE : "BEST_ARCADE_SCORE",
	STATS.BEST_ARCADE_TIME : "BEST_ARCADE_TIME"
}

func disqualify():
	is_disqualified = true

func qualify():
	is_disqualified = false

func set_achievemenet(var index : int):
	print_dbg("Got achievement: " + ACH_ENUM_TO_STRING[index])

	if is_disqualified:
		print_dbg("Player is disqualified from achievements")
		return

	if !Steam.is_init():
		print_dbg("SteamAPI not initialized")
		return

	if Steam.get_achievement(ACH_ENUM_TO_STRING[index]):
		print_dbg("Achievement already unlocked: " + ACH_ENUM_TO_STRING[index])
		return

	Steam.set_achievement(ACH_ENUM_TO_STRING[index])

func increment_filtered_stat(var stat : int, var amount : int):
	if !Steam.is_init():
		return

	var current = Steam.user_stats.get_stat(STAT_ENUM_TO_STRING[stat])

	if current:
		Steam.user_stats.set_stati(STAT_ENUM_TO_STRING[stat], current + amount)
	else:
		Steam.user_stats.set_stati(STAT_ENUM_TO_STRING[stat], amount)

	$"FilteringTimer".start()

func increment_stat(var stat : int, var amount : int):
	if !Steam.is_init():
		return

	var current = Steam.user_stats.get_stat(STAT_ENUM_TO_STRING[stat])
	if current:
		Steam.user_stats.set_stat(STAT_ENUM_TO_STRING[stat], current + amount)
	else:
		Steam.user_stats.set_stat(STAT_ENUM_TO_STRING[stat], amount)

func try_give_arcade_achievements():
	if !Steam.is_init():
		return

	Steam.user_stats.set_stati(STAT_ENUM_TO_STRING[STATS.BEST_ARCADE_SCORE], $"/root/Player".check("s_score"))
	Steam.user_stats.set_statf(STAT_ENUM_TO_STRING[STATS.BEST_ARCADE_TIME], $"/root/Player".check("s_time_total") / 60)

	Steam.user_stats.store_stats()

func give_damage_stat(var value):
	return

func give_clear_ep_achievements(var episode_index):
	match episode_index:
		1 :
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.EASY:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_EASY)
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.NORMAL:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_EASY)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_NORMAL)
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.HARD:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_EASY)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_NORMAL)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_HARD)
				if $"/root/Player".check("s_deaths") != null and $"/root/Player".check("s_deaths") == 0:
					set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_HARD_IRON)
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.HARD_OHKO:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_EASY)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_NORMAL)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_HARD)
				if $"/root/Player".check("s_deaths") != null and $"/root/Player".check("s_deaths") == 0:
					set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_HARD_IRON)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP1_HARD_OHKO)
		2 :
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.EASY:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_EASY)
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.NORMAL:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_EASY)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_NORMAL)
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.HARD:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_EASY)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_NORMAL)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_HARD)
				if $"/root/Player".check("s_deaths") != null and $"/root/Player".check("s_deaths") == 0:
					set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_HARD_IRON)
			if Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.HARD_OHKO:
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_EASY)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_NORMAL)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_HARD)
				if $"/root/Player".check("s_deaths") != null and $"/root/Player".check("s_deaths") == 0:
					set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_HARD_IRON)
				set_achievemenet(ACHIEVEMENTS.CLEAR_EP2_HARD_OHKO)

	if ((Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.NORMAL or
		Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.HARD or
		Globals.campaign_difficulty_idx == Globals.CAMPAIGN_DIFFICULTY_ID.HARD_OHKO) and
		$"/root/Player".check("s_time_total") < SPEEDRUN_MAX_TIME_TOTAL):
			set_achievemenet(ACHIEVEMENTS.CLEAR_SPEEDRUN)

	if $"/root/Player".check("s_treasure_open") == $"/root/Player".check("s_treasure_possible"):
		set_achievemenet(ACHIEVEMENTS.CLEAR_TREASURE_PERCENTAGE)

	if $"/root/Player".check("s_shots_hit") >= $"/root/Player".check("s_shots_fired") * ACCURACY_MIN_PERCENTAGE:
		set_achievemenet(ACHIEVEMENTS.CLEAR_HIT_PERCENTAGE)

func _on_FilteringTimer_timeout():
	if !Steam.is_init():
		return

	Steam.user_stats.store_stats()
