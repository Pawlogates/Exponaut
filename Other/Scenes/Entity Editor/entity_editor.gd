extends Control

@onready var container_behavior_buttons = $container_behavior_buttons
@onready var bg: ColorRect = $bg


var l_available_property_name = ["speed", "acceleration_multiplier_x", "ignore_gravity", "on_timeout_change_ignore_gravity", "on_timeout_change_ignore_gravity_cooldown", "bouncy_y", "bouncy_x", "movement_type", "on_death_spawn_entity", "on_death_spawn_entity_scene", "on_death_spawn_entity_quantity", "on_death_spawn_entity_throwAround", "on_death_spawn_entity_velocity", "on_timeout_death", "on_timeout_death_cooldown"]

var l_speed_button_info : Dictionary = {"behavior_name" : "Movement Speed", "behavior_value" : 400, "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_acceleration_multiplier_x_button_info : Dictionary = {"behavior_name" : "Acceleration", "behavior_value" : 1.0, "behavior_value_step" : 0.1, "behavior_value_min" : 0.25, "behavior_value_max" : 10.0, "behavior_available_options" : ["none"]}

var l_bouncy_y_button_info : Dictionary = {"behavior_name" : "Bounce off the ground", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_bouncy_x_button_info : Dictionary = {"behavior_name" : "Bounce off the walls", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}

var l_ignore_gravity_button_info : Dictionary = {"behavior_name" : "Ignore Gravity", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_timeout_change_ignore_gravity_button_info : Dictionary = {"behavior_name" : "Fall after a delay", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_timeout_change_ignore_gravity_cooldown_button_info : Dictionary = {"behavior_name" : "Fall delay", "behavior_value" : 1.5, "behavior_value_step" : 0.25, "behavior_value_min" : 0, "behavior_value_max" : 4.0, "behavior_available_options" : ["none"]}

var l_movement_type_button_info : Dictionary = {"behavior_name" : "Movement type", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : Globals.l_entity_movement_limited}

var l_on_death_spawn_entity_button_info : Dictionary = {"behavior_name" : "Leave an object after death", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_death_spawn_entity_scene_button_info : Dictionary = {"behavior_name" : "Chosen object", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : Globals.l_entity}
var l_on_death_spawn_entity_quantity_button_info : Dictionary = {"behavior_name" : "Object quantity", "behavior_value" : 400, "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_death_spawn_entity_throwAround_button_info : Dictionary = {"behavior_name" : "Throw object around", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_death_spawn_entity_velocity_button_info : Dictionary = {"behavior_name" : "Throw direction", "behavior_value" : 400, "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}

var l_on_timeout_death_button_info : Dictionary = {"behavior_name" : "Destroy after a delay", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_timeout_death_cooldown_button_info : Dictionary = {"behavior_name" : "Destruction cooldown", "behavior_value" : 2.5, "behavior_value_step" : 0.25, "behavior_value_min" : 0.0, "behavior_value_max" : 12.0, "behavior_available_options" : ["none"]}

var l_none_button_info : Dictionary = {"behavior_name" : "none", "behavior_value" : -1, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : ["none"]}


var choosen_movement_type = "move_x"
var choosen_family = "player"


func _ready():
	Globals.weapon_blocked = true
	
	for property_name in Globals.weapon:
		if property_name == "none" : continue
		
		set(property_name, Globals.weapon[property_name])
	
	for property_name in l_available_property_name:
		
		# Property of float or int value.
		if get("l_" + property_name + "_button_info")["behavior_available_options"] == ["none"]:
			
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_int_float).instantiate()
			
			behavior_button.type = "int_float"
			behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)
		
		# Property of bool value (technically an Array containing "true" and "false").
		elif get("l_" + property_name + "_button_info")["behavior_available_options"] == [true, false]:
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_bool).instantiate()
			
			behavior_button.type = "bool"
			behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)
		
		# Property of Array value.
		else:
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_Array).instantiate()
			
			behavior_button.type = "Array"
			behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("0"):
		Globals.weapon_blocked = false
		queue_free()


func update_entity():
	Globals.weapon = {}
	
	for property_name in l_available_property_name:
		Globals.weapon.get_or_add(property_name, get(property_name))


var collectable = true
var hittable = false
var collidable = false

var health_value = 3
var damage_value = 1
var score_value = 25

var movement_type : String = "normal"

var speed = 400
var jump_velocity = -600
var acceleration = 200
var friction = 400
var fall_speed = 400

var family : String = "all"


var can_move = false
var can_move_x = false
var can_move_y = false

var ignore_gravity = true
var on_death_ignore_gravity_stop = true

var speed_multiplier_x = 1.0
var speed_multiplier_y = 1.0
var acceleration_multiplier_x = 1.0
var acceleration_multiplier_y = 1.0
var friction_multiplier_x = 1.0
var friction_multiplier_y = 1.0
var gravity_multiplier_x = 1.0
var gravity_multiplier_y = 1.0

var on_wall_change_direction_x = true
var on_wall_change_speed = false
var on_wall_change_speed_multiplier = 0.5
var on_wall_change_velocity = true
var on_wall_change_velocity_multiplier = Vector2(0.5, 0.5)
var on_wall_float = false
var on_wall_death = false

var on_ledge_turn = false
var on_ledge_speed_multiplier = 1.0
var on_ledge_death = false

var bouncy_y = false
var bouncy_x = false
var ascending = false

# Timer-based behavior:
var on_timeout_change_direction = false
var on_timeout_change_direction_cooldown = 4.0
var on_timeout_jump = false
var on_timeout_jump_cooldown = 4.0
var on_timeout_change_ignore_gravity = false
var on_timeout_change_ignore_gravity_cooldown = 1.5
var on_timeout_death = false
var on_timeout_death_cooldown = 1.5

var collidable_cooldown = 0.35

# Behavior triggered on entity death:
var on_death_spawn_entity = false
var on_death_spawn_entity_scene = "res://Enemies/togglebot.tscn"
var on_death_spawn_entity_quantity = 1
var on_death_spawn_entity_spreadPosition = false
var on_death_spawn_entity_spreadPosition_multiplier_x = 1.0
var on_death_spawn_entity_spreadPosition_multiplier_y = 1.0
var on_death_spawn_entity_throwAround = false
var on_death_spawn_entity_throwAround_multiplier_x = 1.0
var on_death_spawn_entity_throwAround_multiplier_y = 1.0
var on_death_spawn_entity_velocity = Vector2(0, 0) # Disables behaviour of "on_death_spawn_entity_throwAround".
var on_death_spawn_entity_offset = Vector2(0, 0) # Disables behaviour of "on_death_spawn_entity_spreadPosition".

var on_death_toggle_toggleBlocks = false
var on_death_toggle_toggleBlocks_id = 0

var on_death_disappearInstantly = false # Spawns some particles and removes the entity right after.

# Behavior triggered on entity hit:
var on_hit_spawn_entity = false
var on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
var on_hit_spawn_entity_quantity = 1
var on_hit_spawn_entity_spreadPosition = false
var on_hit_spawn_entity_spreadPosition_multiplier_x = 1.0
var on_hit_spawn_entity_spreadPosition_multiplier_y = 1.0
var on_hit_spawn_entity_throwAround = false
var on_hit_spawn_entity_throwAround_multiplier_x = 1.0
var on_hit_spawn_entity_throwAround_multiplier_y = 1.0

# Behavior triggered on entity spotting a "target" entity:
var patrolling = false
var patrolling_targets = ["Player"] # A valid target is a node with either a matching group name, entity_type or family.
var patrolling_vision_size = Vector2(384, 64)
var patrolling_vision_pos = Vector2(192, 0)

var on_patrolling_spotted_spawn_entity = false
var on_patrolling_spotted_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
var on_patrolling_spotted_spawn_entity_cooldown = 0.5

var on_patrolling_spotted_spawn_entity2 = false
var on_patrolling_spotted_spawn_entity_scene2 = load("res://Enemies/togglebot.tscn")
var on_patrolling_spotted_spawn_entity2_cooldown = 0.5

var on_patrolling_spotted_spawn_entity3 = false
var on_patrolling_spotted_spawn_entity_scene3 = load("res://Enemies/togglebot.tscn")
var on_patrolling_spotted_spawn_entity3_cooldown = 0.5

var on_patrolling_spotted_spawn_entity_offset = Vector2(0, 0)
@export_enum("Player", "Enemy", "none", "all") var on_patrolling_spotted_spawn_entity_family: String = "enemy"
var patrolling_change_direction_cooldown : float = 4.0


# Behavior triggered as long as the entity currently satisfies a condition:
var when_atStartPosition_x_stop = false
var when_atStartPosition_y_stop = false

var start_position_leniency_x = 15
var start_position_leniency_y = 15

# Behavior triggered on spawn:
var on_spawn_offset_position = Vector2(0, 0)
var on_spawn_offset_position_random = false
var on_spawn_offset_position_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200)) # Maximum variance.

