class_name entity_basic
extends CharacterBody2D

@onready var World = Globals.reassign_general()[0]
@onready var Player = Globals.reassign_general()[1]

@onready var sprite = $sprite

@onready var timer_attacking: Timer = $sprite/timer_attacking
@onready var timer_attacked: Timer = $sprite/timer_attacked

@onready var cooldown_jump: Timer = $cooldown_jump
@onready var timer_invincible: Timer = $timer_invincible
@onready var cooldown_collidable: Timer = $cooldown_collidable

@onready var scan_ledge = $scan_ledge

@onready var animation_general: AnimationPlayer = %animation_general

@onready var hitbox: Area2D = $hitbox
@onready var collision_main: CollisionShape2D = $collision_main


# Sound effects.
@onready var sfx_manager = $sfx_manager # The sound effects manager should be called every time a sound should play. Example: "sfx_manager.sfx_play(Globals.sfx_player_jump, 1.0, 0.0)"
@onready var sfx = $sfx_manager/sfx # If a sound effect is already being played, another sound player will play the next one. No more than 5 sounds at a time can be played by an entity.
@onready var sfx1 = $sfx_manager/sfx1
@onready var sfx2 = $sfx_manager/sfx2
@onready var sfx3 = $sfx_manager/sfx3
@onready var sfx4 = $sfx_manager/sfx4

# States an entity can be in, used mainly for managing sprite animations. Note that an entity can be in multiple states at the same time.
var attacked = false;
var attacking = false;
var dead = false;

var can_turn = true

var movement_type_id = 0

var global_gravity = Globals.gravity

var rng = RandomNumberGenerator.new()

# Active direction can't ever be equal to 0.
var direction_active_x = 1
var direction_active_y = -1

# Last velocity cannot be equal to any value between -25 and 25 (used for behavior like bouncing).
var velocity_last_x = 25
var velocity_last_5 = -25

var spotted = false

var start_pos = Vector2(-1, -1) # If equal to Vector2(-1, -1), it will be assigned at _ready().

var collected = false
var rotten = false
var only_visual = false
var removable = false

signal collected_majorCollectible_module
signal collected_majorCollectible_key

var random_position_offset = Vector2(randf_range(0, 250), randf_range(0, 250))

var effect_shrink = false

# Start of properties.
@export_group("Main interactions.") # Section start.

@export var collectable = true
@export var hittable = false
@export var collidable = false

@export_group("") # Section end.

@export_group("Main information.") # Section start.

@export var health_value = 3
@export var damage_value = 1
@export var score_value = 25

@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var movement_type : String = "normal"

@export var speed = 400
@export var jump_velocity = -600
@export var gravity = 1.0
@export var acceleration = 1.0
@export var friction = 1.0

@export_enum("player", "enemy", "none", "all") var family : String = "all"

@export_group("") # Section end.

@export_group("Movement specifics.") # Section start.

@export var can_move = false
@export var can_move_x = false
@export var can_move_y = false

@export var speed_multiplier_x = 1.0
@export var speed_multiplier_y = 1.0
@export var acceleration_multiplier_x = 1.0
@export var acceleration_multiplier_y = 1.0
@export var friction_multiplier_x = 1.0
@export var friction_multiplier_y = 1.0
@export var gravity_multiplier_x = 1.0
@export var gravity_multiplier_y = 1.0

@export var on_wall_turn = false
@export var on_wall_speed_multiplier = 1.0
@export var on_wall_float = false
@export var on_wall_death = false

@export var on_ledge_turn = false
@export var on_ledge_speed_multiplier = 1.0
@export var on_ledge_death = false

@export var bouncy_y = false
@export var bouncy_x = false
@export var ascending = false

# Timer-based behavior:
@export var on_timeout_change_direction = false
@export var on_timeout_change_direction_cooldown = 4.0
@export var on_timeout_jump = false
@export var on_timeout_jump_cooldown = 4.0

@export var collidable_cooldown = 0.35

