extends enemy_basic

@onready var world = $/root/World
@onready var player = $/root/World.player

@onready var scanForLedge = $scanForLedge

var on_floor = false
var on_wall = false
var on_wall_normal = Vector2(0, 0)
var on_ceiling = false

var velocity_last_X = 0
var velocity_last_Y = 0 

var patrolRect_width = 320
var patrolRect_height = 320

var rng = RandomNumberGenerator.new()

#Properties
@export var hp = 3
@export var damageValue = 1
@export var SPEED = 100.0
@export var JUMP_VELOCITY = -400.0
@export var ACCELERATION_MULTIPLIER = 1.0

@export_enum("normal", "followPlayerX", "followPlayerY", "followPlayerXY", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerXY_lookAtPlayer", "chasePlayerXY_lookAtPlayer_whenSpotted", "stationary", "wave_H", "wave_V", "moveAround_startPosition_XY_when_notSpotted", "moveAround_startPosition_X_when_notSpotted", "moveAround_startPosition_Y_when_notSpotted") var movementType: String

@export_group("otherBehaviour")
@export var give_score_onDeath = true
@export var scoreValue = 1000

@export var turnOnLedge = false
@export var turnOnWall = false
@export var slowDown_onDirectionChange = true
@export var floating = false

@export var patroling = false

@export var afterDelay_changeDirection = false
@export var afterDelay_jump = false
@export var directionTimer_time = 4.0
@export var jumpTimer_time = 4.0

@export var onDeath_spawnObject = false
@export var onDeath_spawnObject_objectPath = preload("res://Collectibles/collectibleApple.tscn")
@export var onDeath_spawnObject_objectAmount = 1
@export var onDeath_spawnObject_throwAround = false

@export var immortal = false

@export var shootProjectile_whenSpotted = false
@export var dropProjectile_whenSpotted = false
@export var shootProjectile_cooldown = 0.5
@export var dropProjectile_cooldown = 0.5
@export var scene_shootProjectile : PackedScene = load("res://Projectiles/player_projectile_basic.tscn")
@export var scene_dropProjectile : PackedScene = load("res://Projectiles/player_secondaryProjectile_basic.tscn")
@export var altDropMethod = false
@export var projectile_isBouncingBall = false
@export var shootProjectile_offset_X = 0
@export var shootProjectile_offset_Y = 0
@export var shootProjectile_player = false
@export var shootProjectile_enemy = true

@export var toggle_toggleBlocks_onDeath = false

@export var whenAt_startPosition_X_stop = false
@export var whenAt_startPosition_Y_stop = false
@export var start_pos_leniency_X = 15
@export var start_pos_leniency_Y = 15

@export var onSpawn_offset_position = Vector2(0, 0)

@export var bouncy_Y = false
@export var bouncy_X = false

@export var ascending = false

@export_group("") #END OF BEHAVIOUR LIST


@export_group("specificInfo")
@export var damageTo_player = true
@export var damageTo_enemies = false
@export var familyID = 0 #will not be damaged by entities with the same familyID
@export var can_affect_player = true

@export var stationary_disable_jump_anim = false
@export var patrolRectStatic = false
@export var force_static_H = false
@export var force_static_V = false
@export var onDeath_disappear_instantly = false

#BONUS BOX (The player can bounce off of it, and gains greater height if the jump button is pressed during the bounce.)
@export var is_bonusBox = true
@export var bonusBox_spawn_item_onDeath = false
@export var bonusBox_item_scene = preload("res://Collectibles/collectibleApple.tscn")
@export var bonusBox_collectibleAmount = 10
@export var bonusBox_throw_around = false
@export var bonusBox_spread_position = true
@export var bonusBox_requiresVelocity = true
@export var bonusBox_minimalVelocity = 100
@export var bonusBox_giveVelocity = -400
@export var bonusBox_giveVelocity_jump = -600

@export var particles_star = true
@export var particles_golden = true
@export var particles_splash = true

#GENERAL TIMERS
@export var enable_generalTimers = true
@export var generalTimer1_cooldown = 3.0
@export var generalTimer2_cooldown = 3.0
@export var generalTimer3_cooldown = 3.0
@export var generalTimer4_cooldown = 3.0 #not included in randomizer
@export var generalTimer5_cooldown = 3.0 #not included in randomizer
@export var generalTimer6_cooldown = 3.0 #not included in randomizer
@export var generalTimer1_randomize_cooldown = false
@export var generalTimer2_randomize_cooldown = false
@export var generalTimer3_randomize_cooldown = false
@export var generalTimer4_randomize_cooldown = false #not included in randomizer
@export var generalTimer5_randomize_cooldown = false #not included in randomizer
@export var generalTimer6_randomize_cooldown = false #not included in randomizer
@export var generalTimer_min_cooldown = 0.5
@export var generalTimer_max_cooldown = 12
@export var generalTimer_randomize_cooldown_onSpawn = false

@export var t_item_scene = preload("res://Collectibles/collectibleLime.tscn")
@export var t_item_amount = 1
@export var t_throw_around = true
@export var t_spread_position = true

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
@export var t_afterDelay_idleSound = false
@export var t_afterDelay_idleSound_timerID = 0
@export var t_afterDelay_randomize_speedAndJumpVelocity = false
@export var t_afterDelay_randomize_speedAndJumpVelocity_timerID = 0
@export var t_afterDelay_spawn_collectibles = false
@export var t_afterDelay_spawn_collectibles_timerID = 0

@export var randomize_everything_onSpawn = false #not included in randomizer (and shouldn't be)

@export_group("") #END OF SPECIFIC INFO
#!Properties

func _ready():
	basic_onReady()
	$scanForPlayer.monitoring = false
	$scanForPlayer.monitorable = false
	%scanForPlayer_CollisionShape2D.disabled = true
	%patrolDirectionTimer.set_paused(true)
	%followDelay.set_paused(true)
	
	if randomize_everything_onSpawn:
		randomize_everything()
	
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
		if generalTimer_randomize_cooldown_onSpawn:
			$timerGeneral1.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
			$timerGeneral2.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
			$timerGeneral3.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
			$timerGeneral4.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
			$timerGeneral5.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
			$timerGeneral6.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
		
		else:
			$timerGeneral1.wait_time = generalTimer1_cooldown
			$timerGeneral2.wait_time = generalTimer2_cooldown
			$timerGeneral3.wait_time = generalTimer3_cooldown
			$timerGeneral4.wait_time = generalTimer4_cooldown
			$timerGeneral5.wait_time = generalTimer5_cooldown
			$timerGeneral6.wait_time = generalTimer6_cooldown
		
		$timerGeneral1.start()
		$timerGeneral2.start()
		$timerGeneral3.start()
		$timerGeneral4.start()
		$timerGeneral5.start()
		$timerGeneral6.start()
	
	
	if patroling:
		patrolRect_width = $scanForPlayer/scanForPlayer_CollisionShape2D.shape.size[0]
		patrolRect_height = $scanForPlayer/scanForPlayer_CollisionShape2D.shape.size[1]
	
	if onSpawn_offset_position != Vector2(0, 0):
		position = position + Vector2(randi_range(0, onSpawn_offset_position[0]), randi_range(0, onSpawn_offset_position[1]))
	
	if ascending:
		%flyCooldown.start()
	
	
	#Debug
	if debug:
		$debug_label.visible = true
		$scanForPlayer/scanForPlayer_CollisionShape2D/ColorRect.visible = true
		$scanForLedge/ColorRect.visible = true


#MAIN PROCESS
func _physics_process(delta):
	on_floor = is_on_floor()
	on_wall = is_on_wall()
	on_wall_normal = get_wall_normal()
	on_ceiling = is_on_ceiling()
	
	if velocity.x != 0:
		velocity_last_X = velocity.x
	if velocity.y != 0:
		velocity_last_Y = velocity.y
	
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
		#print("CAN TURN: " + str(can_turn) + " ON WALL: " + str(is_on_wall()) + " DIRECTION: " + str(direction))
		if get_node_or_null("$debug_label"):
			get_node_or_null("$debug_label").text = str("debug message")
		#if enemy_type == "piranha_a":
			#print(start_pos_x)
		#elif enemy_type == "type":
			#print(info)


func _on_area_2d_area_entered(area):
	#HANDLE ATTACK PLAYER
	if area.name == "Player_hitbox_main" and not dead:
		if damageTo_player:
			attacking = true
			attacking_timer.start()
			
			if can_affect_player:
				Globals.playerHit1.emit()
			
		
		#HANDLE BONUS BOX PLAYER BOUNCE
		if is_bonusBox:
			if bonusBox_requiresVelocity and Globals.player_velocity[1] < bonusBox_minimalVelocity:
				return
				
			if Input.is_action_pressed("jump"): #the velocity value here is effectively worth more, because of the building velocity mechanic that is active while you are holding the JUMP button.
				area.get_parent().velocity.y = bonusBox_giveVelocity_jump
				spawn_particles()
				world.player.air_jump = true
				world.player.wall_jump = true
				
			else:
				area.get_parent().velocity.y = bonusBox_giveVelocity
				spawn_particles()
				world.player.air_jump = true
				world.player.wall_jump = true
			
			handle_damage(area)
	
	
	#HANDLE IMMORTAL
	elif immortal and area.is_in_group("player_projectile") and not area.get_parent().enemyProjectile:
		attacking = true
		attacking_timer.start()
		return
	
	#HANDLE DAMAGE
	elif area.is_in_group("player_projectile") and area.get_parent().playerProjectile or area.is_in_group("fire"):
		if not dead:
			handle_damage(area)
			call_deferred("enemy_stunned")
			
	
	#HANDLE ENEMY ENTERED
	elif area.get_parent().is_in_group("enemies"):
		if familyID != 0 and area.get_parent().familyID == familyID:
			return
		
		if not dead and area.get_parent().damageTo_enemies:
			handle_damage(area)
			call_deferred("enemy_stunned")
	
	#HANDLE FRIENDLY ENTERED
	elif area.get_parent().is_in_group("friendly") and not dead:
		attacking = true
		attacking_timer.start()


#SAVE START
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"hp" : hp,
		"direction" : direction,
		"dead" : dead,
		"start_pos_x" : start_pos_x,
		"start_pos_y" : start_pos_y,
		
	}
	return save_dict