# Behaviour triggered on player touching the entity.
var on_touch_modulate = Color(1, 1, 1, 1)


var can_affect_player = false
var can_collect = false
var look_at_player_x = false
var look_at_player_y = false
var look_at_player_rotate = false
var look_at_player_rotate_offset = 0

var on_entityEntered_change_direction_copyEntity = false
var on_entityEntered_change_direction_basedOnPosition = false

var enteredFromAboveAndNotMoving_enable = true
var enteredFromAboveAndNotMoving_velocity = -800


var rng_custom = -1 # Set to -1 for random.


var collectable_multiple = false
var collectable_multiple_health = 4 # Set to "-1" for infinite.

# If an entity is breakable, the player can bounce off of it, and gains greater height if the jump button is pressed during the bounce, making it a "box" in most cases.
var breakable = true

var breakable_on_death_spawn_entity = false
var breakable_on_death_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
var breakable_on_death_spawn_entity_quantity = 5
var breakable_on_death_spawn_entity_throwAround = false
var breakable_on_death_spawn_entity_throwAround_velocity = Vector2(400, -200)
var breakable_on_death_spawn_entity_throwAround_random = false
var breakable_on_death_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
var breakable_on_death_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

var breakable_on_death_player_velocity_y = -200
var breakable_on_death_player_velocity_y_jump = -600

