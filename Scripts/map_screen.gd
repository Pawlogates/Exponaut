extends CenterContainer

var saved_progress : Node2D

var level_icon_scene = load("res://Other/Scenes/Level Select/level_button.tscn")
var main_menu = load("res://Other/Scenes/menu_start.tscn")

var current_level_number = 0
var highest_level_number = 0
var total_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	saved_progress = LevelTransition.get_node("%saved_progress")
	saved_progress.load_game()
	print(str(Globals.selected_episode) + " is the currently selected Level Set.")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	#EPISODE START
	
	if Globals.selected_episode == "Main Levels":
		%background.texture = load("res://Assets/Graphics/other/levelSelect_screen.png")
		place_levelSet_icons("MAIN")
		
	#EPISODE END
	
	
	#EPISODE START
	
	if Globals.selected_episode == "Debug Levels":
		#%background.texture = load("res://Assets/Graphics/other/levelSelect_screen.png")
		place_levelSet_icons("DEBUG")
		
		# DEBUG - OVERWORLD AREAS
		place_level_icon(2, Vector2(540, -240), load("res://Levels/overworld_factory.tscn"))
		place_level_icon(2, Vector2(540, -180), load("res://Levels/overworld_infected_glades.tscn"))
		place_level_icon(2, Vector2(540, -120), load("res://Levels/overworld_glades.tscn"))
		place_level_icon(2, Vector2(540, -60), load("res://Levels/overworld_ascent.tscn"))
		place_level_icon(2, Vector2(600, -60), load("res://Levels/overworld_castle.tscn"))
	
	#EPISODE END
	
	
	# Load saved level states.
	
	# Main Levels
	if Globals.selected_episode == "Main Levels":
		Globals.current_levelSet_ID = "MAIN"
		
		for icon in get_tree().get_nodes_in_group("level_icon"):
			var level_saved_state = saved_progress.get(str("state_", Globals.current_levelSet_ID, "_", icon.level_number))
			var level_saved_score = saved_progress.get(str("score_", Globals.current_levelSet_ID, "_", icon.level_number))
			icon.level_state = level_saved_state
			icon.level_score = level_saved_score
			print("Saved level completion state: ", icon.level_state)
			
			icon.is_main_level = true
		
		
		saved_progress.count_total_score(Globals.current_levelSet_ID, 7)
		total_score = saved_progress.get("total_score")
		
		#Globals.next_level = LevelTransition.get_node("%saved_progress").get("next_level_MAIN")
	
	
	# Bonus levels
	if Globals.selected_episode == "Bonus Levels":
		Globals.current_levelSet_ID = "BONUS"
		
		for icon in get_tree().get_nodes_in_group("level_icon"):
			var level_saved_state = saved_progress.get(str("state_", Globals.current_levelSet_ID, "_", icon.level_number))
			var level_saved_score = saved_progress.get(str("score_", Globals.current_levelSet_ID, "_", icon.level_number))
			icon.level_state = level_saved_state
			icon.level_score = level_saved_score
			#print("Saved level completion state: ", icon.level_state)
		
		saved_progress.count_total_score(Globals.current_levelSet_ID, 7)
		total_score = saved_progress.get("total_score")
		
		Globals.next_level = saved_progress.get("next_level_BONUS")
	
	
	# Debug Levels
	elif Globals.selected_episode == "Debug Levels":
		pass
	
	
	Globals.progress_loadingFinished.emit()
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
	
	current_level_number += 1
	
	var level_icon = level_icon_scene.instantiate()
	
	level_icon.icon_ID = Icon_ID
	level_icon.icon_position = Position
	level_icon.icon_level_filePath = Level_FilePath
	
	level_icon.level_number = current_level_number
	
	%level_icon_container.add_child(level_icon)


func _on_enable_score_attack_mode_pressed():
	if Globals.mode_scoreAttack == false:
		Globals.mode_scoreAttack = true
		$"menu_main/menu_container/Control/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Disable Score Attack Mode[/wave]"
		
	elif Globals.mode_scoreAttack == true:
		Globals.mode_scoreAttack = false
		$"menu_main/menu_container/Control/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Enable Score Attack Mode[/wave]"


func _on_main_menu_pressed():
	if check_if_buttons_blocked():
		return
	
	await LevelTransition.fade_to_black_slow()
	get_tree().change_scene_to_packed(main_menu)


func _on_back_to_overworld_pressed():
	if check_if_buttons_blocked():
		return
	
	var saved_level = load(SavedData.saved_last_area_filePath)
	
	#DEBUG
	if saved_level == load("res://Levels/empty.tscn"):
		saved_level = load("res://Levels/overworld_infected_glades.tscn")
	
	await LevelTransition.fade_to_black()
	Globals.transitioned = false
	get_tree().change_scene_to_packed(saved_level)


var buttons_blocked = false
func check_if_buttons_blocked():
	if buttons_blocked:
		print("Buttons are blocked.")
		return true
	buttons_blocked = true

func _on_buttons_blocked_timeout() -> void:
	print("Button are no longer blocked.")
	buttons_blocked = false


func place_levelSet_icons(ID):
	var level_number_max = 99
	for level_number in range(1, level_number_max):
		var level_info_ID = "info_" + str(ID) + "_" + str(level_number)
		
		print(level_number)
		print(level_info_ID)
		print(saved_progress.get(level_info_ID))
		
		if saved_progress.get(level_info_ID) == null:
			break
		if not FileAccess.file_exists("res://Levels/" + str(ID) + "_" + str(level_number) + ".tscn"):
			break
		
		var info_MAIN = saved_progress.get(level_info_ID)
		place_level_icon(info_MAIN[1], Vector2(info_MAIN[2], info_MAIN[3]), load("res://Levels/" + str(ID) + "_" + str(level_number) + ".tscn"))
		
		highest_level_number = level_number
