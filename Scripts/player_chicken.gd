extends player_general

func _ready():
	Globals.player_pos = get_global_position()
	Globals.player_posX = get_global_position()[0]
	Globals.player_posY = get_global_position()[1]
	
	
	Globals.saveState_loaded.connect(saveState_loaded)
		
	Globals.playerHit1.connect(reduceHp1)
	Globals.playerHit2.connect(reduceHp2)
	Globals.playerHit3.connect(reduceHp3)
			
	Globals.shot_charged.connect(charged_effect)
	Globals.shot.connect(cancel_effect)
	
	
	#if Globals.next_transition != 0:
		#print(("%areaTransition" + str(Globals.next_transition)))
		#position = get_parent().get_node("%areaTransition" + str(Globals.next_transition)).position
	
	
	if $/root/World.cameraLimit_left != 0.0 or $/root/World.cameraLimit_right != 0.0 or $/root/World.cameraLimit_top != 0.0 or $/root/World.cameraLimit_bottom != 0.0:
		%Camera2D.limit_left = $/root/World.cameraLimit_left
		%Camera2D.limit_right = $/root/World.cameraLimit_right
		%Camera2D.limit_bottom = $/root/World.cameraLimit_bottom
		%Camera2D.limit_top = $/root/World.cameraLimit_top


	if Globals.mode_scoreAttack:
		weaponType = "basic"
	
	
	
	if Globals.debug_mode:
		$Player_hitbox_main.monitoring = false
		$Player_hitbox_exact.monitoring = false
		$Player_hitbox_main.monitorable = false
		$Player_hitbox_exact.monitorable = false









func handle_flight(delta):
	if Input.is_action_pressed("jump") or Input.is_action_pressed("move_UP"):
		velocity.y = move_toward(velocity.y, JUMP_VELOCITY, delta * 300)
	elif Input.is_action_pressed("move_DOWN"):
		velocity.y = move_toward(velocity.y, -JUMP_VELOCITY, delta * 300)
	else:
		velocity.y = move_toward(velocity.y, 0, delta * 600)


#MAIN START

