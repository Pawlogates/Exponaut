extends Node2D

@onready var sfx_streak_finished = $collectible_streak_finished
@onready var streak_timer = $collectible_streak_timer

func _ready():
	Globals.itemCollected.connect(itemCollected_reset_combo_cycle)
	Globals.enemyHit.connect(enemyHit_reset_combo_cycle)
	Globals.boxBroken.connect(boxBroken_reset_combo_cycle)
	
	Globals.specialAction.connect(reset_combo_cycle_long)


func check_combo_tier():
	if Globals.collected_in_cycle > 20:
		Globals.combo_tier = 5
		
	elif Globals.collected_in_cycle > 15:
		Globals.combo_tier = 4
	
	elif Globals.collected_in_cycle > 10:
		Globals.combo_tier = 3
	
	elif Globals.collected_in_cycle > 5:
		Globals.combo_tier = 2
	
	elif Globals.collected_in_cycle >= 0:
		Globals.combo_tier = 1
	
	
	if Globals.collected_in_cycle == 20:
		Globals.max_score_multiplier_reached.emit()


func reset_combo_tier():
	Globals.collected_in_cycle = 0
	check_combo_tier()
	
	sfx_streak_finished.play()
	
	Globals.comboReset.emit()
	
	Globals.level_score += Globals.combo_score
	Globals.combo_score = 0


func reset_combo_timer():
	streak_timer.wait_time = 2.5
	print(streak_timer.wait_time)
	streak_timer.start()

func reset_combo_timer_long():
	streak_timer.wait_time = 5.0
	print(streak_timer.wait_time)
	streak_timer.start()


func itemCollected_reset_combo_cycle():
	Globals.collected_in_cycle += 1
	check_combo_tier()
	reset_combo_timer()


func enemyHit_reset_combo_cycle():
	check_combo_tier()
	reset_combo_timer()


func boxBroken_reset_combo_cycle():
	check_combo_tier()
	reset_combo_timer()


func reset_combo_cycle_long():
	check_combo_tier()
	reset_combo_timer_long()


func _on_collectible_streak_timer_timeout():
	var comboScore_value_display = preload("res://Other/Scenes/score_value.tscn").instantiate()
	comboScore_value_display.score = Globals.combo_score
	comboScore_value_display.position = $/root/World.player.position
	$/root/World.add_child(comboScore_value_display)
	
	reset_combo_tier()
	print("Collectible streak finished.")
