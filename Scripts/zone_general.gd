extends Area2D

var splashParticleScene = preload("res://Particles/particles_water_entered.tscn")

@onready var world = $/root/World
@onready var player = $/root/World.player

#possible zone types: "wind", "water"
@export var zone_type = "none"

#possible wind directions: "left", "right"
@export var wind_direction_X = 0
@export var wind_direction_Y = 0

@export var water_strength = 1.0
@export var water_slowdown = 1.0

func _on_area_entered(area):
	if area.is_in_group("player"):
	
		if zone_type == "wind":
			player.inside_wind += 1
			player.insideWind_direction = wind_direction_X
		
		
		elif zone_type == "water":
			player.inside_water += 1
			if player.inside_water == 1:
				water_effect()
				player.insideWater_multiplier = water_strength
				player.SPEED = player.base_SPEED * water_slowdown
				player.velocity.y /= 3
				player.get_node("jumpBuildVelocity").wait_time = 0.25
		
		
		elif zone_type == "low_gravity":
			player.GRAVITY_SCALE = 0.5
		
		
		elif zone_type == "bouncy":
			player.velocity.y = -400
			$AudioStreamPlayer2D.play()
			var splashParticle = splashParticleScene.instantiate()
			splashParticle.global_position = Globals.player_pos
			get_parent().add_child(splashParticle)
		
		
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
		
		
		elif zone_type == "low_gravity":
			player.GRAVITY_SCALE = 1.0


func water_effect():
	$AudioStreamPlayer2D.play()
	var splashParticle = splashParticleScene.instantiate()
	splashParticle.global_position = Globals.player_pos + Vector2(0, 48)
	get_parent().add_child(splashParticle)