func _process(delta):
	if not dead and not debugMovement:
		direction = Input.get_axis("move_L", "move_R")
		apply_gravity(delta)
		handle_wall_jump()
		handle_jump(delta)
		
		#handle_flight(delta)
		
		
		if Input.is_action_just_pressed("attack_fast"):
			if weaponType == "phaser":
				var projectile_phaser = scene_projectile_phaser.instantiate()
				add_child(projectile_phaser)
	
	
		if Input.is_action_pressed("attack_fast"):
			if weaponType == "basic":
				if not attack_cooldown:
					attack_cooldown = true
					$attack_cooldown.start()
					
					shooting = true
					shoot_anim_delay.start()
					animated_sprite_2d.play("shoot")
					
					var projectile_basic = scene_projectile_basic.instantiate()
					projectile_basic.position = position + Vector2(Globals.direction * 32, 0)
					get_parent().add_child(projectile_basic)
					playSound_shoot()
					
				if direction != 0:
					animated_sprite_2d.flip_h = (direction < 0)
			
			
			
			elif weaponType == "short_shotDelay":
				if not attack_cooldown:
					attack_cooldown = true
					$attack_cooldown.start()
					
					shooting = true
					shoot_anim_delay.start()
					animated_sprite_2d.play("shoot")
					
					var projectile_short_shotDelay = scene_projectile_short_shotDelay.instantiate()
					projectile_short_shotDelay.position = position + Vector2(Globals.direction * 32, 0)
					get_parent().add_child(projectile_short_shotDelay)
					playSound_shoot()
					
				if direction != 0:
					animated_sprite_2d.flip_h = (direction < 0)
					
				
				
			elif weaponType == "ice":
				if not attack_cooldown:
					attack_cooldown = true
					$attack_cooldown.start()
					
					shooting = true
					shoot_anim_delay.start()
					animated_sprite_2d.play("shoot")
					
					var projectile_ice = scene_projectile_ice.instantiate()
					projectile_ice.position = position + Vector2(Globals.direction * 32, 0)
					get_parent().add_child(projectile_ice)
					playSound_shoot()
					
				if direction != 0:
					animated_sprite_2d.flip_h = (direction < 0)
				
				
				
			elif weaponType == "fire":
				if not attack_cooldown:
					attack_cooldown = true
					$attack_cooldown.start()
					
					shooting = true
					shoot_anim_delay.start()
					animated_sprite_2d.play("shoot")
					
					var projectile_fire = scene_projectile_fire.instantiate()
					projectile_fire.position = position + Vector2(Globals.direction * 32, 0)
					get_parent().add_child(projectile_fire)
					playSound_shoot()
					
				if direction != 0:
					animated_sprite_2d.flip_h = (direction < 0)
				
				
			elif weaponType == "destructive_fast_speed":
				if not attack_cooldown:
					attack_cooldown = true
					$attack_cooldown.start()
					
					shooting = true
					shoot_anim_delay.start()
					animated_sprite_2d.play("shoot")
					
					var projectile_destructive_fast_speed = scene_projectile_destructive_fast_speed.instantiate()
					projectile_destructive_fast_speed.position = position + Vector2(Globals.direction * 32, 0)
					get_parent().add_child(projectile_destructive_fast_speed)
					playSound_shoot()
					
				if direction != 0:
					animated_sprite_2d.flip_h = (direction < 0)
			
			
			elif weaponType == "veryFast_speed":
				if not attack_cooldown:
					attack_cooldown = true
					$attack_cooldown.start()
					
					shooting = true
					shoot_anim_delay.start()
					animated_sprite_2d.play("shoot")
					
					var projectile_veryFast_speed = scene_projectile_veryFast_speed.instantiate()
					projectile_veryFast_speed.position = position + Vector2(Globals.direction * 32, 0)
					get_parent().add_child(projectile_veryFast_speed)
					playSound_shoot()
					
				if direction != 0:
					animated_sprite_2d.flip_h = (direction < 0)
		
		#PLAYER SHOOTING ANIMATION
		
		if weaponType == "phaser" and not is_dashing and not is_dashing and Input.is_action_just_released("attack_fast") and not crouch_walking and not crouching:
			shooting = true
			shoot_anim_delay.start()
			animated_sprite_2d.play("shoot")
			if direction != 0:
				animated_sprite_2d.flip_h = (direction < 0)
		
		
		
		
		
		if direction != 0:
			Globals.direction = direction
		
		handle_acceleration_direction(delta)
		handle_air_acceleration(delta)
		var _was_in_air = not is_on_floor()
		var was_on_floor = is_on_floor()
		var was_on_wall = is_on_wall_only()
		
		if was_on_wall:
			was_wall_normal = get_wall_normal()
			
		if not is_on_floor():
			$idle_timer.stop()
		
		
		
		#DASH LOGIC
		
		#if Input.is_action_just_pressed("dash") and is_on_floor() and is_dashing == false and not crouch_walking and not crouching:
			#dash_end_slowdown_canceled = false
			#is_dashing = true
			#$dash_timer.start()
			#player_collision.shape.extents = Vector2(20, 20)
			#player_collision.position += Vector2(0, 36)
			#
			#player_hitbox.shape.extents = Vector2(20, 20)
			#player_hitbox.position += Vector2(0, 36)
		
		#DASH LOGIC END
		
		
		
		
		move_and_slide()
		
		#CROUCHING LOGIC
		#if is_on_floor():
			#if direction != 0:
				#animated_sprite_2d.flip_h = (direction < 0)
			#if Input.is_action_pressed("move_DOWN") and not crouch_walking and not crouchTimer:
				#crouch_walk_anim_delay.start()
				#crouch_walk_collision_switch.start()
				#crouching = true
				#crouchTimer = true
				#animated_sprite_2d.play("crouch")
				#
				#crouchMultiplier = 0.6
				#SPEED = 400 * crouchMultiplier
				#
			#
			#if crouch_walking:
				#animated_sprite_2d.play("crouch_walk")
				#crouching = false
				#
				#crouchMultiplier = 0.4
				#SPEED = 400.0 * crouchMultiplier
				#
		#
		#
		#if not Input.is_action_pressed("move_DOWN") and can_stand_up and crouching or not Input.is_action_pressed("move_DOWN") and can_stand_up and crouch_walking or not is_on_floor() and can_stand_up and crouch_walking:
			#player_collision.shape.extents = Vector2(20, 56)
			#player_collision.position = Vector2(0, 0)
			#
			#player_hitbox.shape.extents = Vector2(20, 56)
			#player_hitbox.position = Vector2(0, 0)
			#
			#
			#crouching = false
			#crouch_walking = false
			#crouch_walk_anim_delay.stop()
			#crouch_walk_collision_switch.stop()
			#SPEED = 400.0
			#crouchMultiplier = 1
			#crouchTimer = false
			
		
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		
		if just_left_ledge:
			jump_leniency.start()
			
			
		
		
		var just_left_wall = was_on_wall and not is_on_wall()
		
		if just_left_wall:
			wall_jump_leniency.start()
		
		
		
		apply_friction(delta)
		apply_air_slowdown(delta)
		
		update_anim()
		
		Globals.player_pos = get_global_position()
		Globals.player_posX = get_global_position()[0]
		Globals.player_posY = get_global_position()[1]
		
		just_wall_jumped = false
		
		if is_on_floor() and not direction and not shooting and not crouch_walking and not crouching:
			animated_sprite_2d.play("idle")
		
		
		if is_on_floor() and direction and spawn_dust_effect:
			spawn_dust_effect = false
			$dust_effect.start()
			
			effect_dust = effect_dustScene.instantiate()
			effect_dust.position = Globals.player_pos - Vector2(0, -24)
			get_parent().add_child(effect_dust)
			
		elif not is_on_floor():
			spawn_dust_effect = true
			$dust_effect.stop()
		
		
		if inside_wind:
			if insideWind_direction == -1:
				position.x += -3
			
			elif insideWind_direction == 1:
				position.x += 3
		
		
		
	
	if Input.is_action_pressed("zoom_out"):
		print(zoomValue)
		$Camera2D.zoom.x = move_toward($Camera2D.zoom.x, 0.1, 0.01 * delta * 50 * zoomValue)
		$Camera2D.zoom.y = move_toward($Camera2D.zoom.y, 0.1, 0.01 * delta * 50 * zoomValue)
		
		if $Camera2D.zoom.x < 0.25:
			zoomValue = 0.25
			
		elif $Camera2D.zoom.x < 0.5:
			zoomValue = 0.35
			
		elif $Camera2D.zoom.x < 0.75:
			zoomValue = 0.5
			
		elif $Camera2D.zoom.x > 1.2:
			zoomValue = 1.5
			
		else:
			zoomValue = 1
		
	
	if Input.is_action_pressed("zoom_in"):
		print(zoomValue)
		$Camera2D.zoom.x = move_toward($Camera2D.zoom.x, 2, 0.01 * delta * 50 * zoomValue)
		$Camera2D.zoom.y = move_toward($Camera2D.zoom.y, 2, 0.01 * delta * 50 * zoomValue)
		
		if $Camera2D.zoom.x < 0.25:
			zoomValue = 0.25
			
		elif $Camera2D.zoom.x < 0.5:
			zoomValue = 0.35
			
		elif $Camera2D.zoom.x < 0.75:
			zoomValue = 0.5
			
		elif $Camera2D.zoom.x > 1.2:
			zoomValue = 1.5
			
		else:
			zoomValue = 1
			
	
	
	if Input.is_action_pressed("zoom_reset"):
		$Camera2D.zoom.x = 1
		$Camera2D.zoom.y = 1
	
	
	
	#DEBUG
	
	if not debugMovement and Input.is_action_just_pressed("cheat"):
		#movement_data = preload("res://fasterMovementData.tres")
		debugMovement = true
		Globals.cheated.emit()
		
	elif debugMovement and Input.is_action_just_pressed("cheat"):
		#movement_data = preload("res://fasterMovementData.tres")
		debugMovement = false
		
		
	
	if debugMovement:
		
		if Input.is_action_pressed("move_R"):
			global_position.x += 40
		
		if Input.is_action_pressed("move_L"):
			global_position.x -= 40
		
		if Input.is_action_pressed("move_UP"):
			global_position.y -= 40
		
		if Input.is_action_pressed("move_DOWN"):
			global_position.y += 40
	
	
	
	
	
	#STUCK IN WALL
	
	if velocity.y > 1000 and not can_stand_up and Input.is_action_just_pressed("jump"):
		position.y += 6
		position.x += 3
	
	if velocity.y > 6000:
		position.y += -120
		position.x += 40
	
	
	
	
	if Globals.mode_scoreAttack:
		if Globals.combo_tier >= 5:
			weaponType = "phaser"
		else:
			weaponType = "basic"

