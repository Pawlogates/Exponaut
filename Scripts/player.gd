extends CharacterBody2D

@onready var World = Globals.reassign_general()[0]
@onready var Player = Globals.reassign_general()[1]


@export var camera_speed_multiplier : float = 1.0

@export var speed = 400.0
@export var jump_velocity = -575.0
@export var acceleration = 1200.0
@export var friction = 1200.0
@export var fall_speed = 1000.0
@export var gravity_multiplier = 1.0
@export var air_slowdown = -400.0
@export var air_acceleration = 1400.0

@export var collision_size : Vector2 = Vector2(-1, -1)
@export var collision_pos_offset : Vector2 = Vector2(-1, -1)

@export var hitbox_size : Vector2 = Vector2(-1, -1)
@export var hitbox_pos_offset : Vector2 = Vector2(-1, -1)

@export var dash_hitbox_size : Vector2 = Vector2(-1, -1)
@export var dash_hitbox_pos_offset : Vector2 = Vector2(-1, -1)


var entity_name : String = "Player"

var base_speed = speed
var base_jump_velocity = jump_velocity
var base_acceleration = acceleration
var base_friction = friction
var base_gravity_multiplier = gravity_multiplier
var base_speed_multiplier_x = speed_multiplier_x
var base_speed_multiplier_y = speed_multiplier_y

@export var speed_multiplier_x : float = 1.0
@export var speed_multiplier_y : float = 1.0

@export var ability_jump = true
@export var ability_air_jump = true
@export var ability_wall_jump = true
@export var ability_crouch = true
@export var ability_crouch_walk = true
@export var ability_dash = true

@export var flight = false

@export var attack_pos_offset : Vector2 = Vector2(32, 0)


var can_jump = true
var can_air_jump = false
var can_wall_jump = false

var on_wall_normal = Vector2.ZERO

var gravity = Globals.gravity

@onready var sprite = $sprite
@onready var camera = $camera
@onready var sfx_manager = $sfx_manager
@onready var combo_manager = $"Combo Manager"

@onready var collision_main = $CollisionShape2D
@onready var collision_hitbox = $hitbox_main/CollisionShape2D
@onready var hitbox_main: Area2D = $hitbox_main

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

@onready var animation_player_sprite_general = $sprite/animation_player_sprite_general
@onready var animation_player_sprite_color = $sprite/animation_player_sprite_color

@onready var t_state_shoot = $timer_state_shoot
@onready var t_state_damage = $timer_state_damage
#@onready var t_state_crouch = $timer_state_crouch
#@onready var t_state_walk = $timer_state_walk

@onready var c_crouch_walk = $sprite/cooldown_crouch_walk
@onready var c_crouch_walk_correct_collision = $sprite/cooldown_crouch_walk_correct_collision

@onready var hitbox_dash_scan_solid = $hitbox_dash_scan_solid


@export var damage_value = 50 # Used when bouncing off an entity, NOT when attacking with a projectile/weapon.
@export var health_value = 120 # So far it's handled through Global signals, and the value is Global too.


# Properties:
var jump_active = false

var crouch_active = false
var crouch_walk_active = false
var crouch_walk_multiplier = 1

# If "can_stand_up" is equal to 0, there is nothing blocking the player's collision.
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

var block_movement = false # Blocks all player inputs.
var block_movement_cutscene = false # Blocks all actual inputs but allows simulated inputs to still move the player.
var block_movement_full = false # Blocks the move_and_slide() function.

var double_score = false

var lethalBall_released = false

var can_collect = true # Whether the entity (player in this case) can collect another entity.

var can_press_button_floor : bool = true
var can_press_button_wall : bool = true
var can_press_button_bg : bool = true

var last_checkpoint_pos = Vector2(-1, -1)

var family = "Player"


# Emitted when player lands on the ground.
signal player_just_landed
# Emitted when player touches a zone of the "bouncy" type.
signal player_just_bounced
# Emitted when player exits a zone of the "wind" type (used mostly for conveyor belts).
signal player_just_left_wind


func _ready():
	Globals.refreshed1_0.connect(debug_info)
	
	if collision_size == Vector2(-1, -1) : collision_size = collision_main.shape.extents
	if collision_pos_offset == Vector2(-1, -1) : collision_pos_offset = collision_main.position
	if hitbox_size == Vector2(-1, -1) : hitbox_size = collision_hitbox.shape.extents
	if hitbox_pos_offset == Vector2(-1, -1) : hitbox_pos_offset = collision_hitbox.position
	if dash_hitbox_size == Vector2(-1, -1) : dash_hitbox_size = collision_size / 2
	if dash_hitbox_pos_offset == Vector2(-1, -1) : dash_hitbox_pos_offset = collision_size / 2
	
	World = Globals.reassign_general()[0]
	
	camera.position_smoothing_speed *= camera_speed_multiplier
	
	base_speed = speed
	base_jump_velocity = jump_velocity
	base_acceleration = acceleration
	base_friction = friction
	base_gravity_multiplier = gravity_multiplier
	base_speed_multiplier_x = speed_multiplier_x
	base_speed_multiplier_y = speed_multiplier_y
	
	Globals.player_position = position
	Globals.player_direction_x_active = 1
	
	Globals.levelState_saved.connect(on_levelState_saved)
	Globals.levelState_loaded.connect(on_levelState_loaded)
	Globals.playerData_saved.connect(on_playerData_saved)
	Globals.playerData_loaded.connect(on_playerData_loaded)
	Globals.levelSet_saved.connect(on_levelSet_saved)
	Globals.levelSet_loaded.connect(on_levelSet_loaded)
	
	Globals.player_damage.connect(reduce_health)
	Globals.player_heal.connect(increase_health)
	Globals.player_kill.connect(kill)
	
	Globals.projectile_charged.connect(charged_effect)
	Globals.projectile_shot.connect(cancel_effect)
	
	player_just_landed.connect(on_just_landed)
	
	Globals.powerUp_activated.connect(on_powerUp_activated)
	Globals.max_scoreMultiplier_reached.connect(on_max_scoreMultiplier_reached)
	Globals.combo_reset.connect(on_combo_reset)
	
	await get_tree().create_timer(1.0, true).timeout
	if World.camera_boundary_left != 0.0 or World.camera_boundary_right != 0.0 or World.camera_boundary_top != 0.0 or World.camera_boundary_bottom != 0.0:
		camera.limit_left = World.camera_boundary_left
		camera.limit_right = World.camera_boundary_right
		camera.limit_bottom = World.camera_boundary_bottom
		camera.limit_top = World.camera_boundary_top

