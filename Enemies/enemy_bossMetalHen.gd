extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

@onready var sprite = $AnimatedSprite2D

@onready var attacking_timer = $AnimatedSprite2D/AttackingTimer
@onready var attacked_timer = $AnimatedSprite2D/AttackedTimer
@onready var dead_timer = $AnimatedSprite2D/DeadTimer

@onready var particle_limiter = $particle_limiter

@onready var hit = $hit
@onready var death = $death

@onready var enemy_frog = $"."

@onready var start_pos = global_position

var frog_x
var frog_y

var jumped = true
var flying = false

var hp = 10

var starParticle_fastScene = load("res://particles_starFast.tscn")
var starParticle_fast = starParticle_fastScene.instantiate()
var hit_effectScene = load("res://hit_effect.tscn")
var hit_effect = hit_effectScene.instantiate()
var dead_effectScene = load("res://dead_effect.tscn")
var dead_effect = dead_effectScene.instantiate()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = -1




func _ready():

	pass


func _physics_process(delta):
	
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
			
	#frog_x = enemy_frog.get_global_position()[0]
	#frog_y = enemy_frog.get_global_position()[1]
	
	# Add the gravity.
	if not flying or dead:
		velocity.y += gravity * delta
	
	elif flying and not dead:
		velocity.y = move_toward(velocity.y, -500, 10)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	if not dead:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, 10)
		
	manage_animation()
	move_and_slide()
	#handle_turn()

	
func _on_jump_timer_timeout():
	if not dead and not flying and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	jumped = false
	


var attacked = false;
var attacking = false;
var dead = false;

func _on_area_2d_area_entered(area):
	if area.name == "Player_hitbox_main" and not dead:
		Globals.playerHit1.emit()
		attacking = true
		attacking_timer.start()
		
	elif area.name == "projectile_basic_quick" or "projectile_basic_quick2" or "projectile_basic_quick3" or "projectile_basic_quick4":
		if not dead:
			attacked = true
			attacked_timer.start()
			hit.play()
			add_child(hit_effect)
			hp -= 1
			if hp <= 0:
				dead = true
				if dead:
					direction = 0
					sprite.play("dead")
					death.play()
					add_child(dead_effect)
			


func manage_animation():
	
	if not dead and not flying:
		if is_on_floor() and not attacked and not attacking and not dead:
			sprite.play("walk")
			
		elif attacking:
		
			sprite.play("attack")

		elif attacked and not attacking:
			sprite.play("damage")
			
			if not particle_buffer:
				add_child(starParticle_fast)
			
				particle_limiter.start()
				particle_buffer = true
				
		#elif not is_on_floor() and not jumped:
			#sprite.play("jumping")
			#jumped = true
	
	elif not dead:
		sprite.play("flying")
	
	


func _on_attacking_timer_timeout():
	attacking = false


func _on_attacked_timer_timeout():
	attacked = false




var particle_buffer = false

func _on_particle_limiter_timeout():
	particle_buffer = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	if dead:
		queue_free()
		



#func handle_turn():
	#if not dead:
		#if Globals.player_posX > frog_x:
			#sprite.flip_h = false

		#else:
			#sprite.flip_h = true
		


func _on_fly_cooldown_timeout():
	if not dead:
		flying = true
		%flyEnd.start()


func _on_fly_end_timeout():
	if not dead:
		flying = false
		%flyCooldown.start()
	



