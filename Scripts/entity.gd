extends entity_basic

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

# Start of properties.
@export_group("Main interactions.") # Section start.

@export var collectable = true
@export var hittable = false
@export var collidable = false

@export_group("") # Section end.

@export_group("Main information.") # Section start.

@export var health = 3
@export var damage = 1
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
@export var on_death_spawn_entity_scene = load("res://Collectibles/collectibleApple.tscn")
@export var on_death_spawn_entity_quantity = 1
@export var on_death_spawn_entity_spreadPosition = false
@export var on_death_spawn_entity_spreadPosition_multiplier_x = 1.0
@export var on_death_spawn_entity_spreadPosition_multiplier_y = 1.0
@export var on_death_spawn_entity_throwAround = false
@export var on_death_spawn_entity_throwAround_multiplier_x = 1.0
@export var on_death_spawn_entity_throwAround_multiplier_y = 1.0

@export var on_death_toggle_toggleBlocks = false
@export var on_death_toggle_toggleBlocks_id = 0

@export var on_death_disappearInstantly = false # Spawns some particles and removes the entity right after.

# Behavior triggered on entity spotting a "target" entity:
@export var spotted_patrolling = false
@export var spotted_targets = "Player" # A valid target is a node with either a matching group name, entity_type or family.
@export var spotted_vision_size = Vector2(256, 64)

@export var on_spotted_spawn_entity = false
@export var on_spotted_spawn_entity_scene = load("res://Projectiles/player_projectile_basic.tscn")
@export var on_spotted_spawn_entity_cooldown = 0.5

@export var on_spotted_spawn_entity2 = false
@export var on_spotted_spawn_entity_scene2 = load("res://Projectiles/player_projectile_basic.tscn")
@export var on_spotted_spawn_entity2_cooldown = 0.5

@export var on_spotted_spawn_entity3 = false
@export var on_spotted_spawn_entity_scene3 = load("res://Projectiles/player_projectile_basic.tscn")
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

@export_enum("none", "loop_upDown", "loop_upDown_slight", "loop_scale") var animation = "loop_upDown"

# If an entity is breakable, the player can bounce off of it, and gains greater height if the jump button is pressed during the bounce, making it a "box" in most cases.
@export var breakable = false

@export var breakable_on_death_spawn_entity = false
@export var breakable_on_death_spawn_entity_scene = load("res://Collectibles/collectibleApple.tscn")
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
@export var breakable_on_hit_spawn_entity_scene = load("res://Collectibles/collectibleApple.tscn")
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

# Advanced box. An example of an advanced box would be the large gem that floats until hit by the player, after which it gains physics-based movement, and can be broken again, opening a level portal.
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var breakable_advanced_on_hit_gain_movement : String = "none"
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var breakable_advanced_on_death_gain_movement : String = "none"
@export var breakable_advanced_on_death_prevent_death = 0 # How many times an entity death will be prevented.
@export var breakable_advanced_on_death_prevent_score = 0 # How many times an entity death will not grant any score.

@export var breakable_advanced_score_value = 125
@export var breakable_advanced_score_value2 = 125
@export var breakable_advanced_score_value3 = 125
@export var breakable_advanced_score_value4 = 125
@export var breakable_advanced_score_value5 = 125

@export var breakable_advanced_on_death_spawn_entity = false
@export var breakable_advanced_on_death_spawn_entity_scene = load("res://Collectibles/collectibleApple.tscn")
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
@export var breakable_advanced_on_hit_spawn_entity_scene = load("res://Collectibles/collectibleApple.tscn")
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
@export var breakable_advanced_portal_particle_amount = 25
@export var breakable_advanced_portal_level_id = "none" # Example: "MAIN_1"
@export var breakable_advanced_portal_checkpoint_offset = Vector2(320, -64)

# Major collectibles have a special pickup animation. An example would be the projectile upgrade modules.
@export var majorCollectible_module = false
@export var majorCollectible_key = false

# A temporary powerup will grant an ability for a short time, as well as a score multiplier of x2. Note: Set the ability to "none" for a simple score multiplier powerup.
@export var temporaryPowerup = false
@export_enum("none", "higher_jump", "increased_speed", "teleport_forward_on_airJump") var temporary_powerup = "none"
@export var temporary_powerup_duration = 10

@export var inventory_item = false
@export var inventory_item_scene = load("res://Collectibles/collectibleApple.tscn")
@export var inventory_item_is_hidden = false

