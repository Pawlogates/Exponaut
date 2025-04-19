extends CharacterBody2D

@export var SPEED = 400.0
@export var JUMP_VELOCITY = -500.0
@export var ACCELERATION = 1200.0
@export var FRICTION = 1200.0
@export var GRAVITY_SCALE = 1.0
@export var AIR_SLOWDOWN = -400.0
@export var AIR_ACCELERATION = 1400.0

@export var can_jump = true
@export var can_air_jump = true
@export var can_wall_jump = true
@export var can_crouch = true
@export var can_crouch_walk = true
@export var can_dash = true

@export var flight = false

var normal_jump = false
var air_jump = false
var on_wall_normal = Vector2.ZERO

var starParticleScene = preload("res://Particles/particles_star.tscn")
var effect_dustScene = preload("res://Particles/effect_dust.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var start_pos = global_position

var base_SPEED = SPEED
var base_JUMP_VELOCITY = JUMP_VELOCITY
var base_ACCELERATION = ACCELERATION
var base_FRICTION = FRICTION
var base_GRAVITY_SCALE = GRAVITY_SCALE

@onready var world = $/root/World

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

@onready var player_collision = $CollisionShape2D
@onready var player_hitbox = $Player_hitbox_main/CollisionShape2D

@onready var timer_attack_cooldown: Timer = %attack_cooldown
@onready var timer_secondary_attack_cooldown: Timer = %secondaryAttack_cooldown

@onready var jump_leniency = $jump_leniency
@onready var wall_jump_leniency = $wallJump_leniency
@onready var powerup_timer = $powerup_timer
@onready var dash_timer = $dash_timer
@onready var shoot_anim_delay = $AnimatedSprite2D/shootAnimDelay
@onready var crouch_walk_anim_delay = $AnimatedSprite2D/crouch_walkAnimDelay
@onready var crouch_walk_collision_switch = $AnimatedSprite2D/crouch_walkCollisionSwitch
@onready var player_hitbox_tile_detection = $Player_hitbox_tileDetection
@onready var jump_build_velocity = $jumpBuildVelocity
@onready var dash_speed_block = $dash_timer/dash_speedBlock
@onready var dash_end_slowdown_delay = $dash_timer/dash_endSlowdown_delay
@onready var dash_end_slowdown_active = $dash_timer/dash_endSlowdown_active
@onready var timer_block_movement_full: Timer = $block_movement_full

@onready var sfx_damage = $damage
@onready var sfx_death = $death
@onready var sfx_jump = $jump
@onready var sfx_air_jump = $air_jump
@onready var sfx_wall_jump = $wall_jump

@onready var animation_player = $AnimationPlayer
@onready var animation_player2 = $AnimationPlayer2

var crouch_walking = false
var crouching = false
var crouchTimer = false
var crouchMultiplier = 1

#if can_stand_up is equal to 0, there is nothing blocking the player
var can_stand_up = 0

var dash_end_slowdown = false

var rng = RandomNumberGenerator.new()
var pitch_scale = 1.0

var jumpBuildVelocity_active = false

var dead = false

var direction = 1
var shooting = false

var debugMovement = false

var spawn_dust_effect = true

var block_movement = false
var block_movement_full = false

var damageValue = 1

var double_score = false

var lethalBall_released = false

#ACTIVATES WHEN PLAYER LANDS ON THE GROUND
signal player_just_landed

func _ready():
	base_SPEED = SPEED
	base_JUMP_VELOCITY = JUMP_VELOCITY
	base_ACCELERATION = ACCELERATION
	base_FRICTION = FRICTION
	base_GRAVITY_SCALE = GRAVITY_SCALE
	
	world.reassign_player()
	
	Globals.player_pos = get_global_position()
	Globals.player_posX = get_global_position()[0]
	Globals.player_posY = get_global_position()[1]
	
	Globals.saveState_loaded.connect(saveState_loaded)
	
	Globals.playerHit1.connect(reduceHp1)
	Globals.playerHit2.connect(reduceHp2)
	Globals.playerHit3.connect(reduceHp3)
	
	Globals.shot_charged.connect(charged_effect)
	Globals.shot.connect(cancel_effect)
	
	Globals.saved_player_posX = position.x
	Globals.saved_player_posY = position.y
	
	player_just_landed.connect(on_player_landed)
	
	Globals.powerup_activated.connect(on_powerup_activated)
	Globals.max_score_multiplier_reached.connect(on_max_score_multiplier_reached)
	Globals.comboReset.connect(on_comboReset)
	
	
	if world.cameraLimit_left != 0.0 or world.cameraLimit_right != 0.0 or world.cameraLimit_top != 0.0 or world.cameraLimit_bottom != 0.0:
		%Camera2D.limit_left = world.cameraLimit_left
		%Camera2D.limit_right = world.cameraLimit_right
		%Camera2D.limit_bottom = world.cameraLimit_bottom
		%Camera2D.limit_top = world.cameraLimit_top
	
	
	#total collectibles
	await get_tree().create_timer(0.5, false).timeout
	Globals.collectibles_in_this_level = get_tree().get_nodes_in_group("Collectibles").size() + (get_tree().get_nodes_in_group("bonusBox").size() * 10)
	
	
	if Globals.mode_scoreAttack:
		weaponType = "basic"


func _process(delta):
	handle_actions()
	
	get_basic_player_values()
	
	if debugMovement:
		handle_debugMovement(delta)
	
	else:
		apply_gravity(delta)
		
		if can_jump:
			if not handle_jump(delta):
				if can_wall_jump:
					handle_wall_jump()
			
		handle_acceleration_direction(delta)
		handle_air_acceleration(delta)
	
	#SHOOTING LOGIC
	handle_shooting()
	
	if not debugMovement:
		#DASHING LOGIC
		if can_dash:
			handle_dash()
		
		#CROUCHING LOGIC
		if can_crouch:
			handle_crouching()
	
	
	if not debugMovement:
		if not stuck:
			if flight:
				handle_flight(delta)
			
			handle_inside_zone()
			
			if not block_movement_full:
				move_and_slide() #MAIN MOVEMENT
			
		apply_friction(delta)
		apply_air_slowdown(delta)
		
		update_anim()
	
	if not attacked and not dead and velocity.y == 0 and is_on_floor() and not on_floor and not shooting and not crouch_walking and not crouching:
		sprite.play("idle")
	
	handle_spawn_dust()
	handle_zoom(delta)
	handle_toggle_debugMovement()
	handle_manual_player_death()
	
	#HANDLE STUCK IN WALL
	handle_stuck()
	
	#DEBUG SCREEN
	handle_debug_screen()
	
	handle_gameMode_scoreAttack()
	
	handle_just_landed()

#MAIN END


var zoomValue = 1

var is_dashing = false
var started_dash = false
var speedBlockActive = false
var dash_slowdown = false
var wall_jump = false

var true_just_landed_queued = true
var true_just_landed = false

func apply_gravity(delta):
	if not is_on_floor() and not is_dashing or dash_slowdown:
		if not flight:
			if Input.is_action_pressed("jump"):
				if inside_water:
					velocity.y += gravity * 1.0 * delta * GRAVITY_SCALE * insideWater_multiplier
				else:
					velocity.y += gravity * 1.0 * delta * GRAVITY_SCALE
			
			elif Input.is_action_pressed("move_DOWN"):
				if inside_water:
					velocity.y += gravity * 2.0 * delta * GRAVITY_SCALE * insideWater_multiplier
				else:
					velocity.y += gravity * 4.0 * delta * GRAVITY_SCALE
			
			else:
				if inside_water:
					velocity.y += gravity * 1.5 * delta * GRAVITY_SCALE * insideWater_multiplier
				else:
					velocity.y += gravity * 1.5 * delta * GRAVITY_SCALE
			
	
	if not dead and is_dashing:
		if not speedBlockActive or dash_slowdown:
			dash_speed_block.start()
		
		speedBlockActive = true
		sprite.play("crouch")
		
		if started_dash == false or dash_slowdown:
			velocity.x = 0
		
		else:
			if Input.is_action_pressed("move_DOWN"):
				velocity.y += gravity * delta * 4 * GRAVITY_SCALE
				velocity.x = move_toward(velocity.x, 1000 * direction, 6000 * delta)
			else:
				velocity.y += gravity * delta * 2 * GRAVITY_SCALE
				velocity.x = move_toward(velocity.x, 1000 * direction, 6000 * delta)
	
	else:
		started_dash = false
	
	if dash_end_slowdown and not dash_end_slowdown_canceled:
		velocity.x = move_toward(velocity.x, 0, 7000 * delta)
	
	#HANDLE JUST LANDED
	if true_just_landed_queued and is_on_floor():
		true_just_landed_queued = false
		true_just_landed = true

var count = 0
var just_landed = false
var just_landed_queued = false
var dash_end_slowdown_await_jump = false
var justLanded_delay_started = false

func handle_jump(delta):
	if dead:
		return
		
	if is_on_floor():
		normal_jump = true
		air_jump = true
		wall_jump = true
		
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
		velocity.x = base_SPEED * 4.5 * direction
	
	
	#NORMAL JUMP
	if on_floor or normal_jump and jump_leniency.time_left > 0.0:
		
		if Input.is_action_just_pressed("jump"):
			normal_jump = false
			jump_build_velocity.start()
			
			sfx_jump.play()
			
			var x = randi_range(0, 1)
			if not is_dashing and x or not is_dashing and not direction:
				%AnimationPlayer.stop()
				%AnimationPlayer.speed_scale = 2
				%AnimationPlayer.play("jumped")
			else:
				%AnimationPlayer.stop()
				%AnimationPlayer.speed_scale = 1.5
				if direction == 1:
					%AnimationPlayer.play("rotate_right")
				if direction == -1:
					%AnimationPlayer.play("rotate_left")
			
			jumpBuildVelocity_active = true
			return true
	
	if jumpBuildVelocity_active and Input.is_action_pressed("jump"):
		if inside_water:
			velocity.y = move_toward(velocity.y, JUMP_VELOCITY, 8500 * insideWater_multiplier * delta)
		else:
			velocity.y = move_toward(velocity.y, JUMP_VELOCITY, 8500 * delta)
		
	elif not on_floor and not on_wall and not wall_jump_leniency.time_left > 0.0 or not on_floor and on_wall and not wall_jump and wall_jump_leniency.time_left > 0.0:
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
		if can_air_jump and Input.is_action_just_pressed("jump") and air_jump and not Input.is_action_pressed("move_DOWN"):
			if inside_water:
				velocity.y = JUMP_VELOCITY * 0.8 * insideWater_multiplier
			else:
				velocity.y = JUMP_VELOCITY * 0.8
				
			air_jump = false
			
			sfx_air_jump.play()
			
			var x = randi_range(0, 1)
			if x or not direction:
				%AnimationPlayer.stop()
				%AnimationPlayer.speed_scale = 3
				%AnimationPlayer.play("air_jumped")
			else:
				%AnimationPlayer.stop()
				%AnimationPlayer.speed_scale = 1
				if direction == 1:
					%AnimationPlayer.play("rotate_right")
				if direction == -1:
					%AnimationPlayer.play("rotate_left")
			
			dash_end_slowdown_canceled = true
			if dash_end_slowdown_await_jump:
				velocity.x += 300 * direction
			
			return true
	
	return false


func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_leniency.time_left <= 0.0: return
	
	if Input.is_action_just_pressed("jump") and wall_jump:
		velocity.x = on_wall_normal.x * SPEED
		if inside_water:
			velocity.y = JUMP_VELOCITY * 1 * insideWater_multiplier
		else:
			velocity.y = JUMP_VELOCITY * 1
		
		wall_jump = false
		
		sfx_wall_jump.play()
		
		var x = randi_range(0, 1)
		if x or not direction:
			%AnimationPlayer.stop()
			%AnimationPlayer.speed_scale = 3
			%AnimationPlayer.play("air_jumped")
		else:
			%AnimationPlayer.stop()
			%AnimationPlayer.speed_scale = 1
			if direction == -1:
				%AnimationPlayer.play("rotate_right")
			if direction == 1:
				%AnimationPlayer.play("rotate_left")


func apply_friction(delta):
	if direction == 0 and not inside_wind and not just_bounced:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


func handle_acceleration_direction(delta):
	
	if not is_on_floor() or just_bounced: return
	
	# HANDLE WALKING
	if direction != 0:
		# Unlimited velocity buildup due to wind (conveyor belts).
		if inside_wind and insideWind_direction_X == Globals.direction:
			velocity.x = move_toward(velocity.x, direction * 10000, ACCELERATION * delta * crouchMultiplier * insideWater_multiplier)
		# Normal
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta * crouchMultiplier * insideWater_multiplier)
	
	if just_bounced:
		return
	
	if Input.is_action_just_pressed("move_L") or Input.is_action_just_pressed("move_R"):
		velocity.x *= 0.75