func _process(delta):
	# delete this hack as soon as possible... and replace it
	# hack - [start]
	if dead:
		#sprite.position.y = 36
		sprite.modulate = Color.RED
		#sprite.rotation_degrees = move_toward(sprite.rotation_degrees, 100 * randi_range(-20, 20), delta * 100 * randf_range(-4, 4))
	elif sprite.modulate != Color(0,0,0,0):
		#sprite.position.y = -24
		sprite.modulate.r = move_toward(sprite.modulate.r, 1, delta / 4)
		sprite.modulate.g = move_toward(sprite.modulate.g, 1, delta / 4)
		sprite.modulate.b = move_toward(sprite.modulate.b, 1, delta / 4)
		#sprite.rotation_degrees = 0
	
	if dead:
		if on_floor:
			velocity.y = randi_range(200, -2000)
			velocity.x = randi_range(-2000, 2000)
		if on_wall:
			velocity.y = randi_range(200, -2000)
			velocity.x = randi_range(-2000, 2000)
	# hack - [end]
	
	# Handle JUST (1/3):
	just_queue() # The word "just" refers to something very specific. Check out the function for the explanation.
	# Handle JUST (2/3):
	just_update() # The word "just" refers to something very specific. Check out the function for the explanation.
	
	if on_wall:
		Globals.spawn_scenes(World, Globals.scene_effect_dust, 1, position + Vector2(24 * Globals.player_direction_x_active, 0), 4, Color(0, 1, 0, 0), Vector2(-0.5, -0.5), 10)
	
	update_can() # The word "can" does too.
	
	get_basic_player_values()
	
	if debug_movement:
		handle_debug_movement(delta)
	
	else:
		handle_gravity(delta)
		
		if not dead:
			if can_jump or can_air_jump:
				if not handle_jump(delta):
					if can_wall_jump:
						handle_wall_jump()
					else:
						handle_wall_run(delta)
		
		if on_floor : handle_walk(delta)
		handle_air_acceleration(delta)
	
	
	handle_attack_main()
	handle_attack_secondary()
	
	handle_friction(delta)
	handle_air_slowdown(delta)
	
	if not debug_movement:
		# DASHING LOGIC
		if can_dash:
			handle_dash()
		
		# CROUCHING LOGIC
		if ability_crouch:
			handle_crouch()
	
	
	if not debug_movement:
		if not stuck:
			if flight:
				handle_flight(delta)
			
			if not block_movement_full:
				move_and_slide() #MAIN MOVEMENT
				handle_inside_zone()
		
		update_sprite()
	
	if not state_damage and not dead and velocity.y == 0 and is_on_floor() and not on_floor and not state_shoot and not crouch_walk_active and not crouch_active:
		if not attack_melee_active : sprite.play("idle")
	
	handle_spawn_dust()
	
	handle_manual_player_death()
	
	#HANDLE STUCK IN WALL
	handle_stuck()
	
	# Handle JUST (3/3):
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
	animation_player_sprite_color.play("flash_white_faint")
	
	dash_active = false
	
	if can_stand_up == 0:
		collision_main.shape.extents = collision_size
		collision_main.position = collision_pos_offset
		
		collision_hitbox.shape.extents = hitbox_size
		collision_hitbox.position = hitbox_pos_offset
		
		can_dash = true
		
		state_crouch = 0
		state_crouch_walk = 0
	
	else:
		await safe_standUp
		collision_main.shape.extents = collision_size
		collision_main.position = collision_pos_offset
		
		collision_hitbox.shape.extents = hitbox_size
		collision_hitbox.position = hitbox_pos_offset
		
		can_dash = true
		
		state_crouch = 0
		state_crouch_walk = 0
		#state_crouch_walk = 1
	
	raycast_top.enabled = true

func _on_timer_dash_speed_block_timeout():
	dash_speed_block_active = false
	c_dash_end_slowdown_enable.start()

func _on_cooldown_dash_end_slowdown_enable_timeout():
	if not dash_end_slowdown_canceled:
		c_dash_end_slowdown_disable.start()
		dash_end_slowdown_active = true
		sprite.play_backwards("crouch")
	
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
	if not on_floor : state_jump = 1
	
	if not on_floor and not dash_active or dash_end_slowdown_active:
		if not flight:
			if Input.is_action_pressed("jump"):
				if block_movement : return
				if inside_water:
					velocity.y += fall_speed * 0.85 * delta * gravity_multiplier * inside_water_multiplier_x
				else:
					velocity.y += fall_speed * 0.85 * delta * gravity_multiplier
			
			elif Input.is_action_pressed("move_down"):
				if block_movement : return
				if inside_water:
					velocity.y += fall_speed * 2.0 * delta * gravity_multiplier * inside_water_multiplier_x
				else:
					velocity.y += fall_speed * 4.0 * delta * gravity_multiplier
			
			else:
				if not recently_bounced:
					if velocity.y < -200 : velocity.y = -200
				
				if inside_water:
					velocity.y += fall_speed * 1 * delta * gravity_multiplier * inside_water_multiplier_x
				else:
					velocity.y += fall_speed * 1 * delta * gravity_multiplier
	
	
	if not dead and dash_active:
		if not dash_speed_block_active or dash_end_slowdown_active:
			t_dash_speed_block.start()
		
		dash_speed_block_active = true
		
		#if started_dash == false or dash_slowdown:
			#velocity.x = 0
		
		if Input.is_action_pressed("move_down"):
			if block_movement : return
			velocity.y += fall_speed * delta * 4 * gravity_multiplier
			velocity.x = move_toward(velocity.x, 800 * direction_x, 6000 * delta)
		
		else:
			
			if Input.is_action_pressed("jump"):
				if block_movement : return
				velocity.y += fall_speed * delta * 1 * gravity_multiplier
				velocity.x = move_toward(velocity.x, 800 * direction_x, 6000 * delta)
			else:
				velocity.y += fall_speed * delta * 2.5 * gravity_multiplier
				velocity.x = move_toward(velocity.x, 800 * direction_x, 6000 * delta)
		
		if abs(velocity.x) > 500:
			state_crouch_walk = 1
			state_crouch = 0
		else:
			state_crouch_walk = 0
			state_crouch = 1
	
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
	if direction_x and not state_damage:
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
	if attack_melee_active : return
	if sprite.animation == "crouch" and sprite.frame != 0: return
	
	var queued_anim = "idle"
	var x = 0
	
	if state_idle >= x : queued_anim = "idle"; x = state_idle
	if state_walk >= x : queued_anim = "walk"; x = state_walk
	if state_jump >= x : queued_anim = "jump"; x = state_jump
	if state_fall >= x : queued_anim = "fall"; x = state_fall
	if state_shoot >= x : queued_anim = "shoot"; x = state_shoot
	if state_damage >= x : queued_anim = "damage"; x = state_damage
	if state_crouch >= x : queued_anim = "crouch"; x = state_crouch
	if state_crouch_walk >= x : queued_anim = "crouch_walk"; x = state_crouch_walk
	if state_death >= x : queued_anim = "death"; x = state_death
	
	if not sprite.animation == queued_anim : sprite.play(queued_anim)


func _on_cooldown_state_idle_timeout(): # Walking anim weight is disabled here, allowing for the Idle anim to take over after a delay after the player stops moving horizontally.
	if on_floor : state_walk = 0
	Globals.dm("The 'Walk' state's weight has been set to 0, after a short delay after the player stopped moving.")


func handle_friction(delta):
	if not direction_x and not inside_wind:
		velocity.x = move_toward(velocity.x, 0, friction * inside_water_multiplier_x * delta)


func handle_air_slowdown(delta):
	if direction_x == 0 and not on_floor:
		velocity.x = move_toward(velocity.x, 0, air_slowdown * delta)