# Behavior triggered on entity death:
@export var on_death_spawn_entity = false
@export var on_death_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var on_death_spawn_entity_quantity = 1
@export var on_death_spawn_entity_spreadPosition = false
@export var on_death_spawn_entity_spreadPosition_multiplier_x = 1.0
@export var on_death_spawn_entity_spreadPosition_multiplier_y = 1.0
@export var on_death_spawn_entity_throwAround = false
@export var on_death_spawn_entity_throwAround_multiplier_x = 1.0
@export var on_death_spawn_entity_throwAround_multiplier_y = 1.0
@export var on_death_spawn_entity_velocity = Vector2(0, 0) # Disables behaviour of "on_death_spawn_entity_throwAround".
@export var on_death_spawn_entity_offset = Vector2(0, 0) # Disables behaviour of "on_death_spawn_entity_spreadPosition".

@export var on_death_toggle_toggleBlocks = false
@export var on_death_toggle_toggleBlocks_id = 0

@export var on_death_disappearInstantly = false # Spawns some particles and removes the entity right after.

# Behavior triggered on entity hit:
@export var on_hit_spawn_entity = false
@export var on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var on_hit_spawn_entity_quantity = 1
@export var on_hit_spawn_entity_spreadPosition = false
@export var on_hit_spawn_entity_spreadPosition_multiplier_x = 1.0
@export var on_hit_spawn_entity_spreadPosition_multiplier_y = 1.0
@export var on_hit_spawn_entity_throwAround = false
@export var on_hit_spawn_entity_throwAround_multiplier_x = 1.0
@export var on_hit_spawn_entity_throwAround_multiplier_y = 1.0

# Behavior triggered on entity spotting a "target" entity:
@export var spotted_patrolling = false
@export var spotted_targets = "Player" # A valid target is a node with either a matching group name, entity_type or family.
@export var spotted_vision_size = Vector2(256, 64)

@export var on_spotted_spawn_entity = false
@export var on_spotted_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var on_spotted_spawn_entity_cooldown = 0.5

@export var on_spotted_spawn_entity2 = false
@export var on_spotted_spawn_entity_scene2 = load("res://Enemies/togglebot.tscn")
@export var on_spotted_spawn_entity2_cooldown = 0.5

@export var on_spotted_spawn_entity3 = false
@export var on_spotted_spawn_entity_scene3 = load("res://Enemies/togglebot.tscn")
@export var on_spotted_spawn_entity3_cooldown = 0.5

@export var on_spotted_spawn_entity_offset = Vector2(0, 0)
@export_enum("player", "enemy", "none", "all") var on_spotted_spawn_entity_family: String = "enemy"

# Behavior triggered as long as the entity currently satisfies a condition:
@export var when_atStartPosition_x_stop = false
@export var when_atStartPosition_y_stop = false

@export var start_position_leniency_x = 15
@export var start_position_leniency_y = 15

# Behavior triggered on spawn:
@export var on_spawn_offset_position = Vector2(0, 0)
@export var on_spawn_offset_position_random = false
@export var on_spawn_offset_position_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200)) # Maximum variance.

# Behaviour triggered on player touching the entity.
var on_touch_modulate = Color(1, 1, 1, 1)

@export_group("") # Section end.

@export_group("Other properties.") # Section start.

@export var can_affect_player = false
@export var can_collect = false
@export var look_at_player_x = false
@export var look_at_player_y = false
@export var look_at_player_rotate = false
@export var look_at_player_rotate_offset = 0

@export var on_entityEntered_change_direction_copyEntity = false
@export var on_entityEntered_change_direction_basedOnPosition = false

@export var enteredFromAboveAndNotMoving_enable = true
@export var enteredFromAboveAndNotMoving_velocity = -800

@export var rng_custom = -1 # Set to -1 for random.
@export var disable_animations = ["none", "none", "none"]

@export_enum("none", "loop_up_down", "loop_up_down_slight", "loop_scale") var animation = "loop_up_down"

