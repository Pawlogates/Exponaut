extends enemy_basic


const SPEED = 100.0
const JUMP_VELOCITY = -250.0



var projectile = preload("res://Enemies/projectile_pig.tscn")




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
	
	
	if not attacked:
		move_and_slide()
	






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









func _ready():
	basic_onReady()
	hp = 2





#UNLOADING LOGIC

func offScreen_unload():
	basic_offScreen_unload()


func offScreen_load():
	basic_offScreen_load()






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
