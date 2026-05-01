extends Control

func _ready() -> void:
	if Globals.gameState_level:
		if Globals.gameState_scoring_focus:
			position.x += 700
			position.y -= 350
			scale *= 1.2
		else:
			queue_free()
	
	if len(get_tree().get_nodes_in_group("screen_results_level")) != 0:
		queue_free()


func _on_button_pressed() -> void:
	queue_free()