var breakable_on_death_spawn_entity_spread_position = true

var breakable_on_hit_spawn_entity = false
var breakable_on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
var breakable_on_hit_spawn_entity_quantity = 10
var breakable_on_hit_spawn_entity_throwAround = false
var breakable_on_hit_spawn_entity_throwAround_velocity = Vector2(400, -200)
var breakable_on_hit_spawn_entity_throwAround_random = false
var breakable_on_hit_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
var breakable_on_hit_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

var breakable_on_hit_player_velocity_y = -400
var breakable_on_hit_player_velocity_y_jump = -600

var breakable_on_hit_spawn_entity_spread_position = true

# Only breakable while these conditions are satisfied.
var breakable_requires_velocity_x = true
var breakable_requires_velocity_y = true

# Velocity ranges in which a box can be broken. Note: Set to -1 for "never".
# Single range:
var breakable_requires_velocity_x_range = Vector2(-1, -1)
var breakable_requires_velocity_y_range = Vector2(200, 100000)

# Multiple ranges:
# Example: 1 - [Vector2(-100000, -400) and 2 - [Vector2(400, 100000)] will make the box break only if an entity (or the player) moves into it very fast horizontally.
var breakable_requires_velocity_x_range2 = Vector2(-1, -1)
var breakable_requires_velocity_y_range2 = Vector2(-1, -1)

# Advanced box is an entity that gained movement after being hit or killed. An example of an advanced box would be the large gem that floats until hit by the player, after which it gains physics-based movement, and can be broken again, opening a level portal.
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var on_hit_gain_movement : String = "none"
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var on_death_gain_movement : String = "none"
var on_death_prevent_death = 0 # How many times an entity death will be prevented.
var on_death_prevent_score = 0 # How many times an entity death will not grant any score.

var score_value2 = 125
var score_value3 = 125
var score_value4 = 125
var score_value5 = 125

var breakable_advanced_on_death_spawn_entity = false
var breakable_advanced_on_death_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
var breakable_advanced_on_death_spawn_entity_quantity = 10
var breakable_advanced_on_death_spawn_entity_throwAround = false
var breakable_advanced_on_death_spawn_entity_throwAround_velocity = Vector2(400, -200)
var breakable_advanced_on_death_spawn_entity_throwAround_random = false
var breakable_advanced_on_death_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
var breakable_advanced_on_death_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

