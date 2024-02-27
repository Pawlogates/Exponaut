extends ColorRect


signal retry()
signal next_level()

@onready var retry_btn = %RetryBtn
@onready var map_btn = %MapBtn


var level_score = 0
var displayScore = 0

func _on_retry_btn_pressed():
	retry.emit()



func _ready():
	set_process(false)
	

func _process(delta):
	if displayScore != Globals.level_score and level_score - displayScore <= 10:
		displayScore += 1
		
	if displayScore != level_score and level_score - displayScore <= 100 and Globals.level_score - displayScore > 10:
		displayScore += 3
	
	if displayScore != level_score and level_score - displayScore <= 1000 and Globals.level_score - displayScore > 100:
		displayScore += 11
		
	if displayScore != level_score and level_score - displayScore > 1000:
		displayScore += 41
		
	if displayScore != level_score and level_score - displayScore > 10000:
		displayScore += 121
		
	if displayScore != level_score and level_score - displayScore > 25000:
		displayScore += 251
		
	
	%"Level Score Label".text = str(displayScore)
	%"Total Score Label".text = str(displayScore)



func exit_reached():
	level_score = Globals.level_score
	
	if not Globals.mode_scoreAttack:
		if get_tree().get_nodes_in_group("Collectibles").size() == 0:
			if LevelTransition.get_node("%saved_progress").get("state_" + str(Globals.current_level)) < 3:
				LevelTransition.get_node("%saved_progress").set("state_" + str(Globals.current_level), 3)
				
		elif get_tree().get_nodes_in_group("specialCollectible").size() <= 0:
			if LevelTransition.get_node("%saved_progress").get("state_" + str(Globals.current_level)) < 2:
				LevelTransition.get_node("%saved_progress").set("state_" + str(Globals.current_level), 2)
				
		elif get_tree().get_nodes_in_group("Collectibles").size() >= 0:
			if LevelTransition.get_node("%saved_progress").get("state_" + str(Globals.current_level)) < 1:
				LevelTransition.get_node("%saved_progress").set("state_" + str(Globals.current_level), 1)
		
		if LevelTransition.get_node("%saved_progress").get("score_" + str(Globals.current_level)) < level_score:
			LevelTransition.get_node("%saved_progress").set("score_" + str(Globals.current_level), level_score)
	
	
	
	
		if Globals.selected_episode == "rooster_island":
			if Globals.current_level_ID == LevelTransition.get_node("%saved_progress").next_level_RI1:
				LevelTransition.get_node("%saved_progress").next_level_RI1 += 1
				
		elif Globals.selected_episode == "rooster_island_2":
			if Globals.current_level_ID == LevelTransition.get_node("%saved_progress").next_level_RI2:
				LevelTransition.get_node("%saved_progress").next_level_RI2 += 1
	
	
	
		Globals.save_progress.emit()
	
	
	
	
	
	
	$AudioStreamPlayer.play()
	$level_finished_text_hide.start()
	await $level_finished_text_hide.timeout
	await LevelTransition.fade_to_black()
	%"Level Finished Label".visible = false
	%"Button Container".visible = true
	%Background.visible = true
	%"End Screen".visible = true
	%"End Screen Values".visible = true
	await LevelTransition.fade_from_black_slow()
	%MapBtn.grab_focus()
	
	set_process(true)
	
	




var mapScreen = load("res://map_screen.tscn")

func _on_map_btn_pressed():
	#next_level.emit()
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(mapScreen)
	await LevelTransition.fade_from_black_slow()
