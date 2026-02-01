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

@onready var animation_all: AnimationPlayer = %animation_all
@onready var animation_general: AnimationPlayer = %animation_general
@onready var animation_color: AnimationPlayer = %animation_color

@onready var collision_main: CollisionShape2D = $collision_main
@onready var hitbox: Area2D = $hitbox
@onready var collision_hitbox: CollisionShape2D = $hitbox/collision_hitbox

@onready var scan_visible: VisibleOnScreenNotifier2D = $scan_visible

@onready var container_effect_thrownAway: Node2D = $sprite/container_effect_thrownAway

@onready var cooldown_sfx_idle: Timer = $cooldown_sfx_idle

@onready var text_container: Control = $text_container


# Patrolling - [START]
@onready var scan_patrolling: Area2D = $scan_patrolling
@onready var collision_patrolling: CollisionShape2D = $scan_patrolling/collision_patrolling
@onready var c_patrolling_target_spotted_queue: Timer = $cooldown_patrolling_target_spotted_queue
@onready var c_patrolling_target_spotted: Timer = $cooldown_patrolling_target_spotted
@onready var c_patrolling_change_direction: Timer = $cooldown_patrolling_change_direction

var patrolling_target_spotted_active = false
# Patrolling - [END]

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

var gravity = Globals.gravity

var rng = RandomNumberGenerator.new()

# Active direction can't ever be equal to 0.
var direction_active_x = 1
var direction_active_y = -1

# Last velocity cannot be equal to any value between -25 and 25 (used for behavior like bouncing).
var velocity_last_x = 25
var velocity_last_y = -25

var start_pos = Vector2(-1, -1) # If equal to Vector2(-1, -1), it will be assigned at _ready().

var collected = false
var rotten = false
var only_visual = false
var removable = false

signal collected_majorCollectible_module
signal collected_majorCollectible_key

var random_position_offset = Vector2(randf_range(0, 250), randf_range(0, 250))

var effect_shrink = false

var last_wall_normal = Vector2(99, 99)


# Start of properties.
@export_group("Main interactions.") # Section start.

@export var collectable = true
@export var hittable = false
@export var collidable = false

@export_group("") # Section end.


#---------------------------------------------------------------------------#


@export_group("Main information.") # Section start.

@export var health_value = 3
@export var damage_value = 1
@export var score_value = 25