var breakable_advanced_on_death_player_velocity = -400
var breakable_advanced_on_death_player_velocity_jump = -600

var breakable_advanced_on_death_spawn_entity_spread_position = true

var breakable_advanced_on_hit_spawn_entity = false
var breakable_advanced_on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
var breakable_advanced_on_hit_spawn_entity_quantity = 10
var breakable_advanced_on_hit_spawn_entity_throwAround = false
var breakable_advanced_on_hit_spawn_entity_throwAround_velocity = Vector2(400, -200)
var breakable_advanced_on_hit_spawn_entity_throwAround_random = false
var breakable_advanced_on_hit_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
var breakable_advanced_on_hit_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

var breakable_advanced_on_hit_player_velocity = -400
var breakable_advanced_on_hit_player_velocity_jump = -600

var breakable_advanced_on_hit_spawn_entity_spread_position = true


var breakable_advanced_portal_on_death_open = false
var breakable_advanced_portal_particle_quantity = 25
var breakable_advanced_portal_level_id = "none" # Example: "MAIN_1"
var breakable_advanced_portal_checkpoint_offset = Vector2(320, -64)

var breakable_advanced_on_touch_modulate = Color(1, 1, 1, 1)

# Major collectibles have a special pickup animation. An example would be the projectile upgrade modules.
var majorCollectible_module = false
var majorCollectible_key = false

# A temporary powerup will grant an ability for a short time, as well as a score multiplier of x2. Note: Set the ability to "none" for a simple score multiplier powerup.
var temporaryPowerup = false
@export_enum("none", "higher_jump", "increased_speed", "teleport_forward_on_airJump") var temporary_powerup = "none"
var temporary_powerup_duration = 10

var inventory_item = false
var inventory_item_scene = load("res://Enemies/togglebot.tscn")
var inventory_item_is_hidden = false

var is_healthItem = false
var rotting = false
var fall_when_button_pressed = false

var transform_player = false
var transform_player_scene = load("res://Enemies/togglebot.tscn")

var on_collected_effect_special = false

var immortal = false


# General timers. Each one can have an action assigned to it, which will be executed on the matching timer's timeout.
var general_timers_enabled = false

var t1_cooldown = 3.0
var t2_cooldown = 3.0
var t3_cooldown = 3.0
var t4_cooldown = 3.0
var t5_cooldown = 3.0
var t6_cooldown = 3.0

var t1_on_timeout_randomize_cooldown = false
var t2_on_timeout_randomize_cooldown = false
var t3_on_timeout_randomize_cooldown = false
var t4_on_timeout_randomize_cooldown = false
var t5_on_timeout_randomize_cooldown = false
var t6_on_timeout_randomize_cooldown = false

var t_randomize_cooldown_min = 0.5
var t_randomize_cooldown_max = 6

var t1_on_spawn_randomize = false
var t2_on_spawn_randomize = false
var t3_on_spawn_randomize = false
var t4_on_spawn_randomize = false
var t5_on_spawn_randomize = false
var t6_on_spawn_randomize = false

# Actions that can be performed when their respective general timers finish. Note that "t_trigger_[action]" stands for: GENERAL TIMER (t) _ TRIGGER ON TIMEOUT (trigger) _ BEHAVIOR ([action]).
# The values (int) of these properties correspond to a specific general timer, which will look for a behavior matching its ID number on timeout.
# A value of -1 means that this behavior will not match any general timer.
var t_trigger_jump = -1
var t_trigger_jumpAndMove = -1
var t_trigger_change_direction = -1
var t_trigger_selfDestruct = -1
var t_trigger_selfDestructAndSpawnEntity = -1
var t_trigger_sfx = -1
var t_trigger_randomize_speedAndJumpVelocity = -1

var t_trigger_spawnEntity = -1
var t_trigger_spawnEntity_scene = load("res://Enemies/togglebot.tscn")
var t_trigger_spawnEntity_quantity = 4
var t_trigger_spawnEntity_velocity = Vector2(200, -400)
var t_trigger_spawnEntity_velocity_random = true
var t_trigger_spawnEntity_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