#!SAVE


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


func handle_damage(area):
	if immortal:
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
			
			add_child(star1)
			add_child(star2)
			add_child(star3)
		
		
		death.play()
		
		var hitDeath_effect = hitDeath_effectScene.instantiate()
		var dead_effect = dead_effectScene.instantiate()
		var dust = effect_dust_moveUpScene.instantiate()
		
		add_child(hitDeath_effect)
		add_child(dead_effect)
		add_child(dust)
		
		if onDeath_spawnObject:
			call_deferred("spawnObjects")
		if toggle_toggleBlocks_onDeath:
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")
		if onDeath_disappear_instantly:
			await get_tree().create_timer(1, false).timeout
			queue_free()


func spawnObjects():
	var x = onDeath_spawnObject_objectAmount
	while x > 0:
		x -= 1
		
		var onDeath_spawnObject_object = onDeath_spawnObject_objectPath.instantiate()
		onDeath_spawnObject_object.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
		world.add_child(onDeath_spawnObject_object)
		
		if onDeath_spawnObject_object.get_class() == "CharacterBody2D" and onDeath_spawnObject_throwAround:
			onDeath_spawnObject_object.velocity.x = rng.randf_range(400.0, -400.0)
			onDeath_spawnObject_object.velocity.y = min(-abs(onDeath_spawnObject_object.velocity.x) * 1.2, 100)

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
	if can_turn and not scanForLedge.get_collider() and is_on_floor():
		can_turn = false
		%Limit_turn.start()
		
		if direction == 1:
			direction = -1
			scanForLedge.position.x = -32
			
		else:
			direction = 1
			scanForLedge.position.x = 32
		
		if slowDown_onDirectionChange:
			velocity.x = -(0.5 * velocity_last_X)
		else:
			velocity.x = -velocity_last_X


