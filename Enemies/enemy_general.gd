extends enemy_basic

var on_floor = false
var on_wall = false
var on_ceiling = false

var patrolRect_width = 320
var patrolRect_height = 320

var starParticleScene = preload("res://particles_special.tscn")
var starParticle2Scene = preload("res://particles_star.tscn")
var orbParticleScene = preload("res://particles_special2_multiple.tscn")
var splashParticleScene = preload("res://particles_water_entered.tscn")
var effect_dustScene = preload("res://effect_dust.tscn")
var effect_dust_moveUpScene = preload("res://effect_dust_moveUp.tscn")

@export var SPEED = 400
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION_MULTIPLIER = 1.0

@export_enum("normal", "followPlayerX", "followPlayerY", "followPlayerXY", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerXY_lookAtPlayer", "chasePlayerXY_lookAtPlayer_whenSpotted", "stationary", "wave_H", "wave_V", "moveAround_startPosition_XY_when_notSpotted", "moveAround_startPosition_X_when_notSpotted", "moveAround_startPosition_Y_when_notSpotted") var movementType: String

@export_group("otherBehaviour")
@export var give_score_onDeath = false
@export var scoreValue = 1000

@export var turnOnLedge = false
@export var turnOnWall = false
@export var floating = false

@export var patroling = false

@export var afterDelay_changeDirection = false
@export var afterDelay_jump = false

@export var onDeath_spawnObject = false

@export var immortal = false
@export var damageTo_player = true
@export var damageTo_enemies = false

@export var patrolRectStatic = false

@export var shootProjectile_whenSpotted = false
@export var dropProjectile_whenSpotted = false
@export var shootProjectile_cooldown = 0.5
@export var dropProjectile_cooldown = 0.5

@export var toggle_skull_blocks_onDeath = false

@export var force_static_H = false
@export var force_static_V = false

@export var onDeath_disappear_instantly = false

@export var whenAt_startPosition_X_stop = false
@export var whenAt_startPosition_Y_stop = false

@export var onSpawn_offset_position = Vector2(0, 0)

@export var bouncy_Y = false
@export var bouncy_X = false

@export var ascending = false

@export_group("") #END OF BEHAVIOUR LIST



@export_group("specificInfo")
@export var onDeath_spawnObject_objectPath = preload("res://Collectibles/collectibleApple.tscn")
@export var onDeath_spawnObject_objectAmount = 1
@export var onDeath_spawnObject_throwAround = false

@export var directionTimer_time = 4.0
@export var jumpTimer_time = 4.0

@export var stationary_disable_jump_anim = false

@export var start_pos_leniency_X = 15
@export var start_pos_leniency_Y = 15

#BONUS BOX (The player can bounce off of it, and gains greater height if the jump button is pressed during the bounce.)
@export var is_bonusBox = false
@export var bonusBox_spawn_item_onDeath = true
@export var bonusBox_item_scene = preload("res://Collectibles/collectibleApple.tscn")
@export var bonusBox_collectibleAmount = 10
@export var bonusBox_throw_around = false
@export var bonusBox_spread_position = true
@export var bonusBox_requiresVelocity = true
@export var bonusBox_minimalVelocity = 100

@export var particles_star = true
@export var particles_golden = true
@export var particles_splash = true

#GENERAL TIMERS
@export var enable_generalTimers = true
@export var generalTimer1_cooldown = 3.0
@export var generalTimer2_cooldown = 3.0
@export var generalTimer3_cooldown = 3.0

@export var t_afterDelay_jump = false
@export var t_afterDelay_jump_timerID = 0
@export var t_afterDelay_jumpAndMove = false
@export var t_afterDelay_jumpAndMove_timerID = 0
@export var t_afterDelay_changeDirection = false
@export var t_afterDelay_changeDirection_timerID = 0
@export var t_afterDelay_spawnObject = false
@export var t_afterDelay_spawnObject_timerID = 0
@export var t_afterDelay_selfDestruct = false
@export var t_afterDelay_selfDestruct_timerID = 0
@export var t_afterDelay_selfDestructAndSpawnObject = false
@export var t_afterDelay_selfDestructAndSpawnObject_timerID = 0

@export_group("") #END OF BEHAVIOUR LIST


var rng = RandomNumberGenerator.new()

func _on_area_2d_area_entered(area):
	#HANDLE ATTACK PLAYER
	if area.name == "Player_hitbox_main" and not dead:
		if damageTo_player:
			attacking = true
			attacking_timer.start()
			
			if hostile:
				Globals.playerHit1.emit()
			
		
		#HANDLE BONUS BOX PLAYER BOUNCE
		if is_bonusBox:
			if bonusBox_requiresVelocity and area.get_parent().velocity.y < bonusBox_minimalVelocity:
				return
				
			if Input.is_action_pressed("jump"):
				area.get_parent().velocity.y = -600
				spawn_particles()
				
			else:
				area.get_parent().velocity.y = -300
				spawn_particles()
			
			handle_damage(area)
	
	
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
	elif area.is_in_group("player_projectile") and area.get_parent().playerProjectile and hostile or not hostile and area.get_parent().is_in_group("enemies") or area.is_in_group("fire"):
		if not dead and not area.is_in_group("fire") and area.get_parent().playerProjectile:
			handle_damage(area)
			call_deferred("enemy_stunned")
			
	
	
	elif area.get_parent().is_in_group("enemies"):
		if not dead and area.get_parent().damageTo_enemies:
			handle_damage(area)
			call_deferred("enemy_stunned")
			
	



@export var familyID = 0

func handle_damage(area):
	if familyID != 0 and area.get_parent().familyID == familyID:
		return
		
	attacked = true
	attacked_timer.start()
	hit.play()
	var hit_effect = hit_effectScene.instantiate()
	add_child(hit_effect)
	if not area.is_in_group("fire"):
		hp -= area.get_parent().damageValue
	else:
		hp -= area.damageValue
	Globals.enemyHit.emit()
	if hp <= 0:
		dead = true
		
		Globals.specialAction.emit()
		direction = 0
		sprite.play("dead")
		if direction == 1:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		
		if is_bonusBox:
			if bonusBox_spawn_item_onDeath:
				call_deferred("bonusBox_spawn_collectibles")
				
			if give_score_onDeath:
				Globals.level_score += scoreValue
				Globals.combo_score += scoreValue * Globals.combo_tier
				Globals.itemCollected.emit()
				
				%collectedDisplay.text = str(scoreValue * Globals.combo_tier)
				%AnimationPlayer.play("score_value")
			
			
			var star1 = starParticleScene.instantiate()
			var star2 = starParticleScene.instantiate()
			var star3 = starParticleScene.instantiate()
			var dust = effect_dust_moveUpScene.instantiate()
			
			add_child(star1)
			add_child(star2)
			add_child(star3)
			add_child(dust)
		
		
		death.play()
		
		var hitDeath_effect = hitDeath_effectScene.instantiate()
		var dead_effect = dead_effectScene.instantiate()
		
		add_child(hitDeath_effect)
		add_child(dead_effect)
		
		if onDeath_spawnObject:
			call_deferred("spawnObjects")
		if toggle_skull_blocks_onDeath:
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "skull_block", "skull_block_toggle")
		if onDeath_disappear_instantly:
			await get_tree().create_timer(1, false).timeout
			queue_free()





