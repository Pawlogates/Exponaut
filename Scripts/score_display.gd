extends Node2D

var displayScore : int = 0
var comboScore_deco_speed = 25
var last_combo_tier : int = 1
var multiplier_label_target_font_size : float = 16.0

var target_pos : Vector2 = Vector2(64, 64)

@onready var score_label = %Score
@onready var multiplier_label = %Multiplier
@onready var streak_label = %Streak
@onready var comboScore_label = %ComboScore

@onready var bg_score = $Control/bg_score
@onready var bg_comboScore = $Control/bg_comboScore

@onready var decoration_gear: Node2D = $decoration_gear
@onready var decoration_gear_3: Node2D = $decoration_gear3
@onready var decoration_gear_2: Node2D = $decoration_gear2

@onready var deco_highlight_shine_around: Node2D = $deco_highlight_shine_around

@onready var deco_tetronaut: Node2D = $deco_tetronaut


func _physics_process(delta):
	if Globals.gameState_tetronaut:
		position = position.lerp(target_pos, delta)
		deco_highlight_shine_around.modulate.a = lerp(deco_highlight_shine_around.modulate.a, 0.025, delta / 4)
		deco_highlight_shine_around.scale = deco_highlight_shine_around.scale.lerp(Vector2(0.85, 0.85), delta * 4)
		modulate.r = lerp(modulate.r, 1.0, delta)
		modulate.g = lerp(modulate.r, 1.0, delta)
		modulate.b = lerp(modulate.r, 1.0, delta)
	
	count_score()
	
	if not is_instance_valid(multiplier_label) : return
	
	multiplier_label["theme_override_font_sizes/font_size"] = move_toward(multiplier_label["theme_override_font_sizes/font_size"], multiplier_label_target_font_size, delta)

	if Globals.combo_streak > 0:
		multiplier_label.text = str("x", Globals.combo_tier)
		multiplier_label.material = Globals.material_rainbow
	else:
		multiplier_label.text = "x0"
		multiplier_label.material = null
	
	if Globals.combo_tier != last_combo_tier : on_combo_tier_updated()
	last_combo_tier = Globals.combo_tier
	
	streak_label.text = str(Globals.combo_streak)
	comboScore_label.text = str(Globals.combo_score)
	
	if Globals.combo_streak > 0:
		comboScore_label.modulate.a = move_toward(comboScore_label.modulate.a, 1, delta)
	else:
		comboScore_label.modulate.a = move_toward(comboScore_label.modulate.a, 0, delta)
	
	comboScore_label.scale = comboScore_label.scale.move_toward(Vector2(1, 1), delta)
	
	bg_comboScore.position.y = move_toward(bg_comboScore.position.y, 1, delta * comboScore_deco_speed)
	bg_comboScore.modulate.g = move_toward(bg_comboScore.modulate.g, 1, delta * 2)
	bg_comboScore.modulate.b = move_toward(bg_comboScore.modulate.b, 1, delta * 2)


var count_direction : int = 1
var display_difference : int = 0
var count_multiplier : float = 1.0

func count_score():
	display_difference = abs(Globals.level_score - displayScore)
	
	if Globals.combo_streak > 0 : count_multiplier = 2.0
	elif count_multiplier != 3.0 : count_multiplier = 1.0
	
	
	if displayScore < Globals.level_score:
		count_direction = 1
	elif displayScore > Globals.level_score:
		count_direction = -1
	
	
	if display_difference > 25000:
		displayScore += 1203 * count_direction * count_multiplier
	elif display_difference > 10000:
		displayScore += 601 * count_direction * count_multiplier
	elif display_difference > 1000:
		displayScore += 201 * count_direction * count_multiplier
	elif display_difference > 100:
		displayScore += 16 * count_direction * count_multiplier
	elif display_difference > 10:
		displayScore += 3 * count_direction # Multiplier is not applied because otherwise the counter would be able to exceed the target score.
	elif display_difference > 0:
		displayScore += 1 * count_direction
	
	if is_instance_valid(score_label) : score_label.text = str(displayScore) + "$"


func _ready():
	Globals.gameState_changed.connect(on_gameState_changed)
	Globals.levelState_loaded.connect(score_correct_saved)
	
	Globals.score_reduced.connect(score_correct)
	Globals.score_reset.connect(reset_displayScore)
	
	Globals.entity_collected.connect(on_entity_collected)
	Globals.entity_hit.connect(on_entity_hit)
	Globals.entity_killed.connect(on_entity_killed)
	Globals.combo_refreshed.connect(on_combo_refreshed)
	
	Globals.not_enough_score.connect(on_not_enough_score)
	
	
	if Globals.gameState_tetronaut:
		target_pos.x = Globals.window_size.x / 2 - $Control.size.x / 2
		target_pos.y += 10
		decoration_gear.position.x -= 48
		decoration_gear_3.position.x -= 48
	
	else:
		deco_tetronaut.queue_free()


func score_correct_saved():
	displayScore = Globals.level_score

func score_correct():
	displayScore = Globals.level_score

func reset_displayScore():
	displayScore = 0


func comboScore_updated(new_speed):
	comboScore_deco_speed = new_speed
	comboScore_label.scale = Vector2(1.1, 1.1)
	bg_comboScore.position.y = 64
	bg_comboScore.modulate.g = 0
	bg_comboScore.modulate.b = 0

func on_entity_collected():
	comboScore_updated(25)
	
	if Globals.gameState_tetronaut:
		position.y += 5
		deco_highlight_shine_around.modulate.a += 0.1
		deco_highlight_shine_around.scale *= 1.01
		if Globals.get_random_bool(10) : deco_highlight_shine_around.modulate = Globals.l_color_all.pick_random()
		
		if Globals.get_random_bool(25) : modulate.r += randf_range(-0.25, 0.5)
		if Globals.get_random_bool(25) : modulate.g += randf_range(-0.25, 0.5)
		if Globals.get_random_bool(25) : modulate.b += randf_range(-0.25, 0.5)

func on_entity_hit():
	comboScore_updated(70)

func on_entity_killed():
	comboScore_updated(10)

func on_combo_refreshed(_time):
	comboScore_updated(25)


func on_gameState_changed():
	count_multiplier = 3.0


func on_combo_tier_updated():
	multiplier_label["theme_override_font_sizes/font_size"] = 64.0
	multiplier_label_target_font_size = 24 + Globals.combo_tier * 4
	Globals.spawn_scenes(multiplier_label, Globals.scene_particle_star, 4, multiplier_label.size / 2)


@onready var animation_general: AnimationPlayer = $Control/animation_general

func on_not_enough_score():
	animation_general.play("shake")
	await get_tree().create_timer(1.0, true).timeout
	animation_general.stop()