#TURN ON WALL
func handle_turnOnWall():
	if is_on_wall() and can_turn:
		can_turn = false
		%Limit_turn.start()
		
		if direction == 1:
			direction = -1
			
			if turnOnLedge:
				scanForLedge.position.x = -32
			
		else:
			direction = 1
			
			if turnOnLedge:
				scanForLedge.position.x = 32
		
		if slowDown_onDirectionChange:
			velocity.x = -(0.5 * velocity_last_X)
		else:
			velocity.x = -velocity_last_X


func _on_limit_turn_timeout():
	can_turn = true
	if debug:
		print("CAN TURN AGAIN")
#!TURN ON WALL



#OTHER BEHAVIOUR
func handle_patroling():
	handle_patrolDirection()


var start_pos_can_turn_X = true
var start_pos_can_turn_Y = true

func handle_whenAt_startPosition_X_stop(delta):
	if abs(global_position.x - start_pos_x) <= start_pos_leniency_X:
		#if debug:
			#scale = Vector2(1.5, 1.5)
		if not spottedPlayer:
			start_pos_can_turn_X = false
			velocity.x = move_toward(velocity.x, 0, delta * ACCELERATION_MULTIPLIER * 1000)
	else:
		start_pos_can_turn_X = true
		#if debug:
			#scale = Vector2(1, 1)