var t_trigger_spawnEntity2 = -1
var t_trigger_spawnEntity2_scene = load("res://Enemies/togglebot.tscn")
var t_trigger_spawnEntity2_quantity = 4
var t_trigger_spawnEntity2_velocity = Vector2(200, -400)
var t_trigger_spawnEntity2_velocity_random = true
var t_trigger_spawnEntity2_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

var t_trigger_spawnEntity3 = -1
var t_trigger_spawnEntity3_scene = load("res://Enemies/togglebot.tscn")
var t_trigger_spawnEntity3_quantity = 4
var t_trigger_spawnEntity3_velocity = Vector2(200, -400)
var t_trigger_spawnEntity3_velocity_random = true
var t_trigger_spawnEntity3_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

# These properties decide whether or not a specific particle will be spawned:
var particle_star = true
var particle_orb = true
var particle_splash = true
var particle_leaf = true
var particle_star_fast = true
var effect_hit_enemy = true
var effect_kill_enemy = true
var effect_oneShot_enemy = true

#UNFINISHED
# General particles. These properties control when, where, how many and what kind of particle/effect is supposed to spawn.
# Note that this behavior is very similar to how GENERAL TIMERS work.
var p_particle_star = -1
var p_particle_orb = -1
var p_particle_splash = -1
var p_particle_leaf = -1
#UNFINISHED


var heal_player = false # Will heal the player even if collected by an entity.
var heal_value = 1
var heal_entity = false

var award_score = true
var on_collected_award_score = true
var on_hit_award_score = false
var on_death_award_score = false

var reset_puzzle = false
var on_collected_reset_puzzle = false
var on_hit_reset_puzzle = false
var on_death_reset_puzzle = false

var remove_delay = 1.0

var on_floor_bounce = false
var on_wall_bounce = false

var variable_speed = false

var anim_alternate_walk = false
var anim_alternate_walk_hittable_only_during = false

var on_wall_jump_velocity : int = -100


var start_animation = "general/loop_up_down"
var on_collected_anim_name : String = "general/fade_out_up"
#("none", "general/loop_up_down", "general/rotate_around_y_fade_out", "general/reflect_straight")
#("none", "general/loop_up_down", "general/loop_up_down_slight", "general/loop_scale", "gear/rotate")

var can_change_sprite_anim : bool = false

var disable_sprite_anims = ["none"]
var disable_anims = ["none"]

var idle_sfx = false
var idle_sfx_cooldown = 4.0
var idle_sfx_randomize_cooldown = false

var on_collected_spawn_star : bool = true
var on_collected_spawn_star2 : bool = true
var on_collected_spawn_orb_orange : bool = true
var on_collected_spawn_orb_blue : bool = true
var on_collected_spawn_homing_square_yellow : bool = true

var sfx_self_collected_filepath = Globals.d_sfx + "/" + "jewel_collect.wav" # The "self" refers to the sfx playing on ITSELF having died, been collected, killing another entity, etc. So the main sfx properties are the ones with "self" in the middle.
var sfx_self_hit_filepath = Globals.d_sfx + "/" + "player_attack.wav"
var sfx_self_shot_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
var sfx_self_death_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
var sfx_self_bounced_filepath = Globals.d_sfx + "/" + "error.wav"
var sfx_self_spotted_filepath = Globals.d_sfx + "/" + "error.wav"

var sfx_self_reflected_straight_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
var sfx_self_reflected_slope_filepath = Globals.d_sfx + "/" + "error.wav"

var sfx_collected_filepath = Globals.d_sfx + "/" + "jewel_collect.wav"
var sfx_hit_filepath = Globals.d_sfx + "/" + "player_attack.wav"
var sfx_shot_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
var sfx_death_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
var sfx_bounced_filepath = Globals.d_sfx + "/" + "error.wav"
var sfx_spotted_filepath = Globals.d_sfx + "/" + "beam_enabled.mp3"

var entity_name = "none"
var entity_type : String = "collectible"
var direction_x = 1
var direction_y = -1

var on_spawn_randomize_everything = false

var debug = false