#MAIN END







func apply_gravity(delta):
	if not is_on_floor() and not is_dashing or dash_slowdown:
		velocity.y += gravity * 1.2 * delta * GRAVITY_SCALE * insideWater_multiplier
	
	if is_dashing:
		animated_sprite_2d.play("crouch")
		if not speedBlockActive or dash_slowdown:
			dash_speed_block.start()
		speedBlockActive = true
		if started_dash == false or dash_slowdown:
			velocity.x = 0
		else:
			velocity.y += gravity * delta * 2 * GRAVITY_SCALE
			
			velocity.x = move_toward(velocity.x, 1000 * direction, 6000 * delta)
			
		
	else:
		started_dash = false
	
	if dash_end_slowdown:
		velocity.x = move_toward(velocity.x, 0, 7000 * delta)
	



func handle_jump(delta):
	if is_on_floor(): #or is_on_wall():
		#air_jump = true
		#wall_jump = true
		pass
		
	elif not justLanded_delay_started:
		justLanded_delay_started = true
		%justLanded_delay.start()
	
	if just_landed_queued and is_on_floor():
		just_landed_queued = false
		just_landed = true
		
	if just_landed:
		if is_dashing and not is_on_floor() and air_jump:
			just_landed = false
			dash_end_slowdown_await_jump = true
			%awaitJump_timer.start()
	
	if dash_end_slowdown_await_jump and is_on_floor() and Input.is_action_just_pressed("jump"):
		dash_end_slowdown_await_jump = false
		dash_end_slowdown_canceled = true
		velocity.x = SPEED * 3 * direction
		
		

	
	if is_on_floor() or jump_leniency.time_left > 0.0:
		
		if Input.is_action_just_pressed("jump"):
			jump_build_velocity.start()
			jump.play()
			jumpBuildVelocity_active = true
	
	if jumpBuildVelocity_active and Input.is_action_pressed("jump"):
		velocity.y = move_toward(velocity.y, JUMP_VELOCITY, 8000 * insideWater_multiplier * delta)
		
	elif not is_on_floor():
		
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
		
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = JUMP_VELOCITY * 0.8 * insideWater_multiplier
			air_jump = false
			jump.play()
			dash_end_slowdown_canceled = true
		




