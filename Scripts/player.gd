extends CharacterBody2D

@onready var World = Globals.reassign_general()[0]
@onready var Player = Globals.reassign_general()[1]

@export var speed_x = 400.0
@export var speed_y = 400.0
@export var jump_velocity = -550.0
@export var acceleration = 1200.0
@export var friction = 1200.0
@export var fall_speed = 1000.0
@export var gravity_multiplier = 1.0
@export var air_slowdown = -400.0
@export var air_acceleration = 1400.0

var base_speed_x = speed_x
var base_speed_y = speed_y
var base_jump_velocity = jump_velocity
var base_acceleration = acceleration
var base_friction = friction
var base_gravity_multiplier = gravity_multiplier

@export var speed_multiplier_x = 1.0
@export var speed_multiplier_y = 1.0

@export var ability_jump = true
@export var ability_air_jump = true
@export var ability_wall_jump = true
@export var ability_crouch = true
@export var ability_crouch_walk = true
@export var ability_dash = true

@export var flight = false

var can_jump = true
var can_air_jump = false
var can_wall_jump = false

var on_wall_normal = Vector2.ZERO

var gravity = Globals.gravity

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

@onready var collision_main = $CollisionShape2D
@onready var hitbox = $hitbox_main/CollisionShape2D

@onready var sfx_manager = $sfx_manager

@onready var c_attack: Timer = %cooldown_attack
@onready var c_secondaryAttack: Timer = %cooldown_secondaryAttack

@onready var t_leniency_jump = $timer_leniency_jump
@onready var t_leniency_wall_jump = $timer_leniency_wall_jump
@onready var t_powerUp = $timer_powerUp
@onready var t_await_jump = $timer_await_jump
@onready var t_dash = $timer_dash
@onready var t_dash_speed_block = $timer_dash/timer_dash_speed_block
@onready var c_dash_end_slowdown_enable = $timer_dash/cooldown_dash_end_slowdown_enable
@onready var c_dash_end_slowdown_disable = $timer_dash/cooldown_dash_end_slowdown_disable
@onready var t_dash_await_jump = $timer_dash/timer_dash_await_jump
@onready var dash_check = $timer_dash/dash_check
@onready var t_block_movement_full: Timer = $block_movement_full
@onready var t_invincible = $timer_invincible
@onready var c_state_idle: Timer = $cooldown_state_idle

@onready var animation_player_sprite_general = %animation_player_sprite_general
@onready var animation_player_sprite_color = %animation_player_sprite_color

@onready var t_state_shoot = $timer_state_shoot
@onready var t_state_damage = $timer_state_damage
#@onready var t_state_crouch = $timer_state_crouch
#@onready var t_state_walk = $timer_state_walk

@onready var c_crouch_walk = $AnimatedSprite2D/cooldown_crouch_walk
@onready var c_crouch_walk_correct_collision = $AnimatedSprite2D/cooldown_crouch_walk_correct_collision

@onready var hitbox_dash_scan_solid = $hitbox_dash_scan_solid


@export var damage_value = 1 # Used when bouncing off an entity, NOT when attacking with a projectile/weapon.
@export var health_value = 15 # So far it's handled through Global signals, and the value is Global too.


# Properties:
var jump_active = false

var crouch_active = false
var crouch_walk_active = false
var crouch_walk_multiplier = 1

# If can_stand_up is equal to 0, there is nothing blocking the player
var can_stand_up = 0

var rng = RandomNumberGenerator.new()
var pitch_scale = 1.0

var dead = false
var invulnerable = false # Used for the invulnerability period during which the player cannot be damaged.
var invincible = false # Used for temporary powerups.

var direction_x = 0 # Only horizontal.
var direction_y = 0 # Only vertical.
var direction_x_active = 1 # Can never be equal to 0.
var direction_y_active = -1 # Can never be equal to 0.
var direction_full = Vector2(0, 0)
var direction_full_active = Vector2(1, -1) # None of the values (x and y) can ever be equal to 0.

# Used mostly for sprite animations.
var state_idle = 0
var state_walk = 0
var state_jump = 0
var state_fall = 0
var state_shoot = 0
var state_crouch = 0
var state_crouch_walk = 0
var state_damage = 0
var state_death = 0

var dead_anim_active = false

var debug_movement = false

var spawn_dust_effect = true

var block_movement = false # Blocks all inputs and makes the player stop smoothly.
var block_movement_cutscene = false # Blocks all actual inputs but allows simulated inputs to still move the player.
var block_movement_full = false # Blocks the move_and_slide() function.

var double_score = false

var lethalBall_released = false

var can_collect = true # Whether the entity (player in this case) can collect another entity.

# Emitted when player lands on the ground.
signal player_just_landed
# Emitted when player touches a zone of the "bouncy" type.
signal player_just_bounced
# Emitted when player exits a zone of the "wind" type (used mostly for conveyor belts).
signal player_just_left_wind


