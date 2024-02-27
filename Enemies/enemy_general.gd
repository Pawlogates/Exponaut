extends enemy_basic

var on_floor = is_on_floor()


@export var SPEED = 400
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION_MULTIPLIER = 1.0

@export_enum("normal", "followPlayerX", "followPlayerY", "followPlayerXY", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerXY_lookAtPlayer", "chasePlayerXY_lookAtPlayer_whenSpotted", "stationary", "wave_H", "wave_V", "bouncing") var movementType: String

@export_group("otherBehaviour")
@export var turnOnLedge = false
@export var turnOnWall = false
@export var floating = false

@export var patroling = false

@export var afterDelay_changeDirection = false
@export var afterDelay_jump = false

@export var onDeath_spawnObject = false
@export var immortal = false

@export var patrolRectStatic = false

@export var shootProjectile_whenSpotted = false
@export var dropProjectile_whenSpotted = false

@export var toggle_skull_blocks_onDeath = false

@export var force_static_H = false
@export var force_static_V = false

#@export var varName = false


@export_group("") #END OF BEHAVIOUR LIST



@export_group("specificInfo")
@export var onDeath_spawnObject_objectPath = preload("res://Collectibles/collectibleApple.tscn")
@export var onDeath_spawnObject_objectAmount = 1
@export var onDeath_spawnObject_throwAround = false

@export var directionTimer_time = 4.0
@export var jumpTimer_time = 4.0

@export var stationary_disable_jump_anim = false


#GENERAL TIMERS
@export var enable_generalTimers = true
@export var generalTimer1_cooldown = 3.0
@export var generalTimer2_cooldown = 3.0
@export var generalTimer3_cooldown = 3.0

@export var afterDelay_jumpAndMove = false
@export var afterDelay_jumpAndMove_timerID = 0
@export var afterDelay_jump2 = false
@export var afterDelay_jump2_timerID = 0
@export var afterDelay_changeDirection2 = false
@export var afterDelay_changeDirection2_timerID = 0

@export_group("") #END OF BEHAVIOUR LIST


var rng = RandomNumberGenerator.new()

func _on_area_2d_area_entered(area):
	if area.name == "Player_hitbox_main" and not dead:
		attacking = true
		attacking_timer.start()
		
		if not hostile:
			return
		
		Globals.playerHit1.emit()
		
	#HANDLE IMMORTAL
	elif immortal and area.is_in_group("player_projectile") and not area.get_parent().enemyProjectile:
		attacking = true
		attacking_timer.start()
		return
	
	#HANDLE FRIENDLY
	elif area.get_parent().is_in_group("friendly") and not dead:
		attacking = true
		attacking_timer.start()
	
	#HANDLE DAMAGE
	elif area.is_in_group("player_projectile") and not area.get_parent().enemyProjectile and hostile or not hostile and area.get_parent().is_in_group("enemies") or area.is_in_group("fire"):
		if not area.is_in_group("fire") and not area.get_parent().enemyProjectile:
			call_deferred("enemy_stunned")
			
		
		
		if not dead:
			attacked = true
			attacked_timer.start()
			hit.play()
			hit_effect = hit_effectScene.instantiate()
			add_child(hit_effect)
			if not area.is_in_group("fire"):
				hp -= area.get_parent().damageValue
			else:
				hp -= area.damageValue
			Globals.enemyHit.emit()
			if hp <= 0:
				dead = true
				if dead:
					Globals.specialAction.emit()
					direction = 0
					sprite.play("dead")
					if direction == 1:
						sprite.flip_h = false
					else:
						sprite.flip_h = true
						
					death.play()
					
					add_child(hitDeath_effect)
					add_child(dead_effect)
				
				if onDeath_spawnObject:
					call_deferred("spawnObjects")
				if toggle_skull_blocks_onDeath:
					get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "skull_block", "skull_block_toggle")
		
		
	
	
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
		
		#print("this object is in: ", loadingZone)

	#SAVE END




func manage_animation():
	if not dead:
		if not attacked and not attacking and velocity.x != 0:
			if not floating:
				sprite.play("walk")
			else:
				sprite.play("flying")
			
			
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
		
		elif on_floor and movementType == "stacionary":
			sprite.play("idle")
		
		
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
		
	




func spawnObjects():
	while onDeath_spawnObject_objectAmount > 0:
		onDeath_spawnObject_objectAmount -= 1
		var onDeath_spawnObject_object = onDeath_spawnObject_objectPath.instantiate()
		get_parent().get_parent().add_child(onDeath_spawnObject_object)
		onDeath_spawnObject_object.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
		
		if onDeath_spawnObject_object.get_class() == "CharacterBody2D" and onDeath_spawnObject_throwAround:
			onDeath_spawnObject_object.velocity.x = rng.randf_range(400.0, -400.0)
			onDeath_spawnObject_object.velocity.y = min(-abs(onDeath_spawnObject_object.velocity.x) * 1.2, 100)





