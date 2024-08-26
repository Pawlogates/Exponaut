extends Node2D

var displayScore = 0

var comboScore_deco_speed = 25

@onready var score_label = %Score
@onready var multiplier_label = %Multiplier
@onready var streak_label = %Streak
@onready var comboScore_label = %ComboScore

@onready var bg_score = $Control/bg_score
@onready var bg_comboScore = $Control/bg_comboScore

func _process(delta):
	count_score()
	
	multiplier_label.text = str("x", Globals.combo_tier)
	streak_label.text = str(Globals.collected_in_cycle)
	comboScore_label.text = str(Globals.combo_score)
	
	if Globals.collected_in_cycle > 0:
		comboScore_label.modulate.a = move_toward(comboScore_label.modulate.a, 1, delta)
	else:
		comboScore_label.modulate.a = move_toward(comboScore_label.modulate.a, 0, delta)
	
	comboScore_label.scale = comboScore_label.scale.move_toward(Vector2(1, 1), delta)
	
	bg_comboScore.position.y = move_toward(bg_comboScore.position.y, 1, delta * comboScore_deco_speed)
	bg_comboScore.modulate.g = move_toward(bg_comboScore.modulate.g, 1, delta * 2)
	bg_comboScore.modulate.b = move_toward(bg_comboScore.modulate.b, 1, delta * 2)


var count_direction = 1
var display_difference = 0

func count_score():
	display_difference = abs(Globals.level_score - displayScore)
	
	if displayScore < Globals.level_score:
		count_direction = 1
	elif displayScore > Globals.level_score:
		count_direction = -1
	
	if display_difference > 25000:
		displayScore += 251 * count_direction
	elif display_difference > 10000:
		displayScore += 121 * count_direction
	elif display_difference > 1000:
		displayScore += 41 * count_direction
	elif display_difference > 100:
		displayScore += 11 * count_direction
	elif display_difference > 10:
		displayScore += 3 * count_direction
	elif display_difference > 0:
		displayScore += 1 * count_direction
	
	score_label.text = str(displayScore)


func _ready():
	Globals.saveState_loaded.connect(score_correct_saved)
	
	Globals.score_reduced.connect(score_correct)
	Globals.scoreReset.connect(reset_displayScore)
	
	Globals.itemCollected.connect(on_itemCollected)
	Globals.enemyHit.connect(on_enemyHit)
	Globals.boxBroken.connect(on_boxBroken)
	
	Globals.specialAction.connect(on_specialAction)


func score_correct_saved():
	displayScore = Globals.saved_level_score

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

func on_itemCollected():
	comboScore_updated(25)

func on_enemyHit():
	comboScore_updated(25)

func on_boxBroken():
	comboScore_updated(25)

func on_specialAction():
	comboScore_updated(12.5)