func handle_air_acceleration(delta):
	if is_on_floor() : return
	
	if direction_x != 0:
		# Reduce slowdown while under influence of heavy wind (conveyor belts).
		if just_left_wind:
			velocity.x = move_toward(velocity.x, speed * 4 * direction_x, air_acceleration / 3 * delta)
		# Bounced off an entity.
		elif recently_bounced:
			velocity.x = move_toward(velocity.x, speed * direction_x, air_acceleration * delta)
		# Normal
		else:
			velocity.x = move_toward(velocity.x, speed * direction_x, air_acceleration * delta)
	
	if not recently_bounced:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			if block_movement : return
			velocity.x *= 0.75


func handle_walk(delta):
	handle_move_x(delta)


func handle_move_x(delta):
	if not direction_x:
		state_jump = 0
		state_idle = 1
		return
	
	if not inside_wind : velocity.x = move_toward(velocity.x, direction_x * speed, acceleration * delta * crouch_walk_multiplier * inside_water_multiplier_x)
	else:
		if direction_x == inside_wind_direction_x:
			velocity.x = move_toward(velocity.x, direction_x * speed * 4, acceleration * delta * crouch_walk_multiplier * inside_water_multiplier_x)
		else:
			velocity.x = move_toward(velocity.x, direction_x * speed / 2, acceleration * delta * crouch_walk_multiplier * inside_water_multiplier_x)
	
	if not recently_bounced:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			if block_movement : return
			velocity.x *= 0.75
	
	state_walk = 1
	state_idle = 0


func handle_jump(delta):
	if just_landed:
		if dash_active and can_jump:
			dash_just_landed = false
			dash_end_slowdown_await_jump = true
			%timer_await_jump.start()
	
	if dash_end_slowdown_await_jump and is_on_floor() and Input.is_action_just_pressed("jump"):
		if block_movement : return
		dash_end_slowdown_await_jump = false
		dash_end_slowdown_canceled = true
		velocity.x = base_speed * 6 * direction_x
		Globals.spawn_scenes(World, Globals.scene_effect_dust, 1, position + Vector2(24 * Globals.player_direction_x_active, 0), 1, Color(0, 1, 0, 0), Vector2(1, 1), 10)
		Globals.spawn_scenes(World, Globals.scene_particle_special, 12, position + Vector2(24 * Globals.player_direction_x_active, 0), 1, Color(0, 1, 0, 0), Vector2(0, 0), 10)
		
		state_jump = 1
		state_crouch = 0
	
	
	# Regular jump:
	if can_jump and on_floor or can_jump and t_leniency_jump.time_left > 0.0:
		
		if Input.is_action_just_pressed("jump"):
			if block_movement : return
			Globals.spawn_scenes(World, Globals.scene_particle_special, 3, position + Vector2(24 * Globals.player_direction_x_active, 64), 8, Color(1, 1, 9, 0), Vector2(-0.6, -0.6), 10)
			Globals.message_debug("player jump")
			can_jump = false
			
			sfx(Globals.sfx_player_jump, 1.0, 1.0)
			
			if not dash_active:
			
				if Globals.get_random_bool(90) or not direction_x:
					animation_player_sprite_general.stop()
					animation_player_sprite_general.speed_scale = 2
					animation_player_sprite_general.play("jumped")
				
				else:
					animation_player_sprite_general.stop()
					animation_player_sprite_general.speed_scale = 1.5
					
					if direction_x == 1:
						animation_player_sprite_general.play("rotate_right")
					if direction_x == -1:
						animation_player_sprite_general.play("rotate_left")
			
			else:
				animation_player_sprite_general.stop()
				animation_player_sprite_general.speed_scale = 1.5
				
				if direction_x == 1:
					animation_player_sprite_general.play("rotate_right")
				if direction_x == -1:
					animation_player_sprite_general.play("rotate_left")
			
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
			if block_movement : return
			velocity.y = jump_velocity / 2
			Globals.spawn_scenes(World, Globals.scene_effect_dust, 1, position + Vector2(24 * Globals.player_direction_x_active, 0), 1, Color(0, 1, 0, 0), Vector2(0, 0), 10)
		
		if Globals.gameState_debug and Input.is_action_just_pressed("jump") or can_air_jump and Input.is_action_just_pressed("jump") and not Input.is_action_pressed("crouch"):
			if block_movement : return
			Globals.message_debug("player air jump")
			print("player air jump")
			Globals.spawn_scenes(World, Globals.scene_particle_special, 12, position + Vector2(0, 24), 8, Color(0, 1, 0, 0), Vector2(-0.6, -0.6), 10)
			if inside_water:
				velocity.y = jump_velocity * 0.8 * inside_water_multiplier_x
			else:
				velocity.y = jump_velocity * 0.8
			if Globals.player_direction_x : velocity.x = 200 * Globals.player_direction_x
			
			can_air_jump = false
			
			sfx(Globals.sfx_player_jump, 1.0, 1.0)
			
			if Globals.get_random_bool(90) or not direction_x:
				animation_player_sprite_general.stop()
				animation_player_sprite_general.speed_scale = 3
				animation_player_sprite_general.play("air_jumped")
			
			else:
				animation_player_sprite_general.stop()
				animation_player_sprite_general.speed_scale = randf_range(0.75, 2)
				
				if direction_x == 1:
					animation_player_sprite_general.play("rotate_right")
				if direction_x == -1:
					animation_player_sprite_general.play("rotate_left")
			
			dash_end_slowdown_canceled = true
			if dash_end_slowdown_await_jump:
				velocity.x += 500 * direction_x
			
			state_jump = 1
			
			return true
	
	return false


func handle_wall_jump():
	if not is_on_wall_only() and t_leniency_wall_jump.time_left <= 0.0 : return
	
	if Input.is_action_just_pressed("jump") and can_wall_jump:
		if block_movement : return
		Globals.message_debug("player wall jump")
		print(("player wall jump"))
		
		if Globals.player_direction_x:
			velocity.x = on_wall_normal.x * speed
		else:
			velocity.x = on_wall_normal.x * speed / 2
		
		if inside_water:
			velocity.y = jump_velocity * 1 * inside_water_multiplier_x
		else:
			velocity.y = jump_velocity * 1
		
		Globals.spawn_scenes(World, Globals.scene_particle_special, 4, position + Vector2(24 * -Globals.player_direction_x_active, 40), 4, Color(0, 1, 0, 0), Vector2(0, 0), 10)
		Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 4, position + Vector2(24 * -Globals.player_direction_x_active, 40), 4, Color(0, 1, 0, 0), Vector2(-0.5, -0.5), 10)
		
		can_wall_jump = false
		
		sfx(Globals.sfx_player_wall_jump, 1.0, 1.0)
		
		var x = randi_range(0, 1)
		if x or not direction_x:
			animation_player_sprite_general.stop()
			animation_player_sprite_general.speed_scale = 3
			animation_player_sprite_general.play("air_jumped")
		else:
			animation_player_sprite_general.stop()
			animation_player_sprite_general.speed_scale = 1
			if direction_x == -1:
				animation_player_sprite_general.play("rotate_left")
			if direction_x == 1:
				animation_player_sprite_general.play("rotate_right")