#MAIN PROCESS

func _physics_process(delta):
	on_floor = is_on_floor()
	
	#MOVEMENT TYPE
	if movementType == "normal":
		movement_normal(delta)
		
	elif movementType == "followPlayerX":
		movement_followPlayerX(delta)
	elif movementType == "followPlayerY":
		movement_followPlayerY(delta)
	elif movementType == "followPlayerXY":
		movement_followPlayerXY(delta)
		
	elif movementType == "followPlayerX_whenSpotted":
		movement_followPlayerX_whenSpotted(delta)
	elif movementType == "followPlayerY_whenSpotted":
		movement_followPlayerY_whenSpotted(delta)
	elif movementType == "followPlayerXY_whenSpotted":
		movement_followPlayerXY_whenSpotted(delta)
		
	elif movementType == "chasePlayerXY_lookAtPlayer":
		movement_chasePlayerXY_lookAtPlayer(delta)
	elif movementType == "chasePlayerXY_lookAtPlayer_whenSpotted":
		movement_chasePlayerXY_lookAtPlayer_whenSpotted(delta)
		
	
	elif movementType == "stationary":
		movement_stationary(delta)
	
	elif movementType == "wave_H":
		movement_wave_H(delta)
	
	
	
	elif movementType == "bouncing":
		movement_bouncing(delta)
	
	
	
	
	
	
	
	#OTHER BEHAVIOUR
	if turnOnLedge:
		handle_turnOnLedge()
	
	if turnOnWall:
		handle_turnOnWall()
	
	if patroling:
		handle_patroling()
	
	if dropProjectile_whenSpotted:
		handle_dropProjectile_whenSpotted()
		
	if shootProjectile_whenSpotted:
		handle_shootProjectile_whenSpotted()
	
	
	
	
	
	
	
	
	if not floating or dead:
		
		#USE BASIC GRAVITY?
		if movementType != "followPlayerY" and movementType != "followPlayerXY" and movementType != "chasePlayerXY_lookAtPlayer" and movementType != "chasePlayerXY_lookAtPlayer_whenSpotted":
			if not is_on_floor():
				velocity.y += gravity * delta
				
				
	
	if force_static_H:
		velocity.x = 0
	if force_static_V:
		velocity.y = 0
	
	
	
	basic_sprite_flipDirection()
	stuck_inside_wall_check()
	
	manage_animation()
	
	if not stuck:
		move_and_slide()




@export var enemyHp = 3
@export var enemyDirection = 1

func _ready():
	hp = enemyHp
	direction = enemyDirection
	basic_onReady()
	$scanForPlayer.monitoring = false
	$scanForPlayer.monitorable = false
	%scanForPlayer_CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)
	
	if movementType == "chasePlayerXY_lookAtPlayer" or movementType == "movement_chasePlayerXY_lookAtPlayer_whenSpotted(" or movementType == "followPlayerY" or movementType == "followPlayerY_whenSpotted(" or movementType == "followPlayerXY" or movementType == "followPlayerXY_whenSpotted":
		floor_snap_length = 0
	
	%patrolDirectionTimer.wait_time = directionTimer_time
	%jumpTimer.wait_time = jumpTimer_time
	
	if enable_generalTimers:
		$timerGeneral1.start()
		$timerGeneral2.start()
		$timerGeneral3.start()
		
		$timerGeneral1.wait_time = generalTimer1_cooldown
		$timerGeneral2.wait_time = generalTimer2_cooldown
		$timerGeneral3.wait_time = generalTimer3_cooldown





#UNLOADING LOGIC

func offScreen_unload():
	pass
	#basic_offScreen_unload()
	#$scanForPlayer.monitoring = false
	#$scanForPlayer.monitorable = false
	#%scanForPlayer_CollisionShape2D.disabled = true
	#%patrolDirectionTimer.set_paused(true)
	#%followDelay.set_paused(true)


func offScreen_load():
	basic_offScreen_load()
	$scanForPlayer.monitoring = true
	$scanForPlayer.monitorable = true
	%scanForPlayer_CollisionShape2D.disabled = false
	%patrolDirectionTimer.set_paused(false)
	%followDelay.set_paused(false)






#OTHER BEHAVIOUR

func handle_turnOnLedge():
	if not $scanForLedge.get_collider() and is_on_floor():
		
		if direction == 1:
			direction = -1
			$scanForLedge.position.x = -32
			
		else:
			direction = 1
			$scanForLedge.position.x = 32
		
		velocity.x = SPEED * direction




