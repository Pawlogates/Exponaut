extends CharacterBody2D

@onready var sprite: Sprite2D = $sprite
@onready var sfx_manager: Node2D = $sfx_manager


var direction : Vector2 = Vector2(0, 0)
var SPEED = 300
var target_pos : Vector2 = Vector2(0, 0)

var score_value : int = -1

var collected : bool = false


func _process(delta: float) -> void:
	rotation_degrees = position.distance_to(target_pos) / 4
	modulate.a -= position.distance_to(target_pos) / 1000000
	
	if position.distance_to(target_pos) < 100:
		if not collected:
			collected = true
			Globals.combo_streak += 1 # These values need to be modified before the "handle_award_score" function goes off, due to many of the visual effects being based on them.
			Globals.entity_collected.emit()
			handle_award_score()
			
			Globals.spawn_scenes(get_parent(), Globals.scene_orb_blue, 1, position)
			Globals.spawn_scenes(get_parent(), Globals.scene_particle_star, 1, position)
			Globals.spawn_scenes(get_parent(), Globals.scene_particle_special_multiple, 1, position)
			
			visible = false
			
			await get_tree().create_timer(1.0, true).timeout
			
			queue_free()
	
	#scale -= Vector2(1, 1) * delta / 40
	if not collected : scale = Vector2(0.25, 0.25) + Vector2(1, 1) * position.distance_to(target_pos) / 1000
	
	SPEED *= 1.05
	
	if SPEED > 5000:
		SPEED = 5000
	
	if abs(target_pos.x - position.x) < 200: velocity.x *= 0.95
	if abs(target_pos.y - position.y) < 200: velocity.y *= 0.95
	
	if position.x > target_pos.x: direction.x = -1
	else : direction.x = 1
	if position.y > target_pos.y : direction.y = -1
	else : direction.y = 1
	
	velocity.x = move_toward(velocity.x, direction.x * SPEED, delta * SPEED)
	velocity.y = move_toward(velocity.y, direction.y * SPEED, delta * SPEED)
	
	move_and_slide()

func _ready() -> void:
	target_pos.x = Globals.window_size.x / 2 - 64
	target_pos.y = 128
	
	if score_value == -1 : score_value = randi_range(10, 2500)
	
	velocity.x = randi_range(-1600, 1600)
	velocity.y = randi_range(-800, 1200)
	
	await get_tree().create_timer(20.0, true).timeout
	
	queue_free()


func handle_award_score():
	#score_value *= randf_range(4.0, 50000)
	
	var experience_value : int = 1
	Overlay.hud_player_experience.experience_increase(experience_value + (randi_range(0, 2)) + randi_range(-experience_value * 0.1, experience_value * 0.1))
	
	Globals.level_score += score_value
	
	if Globals.combo_streak > 1:
		Globals.combo_score += score_value * Globals.combo_tier
	
	# Combo tier increases every 5 collectibles collected during a combo, usually up to x10, and eventually to x11 after reaching a combo streak of 100.
	if Globals.combo_tier > 1 : pass
	elif Globals.combo_tier > 2 : pass
	elif Globals.combo_tier > 3 : pass
	
	elif Globals.combo_tier > 4:
		sprite.material = Globals.material_score_value_rainbow2
		sprite.material.set_shader_parameter("strength", 0.5)
	
	else:
		sprite.material = Globals.material_score_value_rainbow2
		sprite.material.set_shader_parameter("strength", 0.0)
	
	sfx_manager.sfx_play(Globals.sfx_jewel_collect, 1.0, randf_range(0.9, 1.1) + (0.025 * (Globals.combo_streak)))
	
	spawn_display_score(score_value)
	if Globals.combo_streak > 0 : spawn_display_combo_score(score_value * Globals.combo_tier)
	
	if Globals.random_bool(4, 1):
		if Globals.combo_streak > 1 : spawn_display_score_bonus(Globals.combo_score, Vector2(-0.9, -0.9) + Vector2((0.05), (0.05)) * Globals.combo_streak)
		elif Globals.debug_mode : spawn_display_score_bonus(Globals.combo_score, -Vector2(-0.5, -0.5))


func spawn_display_score(value : int):
	var node = Globals.scene_effect_score_value.instantiate()
	
	node.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	node.value = value
	node.scale += Vector2(1, 1) * randf_range(-0.1, 0.1)
	node.z_index += Globals.combo_streak
	
	Globals.main_scene.add_child(node)

func spawn_display_combo_score(value : int):
	var node = Globals.scene_effect_combo_score_value.instantiate()
	
	node.position = position + Vector2(randi_range(-250, 250), randi_range(-100, 100))
	node.value = value
	node.scale += Vector2(1, 1) * 0.1 * Globals.combo_tier
	node.z_index += Globals.combo_streak
	
	Globals.main_scene.add_child(node)


func spawn_display_score_bonus(value : int, add_scale : Vector2 = Vector2(1, 1), ignore_gravity : bool = false):
	var node = Globals.scene_effect_score_bonus.instantiate()
	
	node.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	node.value = value
	node.add_scale += add_scale # Note: This line modifies a custom property, not "scale".
	node.z_index += Globals.combo_streak
	
	Globals.main_scene.add_child(node)
