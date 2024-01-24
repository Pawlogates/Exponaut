extends enemy_basic


var debugValue = 0

@export var SPEED = 400
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION_MULTIPLIER = 5

@export_enum("normal", "followPlayerX", "followPlayerY", "followPlayerXY", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerXY_lookAtPlayer", "chasePlayerXY_lookAtPlayer_whenSpotted", "stationary") var movementType: String

@export_group("otherBehaviour")
@export var turnOnLedge = false
@export var turnOnWall = false
@export var floating = false

@export var patroling = false

@export var afterDelay_changeDirection = false
@export var afterDelay_jump = false

@export var onDeath_spawnObject = false
#@export var floating = false
#@export var floating = false
#@export var floating = false
#@export var floating = false
#@export var floating = false


@export_group("") #END OF BEHAVIOUR LIST



@export_group("specificInfo")
@export var onDeath_spawnObject_objectPath = preload("res://Collectibles/collectibleApple.tscn")
@export var onDeath_spawnObject_objectAmount = 1
@export var onDeath_spawnObject_throwAround = false

@export var directionTimer_time = 4.0
@export var jumpTimer_time = 4.0


@export_group("") #END OF BEHAVIOUR LIST


var rng = RandomNumberGenerator.new()

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
			hit_effect = hit_effectScene.instantiate()
			add_child(hit_effect)
			hp -= area.get_parent().damageValue
			Globals.enemyHit.emit()
			if hp <= 0:
				dead = true
				direction = 0
				sprite.play("dead")
				death.play()
				add_child(dead_effect)
				
				if onDeath_spawnObject:
					call_deferred("spawnObjects")
					
					
	
	
	
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
		if not attacked and not attacking:
			sprite.play("walk")
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




func spawnObjects():
	while onDeath_spawnObject_objectAmount > 0:
		onDeath_spawnObject_objectAmount -= 1
		var onDeath_spawnObject_object = onDeath_spawnObject_objectPath.instantiate()
		get_tree().get_root().add_child(onDeath_spawnObject_object)
		onDeath_spawnObject_object.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
		
		if onDeath_spawnObject_object.get_class() == "CharacterBody2D" and onDeath_spawnObject_throwAround:
			onDeath_spawnObject_object.velocity.x = rng.randf_range(400.0, -400.0)
			onDeath_spawnObject_object.velocity.y = min(-abs(onDeath_spawnObject_object.velocity.x) * 1.2, 100)





#MAIN PROCESS

func _physics_process(delta):
	
	#OTHER BEHAVIOUR
	
	if turnOnLedge:
		handle_turnOnLedge()
	
	if turnOnWall:
		handle_turnOnWall()
	
	if patroling:
		handle_patroling()
	
	
	
	
	
	
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
	
	
	
	
	
	
	
	if not floating:
		
		#USE BASIC GRAVITY?
		if movementType != "followPlayerY" and movementType != "followPlayerXY" and movementType != "chasePlayerXY_lookAtPlayer" and movementType != "chasePlayerXY_lookAtPlayer_whenSpotted":
			if not is_on_floor():
				velocity.y += gravity * delta
				
				
	
	
	basic_sprite_flipDirection()
	manage_animation()
	
	
	
	move_and_slide()





func _ready():
	hp = 3
	direction = 1
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
	if not dead:
		velocity.x = SPEED * direction



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
	if global_position.x > Globals.player_posX:
		direction = -1
		
	elif global_position.x < Globals.player_posX:
		direction = 1
	
	
	if not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * 3 * delta)
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
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta)
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
	velocity.x = 0



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
	if not dead:
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








