extends Node2D

var displayScore = 0

@onready var score_label = %Score
@onready var multiplier_label = %Multiplier
@onready var streak_label = %Streak
@onready var comboScore_label = %ComboScore

func _process(_delta):
	count_score()
	multiplier_label.text = str("x", Globals.combo_tier)
	streak_label.text = str(Globals.collected_in_cycle)
	comboScore_label.text = str(Globals.combo_score)


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


func score_correct_saved():
	displayScore = Globals.saved_level_score


func score_correct():
	displayScore = Globals.level_score


func reset_displayScore():
	displayScore = 0
