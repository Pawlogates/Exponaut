extends entity_basic

func _ready():
	pass

func _process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta


# The entity's HITBOX has been touched by another entity's MAIN COLLISION.
func _on_hitbox_body_entered(body: Node2D) -> void:
	inside_check_enter(body)


func _on_hitbox_body_exited(body: Node2D) -> void:
	inside_check_exit(body)


# The entity's HITBOX has been touched by another entity's HITBOX.
func _on_hitbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_hitbox_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


# Functionality around entities being inside other entities, which causes them to modify their movement. This is the case when this entity's HITBOX is inside another entity's MAIN COLLISION.
# Note that this does not include behaviors such as the entity being COLLECTED by the player, or being HIT by a projectile.
var inside_player = 0
var inside_projectile = 0
var inside_enemy = 0
var inside_collectible = 0
var inside_box = 0

var is_collidable = true

func inside_check_enter(body):
	if body.is_in_group("Player"):
		inside_player += 1
		if collidable:
			print("Player has entered an entity " + "(" + entity_name + ").")
			collidable = false
			timer_collidable.start()
			
			direction = body.direction
	
	elif body.is_in_group("Player Projectile"):
		projectile_last = body
		inside_projectile += 1
		if collidable:
			print("Player Projectile " + "(" + body.entity_name + "). has entered an entity " + "(" + entity_name + ").")
			collidable = false
			collisionCheck_delay.start()
			
			direction = body.direction
			if body.position.x > position.x:
				direction = 1
			elif body.position.x == position.x and abs(body.velocity.x) < 25:
				direction = 0
				velocity.y = enteredFromAboveAndNotMoving
	
	elif body.is_in_group("Enemy"):
		enemy_last = body
		inside_enemy += 1
		if collidable:
			print("Enemy " + "(" + body.entity_name + "). has entered an entity " + entity_name + ").")
			collidable = false
			collisionCheck_delay.start()
			
			#direction = body.direction
	
	elif body.is_in_group("Collectible"):
		collectible_last = body
		inside_collectible += 1
		if collidable:
			print("Collectible " + "(" + body.entity_name + "). has entered an entity " + entity_name + ").")
			collidable = false
			collisionCheck_delay.start()
			
			#direction = body.direction
	
	elif body.is_in_group("Box"):
		box_last = body
		inside_box += 1
		if collidable:
			print("Box " + "(" + body.entity_name + "). has entered an entity " + entity_name + ").")
			collidable = false
			collisionCheck_delay.start()
			
			#direction = body.direction


func inside_check_exit(body):
	if body.is_in_group("Player"):
		inside_player -= 1
		#direction = body.direction
		print("Player exitted this collectible.")
	
	elif body.is_in_group("Player Projectile"):
		inside_projectile -= 1
		#direction = body.direction
	
	elif body.is_in_group("Enemy"):
		inside_enemy -= 1
		#direction = body.direction
	
	elif body.is_in_group("Collectible"):
		inside_collectible -= 1
		#direction = body.direction
	
	elif body.is_in_group("Box"):
		inside_box -= 1
		#direction = body.direction
	
	
	if not inside_player and not inside_projectile and not inside_enemy:
		direction = 0


# The entity moves (the function is executed every frame) according to its movement type, and only one is active at a time. (This is unlike the other properties, which synergize with eachother to provide a very vast selection of unique object behaviours).

func handle_movement():
	if movement_type_id == 0:
		movement_normal()


#MOVEMENT TYPES
func movement_normal(delta):
	if direction and not dead:
		move_in_direction(delta)
	
	else:
		move_toward_zero_velocity_x(delta)


#FOLLOW PLAYER
func movement_followPlayerX(delta):
	if not dead:
		if can_turn:
			#LevelTransition.info_text_display.display_message(str(can_turn), 0)
			if global_position.x > Globals.player_posX:
				direction = -1
				
			elif global_position.x < Globals.player_posX:
				direction = 1
		
		
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * 3 * delta * ACCELERATION)
	
	else:
		move_toward_zero_velocity_x(delta)


func movement_followPlayerY(delta):
	if global_position.y < Globals.player_posY:
		direction_v = 1
		
	elif global_position.y > Globals.player_posY:
		direction_v = -1
	
	
	if not dead:
		velocity.y = move_toward(velocity.y, direction_v * SPEED, SPEED * ACCELERATION * delta)
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, direction_v * SPEED, SPEED * delta)


func movement_followPlayerXY(delta):
	if not dead:
		position = position.move_toward(Globals.player_pos, SPEED * delta)
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)


func movement_followPlayerX_whenSpotted(delta):
	if spottedPlayer:
		movement_followPlayerX(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_followPlayerY_whenSpotted(delta):
	if spottedPlayer:
		movement_followPlayerY(delta)
		start_pos_can_turn_Y = true


func movement_followPlayerXY_whenSpotted(delta):
	if spottedPlayer:
		movement_followPlayerXY(delta)


#CHASE PLAYER
func movement_chasePlayerX(_delta):
	self.position.x = lerp(self.position.x, Globals.player_pos.x, 0.01)


func movement_chasePlayerX_whenSpotted(delta):
	if spottedPlayer:
		movement_chasePlayerX(delta)
	
	if dead and not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)


func movement_chasePlayerY(_delta):
	self.position.y = lerp(self.position.y, Globals.player_pos.y, 0.01)


func movement_chasePlayerY_whenSpotted(delta):
	if spottedPlayer:
		movement_chasePlayerY(delta)
	
	if dead and not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)


func movement_chasePlayerXY(_delta):
	self.position = lerp(self.position, Globals.player_pos, 0.01)


func movement_chasePlayerXY_whenSpotted(delta):
	if spottedPlayer:
		movement_chasePlayerXY(delta)
	
	if dead and not is_on_floor():
		velocity.y = move_toward(velocity.y, SPEED, SPEED * delta)



func movement_stationary(delta):
	if not dead:
		if not t_afterDelay_jumpAndMove:
			if Globals.player_posX >= position.x:
				direction = 1
			else:
				direction = -1
		
		move_toward_zero_velocity_x(delta)


var velocity_H_target = 100
var velocity_V_target = -100
var toggle_H = false
var toggle_V = false

func movement_wave_V(delta):
	if direction:
		velocity.x = direction * SPEED
	else:
		move_toward_zero_velocity_x(delta)
	
	
	if dead:
		velocity.y = move_toward(velocity.y, 800, 400 * delta * ACCELERATION)
	
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
		velocity.y = move_toward(velocity.y, 0, 500 * delta * ACCELERATION)
	
	
	if dead:
		velocity.x = move_toward(velocity.x, 800, 400 * delta * ACCELERATION)
	
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
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 1000 * ACCELERATION)
		velocity.y = move_toward(velocity.y, direction_v * SPEED, delta * 800 * ACCELERATION)
	
	
	if dead:
		velocity.x = 0
		velocity.y = 0


func reassign_global_values():
	global_gravity = Globals.global_gravity