func _ready():
	base_speed_x = speed_x
	base_speed_y = speed_y
	base_jump_velocity = jump_velocity
	base_acceleration = acceleration
	base_friction = friction
	base_gravity_multiplier = gravity_multiplier
	
	Globals.player_position = position
	
	Globals.levelState_saved.connect(on_levelState_saved)
	Globals.levelState_loaded.connect(on_levelState_loaded)
	Globals.playerData_saved.connect(on_playerData_saved)
	Globals.playerData_loaded.connect(on_playerData_loaded)
	Globals.levelSet_saved.connect(on_levelSet_saved)
	Globals.levelSet_loaded.connect(on_levelSet_loaded)
	
	Globals.player_damage.connect(reduce_health)
	Globals.player_kill.connect(kill)
	Globals.player_heal.connect(heal)
	
	Globals.projectile_charged.connect(charged_effect)
	Globals.projectile_shot.connect(cancel_effect)
	
	player_just_landed.connect(on_just_landed)
	
	Globals.powerUp_activated.connect(on_powerUp_activated)
	Globals.max_scoreMultiplier_reached.connect(on_max_scoreMultiplier_reached)
	Globals.combo_reset.connect(on_combo_reset)
	
	
	if World.camera_boundary_left != 0.0 or World.camera_boundary_right != 0.0 or World.camera_boundary_top != 0.0 or World.camera_boundary_bottom != 0.0:
		camera.limit_left = World.camera_boundary_left
		camera.limit_right = World.camera_boundary_right
		camera.limit_bottom = World.camera_boundary_bottom
		camera.limit_top = World.camera_boundary_top
	
	
	#total collectibles
	await get_tree().create_timer(0.5, false).timeout
	Globals.total_collectibles_in_currentLevel = get_tree().get_nodes_in_group("Collectibles").size() + (get_tree().get_nodes_in_group("bonusBox").size() * 10)
	
	
	if Globals.mode_scoreAttack:
		weaponType = "basic"


func _process(delta):
	if Input.is_action_pressed("LMB"):
		position = get_global_mouse_position()
		velocity.y = 0
	
	update_can() # The word "can" does too.
	
	get_basic_player_values()
	
	if debug_movement:
		handle_debugMovement(delta)
	
	else:
		handle_gravity(delta)
		
		if can_jump and not dead:
			if not handle_jump(delta):
				if can_wall_jump:
					handle_wall_jump()
		
		handle_move_x(delta)
		handle_air_acceleration(delta)
	
	#SHOOTING LOGIC
	handle_shoot()
	
	handle_friction(delta)
	handle_air_slowdown(delta)
	
	if not debug_movement:
		#DASHING LOGIC
		if can_dash:
			handle_dash()
		
		#CROUCHING LOGIC
		if ability_crouch:
			handle_crouch()
	
	
	if not debug_movement:
		if not stuck:
			if flight:
				handle_flight(delta)
			
			handle_inside_zone()
			
			if not block_movement_full:
				move_and_slide() #MAIN MOVEMENT
		
		update_sprite()
	
	if not state_damage and not dead and velocity.y == 0 and is_on_floor() and not on_floor and not state_shoot and not crouch_walk_active and not crouch_active:
		sprite.play("idle")
	
	handle_spawn_dust()
	
	handle_manual_player_death()
	
	#HANDLE STUCK IN WALL
	handle_stuck()
	
	handle_gameMode_scoreAttack()
	
	# Handle JUST.
	just_queue() # The word "just" refers to something very specific. Check out the function for the explanation.
	just_update() # The word "just" refers to something very specific. Check out the function for the explanation.
	just_handle()

#MAIN END

var zoomValue = 1

# Ground dash logic:
var dash_active = false
var dash_speed_block_active = false
var dash_end_slowdown_active = false
var dash_end_slowdown_await_jump = false
var dash_just_landed = false
var dash_just_landed_queued = false
var dash_end_slowdown_canceled = false

var can_dash = true

signal safe_standUp

func _on_timer_dash_timeout():
	dash_active = false
	
	if can_stand_up == 0:
		collision_main.shape.size = Vector2(20, 56)
		collision_main.position = Vector2(0, 0)
		
		hitbox.shape.extents = Vector2(16, 40)
		hitbox.position = Vector2(0, 0)
		
		can_dash = true
	
	else:
		await safe_standUp
		collision_main.shape.extents = Vector2(40, 112)
		collision_main.position = Vector2(0, 0)
		
		hitbox.shape.extents = Vector2(16, 40)
		hitbox.position = Vector2(0, 0)
		
		can_dash = true
	
	raycast_top.enabled = true

func _on_timer_dash_speed_block_timeout():
	dash_speed_block_active = false
	c_dash_end_slowdown_enable.start()