func handle_air_acceleration(delta):
	if is_on_floor() or just_bounced: return
	
	if direction != 0:
		# Reduce slowdown while under influence of heavy wind (conveyor belts).
		if just_left_wind:
			velocity.x = move_toward(velocity.x, SPEED * 2 * direction, AIR_ACCELERATION / 3 * delta)
		# Normal
		else:
			velocity.x = move_toward(velocity.x, SPEED * direction, AIR_ACCELERATION * delta)
	
	if just_bounced:
		return
	
	if Input.is_action_just_pressed("move_L") or Input.is_action_just_pressed("move_R"):
		velocity.x *= 0.75


var attacked = false
var deathAnim_playing = false

func update_anim():
	if direction != 0 and not dead:
		sprite.flip_h = (direction < 0)
	
	if not flight:
		if not is_on_floor():
			$idle_timer.stop()
	
	if dead and not deathAnim_playing:
		deathAnim_playing = true
		sprite.play("death")
		return
	
	if dead:
		return
	
	if attacked:
		sprite.play("damage")
		return
	
	if flight:
		sprite.play("flight")
		return
	
	if is_on_floor() and not flight:
		
		idle_after_delay()
		
		if not attacked and not dead and not is_dashing and direction != 0 and not shooting and not crouch_walking and not crouching:
			sprite.play("walk")
			sprite.flip_h = (direction < 0)
			$idle_timer.stop()
	
	if not flight and not attacked and not dead and not is_dashing and not is_on_floor() and not shooting and not crouch_walking and not crouching:
		sprite.play("jump")


