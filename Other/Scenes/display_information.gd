extends Control

func _ready() -> void:
	if Globals.gameState_level or Globals.gameState_levelSet_screen:
		if Globals.gameState_scoring_focus:
			if Globals.gameState_level and not Globals.World.level_finished_active:
				position.x += 700
				position.y -= 350
				scale *= 1.2
			else:
				position.x += 1275
				position.y += -50
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
