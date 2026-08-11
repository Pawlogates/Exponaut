extends Control

var menu : Node

func _ready() -> void:
	menu = get_tree().get_first_node_in_group("menu_main")
	
	if menu.force_info_delete : queue_free()
	
	if Globals.gameState_scoring_focus and menu.manual_request:
		if Globals.node_exists("screen_results_level") and Globals.gameState_level:
			position += Vector2(1675, 525)
	
	#if not Globals.gameState_levelSet_screen:
		#if Globals.random_bool(1, 4) : queue_free()
	
	if Globals.gameState_level or Globals.gameState_levelSet_screen:
		
		if Globals.gameState_scoring_focus:
			
			if Globals.gameState_level:
				if Globals.World.level_finished_active:
					if not menu.manual_request:
						position.x += 1700
						position.y += 325
					else:
						position.x += 65
						position.y += -200
					
				else:
					if not menu.manual_request:
						position.x += 1250
						position.y += 200
					
					else:
						position.x += 770
						position.y -= 150
			else:
				position.x += 0
				position.y += 75
		else:
			queue_free()
	
	else:
		position.x = 510
		position.y = 240
		scale *= 1.2
	
	#if len(get_tree().get_nodes_in_group("screen_results_level")) != 0:
		#queue_free()


func _on_button_pressed() -> void:
	queue_free()
