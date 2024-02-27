extends enemy_basic


const SPEED = 200.0
const JUMP_VELOCITY = -250.0



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if direction and not dead and spottedPlayer and is_on_floor() and not followDelay:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 500)


	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta)
	
	
	
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
	








func manage_animation():
	if not dead:
		if is_on_floor() and not spottedPlayer and not attacked and not attacking:
			sprite.play("idle")
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
				starParticle_fast = starParticle_fastScene.instantiate()
				add_child(starParticle_fast)
			
				particle_limiter.start()
				particle_buffer = true
			
		if is_on_floor() and spottedPlayer and not attacked and not attacking and not followDelay:
			sprite.play("walk")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
		
		elif not is_on_floor() and not attacked:
			sprite.play("falling")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true






func _ready():
	hp = 2
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
	$scanForPlayer.monitoring = true
	$scanForPlayer.monitorable = true
	%scanForPlayer_CollisionShape2D.disabled = false
	%patrolDirectionTimer.set_paused(false)
	%followDelay.set_paused(false)








func _on_patrol_direction_timer_timeout():
		if not dead:
			if direction == -1:
				direction = 1
				%scanForPlayer_CollisionShape2D.position.x = 320
			else:
				direction = -1
				%scanForPlayer_CollisionShape2D.position.x = -320



#spot player logic

var spottedPlayer = false
var followDelay = true

func _on_scan_for_player_area_entered(area):
	if area.name == "Player_hitbox_main" and not dead:
		spottedPlayer = true
		%followDelay.start()
		%patrolDirectionTimer.stop()

func _on_scan_for_player_area_exited(area):
	if area.name == "Player_hitbox_main" and not dead:
		spottedPlayer = false
		%followDelay.stop()
		followDelay = true
		%patrolDirectionTimer.start()
		

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