# Player damage (Received by player).
#func health_decrease(value):
	#if invulnerable or invincible or dead:
		#sfx(Globals.sfx_player_damage, 1.0, 0.0)
		#state_damage = true
		#t_state_damage.start()


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
	state_shoot = 0


# Player crouch/dash logic:
func handle_crouch():
	if can_dash and is_on_floor():
		if Input.is_action_pressed("crouch") and on_floor:
			if block_movement : return
			Globals.message_debug("player crouch")
			c_crouch_walk.start()
			c_crouch_walk_correct_collision.start()
			crouch_active = true
			state_crouch = 1
			if not (sprite.animation == "crouch" and sprite.frame == 4):
				sprite.play("crouch")
			
			crouch_walk_multiplier = 0.6
			if ability_crouch_walk:
				speed = base_speed * crouch_walk_multiplier
			else:
				speed = 0
			
			raycast_top.enabled = false
		
		
		if crouch_walk_active:
			state_crouch_walk = 1
			crouch_active = false
			
			crouch_walk_multiplier = 0.4
			speed = base_speed * crouch_walk_multiplier
			
			raycast_top.enabled = false
	
	if Input.is_action_just_released("crouch"):
		if block_movement : return
		collision_main.shape.extents = collision_size
		collision_main.position = collision_pos_offset
		
		collision_hitbox.shape.extents = hitbox_size
		collision_hitbox.position = hitbox_pos_offset
		
		
		crouch_active = false
		crouch_walk_active = false
		c_crouch_walk.stop()
		c_crouch_walk_correct_collision.stop()
		speed = base_speed
		crouch_walk_multiplier = 1
		raycast_top.enabled = true
		state_crouch_walk = 0
		state_crouch = 0

func _on_cooldown_crouch_walk_timeout():
	if ability_crouch_walk:
		Globals.message_debug("Player is crouching.")
		crouch_walk_active = true

func _on_cooldown_crouch_walk_correct_collision_timeout():
	collision_main.shape.extents = dash_hitbox_size
	collision_main.position = dash_hitbox_pos_offset
	
	collision_hitbox.shape.extents = dash_hitbox_size
	collision_hitbox.position = dash_hitbox_pos_offset

func handle_dash():
	if can_dash and Input.is_action_just_pressed("dash") and is_on_floor() and dash_active == false and not crouch_walk_active and not crouch_active:
		if block_movement : return
		dash()

func dash():
	Globals.message_debug("Player is now performing a dash.")
	
	if Globals.player_direction_x : velocity.x = -500 * Globals.player_direction_x_active
	else : velocity.x = 1000 * Globals.player_direction_x_active
	
	dash_active = true
	can_dash = false
	dash_end_slowdown_canceled = false
	t_dash.start()
	state_crouch = 1
	
	collision_main.shape.extents = dash_hitbox_size
	collision_main.position = dash_hitbox_pos_offset
	
	collision_hitbox.shape.extents = dash_hitbox_size
	collision_hitbox.position = dash_hitbox_pos_offset
	
	raycast_top.enabled = false


func _on_timer_jump_timeout():
	pass


func _on_hitbox_main_area_entered(area):
	pass


func saveState_loaded():
	camera.position_smoothing_enabled = false
	await get_tree().create_timer(0.1, false).timeout
	camera.position_smoothing_enabled = true
	
	collision_main.shape.extents = collision_size
	collision_main.position = collision_pos_offset
	
	collision_hitbox.shape.extents = Vector2(16, 40)
	collision_hitbox.position = Vector2(0, 0)
	
	dead_anim_active = false
	
	
	Overlay.animation("fade_black", true, true, 1.0)


func _on_cooldown_effect_dust_timeout():
	spawn_dust_effect = true


func _on_cooldown_just_landed_timeout():
	recently_landed = false
	q_just_landed = true


# UNUSED!!!
func _on_await_jump_timer_timeout():
	dash_end_slowdown_await_jump = false


#TRANSFORMATIONS
#var player_bird_scene = load("res://Other/Scenes/player_bird.tscn")
#var player_chicken_scene = load("res://Other/Scenes/player_chicken.tscn")
#var player_rooster_scene = load("res://Other/Scenes/player.tscn")

#func transformInto_rooster():
	#call_deferred("deferred_spawnRooster")
	#call_deferred("delete")
#
#func transformInto_bird():
	#call_deferred("deferred_spawnBird")
	#call_deferred("delete")
#
#func transformInto_chicken():
	#call_deferred("deferred_spawnChicken")
	#call_deferred("delete")
#
#
#func deferred_spawnRooster():
	#remove_from_group("player")
	#remove_from_group("player_root")
	#camera.remove_from_group("player_camera")
	#var player_rooster = player_rooster_scene.instantiate()
	#player_rooster.position = position
	#World.add_child(player_rooster)
#
#func deferred_spawnBird():
	#remove_from_group("player")
	#remove_from_group("player_root")
	#camera.remove_from_group("player_camera")
	#var player_bird = player_bird_scene.instantiate()
	#player_bird.position = position
	#World.add_child(player_bird)
#
#func deferred_spawnChicken():
	#remove_from_group("player")
	#remove_from_group("player_root")
	#camera.remove_from_group("player_camera")
	#var player_chicken = player_chicken_scene.instantiate()
	#player_chicken.position = position
	#World.add_child(player_chicken)


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


func _on_dash_check_timeout():
	if can_stand_up == 0:
		safe_standUp.emit()


func handle_attack_main():
	#if Globals.weapon_main == "none" : return # Unneeded performance hit.
	handle_attack_melee()