#TURN ON WALL

func handle_turnOnWall():
	if is_on_wall() and can_turn:
		can_turn = false
		%Limit_turn.start()
		
		if direction == 1:
			direction = -1
			$scanForLedge.position.x = -32
			
		else:
			direction = 1
			$scanForLedge.position.x = 32
			
		
		if not dead and not movementType == "stationary":
			velocity.x = SPEED * direction
		elif not dead and movementType == "stationary":
			velocity.x = SPEED / 2 * direction



func _on_limit_turn_timeout():
	can_turn = true

#TURN ON WALL END



func handle_patroling():
	handle_patrolDirection()







#MOVEMENT TYPES

func movement_normal(delta):
	if direction and not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta)
		
	else:
		velocity.x = move_toward(velocity.x, 0, 10)
		


func movement_followPlayerX(delta):
	if not dead:
		if can_turn:
			if global_position.x > Globals.player_posX:
				direction = -1
				
			elif global_position.x < Globals.player_posX:
				direction = 1
		
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * 3 * delta * ACCELERATION_MULTIPLIER)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 3 * delta)
	



func movement_followPlayerY(delta):
	if global_position.y < Globals.player_posY:
		direction_v = 1
		
	elif global_position.y > Globals.player_posY:
		direction_v = -1
	
	
	if not dead:
		velocity.y = move_toward(velocity.y, direction_v * SPEED, SPEED * ACCELERATION_MULTIPLIER * delta)
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, direction_v * SPEED, SPEED * delta)
	


func movement_followPlayerXY(delta):
	if not dead:
		position = position.move_toward(Globals.player_pos, SPEED * delta)
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)
	



func movement_chasePlayerXY_lookAtPlayer(delta):
	if not dead:
		look_at(Globals.player_pos)
		self.position = lerp(self.position, Globals.player_pos, 0.01)
	
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)



func movement_followPlayerX_whenSpotted(delta):
	if spottedPlayer:
		movement_followPlayerX(delta)
	
	if spottedPlayer:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * ACCELERATION_MULTIPLIER)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	


func movement_followPlayerY_whenSpotted(delta):
	if spottedPlayer:
		movement_followPlayerY(delta)


func movement_followPlayerXY_whenSpotted(delta):
	if spottedPlayer:
		movement_followPlayerXY(delta)


func movement_chasePlayerXY_lookAtPlayer_whenSpotted(delta):
	if spottedPlayer:
		movement_chasePlayerXY_lookAtPlayer(delta)
	
	if dead and not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)


func movement_stationary(delta):
	if not dead:
		if not afterDelay_jumpAndMove:
			if Globals.player_posX > position.x:
				direction = 1
			else:
				direction = -1
		
		if direction:
			velocity.x = move_toward(velocity.x, 0, 150 * delta)
		
		
		if is_on_floor() and not attacking and not attacked:
			sprite.play("idle")
		elif not is_on_floor() and not attacking and not attacked:
			if not stationary_disable_jump_anim:
				sprite.play("walk")



var velocity_V_target = -100
var toggle = false

func movement_wave_H(delta):
	if dead:
		return
	
	#if is_on_wall():
		#if direction == 1:
			#direction = -1
		#else:
			#direction = 1
		
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta * ACCELERATION_MULTIPLIER)
	
	
	if dead:
		velocity.y = move_toward(velocity.y, 800, 400 * delta * ACCELERATION_MULTIPLIER)
	
	if not dead:
		if velocity.y == velocity_V_target:
			if toggle:
				toggle = false
				velocity_V_target = 100
			else:
				toggle = true
				velocity_V_target = -100
			
		
	velocity.y = move_toward(velocity.y, velocity_V_target, 100 * delta)




func movement_bouncing(delta):
	if not dead:
		if not afterDelay_jumpAndMove:
			if Globals.player_posX > position.x:
				direction = 1
			else:
				direction = -1
		
		if direction:
			velocity.x = move_toward(velocity.x, 0, 150 * delta)
		
		
		if on_floor and not attacking and not attacked:
			sprite.play("idle")
		elif not on_floor and not attacking and not attacked:
			sprite.play("jump")
		
		if on_floor:
			velocity.y = JUMP_VELOCITY

#MOVEMENT TYPES END





func _on_patrol_direction_timer_timeout():
	if afterDelay_changeDirection:
		if not dead:
			if direction == -1:
				direction = 1
				%scanForPlayer_CollisionShape2D.position.x = 320
			else:
				direction = -1
				%scanForPlayer_CollisionShape2D.position.x = -320


