extends Area2D

#possible zone types: "wind", "water", "kill", "bouncy", "gravity".
@export_enum("wind", "water", "kill", "bouncy", "gravity") var zone_type = "wind"

#@export var inside_wind = 0
@export var inside_wind_direction_x : int = 1
@export var inside_wind_direction_y : int = 0
@export var inside_wind_multiplier_x = 1.0
@export var inside_wind_multiplier_y = 1.0

#@export var inside_water = 0
@export var inside_water_multiplier_x = 1.0
@export var inside_water_multiplier_y = 1.0

@export var gravity_value = 0.4

@export var bouncy_velocity_x = -1 # Set to -1 to not apply this velocity.
@export var bouncy_velocity_y = -800

func _on_area_entered(area):
	if Globals.is_node_valid(area):
		var target : Node = area.get_parent()
		
		if not "inside_water" in target : return
		
		if zone_type == "wind":
			target.inside_wind += 1
			target.inside_wind_direction_x = inside_wind_direction_x
			target.inside_wind_direction_y = inside_wind_direction_y
			target.inside_wind_multiplier_x = inside_wind_multiplier_x
			target.inside_wind_multiplier_y = inside_wind_multiplier_y
		
		elif zone_type == "water":
			target.inside_water += 1
			
			if target.inside_water == 1:
				water_effect_enter(target)
				target.inside_water_multiplier_x = inside_water_multiplier_x
				target.inside_water_multiplier_y = inside_water_multiplier_y
				target.velocity.y /= 3
		
		
		elif zone_type == "gravity":
			target.GRAVITY_SCALE = gravity_value
		
		
		elif zone_type == "bouncy":
			target.on_just_bounced()
			
			if bouncy_velocity_x != -1:
				target.velocity.x = bouncy_velocity_x
			if bouncy_velocity_y != -1:
				target.velocity.y = bouncy_velocity_y
			
			water_effect_enter(target)
		
		
		elif zone_type == "kill":
			target.kill()

func _on_area_exited(area):
	if Globals.is_node_valid(area):
		var target : Node = area.get_parent()
		
		if not "inside_water" in target : return
		
		if zone_type == "wind":
			target.inside_wind -= 1
		
		
		elif zone_type == "water":
			target.inside_water -= 1
			if target.inside_water == 0:
				water_effect_enter(target)
				target.speed = Globals.Player.base_speed
		
		
		elif zone_type == "gravity":
			target.GRAVITY_SCALE = 1.0

func water_effect_enter(target : Node):
	$AudioStreamPlayer2D.play()
	var splashParticle = Globals.scene_particle_splash.instantiate()
	splashParticle.global_position = target.position + Vector2(0, 48)
	get_parent().add_child(splashParticle)


func reassign_player():
	Globals.Player = get_tree().get_first_node_in_group("player_root")
