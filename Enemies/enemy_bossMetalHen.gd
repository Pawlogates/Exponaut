extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

@onready var sprite = $AnimatedSprite2D

@onready var attacking_timer = $AnimatedSprite2D/AttackingTimer
@onready var attacked_timer = $AnimatedSprite2D/AttackedTimer


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

var starParticle_fastScene = preload("res://particles_starFast.tscn")
var hit_effectScene = preload("res://hit_effect.tscn")
var dead_effectScene = preload("res://dead_effect.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = -1





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
		
	elif area.is_in_group("player_projectile"):
		if not dead:
			attacked = true
			attacked_timer.start()
			hit.play()
			add_child(hit_effectScene.instantiate())
			hp -= 1
			Globals.enemyHit.emit()
			if hp <= 0:
				dead = true
				if dead:
					direction = 0
					sprite.play("dead")
					death.play()
					add_child(dead_effectScene.instantiate())
	
	
	#SAVE START
	
	elif area.is_in_group("loadingZone_area"):
	
		remove_from_group("loadingZone0")
		remove_from_group("loadingZone1")
		remove_from_group("loadingZone2")
		remove_from_group("loadingZone3")
		remove_from_group("loadingZone4")
		remove_from_group("loadingZone5")
		
		loadingZone = area.loadingZone_ID
		add_to_group(loadingZone)
		Globals.save.emit()
		
		#print("this object is in: ", loadingZone)

	#SAVE END
	


func manage_animation():
	
	if not dead and not flying:
		if is_on_floor() and not attacked and not attacking and not dead:
			sprite.play("walk")
			
		elif attacking:
		
			sprite.play("attack")

		elif attacked and not attacking:
			sprite.play("damage")
			
			if not particle_buffer:
				add_child(starParticle_fastScene.instantiate())
			
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
	





func _ready():
	add_to_group("loadingZone0")
	
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	$Area2D.set_monitorable(false)
	
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D/AttackingTimer.set_paused(true)
	$AnimatedSprite2D/AttackedTimer.set_paused(true)
	$AnimatedSprite2D/DeadTimer.set_paused(true)






#IS IN VISIBLE RANGE?

func offScreen_unload():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	$Area2D.set_monitorable(false)
	
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D/AttackingTimer.set_paused(true)
	$AnimatedSprite2D/AttackedTimer.set_paused(true)
	$AnimatedSprite2D/DeadTimer.set_paused(true)



func offScreen_load():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	sprite.play()
	sprite.visible = true
	$Area2D.set_monitorable(true)
	
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D/AttackingTimer.set_paused(false)
	$AnimatedSprite2D/AttackedTimer.set_paused(false)
	$AnimatedSprite2D/DeadTimer.set_paused(false)







#SAVE START

@onready var loadingZone = "loadingZone0"

func save():
	var save_dict = {
		"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"direction" : direction,
		"health" : hp,
		
	}
	return save_dict

#SAVE END
