extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -250.0

@onready var sprite = $AnimatedSprite2D

@onready var attacking_timer = $AnimatedSprite2D/AttackingTimer
@onready var attacked_timer = $AnimatedSprite2D/AttackedTimer
@onready var dead_timer = $AnimatedSprite2D/DeadTimer

@onready var particle_limiter = $particle_limiter

@onready var hit = $hit
@onready var death = $death


var hp = 7

var starParticle_fastScene = preload("res://particles_starFast.tscn")
var hit_effectScene = preload("res://hit_effect.tscn")
var dead_effectScene = preload("res://dead_effect.tscn")

var projectile = preload("res://Enemies/projectile_pig.tscn")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = -1






#MAIN PROCESS

func _physics_process(delta):
	if is_on_wall():
		if direction == 1:
				direction = -1
		else:
			direction = 1
			
		if direction == 1:
				sprite.flip_h = false
		else:
			sprite.flip_h = true
		
#	if not $scanForLedge.get_collider() and is_on_floor() or is_on_wall():
#		if direction == 1:
#			direction = -1
#			$scanForLedge.position.x = -32
#			%CollisionShape2D.position.x = -320
#			
#		else:
#			direction = 1
#			$scanForLedge.position.x = 32
#			%CollisionShape2D.position.x = 320
			
			
	if not dead:
		velocity.y = 0
	else:
		velocity.y = move_toward(velocity.y, 200, 100 * delta)
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 500)
		
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta)
		
	
	
	
	manage_animation()
	move_and_slide()
	





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
	
	elif area.name == "loadingZone1" or area.name == "loadingZone2" or area.name == "loadingZone3" or area.name == "loadingZone4" or area.name == "loadingZone5":
		remove_from_group("loadingZone0")
		remove_from_group("loadingZone1")
		remove_from_group("loadingZone2")
		remove_from_group("loadingZone3")
		remove_from_group("loadingZone4")
		remove_from_group("loadingZone5")
		
		loadingZone = area.name
		add_to_group(loadingZone)
		
		#print("this object is in: ", loadingZone)
	
	#SAVE END


var started_falling = false

func manage_animation():
	if not dead:
		if is_on_floor() and not spottedPlayer and not attacked and not attacking:
			sprite.play("move")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
		
			
		if attacking:
		
			sprite.play("attack")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
				
		if attacked and not attacking:
			sprite.play("damage")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
			
			if not particle_buffer:
				add_child(starParticle_fastScene.instantiate())
			
				particle_limiter.start()
				particle_buffer = true
			
		if is_on_floor() and spottedPlayer and not attacked and not attacking:
			sprite.play("attack")
			
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
				
			
		
		elif not is_on_floor() and not attacked and not started_falling:
			started_falling = true
			sprite.play("falling")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
		
		if is_on_floor():
			started_falling = false


func _on_attacking_timer_timeout():
	attacking = false


func _on_attacked_timer_timeout():
	attacked = false


func _on_dead_timer_timeout():
	dead = false


var particle_buffer = false

func _on_particle_limiter_timeout():
	particle_buffer = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	if dead:
		queue_free()






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
	$scanForPlayer.set_monitorable(false)
	$scanForPlayer.set_monitoring(false)
	$Area2D.set_monitorable(false)
	
	$CollisionShape2D.disabled = true
	%CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)
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
	$scanForPlayer.set_monitorable(false)
	$scanForPlayer.set_monitoring(false)
	$Area2D.set_monitorable(false)
	
	$CollisionShape2D.disabled = true
	%CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)
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
	$scanForPlayer.set_monitorable(true)
	$scanForPlayer.set_monitoring(true)
	
	$CollisionShape2D.disabled = false
	%CollisionShape2D.disabled = false
	%patrolDirectionTimer.set_paused(false)
	%followDelay.set_paused(false)
	$AnimatedSprite2D/AttackingTimer.set_paused(false)
	$AnimatedSprite2D/AttackedTimer.set_paused(false)
	$AnimatedSprite2D/DeadTimer.set_paused(false)



#func _on_patrol_direction_timer_timeout():
#	if not dead:
#		if direction == -1:
#			direction = 1
#			%CollisionShape2D.position.x = 320
#		else:
#			direction = -1
#			%CollisionShape2D.position.x = -320



#spot player logic

var spottedPlayer = false
var followDelay = true

#func _on_scan_for_player_area_entered(area):
#	if area.name == "Player_hitbox_main" and not dead:
#		spottedPlayer = true
#		add_child(projectile.instantiate())
#		%shoot_delay.start()

#func _on_scan_for_player_area_exited(area):
#	if area.name == "Player_hitbox_main" and not dead:
#		spottedPlayer = false
#		%shoot_delay.stop()
#		






func _on_follow_delay_timeout():
	followDelay = false




#SAVE START

var loadingZone = "loadingZone0"

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


func _on_shoot_delay_timeout():
	add_child(projectile.instantiate())