@export_enum("stationary", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var movement_type : String = "normal"

@export var speed = 400
@export var jump_velocity = -600
@export var acceleration = 400
@export var friction = 400
@export var fall_speed = 400

@export_enum("Player", "Enemy", "none", "all") var family : String = "all"

@export_group("") # Section end.


#---------------------------------------------------------------------------#


@export_group("Movement specifics.") # Section start.

@export var can_move = false
@export var can_move_x = false
@export var can_move_y = false

@export var ignore_gravity = true
@export var on_death_ignore_gravity_stop = true

@export var speed_multiplier_x = 1.0
@export var speed_multiplier_y = 1.0
@export var acceleration_multiplier_x = 1.0
@export var acceleration_multiplier_y = 1.0
@export var friction_multiplier_x = 1.0
@export var friction_multiplier_y = 1.0
@export var gravity_multiplier_x = 1.0
@export var gravity_multiplier_y = 1.0

@export var on_wall_change_direction_x = true
@export var on_wall_change_speed = false
@export var on_wall_change_speed_multiplier = 0.5
@export var on_wall_change_velocity = true
@export var on_wall_change_velocity_multiplier = Vector2(0.8, 0.8)
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
@export var patrolling = false
@export var patrolling_targets = ["Player"] # A valid target is a node with either a matching group name, entity_type or family.
@export var patrolling_vision_size = Vector2(384, 64)
@export var patrolling_vision_pos = Vector2(192, 0)

@export var on_patrolling_spotted_spawn_entity = false
@export var on_patrolling_spotted_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var on_patrolling_spotted_spawn_entity_cooldown = 0.5

@export var on_patrolling_spotted_spawn_entity2 = false
@export var on_patrolling_spotted_spawn_entity_scene2 = load("res://Enemies/togglebot.tscn")
@export var on_patrolling_spotted_spawn_entity2_cooldown = 0.5

@export var on_patrolling_spotted_spawn_entity3 = false
@export var on_patrolling_spotted_spawn_entity_scene3 = load("res://Enemies/togglebot.tscn")
@export var on_patrolling_spotted_spawn_entity3_cooldown = 0.5

@export var on_patrolling_spotted_spawn_entity_offset = Vector2(0, 0)
@export_enum("Player", "Enemy", "none", "all") var on_patrolling_spotted_spawn_entity_family: String = "enemy"
@export var patrolling_change_direction_cooldown : float = 4.0


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


#---------------------------------------------------------------------------#


@export_group("Other properties (behavior).") # Section start.

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

@export var idle_sfx = false
@export var idle_sfx_cooldown = 4.0
@export var idle_sfx_randomize_cooldown = false

@export var rng_custom = -1 # Set to -1 for random.
@export var disable_animations = ["none", "none", "none"]

@export_enum("none", "loop_up_down", "loop_up_down_slight", "loop_scale") var animation = "loop_up_down"

# If an entity is breakable, the player can bounce off of it, and gains greater height if the jump button is pressed during the bounce, making it a "box" in most cases.
@export var breakable = true

@export var breakable_on_death_spawn_entity = false
@export var breakable_on_death_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var breakable_on_death_spawn_entity_quantity = 5
@export var breakable_on_death_spawn_entity_throwAround = false
@export var breakable_on_death_spawn_entity_throwAround_velocity = Vector2(400, -200)
@export var breakable_on_death_spawn_entity_throwAround_random = false
@export var breakable_on_death_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
@export var breakable_on_death_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

@export var breakable_on_death_player_velocity_y = -200
@export var breakable_on_death_player_velocity_y_jump = -600

@export var breakable_on_death_spawn_entity_spread_position = true

@export var breakable_on_hit_spawn_entity = false
@export var breakable_on_hit_spawn_entity_scene = load("res://Enemies/togglebot.tscn")
@export var breakable_on_hit_spawn_entity_quantity = 10
@export var breakable_on_hit_spawn_entity_throwAround = false
@export var breakable_on_hit_spawn_entity_throwAround_velocity = Vector2(400, -200)
@export var breakable_on_hit_spawn_entity_throwAround_random = false
@export var breakable_on_hit_spawn_entity_throwAround_random_velocity_minimal = Vector2(-200, -600)
@export var breakable_on_hit_spawn_entity_throwAround_random_velocity_maximum = Vector2(600, 200)

@export var breakable_on_hit_player_velocity_y = -400
@export var breakable_on_hit_player_velocity_y_jump = -600

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


@export var heal_player = false # Will heal the player even if collected by an entity.
@export var heal_value = 1
@export var heal_entity = false

@export var award_score = true

@export var remove_delay = 1.0
@export var on_floor_bounce = false
@export var on_wall_bounce = false

@export var variable_speed = false

@export var anim_alternate_walk = false
@export var anim_alternate_walk_hittable_only_during = false

@export var on_wall_jump_velocity : int = -100

@export_group("") # End of section.


#---------------------------------------------------------------------------#


@export_group("Other properties (visual).") # Section start.

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
		Globals.dm("Attempting to remove a dead entity on it leaving the screen.", 1)
		if len(container_effect_thrownAway.get_children()):
			Globals.dm("The dead entity has a potentially still visible segments. Waiting additional 4 seconds.", 2)
			await get_tree().create_timer(4, false).timeout
		
		queue_free()
		Globals.dm("The dead entity has been deleted.", 3)


# Executes on entity being added to the scene tree.
func basic_on_spawn():
	basic_on_active()
	
	add_to_group(family)
	
	if idle_sfx:
		if idle_sfx_cooldown : cooldown_sfx_idle.wait_time = idle_sfx_cooldown # If "idle_sfx_cooldown" is not equal to "0".
		if idle_sfx_randomize_cooldown : cooldown_sfx_idle.wait_time = randf_range(0.5, 8)
		cooldown_sfx_idle.start()


# Executes on entity entering the camera view.
func basic_on_inactive():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	
	collision_main.disabled = true
	
	timer_attacking.set_paused(true)
	timer_attacked.set_paused(true)
	
	#$jumpTimer.set_paused(true)
	
	remove_if_corpse()
	
	animation_general.advance(abs(position[0]) / 100)
	
	hitbox.set_monitorable(false)
	hitbox.set_monitoring(false)


# Executes on entity leaving the camera view.
func basic_on_active():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	sprite.play()
	sprite.visible = true
	
	collision_main.disabled = false
	
	timer_attacking.set_paused(false)
	timer_attacked.set_paused(false)
	
	#$jumpTimer.set_paused(false)
	
	animation_general.advance(abs(position[0]) / 100)
	
	await get_tree().create_timer(0.5, false).timeout
	hitbox.set_monitorable(true)
	hitbox.set_monitoring(true)


func enemy_stunned():
	hitbox.monitoring = false
	hitbox.monitorable = false
	await get_tree().create_timer(0.75, false).timeout
	hitbox.monitoring = true
	hitbox.monitorable = true

func basic_sprite_flipDirection():
	if not dead:
		if direction_active_x > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true


# Randomize every single property.
func randomize_everything():
	# prepare lists
	#list_sprite = prepare_list_all("Assets/Graphics/sprites/packed/enemies", [])
	#list_collectible = prepare_list_all("Collectibles", [])
	#list_enemy = prepare_list_all("Enemies", [])
	#list_box = prepare_list_all("Boxes", [])
	#list_projectile = prepare_list_all("Projectiles", ["charged", "lethalBall"])
	#
	#var list_every_object = list_collectible + list_box + list_enemy
	#var list_without_enemies = list_collectible + list_box
	#
	#list_onDeath_item_scene = list_every_object
	#list_onDeath_item_blacklist_enemy_scene = list_without_enemies
	#list_onDeath_projectile_scene = list_projectile
	#list_onDeath_secondaryProjectile_scene = list_projectile
	#list_onHit_item_scene = list_every_object
	#list_onHit_item_blacklist_enemy_scene = list_without_enemies
	#list_onSpotted_item_scene = list_every_object
	#list_onSpotted_item_blacklist_enemy_scene = list_without_enemies
	#list_onSpotted_projectile_scene = list_projectile
	#list_onSpotted_secondaryProjectile_scene = list_projectile
	#list_onTimer_item_scene = list_every_object
	#list_onTimer_item_blacklist_enemy_scene = list_without_enemies
	#list_onTimer_projectile_scene = list_projectile
	#list_onTimer_secondaryProjectile_scene = list_projectile
	#list_bonusBox_item_scene = list_every_object
	#list_bonusBox_item_blacklist_enemy_scene = list_without_enemies
	
	# randomize and apply property values
	#hp = randi_range(1, 10)
	#if applyRandom_falseTrue(12, 1):
		#SPEED = randi_range(-800, 0)
	#else:
		#SPEED = randi_range(0, 1200)
	#JUMP_VELOCITY = randi_range(400, -1200)
	#ACCELERATION = randi_range(0, 3)
	#if applyRandom_falseTrue(1,3):
		#movementType = applyRandom_fromList("list_movementType", -1)
	#else:
		#movementType = applyRandom_fromList("list_movementType_limited", -1)
	#give_score_onDeath = applyRandom_falseTrue(1, 9)
	#scoreValue = randi_range(0, 100000)
	#turnOnLedge = applyRandom_falseTrue(1, 2)
	#turnOnWall = applyRandom_falseTrue(1, 4)
	#floating = applyRandom_falseTrue(6, 1)
	#patroling = applyRandom_falseTrue(1,9)
	#afterDelay_changeDirection = applyRandom_falseTrue(3, 1)
	#afterDelay_jump = applyRandom_falseTrue(3, 1)
	#directionTimer_time = randf_range(0.5, 12)
	#jumpTimer_time = randf_range(0.5, 12)
	#onDeath_spawnObject = applyRandom_falseTrue(1, 6)
	#onDeath_spawnObject_objectAmount = randi_range(1, 8)
	#onDeath_spawnObject_throwAround = applyRandom_falseTrue(1, 3)
	#
	#if onDeath_spawnObject_objectAmount > 4:
		#onDeath_spawnObject_objectPath = load(applyRandom_fromList("list_onDeath_item_blacklist_enemy_scene", -1))
	#else:
		#onDeath_spawnObject_objectPath = load(applyRandom_fromList("list_onDeath_item_scene", -1))
	#
	#look_at_player = applyRandom_falseTrue(6,1)
	#immortal = applyRandom_falseTrue(9, 1)
	#shootProjectile_whenSpotted = applyRandom_falseTrue(1, 4)
	#dropProjectile_whenSpotted = applyRandom_falseTrue(1, 4)
	#shootProjectile_cooldown = randf_range(0.5, 6)
	#dropProjectile_cooldown = randf_range(0.5, 6)
	#scene_shootProjectile = load(applyRandom_fromList("list_onSpotted_projectile_scene", -1))
	#scene_dropProjectile = load(applyRandom_fromList("list_onSpotted_secondaryProjectile_scene", -1))
	#altDropMethod = applyRandom_falseTrue(1, 2)
	#projectile_isBouncingBall = applyRandom_falseTrue(1, 2)
	#shootProjectile_offset_X = randi_range(-120, 120)
	#shootProjectile_offset_Y = randi_range(-120, 120)
	#shootProjectile_player = applyRandom_falseTrue(3, 1)
	#shootProjectile_enemy = applyRandom_falseTrue(1, 6)
	#toggle_toggleBlocks_onDeath = applyRandom_falseTrue(1, 3)
	#whenAt_startPosition_X_stop = applyRandom_falseTrue(1, 4)
	#whenAt_startPosition_Y_stop = applyRandom_falseTrue(1, 4)
	#start_pos_leniency_X = randi_range(16, 128)
	#start_pos_leniency_Y = randi_range(16, 128)
	#onSpawn_offset_position = Vector2(randi_range(-64, 64), randi_range(-64, 64))
	#bouncy_Y = applyRandom_falseTrue(4, 1)
	#bouncy_X = applyRandom_falseTrue(1, 1)
	#ascending = applyRandom_falseTrue(1, 3)
	#damageTo_player = applyRandom_falseTrue(1, 7)
	#damageTo_enemies = applyRandom_falseTrue(1, 1)
	#stationary_disable_jump_anim = applyRandom_falseTrue(6, 1)
	#patrolRectStatic = applyRandom_falseTrue(9, 1)
	#force_static_H = applyRandom_falseTrue(12, 1)
	#force_static_V = applyRandom_falseTrue(12, 1)
	#onDeath_disappear_instantly = applyRandom_falseTrue(6, 1)
	#is_bonusBox = applyRandom_falseTrue(1, 9)
	#bonusBox_spawn_item_onDeath = applyRandom_falseTrue(1, 4)
	#bonusBox_collectibleAmount = randi_range(1, 8)
	#bonusBox_throw_around = applyRandom_falseTrue(1, 3)
	#bonusBox_spread_position = applyRandom_falseTrue(1, 3)
	#
	#if bonusBox_collectibleAmount > 4:
		#bonusBox_item_scene = load(applyRandom_fromList("list_bonusBox_item_blacklist_enemy_scene", -1))
	#else:
		#bonusBox_item_scene = load(applyRandom_fromList("list_bonusBox_item_scene", -1))
	#
	#bonusBox_requiresVelocity = applyRandom_falseTrue(1, 1)
	#bonusBox_minimalVelocity = randi_range(50, 300)
	#particles_star = applyRandom_falseTrue(1, 2)
	#particles_golden = applyRandom_falseTrue(1, 2)
	#particles_splash = applyRandom_falseTrue(1, 2)
	#enable_generalTimers = applyRandom_falseTrue(1, 6)
	#generalTimer1_cooldown = randf_range(0.5, 12)
	#generalTimer2_cooldown = randf_range(2, 12)
	#generalTimer3_cooldown = randf_range(4, 12)
	#generalTimer1_randomize_cooldown = applyRandom_falseTrue(5, 1)
	#generalTimer2_randomize_cooldown = applyRandom_falseTrue(5, 1)
	#generalTimer3_randomize_cooldown = applyRandom_falseTrue(5, 1)
	#generalTimer_min_cooldown = randf_range(0.5, 4)
	#generalTimer_max_cooldown = randf_range(4, 12)
	#t_item_amount = randi_range(1, 4)
	#t_throw_around = applyRandom_falseTrue(1, 1)
	#t_spread_position = applyRandom_falseTrue(1, 1)
	#
	#if t_item_amount > 4:
		#t_item_scene = load(applyRandom_fromList("list_onTimer_item_blacklist_enemy_scene", -1))
	#else:
		#t_item_scene = load(applyRandom_fromList("list_onTimer_item_scene", -1))
	#
	#t_afterDelay_jump = applyRandom_falseTrue(1, 1)
	#t_afterDelay_jump_timerID = randi_range(1, 6)
	#t_afterDelay_jumpAndMove = applyRandom_falseTrue(1, 1)
	#t_afterDelay_jumpAndMove_timerID = randi_range(1, 6)
	#t_afterDelay_changeDirection = applyRandom_falseTrue(1, 1)
	#t_afterDelay_changeDirection_timerID = randi_range(1, 6)
	#t_afterDelay_spawnObject = applyRandom_falseTrue(1, 1)
	#t_afterDelay_spawnObject_timerID = randi_range(1, 6)
	#t_afterDelay_selfDestruct = applyRandom_falseTrue(1, 1)
	#t_afterDelay_selfDestruct_timerID = randi_range(1, 6)
	#t_afterDelay_selfDestructAndSpawnObject = applyRandom_falseTrue(1, 1)
	#t_afterDelay_selfDestructAndSpawnObject_timerID = randi_range(1, 6)
	#t_afterDelay_idleSound = applyRandom_falseTrue(1, 1)
	#t_afterDelay_idleSound_timerID = randi_range(1, 6)
	#t_afterDelay_randomize_speedAndJumpVelocity = applyRandom_falseTrue(1, 1)
	#t_afterDelay_randomize_speedAndJumpVelocity_timerID = randi_range(1, 6)
	#t_afterDelay_spawn_collectibles = applyRandom_falseTrue(1, 1)
	#t_afterDelay_spawn_collectibles_timerID = randi_range(1, 6)
	
	modulate.r = randf_range(0, 1)
	modulate.g = randf_range(0, 1)
	modulate.b = randf_range(0, 1)
	modulate.a = randf_range(0.75, 1)
	
	await get_tree().create_timer(1, false).timeout
	#print(movementType)
	
	sprite.sprite_frames = load(Globals.random_from_list("list_sprite", -1))
	collision_main.get_shape().size = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_size()
	sprite.material.set_shader_parameter("Shift_Hue", randf_range(0, 1))
	if Globals.random_bool(3, 1):
		scale.x = randf_range(0.1, 2)
		scale.y = scale.x
	if Globals.random_bool(4, 1) : sprite.material = null