@export var is_healthItem = false
@export var rotting = false
@export var fall_when_button_pressed = false

@export var transform_player = false
@export var transform_player_scene = load("res://Collectibles/collectibleApple.tscn")

@export var on_collected_effect_special = false

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
@export var t_trigger_spawnEntity_scene = load("res://Enemies/friendly_butterfly_apples.tscn")
@export var t_trigger_spawnEntity_quantity = 4
@export var t_trigger_spawnEntity_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity_velocity_random = true
@export var t_trigger_spawnEntity_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

@export var t_trigger_spawnEntity2 = -1
@export var t_trigger_spawnEntity2_scene = load("res://Enemies/friendly_butterfly_apples.tscn")
@export var t_trigger_spawnEntity2_quantity = 4
@export var t_trigger_spawnEntity2_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity2_velocity_random = true
@export var t_trigger_spawnEntity2_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

@export var t_trigger_spawnEntity3 = -1
@export var t_trigger_spawnEntity3_scene = load("res://Enemies/friendly_butterfly_apples.tscn")
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

@export_group("") # End of section.
# End of properties.


func _ready():
	basic_on_spawn()
	reassign_general()
	reassign_movement_type_id()

func _process(delta):
	if direction_x != 0:
		direction_active_x = direction_x
	
	if look_at_player_x:
		if position.x < Player.position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	
	if look_at_player_y:
		if position.y < Player.position.y:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
	
	if look_at_player_rotate:
		rotation_degrees = 0
		look_at(Player.position)
		rotation_degrees += look_at_player_rotate_offset
	
	if not on_collected_effect_thrownAway:
		if not animation_general.current_animation == "fade_out_up":
			removable = true
	
	if removable:
		print("Removed already collected entity.")
		queue_free()
	
	if on_collected_effect_special:
		position = lerp(position, World.player.position + random_position_offset, delta)
	
	if on_collected_effect_thrownAway:
		if effect_thrownAway_active:
			effect_thrownAway(delta)


func handle_gravity(delta):
	if can_move:
		if can_move_y:
			if not is_on_floor():
				velocity.y += gravity * delta


func direction_toward_target_x(target):
	if position.x < Player.position.x:
		direction_x = 1
	else:
		direction_x = -1

func direction_toward_target_y(target : Node):
	if position.y < target.position.y:
		direction_y = 1
	else:
		direction_y = -1


# The entity's HITBOX has been touched by the player, or another entity's MAIN COLLISION.
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Executes only if the node is a valid one to interact with.
	if not body.is_in_group("Player") and body.is_in_group("Entity") : return
	
	# Assigns an "inside" variable depending on the node that just entered this entity. Used mostly for the pushing movement logic.
	inside_check_enter(body)
	
	# Tries to COLLECT the entity.
	if collectable and not collected:
		if not rotten or body.can_collect:
			handle_collectable(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	inside_check_exit(body)


# The entity's HITBOX has been touched by another entity's HITBOX.
func _on_hitbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_hitbox_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


func reassign_movement_type_id():
	if movement_type == "normal":
		movement_type_id = 0
	elif movement_type == "move_x":
		movement_type_id = 1


# Functionality around entities being inside other entities, which causes them to modify their movement. This is the case when this entity's HITBOX is inside another entity's MAIN COLLISION.
# Note that this does not include behaviors such as the entity being COLLECTED by the player, or being HIT by a projectile.
var inside_player = 0
var inside_player_last = Node
var inside_player_all : Array = []
var inside_entity = 0
var inside_entity_last = Node
var inside_entity_all : Array = []

var is_collidable = true

func inside_check_enter(body):
	if body.is_in_group("Player"):
		
		inside_player += 1
		inside_player_last = body
		inside_player_all += body
	
	elif body.is_in_group("Entity"):
		
		inside_entity += 1
		inside_entity_last = body
		inside_entity_all += body
	
	else:
		return
	
	if collidable and is_collidable:
		
		if body.is_in_group("Player"):
			print("Player entered an entity " + "(" + entity_name + ").")
		else:
			print("An entity " + "(" + body.entity_name + "). has entered another entity " + "(" + entity_name + ").")
		
		collidable = false
		cooldown_collidable.wait_time = collidable_cooldown
		cooldown_collidable.start()
		
		if enteredFromAboveAndNotMoving_enable and body.position.y <= position.y and abs(body.velocity.x) < 25:
				direction_x = 0
				velocity.y = enteredFromAboveAndNotMoving_velocity
		
		elif on_entityEntered_change_direction_copyEntity:
			
			direction_x = body.direction
		
		elif on_entityEntered_change_direction_basedOnPosition:
				
			if body.position.x > position.x:
				direction_x = 1
				
			else:
				direction_x = -1


func inside_check_exit(body):
	if body.is_in_group("Player"):
		
		inside_player -= 1
		inside_player_last = body
		inside_player_all -= body
	
	elif body.is_in_group("Entity"):
		
		inside_entity -= 1
		inside_entity_last = body
		inside_entity_all -= body
	
	else:
		return
	
	
	if not inside_player and not inside_entity:
		direction_x = 0


# The entity moves (the function is executed every frame) according to its movement type, and only one is active at a time. (This is unlike the other properties, which synergize with eachother to provide a very vast selection of unique object behaviors).
# Movement types: 0 - "normal", 1 - "move_x", 2 - "move_y", 3 - "move_xy", 4 - "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted".
func handle_movement(delta):
	if movement_type_id == 0:
		movement_normal(delta)
	elif movement_type_id == 1:
		movement_move_x(delta)


# Movement types:

# The entity doesn't move by itself, it just falls down to the ground and can be affected by other entities and the player.
func movement_normal(delta):
	if not dead:
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)

