class_name entity_basic
extends CharacterBody2D

@onready var World = Globals.reassign_general()[0]
@onready var Player = Globals.reassign_general()[1]

@onready var sprite = $AnimatedSprite2D

@onready var timer_attacking: Timer = $sprite/timer_attacking
@onready var timer_attacked: Timer = $sprite/timer_attacked

@onready var cooldown_particles: Timer = $cooldown_particles
@onready var cooldown_collidable: Timer = $cooldown_collidable

@onready var cooldown_jump: Timer = $cooldown_jump
@onready var timer_invincible: Timer = $timer_invincible

@onready var scan_ledge = $scan_ledge

@onready var animation_general: AnimationPlayer = %animation_general


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

var global_gravity = Globals.global_gravity

var rng = RandomNumberGenerator.new()


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



func basic_on_spawn():
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
	
	animation_general.advance(abs(position[0]) / 100)


#IS IN VISIBLE RANGE?
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
