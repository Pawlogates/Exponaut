extends CharacterBody2D

@onready var world = $/root/World
@onready var player = $/root/World.player

#@export_enum("normal", "charged", "lethalBall") var projectile_type = "normal"

@export var SPEED = 400.0
@export var SPEED_V = 400.0

@export var can_collect = true
@export var remove_delay = 1.0
@export var bouncy = false
@export var familyID = 0
@export var damageValue = 1

#SPAWN ITEM
@export var spawn_on_death = false
@export var item_scene = preload("res://Blocks/special_block_iceCube.tscn")
@export var give_momentum = false
@export var momentum_x = 0.0
@export var momentum_y = 0.0

@export var type : String

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

var enemyProjectile = false
var playerProjectile = false

var upward_shot = false
var downward_shot = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var delta_value : float = 0

var x = 1
var rng = RandomNumberGenerator.new()

var projectile_shot = false

var direction = 0
var direction_V = 0

var vertical_shot = false
var direction_whenShot = 0

var start_pos = Vector2(0, 0)

var start_frame_correct = true
var not_bounced = true

var stop_movement = false

var speed_target = 0.0
var speed_current = 0.0

func _ready():
	start_pos = position
	$remove_delay.wait_time = remove_delay
	$remove_delay.start()


func _process(delta):
	delta_value = delta
	
	if not projectile_shot and Input.is_action_pressed("attack_main") or enemyProjectile or not projectile_shot and Globals.debug_magic_projectiles:
		projectile_shot = true
		Globals.shot.emit()
		
		start_pos = position
		
		if not enemyProjectile and Globals.direction != 0:
			%animation.flip_h = (Globals.direction < 0)
		elif enemyProjectile and direction != 0:
			%animation.flip_h = (direction < 0)
		
		
		if not enemyProjectile:
			if Input.is_action_pressed("move_DOWN"):
				downward_shot = true
				vertical_shot = true
				direction = 0
				direction_V = 1
				
				if Globals.direction == 1:
					rotation_degrees = 90
				elif Globals.direction == -1:
					rotation_degrees = -90
			
			elif Globals.direction == 1:
				direction = 1
				downward_shot = false
				vertical_shot = false
			
			elif Globals.direction == -1:
				direction = -1
				downward_shot = false
				vertical_shot = false
		
		direction_whenShot = Globals.direction
	
	
	if is_on_wall():
		if direction != 0:
			%animation.flip_h = (direction < 0)
		
		
		# Handle straight surface bounce
		straight_bounce()
		
		# Handle slope surface bounce
		if vertical_shot:
			slope_bounce(true)
			
		else:
			slope_bounce(false)
		
		
		if direction_whenShot == 1:
			rotation_degrees = 90
		else:
			rotation_degrees = -90
	
	velocity = Vector2(SPEED * direction, SPEED_V * direction_V)
	move_and_slide()
	
	if start_frame_correct:
		start_frame_correct = false
		position.y = start_pos[1]


func _on_remove_delay_timeout():
	if spawn_on_death:
		var item = item_scene.instantiate()
		item.position = position
		
		if give_momentum and not direction_V == -1:
			item.velocity.x = momentum_x * direction
			item.velocity.y = momentum_y
		
		elif downward_shot or direction_V == -1:
			item.velocity.y = -300
		
		
		get_parent().add_child(item)
	
	if Globals.debug_magic_projectiles:
		position = Globals.player_pos + Vector2(24 * Globals.direction, 0)
		projectile_shot = false
		direction = 0
		direction_V = 0
		SPEED = 400
		SPEED_V = 400
		start_frame_correct = true
		not_bounced = true
		return
	
	queue_free()


func slope_bounce(is_vertical_shot):
	if is_vertical_shot:
		if get_wall_normal()[0] < 0 and get_wall_normal()[1] < 0: #45deg-left up
			direction = -1
			direction_V = 0
			vertical_shot = false
			not_bounced = false
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] < 0: #45deg-right up
			direction = 1
			direction_V = 0
			vertical_shot = false
			not_bounced = false
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] > 0: #45deg-right down
			direction = 1
			direction_V = 0
			vertical_shot = false
			not_bounced = false
		elif get_wall_normal()[0] < 0 and get_wall_normal()[1] > 0: #45deg-left down
			direction = -1
			direction_V = 0
			vertical_shot = false
			not_bounced = false
	
	else:
		if get_wall_normal()[0] < 0 and get_wall_normal()[1] < 0: #45deg-left up
			direction = 0
			direction_V = -1
			vertical_shot = true
			not_bounced = false
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] < 0: #45deg-right up
			direction = 0
			direction_V = -1
			vertical_shot = true
			not_bounced = false
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] > 0: #45deg-right down
			direction = 0
			direction_V = 1
			vertical_shot = true
			not_bounced = false
		elif get_wall_normal()[0] < 0 and get_wall_normal()[1] > 0: #45deg-left down
			direction = 0
			direction_V = 1
			vertical_shot = true
			not_bounced = false

func straight_bounce():
	if get_wall_normal() == Vector2(0, -1): #bottom
		vertical_shot = true
		SPEED_V /= 2
		SPEED /= 2
		direction = 0
		direction_V = -1
	elif get_wall_normal() == Vector2(0, 1): #top
		vertical_shot = true
		SPEED_V /= 2
		SPEED /= 2
		direction = 0
		direction_V = 1
	
	if not_bounced and downward_shot: #this is so that if you shoot downwards, the projectile cannot bounce off of a wall (left/right) until it had already bounced off of another surface. 
		return
	
	elif get_wall_normal() == Vector2(-1, 0): #right
		vertical_shot = false
		SPEED_V /= 2
		SPEED /= 2
		direction = -1
		direction_V = 0
	elif get_wall_normal() == Vector2(1, 0): #left
		vertical_shot = false
		SPEED_V /= 2
		SPEED /= 2
		direction = 1
		direction_V = 0


func _on_scan_body_entered(body):
	if body.is_in_group("player"):
		if enemyProjectile:
			if damageValue == 1:
				Globals.playerHit1.emit()
			elif damageValue == 2:
				Globals.playerHit2.emit()
			elif damageValue == 3:
				Globals.playerHit3.emit()
