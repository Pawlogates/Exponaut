extends CharacterBody2D


const SPEED = 800.0
const JUMP_VELOCITY = -400.0

var direction = 1
var direction_v = 1

var velocity_last = Vector2(0, 0)

var swarming = true
var buildSpeed = 1

var portal_target_pos = Vector2(0, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	scale = Vector2(3, 3)
	$AnimatedSprite2D.speed_scale = randf_range(0.1, 2)
	await get_tree().create_timer(10, false).timeout
	swarming = false


func _physics_process(delta):
	scale = scale.move_toward(Vector2(0.001, 0.001), 0.0066)
	
	if position.x > portal_target_pos[0]:
		direction = -1
	else:
		direction = 1
		
	if position.y > portal_target_pos[1]:
		direction_v = -1
	else:
		direction_v = 1
		
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
	
	velocity.y = move_toward(velocity.y, direction_v * SPEED, SPEED * buildSpeed * delta / 20)
	
	if swarming:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * buildSpeed * delta / 20)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity = velocity_last

	velocity_last = velocity

	move_and_slide()
	
	buildSpeed += 0.3
	
	if scale.x <= 0.005:
		queue_free()
		print("Removed this shrine portal particle.")
