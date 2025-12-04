class_name entity_basic
extends CharacterBody2D

var scene_particle_star = preload("res://Other/Particles/star.tscn")
var scene_effect_hit_enemy = preload("res://Other/Effects/hit_enemy.tscn")
var scene_effect_dead_enemy = preload("res://Other/Effects/dead_enemy.tscn")
var scene_effect_oneShot_enemy = preload("res://Other/Effects/oneShot_enemy.tscn")
var scene_particle_special = preload("res://Other/Particles/special.tscn")
var scene_particle_special_multiple = preload("res://Other/Particles/special_multiple.tscn")
var scene_particle_special2 = preload("res://Other/Particles/special2.tscn")
var scene_particle_special2_multiple = preload("res://Other/Particles/special2_multiple.tscn")
var scene_particle_splash = preload("res://Other/Particles/splash.tscn")
var scene_effect_dust = preload("res://Other/Effects/dust.tscn")

# States an entity can be in, used mainly for managing sprite animations. Note that an entity can be in multiple states at the same time.
var attacked = false;
var attacking = false;
var dead = false;

var can_turn = true

@onready var sprite = $AnimatedSprite2D

@onready var timer_attacking = $sprite/timer_attacking
@onready var timer_attacked = $sprite/timer_attacked

@onready var cooldown_particles = $cooldown_particles

@onready var cooldown_jump = $cooldown_jump
@onready var timer_invincible = $timer_invincible

@onready var scan_ledge = $scan_ledge

# Sound effects.
@onready var sfx_manager = $sfx_manager # The sound effects manager. When it is asked to play a sound ("Globals.sfx.emit(file, volume, pitch, fade)")
@onready var sfx = $sfx_manager/sfx # If a sound effect is already being played, another sound player will play the next one. No more than 5 sounds at a time can be played by an entity.
@onready var sfx1 = $sfx_manager/sfx1
@onready var sfx2 = $sfx_manager/sfx2
@onready var sfx3 = $sfx_manager/sfx3
@onready var sfx4 = $sfx_manager/sfx4

var global_gravity = Globals.global_gravity

@export_group("main interactions") # Section start.

@export var collectable = true
@export var hittable = false
@export var collidable = false

@export_group("") # Section end.

@export_group("major properties")

@export var health = 3
@export var damage = 1
@export var score_value = 25

@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var movement_type: String

@export var speed = 400
@export var jump_velocity = -600
@export var gravity = 1.0
@export var acceleration = 1.0
@export var friction = 1.0

@export_group("") # Section end.

@export_group("general properties") # Section start

@export var speed_multiplier_x = 1.0
@export var speed_multiplier_y = 1.0
@export var acceleration_multiplier_x = 1.0
@export var acceleration_multiplier_y = 1.0
@export var friction_multiplier_x = 1.0
@export var friction_multiplier_y = 1.0
@export var gravity_multiplier_x = 1.0
@export var gravity_multiplier_y = 1.0

@export var can_move = false
@export var can_move_x = false
@export var can_move_y = false
@export var gravity_value = 1.0

@export_group("") # Section end.

@export_group("other properties") # Section start.

@export_group("") # Section end.

@onready var world = $/root/World
@onready var player = $/root/World.player

@onready var main_collision = $CollisionShape2D

var on_floor = false
var on_wall = false
var on_wall_normal = Vector2(0, 0)
var on_ceiling = false

var velocity_last_X = 0
var velocity_last_Y = 0 

var patrolRect_width = 320
var patrolRect_height = 320

var rng = RandomNumberGenerator.new()

