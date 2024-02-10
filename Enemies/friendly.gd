extends enemy_basic


var SPEED = 150.0
var JUMP_VELOCITY = -600.0

@export var followPlayer = false


#MAIN PROCESS

func _physics_process(delta):
	if not $scanForLedge.get_collider() and is_on_floor() or is_on_wall():
		if direction == 1:
			direction = -1
			$scanForLedge.position.x = -32
			
		else:
			direction = 1
			$scanForLedge.position.x = 32
			
		
		
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if followPlayer:
		if position.x <= Globals.player_posX:
			direction = 1
			sprite.flip_h = false
		else:
			direction = -1
			sprite.flip_h = true
	
	
	if direction and not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 800)
	else:
		velocity.x = move_toward(velocity.x, 0, 10 * delta)
		
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
	hp = 3
	%scanForLedge.enabled = false
	
	if not followPlayer:
		$directionChange_timer.wait_time = rng.randf_range(0.5, 12.0)
		$directionChange_timer.start()
		
	
	
	$idleSound_timer.wait_time = rng.randf_range(0.5, 12.0)
	$jump_timer.wait_time = rng.randf_range(0.5, 12.0)
	
	$idleSound_timer.start()
	$jump_timer.start()




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






var rng = RandomNumberGenerator.new()

func _on_idle_sound_timer_timeout():
	if dead:
		$idleSound_timer.stop()
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)
		return
		
	$idleSound_timer.wait_time = rng.randf_range(0.5, 12.0)
	
	$idle.play()
	
	$idleSound_timer.start()
	
	SPEED = rng.randf_range(50, 400)
	JUMP_VELOCITY = rng.randf_range(-150, -600)


func _on_direction_change_timer_timeout():
	if dead:
		$directionChange_timer.stop()
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)
		return
		
	$directionChange_timer.wait_time = rng.randf_range(0.5, 12.0)
	
	if not dead:
		if direction == -1:
			direction = 1
		else:
			direction = -1
	
	$directionChange_timer.start()
	
	SPEED = rng.randf_range(50, 400)
	JUMP_VELOCITY = rng.randf_range(-150, -600)


func _on_jump_timer_timeout():
	if dead:
		$jump_timer.stop()
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)
		return
		
	$jump_timer.wait_time = rng.randf_range(0.5, 12.0)
	
	velocity.y = JUMP_VELOCITY
	
	$jump_timer.start()
	
	SPEED = rng.randf_range(50, 400)
	JUMP_VELOCITY = rng.randf_range(-150, -600)