#SAVE START

func save():
	var save_dict = {
		#"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"hp" : hp,
		"direction" : direction,
		"dead" : dead,
		
	}
	return save_dict

#SAVE END



func manage_animation():
	if not dead:
		if on_floor and not attacked and not attacking and velocity.x != 0:
			if not floating:
				sprite.play("walk")
			
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
		
		elif on_floor and velocity.x == 0:
			sprite.play("idle")
		
		elif not on_floor and not floating and not on_floor and not ascending:
			sprite.play("jump")
		
		elif floating or ascending:
			sprite.play("flying")
		
		
		
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
				var starParticle_fast = starParticle_fastScene.instantiate()
				add_child(starParticle_fast)
			
				particle_limiter.start()
				particle_buffer = true
		
	




func spawnObjects():
	while onDeath_spawnObject_objectAmount > 0:
		onDeath_spawnObject_objectAmount -= 1
		var onDeath_spawnObject_object = onDeath_spawnObject_objectPath.instantiate()
		$/root/World.add_child(onDeath_spawnObject_object)
		onDeath_spawnObject_object.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
		
		if onDeath_spawnObject_object.get_class() == "CharacterBody2D" and onDeath_spawnObject_throwAround:
			onDeath_spawnObject_object.velocity.x = rng.randf_range(400.0, -400.0)
			onDeath_spawnObject_object.velocity.y = min(-abs(onDeath_spawnObject_object.velocity.x) * 1.2, 100)





