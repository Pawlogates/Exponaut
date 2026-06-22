extends Control

func _ready() -> void:
	if not Globals.gameState_levelSet_screen:
		if Globals.random_bool(1, 4) : queue_free()
	
	if Globals.gameState_level or Globals.gameState_levelSet_screen:
		if Globals.gameState_scoring_focus:
			if Globals.gameState_level and not Globals.World.level_finished_active:
				position.x += 700
				position.y -= 350
				scale *= 1.2
			else:
				position.x += 1240
				position.y += -75
				scale *= 1.2
		else:
			queue_free()
	
	else:
		position.x -= 510
		position.y -= 240
		scale *= 1.2
	
	#if len(get_tree().get_nodes_in_group("screen_results_level")) != 0:
		#queue_free()


func _on_button_pressed() -> void:
	queue_free()