func handle_whenAt_startPosition_Y_stop(delta):
	if start_pos_y - global_position.y <= start_pos_leniency_Y:
		velocity.y = move_toward(velocity.y, 0, delta * ACCELERATION_MULTIPLIER)
		start_pos_can_turn_Y = false


func handle_bouncy_Y(_delta):
	if not dead:
		if on_floor:
			velocity.y = JUMP_VELOCITY
		if on_ceiling:
			velocity.y = -JUMP_VELOCITY
			

func handle_bouncy_X(_delta):
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
#!MOVEMENT TYPES


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


func handle_patrolDirection():
	if not dead and not patrolRectStatic:
		if direction == 1:
			%scanForPlayer_CollisionShape2D.position.x = patrolRect_width / 2
		else:
			%scanForPlayer_CollisionShape2D.position.x = -patrolRect_width / 2


# Spot player logic
var spottedPlayer = false
var followDelay = true

func _on_scan_for_player_area_entered(area):
	if patroling:
		if area.name == "Player_hitbox_main" and not dead:
			spottedPlayer = true
			print("Player entered sight.")
			await get_tree().create_timer(0.1, false).timeout
			%followDelay.start()
			%patrolDirectionTimer.stop()


func _on_scan_for_player_area_exited(area):
	if patroling:
		if area.name == "Player_hitbox_main" and not dead:
			spottedPlayer = false
			await get_tree().create_timer(0.1, false).timeout
			%followDelay.stop()
			followDelay = true
			%patrolDirectionTimer.start()


func _on_follow_delay_timeout():
	followDelay = false


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
			world.add_child(dropProjectile)
			
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
			
			
			world.add_child(shootProjectile)
			
			$shootProjectile.play()
			
			attacking = true
			attacking_timer.start()


var shoot_delay = false
var drop_delay = false

func _on_shoot_delay_timeout():
	shoot_delay = false

func _on_drop_delay_timeout():
	drop_delay = false


var stuck = false

func stuck_inside_wall_check():
	if velocity.y > 2000:
		if not stuck:
			if not get_node_or_null("%scanForLedge"):
				return
			stuck = true
		
	if stuck:
		if scanForLedge.get_collider():
			velocity.y = 0
			position -= Vector2(1, 8)
		else:
			stuck = false


#GENERAL TIMERS
func handle_generalTimerTimeout(generalTimer):
	#If the timer ID that goes off, matches with any timer action's ID, then the action is executed.
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
	
	if t_afterDelay_idleSound:
		if t_afterDelay_idleSound_timerID == generalTimer:
			t_idleSound()
	
	if t_afterDelay_randomize_speedAndJumpVelocity:
		if t_afterDelay_randomize_speedAndJumpVelocity_timerID == generalTimer:
			t_randomize_speedAndJumpVelocity()
	
	if t_spawn_collectibles:
		if t_afterDelay_spawn_collectibles_timerID == generalTimer:
			t_spawn_collectibles()
	
	
	#Randomize cooldowns
	if generalTimer == 1:
		if generalTimer1_randomize_cooldown:
			$timerGeneral1.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
	
	elif generalTimer == 2:
		if generalTimer2_randomize_cooldown:
			$timerGeneral2.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)

	elif generalTimer == 3:
		if generalTimer3_randomize_cooldown:
			$timerGeneral3.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
	
	elif generalTimer == 4:
		if generalTimer4_randomize_cooldown:
			$timerGeneral4.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)

	elif generalTimer == 5:
		if generalTimer5_randomize_cooldown:
			$timerGeneral5.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
	
	elif generalTimer == 6:
		if generalTimer6_randomize_cooldown:
			$timerGeneral6.wait_time = rng.randf_range(generalTimer_min_cooldown, generalTimer_max_cooldown)
	
	generalTimers_correct_cooldowns()
	
	#Restart timers
	if generalTimer == 1:
		$timerGeneral1.start()
	elif generalTimer == 2:
		$timerGeneral2.start()
	elif generalTimer == 3:
		$timerGeneral3.start()
	elif generalTimer == 4:
		$timerGeneral4.start()
	elif generalTimer == 5:
		$timerGeneral5.start()
	elif generalTimer == 6:
		$timerGeneral6.start()