# If an entity is breakable, the player can bounce off of it, and gains greater height if the jump button is pressed during the bounce, making it a "box" in most cases.
@export var breakable = false

@export var breakable_on_death_spawn_entity = false
@export var breakable_on_death_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var breakable_on_death_spawn_entity_quantity = 10
@export var breakable_on_death_spawn_entity_throwAround = false
@export var breakable_on_death_spawn_entity_throwAround_velocity = Vector2(400, -200)
@export var breakable_on_death_spawn_entity_throwAround_random = false
@export var breakable_on_death_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
@export var breakable_on_death_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

@export var breakable_on_death_player_velocity = -400
@export var breakable_on_death_player_velocity_jump = -600

@export var breakable_on_death_spawn_entity_spread_position = true

@export var breakable_on_hit_spawn_entity = false
@export var breakable_on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var breakable_on_hit_spawn_entity_quantity = 10
@export var breakable_on_hit_spawn_entity_throwAround = false
@export var breakable_on_hit_spawn_entity_throwAround_velocity = Vector2(400, -200)
@export var breakable_on_hit_spawn_entity_throwAround_random = false
@export var breakable_on_hit_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
@export var breakable_on_hit_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

@export var breakable_on_hit_player_velocity = -400
@export var breakable_on_hit_player_velocity_jump = -600

@export var breakable_on_hit_spawn_entity_spread_position = true

# Only breakable while these conditions are satisfied.
@export var breakable_requires_velocity_x = true
@export var breakable_requires_velocity_y = true

# Velocity ranges in which a box can be broken. Note: Set to -1 for "never".
# Single range:
@export var breakable_requires_velocity_x_range = Vector2(-1, -1)
@export var breakable_requires_velocity_y_range = Vector2(200, 100000)

# Multiple ranges:
# Example: 1 - [Vector2(-100000, -400) and 2 - [Vector2(400, 100000)] will make the box break only if an entity (or the player) moves into it very fast horizontally.
@export var breakable_requires_velocity_x_range2 = Vector2(-1, -1)
@export var breakable_requires_velocity_y_range2 = Vector2(-1, -1)

# Advanced box is an entity that gained movement after being hit or killed. An example of an advanced box would be the large gem that floats until hit by the player, after which it gains physics-based movement, and can be broken again, opening a level portal.
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var on_hit_gain_movement : String = "none"
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var on_death_gain_movement : String = "none"
@export var on_death_prevent_death = 0 # How many times an entity death will be prevented.
@export var on_death_prevent_score = 0 # How many times an entity death will not grant any score.

@export var score_value2 = 125
@export var score_value3 = 125
@export var score_value4 = 125
@export var score_value5 = 125

@export var breakable_advanced_on_death_spawn_entity = false
@export var breakable_advanced_on_death_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var breakable_advanced_on_death_spawn_entity_quantity = 10
@export var breakable_advanced_on_death_spawn_entity_throwAround = false
@export var breakable_advanced_on_death_spawn_entity_throwAround_velocity = Vector2(400, -200)
@export var breakable_advanced_on_death_spawn_entity_throwAround_random = false
@export var breakable_advanced_on_death_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
@export var breakable_advanced_on_death_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

@export var breakable_advanced_on_death_player_velocity = -400
@export var breakable_advanced_on_death_player_velocity_jump = -600

@export var breakable_advanced_on_death_spawn_entity_spread_position = true

@export var breakable_advanced_on_hit_spawn_entity = false
@export var breakable_advanced_on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var breakable_advanced_on_hit_spawn_entity_quantity = 10
@export var breakable_advanced_on_hit_spawn_entity_throwAround = false
@export var breakable_advanced_on_hit_spawn_entity_throwAround_velocity = Vector2(400, -200)
@export var breakable_advanced_on_hit_spawn_entity_throwAround_random = false
@export var breakable_advanced_on_hit_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
@export var breakable_advanced_on_hit_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

