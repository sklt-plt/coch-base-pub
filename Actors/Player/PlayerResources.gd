extends Node

var r_health : int
var r_armor : int
var r_pistol_ammo : int
var r_shotgun_ammo : int
var r_crossbow_ammo : int
var r_keys : int
var ammo_bonus_cap : int
var e_melee_level : int
var e_pistol_level : int
var e_double_barrel_level : int
var e_crossbow_level : int
var r_time_left : float
var r_time_freeze: float
var r_progress: int
var r_progress_multiplier: float

var resources_limits = {}
var resource_max_upgrades = {}

const ARMOR_DAMAGE_PERCENTAGE = 0.66

export (AudioStream) var audio_hurt
export (AudioStream) var audio_death

export (bool) var use_time_limit

const TIME_LEFT_MAX = 4.0*60

var progress_multiplier_decay = 0.0
const PROGRESS_MULTIPLIER_DECAY_SPEED_3x = 0.15
const PROGRESS_MULTIPLIER_DECAY_SPEED_2x = 0.1
const PROGRESS_MULTIPLIER_DECAY_SPEED_1x = 0.075
var current_multiplier_decay_speed = 0.1

func reset():
	#(re)set values to default
	r_health = 30 #100
	r_armor = 50
	r_pistol_ammo = 50
	r_shotgun_ammo = 25
	r_crossbow_ammo = 25
	r_keys = 0
	ammo_bonus_cap = 0
	e_melee_level = 1
	e_pistol_level = 1
	e_double_barrel_level = 0
	e_crossbow_level = 0
	r_time_left = TIME_LEFT_MAX
	r_time_freeze = 0.01
	r_progress = 0
	r_progress_multiplier = 1

	resources_limits = {
		"r_health" : 30, #100
		"r_armor"  : 50,
		"r_pistol_ammo" : 50,
		"r_shotgun_ammo" : 25,
		"r_crossbow_ammo" : 25,
		"r_keys" : 100,
		"e_melee_level" : 1,
		"e_pistol_level" : 1,
		"e_double_barrel_level" : 1,
		"e_crossbow_level" : 1,
		"r_time_left" : TIME_LEFT_MAX,
		"r_time_freeze": 1.04,
		"r_progress": 300,
		"r_progress_multiplier": 3.9,
	}

	resource_max_upgrades = {
		"r_health" : 200,
		"r_armor"  : 150,
		"ammo_bonus_cap" : 100
	}

	use_time_limit = false

func _ready():
	reset()

func _process(delta):
	if not $"../InputProxy".is_locked:
		if use_time_limit:
			if not take("r_time_freeze", delta) and not take("r_time_left", delta):
				$"../GameOverStats".reason = "Time Up!"
				deal_damage(10000)

	if r_progress_multiplier > 1.0:
		take("r_progress_multiplier", progress_multiplier_decay * delta)
		progress_multiplier_decay = min(1, progress_multiplier_decay + current_multiplier_decay_speed * delta)
	else:
		r_progress_multiplier = 1.0


func upgrade_resource(var resource, var value):
	if resource == "ammo_bonus_cap":
		ammo_bonus_cap += value
	else:
		resources_limits[resource] += value
		give(resource, value)

func deal_damage(var value):
	if r_health > 0.0:
		var armor_damage = value * ARMOR_DAMAGE_PERCENTAGE
		var actual_armor_damage = min(r_armor, armor_damage)
		var health_damage = value - actual_armor_damage

		r_armor -= actual_armor_damage
		r_health -= health_damage

		$"../HUD/HurtEffect".color.a += health_damage/resources_limits["r_health"]

		if r_health <= 0.0:
			$"../InputProxy".is_locked = true
			$"../PlayerMovement".set_dead()
			get_parent().visible = false
			$"../SFXPlayer".stream = audio_death
			$"../SFXPlayer".play()
			if $"/root/EpisodeManager".is_normal_episode_playing():
				$"../GameOver".show_delayed()
			else:
				$"../GameOverStats".show_delayed()

		else:
			$"../SFXPlayer".stream = audio_hurt
			$"../SFXPlayer".play()

		r_progress_multiplier -= 1.0

func take(var resource, var value):
	var res = get(resource)
	if !res:
		print("Error: can't take resource '", resource, "' - not found")
		return false
	if res < value:
		return false
	else:
		set(resource, res - value)
		return true

func switch_to_new_weapon(var resource):
	match resource:
		"e_melee_level":
			get_node("../BodyCollision/LookHeight/LookDirection/GunController").switch_guns(0)
		"e_pistol_level":
			get_node("../BodyCollision/LookHeight/LookDirection/GunController").switch_guns(1)
		"e_double_barrel_level":
			get_node("../BodyCollision/LookHeight/LookDirection/GunController").switch_guns(2)
		"e_crossbow_level":
			get_node("../BodyCollision/LookHeight/LookDirection/GunController").switch_guns(3)

func set(var resource, var value):
	.set(resource, value)
	switch_to_new_weapon(resource)

func give(var resource, var value):
	if value > 0:
		var resource_value = get(resource)
		if resource_value == null:
			print("Error: can't give resource '", resource, "' - not found")
			return false || use_time_limit

		if not resources_limits.has(resource):
			#assume there is no limit
			set(resource, resource_value + value)
			return true

		#check limits
		#if this is ammo take bonus capacity into consideration
		if resource == "r_pistol_ammo" or resource == "r_shotgun_ammo" or resource == "r_crossbow_ammo":
			if get(resource) == resources_limits[resource]+ammo_bonus_cap:
				#player is full
				return false || use_time_limit

			resource_value = min(resource_value + value, resources_limits[resource]+ammo_bonus_cap)
		elif resource == "r_progress":
			resource_value = min(resource_value + value * floor((r_progress_multiplier)), resources_limits[resource])

			give("r_progress_multiplier", 0.75)

			if (r_progress_multiplier < 0.45 * resources_limits["r_progress_multiplier"]):
				current_multiplier_decay_speed = PROGRESS_MULTIPLIER_DECAY_SPEED_1x
			elif (r_progress_multiplier < 0.65 * resources_limits["r_progress_multiplier"]):
				current_multiplier_decay_speed = PROGRESS_MULTIPLIER_DECAY_SPEED_2x
			elif (r_progress_multiplier < 0.85 * resources_limits["r_progress_multiplier"]):
				current_multiplier_decay_speed = PROGRESS_MULTIPLIER_DECAY_SPEED_3x

			progress_multiplier_decay = 0.0

		else:
			if get(resource) == resources_limits[resource]:
				#player is full
				return false || use_time_limit

			resource_value = min(resource_value + value, resources_limits[resource])

		set(resource, resource_value)

		return true
	else:
		return false || use_time_limit

func has(var resource, var value):
	var resource_value = get(resource)
	if resource_value == null:
		return false

	if resource_value >= value:
		return true
	else:
		return false

func check(var resource):
	var resource_value = get(resource)
	if resource_value == null:
		return 0
	else:
		return resource_value

func check_limit(var resource):
	if resource == "ammo_bonus_cap":
		return ammo_bonus_cap
	else:
		return resources_limits[resource]
