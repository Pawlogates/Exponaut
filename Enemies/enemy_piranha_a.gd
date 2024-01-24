extends enemy_basic


const SPEED = 200.0
const JUMP_VELOCITY = -250.0



var projectile = preload("res://Enemies/projectile_pig.tscn")

var direction_force = false




#MAIN PROCESS

func _physics_process(delta):

	#if is_on_wall():
		#if direction == 1:
			#direction = -1
		#else:
			#direction = 1
	
	if not dead and direction == 1:
		sprite.flip_h = false
		%scanForPlayer_CollisionShape2D.position.x = 320
		
	elif not dead:
		sprite.flip_h = true
		%scanForPlayer_CollisionShape2D.position.x = -320
		
	
	if spottedPlayer:
		direction_force = false
	
	if not direction_force and not spottedPlayer and global_position.x < start_pos_x:
		direction = 1
	elif not direction_force and not spottedPlayer and global_position.x > start_pos_x:
		direction = -1
		
	
	if spottedPlayer and global_position.x > Globals.player_posX:
		direction = -1
		
	elif spottedPlayer and global_position.x < Globals.player_posX:
		direction = 1
	



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
		
	
	
	velocity.x = move_toward(velocity.x, direction * SPEED, 500 * delta)
	
	if dead or not spottedPlayer and abs(global_position.x - start_pos_x) <= 5:
		velocity.x = 0
		direction_force = true
	
	
	
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
	








var started_falling = false

func manage_animation():
	if not dead:
		if not spottedPlayer and not attacked and not attacking:
			sprite.play("idle")
			
		if spottedPlayer and not attacked and not attacking:
			sprite.play("move")
			
		if attacking:
			sprite.play("attack")

		if attacked and not attacking:
			sprite.play("damage")
			
			if not particle_buffer:
				add_child(starParticle_fastScene.instantiate())
			
				particle_limiter.start()
				particle_buffer = true
			
		if is_on_floor() and spottedPlayer and not attacked and not attacking:
			sprite.play("attack")
			
			
		
#		elif not is_on_floor() and not attacked and not started_falling:
#			started_falling = true
#			sprite.play("falling")
			
		
#		if is_on_floor():
#			started_falling = false






func _ready():
	hp = 3
	direction = 1
	basic_onReady()
	$scanForPlayer.monitoring = false
	$scanForPlayer.monitorable = false
	%scanForPlayer_CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)



#UNLOADING LOGIC

func offScreen_unload():
	basic_offScreen_unload()
	$scanForPlayer.monitoring = false
	$scanForPlayer.monitorable = false
	%scanForPlayer_CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)


func offScreen_load():
	basic_offScreen_load()
	%scanForPlayer_CollisionShape2D.disabled = false
	%patrolDirectionTimer.set_paused(false)
	%followDelay.set_paused(false)
	
	await get_tree().create_timer(0.5, false).timeout
	$scanForPlayer.monitoring = true
	$scanForPlayer.monitorable = true






func _on_patrol_direction_timer_timeout():
	if not dead:
		if direction == -1:
			direction = 1
			
		else:
			direction = -1



#spot player logic

var spottedPlayer = false
var followDelay = true

func _on_scan_for_player_area_entered(area):
	if area.name == "Player_hitbox_main" and not dead:
		spottedPlayer = true
		%patrolDirectionTimer.stop()
#		add_child(projectile.instantiate())
#		%shoot_delay.start()

func _on_scan_for_player_area_exited(area):
	if area.name == "Player_hitbox_main" and not dead:
		spottedPlayer = false
		%patrolDirectionTimer.start()
#		%shoot_delay.stop()







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