@export var breakable_advanced_on_hit_player_velocity = -400
@export var breakable_advanced_on_hit_player_velocity_jump = -600

@export var breakable_advanced_on_hit_spawn_entity_spread_position = true


@export var breakable_advanced_portal_on_death_open = false
@export var breakable_advanced_portal_particle_quantity = 25
@export var breakable_advanced_portal_level_id = "none" # Example: "MAIN_1"
@export var breakable_advanced_portal_checkpoint_offset = Vector2(320, -64)

@export var breakable_advanced_on_touch_modulate = Color(1, 1, 1, 1)

# Major collectibles have a special pickup animation. An example would be the projectile upgrade modules.
@export var majorCollectible_module = false
@export var majorCollectible_key = false

# A temporary powerup will grant an ability for a short time, as well as a score multiplier of x2. Note: Set the ability to "none" for a simple score multiplier powerup.
@export var temporaryPowerup = false
@export_enum("none", "higher_jump", "increased_speed", "teleport_forward_on_airJump") var temporary_powerup = "none"
@export var temporary_powerup_duration = 10

@export var inventory_item = false
@export var inventory_item_scene = load("res://Enemies/togglebot.tscn")
@export var inventory_item_is_hidden = false

@export var is_healthItem = false
@export var rotting = false
@export var fall_when_button_pressed = false

@export var transform_player = false
@export var transform_player_scene = load("res://Enemies/togglebot.tscn")

@export var on_collected_effect_special = false

@export var immortal = false

# General timers. Each one can have an action assigned to it, which will be executed on the matching timer's timeout.
@export var general_timers_enabled = false

@export var t1_cooldown = 3.0
@export var t2_cooldown = 3.0
@export var t3_cooldown = 3.0
@export var t4_cooldown = 3.0
@export var t5_cooldown = 3.0
@export var t6_cooldown = 3.0

@export var t1_on_timeout_randomize_cooldown = false
@export var t2_on_timeout_randomize_cooldown = false
@export var t3_on_timeout_randomize_cooldown = false
@export var t4_on_timeout_randomize_cooldown = false
@export var t5_on_timeout_randomize_cooldown = false
@export var t6_on_timeout_randomize_cooldown = false

@export var t_randomize_cooldown_min = 0.5
@export var t_randomize_cooldown_max = 6

@export var t1_on_spawn_randomize = false
@export var t2_on_spawn_randomize = false
@export var t3_on_spawn_randomize = false
@export var t4_on_spawn_randomize = false
@export var t5_on_spawn_randomize = false
@export var t6_on_spawn_randomize = false

# Actions that can be performed when their respective general timers finish. Note that "t_trigger_[action]" stands for: GENERAL TIMER (t) _ TRIGGER ON TIMEOUT (trigger) _ BEHAVIOR ([action]).
# The values (int) of these properties correspond to a specific general timer, which will look for a behavior matching its ID number on timeout.
# A value of -1 means that this behavior will not match any general timer.
@export var t_trigger_jump = -1
@export var t_trigger_jumpAndMove = -1
@export var t_trigger_change_direction = -1
@export var t_trigger_selfDestruct = -1
@export var t_trigger_selfDestructAndSpawnEntity = -1
@export var t_trigger_sfx = -1
@export var t_trigger_randomize_speedAndJumpVelocity = -1

@export var t_trigger_spawnEntity = -1
@export var t_trigger_spawnEntity_scene = load("res://Enemies/togglebot.tscn")
@export var t_trigger_spawnEntity_quantity = 4
@export var t_trigger_spawnEntity_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity_velocity_random = true
@export var t_trigger_spawnEntity_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

@export var t_trigger_spawnEntity2 = -1
@export var t_trigger_spawnEntity2_scene = load("res://Enemies/togglebot.tscn")
@export var t_trigger_spawnEntity2_quantity = 4
@export var t_trigger_spawnEntity2_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity2_velocity_random = true
@export var t_trigger_spawnEntity2_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

