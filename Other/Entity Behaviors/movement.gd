extends Node2D

var movement type = "none" # Assigned when the entity is created and assigned this behaviour.
var 

func _process(delta):
	movement()


var movement_type_id = 0

func movement():
	if movement_type_id == 0 : return
	
	elif movement_type_id == 1:
		pass


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