func idle_after_delay():
	if $idle_timer.is_stopped():
		$idle_timer.start()


func _on_idle_timer_timeout():
	if not attacked and not dead and not is_dashing and not shooting and not crouch_walking and not crouching:
		sprite.play("idle")


func apply_air_slowdown(delta):
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, AIR_SLOWDOWN * delta)


var dashReady = true
signal dash_safe

func _on_dash_timer_timeout():
	is_dashing = false
	
	if can_stand_up == 0:
		player_collision.shape.extents = Vector2(20, 56)
		player_collision.position = Vector2(0, 0)
		
		player_hitbox.shape.extents = Vector2(16, 40)
		player_hitbox.position = Vector2(0, 0)
		
		dashReady = true
	
	else:
		await dash_safe
		player_collision.shape.extents = Vector2(20, 56)
		player_collision.position = Vector2(0, 0)
		
		player_hitbox.shape.extents = Vector2(16, 40)
		player_hitbox.position = Vector2(0, 0)
		
		dashReady = true
	
	raycast_top.enabled = true


#PLAYER DAMAGE EFFECTS
func reduceHp1():
	if not dead:
		sfx_damage.play()
		attacked = true
		$attackedTimer.start()

func reduceHp2():
	if not dead:
		sfx_damage.play()
		attacked = true
		$attackedTimer.start()

