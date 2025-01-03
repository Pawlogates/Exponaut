extends Area2D

var splashParticleScene = preload("res://Particles/particles_water_entered.tscn")
var splashParticle = splashParticleScene.instantiate()

#possible zone types: "wind", "water"
@export var zone_type = "none"

#possible wind directions: "left", "right"
@export var wind_direction = 0

@export var water_strength = 1.0
@export var water_slowdown = 1.0

func _on_area_entered(area):
	if area.is_in_group("player"):
		if zone_type == "wind":
			area.get_parent().inside_wind += 1
			area.get_parent().insideWind_direction = wind_direction
		
		elif zone_type == "water":
			area.get_parent().inside_water += 1
			if area.get_parent().inside_water:
				area.get_parent().insideWater_multiplier = water_strength
				area.get_parent().SPEED *= water_slowdown
				area.get_parent().velocity.y /= 3
				area.get_parent().get_node("jumpBuildVelocity").wait_time = 0.2
			
			$AudioStreamPlayer2D.play()
			splashParticle = splashParticleScene.instantiate()
			splashParticle.global_position = Globals.player_pos + Vector2(0, 48)
			get_parent().add_child(splashParticle)
		
		
		elif zone_type == "low_gravity":
			area.get_parent().GRAVITY_SCALE = 0.5
		
		
		elif zone_type == "bouncy":
			area.get_parent().velocity.y = -400
			$AudioStreamPlayer2D.play()
			splashParticle = splashParticleScene.instantiate()
			splashParticle.global_position = Globals.player_pos
			get_parent().add_child(splashParticle)
		
		
		elif zone_type == "kill":
			print("Kill area entered.")
			Globals.kill_player.emit()


func _on_area_exited(area):
	if area.is_in_group("player"):
		
		if zone_type == "wind":
			area.get_parent().inside_wind -= 1
		
		elif zone_type == "water":
			area.get_parent().inside_water -= 1
			if not area.get_parent().inside_water:
				area.get_parent().SPEED = area.get_parent().base_SPEED
				area.get_parent().get_node("jumpBuildVelocity").wait_time = 0.1
			
			$AudioStreamPlayer2D.play()
			splashParticle = splashParticleScene.instantiate()
			splashParticle.global_position = Globals.player_pos + Vector2(0, 48)
			get_parent().add_child(splashParticle)
			
		
		elif zone_type == "low_gravity":
			area.get_parent().GRAVITY_SCALE = 1.0