# The entity always attempts to move horizontally, as it's direction can never be equal to 0.
func movement_move_x(delta):
	handle_gravity(delta)
	
	if direction_x == 0:
		direction_x = direction_active_x # Active means "last value considered active", which in case of velocity, would be anything except 0 (but in this case its actually everything between -25 and 25).
	
	if not dead:
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)

# Same as above, but vertical.
func movement_move_y(delta):
	if direction_y == 0:
		direction_y = direction_active_y
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)

# Same as above, but both horizontal and vertical.
func movement_move_xy(delta):
	if direction_x == 0:
		direction_x = direction_active_x
	
	if direction_y == 0:
		direction_y = direction_active_y
	
	if not dead:
		move_in_direction_y(delta)
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)

# Entity moves horizontally, towards the player.
func movement_follow_player_x(delta):
	handle_gravity(delta)
	
	if can_turn:
		if position.x < Player.position.x:
			direction_x = 1
		else:
			direction_x = -1
	
	if not dead:
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)

# Same as above, but vertical.
func movement_follow_player_y(delta):
	if can_turn:
		if position.y < Player.position.y:
			direction_y = 1
		else:
			direction_y = -1
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)

# Same as above, but both horizontal and vertical.
func movement_follow_player_xy(delta):
	if can_turn:
		if position.x < Player.position.x:
			direction_x = 1
		else:
			direction_x = -1
		
		if position.y < Player.position.y:
			direction_y = 1
		else:
			direction_y = -1
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func movement_follow_player_x_if_spotted(delta):
	handle_gravity(delta)
	
	if spotted and not dead:
		movement_follow_player_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_follow_player_y_if_spotted(delta):
	if spotted and not dead:
		move_in_direction_x(delta)
		movement_follow_player_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)


func movement_follow_player_xy_if_spotted(delta):
	if spotted and not dead:
		movement_follow_player_xy(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)