func reduceHp3():
	if not dead:
		sfx_damage.play()
		attacked = true
		$attackedTimer.start()


func charged_effect():
	animation_player2.play("shot_charged")
	
	var starParticle = starParticleScene.instantiate()
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	add_child(starParticle)

func cancel_effect():
	animation_player2.stop()
	animation_player2.play("RESET")


func _on_shoot_anim_delay_timeout():
	shooting = false


func _on_crouch_walk_anim_delay_timeout():
	if can_crouch_walk:
		crouch_walking = true
		crouchTimer = false

func _on_crouch_walk_collision_switch_timeout():
	player_collision.shape.extents = Vector2(20, 20)
	player_collision.position += Vector2(0, 36)
	player_hitbox.shape.extents = Vector2(20, 20)
	player_hitbox.position += Vector2(0, 28)


func _on_jump_build_velocity_timeout():
	jumpBuildVelocity_active = false


#CHECK IF INSIDE TILES
func _on_player_hitbox_tile_detection_body_entered(_body):
	can_stand_up += 1

func _on_player_hitbox_tile_detection_body_exited(_body):
	can_stand_up -= 1


var dash_end_slowdown_canceled = false

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
	animation_player2.play("streak_reset")


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
	
	player_hitbox.shape.extents = Vector2(16, 40)
	player_hitbox.position = Vector2(0, 0)
	
	deathAnim_playing = false
	
	
	LevelTransition.fade_from_black_slow()


func _on_dust_effect_timeout():
	spawn_dust_effect = true




#ATTACK COOLDOWN
func _on_attack_cooldown_timeout():
	attack_cooldown = false
	if Globals.direction != 0:
		$AnimatedSprite2D.flip_h = (Globals.direction < 0)

func _on_secondary_attack_cooldown_timeout():
	secondaryAttack_cooldown = false
	if Globals.direction != 0:
		$AnimatedSprite2D.flip_h = (Globals.direction < 0)


func _on_just_landed_delay_timeout():
	justLanded_delay_started = false
	just_landed_queued = true


func _on_await_jump_timer_timeout():
	dash_end_slowdown_await_jump = false


