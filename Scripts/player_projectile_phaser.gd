extends Node2D


@onready var shot_main = $Area2D
@onready var charged_shot_buffer = $Timer

@onready var player_projectile_phaser = $"."

@onready var shot_anim = $AnimationPlayer
@onready var charged_shot = $Area2D/charged_shot
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


var projectile_shot = false
var charged = false

var damageValue = 1


var started = false

const FOLLOW_SPEED = 0.4
var mouse_pos

var rng = RandomNumberGenerator.new()
var x

var enemyProjectile = false
var playerProjectile = true


func _ready():
	set_name.call_deferred("player_projectile_phaser")



var can_collect = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	if Input.is_action_just_released("attack_fast") and not charged and not started:
		Globals.shot.emit()
		charged_shot_buffer.stop()
		x = rng.randf_range(0, 2)
		audio_stream_player_2d.set_pitch_scale(x)
		audio_stream_player_2d.play()
		
		charged_shot.visible = false
		
		if Input.is_action_pressed("move_DOWN") and projectile_shot == false:
			shot_anim.play("shot_animDOWN")
			player_projectile_phaser.visible = true
			projectile_shot = true
			
			can_collect = true

		elif Globals.direction == -1 and projectile_shot == false:
				shot_anim.play("shot_animL")
				player_projectile_phaser.visible = true
				projectile_shot = true
	
		elif Globals.direction == 1 and projectile_shot == false:
				shot_anim.play("shot_animR")
				player_projectile_phaser.visible = true
				projectile_shot = true
				
				
			
			
	elif charged == true and Input.is_action_just_released("attack_fast") and charged and not started and not projectile_shot and Input.is_action_pressed("move_DOWN"):
		damageValue = 3
		started = true
		charged_shot.visible = false
		audio_stream_player_2d.play()
		player_projectile_phaser.visible = true
		shot_anim.play("shot_anim_CHARGED_DOWN")
		Globals.shot.emit()
		charged_shot_buffer.stop()
		
		can_collect = true
		
	
	elif charged == true and Input.is_action_just_released("attack_fast") and charged and not started and not projectile_shot and Globals.direction == 1:
		damageValue = 3
		started = true
		charged_shot.visible = false
		audio_stream_player_2d.play()
		player_projectile_phaser.visible = true
		shot_anim.play("shot_anim_CHARGED_R")
		Globals.shot.emit()
		charged_shot_buffer.stop()
		
	elif charged == true and Input.is_action_just_released("attack_fast") and charged and not started and not projectile_shot and Globals.direction == -1:
		damageValue = 3
		started = true
		charged_shot.visible = false
		audio_stream_player_2d.play()
		player_projectile_phaser.visible = true
		shot_anim.play("shot_anim_CHARGED_L")
		Globals.shot.emit()
		charged_shot_buffer.stop()
		
		
	
	#elif started and not projectile_shot:

		#mouse_pos = get_local_mouse_position()
		#player_projectile_phaser.position = player_projectile_phaser.position.lerp(mouse_pos, delta * FOLLOW_SPEED)
		#print(mouse_pos)
	
	
	
	else:
		pass
	
	
func _on_timer_timeout():
	charged = true
	Globals.shot_charged.emit()
	


func _on_animation_player_animation_finished(_shot_anim):
	queue_free()








var direction = 0

func _on_animation_player_animation_started(anim_name):
	if anim_name == "shot_animL" or anim_name == "shot_anim_CHARGED_L":
		direction = -1
		
	elif anim_name == "shot_animR" or anim_name == "shot_anim_CHARGED_R":
		direction = 1
