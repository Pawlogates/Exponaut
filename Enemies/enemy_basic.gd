class_name enemy_basic
extends CharacterBody2D

var starParticle_fastScene = preload("res://Particles/particles_special_multiple.tscn")
var hit_effectScene = preload("res://Particles/hit_effect.tscn")
var dead_effectScene = preload("res://Particles/dead_effect.tscn")
var hitDeath_effectScene = preload("res://Particles/hitDeath_effect.tscn")
var starParticleScene = preload("res://Particles/particles_special.tscn")
var starParticle2Scene = preload("res://Particles/particles_star.tscn")
var orbParticleScene = preload("res://Particles/particles_special2_multiple.tscn")
var splashParticleScene = preload("res://Particles/particles_water_entered.tscn")
var effect_dustScene = preload("res://Particles/effect_dust.tscn")
var effect_dust_moveUpScene = preload("res://Particles/effect_dust_moveUp.tscn")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var attacked = false;
var attacking = false;
var dead = false;

var direction = -1
var direction_v = 1

@export var enemy_type : String = "none"
@export var debug = false

var can_turn = true

@onready var sprite = $AnimatedSprite2D

@onready var attacking_timer = $AnimatedSprite2D/AttackingTimer
@onready var attacked_timer = $AnimatedSprite2D/AttackedTimer
@onready var dead_timer = $AnimatedSprite2D/DeadTimer

@onready var particle_limiter = $particle_limiter
@onready var jump_timer: Timer = $jumpTimer

@onready var hit = $hit
@onready var death = $death

@onready var start_pos_x = global_position.x
@onready var start_pos_y = global_position.y

@onready var scanForLedge = $scanForLedge


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
		if direction == 1:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