#TRANSFORMATIONS
var player_bird_scene = load("res://Other/Scenes/player_bird.tscn")
var player_chicken_scene = load("res://Other/Scenes/player_chicken.tscn")
var player_rooster_scene = load("res://Other/Scenes/player.tscn")

func transformInto_rooster():
	call_deferred("deferred_spawnRooster")
	call_deferred("delete")

func transformInto_bird():
	call_deferred("deferred_spawnBird")
	call_deferred("delete")

func transformInto_chicken():
	call_deferred("deferred_spawnChicken")
	call_deferred("delete")


func deferred_spawnRooster():
	remove_from_group("player")
	remove_from_group("player_root")
	camera.remove_from_group("player_camera")
	var player_rooster = player_rooster_scene.instantiate()
	player_rooster.position = position
	world.add_child(player_rooster)

func deferred_spawnBird():
	remove_from_group("player")
	remove_from_group("player_root")
	camera.remove_from_group("player_camera")
	var player_bird = player_bird_scene.instantiate()
	player_bird.position = position
	world.add_child(player_bird)

func deferred_spawnChicken():
	remove_from_group("player")
	remove_from_group("player_root")
	camera.remove_from_group("player_camera")
	var player_chicken = player_chicken_scene.instantiate()
	player_chicken.position = position
	world.add_child(player_chicken)


func delete():
	queue_free()


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


func _on_attacked_timer_timeout():
	attacked = false


func _on_dash_check_timeout():
	if can_stand_up == 0:
		dash_safe.emit()


func shoot_projectile(projectile_scene):
	if weaponType == "basic" and Globals.collected_in_cycle >= 20:
		if not dead and Input.is_action_just_pressed("attack_main"):
			var projectile_phaser = scene_projectile_phaser.instantiate()
			projectile_phaser.playerProjectile = true
			projectile_phaser.enemyProjectile = false
			add_child(projectile_phaser)
			
			#SHOOTING ANIMATION
			shooting = true
			shoot_anim_delay.start()
			sprite.play("shoot")
			if direction != 0:
				sprite.flip_h = (direction < 0)
		
		return
	
	if not attack_cooldown:
		attack_cooldown = true
		$attack_cooldown.start()
		
		shooting = true
		shoot_anim_delay.start()
		sprite.play("shoot")
		
		var projectile = projectile_scene.instantiate()
		projectile.playerProjectile = true
		projectile.enemyProjectile = false
		projectile.position = position + Vector2(Globals.direction * 24, 0)
		get_parent().add_child(projectile)
		
		playSound_shoot()
		
	if direction != 0:
		sprite.flip_h = (direction < 0)


func shoot_secondaryProjectile(secondaryProjectile_scene):
	if not secondaryAttack_cooldown:
		secondaryAttack_cooldown = true
		$secondaryAttack_cooldown.start()
		
		shooting = true
		shoot_anim_delay.start()
		sprite.play("secondaryShoot")
		
		var secondaryProjectile = secondaryProjectile_scene.instantiate()
		secondaryProjectile.position = position + Vector2(Globals.direction * 0, 32)
		secondaryProjectile.direction = direction
		if velocity.y <= -100 or velocity.y == 0:
			secondaryProjectile.velocity = Vector2(velocity.x * 1.2, -100)
		else:
			secondaryProjectile.velocity = Vector2(velocity.x * 1.2, 100)
		get_parent().add_child(secondaryProjectile)
		playSound_shoot()
		
	if direction != 0:
		sprite.flip_h = (direction < 0)


func handle_gameMode_scoreAttack():
	if Globals.mode_scoreAttack:
		if Globals.combo_tier >= 5:
			if weaponType == "basic":
				weaponType = "phaser"
		else:
			if weaponType == "phaser":
				weaponType = "basic"


@onready var raycast_top = $raycast_top
@onready var raycast_bottom = $raycast_bottom
@onready var raycast_middle = $raycast_middle

var stuck = false

func handle_stuck():
	if stuck:
		raycast_top.target_position.x = 16 * Globals.direction
		raycast_bottom.target_position.x = 16 * Globals.direction
		raycast_middle.target_position.x = 16 * Globals.direction
		#raycast_top.enabled = true
		#raycast_bottom.enabled = true
		#raycast_middle.enabled = true
	#else:
		#raycast_top.enabled = false
		#raycast_bottom.enabled = false
		#raycast_middle.enabled = false
	
	if velocity.y > 4000:
		if not stuck:
			stuck = true
	
	if stuck:
		if raycast_top.get_collider() or raycast_bottom.get_collider() or raycast_middle.get_collider():
			position += Vector2(4 * Globals.direction, -4)
			velocity = Vector2(0, 0)
		else:
			stuck = false