#MAIN PROCESS

func _physics_process(delta):
	on_floor = is_on_floor()
	on_wall = is_on_wall()
	on_ceiling = is_on_ceiling()
	
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
	
	elif movementType == "wave_V":
		movement_wave_V(delta)
	
	
	elif movementType == "moveAround_startPosition_XY_when_notSpotted":
		moveAround_startPosition_XY_when_notSpotted(delta)
	
	elif movementType == "moveAround_startPosition_X_when_notSpotted":
		moveAround_startPosition_X_when_notSpotted(delta)
	
	elif movementType == "moveAround_startPosition_Y_when_notSpotted":
		moveAround_startPosition_Y_when_notSpotted(delta)
	
	
	
	
	
	
	
	
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
	
	
	if whenAt_startPosition_X_stop:
		handle_whenAt_startPosition_X_stop(delta)
	
	if whenAt_startPosition_Y_stop:
		handle_whenAt_startPosition_Y_stop(delta)
	
	
	if bouncy_Y:
		handle_bouncy_Y(delta)
	
	if bouncy_X:
		handle_bouncy_X(delta)
	
	
	if ascending:
		handle_ascending(delta)
	
	
	
	
	
	
	if not floating or dead:
		
		#USE BASIC GRAVITY?
		if not is_ascending and movementType != "followPlayerY" and movementType != "followPlayerXY" and movementType != "chasePlayerXY_lookAtPlayer" and movementType != "chasePlayerXY_lookAtPlayer_whenSpotted":
			if not is_on_floor():
				velocity.y += gravity * delta
				
				
	
	if force_static_H:
		velocity.x = 0
	if force_static_V:
		velocity.y = 0
	
	
	
	basic_sprite_flipDirection()
	stuck_inside_wall_check()
	
	manage_animation()
	
	if not attacked and not stuck:
		move_and_slide()
	
	
	if debug:
		print("CAN TURN: " + str(can_turn) + " ON WALL: " + str(is_on_wall()) + " DIRECTION: " + str(direction))
		if get_node_or_null("$Label"):
			get_node_or_null("$Label").text = "this"





func _ready():
	basic_onReady()
	$scanForPlayer.monitoring = false
	$scanForPlayer.monitorable = false
	%scanForPlayer_CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)
	
	if shootProjectile_cooldown != 0.5:
		%shoot_delay.wait_time = shootProjectile_cooldown
	if dropProjectile_cooldown != 0.5:
		%drop_delay.wait_time = dropProjectile_cooldown
	
	if movementType == "chasePlayerXY_lookAtPlayer" or movementType == "movement_chasePlayerXY_lookAtPlayer_whenSpotted(" or movementType == "followPlayerY" or movementType == "followPlayerY_whenSpotted(" or movementType == "followPlayerXY" or movementType == "followPlayerXY_whenSpotted":
		floor_snap_length = 0
	
	if directionTimer_time != 4.0:
		%patrolDirectionTimer.wait_time = directionTimer_time
	if jumpTimer_time != 4.0:
		%jumpTimer.wait_time = jumpTimer_time
	
	if enable_generalTimers:
		$timerGeneral1.start()
		$timerGeneral2.start()
		$timerGeneral3.start()
		
		$timerGeneral1.wait_time = generalTimer1_cooldown
		$timerGeneral2.wait_time = generalTimer2_cooldown
		$timerGeneral3.wait_time = generalTimer3_cooldown
	
	if patroling:
		patrolRect_width = $scanForPlayer/scanForPlayer_CollisionShape2D.shape.size[0]
		patrolRect_height = $scanForPlayer/scanForPlayer_CollisionShape2D.shape.size[1]
	
	if onSpawn_offset_position != Vector2(0, 0):
		position = position + Vector2(randi_range(0, onSpawn_offset_position[0]), randi_range(0, onSpawn_offset_position[1]))




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


@export var debug = false

#TURN ON WALL