# Attack (main and secondary): - [START]
func handle_attack_secondary():
	if Input.is_action_pressed("e"):
		if block_movement : return
		if Input.is_action_just_pressed("decrease"):
			if block_movement : return
			var new_weapon_name : String = Globals.suffix_increase(Globals.weapon_secondary, -1)
			var new_suffix : String = Globals.get_suffix(new_weapon_name)
			
			if Globals.get_suffix(Globals.weapon_main) != "none":
				if int(new_suffix) > 4 or int(new_suffix) < 1 or new_suffix == "none":
					Globals.weapon_secondary = Globals.suffix_increase(Globals.weapon_secondary, 0)
				else:
					Globals.weapon_secondary = Globals.weapon_secondary
			
			Globals.spawn_message_object(Globals.weapon_secondary)
		
		elif Input.is_action_just_pressed("increase"):
			if block_movement : return
			var new_weapon_name: String = Globals.suffix_increase(Globals.weapon_secondary, 1)
			var new_suffix : String = Globals.get_suffix(new_weapon_name)
			
			if Globals.get_suffix(Globals.weapon_main) != "none":
				print(Globals.suffix_increase(Globals.weapon_secondary, 1))
				if int(new_suffix) > 4 or int(new_suffix) < 1:
					Globals.weapon_secondary = Globals.suffix_increase(Globals.weapon_secondary, 0)
				else:
					Globals.weapon_secondary = new_weapon_name
			else:
				Globals.weapon_secondary = Globals.weapon_secondary + "_1"
			
			Globals.spawn_message_object(Globals.weapon_secondary)
	
	if Input.is_action_just_pressed("e"):
		if block_movement : return
		Globals.weapon_secondary = Globals.qs_list_weapon_name.pick_random()
		while Globals.get_suffix(Globals.weapon_secondary) != "none" : Globals.weapon_secondary = Globals.qs_list_weapon_name.pick_random()
		
		Globals.spawn_message_object(Globals.weapon_secondary)
	
	if block_movement : return
	elif dead : return
	elif Globals.weapon_blocked : return
	
	if Input.is_action_pressed("attack_secondary"):
		if block_movement : return
		elif Globals.weapon_secondary == "none" : return
		
		if not Globals.weapon_secondary == "tie_charged":
		
			if c_attack.time_left > 0.0 : return
			c_attack.start()
			
			#if Globals.weapon is Dictionary:
			attack_main_spawn_scene("res://Projectiles/" + Globals.weapon_secondary + ".tscn")
			
			
			#SHOOTING ANIMATION
			state_shoot = 1
			t_state_shoot.start()
			
			sfx_manager.sfx_play(Globals.sfx_slash)
			
			if not state_damage:
				if direction_x != 0:
					sprite.flip_h = (direction_x < 0)
		
		elif Input.is_action_just_pressed("attack_secondary"):
			if block_movement : return
			if c_attack.time_left > 0.0 : return
			c_attack.wait_time = 0.1
			c_attack.start()
			
			var scene = load("res://Projectiles/tie_charged.tscn").instantiate()
			
			scene.set_player_attack_cooldown = true
			scene.family = "Player"
			
			add_child(scene)
			
			if not state_damage:
				if direction_x != 0:
					sprite.flip_h = (direction_x < 0)
			
			#SHOOTING ANIMATION
			state_shoot = 1
			t_state_shoot.start()
			
			sfx_manager.sfx_play(Globals.sfx_slash)

func attack_main_spawn_scene(filepath):
	if not FileAccess.file_exists(filepath) : filepath = "res://Projectiles/iceball_shard_small.tscn"
	
	var scene = load(filepath).instantiate()
	
	if Globals.weapon_main == "custom":
		for property_name in Globals.weapon:
			if property_name == "none" : continue
			
			scene.set(property_name, Globals.weapon[property_name])
	
	scene.position = position + attack_pos_offset * Globals.player_direction_x_active
	#scene.set_player_attack_cooldown = true
	c_attack.wait_time = scene.set_player_attack_cooldown_value
	scene.collectable = false
	scene.family = "Player"
	scene.direction_x = Globals.player_direction_x_active
	scene.on_spawn_copy_direction_x_active_player = true
	scene.always_active = true
	if not scene.on_spawn_copy_direction_x_player and not scene.on_spawn_copy_direction_x_active_player:
		scene.on_spawn_velocity.x *= scene.direction_x
	
	if Input.is_action_pressed("move_down"):
		if block_movement : return
		scene.direction_y = 1
		scene.direction_x = 0
		scene.movement_type = "normal"
		scene.ignore_gravity = false
		scene.velocity.y = scene.jump_velocity_y + velocity.y
		scene.velocity.y += velocity.y
		scene.velocity.x = 0
		scene.on_spawn_velocity.x /= 4
		if scene.on_spawn_velocity.x <= 250 : scene.on_spawn_velocity.x = 0
		scene.on_spawn_velocity.y = scene.velocity.y
		scene.on_spawn_max_speed = false
		scene.always_max_speed = false
	
	elif Input.is_action_pressed("move_up"):
		if block_movement : return
		scene.direction_y = -1
		scene.direction_x = Globals.player_direction_x_active
		scene.movement_type = "normal"
		scene.ignore_gravity = false
		scene.velocity = Vector2(scene.jump_velocity_x * Globals.player_direction_x_active, scene.jump_velocity_y)
		scene.velocity.y += velocity.y * 2
		scene.on_spawn_max_speed = false
		scene.always_max_speed = false
	
	if scene.on_spawn_velocity_range != [Vector2(-1, -1), Vector2(-1, -1)]:
		scene.on_spawn_velocity_range[0].x *= scene.direction_x
		scene.on_spawn_velocity_range[1].x *= scene.direction_x
		scene.on_spawn_velocity_range[0].y *= -scene.direction_y
		scene.on_spawn_velocity_range[1].y *= -scene.direction_y
	
	World.add_child(scene)
	
	if not Globals.weapon_secondary == "tie_charged":
		var entity_bg_sprite : AnimatedSprite2D = load("res://Other/Scenes/sprite.tscn").instantiate()
		#scene.sprite.sprite_frames = load("res://Assets/Graphics/sprites/packed/projectiles/tie.tres")
		entity_bg_sprite.z_index = -4
		entity_bg_sprite.sprite_frames = load("res://Assets/Graphics/sprites/packed/projectiles/tie.tres")
		entity_bg_sprite.play()
		entity_bg_sprite.modulate = scene.tie_add_modulate
		scene.sprite.add_child(entity_bg_sprite)
		#scene.sprite.scale /= 2
		#scene.sprite_start_scale /= 2
		#scene.effect_grow_target_scale /= 2
	
	Globals.projectile_shot.emit()

func secondaryAttack_spawn_scene(filepath):
	pass


func _on_cooldown_attack_timeout():
	pass

# Secondary:
func _on_cooldown_secondaryAttack_timeout():
	pass

# Attack (main and secondary): - [END]


@onready var raycast_top = $raycast_top
@onready var raycast_bottom = $raycast_bottom
@onready var raycast_middle = $raycast_middle

var stuck = false