# Entity will "chase" the player, which means rapidly closing the distance between them, no matter the gap length.
func movement_chase_player_x(delta):
	handle_gravity(delta)
	
	if not dead:
		movement_chase_player_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_chase_player_y(delta):
	if not dead:
		movement_chase_player_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func movement_chase_player_xy(delta):
	if not dead:
		movement_chase_player_xy(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func movement_chase_player_x_if_spotted(delta):
	handle_gravity(delta)
	
	if spotted and not dead:
		movement_chase_player_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_chase_player_y_if_spotted(delta):
	if spotted and not dead:
		movement_chase_player_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
		move_toward_zero_velocity_y(delta)
	
	if dead:
		handle_gravity(delta)


func movement_chase_player_xy_if_spotted(delta):
	if spotted and not dead:
		movement_chase_player_xy(delta)
	else:
		move_toward_zero_velocity_x(delta)
		move_toward_zero_velocity_y(delta)
	
	if dead:
		handle_gravity(delta)

# Wave-like movement on the axis opposite to the straight line movement happening alongside it.
# Note: This movement type (wave_x and wave_y) is best used alongside the "can_move_y" or "can_move_x" being set to false.
var w_target_velocity_x = -100

func movement_wave_x(delta):
	if not dead:
		if velocity.y in range(direction_y * w_target_velocity_x,direction_y * w_target_velocity_x * 100):
			
			direction_y *= -1
	
	velocity.y = move_toward(velocity.y, w_target_velocity_x, delta * speed * speed_multiplier_y)
	
	if not dead:
		movement_move_x(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


var w_target_velocity_y = 100

func movement_wave_y(delta):
	if not dead:
		if velocity.y in range(direction_y * w_target_velocity_y,direction_y * w_target_velocity_y * 100):
			
			direction_y *= -1
	
	velocity.y = move_toward(velocity.y, w_target_velocity_y, delta * speed * speed_multiplier_y)
	
	if not dead:
		movement_move_x(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


#"move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted"
func move_around_startPosition_x(delta):
	handle_gravity(delta)
	
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)


func move_around_startPosition_y(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)
		movement_move_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func move_around_startPosition_xy(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		if position.y < start_pos.y:
			direction_y = -1
		else:
			direction_y = 1
		
		movement_move_x(delta)
		movement_move_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func move_around_startPosition_x_if_not_spotted(delta):
	handle_gravity(delta)
	
	if spotted and not dead:
		move_around_startPosition_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func move_around_startPosition_y_if_not_spotted(delta):
	if spotted and not dead:
		move_around_startPosition_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)


func move_around_startPosition_xy_if_not_spotted(delta):
	if spotted and not dead:
		move_around_startPosition_x(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)


func reassign_general():
	World = Globals.reassign_general()[0]
	Player = Globals.reassign_general()[1]
	
	global_gravity = Globals.global_gravity


func _on_cooldown_collidable_timeout() -> void:
	is_collidable = true


func _on_cooldown_remove_corpse_timeout() -> void:
	var effect_death = Globals.scene_effect_dead_enemy.instantiate()
	effect_death.position = position
	Globals.World.add_child(effect_death)


func move_toward_zero_velocity_x(delta):
	velocity.x = move_toward(velocity.x, 0, delta * friction)

func move_toward_zero_velocity_y(delta):
	velocity.y = move_toward(velocity.y, 0, delta * friction)

func move_in_direction_x(delta):
	velocity.x = move_toward(velocity.x, speed * speed_multiplier_x, delta * acceleration * acceleration_multiplier_x)

func move_in_direction_y(delta):
	velocity.y = move_toward(velocity.y, speed * speed_multiplier_y, delta * acceleration * acceleration_multiplier_y)

func chase_target_x(delta, target : Node):
	position.x = lerp(position.x, Player.position, delta)

func chase_target_y(delta, target : Node):
	position.y = lerp(position.y, Player.position, delta)

func chase_target_xy(delta, target : Node):
	position = lerp(position, Player.position, delta)


func change_direction_x(value):
	direction_x = value

func change_direction_y(value):
	direction_y = value

func reverse_direction_x():
	direction_x *= -1

func reverse_direction_y():
	direction_y *= -1

@export var onCollected_effect_thrownAway = false
var effect_thrownAway_active = false
var rolled_effect_thrownAway_scale = randf_range(0.1, 10)
var effect_thrownAway_scale = Vector2(rolled_effect_thrownAway_scale, rolled_effect_thrownAway_scale)
var effect_thrownAway_rotation = randi_range(-720, 720)
@export var effect_thrownAway_randomize_velocity = true
@export var effect_thrownAway_randomize_velocity_multiplier_x = 1
@export var effect_thrownAway_randomize_velocity_multiplier_y = 1
var effect_thrownAway_velocity = Vector2(randi_range(-1000 * effect_thrownAway_randomize_velocity_multiplier_x, 1000 * effect_thrownAway_randomize_velocity_multiplier_x), randi_range(-500 * effect_thrownAway_randomize_velocity_multiplier_y, -1000 * effect_thrownAway_randomize_velocity_multiplier_y))
var effect_thrownAway_applied_velocity = false

func effect_thrownAway(delta):
	if not effect_thrownAway_active : return
	if not effect_thrownAway_applied_velocity:
		effect_thrownAway_applied_velocity = true
		can_move = false
		velocity = Vector2(effect_thrownAway_velocity)
		only_visual = true
		z_index += 10
		$CollisionShape2D.disabled = true
		if Globals.gameState_debug:
			Globals.display_message("Applying velocity to collected entity.")
	
	sprite.scale.x = lerp(sprite.scale.x, effect_thrownAway_scale[0], delta / 2)
	sprite.scale.y = lerp(sprite.scale.y, effect_thrownAway_scale[1], delta / 2)
	sprite.rotation_degrees = lerp(float(sprite.rotation_degrees), float(effect_thrownAway_rotation), delta)


func handle_award_score():
	Globals.level_score += score_value
	
	if Globals.combo_collectibles > 1:
		Globals.combo_score += score_value * Globals.combo_tier
	
	# Combo tier increases every 5 collectibles collected during a combo, usually up to x10, and eventually to x11 after reaching a combo streak of 100.
	if Globals.combo_tier > 1:
		
		%collect1.pitch_scale = 1.1
		
		if Globals.combo_tier > 2:
			
			%collect1.pitch_scale = 1.2
			
			if Globals.combo_tier > 3:
				
				%collect1.pitch_scale = 1.3
				
				if Globals.combo_tier > 4:
					
					%collect1.pitch_scale = 1.4
					
					sprite.material = Globals.material_rainbow2.duplicate()
					sprite.material.set_shader_parameter("strength", 0.5)
	
	spawn_scene(Globals.scene_particle_star, Globals.combo_tier)
	
	else:
		%collect1.pitch_scale = 1
		bonus_material.set_shader_parameter("strength", 0.0)
	
	sfx_collect1.play()
	
	%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
	%collectedDisplay.position += Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	animation_player.play("fadeOut_up")
	animation_player2.play("score_value")
	
	#Handle visual effect of collecting the 20th collectible in a streak (resulting in a x5 multiplier).
	if Globals.collected_in_cycle == 20:
		var max_multiplier_particle_amount = 50
		while max_multiplier_particle_amount > 0:
			max_multiplier_particle_amount -= 1
			call_deferred("spawn_particle_score", 2)
	
	# Handle double score particles (while a temporary powerup is active).
	if get_node_or_null("$/root/World/player"):
		if not player.double_score:
			return
		
		var effective_score = collectibleScoreValue * Globals.combo_tier
		var particle_amount : int
		
		if collectibleScoreValue * Globals.combo_tier < 25:
			particle_amount = effective_score
		else:
			particle_amount = 25
		
		while particle_amount > 0:
			particle_amount -= 1
			call_deferred("spawn_particle_score", 1)

func spawn_particle_score(scale_multiplier : int):
	var particle = Globals.scene_particle_special_multiple.instantiate()
	particle.position = position
	particle.scale = Vector2(scale_multiplier, scale_multiplier)
	world.add_child(particle)


func spawn_collectibles():
	while spawnedAmount > 0:
		spawnedAmount -= 1
		spawn_item()
	
	var hit_effect = Globals.scene_effect_hit_enemy.instantiate()
	add_child(hit_effect)


var rng = RandomNumberGenerator.new()

func spawn_item():
	var item
	
	if item_scene is String:
		item = load(item_scene).instantiate()
	else:
		item = item_scene.instantiate()
	
	if "velocity" in item:
		item.position = global_position
		item.velocity.x = rng.randf_range(item_velSpread, -item_velSpread)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
		
		world.add_child(item)
	else:
		spawn_item_static()


func spawn_item_static():
	var item = load(item_scene).instantiate()
	item.position.x = global_position.x + rng.randf_range(item_posSpread, -item_posSpread)
	item.position.y = global_position.y + rng.randf_range(item_posSpread, -item_posSpread)
	
	world.add_child(item)



func spawn_portal():
	var portal = preload("res://Objects/shrine_portal.tscn").instantiate()
	portal.level_ID = shrineGem_portal_level_ID
	portal.level_filePath = shrineGem_level_filePath
	portal.particle_amount = shrineGem_particle_amount
	portal.position = start_pos
	
	world.add_child(portal)



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "collect_special":
		print("Special collectible has been deleted after the collect animation finished.")
		queue_free()


func random_pitch_collect():
	sfx_collect1.pitch_scale = (randf_range(0.8, 1.2))
	sfx_collect1.play()


#AREAS (water, wind, etc.)
var inside_wind = 0 # If above 0, the item is affected by wind.
var insideWind_direction_X = 0
var insideWind_direction_Y = 0
var insideWind_strength_X = 1.0
var insideWind_strength_Y = 1.0

var inside_water = 0
var insideWater_multiplier = 1

func handle_inside_zone(delta):
	if inside_wind:
		velocity.x += SPEED / 5 * insideWind_direction_X * insideWind_strength_X * delta


func reassign_player():
	player = get_tree().get_first_node_in_group("player_root")


func handle_collectable(body): # The main function of the "collectible" entity type. The word "collectable" refers to a MAIN BEHAVIOR type, while "collectible" is (most of the time) the entity TYPE of ones with that main behavior type.
	Globals.entity_collected.emit(value)
	
	if award_score:
		handle_award_score()
	
	if majorCollectible_module:
		var value = Globals.score_multiplier * Globals.combo_multiplier
		Globals.collected_majorCollectible_module.emit(value)
	
	if majorCollectible_key:
		var value = Globals.score_multiplier * Globals.combo_multiplier
		Globals.collected_majorCollectible_key.emit(value)
	
	
	if heal_player:
		if inside_player and not collected:
			collected = true
			
			Globals.itemCollected.emit()
			Globals.increaseHp1.emit()
			
			animation_general.play("fade_out_up")
			sfx_manager.sfx_play(Globals.sfx_player_heal, 1.0, 0.0)
			body.add_child(Globals.scene_particle_star.instantiate())
			body.add_child(Globals.scene_particle_star.instantiate())
			body.add_child(Globals.scene_particle_star.instantiate())
			body.add_child(Globals.scene_particle_star.instantiate())
			
			var feathers = Globals.scene_particle_feather_multiple.instantiate()
			feathers.position = position
			world.add_child(feathers)
			
			feathers = Globals.scene_particle_star.instantiate()
			feathers.position = position
			world.add_child(feathers)
	
	
	if is_gift and inside_player and not collected or is_gift and inside_projectile and body.can_collect and not collected:
		if get_tree().get_nodes_in_group("in_inventory").size() < 6:
			var item = inventory_item_scene.instantiate()
			world.get_node("HUD/Inventory/InventoryContainer").add_child(item)
			item.item_toSpawn = inventory_itemToSpawn
			item.display_region_rect = inventory_texture_region
		
		world.get_node("HUD/Inventory").call("check_inventory")
		get_tree().call_group("in_inventory", "selected_check")
		
		#get_tree().call_group("in_inventory", "itemOrder_correct")
	
	
	if is_shrineGem:
		if inside_player:
			%AnimatedSprite2D.modulate.r = 0.3
			%AnimatedSprite2D.modulate.a = 0.5
			
		elif inside_projectile and not collected:
			if not body.upward_shot:
				velocity.y = -200
				velocity.x = 400 * body.direction
			else:
				velocity.y = -600
				
			stop_upDownLoopAnim = true
			floating = false
			if get_node_or_null("$hit1") : %hit1.play()
			%AnimationPlayer2.stop()
			if not shrineGem_is_finalLevel:
				%AnimationPlayer2.play("hit")
			else:
				%AnimationPlayer2.play("hit_finalLevel")
			
			var star = Globals.scene_particle_star.instantiate()
			star.position = position
			world.add_child(star)
			
			add_child(Globals.scene_particle_splash.instantiate())
		
			if shrineGem_destructible:
				hp -= 1
				if hp <= 0 and not collected:
					collected = true
					stop_upDownLoopAnim = false
					
					add_child(Globals.scene_effect_hit_enemy.instantiate())
					add_child(Globals.scene_particle_star.instantiate())
					add_child(Globals.scene_particle_splash.instantiate())
					add_child(Globals.dust.instantiate())
					
					#await get_tree().create_timer(0.5, false).timeout
					
					Globals.itemCollected.emit()
					
					if shrineGem_giveScore:
						award_score()
						
					if shrineGem_spawnItems:
						call_deferred("spawn_collectibles")
						Globals.boxBroken.emit()
					
					if shrineGem_openPortal:
						call_deferred("spawn_portal")
					
					if shrineGem_portal_level_ID != "none" and SaveData.get("state_" + str(shrineGem_portal_level_ID)) == 0:
						SaveData.set(("state_" + str(shrineGem_portal_level_ID)), -1)
						Globals.save_progress.emit()


func handle_hittable(body):
	pass


func handle_collidable(body):
	pass


func spawn_scene(scene, quantity):
	for current in range(quantity):
		var instance = scene.instantiate()
		World.add_child(instance)
