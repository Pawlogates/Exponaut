extends enemy_basic


const SPEED = 75.0
const JUMP_VELOCITY = -250.0




#MAIN PROCESS

func _physics_process(delta):
	if not $scanForLedge.get_collider() and is_on_floor() or is_on_wall():
		if direction == 1:
			direction = -1
			$scanForLedge.position.x = -32
			
		else:
			direction = 1
			$scanForLedge.position.x = 32
			
			
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if direction and not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 800)


	else:
		velocity.x = move_toward(velocity.x, 0, 10)
		
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
		


#func _on_direction_timer_timeout():
#	if not dead:
#		velocity.y = JUMP_VELOCITY
#		if direction == -1:
#			direction = 1
#		else:
#			direction = -1






func manage_animation():
	if not dead:
		if not attacked and not attacking and not dead:
			if direction == -1:
				sprite.play("walk")
				sprite.flip_h = true
				
			if direction == 1:
				sprite.play("walk")
				sprite.flip_h = false
			
			
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
				starParticle_fast = starParticle_fastScene.instantiate()
				add_child(starParticle_fast)
			
				particle_limiter.start()
				particle_buffer = true
			
	






func _ready():
	basic_onReady()
	hp = 1
	%scanForLedge.enabled = false





#UNLOADING LOGIC

func offScreen_unload():
	basic_offScreen_unload()
	%scanForLedge.enabled = false


func offScreen_load():
	basic_offScreen_load()
	%scanForLedge.enabled = true






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
