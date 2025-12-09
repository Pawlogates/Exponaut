extends Node2D

@export var icon_image_id = 0
@export var icon_position = Vector2(0, 0)
@export var icon_level_filepath : String

var level_number = 0

var level_state = -1
var level_score = -1
var level_score_target = -1

var unlocked = false

var level_info = ["none", -1, -1, -1, -1, -1]

func _ready():
	position = icon_position
	%level_icon.region_rect = Rect2(64 * icon_image_id, 448, 64, 64)
	%AnimationPlayer.advance(abs(position) / 200)
	
	%icon_levelFinished.visible = false
	
	
	await Globals.save_levelSet_loaded
	if not is_main_level and level_number <= Globals.next_level:
		unlocked = true
		
	elif level_state != 0:
		unlocked = true
		
	
	print("Level " + str(level_number) + "'s completion state is: " + str(level_state))
	
	if level_state == 0:
		pass
	elif level_state == 1:
		%icon_levelFinished.visible = true
	elif level_state == 2:
		%icon_levelAllBigApplesCollected.visible = true
	elif level_state == 3:
		%icon_levelAllCollectiblesCollected.visible = true
	
	
	if Globals.levelSet_id == "MAIN":
		level_info = SaveData.get(str("info_MAIN_", level_number))
		level_score_target = level_info[4]
	
	elif Globals.levelSet_id == "BONUS":
		level_info = SaveData.get(str("info_BONUS_", level_number))
		level_score_target = level_info[4]
	
	elif Globals.levelSet_id == "DEBUG":
		level_info = SaveData.get(str("info_DEBUG_", level_number))
		level_score_target = level_info[4]
	
	%level_button.mouse_filter = 1


func _on_pressed():
	if unlocked or Globals.debug_mode or Globals.selected_episode == "Debug Levels":
		Globals.next_transition = 0
		Globals.load_saved_position = false
		%level_start.play()
		await LevelTransition.fade_to_black_slow()
		get_tree().change_scene_to_packed(icon_level_filePath)
		LevelTransition.fade_from_black_slow()
		
		if Globals.selected_episode == "Main Levels":
			Globals.current_level_ID = str("MAIN_", level_number)
			Globals.current_level_number = level_number
		
		elif Globals.selected_episode == "Bonus Levels":
			Globals.current_level_ID = str("BONUS_", level_number)
			Globals.current_level_number = level_number
		
		elif Globals.selected_episode == "Debug Levels":
			Globals.current_level_ID = str("DEBUG_", level_number)
			Globals.current_level_number = level_number
		
	else:
		%level_locked.play()


func _on_focus_entered():
	%level_icon.scale = Vector2(1.1, 1.1)
	
	if unlocked:
		modulate.b = 0.5
	else:
		modulate.b = 0.3
		modulate.g = 0.3
		
	%glow_root.modulate.a = 0.5
	
	get_parent().get_node("%level_info_container").visible = true
	update_level_info()


func _on_focus_exited():
	%level_icon.scale = Vector2(1.0, 1.0)
	modulate.b = 1.0
	modulate.g = 1.0
	%glow_root.modulate.a = 1.0
	
	get_parent().get_node("%level_info_container").visible = false


func _on_mouse_entered():
	%level_icon.scale = Vector2(1.1, 1.1)
	
	if unlocked:
		modulate.b = 0.5
	else:
		modulate.b = 0.3
		modulate.g = 0.3
	
	%glow_root.modulate.a = 0.5
	
	update_level_info()
	get_parent().get_node("%level_info_container").visible = true


func _on_mouse_exited():
	%level_icon.scale = Vector2(1.0, 1.0)
	modulate.b = 1.0
	modulate.g = 1.0
	%glow_root.modulate.a = 1.0
	
	get_parent().get_node("%level_info_container").visible = false


func update_level_info():
	var rank_info = saved_progress.calculate_rank(topRankScore, level_score)
	var rank = rank_info[0]
	
	get_parent().get_node("%score").text = str(level_score)
	get_parent().get_node("%name").text = str(level_info[0])
	get_parent().get_node("%rank").text = str(rank)
	get_parent().get_node("%top_rank_score").text = "Score target: " + str(level_info[4])
