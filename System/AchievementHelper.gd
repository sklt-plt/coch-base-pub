extends Node

const DEBUG = true

const SPEEDRUN_MAX_TIME_TOTAL = 600  # seconds to minutes, 10 minutes total
const BARRELS_MIN_KILLS = 10

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
	CLEAR_ENEMY_PERCENTAGE,
	CLEAR_TREASURE_PERCENTAGE,
	CLEAR_HIT_PERCENTAGE,
	CLEAR_CUSTOM,
	ARCADE_SCORE,
	ARCADE_COMBO,
	BARREL_KILLS,
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
	ACHIEVEMENTS.CLEAR_ENEMY_PERCENTAGE : "CLEAR_ENEMY_PERCENTAGE",
	ACHIEVEMENTS.CLEAR_TREASURE_PERCENTAGE : "CLEAR_TREASURE_PERCENTAGE",
	ACHIEVEMENTS.CLEAR_HIT_PERCENTAGE : "CLEAR_HIT_PERCENTAGE",
	ACHIEVEMENTS.CLEAR_CUSTOM : "CLEAR_CUSTOM",
	ACHIEVEMENTS.ARCADE_SCORE : "ARCADE_SCORE",
	ACHIEVEMENTS.ARCADE_COMBO : "ARCADE_COMBO",
	ACHIEVEMENTS.BARREL_KILLS : "BARREL_KILLS",
	ACHIEVEMENTS.BARREL_LAUNCH : "BARREL_LAUNCH"
}

func disqualify():
	is_disqualified = true

func qualify():
	is_disqualified = false

func set_achievemenet(var index : int):
	print_dbg("Got achievement: " + ACH_ENUM_TO_STRING[index])

	###
	#### TODO: TEST ON WINDOWS
	###

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

func try_give_barrel_kills_achievement():
	if $"/root/Player".check("s_barrel_kills") >= BARRELS_MIN_KILLS:
		set_achievemenet(ACHIEVEMENTS.BARREL_KILLS)

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
		$"/root/Player".check("s_time_total") < 600): # seconds to minutes * 10
			set_achievemenet(ACHIEVEMENTS.CLEAR_SPEEDRUN)