@export_enum("normal", "followPlayerX", "followPlayerY", "followPlayerXY", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerX", "chasePlayerX_whenSpotted", "chasePlayerY", "chasePlayerY_whenSpotted", "chasePlayerXY", "chasePlayerXY_whenSpotted", "stationary", "wave_H", "wave_V", "moveAround_startPosition_XY_when_notSpotted", "moveAround_startPosition_X_when_notSpotted", "moveAround_startPosition_Y_when_notSpotted") var movementType: String

@export_group("otherBehaviour")
@export var give_score_onDeath = true
@export var scoreValue = 1000

@export var turnOnLedge = false
@export var turnOnWall = false
@export var slowDown_onDirectionChange = true
@export var floating = false

@export var patroling = false

@export var afterDelay_changeDirection = false
@export var afterDelay_jump = false
@export var directionTimer_time = 4.0
@export var jumpTimer_time = 4.0

@export var onDeath_spawnObject = false
@export var onDeath_spawnObject_objectPath = preload("res://Collectibles/collectibleApple.tscn")
@export var onDeath_spawnObject_objectAmount = 1
@export var onDeath_spawnObject_throwAround = false

@export var immortal = false

@export var shootProjectile_whenSpotted = false
@export var dropProjectile_whenSpotted = false
@export var shootProjectile_cooldown = 0.5
@export var dropProjectile_cooldown = 0.5
@export var scene_shootProjectile : PackedScene = load("res://Projectiles/player_projectile_basic.tscn")
@export var scene_dropProjectile : PackedScene = load("res://Projectiles/player_secondaryProjectile_basic.tscn")
@export var altDropMethod = false
@export var projectile_isBouncingBall = false
@export var shootProjectile_offset_X = 0
@export var shootProjectile_offset_Y = 0
@export var shootProjectile_player = false
@export var shootProjectile_enemy = true

@export var toggle_toggleBlocks_onDeath = false

@export var whenAt_startPosition_X_stop = false
@export var whenAt_startPosition_Y_stop = false
@export var start_pos_leniency_X = 15
@export var start_pos_leniency_Y = 15

@export var onSpawn_offset_position = Vector2(0, 0)

@export var bouncy_Y = false
@export var bouncy_X = false

@export var ascending = false

@export_group("") #END OF BEHAVIOUR LIST


@export_group("specificInfo")
@export var damageTo_player = true
@export var damageTo_enemies = false
@export var familyID = 0 #will not be damaged by entities with the same familyID
@export var can_affect_player = true
@export var can_collect = false

@export var stationary_disable_jump_anim = false
@export var patrolRectStatic = false
@export var force_static_H = false
@export var force_static_V = false
@export var onDeath_disappear_instantly = false
@export var look_at_player = false

#BONUS BOX (The player can bounce off of it, and gains greater height if the jump button is pressed during the bounce.)
@export var is_bonusBox = true
@export var bonusBox_spawn_item_onDeath = false
@export var bonusBox_item_scene = preload("res://Collectibles/collectibleApple.tscn")
@export var bonusBox_collectibleAmount = 10
@export var bonusBox_throw_around = false
@export var bonusBox_spread_position = true
@export var bonusBox_requiresVelocity = true
@export var bonusBox_minimalVelocity = 100
@export var bonusBox_giveVelocity = -400
@export var bonusBox_giveVelocity_jump = -600


# General timers.
@export var enable_generalTimers = true
@export var generalTimer1_cooldown = 3.0
@export var generalTimer2_cooldown = 3.0
@export var generalTimer3_cooldown = 3.0
@export var generalTimer4_cooldown = 3.0 #not included in randomizer
@export var generalTimer5_cooldown = 3.0 #not included in randomizer
@export var generalTimer6_cooldown = 3.0 #not included in randomizer
@export var generalTimer1_randomize_cooldown = false
@export var generalTimer2_randomize_cooldown = false
@export var generalTimer3_randomize_cooldown = false
@export var generalTimer4_randomize_cooldown = false #not included in randomizer
@export var generalTimer5_randomize_cooldown = false #not included in randomizer
@export var generalTimer6_randomize_cooldown = false #not included in randomizer
@export var generalTimer_min_cooldown = 0.5
@export var generalTimer_max_cooldown = 12
@export var generalTimer_randomize_cooldown_onSpawn = false

# Actions that can be performed when their respective general timers finish. Note that "t_trigger_[action]" stands for: GENERAL TIMER (t) _ TRIGGER ON TIMEOUT (trigger) _ BEHAVIOUR ([action]).
# The values (int) of these properties correspond to a specific general timer, which will look for a behaviour matching its ID number on timeout.
# A value of -1 means that this behaviour will not match any general timer.
@export var t_trigger_jump = -1
@export var t_trigger_jumpAndMove = -1
@export var t_trigger_change_direction = -1
@export var t_trigger_spawnObject = -1
@export var t_trigger_selfDestruct = -1
@export var t_trigger_selfDestructAndSpawnObject = -1
@export var t_trigger_idleSound = -1
@export var t_trigger_randomize_speedAndJumpVelocity = -1
@export var t_trigger_spawn1 = -1
@export var t_trigger_spawn2 = -1
@export var t_trigger_spawn3 = -1

# Whether or not a specific particle will be spawned.
@export var particle_star = true
@export var particle_orb = true
@export var particle_splash = true
@export var particle_leaf = true
@export var particle_star_fast = true
@export var effect_hit_enemy = true
@export var effect_kill_enemy = true
@export var effect_oneShot_enemy = true

# General particles. These properties control when, where, how many and what kind of particle/effect is supposed to spawn.
# Note that this behaviour is very similar to how GENERAL TIMERS work.
@export var p_particle_star = -1
@export var p_particle_orb = -1
@export var p_particle_splash = -1
@export var p_particle_leaf = -1

@export var direction_x = 1
@export var direction_y = -1
@export var randomize_everything_onSpawn = false
@export var entity_name = "none"
@export var debug = false

@export_group("") # End of section.
# End of properties.

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



func basic_onReady():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	
	$Area2D.set_monitorable(false)
	$Area2D.set_monitoring(false)
	
	$CollisionShape2D.disabled = true
	
	$AnimatedSprite2D/AttackingTimer.set_paused(true)
	$AnimatedSprite2D/AttackedTimer.set_paused(true)
	$AnimatedSprite2D/DeadTimer.set_paused(true)
	
	#$jumpTimer.set_paused(false)
	
	remove_if_corpse()


#IS IN VISIBLE RANGE?
func basic_offScreen_unload():
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
	
	$Area2D.set_monitorable(false)
	$Area2D.set_monitoring(false)


func basic_offScreen_load():
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
