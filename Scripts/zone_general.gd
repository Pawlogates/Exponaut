extends Area2D

#possible zone types: "wind", "water", "kill", "bouncy", "gravity".
@export_enum("wind", "water", "kill", "bouncy", "gravity") var zone_type = "wind"

@export var inside_wind = 0
@export var inside_wind_multiplier_x = 1.0
@export var inside_wind_multiplier_y = 1.0

@export var inside_water = 0
@export var inside_water_multiplier_x = 1.0
@export var inside_water_multiplier_y = 1.0

@export var gravity_value = 0.4

@export var bouncy_velocity_X = -1 # Set to -1 to not apply this velocity.
@export var bouncy_velocity_Y = -400

func _on_area_entered(area):
	if area.is_in_group("player"):
	
		if zone_type == "wind":
			Globals.Player.inside_wind += 1
			Globals.Player.inside_wind_multiplier_x = inside_wind_multiplier_x
			Globals.Player.inside_wind_multiplier_y = inside_wind_multiplier_y
		
		
		elif zone_type == "water":
			Globals.Player.inside_water += 1
			
			if Globals.Player.inside_water == 1:
				water_effect_enter()
				Globals.Player.inside_water_multiplier_x = inside_water_multiplier_x
				Globals.Player.inside_water_multiplier_y = inside_water_multiplier_y
				Globals.Player.velocity.y /= 3
				Globals.Player.get_node("jumpBuildVelocity").wait_time = 0.25
		
		
		elif zone_type == "gravity":
			Globals.Player.GRAVITY_SCALE = gravity_value
		
		
		elif zone_type == "bouncy":
			Globals.Player.on_player_just_bounced()
			
			if bouncy_velocity_X != -1:
				Globals.Player.velocity.x = bouncy_velocity_X
			if bouncy_velocity_Y != -1:
				Globals.Player.velocity.y = bouncy_velocity_Y
			
			water_effect_enter()
		
		
		elif zone_type == "kill":
			print("Kill area entered.")
			Globals.kill_player.emit()
	
	
	
	elif area.get_parent().is_in_group("special_block"):
		var block = area.get_parent()
		
		if zone_type == "wind":
			block.inside_wind += 1
			block.inside_wind_multiplier_x = inside_wind_multiplier_x
			block.inside_wind_multiplier_y = inside_wind_multiplier_y
		
		
		elif zone_type == "water":
			block.inside_water += 1
			if block.inside_water == 1:
				#water_effect_general()
				pass
		
		
		elif zone_type == "gravity":
			block.GRAVITY_SCALE = gravity_value
		
		
		elif zone_type == "bouncy":
			if bouncy_velocity_X != -1:
				block.velocity.x = bouncy_velocity_X
			if bouncy_velocity_Y != -1:
				block.velocity.y = bouncy_velocity_Y
			
			#water_effect_general()

func _on_area_exited(area):
	if area.is_in_group("player"):
	
		if zone_type == "wind":
			Globals.Player.inside_wind -= 1
		
		
		elif zone_type == "water":
			Globals.Player.inside_water -= 1
			if Globals.Player.inside_water == 0:
				water_effect_enter()
				Globals.Player.SPEED = Globals.Player.base_SPEED
				Globals.Player.get_node("jumpBuildVelocity").wait_time = 0.1
		
		
		elif zone_type == "gravity":
			Globals.Player.GRAVITY_SCALE = 1.0
	
	
	
	elif area.get_parent().is_in_group("special_block"):
		var block = area.get_parent()
		
		if zone_type == "wind":
			block.inside_wind -= 1
		
		
		elif zone_type == "water":
			block.inside_water -= 1
			if block.inside_water == 0:
				#water_effect_general()
				pass
		
		
		elif zone_type == "gravity":
			block.GRAVITY_SCALE = 1.0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") or body.is_in_group("Collectibles") or body.is_in_group("bonusBox"):
	
		if zone_type == "wind":
			body.inside_wind += 1
			body.inside_wind_multiplier_x = inside_wind_multiplier_x
			body.inside_wind_multiplier_y = inside_wind_multiplier_y
		
		
		elif zone_type == "water":
			body.inside_water += 1
			if body.inside_water == 1:
				#water_effect_general()
				pass
		
		
		elif zone_type == "gravity":
			body.GRAVITY_SCALE = gravity_value
		
		
		elif zone_type == "bouncy":
			if bouncy_velocity_X != -1:
				body.velocity.x = bouncy_velocity_X
			if bouncy_velocity_Y != -1:
				body.velocity.y = bouncy_velocity_Y
			
			#water_effect_general()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies") or body.is_in_group("Collectibles") or body.is_in_group("bonusBox"):
	
		if zone_type == "wind":
			body.inside_wind -= 1
		
		
		elif zone_type == "water":
			body.inside_water -= 1
			if body.inside_water == 0:
				#water_effect_general()
				pass
		
		
		elif zone_type == "gravity":
			body.GRAVITY_SCALE = 1.0


func water_effect_enter():
	$AudioStreamPlayer2D.play()
	var splashParticle = Globals.scene_particle_splash.instantiate()
	splashParticle.global_position = Globals.player_pos + Vector2(0, 48)
	get_parent().add_child(splashParticle)


func reassign_player():
	Globals.Player = get_tree().get_first_node_in_group("player_root")