func _on_cooldown_dash_end_slowdown_enable_timeout():
	if not dash_end_slowdown_canceled:
		c_dash_end_slowdown_disable.start()
		dash_end_slowdown_active = true
	else:
		dash_end_slowdown_canceled = false
		dash_just_landed_queued = false
		dash_just_landed = false
		dash_end_slowdown_await_jump = false

func _on_cooldown_dash_end_slowdown_disable_timeout():
	dash_end_slowdown_active = false
	dash_end_slowdown_canceled = false
	dash_just_landed_queued = false
	dash_just_landed = false
	dash_end_slowdown_await_jump = false
	animation_player_sprite_color.play("streak_reset")


# Checks whether the player is stuck inside a solid tileset.
func _on_hitbox_dash_scan_solid_body_entered(_body):
	can_stand_up += 1

func _on_hitbox_dash_scan_solid_body_exited(_body):
	can_stand_up -= 1


func handle_gravity(delta):
	if not on_floor and not dash_active or dash_end_slowdown_active:
		if not flight:
			if Input.is_action_pressed("jump"):
				if inside_water:
					velocity.y += fall_speed * 1.0 * delta * gravity_multiplier * inside_water_multiplier_x
				else:
					velocity.y += fall_speed * 1.0 * delta * gravity_multiplier
			
			elif Input.is_action_pressed("move_down"):
				if inside_water:
					velocity.y += fall_speed * 2.0 * delta * gravity_multiplier * inside_water_multiplier_x
				else:
					velocity.y += fall_speed * 4.0 * delta * gravity_multiplier
			
			else:
				if inside_water:
					velocity.y += fall_speed * 1.5 * delta * gravity_multiplier * inside_water_multiplier_x
				else:
					velocity.y += fall_speed * 1.5 * delta * gravity_multiplier
	
	
	if not dead and dash_active:
		if not dash_speed_block_active or dash_end_slowdown_active:
			t_dash_speed_block.start()
		
		dash_speed_block_active = true
		sprite.play("crouch")
		
		#if started_dash == false or dash_slowdown:
			#velocity.x = 0
		
		if Input.is_action_pressed("move_down"):
			velocity.y += fall_speed * delta * 4 * gravity_multiplier
			velocity.x = move_toward(velocity.x, 1000 * direction_x, 6000 * delta)
		else:
			velocity.y += fall_speed * delta * 2 * gravity_multiplier
			velocity.x = move_toward(velocity.x, 1000 * direction_x, 6000 * delta)
	
	else:
		dash_active = false
	
	if dash_end_slowdown_active and not dash_end_slowdown_canceled:
		velocity.x = move_toward(velocity.x, 0, 7000 * delta)
	
	
	##WHAT IS THIS?
	#HANDLE JUST LANDED
	#if dash_just_landed_queued and is_on_floor():
		#dash_just_landed_queued = false
		#just_landed = true


func update_sprite():
	if direction_x:
		sprite.flip_h = (direction_x < 0)
	
	else:
		if on_floor or flight:
			if state_idle and state_walk:
				if c_state_idle.is_stopped():
					c_state_idle.start()
		
		else:
			state_walk = 0 # Because being in the air should never cause an idle anim to play, except during flight.
	
	sprite_animation()

func sprite_animation():
	
	var queued_anim = "idle"
	var x = 0
	
	if state_idle >= x : queued_anim = "idle"; x = state_idle
	if state_walk >= x : queued_anim = "walk"; x = state_walk
	if state_jump >= x : queued_anim = "jump"; x = state_jump
	if state_fall >= x : queued_anim = "fall"; x = state_fall
	if state_shoot >= x : queued_anim = "shoot"; x = state_shoot
	if state_damage >= x : queued_anim = "damaged"; x = state_damage
	if state_crouch >= x : queued_anim = "crouch"; x = state_crouch
	if state_crouch_walk >= x : queued_anim = "crouch_walk"; x = state_crouch_walk
	if state_death >= x : queued_anim = "death"; x = state_death
	
	sprite.play(queued_anim)


func _on_cooldown_state_idle_timeout(): # Walking anim weight is disabled here, allowing for the Idle anim to take over after a delay after the player stops moving horizontally.
	if on_floor : state_walk = 0
	Globals.dm("The 'Walk' state's weight has been set to 0, after a short delay after the player stopped moving.")


func handle_friction(delta):
	if not direction_x:
		velocity.x = move_toward(velocity.x, 0, friction * inside_water_multiplier_x * delta)


func handle_air_slowdown(delta):
	if direction_x == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_slowdown * delta)


func handle_air_acceleration(delta):
	if is_on_floor() or recently_bounced: return
	
	if direction_x != 0:
		# Reduce slowdown while under influence of heavy wind (conveyor belts).
		if just_left_wind:
			velocity.x = move_toward(velocity.x, speed_x * 2 * direction_x, air_acceleration / 3 * delta)
		# Normal
		else:
			velocity.x = move_toward(velocity.x, speed_x * direction_x, air_acceleration * delta)
	
	if not recently_bounced:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			velocity.x *= 0.75


