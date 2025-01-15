extends Area2D

var splashParticleScene = preload("res://Particles/particles_water_entered.tscn")

@onready var world = $/root/World
@onready var player = $/root/World.player

#possible zone types: "wind", "water", "kill", "bouncy", "gravity".
@export_enum("wind", "water", "kill", "bouncy", "gravity") var zone_type = "wind"

#possible wind directions: "left", "right"
@export var wind_direction_X = 1
@export var wind_direction_Y = 0
@export var wind_strength_X = 1.0
@export var wind_strength_Y = 1.0

@export var water_strength = 0.8
@export var water_slowdown = 0.6

@export var gravity_value = 0.4

@export var bouncy_velocity_X = -1 # Set to -1 to not apply this velocity.
@export var bouncy_velocity_Y = -400

func _on_area_entered(area):
	if area.is_in_group("player"):
	
		if zone_type == "wind":
			player.inside_wind += 1
			player.insideWind_direction_X = wind_direction_X
			player.insideWind_direction_Y = wind_direction_Y
			player.insideWind_strength_X = wind_strength_X
			player.insideWind_strength_Y = wind_strength_Y
		
		
		elif zone_type == "water":
			player.inside_water += 1
			if player.inside_water == 1:
				water_effect()
				player.insideWater_multiplier = water_strength
				player.SPEED = player.base_SPEED * water_slowdown
				player.velocity.y /= 3
				player.get_node("jumpBuildVelocity").wait_time = 0.25
		
		
		elif zone_type == "gravity":
			player.GRAVITY_SCALE = gravity_value
		
		
		elif zone_type == "bouncy":
			player.on_player_just_bounced()
			
			if bouncy_velocity_X != -1:
				player.velocity.x = bouncy_velocity_X
			if bouncy_velocity_Y != -1:
				player.velocity.y = bouncy_velocity_Y
			
			water_effect()
		
		
		elif zone_type == "kill":
			print("Kill area entered.")
			Globals.kill_player.emit()


func _on_area_exited(area):
	if area.is_in_group("player"):
	
		if zone_type == "wind":
			player.inside_wind -= 1
		
		
		elif zone_type == "water":
			player.inside_water -= 1
			if player.inside_water == 0:
				water_effect()
				player.SPEED = player.base_SPEED
				player.get_node("jumpBuildVelocity").wait_time = 0.1
		
		
		elif zone_type == "gravity":
			player.GRAVITY_SCALE = 1.0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") or body.is_in_group("Collectibles") or body.is_in_group("bonusBox"):
	
		if zone_type == "wind":
			body.inside_wind += 1
			body.insideWind_direction_X = wind_direction_X
			body.insideWind_direction_Y = wind_direction_Y
			body.insideWind_strength_X = wind_strength_X
			body.insideWind_strength_Y = wind_strength_Y
		
		
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
				water_effect()
				pass
		
		
		elif zone_type == "gravity":
			body.GRAVITY_SCALE = 1.0


func water_effect():
	$AudioStreamPlayer2D.play()
	var splashParticle = splashParticleScene.instantiate()
	splashParticle.global_position = Globals.player_pos + Vector2(0, 48)
	get_parent().add_child(splashParticle)
