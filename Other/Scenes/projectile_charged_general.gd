extends CharacterBody2D

# This script is one of the very few from before the refactor, that are still used in the game. Please don't look at this...

@onready var shot_main = $Area2D
@onready var charged_shot_buffer = $Timer

@onready var player_projectile_phaser = $"."

@onready var shot_anim = $AnimationPlayer
@onready var charged_shot = $Area2D/charged_shot
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

@onready var projectile_hitbox: CollisionShape2D = $Area2D/projectile_hitbox
@onready var sprite: AnimatedSprite2D = $Area2D/sprite

var attack_melee_block_movement = false
var block_movement = false
var invulnerable = false

var set_player_attack_cooldown = true
var family = "Player"

var projectile_shot = false
var charged = false

var started = false

const FOLLOW_SPEED = 0.4
var mouse_pos

var rng = RandomNumberGenerator.new()
var x

var enemyProjectile = false
var playerProjectile = true

var upward_shot = false
var downward_shot = false

var bouncy = false

var can_collect = true
var can_move = true
var collected = false
var entity_type = "projectile"
var dead = false
var damage_value = 15


func _ready():
	set_name("player_projectile_phaser")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if projectile_shot:
		if projectile_hitbox.disabled:
			modulate = Color.BLACK
			sprite.modulate.a = 0.5
		else:
			modulate = Color.WHITE
			sprite.modulate.a = 1
	
	if Input.is_action_just_released("attack_secondary") and not charged and not started:
		Globals.projectile_shot.emit()
		charged_shot_buffer.stop()
		x = rng.randf_range(0, 2)
		audio_stream_player_2d.set_pitch_scale(x)
		audio_stream_player_2d.play()
		
		charged_shot.visible = false
		
		if Input.is_action_pressed("move_down") and projectile_shot == false:
			direction_y = 1
			
			shot_anim.play("shot_animDOWN")
			player_projectile_phaser.visible = true
			projectile_shot = true
			
			can_collect = true
			await get_tree().create_timer(0.5, false).timeout
			upward_shot = true

		elif Globals.player_direction_x_active == -1 and projectile_shot == false:
				shot_anim.play("shot_animL")
				player_projectile_phaser.visible = true
				projectile_shot = true
	
		elif Globals.player_direction_x_active == 1 and projectile_shot == false:
				shot_anim.play("shot_animR")
				player_projectile_phaser.visible = true
				projectile_shot = true
	
	elif charged == true and Input.is_action_just_released("attack_secondary") and charged and not started and not projectile_shot and Input.is_action_pressed("move_down"):
		direction_y = 1
		
		damage_value = 3
		started = true
		charged_shot.visible = false
		audio_stream_player_2d.play()
		player_projectile_phaser.visible = true
		shot_anim.play("shot_anim_CHARGED_DOWN")
		charged_shot_buffer.stop()
		projectile_shot = true
		
		can_collect = true
		await get_tree().create_timer(0.5, false).timeout
		upward_shot = true
	
	
	elif charged == true and Input.is_action_just_released("attack_secondary") and charged and not started and not projectile_shot and Globals.player_direction_x_active == 1:
		damage_value = 3
		started = true
		charged_shot.visible = false
		audio_stream_player_2d.play()
		player_projectile_phaser.visible = true
		shot_anim.play("shot_anim_CHARGED_R")
		Globals.projectile_shot.emit()
		charged_shot_buffer.stop()
		projectile_shot = true
	
	elif charged == true and Input.is_action_just_released("attack_secondary") and charged and not started and not projectile_shot and Globals.player_direction_x_active == -1:
		damage_value = 3
		started = true
		charged_shot.visible = false
		audio_stream_player_2d.play()
		player_projectile_phaser.visible = true
		shot_anim.play("shot_anim_CHARGED_L")
		Globals.projectile_shot.emit()
		charged_shot_buffer.stop()
		projectile_shot = true


func _on_timer_timeout():
	charged = true
	Globals.projectile_charged.emit()


func _on_animation_player_animation_finished(_shot_anim):
	queue_free()


func _on_animation_player_animation_started(anim_name):
	if anim_name == "shot_animL" or anim_name == "shot_anim_CHARGED_L":
		direction_x = -1
		await get_tree().create_timer(0.5, false).timeout
		direction_x = 1
	
	elif anim_name == "shot_animR" or anim_name == "shot_anim_CHARGED_R":
		direction_x = 1
		await get_tree().create_timer(0.5, false).timeout
		direction_x = -1


var direction_x = 0
var direction_y = 0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("entity_hitbox") : return
	
	var target = area.get_parent()
	
	if projectile_shot:
		if target.can_move and not target.dead:
			if target.entity_type == "enemy":
				if abs(target.velocity.y) <= 50:
					target.handle_hit(self, damage_value * (1 + 0.1 * Globals.player_level))
					Globals.Player.camera.effect((target.position - Globals.player_position) * 2, Vector2(1.5, 1.5), randi_range(-10, 10), 4)
					await get_tree().create_timer(0.25, true).timeout
					Globals.Player.camera.effect(Vector2(0, 0), Vector2(1, 1), 0, 1)
					
					Globals.spawn_scenes(Globals.World, Globals.scene_effect_hit_enemy, 1, target.position)
			
			target.velocity.x = direction_x * 500 * randf_range(0.9, 1.1)
			target.velocity.y = -250 * randf_range(0.9, 1.1)
			
			if direction_y == 1:
				target.velocity.y = -250 * randf_range(0.9, 1.1)
			elif direction_y == -1:
				target.velocity.y = -500 * randf_range(0.9, 1.1)
	
	if target.entity_type == "enemy" or target.entity_type == "box" or target.can_move:
		target.handle_hit(self, damage_value)

func toggle_direction_x():
	direction_x *= -1

func toggle_direction_y():
	direction_y *= -1