func handle_walk(delta):
	handle_move_x(delta)
	state_walk = 5


func handle_move_x(delta):
	if not on_floor or not direction_x:
		state_idle = 1
		return
	
	if inside_wind:
		if inside_wind_multiplier_x == direction_x:
			speed_x = base_speed_x * inside_wind_multiplier_x
	else:
		velocity.x = move_toward(velocity.x, direction_x * speed_x, acceleration * delta * crouch_walk_multiplier * inside_water_multiplier_x)
	
	if not recently_bounced:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			velocity.x *= 0.75
	
	state_walk = 1
	state_idle = 0


func handle_jump(delta):
	if just_landed:
		if dash_active and can_air_jump:
			dash_just_landed = false
			dash_end_slowdown_await_jump = true
			%timer_await_jump.start()
	
	if dash_end_slowdown_await_jump and is_on_floor() and Input.is_action_just_pressed("jump"):
		dash_end_slowdown_await_jump = false
		dash_end_slowdown_canceled = true
		velocity.x = base_speed_x * 4.5 * direction_x
		
		state_jump = 1
	
	
	# Regular jump:
	if can_jump and on_floor and t_leniency_jump.time_left > 0.0:
		
		if Input.is_action_just_pressed("jump"):
			Globals.message_debug("player jump")
			can_jump = false
			
			sfx(Globals.sfx_player_jump, 1.0, 1.0)
			var x = randi_range(0, 1)
			if not dash_active and x or not dash_active and not direction_x:
				%animation_player_sprite_general.stop()
				%animation_player_sprite_general.speed_scale = 2
				%animation_player_sprite_general.play("jumped")
			else:
				%animation_player_sprite_general.stop()
				%animation_player_sprite_general.speed_scale = 1.5
				if direction_x == 1:
					%animation_player_sprite_general.play("rotate_right")
				if direction_x == -1:
					%animation_player_sprite_general.play("rotate_left")
			
			velocity.y = jump_velocity
			
			state_jump = 1
			
			return true
	
	#if jump_active and Input.is_action_pressed("jump"):
		#if inside_water:
			#velocity.y = move_toward(velocity.y, jump_velocity, 8500 * inside_water_multiplier * delta)
		#else:
			#velocity.y = move_toward(velocity.y, jump_velocity, 8500 * delta)
		
	elif not on_floor and not on_wall and not t_leniency_wall_jump.time_left > 0.0 or not on_floor and on_wall and not can_wall_jump and t_leniency_wall_jump.time_left > 0.0:
		if Input.is_action_just_released("jump") and velocity.y < jump_velocity / 2:
			velocity.y = jump_velocity / 2
		if can_air_jump and Input.is_action_just_pressed("jump") and not Input.is_action_pressed("move_down"):
			Globals.message_debug("player air jump")
			if inside_water:
				velocity.y = jump_velocity * 0.8 * inside_water_multiplier_x
			else:
				velocity.y = jump_velocity * 0.8
			
			can_air_jump = false
			
			sfx(Globals.sfx_player_jump, 1.0, 0.0)
			
			var x = randi_range(0, 1)
			if x or not direction_x:
				%animation_player_sprite_general.stop()
				%animation_player_sprite_general.speed_scale = 3
				%animation_player_sprite_general.play("air_jumped")
			else:
				%animation_player_sprite_general.stop()
				%animation_player_sprite_general.speed_scale = 1
				if direction_x == 1:
					%animation_player_sprite_general.play("rotate_right")
				if direction_x == -1:
					%animation_player_sprite_general.play("rotate_left")
			
			dash_end_slowdown_canceled = true
			if dash_end_slowdown_await_jump:
				velocity.x += 500 * direction_x
			
			state_jump = 1
			
			return true
	
	return false


func handle_wall_jump():
	if not is_on_wall_only() and t_leniency_wall_jump.time_left <= 0.0: return
	
	if Input.is_action_just_pressed("jump") and can_wall_jump:
		Globals.message_debug("player wall jump")
		velocity.x = on_wall_normal.x * speed_x
		if inside_water:
			velocity.y = jump_velocity * 1 * inside_water_multiplier_x
		else:
			velocity.y = jump_velocity * 1
		
		can_wall_jump = false
		
		sfx(Globals.sfx_player_wall_jump, 1.0, 0.0)
		
		var x = randi_range(0, 1)
		if x or not direction_x:
			%animation_player_sprite_general.stop()
			%animation_player_sprite_general.speed_scale = 3
			%animation_player_sprite_general.play("air_jumped")
		else:
			%animation_player_sprite_general.stop()
			%animation_player_sprite_general.speed_scale = 1
			if direction_x == -1:
				%animation_player_sprite_general.play("rotate_right")
			if direction_x == 1:
				%animation_player_sprite_general.play("rotate_left")