func handle_turnOnWall():
	if is_on_wall() and can_turn:
		can_turn = false
		%Limit_turn.start()
		
		if direction == 1:
			direction = -1
			
			if turnOnLedge:
				$scanForLedge.position.x = -32
			
		else:
			direction = 1
			
			if turnOnLedge:
				$scanForLedge.position.x = 32
			
		
		if not dead and not movementType == "stationary":
			velocity.x = SPEED * direction
		elif not dead and movementType == "stationary":
			velocity.x = SPEED / 2 * direction



func _on_limit_turn_timeout():
	can_turn = true
	if debug:
		print("CAN TURN AGAIN")

#TURN ON WALL END



#OTHER BEHAVIOUR

func handle_patroling():
	handle_patrolDirection()


var start_pos_can_turn_X = true
var start_pos_can_turn_Y = true
func handle_whenAt_startPosition_X_stop(delta):
	if abs(global_position.x - start_pos_x) <= start_pos_leniency_X:
		if debug:
			scale = Vector2(1.5, 1.5)
		if not spottedPlayer:
			start_pos_can_turn_X = false
			velocity.x = move_toward(velocity.x, 0, delta * ACCELERATION_MULTIPLIER * 1000)
	else:
		start_pos_can_turn_X = true
		if debug:
			scale = Vector2(1, 1)


func handle_whenAt_startPosition_Y_stop(delta):
	if start_pos_y - global_position.y <= start_pos_leniency_Y:
		velocity.y = move_toward(velocity.y, 0, delta * ACCELERATION_MULTIPLIER)
		start_pos_can_turn_Y = false


func handle_bouncy_Y(delta):
	if not dead:
		if on_floor:
			velocity.y = JUMP_VELOCITY
		if on_ceiling:
			velocity.y = -JUMP_VELOCITY
			

func handle_bouncy_X(delta):
	if not dead:
		if on_wall:
			velocity.x = SPEED * direction


func handle_ascending(delta):
	if is_ascending and not dead:
		velocity.y = move_toward(velocity.y, JUMP_VELOCITY, delta * ACCELERATION_MULTIPLIER * 1000)



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
		start_pos_can_turn_Y = true


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
		if not t_afterDelay_jumpAndMove:
			if Globals.player_posX > position.x:
				direction = 1
			else:
				direction = -1
		
		if direction:
			velocity.x = move_toward(velocity.x, 0, 150 * delta)
		



var velocity_H_target = 100
var velocity_V_target = -100
var toggle_H = false
var toggle_V = false

func movement_wave_V(delta):
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta * ACCELERATION_MULTIPLIER)
	
	
	if dead:
		velocity.y = move_toward(velocity.y, 800, 400 * delta * ACCELERATION_MULTIPLIER)
	
	if not dead:
		if velocity.y == velocity_V_target:
			if toggle_V:
				toggle_V = false
				velocity_V_target = 100
			else:
				toggle_V = true
				velocity_V_target = -100
			
		
	velocity.y = move_toward(velocity.y, velocity_V_target, 100 * delta)


func movement_wave_H(delta):
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, 500 * delta * ACCELERATION_MULTIPLIER)
	
	
	if dead:
		velocity.x = move_toward(velocity.x, 800, 400 * delta * ACCELERATION_MULTIPLIER)
	
	if not dead:
		if velocity.x == velocity_H_target:
			if toggle_H:
				toggle_H = false
				velocity_H_target = 100
			else:
				toggle_H = true
				velocity_H_target = -100
			
		
	velocity.x = move_toward(velocity.x, velocity_H_target, 100 * delta)




func moveAround_startPosition_XY_when_notSpotted(delta):
	if direction == 1:
		%scanForPlayer_CollisionShape2D.position.x = patrolRect_width / 2
			
	else:
		%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width / 2
			
	
	
	if not dead and not spottedPlayer:
		if global_position.x >= start_pos_x: #start_pos_x - global_position.x <= 15:
			direction = -1
		else:
			direction = 1
	
	if not dead and not spottedPlayer:
		if global_position.y >= start_pos_y:
			direction_v = -1
		else:
			direction_v = 1
	
	
	if not dead and spottedPlayer:
		if global_position.x >= Globals.player_posX: #Globals.player_posX - global_position.x <= 15:
			direction = -1
		else:
			direction = 1
	
	
	if not dead and spottedPlayer:
		if global_position.y >= Globals.player_posY:
			direction_v = -1
		else:
			direction_v = 1
	
	
	
	
	if not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 1000 * ACCELERATION_MULTIPLIER)
		velocity.y = move_toward(velocity.y, direction_v * SPEED, delta * 800 * ACCELERATION_MULTIPLIER)
		
		
		
	if dead:
		velocity.x = 0
		velocity.y = 0


