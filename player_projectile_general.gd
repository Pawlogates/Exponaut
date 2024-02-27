extends CharacterBody2D


@export var SPEED = 400.0
@export var V_SPEED = 400.0

var enemyProjectile = false
var playerProjectile = true


#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var x = 1
var rng = RandomNumberGenerator.new()

var projectile_shot = false

var direction = 0
var damageValue = 1

var bouncy = false

var downwards_shot = false
var direction_whenShot = 0


#SPAWN ITEM
@export var spawn_on_death = false
@export var item_scene = preload("res://Tiles/special_block_iceCube.tscn")
@export var give_momentum = false
@export var momentum_x = 0.0
@export var momentum_y = 0.0

func _process(delta):
	if projectile_shot == false and Input.is_action_pressed("attack_fast") or enemyProjectile:
		projectile_shot = true
		Globals.shot.emit()
		
		if not enemyProjectile and Globals.direction != 0:
			%animation.flip_h = (Globals.direction < 0)
		elif enemyProjectile and direction != 0:
			%animation.flip_h = (direction < 0)
		
		
		if not enemyProjectile:
			if Input.is_action_pressed("move_DOWN"):
				velocity.x = 0
				velocity.y = V_SPEED
				downwards_shot = true
				
				if Globals.direction == 1:
					rotation_degrees = 90
				elif Globals.direction == -1:
					rotation_degrees = -90
				
			
			elif Globals.direction == 1:
				velocity.x = SPEED
				velocity.y = 0
				direction = 1
				
			
			elif Globals.direction == -1:
				velocity.x = -SPEED
				velocity.y = 0
				direction = -1
		
		
		
		else:
			if direction == 1:
				velocity.x = SPEED
				velocity.y = 0
				direction = 1
				
			
			elif direction == -1:
				velocity.x = -SPEED
				velocity.y = 0
				direction = -1
		
		
		direction_whenShot = Globals.direction
		
		
		
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
			
		velocity.x = SPEED / 3 * direction
		
		if direction != 0:
			%animation.flip_h = (direction < 0)
			
	
	if is_on_floor() and downwards_shot:
		velocity.y = -V_SPEED / 3
		
		if direction_whenShot == 1:
			rotation_degrees = -90
		else:
			rotation_degrees = 90
		
		
	
	
	move_and_slide()


func _on_remove_delay_timeout():
	if spawn_on_death:
		var item = item_scene.instantiate()
		item.position = position
		
		if give_momentum and not downwards_shot:
			item.velocity.x = momentum_x * direction
			item.velocity.y = momentum_y
		
		elif downwards_shot:
			item.velocity.y = -300
		
		
		get_parent().add_child(item)
	
	
	queue_free()