# Player damage (Received by player).
func health_decrease(value):
	if invulnerable or invincible or dead:
		sfx(Globals.sfx_player_damage, 1.0, 0.0)
		state_damage = true
		t_state_damage.start()


func charged_effect():
	animation_player_sprite_color.play("shot_charged")
	
	var star = Globals.scene_particle_star.instantiate()
	add_child(star)
	star = Globals.scene_particle_star.instantiate()
	add_child(star)
	star = Globals.scene_particle_star.instantiate()
	add_child(star)
	star = Globals.scene_particle_star.instantiate()
	add_child(star)

func cancel_effect():
	animation_player_sprite_color.stop()
	animation_player_sprite_color.play("RESET")


func _on_timer_state_shoot():
	state_shoot = false


# Player crouch/dash logic:
func handle_crouch():
	if can_dash and is_on_floor():
		if Input.is_action_pressed("move_down") and not crouch_walk_active:
			Globals.message_debug("player crouch")
			c_crouch_walk.start()
			c_crouch_walk_correct_collision.start()
			crouch_active = true
			state_crouch = 1
			sprite.play("crouch")
			
			crouch_walk_multiplier = 0.6
			if ability_crouch_walk:
				speed_x = base_speed_x * crouch_walk_multiplier
			else:
				speed_x = 0
			
			raycast_top.enabled = false
		
		
		if crouch_walk_active:
			sprite.play("crouch_walk")
			crouch_active = false
			
			crouch_walk_multiplier = 0.4
			speed_x = base_speed_x * crouch_walk_multiplier
			
			raycast_top.enabled = false
	
	if not Input.is_action_pressed("move_down") and can_stand_up == 0 and crouch_active or not Input.is_action_pressed("move_down") and can_stand_up == 0 and crouch_walk_active or not is_on_floor() and can_stand_up == 0 and crouch_walk_active:
		collision_main.shape.extents = Vector2(20, 56)
		collision_main.position = Vector2(0, 0)
		
		hitbox.shape.extents = Vector2(16, 40)
		hitbox.position = Vector2(0, 0)
		
		
		crouch_active = false
		crouch_walk_active = false
		c_crouch_walk.stop()
		c_crouch_walk_correct_collision.stop()
		speed_x = base_speed_x
		crouch_walk_multiplier = 1
		
		raycast_top.enabled = true

func _on_cooldown_crouch_walk_timeout():
	if ability_crouch_walk:
		Globals.message_debug("Player is crouching.")
		crouch_walk_active = true

func _on_cooldown_crouch_walk_correct_collision_timeout():
	collision_main.shape.extents = Vector2(20, 20)
	collision_main.position += Vector2(0, 36)
	hitbox.shape.extents = Vector2(20, 20)
	hitbox.position += Vector2(0, 28)

func handle_dash():
	if can_dash and Input.is_action_just_pressed("dash") and is_on_floor() and dash_active == false and not crouch_walk_active and not crouch_active:
		Globals.message_debug("player dash")
		dash_end_slowdown_canceled = false
		dash_active = true
		can_dash = false
		t_dash.start()
		
		collision_main.shape.extents = Vector2(20, 20)
		collision_main.position += Vector2(0, 36)
		
		hitbox.shape.extents = Vector2(20, 20)
		hitbox.position += Vector2(0, 28)
		
		raycast_top.enabled = false


func _on_timer_jump_timeout():
	pass


func _on_hitbox_main_area_entered(area):
	pass


func saveState_loaded():
	$Camera2D.position_smoothing_enabled = false
	await get_tree().create_timer(0.1, false).timeout
	$Camera2D.position_smoothing_enabled = true
	
	collision_main.shape.extents = Vector2(20, 56)
	collision_main.position = Vector2(0, 0)
	
	hitbox.shape.extents = Vector2(16, 40)
	hitbox.position = Vector2(0, 0)
	
	dead_anim_active = false
	
	
	Overlay.animation("fade_black", true, true, 1.0)


func _on_cooldown_effect_dust_timeout():
	spawn_dust_effect = true


# Attack Cooldown:
# Main:
func _on_cooldown_attack_timeout():
	attack_cooldown = false
	if Globals.direction_x != 0:
		$AnimatedSprite2D.flip_h = (Globals.direction_x < 0)

# Secondary:
func _on_cooldown_secondaryAttack_timeout():
	secondaryAttack_cooldown = false
	if Globals.direction_x != 0:
		$AnimatedSprite2D.flip_h = (Globals.direction_x < 0)


func _on_just_landed_delay_timeout():
	recently_landed = false
	q_just_landed = true


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
	World.add_child(player_rooster)

func deferred_spawnBird():
	remove_from_group("player")
	remove_from_group("player_root")
	camera.remove_from_group("player_camera")
	var player_bird = player_bird_scene.instantiate()
	player_bird.position = position
	World.add_child(player_bird)