func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_leniency.time_left <= 0.0: return
	var wall_normal = get_wall_normal()
	
	if wall_jump_leniency.time_left > 0.0:
		wall_normal = was_wall_normal
	
	
	if Input.is_action_just_pressed("jump") and wall_jump:
		velocity.x = wall_normal.x * SPEED / 2
		velocity.y = JUMP_VELOCITY * 1 * insideWater_multiplier
		just_wall_jumped = true
		wall_jump = false
		
		
	



func apply_friction(delta):
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		




func handle_acceleration_direction(delta):
	
	if not is_on_floor(): return
	
	#HANDLE WALKING
	if direction != 0:
		if Input.is_action_pressed("move_DOWN"):
			velocity.x = move_toward(velocity.x, direction * SPEED / 3, ACCELERATION * delta * crouchMultiplier * insideWater_multiplier)
		else:
			velocity.x = move_toward(velocity.x, SPEED * direction, AIR_ACCELERATION * delta)
	
	if Input.is_action_just_pressed("move_L") or Input.is_action_just_pressed("move_R"):
		velocity.x = velocity.x * 0.5





func handle_air_acceleration(delta):
	
	if is_on_floor(): return
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, SPEED * direction, AIR_ACCELERATION * delta)
		
	if Input.is_action_just_pressed("move_L") or Input.is_action_just_pressed("move_R"):
		velocity.x = velocity.x * 0.5	
		
	
	
	






func update_anim():
	idle_after_delay()
	
	if not is_dashing and direction != 0 and not shooting and not crouch_walking and not crouching:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.flip_h = (direction < 0)
		$idle_timer.stop()
		
		
	#if not is_dashing and not is_on_floor() and not shooting and not crouch_walking and not crouching:
		#animated_sprite_2d.play("jump")
		#
		#if direction != 0:
			#animated_sprite_2d.flip_h = (direction < 0)
		#
		