func _on_jump_timer_timeout():
	if afterDelay_jump:
		if not dead:
			velocity.y = JUMP_VELOCITY
				


func handle_patrolDirection():
	if not dead and not patrolRectStatic:
		if direction == 1:
			%scanForPlayer_CollisionShape2D.position.x = 320
		else:
			%scanForPlayer_CollisionShape2D.position.x = -320



#spot player logic

var spottedPlayer = false
var followDelay = true

func _on_scan_for_player_area_entered(area):
	if patroling:
		if area.name == "Player_hitbox_main" and not dead:
			spottedPlayer = true
			%followDelay.start()
			%patrolDirectionTimer.stop()


func _on_scan_for_player_area_exited(area):
	if patroling:
		if area.name == "Player_hitbox_main" and not dead:
			spottedPlayer = false
			%followDelay.stop()
			followDelay = true
			%patrolDirectionTimer.start()
		



func _on_follow_delay_timeout():
	followDelay = false





@export var scene_dropProjectile = load("res://player_projectileSecondary_basic.tscn")
@export var scene_shootProjectile = load("res://player_projectileSecondary_basic.tscn")
@export var altDropMethod = false
@export var projectile_isBouncingBall = false

func handle_dropProjectile_whenSpotted():
	if not shoot_delay and spottedPlayer:
		shoot_delay = true
		%shoot_delay.start()
		
		if not dead:
			var dropProjectile = scene_dropProjectile.instantiate()
			dropProjectile.position = position + Vector2(Globals.direction * 0, 32)
			dropProjectile.direction = direction
			if altDropMethod and velocity.y <= -100 or altDropMethod and velocity.y == 0:
				dropProjectile.velocity = Vector2(velocity.x * 1.2, -100)
			else:
				dropProjectile.velocity = Vector2(velocity.x * 1.2, 100)
				
			dropProjectile.enemyProjectile = true
			dropProjectile.playerProjectile = false
			dropProjectile.bouncy = true
			get_parent().get_parent().add_child(dropProjectile)
			
			$dropProjectile.play()
			
			attacking = true
			attacking_timer.start()



func handle_shootProjectile_whenSpotted():
	if not shoot_delay and spottedPlayer:
		shoot_delay = true
		%shoot_delay.start()
		
		if not dead:
			var shootProjectile = scene_shootProjectile.instantiate()
			shootProjectile.position = position + Vector2(Globals.direction * 0, 32)
			shootProjectile.direction = direction
			
			if projectile_isBouncingBall:
				shootProjectile.velocity = Vector2(SPEED * direction, rng.randf_range(200.0, -1000.0))
			else:
				
				if altDropMethod and velocity.y <= -100 or altDropMethod and velocity.y == 0:
					shootProjectile.velocity = Vector2(velocity.x * 1.2, -100)
				else:
					shootProjectile.velocity = Vector2(velocity.x * 1.2, 100)
				
			
			shootProjectile.enemyProjectile = true
			shootProjectile.playerProjectile = false
			shootProjectile.bouncy = true
			
			shootProjectile.direction = direction
			get_parent().get_parent().add_child(shootProjectile)
			
			$shootProjectile.play()
			
			attacking = true
			attacking_timer.start()




var shoot_delay = false

func _on_shoot_delay_timeout():
	shoot_delay = false



var stuck = false

func stuck_inside_wall_check():
	if velocity.y > 2000:
		stuck = true
		
	if stuck:
		if $scanForLedge.get_collider():
			velocity.y = 0
			position -= Vector2(1, 8)
		else:
			stuck = false
	








#GENERAL TIMERS

func handle_generalTimerTimeout(generalTimer):
	if afterDelay_jumpAndMove:
		if afterDelay_jumpAndMove_timerID == generalTimer:
			jumpAndMove()
	
	if afterDelay_jump2:
		if afterDelay_jump2_timerID == generalTimer:
			jump2()
	
	if afterDelay_changeDirection2:
		if afterDelay_changeDirection2_timerID == generalTimer:
			changeDirection2()




func _on_timer_general_1_timeout():
	handle_generalTimerTimeout(1)

func _on_timer_general_2_timeout():
	handle_generalTimerTimeout(2)

func _on_timer_general_3_timeout():
	handle_generalTimerTimeout(3)




func jumpAndMove():
	velocity = Vector2(SPEED * direction, JUMP_VELOCITY)

func jump2():
	if not dead:
		velocity.y = JUMP_VELOCITY

func changeDirection2():
	if not dead:
		if direction == -1:
			direction = 1
			%scanForPlayer_CollisionShape2D.position.x = 320
		else:
			direction = -1
			%scanForPlayer_CollisionShape2D.position.x = -320