var confirm_timer_isActive = false
func _on_stuck_check_timeout():
	if confirm_timer_isActive:
		return
	
	if velocity.y == JUMP_VELOCITY or velocity[1] == 0:
		$stuckCheck/stuckCheck_confirm.start()
		confirm_timer_isActive = true

func _on_stuck_check_confirm_timeout():
	if velocity.y == JUMP_VELOCITY or velocity[1] == 0:
		stuck = true
		print("The stuckCheck_confirm timer just went off while a rare stuck case is possible - [velocity.y = JUMP_VELOCITY] or [velocity = Vector2(0, 0)]. Now the 'stuck' variable becomes true and will be cancelled right after, unless any of the raycasts detect collision.") 
		
		raycast_top.target_position.x = 16
		raycast_bottom.target_position.x = 16
		raycast_middle.target_position.x = 16
	
	else:
		print("The stuckCheck_confirm timer just went off, but it seems like there is no way the player could be stuck.")
	
	confirm_timer_isActive = false



#Debug movement type that lets you freely move in any direction. Press CTRL + C to activate it. (needs Globals.debug_mode to be true)
#Hold RMB to move a lot slower. Hold SHIFT to move very fast.
func handle_debugMovement(delta):
	if Input.is_action_pressed("move_R"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.x += 200 * delta
			return
		
		elif Input.is_action_pressed("dash"):
			global_position.x += 2000 * delta
			return
			
		global_position.x += 1000 * delta
	
	if Input.is_action_pressed("move_L"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.x -= 200 * delta
			return
		
		elif Input.is_action_pressed("dash"):
			global_position.x -= 2000 * delta
			return
			
		global_position.x -= 1000 * delta
	
	if Input.is_action_pressed("move_UP"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.y -= 200 * delta
			return
		
		elif Input.is_action_pressed("dash"):
			global_position.y -= 2000 * delta
			return
			
		global_position.y -= 1000 * delta
	
	if Input.is_action_pressed("move_DOWN"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.y += 200 * delta
			return
			
		elif Input.is_action_pressed("dash"):
			global_position.y += 2000 * delta
			return
			
		global_position.y += 1000 * delta
	
	crouching = false
	crouch_walking = false


func handle_crouching():
	if not dead and is_on_floor():
		if direction != 0:
			sprite.flip_h = (direction < 0)
		if dashReady and Input.is_action_pressed("move_DOWN") and not crouch_walking and not crouchTimer:
			crouch_walk_anim_delay.start()
			crouch_walk_collision_switch.start()
			crouching = true
			crouchTimer = true
			sprite.play("crouch")
			
			crouchMultiplier = 0.6
			if can_crouch_walk:
				SPEED = base_SPEED * crouchMultiplier
			else:
				SPEED = 0
			
			raycast_top.enabled = false
		
		
		if crouch_walking:
			sprite.play("crouch_walk")
			crouching = false
			
			crouchMultiplier = 0.4
			SPEED = base_SPEED * crouchMultiplier
			
			raycast_top.enabled = false
	
	if not Input.is_action_pressed("move_DOWN") and can_stand_up == 0 and crouching or not Input.is_action_pressed("move_DOWN") and can_stand_up == 0 and crouch_walking or not is_on_floor() and can_stand_up == 0 and crouch_walking:
		player_collision.shape.extents = Vector2(20, 56)
		player_collision.position = Vector2(0, 0)
		
		player_hitbox.shape.extents = Vector2(16, 40)
		player_hitbox.position = Vector2(0, 0)
		
		
		crouching = false
		crouch_walking = false
		crouch_walk_anim_delay.stop()
		crouch_walk_collision_switch.stop()
		SPEED = base_SPEED
		crouchMultiplier = 1
		crouchTimer = false
		
		raycast_top.enabled = true

func handle_dash():
	if dashReady and Input.is_action_just_pressed("dash") and is_on_floor() and is_dashing == false and not crouch_walking and not crouching:
		dash_end_slowdown_canceled = false
		is_dashing = true
		dashReady = false
		$dash_timer.start()
		
		player_collision.shape.extents = Vector2(20, 20)
		player_collision.position += Vector2(0, 36)
		
		player_hitbox.shape.extents = Vector2(20, 20)
		player_hitbox.position += Vector2(0, 28)
		
		raycast_top.enabled = false


var attack_cooldown = false
var secondaryAttack_cooldown = false
@export var weaponType = "none"
@export var secondaryWeaponType = "none"

#WEAPON TYPES
var scene_projectile_phaser = load("res://Projectiles/player_projectile_charged_phaser.tscn")
var scene_projectile_basic = load("res://Projectiles/player_projectile_basic.tscn")
var scene_projectile_short_shotDelay = load("res://Projectiles/player_projectile_short_shotDelay.tscn")
var scene_projectile_ice = load("res://Projectiles/player_projectile_ice.tscn")
var scene_projectile_fire = load("res://Projectiles/player_projectile_fire.tscn")
var scene_projectile_destructive_fast_speed = load("res://Projectiles/player_projectile_destructive_fast_speed.tscn")
var scene_projectile_veryFast_speed = load("res://Projectiles/player_projectile_veryFast_speed.tscn")
var scene_projectile_lethalBall_basic = load("res://Projectiles/projectile_lethalBall_base.tscn")
#WEAPON TYPES END

#SECONDARY WEAPON TYPES
var scene_secondaryProjectile_basic = load("res://Projectiles/player_secondaryProjectile_basic.tscn")
var scene_secondaryProjectile_fast = load("res://Projectiles/player_secondaryProjectile_fast.tscn")
#SECONDARY WEAPON TYPES END

func handle_shooting():
	#MAIN ATTACK
	if weaponType == "phaser":
		if not dead and Input.is_action_just_pressed("attack_main"):
			var projectile_phaser = scene_projectile_phaser.instantiate()
			add_child(projectile_phaser)
			
			#SHOOTING ANIMATION
			shooting = true
			shoot_anim_delay.start()
			sprite.play("shoot")
			if direction != 0:
				sprite.flip_h = (direction < 0)
			
			return
	
	if not dead and Input.is_action_pressed("attack_main"):
		
		if weaponType == "basic":
			shoot_projectile(scene_projectile_basic)
		elif weaponType == "short_shotDelay":
			shoot_projectile(scene_projectile_short_shotDelay)
		elif weaponType == "ice":
			shoot_projectile(scene_projectile_ice)
		elif weaponType == "fire":
			shoot_projectile(scene_projectile_fire)
		elif weaponType == "destructive_fast_speed":
			shoot_projectile(scene_projectile_destructive_fast_speed)
		elif weaponType == "veryFast_speed":
			shoot_projectile(scene_projectile_veryFast_speed)
		elif weaponType == "lethalBall_basic":
			shoot_projectile(scene_projectile_lethalBall_basic)
	
	
	#SECONDARY ATTACK
	if not dead and Input.is_action_pressed("attack_secondary"):
		if secondaryWeaponType == "basic":
			shoot_secondaryProjectile(scene_secondaryProjectile_basic)
		elif secondaryWeaponType == "fast":
			shoot_secondaryProjectile(scene_secondaryProjectile_fast)


var on_floor = false #is_on_floor()
var on_wall = false #is_on_wall_only()

func get_basic_player_values():
	if not dead and not block_movement:
		direction = Input.get_axis("move_L", "move_R")
	else:
		direction = 0
	
	if is_on_floor():
		on_floor = true
	else:
		on_floor = false
	
	if is_on_wall():
		on_wall = true
		on_wall_normal = get_wall_normal()
	else:
		on_wall = false
	
	#Leniency timers
	if on_floor:
		jump_leniency.start()
	if on_wall:
		wall_jump_leniency.start()
	#Leniency timers
	
	Globals.player_pos = get_global_position()
	Globals.player_posX = get_global_position()[0]
	Globals.player_posY = get_global_position()[1]
	Globals.player_velocity = velocity
	
	if direction != 0:
		Globals.direction = direction


func handle_spawn_dust():
	if is_on_floor() and direction and spawn_dust_effect:
		spawn_dust_effect = false
		$dust_effect.start()
		
		var effect_dust = effect_dustScene.instantiate()
		effect_dust.position = Globals.player_pos - Vector2(0, -48)
		get_parent().add_child(effect_dust)
		
	elif not is_on_floor():
		spawn_dust_effect = true
		$dust_effect.stop()


@onready var timer_just_left_wind: Timer = $just_left_wind
var just_left_wind = false
var just_left_wind_active = true

#AREAS (water, wind, etc.)
var inside_wind = 0 # If above 0, the player is affected by wind.
var insideWind_direction_X = 0
var insideWind_direction_Y = 0
var insideWind_strength_X = 1.0
var insideWind_strength_Y = 1.0

var inside_water = 0
var insideWater_multiplier = 1

func handle_inside_zone():
	if inside_wind:
		velocity.x += 10 * insideWind_direction_X * insideWind_strength_X
		velocity.y += 10 * insideWind_direction_Y * insideWind_strength_Y
		just_left_wind = false
		just_left_wind_active = false
	else:
		if abs(velocity.x) > 1000 and not just_left_wind_active:
			just_left_wind = true
			timer_just_left_wind.start()
			just_left_wind_active = true
			print("just_left_wind is now true (player left a conveyor belt).")


func handle_zoom(delta):
	if Input.is_action_pressed("zoom_out"):
		print(str($Camera2D.zoom.x) + " is the current zoom. " + str(zoomValue) + " is the current zoomValue (speed multiplier)")
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
		
		
	elif Input.is_action_pressed("zoom_in"):
		print(str($Camera2D.zoom.x) + " is the current zoom. " + str(zoomValue) + " is the current zoomValue (speed multiplier)")
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
		
		
	elif Input.is_action_pressed("zoom_reset"):
		print("Camera zoom reset.")
		$Camera2D.zoom.x = 1
		$Camera2D.zoom.y = 1


func handle_toggle_debugMovement():
	if Globals.debug_mode:
		if not debugMovement and Input.is_action_just_pressed("cheat"):
			debugMovement = true
			
		elif debugMovement and Input.is_action_just_pressed("cheat"):
			debugMovement = false


func handle_manual_player_death():
	if Input.is_action_just_pressed("back"):
		Globals.playerHP = 100
		world.kill_player()


func handle_flight(delta):
	if Input.is_action_pressed("jump") or Input.is_action_pressed("move_UP"):
		velocity.y = move_toward(velocity.y, JUMP_VELOCITY, delta * ACCELERATION / 2)
	elif Input.is_action_pressed("move_DOWN"):
		velocity.y = move_toward(velocity.y, -JUMP_VELOCITY, delta * ACCELERATION / 2)
	else:
		velocity.y = move_toward(velocity.y, 0, delta * 600)


func handle_just_landed():
	if true_just_landed:
		true_just_landed = false
		print("Player landed.")
		player_just_landed.emit()
	if not is_on_floor():
		true_just_landed_queued = true


func on_player_landed():
	%AnimationPlayer.play("RESET")
	$landed.play()


func on_powerup_activated():
	double_score = true
	$powerup_timer.start()

func _on_powerup_timer_timeout():
	double_score = false


func on_max_score_multiplier_reached():
	animation_player2.play("max_score_multiplier_reached")
	air_jump = true
	wall_jump = true

func on_comboReset():
	animation_player2.play("streak_reset")


func _on_block_movement_full_timeout() -> void:
	block_movement_full = false
	velocity = Vector2(0, 0)


var debugToggle = false
var scene_debug_screen = preload("res://Other/Scenes/User Interface/Debug/screen_debug.tscn")
func handle_debug_screen():
	if Input.is_action_just_pressed("show_debugInfo"):
		if not debugToggle:
			#$/root/World.player.block_movement = true
			var debug_screen = scene_debug_screen.instantiate()
			world.hud.add_child(debug_screen)
			
			debug_screen.debugToggle = true
			debugToggle = true
			debug_screen.visible = true
			
			get_tree().set_debug_collisions_hint(true)
			debug_screen.refresh_debugInfo()
			debug_screen.refresh_debugInfo_values()
		
		else:
			#$/root/World.player.block_movement = false
			get_tree().set_debug_collisions_hint(false)
			
			world.debug_screen_delete()
			debugToggle = false


func _on_just_left_wind_timeout() -> void:
	just_left_wind = false
	print("just_left_wind is now false (player left a conveyor belt for and a set time is up) so regular air acceleration is applied.")


# If the player just bounced off a bounce-type zone.
@onready var timer_just_bounced: Timer = $just_bounced
var just_bounced = false

func on_player_just_bounced():
	just_bounced = true
	timer_just_bounced.start()
	air_jump = true
	wall_jump = true
	sprite.modulate.g = 0.8

func _on_just_bounced_timeout() -> void:
	just_bounced = false
	sprite.modulate.g = 1.0


var menu_levelSelect = preload("res://Other/Scenes/Level Select/screen_levelSelect.tscn")
var menu_start = preload("res://Other/Scenes/menu_start.tscn")

func handle_actions():
	if Input.is_action_just_pressed("menu"):
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(menu_levelSelect)
		await LevelTransition.fade_from_black_slow()
		
	elif Input.is_action_just_pressed("menu_start"):
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(menu_start)
		await LevelTransition.fade_from_black_slow()
