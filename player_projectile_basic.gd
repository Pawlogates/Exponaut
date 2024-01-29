extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var x = 1
var rng = RandomNumberGenerator.new()

var projectile_shot = false

var direction = 0
var damageValue = 1

var downwards_shot = false

var direction_whenShot = 0


func _process(delta):
	if projectile_shot == false and Input.is_action_pressed("attack_fast"):
		projectile_shot = true
		Events.shot.emit()
		x = rng.randf_range(0.8, 1.2)
		$AudioStreamPlayer2D.set_pitch_scale(x)
		$AudioStreamPlayer2D.play()
		
		if Globals.direction != 0:
			%animation.flip_h = (Globals.direction < 0)
		
		
		
		if Input.is_action_pressed("move_DOWN"):
			velocity.x = 0
			velocity.y = 400
			downwards_shot = true
			
			if Globals.direction == 1:
				rotation_degrees = 90
			elif Globals.direction == -1:
				rotation_degrees = -90
			
		
		elif Globals.direction == 1:
			velocity.x = 400
			velocity.y = 0
			direction = 1
			
		
		elif Globals.direction == -1:
			velocity.x = -400
			velocity.y = 0
			direction = -1
		
		
		direction_whenShot = Globals.direction
		
		
		
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
			
		velocity.x = 100 * direction
		
		if direction != 0:
			%animation.flip_h = (direction < 0)
			
	
	if is_on_floor() and downwards_shot:
		velocity.y = -100
		
		if direction_whenShot == 1:
			rotation_degrees = -90
		else:
			rotation_degrees = 90
		
		
	
	
	move_and_slide()



	#elif charged == true and Input.is_action_just_released("attack_fast") and charged and not started and not projectile_shot and Input.is_action_pressed("move_DOWN"):
		#damageValue = 3
		#started = true
		#charged_shot.visible = false
		#audio_stream_player_2d.play()
		#projectile_basic_quick.visible = true
		#shot_anim.play("shot_anim_CHARGED_DOWN")
		#Events.shot.emit()
		#charged_shot_buffer.stop()
		#
		#can_collect = true
		#
	#
	#elif charged == true and Input.is_action_just_released("attack_fast") and charged and not started and not projectile_shot and Globals.direction == 1:
		#damageValue = 3
		#started = true
		#charged_shot.visible = false
		#audio_stream_player_2d.play()
		#projectile_basic_quick.visible = true
		#shot_anim.play("shot_anim_CHARGED_R")
		#Events.shot.emit()
		#charged_shot_buffer.stop()
		#
	#elif charged == true and Input.is_action_just_released("attack_fast") and charged and not started and not projectile_shot and Globals.direction == -1:
		#damageValue = 3
		#started = true
		#charged_shot.visible = false
		#audio_stream_player_2d.play()
		#projectile_basic_quick.visible = true
		#shot_anim.play("shot_anim_CHARGED_L")
		#Events.shot.emit()
		#charged_shot_buffer.stop()
	


func _on_remove_delay_timeout():
	queue_free()