func moveAround_startPosition_X_when_notSpotted(delta):
	if direction == 1:
		%scanForPlayer_CollisionShape2D.position.x = patrolRect_width / 2
			
	else:
		%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width / 2
			
	
	
	if not dead and not spottedPlayer:
		if start_pos_can_turn_X:
			if global_position.x >= start_pos_x:
				direction = -1
			else:
				direction = 1
			
	
	#if not dead and not spottedPlayer:
		#if global_position.y >= start_pos_y:
			#direction_v = -1
		#else:
			#direction_v = 1
	
	
	if not dead and spottedPlayer:
		start_pos_can_turn_X = true
		if global_position.x >= Globals.player_posX: #Globals.player_posX - global_position.x <= 15:
			direction = -1
		else:
			direction = 1
	
	
	#if not dead and spottedPlayer:
		#if global_position.y >= Globals.player_posY:
			#direction_v = -1
		#else:
			#direction_v = 1
	
	
	
	
	if not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 800)
		#velocity.y = move_toward(velocity.y, direction_v * SPEED, delta * 400)
		
		
		
	if dead:
		velocity.x = 0
		#velocity.y = 0

func moveAround_startPosition_Y_when_notSpotted(delta):
	if direction == 1:
		%scanForPlayer_CollisionShape2D.position.x = patrolRect_width / 2
			
	else:
		%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width / 2
			
	
	
	#if not dead and not spottedPlayer:
		#if global_position.x >= start_pos_x: #start_pos_x - global_position.x <= 15:
			#direction = -1
		#else:
			#direction = 1
	
	if not dead and not spottedPlayer:
		if start_pos_can_turn_Y and global_position.y >= start_pos_y:
			direction_v = -1
		else:
			direction_v = 1
	
	
	#if not dead and spottedPlayer:
		#if global_position.x >= Globals.player_posX: #Globals.player_posX - global_position.x <= 15:
			#direction = -1
		#else:
			#direction = 1
	
	
	if not dead and spottedPlayer:
		start_pos_can_turn_Y = true
		if global_position.y >= Globals.player_posY:
			direction_v = -1
		else:
			direction_v = 1
	
	
	
	
	if not dead:
		#velocity.x = move_toward(velocity.x, direction * SPEED, delta * 800)
		velocity.y = move_toward(velocity.y, direction_v * SPEED, delta * 400)
		
		
		
	if dead:
		#velocity.x = 0
		velocity.y = 0


#MOVEMENT TYPES END





func _on_patrol_direction_timer_timeout():
	if afterDelay_changeDirection:
		if not dead:
			if direction == -1:
				direction = 1
				%scanForPlayer_CollisionShape2D.position.x = patrolRect_width / 2
			else:
				direction = -1
				%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width / 2


func _on_jump_timer_timeout():
	if afterDelay_jump:
		if not dead and not is_ascending:
			velocity.y = JUMP_VELOCITY
				


func handle_patrolDirection():
	if not dead and not patrolRectStatic:
		if direction == 1:
			%scanForPlayer_CollisionShape2D.position.x = patrolRect_width / 2
		else:
			%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width / 2



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

@export var shootProjectile_offset_X = 0
@export var shootProjectile_offset_Y = 0

@export var shootProjectile_player = false
@export var shootProjectile_enemy = true


func handle_dropProjectile_whenSpotted():
	if not shoot_delay and spottedPlayer:
		shoot_delay = true
		%shoot_delay.start()
		
		if not dead:
			var dropProjectile = scene_dropProjectile.instantiate()
			dropProjectile.position = global_position + Vector2(0, 32)
			dropProjectile.direction = direction
			if altDropMethod and velocity.y <= -100 or altDropMethod and velocity.y == 0:
				dropProjectile.velocity = Vector2(velocity.x * 1.2, -100)
			else:
				dropProjectile.velocity = Vector2(velocity.x * 1.2, 100)
				
			dropProjectile.enemyProjectile = true
			dropProjectile.playerProjectile = false
			dropProjectile.bouncy = true
			$/root/World.add_child(dropProjectile)
			
			$dropProjectile.play()
			
			attacking = true
			attacking_timer.start()