@export var t_trigger_spawnEntity3 = -1
@export var t_trigger_spawnEntity3_scene = load("res://Enemies/togglebot.tscn")
@export var t_trigger_spawnEntity3_quantity = 4
@export var t_trigger_spawnEntity3_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity3_velocity_random = true
@export var t_trigger_spawnEntity3_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

# These properties decide whether or not a specific particle will be spawned:
@export var particle_star = true
@export var particle_orb = true
@export var particle_splash = true
@export var particle_leaf = true
@export var particle_star_fast = true
@export var effect_hit_enemy = true
@export var effect_kill_enemy = true
@export var effect_oneShot_enemy = true

#UNFINISHED
# General particles. These properties control when, where, how many and what kind of particle/effect is supposed to spawn.
# Note that this behavior is very similar to how GENERAL TIMERS work.
@export var p_particle_star = -1
@export var p_particle_orb = -1
@export var p_particle_splash = -1
@export var p_particle_leaf = -1
#UNFINISHED

@export var on_collected_effect_thrownAway = false

@export var heal_player = false # Will heal the player even if collected by an entity.
@export var heal_value = 1
@export var heal_entity = false

@export var award_score = true

@export var remove_delay = 1.0
@export var on_floor_bounce = false
@export var on_wall_bounce = false
@export var on_death_effect_shrink = false

@export_group("") # End of section.
# End of properties.


@export var entity_name = "none"
@export_enum("collectible", "enemy", "projectile", "box", "block") var entity_type : String = "collectible"
@export var direction_x = 1
@export var direction_y = -1

@export var on_spawn_randomize_everything = false

@export var debug = false


func _on_attacking_timer_timeout():
	attacking = false

func _on_attacked_timer_timeout():
	attacked = false

func _on_dead_timer_timeout():
	dead = false


var particle_buffer = false

func _on_particle_limiter_timeout():
	particle_buffer = false


func remove_if_corpse():
	await get_tree().create_timer(0.2, false).timeout
	if dead:
		queue_free()


# Executes on entity being added to the scene tree.
func basic_on_spawn():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	
	hitbox.set_monitorable(false)
	hitbox.set_monitoring(false)
	
	collision_main.disabled = true
	
	timer_attacking.set_paused(true)
	timer_attacked.set_paused(true)
	
	cooldown_jump.set_paused(false)
	timer_invincible.set_paused(true)
	
	remove_if_corpse()
	
	animation_general.play(animation)
	animation_general.advance(abs(position[0]) / 100)


# Executes on entity entering the camera view.
func basic_on_active():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	
	$CollisionShape2D.disabled = true
	
	$AnimatedSprite2D/AttackingTimer.set_paused(true)
	$AnimatedSprite2D/AttackedTimer.set_paused(true)
	$AnimatedSprite2D/DeadTimer.set_paused(true)
	
	#$jumpTimer.set_paused(true)
	
	remove_if_corpse()
	
	animation_general.advance(abs(position[0]) / 100)
	
	$Area2D.set_monitorable(false)
	$Area2D.set_monitoring(false)


# Executes on entity leaving the camera view.
func basic_on_inactive():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	sprite.play()
	sprite.visible = true
	
	$CollisionShape2D.disabled = false
	
	$AnimatedSprite2D/AttackingTimer.set_paused(false)
	$AnimatedSprite2D/AttackedTimer.set_paused(false)
	$AnimatedSprite2D/DeadTimer.set_paused(false)
	
	#$jumpTimer.set_paused(false)
	
	animation_general.advance(abs(position[0]) / 100)
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.set_monitorable(true)
	$Area2D.set_monitoring(true)


func enemy_stunned():
	$Area2D.monitoring = false
	$Area2D.monitorable = false
	await get_tree().create_timer(0.75, false).timeout
	$Area2D.monitoring = true
	$Area2D.monitorable = true

func basic_sprite_flipDirection():
	if not dead:
		if direction_x == 1:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
