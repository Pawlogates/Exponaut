extends Node2D


func _ready():
	
	Globals.itemCollected.connect(itemCollected_reset_combo_cycle)
	Globals.enemyHit.connect(enemyHit_reset_combo_cycle)
	



func check_combo_tier():
	if Globals.collected_in_cycle >= 0 and Globals.collected_in_cycle < 5:
		Globals.combo_tier = 1
		
	if Globals.collected_in_cycle >= 5 and Globals.collected_in_cycle < 10:
		Globals.combo_tier = 2
	
	if Globals.collected_in_cycle >= 10 and Globals.collected_in_cycle < 15:
		Globals.combo_tier = 3
	
	if Globals.collected_in_cycle >= 15 and Globals.collected_in_cycle < 20:
		Globals.combo_tier = 4
	
	if Globals.collected_in_cycle >= 20 and Globals.collected_in_cycle < 25:
		Globals.combo_tier = 5
		
		

@onready var audio_stream_player = $AudioStreamPlayer


func reset_combo_tier():
	Globals.collected_in_cycle = 0
	check_combo_tier()
	
	audio_stream_player.play()
	
	Globals.comboReset.emit()
	
	




@onready var combo_cycle_timer = $combo_cycle_timer


func reset_combo_timer():
	combo_cycle_timer.start()







func itemCollected_reset_combo_cycle():
	check_combo_tier()
	Globals.collected_in_cycle += 1
	
	reset_combo_timer()
	


func enemyHit_reset_combo_cycle():
	check_combo_tier()
	reset_combo_timer()







func _on_combo_cycle_timer_timeout():
	#print("combo reset")
	reset_combo_tier()
	Globals.level_score += Globals.combo_score
	Globals.combo_score = 0






func _on_timer_timeout():
	if Globals.collected_in_cycle == 0:
		Globals.comboReset.emit()