func _on_timer_general_1_timeout():
	handle_generalTimerTimeout(1)

func _on_timer_general_2_timeout():
	handle_generalTimerTimeout(2)

func _on_timer_general_3_timeout():
	handle_generalTimerTimeout(3)

func _on_timer_general_4_timeout():
	handle_generalTimerTimeout(4)

func _on_timer_general_5_timeout():
	handle_generalTimerTimeout(5)

func _on_timer_general_6_timeout():
	handle_generalTimerTimeout(6)



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
	world.add_child(effect_dust)
	
	var orbParticle = orbParticleScene.instantiate()
	orbParticle.global_position = global_position
	world.add_child(orbParticle)
	
	queue_free()

func t_idleSound():
	$idle.play()

func t_randomize_speedAndJumpVelocity():
	SPEED = rng.randf_range(50, 400)
	JUMP_VELOCITY = rng.randf_range(-150, -600)

func t_spawn_collectibles():
	var x = t_item_amount
	while x > 0:
		x -= 1
		
		t_spawn_item()
	
	#var hit_effect = hit_effectScene.instantiate()
	#add_child(hit_effect)

func t_spawn_item():
	var item = t_item_scene.instantiate()
	
	if t_throw_around:
		if item.get("velocity") == null:
			return
		item.velocity.x = rng.randf_range(400.0, -400.0)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	if t_spread_position:
		item.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
	else:
		item.position = position
	
	world.add_child(item)


#GENERAL TIMERS END

func spawn_particles():
	if particles_star:
		add_child(starParticleScene.instantiate())
	if particles_golden:
		add_child(orbParticleScene.instantiate())
	if particles_splash:
		add_child(splashParticleScene.instantiate())


func bonusBox_spawn_collectibles():
	var x = bonusBox_collectibleAmount
	while x > 0:
		x -= 1
		
		bonusBox_spawn_item()
		
	#var hit_effect = hit_effectScene.instantiate()
	#add_child(hit_effect)


func bonusBox_spawn_item():
	var item = bonusBox_item_scene.instantiate()
	
	if bonusBox_throw_around:
		if item.get("velocity") == null:
			return
		item.velocity.x = rng.randf_range(400.0, -400.0)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	if bonusBox_spread_position:
		item.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
	else:
		item.position = position
	
	world.add_child(item)


func generalTimers_correct_cooldowns():
	if not generalTimer1_randomize_cooldown:
		$timerGeneral1.wait_time = generalTimer1_cooldown
	if not generalTimer2_randomize_cooldown:
		$timerGeneral2.wait_time = generalTimer2_cooldown
	if not generalTimer3_randomize_cooldown:
		$timerGeneral3.wait_time = generalTimer3_cooldown
	if not generalTimer4_randomize_cooldown:
		$timerGeneral4.wait_time = generalTimer4_cooldown
	if not generalTimer5_randomize_cooldown:
		$timerGeneral5.wait_time = generalTimer5_cooldown
	if not generalTimer6_randomize_cooldown:
		$timerGeneral6.wait_time = generalTimer6_cooldown


func applyRandom_fromList(list_name, list_length):
	var list = get(str(list_name))
	var randomized_ID = randi_range(0, list_length)
	var randomized_property = list[randomized_ID]
	
	return randomized_property


func applyRandom_falseTrue(false_probability, true_probability):
	var randomized_number = randi_range(-false_probability, true_probability)
	if randomized_number <= 0:
		var randomized_bool = false
		return randomized_bool
	else:
		var randomized_bool = true
		return randomized_bool


