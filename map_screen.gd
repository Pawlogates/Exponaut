extends CenterContainer

var level_icon_scene = load("res://level_button.tscn")
#var level_icon = level_icon_scene.instantiate()

var main_menu = load("res://start_menu.tscn")


var level_number = 0

var total_score = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	savedProgress_load()
	
	LevelTransition.get_node("%saved_progress").load_game()
	print(Globals.selected_episode)
	
	
	#EPISODE START
	if Globals.selected_episode == "rooster_island":
		%background.texture = load("res://Assets/Graphics/menu_map.png")
		level_number = 0
		
		#LEVEL ICON START
		place_level_icon(5, Vector2(-368, -140), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(-416, 4), load("res://Levels/RI1_2.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(2, Vector2(-320, 132), load("res://Levels/RI1_3.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(4, Vector2(-240, 4), load("res://Levels/RI1_4.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(9, Vector2(-160, -92), load("res://Levels/RI1_5.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(7, Vector2(-16, -28), load("res://Levels/RI1_6.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(2, Vector2(32, 100), load("res://Levels/RI1_7.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(176, 164), load("res://Levels/RI1_8.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(4, Vector2(240, 52), load("res://Levels/RI1_9.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(9, Vector2(352, -44), load("res://Levels/RI1_10.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(12, Vector2(496, -60), load("res://Levels/RI1_11.tscn"))
		#LEVEL ICON END
		
	#EPISODE END
	
	
	
	#EPISODE START
	if Globals.selected_episode == "Main Levels":
		%background.texture = load("res://Assets/Graphics/menu_map2.png")
		level_number = 0
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(-416, 4), load("res://Levels/MAIN_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(7, Vector2(-352, 36), load("res://Levels/MAIN_2.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(10, Vector2(-272, 36), load("res://Levels/MAIN_3.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(5, Vector2(-192, -28), load("res://Levels/MAIN_4.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(5, Vector2(-192, -28), load("res://Levels/MAIN_5.tscn"))
		#LEVEL ICON END
		
		
	#EPISODE END
	
	
	
	#load saved level state
	
	#RI1
	if Globals.selected_episode == "rooster_island":
		for icon in get_tree().get_nodes_in_group("level_icon"):
			icon.level_state = LevelTransition.get_node("%saved_progress").get("state_RI1_" + str(icon.level_number))
			icon.level_score = LevelTransition.get_node("%saved_progress").get("score_RI1_" + str(icon.level_number))
			print("saved level state:", icon.level_state)
		
		
		Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_RI1")
		
	
	#Main Levels
	elif Globals.selected_episode == "Main Levels":
		Globals.current_levelSet_ID = "MAIN"
		
		for icon in get_tree().get_nodes_in_group("level_icon"):
			icon.level_state = LevelTransition.get_node("%saved_progress").get("state_MAIN_" + str(icon.level_number))
			icon.level_score = LevelTransition.get_node("%saved_progress").get("score_MAIN_" + str(icon.level_number))
			icon.is_main_level = true
			print("saved level state:", icon.level_state)
		
		
		LevelTransition.get_node("%saved_progress").count_total_score("MAIN", 13)
		total_score = LevelTransition.get_node("%saved_progress").get("total_score")
		
		#Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_MAIN")
		
	
	
	Globals.progress_loadingFinished.emit()
	
	$level_icon_container/level_button_root/level_button.grab_focus()
	%ColorRect.visible = true
	%fade_animation.play("fade_from_black")
	




#var Icon_ID = -1
#var Position = Vector2(0, 0)
#var Level_FilePath = load("res://Levels/RI1_1.tscn")

func place_level_icon(Icon_ID, Position, Level_FilePath):
	
	level_number += 1
	
	var level_icon = level_icon_scene.instantiate()
	
	level_icon.icon_ID = Icon_ID
	level_icon.icon_position = Position
	level_icon.icon_level_filePath = Level_FilePath
	
	level_icon.level_number = level_number
	
	%level_icon_container.add_child(level_icon)








func _on_enable_score_attack_mode_pressed():
	if Globals.mode_scoreAttack == false:
		Globals.mode_scoreAttack = true
		$"menu_main/menu_container/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Disable Score Attack Mode[/wave]"
		
	elif Globals.mode_scoreAttack == true:
		Globals.mode_scoreAttack = false
		$"menu_main/menu_container/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Enable Score Attack Mode[/wave]"
		
		


func _on_main_menu_pressed():
	get_tree().change_scene_to_packed(main_menu)


func _on_back_to_overworld_pressed():
	if Globals.delete_saves:
		saved_level_filePath = "res://Levels/Overworld.tscn"
	
	print(saved_level)
	saved_level = load(saved_level_filePath)
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(saved_level)



var saved_level_filePath = "empty"
var saved_level:PackedScene = load("res://Levels/empty.tscn")


func savedProgress_load():
	if not FileAccess.file_exists("user://savedProgress.save"):
		print("no save")
		#%Continue.process_mode = Node.PROCESS_MODE_DISABLED
		#%Continue.modulate.b = 0.3
		#%Continue.modulate.g = 0.3
		#%Continue.modulate.a = 0.3
		return
		
		
	var savedProgress_file = FileAccess.open("user://savedProgress.save", FileAccess.READ)
	while savedProgress_file.get_position() < savedProgress_file.get_length():
		var json_string = savedProgress_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var data = json.get_data()
		
		
		#LOAD PROGRESS
		
		saved_level_filePath = data["level_filePath"]
		Globals.next_transition = data["level_next_transition"]
		
		#LOAD PROGRESS END
