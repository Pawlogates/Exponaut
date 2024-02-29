extends CenterContainer

var level_icon_scene = load("res://level_button.tscn")
var level_icon = level_icon_scene.instantiate()

var main_menu = load("res://start_menu.tscn")


var level_ID = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(Globals.selected_episode)
	
	
	#EPISODE START
	if Globals.selected_episode == "rooster_island":
		%background.texture = load("res://Assets/Graphics/menu_map.png")
		level_ID = 0
		
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
	if Globals.selected_episode == "rooster_island_2":
		%background.texture = load("res://Assets/Graphics/menu_map2.png")
		level_ID = 0
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(-416, 4), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(7, Vector2(-352, 36), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(10, Vector2(-272, 36), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(5, Vector2(-192, -28), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(4, Vector2(-96, -76), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(8, Vector2(16, 148), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(5, Vector2(96, 84), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(6, Vector2(176, 116), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(9, Vector2(272, -28), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(352, -180), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(12, Vector2(400, 84), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(12, Vector2(464, 84), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(11, Vector2(528, 84), load("res://Levels/RI1_1.tscn"))
		#LEVEL ICON END
		
	#EPISODE END
	
	
	
	#load saved level state
	
	#RI1
	if Globals.selected_episode == "rooster_island":
		for level_icon in get_tree().get_nodes_in_group("level_icon"):
			level_icon.level_state = LevelTransition.get_node("%saved_progress").get("state_RI1_" + str(level_icon.level_ID))
			level_icon.level_score = LevelTransition.get_node("%saved_progress").get("score_RI1_" + str(level_icon.level_ID))
			print("saved level state:", level_icon.level_state)
		
		
		Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_RI1")
		
	
	elif Globals.selected_episode == "rooster_island_2":
		for level_icon in get_tree().get_nodes_in_group("level_icon"):
			level_icon.level_state = LevelTransition.get_node("%saved_progress").get("state_RI2_" + str(level_icon.level_ID))
			level_icon.level_score = LevelTransition.get_node("%saved_progress").get("score_RI2_" + str(level_icon.level_ID))
			print("saved level state:", level_icon.level_state)
		
		
		Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_RI2")
		
	
	
	
	Globals.progress_loadingFinished.emit()
	
	$level_icon_container/level_button_root/level_button.grab_focus()
	%ColorRect.visible = true
	%fade_animation.play("fade_from_black")
	




var Icon_ID = -1
var Position = Vector2(0, 0)
var Level_FilePath = load("res://Levels/RI1_1.tscn")

func place_level_icon(Icon_ID, Position, Level_FilePath):
	
	level_ID += 1
	
	level_icon = level_icon_scene.instantiate()
	
	level_icon.icon_ID = Icon_ID
	level_icon.icon_position = Position
	level_icon.icon_level_filePath = Level_FilePath
	
	level_icon.level_ID = level_ID
	
	%level_icon_container.add_child(level_icon)






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_quit_pressed():
	get_tree().change_scene_to_packed(main_menu)



func _on_enable_score_attack_mode_pressed():
	if Globals.mode_scoreAttack == false:
		Globals.mode_scoreAttack = true
		$"menu_main/menu_container/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Disable Score Attack Mode[/wave]"
		
	elif Globals.mode_scoreAttack == true:
		Globals.mode_scoreAttack = false
		$"menu_main/menu_container/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Enable Score Attack Mode[/wave]"
		
		


func _on_options_pressed():
	get_tree().change_scene_to_packed(main_menu)