@onready var list_movementType = ["normal", "followPlayerX", "stationary", "wave_H", "wave_V", "moveAround_startPosition_XY_when_notSpotted", "moveAround_startPosition_X_when_notSpotted", "moveAround_startPosition_Y_when_notSpotted", "followPlayerY", "followPlayerXY", "chasePlayerXY_lookAtPlayer", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerXY_lookAtPlayer_whenSpotted"]
@onready var list_itemToSpawn = [load("res://Collectibles/collectibleOrange.tscn"), load("res://Collectibles/collectibleGrape.tscn"), load("res://Boxes/box_oranges.tscn"), load("res://Boxes/box_grapes.tscn"), load("res://Enemies/enemy_frogBlue.tscn"), load("res://Enemies/enemy_frogBlue.tscn"), load("res://Enemies/enemy_frog.tscn"), load("res://Collectibles/collectibleRotApple.tscn"), load("res://Boxes/box_rotApples.tscn"), load("res://Collectibles/collectibleWeapon_fire.tscn"), load("res://Collectibles/collectibleCarrot.tscn"), load("res://Collectibles/collectibleCheese.tscn"), load("res://Collectibles/collectiblePeach.tscn"), load("res://Collectibles/collectibleJewel_yellow.tscn"), load("res://Collectibles/collectibleSpecialApple_golden.tscn"), load("res://Enemies/enemy_chaos.tscn")]
@onready var list_projectileToSpawn = [load("res://Projectiles/player_projectile_basic.tscn"), load("res://Projectiles/player_projectile_destructive_fast_speed.tscn"), load("res://Projectiles/player_projectile_fire.tscn"), load("res://Projectiles/player_projectile_ice.tscn"), load("res://Projectiles/player_projectile_short_shotDelay.tscn"), load("res://Projectiles/player_projectile_veryFast_speed.tscn"), load("res://Projectiles/projectile_bullet.tscn"), load("res://Projectiles/projectile_fireball.tscn")]
@onready var list_secondaryProjectileToSpawn = [load("res://Projectiles/player_secondaryProjectile_basic.tscn"), load("res://Projectiles/player_secondaryProjectile_fast.tscn"), load("res://Projectiles/player_secondaryProjectile_bouncingBall.tscn")]

func randomize_everything():
	SPEED = randi_range(0, 1200)
	JUMP_VELOCITY = randi_range(0, -1200)
	ACCELERATION_MULTIPLIER = randi_range(0, 12)
	movementType = applyRandom_fromList("list_movementType", 10) #14 for every type
	give_score_onDeath = applyRandom_falseTrue(1, 9)
	scoreValue = randi_range(0, 100000)
	turnOnLedge = applyRandom_falseTrue(1, 4)
	turnOnWall = applyRandom_falseTrue(1, 12)
	floating = applyRandom_falseTrue(6, 1)
	patroling = applyRandom_falseTrue(1,9)
	afterDelay_changeDirection = applyRandom_falseTrue(3, 1)
	afterDelay_jump = applyRandom_falseTrue(3, 1)
	directionTimer_time = randf_range(0.5, 12)
	jumpTimer_time = randf_range(0.5, 12)
	onDeath_spawnObject = applyRandom_falseTrue(1, 6)
	onDeath_spawnObject_objectPath = applyRandom_fromList("list_itemToSpawn", 15)
	onDeath_spawnObject_objectAmount = randi_range(1, 8)
	onDeath_spawnObject_throwAround = applyRandom_falseTrue(1, 3)
	immortal = applyRandom_falseTrue(9, 1)
	shootProjectile_whenSpotted = applyRandom_falseTrue(1, 4)
	dropProjectile_whenSpotted = applyRandom_falseTrue(1, 4)
	shootProjectile_cooldown = randf_range(0.5, 6)
	dropProjectile_cooldown = randf_range(0.5, 6)
	scene_shootProjectile = applyRandom_fromList("list_projectileToSpawn", 7)
	scene_dropProjectile = applyRandom_fromList("list_secondaryProjectileToSpawn", 2)
	altDropMethod = applyRandom_falseTrue(1, 2)
	projectile_isBouncingBall = applyRandom_falseTrue(1, 2)
	shootProjectile_offset_X = randi_range(-120, 120)
	shootProjectile_offset_Y = randi_range(-120, 120)
	shootProjectile_player = applyRandom_falseTrue(3, 1)
	shootProjectile_enemy = applyRandom_falseTrue(1, 6)
	toggle_toggleBlocks_onDeath = applyRandom_falseTrue(1, 3)
	whenAt_startPosition_X_stop = applyRandom_falseTrue(1, 4)
	whenAt_startPosition_Y_stop = applyRandom_falseTrue(1, 4)
	start_pos_leniency_X = randi_range(4, 64)
	start_pos_leniency_Y = randi_range(4, 64)
	onSpawn_offset_position = Vector2(randi_range(-64, 64), randi_range(-64, 64))
	bouncy_Y = applyRandom_falseTrue(4, 1)
	bouncy_X = applyRandom_falseTrue(1, 1)
	ascending = applyRandom_falseTrue(1, 3)
	damageTo_player = applyRandom_falseTrue(1, 7)
	damageTo_enemies = applyRandom_falseTrue(1, 1)
	stationary_disable_jump_anim = applyRandom_falseTrue(6, 1)
	patrolRectStatic = applyRandom_falseTrue(9, 1)
	force_static_H = applyRandom_falseTrue(12, 1)
	force_static_V = applyRandom_falseTrue(12, 1)
	onDeath_disappear_instantly = applyRandom_falseTrue(6, 1)
	is_bonusBox = applyRandom_falseTrue(1, 9)
	bonusBox_spawn_item_onDeath = applyRandom_falseTrue(1, 4)
	bonusBox_item_scene = applyRandom_fromList("list_itemToSpawn", 15)
	bonusBox_collectibleAmount = randi_range(1, 8)
	bonusBox_throw_around = applyRandom_falseTrue(1, 3)
	bonusBox_spread_position = applyRandom_falseTrue(1, 3)
	bonusBox_requiresVelocity = applyRandom_falseTrue(1, 1)
	bonusBox_minimalVelocity = randi_range(50, 300)
	particles_star = applyRandom_falseTrue(1, 2)
	particles_golden = applyRandom_falseTrue(1, 2)
	particles_splash = applyRandom_falseTrue(1, 2)
	enable_generalTimers = applyRandom_falseTrue(1, 6)
	generalTimer1_cooldown = randf_range(0.5, 12)
	generalTimer2_cooldown = randf_range(0.5, 12)
	generalTimer3_cooldown = randf_range(0.5, 12)
	generalTimer1_randomize_cooldown = applyRandom_falseTrue(1, 2)
	generalTimer2_randomize_cooldown = applyRandom_falseTrue(1, 2)
	generalTimer3_randomize_cooldown = applyRandom_falseTrue(1, 2)
	generalTimer_min_cooldown = randf_range(0.5, 4)
	generalTimer_max_cooldown = randf_range(4, 12)
	t_item_scene = applyRandom_fromList("list_itemToSpawn", 14)
	t_item_amount = randi_range(1, 8)
	t_throw_around = applyRandom_falseTrue(1, 1)
	t_spread_position = applyRandom_falseTrue(1, 1)
	t_afterDelay_jump = applyRandom_falseTrue(1, 1)
	t_afterDelay_jump_timerID = randi_range(0, 3)
	t_afterDelay_jumpAndMove = applyRandom_falseTrue(1, 1)
	t_afterDelay_jumpAndMove_timerID = randi_range(0, 3)
	t_afterDelay_changeDirection = applyRandom_falseTrue(1, 1)
	t_afterDelay_changeDirection_timerID = randi_range(0, 3)
	t_afterDelay_spawnObject = applyRandom_falseTrue(1, 1)
	t_afterDelay_spawnObject_timerID = randi_range(0, 3)
	t_afterDelay_selfDestruct = applyRandom_falseTrue(1, 1)
	t_afterDelay_selfDestruct_timerID = randi_range(0, 3)
	t_afterDelay_selfDestructAndSpawnObject = applyRandom_falseTrue(1, 1)
	t_afterDelay_selfDestructAndSpawnObject_timerID = randi_range(0, 3)
	t_afterDelay_idleSound = applyRandom_falseTrue(1, 1)
	t_afterDelay_idleSound_timerID = randi_range(0, 3)
	t_afterDelay_randomize_speedAndJumpVelocity = applyRandom_falseTrue(1, 1)
	t_afterDelay_randomize_speedAndJumpVelocity_timerID = randi_range(0, 3)
	t_afterDelay_spawn_collectibles = applyRandom_falseTrue(1, 1)
	t_afterDelay_spawn_collectibles_timerID = randi_range(0, 3)
	
	modulate.r = randf_range(0, 1)
	modulate.g = randf_range(0, 1)
	modulate.b = randf_range(0, 1)
	modulate.a = randf_range(0.5, 1)