func idle_after_delay():
	if $idle_timer.is_stopped():
		
		$idle_timer.start()
		



func _on_idle_timer_timeout():
	if not is_dashing and not shooting and not crouch_walking and not crouching:
		animated_sprite_2d.play("idle")
		




func apply_air_slowdown(delta):
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, AIR_SLOWDOWN * delta)
	


func _on_dash_timer_timeout():
	is_dashing = false
	
	player_collision.shape.extents = Vector2(20, 56)
	player_collision.position = Vector2(0, 0)
	
	player_hitbox.shape.extents = Vector2(20, 56)
	player_hitbox.position = Vector2(0, 0)






func reduceHp1():
	damage.play()
	

func reduceHp2():
	damage.play()


func reduceHp3():
	damage.play()



func charged_effect():
	animation_player.play("shot_charged")
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)

func cancel_effect():
	animation_player.stop()
	animation_player.play("RESET")
	


func _on_shoot_anim_delay_timeout():
	shooting = false



func _on_crouch_walk_anim_delay_timeout():
	crouch_walking = true
	crouchTimer = false

func _on_crouch_walk_collision_switch_timeout():
	player_collision.shape.extents = Vector2(20, 20)
	player_collision.position += Vector2(0, 36)
	player_hitbox.shape.extents = Vector2(20, 20)
	player_hitbox.position += Vector2(0, 36)



func _on_jump_build_velocity_timeout():
	jumpBuildVelocity_active = false




#CHECK IF INSIDE TILES
func _on_player_hitbox_tile_detection_body_entered(_body):
	can_stand_up = false

func _on_player_hitbox_tile_detection_body_exited(_body):
	can_stand_up = true




func _on_dash_speed_block_timeout():
	started_dash = true
	speedBlockActive = false
	dash_end_slowdown_delay.start()
	

func _on_dash_end_slowdown_timeout():
	if not dash_end_slowdown_canceled:
		dash_end_slowdown_active.start()
		dash_end_slowdown = true
	else:
		dash_end_slowdown_canceled = false
		just_landed_queued = false
		just_landed = false
		dash_end_slowdown_await_jump = false




func _on_dash_end_slowdown_active_timeout():
	dash_end_slowdown = false
	dash_end_slowdown_canceled = false
	just_landed_queued = false
	just_landed = false
	dash_end_slowdown_await_jump = false









#SAVE START

func _on_player_hitbox_main_area_entered(area):
	if area.is_in_group("loadingZone_area"):
			Globals.save.emit()
			
	#SAVE END
	
	
	elif area.is_in_group("bgMove_area"):
		if not get_parent().regular_level:
			get_parent().bgMove_growthSpeed = 1
	



func saveState_loaded():
	$Camera2D.position_smoothing_enabled = false
	await get_tree().create_timer(0.1, false).timeout
	$Camera2D.position_smoothing_enabled = true
	
	player_collision.shape.extents = Vector2(20, 56)
	player_collision.position = Vector2(0, 0)
	
	player_hitbox.shape.extents = Vector2(20, 56)
	player_hitbox.position = Vector2(0, 0)






func _on_dust_effect_timeout():
	spawn_dust_effect = true


func _on_attack_cooldown_timeout():
	attack_cooldown = false
	if Globals.direction != 0:
		$AnimatedSprite2D.flip_h = (Globals.direction < 0)


func _on_just_landed_delay_timeout():
	justLanded_delay_started = false
	just_landed_queued = true


func _on_await_jump_timer_timeout():
	dash_end_slowdown_await_jump = false










func playSound_shoot():
	pitch_scale = rng.randf_range(0.8, 1.2)
	if not $shoot.playing:
		$shoot.set_pitch_scale(pitch_scale)
		$shoot.play()
	elif not $shoot2.playing:
		$shoot2.set_pitch_scale(pitch_scale)
		$shoot2.play()
	elif not $shoot3.playing:
		$shoot3.set_pitch_scale(pitch_scale)
		$shoot3.play()
	elif not $shoot4.playing:
		$shoot4.set_pitch_scale(pitch_scale)
		$shoot4.play()