func deferred_spawnChicken():
	remove_from_group("player")
	remove_from_group("player_root")
	camera.remove_from_group("player_camera")
	var player_chicken = player_chicken_scene.instantiate()
	player_chicken.position = position
	World.add_child(player_chicken)


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
	state_damage = false


func _on_dash_check_timeout():
	if can_stand_up == 0:
		safe_standUp.emit()


func shoot_projectile(projectile_scene):
	if weaponType == "basic" and Globals.collected_in_cycle >= 20:
		if not dead and Input.is_action_just_pressed("attack_main"):
			#var projectile_phaser = scene_projectile_phaser.instantiate()
			#projectile_phaser.playerProjectile = true
			#projectile_phaser.enemyProjectile = false
			#add_child(projectile_phaser)
			
			state_shoot = true
			t_state_shoot.start()
			sprite.play("shoot")
			if direction_x != 0:
				sprite.flip_h = (direction_x < 0)
		
		return
	
	if not attack_cooldown:
		attack_cooldown = true
		$attack_cooldown.start()
		
		state_shoot = true
		t_state_shoot.start()
		sprite.play("shoot")
		
		var projectile = projectile_scene.instantiate()
		projectile.playerProjectile = true
		projectile.enemyProjectile = false
		projectile.position = position + Vector2(Globals.direction_x * 24, -10)
		get_parent().add_child(projectile)
		
		playSound_shoot()
		
	if direction_x != 0:
		sprite.flip_h = (direction_x < 0)


func shoot_secondaryProjectile(secondaryProjectile_scene):
	if not secondaryAttack_cooldown:
		secondaryAttack_cooldown = true
		$secondaryAttack_cooldown.start()
		
		state_shoot = true
		t_state_shoot.start()
		sprite.play("secondaryShoot")
		
		var secondaryProjectile = secondaryProjectile_scene.instantiate()
		secondaryProjectile.position = position + Vector2(Globals.direction_x * 0, 32)
		secondaryProjectile.direction_x = direction_x
		if velocity.y <= -100 or velocity.y == 0:
			secondaryProjectile.velocity = Vector2(velocity.x * 1.2, -100)
		else:
			secondaryProjectile.velocity = Vector2(velocity.x * 1.2, 100)
		get_parent().add_child(secondaryProjectile)
		playSound_shoot()
		
	if direction_x != 0:
		sprite.flip_h = (direction_x < 0)


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
		raycast_top.target_position.x = 16 * Globals.player_direction_x_active
		raycast_bottom.target_position.x = 16 * Globals.player_direction_x_active
		raycast_middle.target_position.x = 16 * Globals.player_direction_x_active
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
			position += Vector2(4 * Globals.player_direction_x_active, -4)
			velocity = Vector2(0, 0)
		else:
			stuck = false


var confirm_timer_isActive = false
func _on_stuck_check_timeout():
	if confirm_timer_isActive:
		return
	
	if velocity.y == jump_velocity or velocity[1] == 0:
		$stuck_check/stuck_confirm.start()
		confirm_timer_isActive = true

func _on_stuck_confirm_timeout():
	if velocity.y == jump_velocity or velocity[1] == 0:
		stuck = true
		Globals.message_debug("The stuck_confirm timer just went off while a rare stuck case is possible - [velocity.y = jump_velocity] or [velocity = Vector2(0, 0)]. Now the 'stuck' variable becomes true and will be cancelled right after, unless any of the raycasts detect collision.") 
		
		raycast_top.target_position.x = 16
		raycast_bottom.target_position.x = 16
		raycast_middle.target_position.x = 16
	
	else:
		Globals.message_debug("The stuck_confirm timer just went off, but it seems like there is no way the player could be stuck.")
	
	confirm_timer_isActive = false