func handle_stuck():
	if debug_movement or Globals.gameState_debug : return
	
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
	if debug_movement or Globals.gameState_debug : return
	
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
func handle_debug_movement(delta):
	camera.effect(Vector2(0, 0), Vector2(0.75, 0.75), 0, 1)
	camera.position_smoothing_speed = 5.0
	
	if Input.is_action_pressed("LMB"):
		position = get_global_mouse_position()
		velocity.y = 0
	
	if Input.is_action_pressed("move_right"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.x += 250 * delta
		
		elif Input.is_action_pressed("dash"):
			global_position.x += 2000 * delta
		
		else:
			global_position.x += 1000 * delta
	
	if Input.is_action_pressed("move_left"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.x -= 250 * delta
		
		elif Input.is_action_pressed("dash"):
			global_position.x -= 2000 * delta
		
		else:
			global_position.x -= 1000 * delta
	
	if Input.is_action_pressed("move_up"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.y -= 250 * delta
		
		elif Input.is_action_pressed("dash"):
			global_position.y -= 2000 * delta
		
		else:
			global_position.y -= 1000 * delta
	
	if Input.is_action_pressed("move_down"):
		if Input.is_action_pressed("attack_secondary"):
			global_position.y += 250 * delta
			
		elif Input.is_action_pressed("dash"):
			global_position.y += 2000 * delta
		
		else:
			global_position.y += 1000 * delta
	
	crouch_active = false
	crouch_walk_active = false


# True if player is currently touching the specified surface.
var on_floor = false
var on_wall = false

func get_basic_player_values():
	if not dead and not block_movement:
		if block_movement : return
		direction_x = Input.get_axis("move_left", "move_right")
	
	else:
		direction_x = 0
	
	Globals.player_direction_x = direction_x
	if direction_x : Globals.player_direction_x_active = direction_x
	
	Globals.player_position = position
	Globals.player_velocity = velocity
	
	
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


func handle_spawn_dust():
	if on_floor and direction_x and spawn_dust_effect:
		spawn_dust_effect = false
		$cooldown_effect_dust.start()
		
		var dust = Globals.scene_effect_dust.instantiate()
		dust.position = Globals.player_position - Vector2(0, -48)
		get_parent().add_child(dust)
		
	elif not on_floor:
		spawn_dust_effect = true
		$cooldown_effect_dust.stop()


# Zones (water, wind, bouncy, etc.)
var inside_wind = 0 # If above 0, the player is affected by wind.
var inside_wind_direction_x : int = 0
var inside_wind_direction_y : int = 0
var inside_wind_multiplier_y = 0
var inside_wind_multiplier_x = 0

var inside_water = 0
var inside_water_multiplier_x = 1.0
var inside_water_multiplier_y = 1.0

func handle_inside_zone():
	if inside_wind:
		velocity.x += inside_wind_direction_x * 5 * inside_wind_multiplier_x
		velocity.y += inside_wind_direction_y * 5 * inside_wind_multiplier_y
		recently_left_wind = false
	else:
		if abs(velocity.x) > 1000 and not recently_left_wind:
			recently_left_wind = true
			t_recently_left_wind.start()
			recently_left_wind = true
			Globals.message_debug("The player's 'just_left_wind' property is now true (because player left a conveyor belt).")


func handle_manual_player_death():
	if Input.is_action_just_pressed("back"):
		if block_movement : return
		Globals.player_damage.emit(-99999, self)


func handle_flight(delta):
	if Input.is_action_pressed("jump"):
		if block_movement : return
		velocity.y = move_toward(velocity.y, jump_velocity, delta * acceleration / 2)
	elif Input.is_action_pressed("crouch"):
		if block_movement : return
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


func _on_block_movement_full_timeout() -> void:
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


func reduce_health(value : int, source : Node):
	Globals.player_health += value
	if is_instance_valid(source) and not source.is_in_group("Player"):
		if not "can_move" in source or not source.can_move or source.velocity == Vector2(0, 0):
			if position.x > source.position.x:
				velocity.x = 500
			else:
				velocity.x = -500
		else:
			velocity.x = source.velocity.x * 2
			velocity.y = -500
	
	invincible = true
	t_invincible.start()
	sfx(Globals.sfx_electric, 1.0, randf_range(0.5, 1.5))
	sprite.modulate = Color.DARK_RED
	
	if dead : return
	
	if Globals.player_health <= 0:
		dead = true
		World.retry_checkpoint()
		Globals.player_health = health_value
		
		if Globals.World.level_type == "debug" : Globals.message("You can't die in these levels! Just have some fun <3 (also press CTRL + R to restart a level)")
		
		velocity.x = randi_range(-2000, 2000)
		velocity.y = randi_range(-500, -3000)

func increase_health(value):
	Globals.player_health += value
	invincible = true
	t_invincible.start()
	sfx(Globals.sfx_player_heal, 1.0, 0.0)

func kill():
	Globals.player_health = 0
	dead = true
	sfx(Globals.sfx_player_death, 1.0, 0.0)
	reduce_health(9999, self)


func sfx(file, volume, pitch):
	sfx_manager.sfx_play(file, volume, pitch)


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
		if on_floor:
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
	animation_player_sprite_general.play("RESET")
	
	state_jump = 0

func on_just_bounced():
	recently_bounced = true
	t_recently_bounced.start()
	can_air_jump = true
	can_wall_jump = true
	sprite.modulate.g = 0.8


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
	dash_end_slowdown_await_jump = false

func _on_timer_state_shoot_timeout() -> void:
	state_shoot = 0


func _on_timer_state_damage_timeout() -> void:
	state_damage = 0


func _on_timer_invincible_timeout() -> void:
	invincible = false


var wall_run_speed_multiplier : float = 1.0

func handle_wall_run(delta):
	if not on_wall:
		state_crouch_walk = 0
		wall_run_speed_multiplier = 1.0
		return
	
	if Input.is_action_pressed("move_up"):
		if block_movement : return
		position.y += -4 * wall_run_speed_multiplier * (delta * 100)
		wall_run_speed_multiplier += delta * 2
		
		state_crouch_walk = 10
		
		if wall_run_speed_multiplier >= 2.0:
			wall_run_speed_multiplier = 1.0
			can_wall_jump = true
			
			if Globals.player_direction_x:
				velocity = Vector2(800 * on_wall_normal.x, -600)
			else:
				velocity = Vector2(400 * on_wall_normal.x, -600)
			
			state_crouch_walk = 0
			if on_wall_normal.x < 0: animation_player_sprite_general.play("rotate_left")
			elif on_wall_normal.x > 0: animation_player_sprite_general.play("rotate_right")
		
		else:
			velocity.y = 0


func handle_damage(value : int = -1, source : Node = self):
	Globals.player_damage.emit(value, source) # Sends a signal to the health bar ui element.
	
	if direction_x_active != 0:
		sprite.flip_h = (direction_x_active > 0)
	
	if Globals.player_direction_x_active > 0 : sprite.rotation_degrees = 45
	else : sprite.rotation_degrees = -45
	
	state_damage = 1
	block_movement_full = true
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.block_movement = true
	Globals.Player.camera.effect((position - Globals.player_position) * 2, Vector2(2.5, 2.5), randi_range(-15, 15), 1)
	await get_tree().create_timer(0.5, true).timeout
	Globals.Player.camera.effect(Vector2(0, 0), Vector2(1, 1), 0, 1)
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.block_movement = false
	block_movement_full = false
	state_damage = 0
	sprite.rotation_degrees = 0
	
	if not is_instance_valid(source) : return
	
	if source.position.x > position.x : velocity.x = -750
	elif source.position.x < position.x : velocity.x = 750
	on_just_bounced()
	velocity.y = -500


var attack_melee_active : bool = false
@onready var timer_block_attack_melee: Timer = $attack_melee/timer_block_attack_melee
@onready var timer_end_attack_melee: Timer = $attack_melee/timer_end_attack_melee
@onready var timer_windup: Timer = $attack_melee/timer_windup
@onready var attack_melee_attack: Node2D = $attack_melee/attack
@onready var attack_melee_hitbox: Area2D = $attack_melee/attack/hitbox
@onready var attack_melee_collision: CollisionShape2D = $attack_melee/attack/hitbox/collision
@onready var attack_melee_decoration_collision_particles: Node2D = $attack_melee/attack/hitbox/collision/decoration_collision_particles

var attack_throw_active : bool = false
@onready var timer_attack_throw: Timer = $attack_throw/timer_attack_throw

@onready var hitbox_extra: Area2D = $attack_melee/attack/hitbox_extra
@onready var collision_extra: CollisionShape2D = $attack_melee/attack/hitbox_extra/collision_extra
@onready var decoration_collision_extra_particles: Node2D = $attack_melee/attack/hitbox_extra/collision_extra/decoration_collision_extra_particles

func attack_melee():
	if timer_block_attack_melee.time_left > 0.0 : return
	
	attack_melee_decoration_collision_particles.visible = true
	
	sprite.stop()
	
	if attack_melee_current_id != "none":
		hitbox_extra.monitorable = false
		hitbox_extra.monitoring = false
		decoration_collision_extra_particles.visible = false
	
	if attack_melee_current_id == "none":
		#Globals.spawn_message_object(str("attack_melee_current_id was set to 'smash_down' (changed from %s)." % attack_melee_current_id), World, position + Vector2(0, -400))
		attack_melee_current_id = "smash_down"
		attack_melee_set_hitbox(Vector2(192, 96), Vector2(64, 32))
		
		sprite.play("smash_down")
		timer_windup.wait_time = 0.33
		timer_block_attack_melee.wait_time = 0.25
		timer_end_attack_melee.wait_time = 2.5
	
	elif attack_melee_current_id == "smash_down" or attack_melee_current_id == "spin_down_ender":
		#Globals.spawn_message_object(str("attack_melee_current_id was set to 'kick_up' (changed from %s)." % attack_melee_current_id), World, position + Vector2(0, -400))
		attack_melee_current_id = "kick_up"
		attack_melee_set_hitbox(Vector2(128, 192), Vector2(64, -32))
		
		sprite.play("kick_up")
		timer_windup.wait_time = 0.25
		timer_block_attack_melee.wait_time = 0.5
		timer_end_attack_melee.wait_time = 1.0
	
	elif attack_melee_current_id == "kick_up":
		#Globals.spawn_message_object(str("attack_melee_current_id was set to 'slide' (changed from %s)." % attack_melee_current_id), World, position + Vector2(0, -400))
		attack_melee_current_id = "slide"
		attack_melee_set_hitbox(Vector2(128, 128), Vector2(64, 0))
		
		dash()
		sprite.play("slide")
		#sprite.rotation_degrees = -45
		#sprite.position.y = -20
		#sprite.modulate = Color.BLUE
		timer_windup.wait_time = 0.25
		timer_block_attack_melee.wait_time = 0.5
		timer_end_attack_melee.wait_time = 2.5
		
	
	elif attack_melee_current_id == "slide":
		#Globals.spawn_message_object(str("attack_melee_current_id was set to 'smash_down' (changed from %s)." % attack_melee_current_id), World, position + Vector2(0, -400))
		attack_melee_current_id = "smash_down"
		attack_melee_set_hitbox(Vector2(256, 128), Vector2(64, 0))
		
		sprite.play("smash_down")
		timer_windup.wait_time = 0.25
		timer_block_attack_melee.wait_time = 0.5
		timer_end_attack_melee.wait_time = 1.5
	
	attack_melee_active = true
	
	timer_windup.start()
	timer_block_attack_melee.start()
	timer_end_attack_melee.start()
	spawn_messages_timers()
	
	for entity in attack_melee_hitbox.get_overlapping_areas():
		var target : Node = entity.get_parent()
		if target.is_in_group("entity"):
			target.attack_melee_block_movement = false
	
	await get_tree().create_timer(0.15, true).timeout
	
	collision_extra.disabled = false
	hitbox_extra.monitorable = true
	hitbox_extra.monitoring = true
	decoration_collision_extra_particles.visible = true
	hitbox_extra.scale.x = Globals.player_direction_x_active

func stop_attack_melee():
	hitbox_extra.monitorable = false
	hitbox_extra.monitoring = false
	decoration_collision_extra_particles.visible = false
	
	attack_melee_active = false
	attack_melee_current_id = "none"
	
	attack_melee_decoration_collision_particles.visible = false
	
	sprite.stop()
	sprite.play("walk")
	
	sprite.rotation = 0
	sprite.position.y = -40
	#sprite.modulate = Color.RED

var attack_melee_current_id : String = "none"
var attack_melee_damage_value : int = 25 # This value is often changed right before an attack.

func handle_attack_melee(): # The word "handle" refers to a function being executed every frame.
	if Input.is_action_just_pressed("attack_main"):
		if block_movement : return
		attack_melee()
	
	attack_melee_hitbox.scale.x = Globals.player_direction_x_active
	attack_melee_decoration_collision_particles.visible = attack_melee_active and timer_windup.time_left == 0.0 and timer_end_attack_melee.time_left > 0.0 # Will be true if the windup timer is finished and the attack timer is active.
	
	if not attack_melee_active : return
	
	if attack_melee_current_id != "smash_down":
		hitbox_extra.monitorable = false
		hitbox_extra.monitoring = false
		decoration_collision_extra_particles.visible = false
	
	if attack_melee_current_id == "smash_down" and not sprite.is_playing():
		if Input.is_action_pressed("attack_main"):
			if block_movement : return
			#Globals.spawn_message_object(str("attack_melee_current_id was set to 'spin_down' (changed from %s)." % attack_melee_current_id), World, position + Vector2(0, -400))
			attack_melee_current_id = "spin_down"
			attack_melee_set_hitbox(Vector2(128, 128), Vector2(64, 0))
		
		else:
			stop_attack_melee()
	
	if attack_melee_current_id == "spin_down":
		if Input.is_action_pressed("attack_main"):
			if block_movement : return
			sprite.play("spin_down")
		else:
			#Globals.spawn_message_object(str("attack_melee_current_id was set to 'spin_down_ender' (changed from %s)." % attack_melee_current_id), World, position + Vector2(0, -400))
			attack_melee_current_id = "spin_down_ender"
			attack_melee_set_hitbox(Vector2(64, 32), Vector2(0, -96))
			
			sprite.play("spin_down_ender")
			
			timer_windup.wait_time = 0.25
			timer_block_attack_melee.wait_time = 0.25
			timer_end_attack_melee.wait_time = 1
			
			spawn_messages_timers()
			
			timer_windup.start()
			timer_block_attack_melee.start()
			timer_end_attack_melee.start()
	
	# Extra collision:
	if hitbox_extra.monitoring:
		for entity in hitbox_extra.get_overlapping_areas():
			if not hitbox_extra.monitoring : return
			
			var target : Node = entity.get_parent()
			if not "invulnerable" in target : continue
			if not "is_ready" in target : continue
			
			if not target.invulnerable and target.is_ready:
				attack_melee_hit(target, 0.25, Vector2(250, 500), 1.0, 10)
			
			hitbox_extra.monitorable = false
			hitbox_extra.monitoring = false
			decoration_collision_extra_particles.visible = false
	
	# Regular collision:
	if attack_melee_hitbox.monitoring:
		for entity in attack_melee_hitbox.get_overlapping_areas():
			if not attack_melee_hitbox.monitoring : return
			
			if timer_windup.time_left > 0.0 : return
			
			var target : Node = entity.get_parent()
			if not "invulnerable" in target : continue
			if not "is_ready" in target : continue
			
			if target.is_in_group("entity") and not target.invulnerable and not target.collected and not target.is_in_group("entity_editor_preview"):
				if "entity_name" in target : print(target.entity_name)
				if attack_melee_current_id == "smash_down":
					if timer_end_attack_melee.time_left < 2.0:
						# Handle the short kick at the start of smash down.
						attack_melee_hit(target, 0.3, Vector2(600, -350), 0.85, 25)
						if not target.invulnerable and target.is_ready and not target.dead:
							Globals.spawn_scenes(Globals.World, Globals.scene_effect_hit_enemy, 1, position + Vector2(Globals.player_direction_x_active * 96, 0), 4, Color.RED, Vector2(-0.75, -0.75), 10)
							Globals.spawn_scenes(Globals.World, Globals.scene_effect_oneShot_enemy, 1, position + Vector2(Globals.player_direction_x_active * 96, 0), 4, Color.BLUE, Vector2(-0.75, -0.75), 10)
							sfx_manager.sfx_play(Globals.sfx_slash, 1, randf_range(0.85, 1.15))
					
					else:
						attack_melee_hit(target, 0.3, Vector2(600, -350), 0.85, 40)
						if not target.invulnerable and target.is_ready and not target.dead:
							Globals.spawn_scenes(Globals.World, Globals.scene_effect_hit_enemy, 1, position + Vector2(Globals.player_direction_x_active * 64, 32), 4, Color.RED, Vector2(-0.75, -0.75), 10)
							Globals.spawn_scenes(Globals.World, Globals.scene_effect_oneShot_enemy, 1, position + Vector2(Globals.player_direction_x_active * 64, 32), 4, Color.BLUE, Vector2(-0.75, -0.75), 10)
				
				elif attack_melee_current_id == "spin_down":
					attack_melee_hit(target, 0.1, Vector2(100, -100), 0.85, randi_range(25, 30))
				
				elif attack_melee_current_id == "kick_up":
					attack_melee_hit(target, 0.5, Vector2(250, -750), 3, 60)
				
				elif attack_melee_current_id == "slide":
					attack_melee_hit(target, 0.5, Vector2(1200, -400), 3, 75)
					sfx_manager.sfx_play(Globals.sfx_slash, 1, randf_range(0.85, 1.15))

func attack_melee_hit(target : Node, freeze_duration : float = 0.25, add_velocity : Vector2 = Vector2(400, -600), invulnerable_duration_multiplier : float = 0.85, f_damage_value : int = 25):
	#Globals.spawn_message_object(str(timer_block_attack_melee.time_left), World, position + Vector2(200, -0))
	
	if not is_instance_valid(target) : return
	
	decoration_collision_extra_particles.visible = false
	
	if not "timer_invulnerable" in target or not is_instance_valid(target.timer_invulnerable) : return
	if target.invulnerable : return
	if not target.is_ready : return
	if "hittable_if_dead" in target:
		if target.dead and not target.hittable_if_dead : return
	
	target.invulnerable = true
	if invulnerable_duration_multiplier > 1.0 : target.timer_invulnerable.wait_time = freeze_duration * invulnerable_duration_multiplier
	else : target.timer_invulnerable.wait_time = freeze_duration
	target.timer_invulnerable.start()
	
	if target.entity_type == "enemy" or target.entity_type == "box":
		Player.block_movement_full = true
		target.attack_melee_block_movement = true
	
	target.modulate = Color.RED
	
	if target.entity_type == "enemy" or target.entity_type == "box" or target.can_move:
		target.handle_hit(self, f_damage_value)
		
		if Globals.get_random_bool(20) : Globals.spawn_scenes(Globals.World, Globals.scene_particle_star, 1, target.position, 4, Color.BLUE, Vector2(0, 0), 10)
		if Globals.get_random_bool(20) : Globals.spawn_scenes(Globals.World, Globals.scene_particle_special, 1, target.position, 4, Color.BLUE, Vector2(0, 0), 10)
		if Globals.get_random_bool(20) : Globals.spawn_scenes(Globals.World, Globals.scene_particle_special2, 1, target.position, 4, Color.BLUE, Vector2(0, 0), 10)
		sfx_manager.sfx_play(Globals.sfx_slash, 1, randf_range(0.85, 1.15))
		if attack_melee_current_id == "spin_down" : $sfx_manager_spin_down.sfx_play(Globals.sfx_slash, 1, randf_range(0.85, 1.15))
		
	if target.entity_type == "enemy" : await Globals.effect_melee_freeze(clamp(freeze_duration * invulnerable_duration_multiplier, 0.05, 0.75))
	elif target.entity_type == "box" : await get_tree().create_timer(0.25, true).timeout
	
	if not is_instance_valid(target) : Globals.smo("wtf") ; return
	
	if not "timer_invulnerable" in target or not is_instance_valid(target.timer_invulnerable) : return
	
	#if target.entity_type == "enemy" or target.entity_type == "box":
	Player.block_movement_full = false
	target.attack_melee_block_movement = false
	#Globals.smo("unpaused")
	#await get_tree().create_timer(0.1, true).timeout
	
	if target.on_wall : target.velocity = Vector2(-add_velocity.x * randf_range(0.95, 1.05) * Globals.player_direction_x_active, add_velocity.y * randf_range(0.95, 1.05))
	elif target.on_floor : target.velocity = Vector2(add_velocity.x * randf_range(0.95, 1.05) * Globals.player_direction_x_active, 1.25 * add_velocity.y * randf_range(0.95, 1.05))
	else : target.velocity = Vector2(add_velocity.x * randf_range(0.95, 1.05) * Globals.player_direction_x_active, add_velocity.y * randf_range(0.95, 1.05))
	
	target.modulate = Color.WHITE

func attack_throw():
	attack_throw_active = true

func stop_attack_throw():
	attack_throw_active = false
	
	sprite.stop()
	sprite.play("walk")


func _on_timer_attack_throw_timeout() -> void:
	stop_attack_throw()


func _on_timer_end_attack_melee_timeout() -> void:
	stop_attack_melee()

func _on_timer_block_attack_melee_timeout() -> void:
	return

func _on_timer_windup_timeout() -> void:
	return

func spawn_messages_timers():
	return
	#Globals.spawn_message_object(str("windup timer was set to %s." % timer_windup.wait_time), World, position + Vector2(-600, -300))
	#Globals.spawn_message_object(str("block timer was set to %s." % timer_block_attack_melee.wait_time), World, position + Vector2(0, -300))
	#Globals.spawn_message_object(str("end timer was set to %s." % timer_end_attack_melee.wait_time), World, position + Vector2(600, -300))

func attack_melee_set_hitbox(collision_size : Vector2 = Vector2(64, 64), collision_position : Vector2 = Vector2(-1, 0)):
	if collision_size.x != -1 : attack_melee_collision.shape.size.x = collision_size.x
	if collision_size.y != -1 : attack_melee_collision.shape.size.y = collision_size.y
	if collision_position.x != -1 : attack_melee_collision.position.x = collision_position.x
	if collision_position.y != -1 : attack_melee_collision.position.y = collision_position.y


func set_hitbox(state : bool = true):
	hitbox_main.monitorable = state
	hitbox_main.monitoring = state


func debug_info():
	#print(Engine.get_frames_per_second())
	#Globals.spawn_message_object(str(Engine.get_frames_per_second()))
	if Globals.gameState_debug or Globals.debug_mode:
		if Globals.weapon_secondary == "none" : Globals.weapon_secondary = "tie_charged"
