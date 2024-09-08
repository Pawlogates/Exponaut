extends CenterContainer

var level_icon_scene = load("res://Other/Scenes/Level Select/level_button.tscn")
var main_menu = load("res://Other/Scenes/menu_start.tscn")

var level_number = 0
var total_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelTransition.get_node("%saved_progress").load_game()
	print(str(Globals.selected_episode) + " is the currently selected Level Set.")
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#EPISODE START
	if Globals.selected_episode == "Additional Levels":
		level_number = 0
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(-368, -140), load("res://Levels/testLevel_collectibles.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(-416, 4), load("res://Levels/testLevel_object_saved_state.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(-320, 132), load("res://Levels/testLevel_random_enemy.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(-140, 4), load("res://Levels/testLevel_memeSpawner.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(240, 64), load("res://Levels/testLevel_lethalBall.tscn"))
		#LEVEL ICON END
		
		# DEBUG - OVERWORLD AREAS
		place_level_icon(2, Vector2(540, -240), load("res://Levels/overworld_factory.tscn"))
		place_level_icon(2, Vector2(540, -180), load("res://Levels/overworld_infected_glades.tscn"))
		place_level_icon(2, Vector2(540, -120), load("res://Levels/overworld_glades.tscn"))
		place_level_icon(2, Vector2(540, -60), load("res://Levels/overworld_ascent.tscn"))
		place_level_icon(2, Vector2(600, -60), load("res://Levels/overworld_castle.tscn"))
		
	#EPISODE END
	
	
	#EPISODE START
	if Globals.selected_episode == "Main Levels":
		%background.texture = load("res://Assets/Graphics/other/levelSelect_screen.png")
		level_number = 0
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(-460, 40), load("res://Levels/MAIN_1.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(2, Vector2(-360, 80), load("res://Levels/MAIN_2.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(280, 60), load("res://Levels/MAIN_3.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(180, 40), load("res://Levels/MAIN_4.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(0, Vector2(-120, -100), load("res://Levels/MAIN_5.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(700, 80), load("res://Levels/MAIN_6.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(1, Vector2(200, -40), load("res://Levels/MAIN_7.tscn"))
		#LEVEL ICON END
		
		#LEVEL ICON START
		place_level_icon(2, Vector2(350, -120), load("res://Levels/MAIN_8.tscn"))
		#LEVEL ICON END
	
	#EPISODE END
	
	
	#Load saved level states.
	
	# Additional levels
	if Globals.selected_episode == "Additional Levels":
		for icon in get_tree().get_nodes_in_group("level_icon"):
			icon.level_state = LevelTransition.get_node("%saved_progress").get("state_BONUS_" + str(icon.level_number))
			icon.level_score = LevelTransition.get_node("%saved_progress").get("score_BONUS_" + str(icon.level_number))
			print("Saved level completion state: ", icon.level_state)
		
		Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_BONUS")
	
	#Main Levels
	elif Globals.selected_episode == "Main Levels":
		Globals.current_levelSet_ID = "MAIN"
		
		for icon in get_tree().get_nodes_in_group("level_icon"):
			icon.level_state = LevelTransition.get_node("%saved_progress").get("state_MAIN_" + str(icon.level_number))
			icon.level_score = LevelTransition.get_node("%saved_progress").get("score_MAIN_" + str(icon.level_number))
			icon.is_main_level = true
			print("Saved level completion state: ", icon.level_state)
		
		
		LevelTransition.get_node("%saved_progress").count_total_score("MAIN", 13)
		total_score = LevelTransition.get_node("%saved_progress").get("total_score")
		
		#Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_MAIN")
	
	
	Globals.progress_loadingFinished.emit()
	print(Globals.selected_episode)
	$level_icon_container/level_button_root/level_button.grab_focus()
	%ColorRect.visible = true
	%fade_animation.play("fade_from_black")
	
	await get_tree().create_timer(0.1, false).timeout
	
	var x = 0
	for button in get_tree().get_nodes_in_group("buttons_root") + get_tree().get_nodes_in_group("buttons_deco"):
		button.z_index = x
		x += 1
	
	for button in get_tree().get_nodes_in_group("buttons"):
		button.moving = true


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
	await LevelTransition.fade_to_black_slow()
	get_tree().change_scene_to_packed(main_menu)


func _on_back_to_overworld_pressed():
	var saved_level = load(SavedData.saved_last_area_filePath)
	
	#DEBUG
	if saved_level == load("res://Levels/empty.tscn"):
		saved_level = load("res://Levels/overworld_infected_glades.tscn")
	
	await LevelTransition.fade_to_black()
	Globals.transitioned = false
	get_tree().change_scene_to_packed(saved_level)