#Debug movement type that lets you freely move in any direction_x. Press CTRL + C to activate it. (needs Globals.debug_mode to be true)
#Hold RMB to move a lot slower. Hold SHIFT to move very fast.
func handle_debugMovement(delta):
	if Input.is_action_pressed("move_right"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.x += 200 * delta
			return
		
		elif Input.is_action_pressed("dash"):
			global_position.x += 2000 * delta
			return
			
		global_position.x += 1000 * delta
	
	if Input.is_action_pressed("move_left"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.x -= 200 * delta
			return
		
		elif Input.is_action_pressed("dash"):
			global_position.x -= 2000 * delta
			return
			
		global_position.x -= 1000 * delta
	
	if Input.is_action_pressed("move_up"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.y -= 200 * delta
			return
		
		elif Input.is_action_pressed("dash"):
			global_position.y -= 2000 * delta
			return
			
		global_position.y -= 1000 * delta
	
	if Input.is_action_pressed("move_down"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.y += 200 * delta
			return
			
		elif Input.is_action_pressed("dash"):
			global_position.y += 2000 * delta
			return
			
		global_position.y += 1000 * delta
	
	crouch_active = false
	crouch_walk_active = false


var attack_cooldown = false
var secondaryAttack_cooldown = false
@export var weaponType = "none"
@export var secondaryWeaponType = "none"

#WEAPON TYPES
#var scene_projectile_phaser = load("res://Projectiles/player_projectile_charged_phaser.tscn")
#var scene_projectile_basic = load("res://Projectiles/player_projectile_basic.tscn")
#var scene_projectile_short_shotDelay = load("res://Projectiles/player_projectile_short_shotDelay.tscn")
#var scene_projectile_ice = load("res://Projectiles/player_projectile_ice.tscn")
#var scene_projectile_fire = load("res://Projectiles/player_projectile_fire.tscn")
#var scene_projectile_destructive_fast_speed = load("res://Projectiles/player_projectile_destructive_fast_speed.tscn")
#var scene_projectile_veryFast_speed = load("res://Projectiles/player_projectile_veryFast_speed.tscn")
#var scene_projectile_lethalBall_basic = load("res://Projectiles/projectile_lethalBall_base.tscn")
##WEAPON TYPES END

#SECONDARY WEAPON TYPES
#var scene_secondaryProjectile_basic = load("res://Projectiles/player_secondaryProjectile_basic.tscn")
#var scene_secondaryProjectile_fast = load("res://Projectiles/player_secondaryProjectile_fast.tscn")
#SECONDARY WEAPON TYPES END

func handle_shoot():
	#MAIN ATTACK
	if weaponType == "phaser":
		if not dead and Input.is_action_just_pressed("attack_main"):
			#var projectile_phaser = scene_projectile_phaser.instantiate()
			#add_child(projectile_phaser)
			
			#SHOOTING ANIMATION
			state_shoot = true
			t_state_shoot.start()
			sprite.play("shoot")
			if direction_x != 0:
				sprite.flip_h = (direction_x < 0)
			
			return
	
	if not dead and Input.is_action_pressed("attack_main"):
		pass
		#if weaponType == "basic":
			#shoot_projectile(scene_projectile_basic)
		#elif weaponType == "short_shotDelay":
			#shoot_projectile(scene_projectile_short_shotDelay)
		#elif weaponType == "ice":
			#shoot_projectile(scene_projectile_ice)
		#elif weaponType == "fire":
			#shoot_projectile(scene_projectile_fire)
		#elif weaponType == "destructive_fast_speed":
			#shoot_projectile(scene_projectile_destructive_fast_speed)
		#elif weaponType == "veryFast_speed":
			#shoot_projectile(scene_projectile_veryFast_speed)
		#elif weaponType == "lethalBall_basic":
			#shoot_projectile(scene_projectile_lethalBall_basic)
	
	
	#SECONDARY ATTACK
	#if not dead and Input.is_action_pressed("attack_secondary"):
		#if secondaryWeaponType == "basic":
			#shoot_secondaryProjectile(scene_secondaryProjectile_basic)
		#elif secondaryWeaponType == "fast":
			#shoot_secondaryProjectile(scene_secondaryProjectile_fast)


# True if player is currently touching the specified surface.
var on_floor = false
var on_wall = false

func get_basic_player_values():
	if not dead and not block_movement:
		direction_x = Input.get_axis("move_left", "move_right")
	else:
		direction_x = 0
	
	if is_on_floor():
		on_floor = true
	else:
		on_floor = false
	
	if is_on_wall():
		on_wall = true
		on_wall_normal = get_wall_normal()
	else:
		on_wall = false
	
	# Leniency timers:
	if on_floor:
		t_leniency_jump.start()
	if on_wall:
		t_leniency_wall_jump.start()
	
	#Globals.player_pos = get_global_position()
	#Globals.player_posX = get_global_position()[0]
	#Globals.player_posY = get_global_position()[1]
		#Globals.player_pos = get_global_position()
	#Globals.player_posX = get_global_position()[0]
	#Globals.player_posY = get_global_position()[1]
	Globals.player_velocity = velocity
	
	Globals.player_direction_x = direction_x


func handle_spawn_dust():
	if is_on_floor() and direction_x and spawn_dust_effect:
		spawn_dust_effect = false
		$cooldown_effect_dust.start()
		
		var dust = Globals.scene_effect_dust.instantiate()
		dust.position = Globals.player_position - Vector2(0, -48)
		get_parent().add_child(dust)
		
	elif not is_on_floor():
		spawn_dust_effect = true
		$cooldown_effect_dust.stop()


# Zones (water, wind, bouncy, etc.)
var inside_wind = 0 # If above 0, the player is affected by wind.
var inside_wind_multiplier_x = 0
var inside_wind_multiplier_y = 0

var inside_water = 0
var inside_water_multiplier_x = 1.0
var inside_water_multiplier_y = 1.0

func handle_inside_zone():
	if inside_wind:
		velocity.x += 10 * inside_wind_multiplier_x
		velocity.y += 10 * inside_wind_multiplier_y
		recently_left_wind = false
	else:
		if abs(velocity.x) > 1000 and not recently_left_wind:
			recently_left_wind = true
			t_recently_left_wind.start()
			recently_left_wind = true
			Globals.message_debug("The player's 'just_left_wind' property is now true (because player left a conveyor belt).")


func handle_manual_player_death():
	if Input.is_action_just_pressed("back"):
		Globals.player_kill.emit()


func handle_flight(delta):
	if Input.is_action_pressed("jump") or Input.is_action_pressed("move_up"):
		velocity.y = move_toward(velocity.y, jump_velocity, delta * acceleration / 2)
	elif Input.is_action_pressed("move_down"):
		velocity.y = move_toward(velocity.y, -jump_velocity, delta * acceleration / 2)
	else:
		velocity.y = move_toward(velocity.y, 0, delta * 600)


func on_powerUp_activated():
	double_score = true
	$powerup_timer.start()

func _on_powerup_timer_timeout():
	double_score = false


func on_max_scoreMultiplier_reached():
	animation_player_sprite_color.play("max_score_multiplier_reached")
	can_air_jump = true
	can_wall_jump = true

func on_combo_reset():
	animation_player_sprite_color.play("streak_reset")


func on_on_block_movement_full_timeout() -> void:
	block_movement_full = false
	velocity = Vector2(0, 0)


func on_levelState_saved():
	pass

func on_levelState_loaded():
	pass

func on_playerData_saved():
	pass

func on_playerData_loaded():
	pass

func on_levelSet_saved():
	pass

func on_levelSet_loaded():
	pass


func reduce_health(value):
	Globals.player_health -= value
	invincible = true
	t_invincible.start()
	sfx(Globals.sfx_player_damage, 1.0, 0.0)


func heal(value):
	Globals.player_health += value
	invincible = true
	t_invincible.start()
	sfx(Globals.sfx_player_heal, 1.0, 0.0)


func kill():
	Globals.player_health = 0
	dead = true
	sfx(Globals.sfx_player_death, 1.0, 0.0)

func sfx(file, volume, pitch):
	sfx_manager.sfx_play(Globals.sfx_player_jump, 1.0, 1.0)


func _on_timer_leniency_jump_timeout() -> void:
	pass # Replace with function body.


func _on_timer_leniency_wall_jump_timeout() -> void:
	pass # Replace with function body.


# The word "just" refers to something that happens for a single frame, like landing on the ground, or bouncing off something.
# The word "recently" refers to a lingering state that starts on triggering a "just", and lasts for a specific amount of time.

var just_landed : bool = false
var just_bounced : bool = false
var just_left_wind : bool = false

var q_just_landed : bool = false
var q_just_just_left_wind : bool = false

var recently_landed : bool = false
var recently_bounced : bool = false
var recently_left_wind : bool = false

# The "just" queues are conditions that must be "true" for the "just" to be able to have its value set to "true" for one frame, and then they (the queues) get set back to "false" immediately after.
# So basically, a queue represents whether, for example, the player was in the air on the previous frame, so that the game knows it can consider the player as having landed the next time it touched the ground, but only for a single frame, not every single frame the player is touching it.

func just_queue():
	if not on_floor:
		q_just_landed = true

func just_update():
	if q_just_landed:
		if is_on_floor():
			just_landed = true
			q_just_landed = false

func just_handle():
	if just_landed : player_just_landed.emit()
	if just_bounced : player_just_bounced.emit()
	
	just_landed = false
	just_bounced = false


@onready var t_recently_landed: Timer = $timer_recently_landed
@onready var t_recently_bounced: Timer = $timer_recently_bounced
@onready var t_recently_left_wind: Timer = $timer_recently_left_wind

# Player just landed on the ground (the "just" refers to something that just got set to true, and then immediately gets set back to false right after all relevant consequences are applied).
func on_just_landed():
	Globals.message_debug("Player landed.")
	%animation_player_sprite_general.play("RESET")
	
	state_jump = 0

func on_just_bounced():
	recently_bounced = true
	t_recently_bounced.start()
	can_air_jump = true
	can_wall_jump = true
	sprite.modulate.g = 0.8
	recently_bounced = false


func _on_timer_recently_landed_timeout() -> void:
	recently_landed = false

func _on_timer_recently_bounced_timeout() -> void:
	recently_bounced = false
	sprite.modulate.g = 1.0

func _on_timer_recently_left_wind_timeout() -> void:
	recently_left_wind = false
	Globals.message_debug("The 'just_left_wind' is now false (Player left a conveyor belt for and a set time is up) so regular air acceleration is applied.")


func update_can(): # The "can" refers to player's movement options that are not always available.
	if on_floor:
		can_jump = true
		can_air_jump = true
		can_wall_jump = true


func _on_timer_await_jump_timeout() -> void:
	pass # Replace with function body.

func _on_timer_state_shoot_timeout() -> void:
	pass # Replace with function body.


func _on_timer_state_damage_timeout() -> void:
	pass # Replace with function body.