func handle_shootProjectile_whenSpotted():
	if not shoot_delay and spottedPlayer:
		shoot_delay = true
		%shoot_delay.start()
		
		if not dead:
			var shootProjectile = scene_shootProjectile.instantiate()
			shootProjectile.position = position + Vector2(shootProjectile_offset_X * direction, shootProjectile_offset_Y * direction_v)
			shootProjectile.direction = direction
			
			if projectile_isBouncingBall:
				shootProjectile.velocity = Vector2(SPEED * direction, rng.randf_range(200.0, -1000.0))
			else:
				
				if altDropMethod and velocity.y <= -100 or altDropMethod and velocity.y == 0:
					shootProjectile.velocity = Vector2(velocity.x * 1.2, -100)
				else:
					shootProjectile.velocity = Vector2(velocity.x * 1.2, 100)
				
			
			if shootProjectile_player:
				shootProjectile.playerProjectile = true
			else:
				shootProjectile.playerProjectile = false
			
			if shootProjectile_enemy:
				shootProjectile.enemyProjectile = true
			else:
				shootProjectile.enemyProjectile = false
			
			
			
			$/root/World.add_child(shootProjectile)
			
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
	if t_afterDelay_jump:
		if t_afterDelay_jump_timerID == generalTimer:
			t_jump()
	
	if t_afterDelay_jumpAndMove:
		if t_afterDelay_jumpAndMove_timerID == generalTimer:
			t_jumpAndMove()
	
	if t_afterDelay_changeDirection:
		if t_afterDelay_changeDirection_timerID == generalTimer:
			t_changeDirection()
	
	if t_afterDelay_selfDestruct:
		if t_afterDelay_selfDestruct_timerID == generalTimer:
			t_selfDestruct()



func _on_timer_general_1_timeout():
	handle_generalTimerTimeout(1)

func _on_timer_general_2_timeout():
	handle_generalTimerTimeout(2)

func _on_timer_general_3_timeout():
	handle_generalTimerTimeout(3)



func t_jump():
	if not dead:
		velocity.y = JUMP_VELOCITY

func t_jumpAndMove():
	if not dead:
		velocity = Vector2(SPEED * direction, JUMP_VELOCITY)

func t_changeDirection():
	if not dead:
		if direction == -1:
			direction = 1
			%scanForPlayer_CollisionShape2D.position.x = patrolRect_width
		else:
			direction = -1
			%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width

func t_selfDestruct():
	var effect_dust = effect_dustScene.instantiate()
	effect_dust.global_position = global_position
	$/root/World.add_child(effect_dust)
	
	var orbParticle = orbParticleScene.instantiate()
	orbParticle.global_position = global_position
	$/root/World.add_child(orbParticle)
	
	queue_free()


#GENERAL TIMERS END



var is_ascending = false

func _on_fly_cooldown_timeout():
	if not dead:
		is_ascending = true
		%flyEnd.start()
		velocity.y = 0

func _on_fly_end_timeout():
	if not dead:
		is_ascending = false
		%flyCooldown.start()



func spawn_particles():
	if particles_star:
		add_child(starParticleScene.instantiate())
	if particles_golden:
		add_child(orbParticleScene.instantiate())
	if particles_splash:
		add_child(splashParticleScene.instantiate())



func bonusBox_spawn_collectibles():
	while bonusBox_collectibleAmount > 0:
		bonusBox_collectibleAmount -= 1
		bonusBox_spawn_item()
		
	
	var hit_effect = hit_effectScene.instantiate()
	add_child(hit_effect)



func bonusBox_spawn_item():
	var item = bonusBox_item_scene.instantiate()
	
	if bonusBox_throw_around:
		item.velocity.x = rng.randf_range(400.0, -400.0)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	if bonusBox_spread_position:
		item.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
	
	
	$/root/World.add_child(item)
