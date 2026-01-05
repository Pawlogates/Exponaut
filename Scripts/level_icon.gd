extends Button

@onready var screen_levelSet = get_parent()

@export var icon_image_id = 0
@export var icon_position = Vector2(0, 0)
@export var icon_level_filepath : String

var level_saved = SaveData.default_saved_level # The saved (in the "SaveData" global node, and the "levelSet" save files) array of best results for each category achieved by the player.
var level_info = SaveData.default_info_level
var level_unlock = SaveData.default_unlock_level
var level_major_collectibles = SaveData.default_collectibles_level

var levelSet_id = "none"

var level_number = 0
var level_id = "none" # Example: "MAIN_1".

var level_state = -1
var level_score = -1
var level_score_target = -1
var level_time = -1
var level_time_target = -1
var level_rank = "none"
var level_rank_value = -1
var level_name = "none"
var level_type = "none"
var level_creator = "none"
var level_message = "none"
var level_difficulty = "none"

var level_icon_id = 0
var level_icon_position_x = 0
var level_icon_position_y = 0

var level_unlockMethod_previous = true
var level_unlockMethod_portal_in_level_id = "none"
var level_unlockMethod_key_in_level_id = "none"
var level_unlockMethod_score_in_level_id = "none"
var level_unlockMethod_score_in_levelSet_id = "none"
var level_unlockMethod_score_in_overworld_levelSet_id = "none"
var level_unlockMethod_time_in_level_id = "none"
var level_unlockMethod_time_in_levelSet_id = "none"

var level_saved_major_collectibles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var level_info_major_collectibles = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # Each value represents a major collectible SLOT, which should always match a major collectible placed in the matching level.

var unlocked = false


func _ready():
	Globals.wait(self, 3.0)
	position = Vector2(level_icon_position_x, level_icon_position_y)
	level_id = Globals.levelSet_id + "_" + str(level_number)
	update_level_info()
	if level_state > -1 : unlocked = true
	
	position = icon_position
	%icon.region_rect = Rect2(64 * icon_image_id, 448, 64, 64)
	%AnimationPlayer.advance((abs(position.x) / 100))
	
	await Globals.levelSet_loaded
	
	if level_state == 0:
		pass
	elif level_state == 1:
		%icon_state_finished.visible = true
	elif level_state == 2:
		%icon_state_allMajorCollectibles.visible = true
	elif level_state == 3:
		%icon_state_allCollectibles.visible = true


func _on_pressed():
	if unlocked or Globals.debug_mode:
		Globals.transition_next = 0
		%level_start.play()
		Overlay.animation("fade_black", true, true, 1.0)
		get_tree().change_scene_to_packed(load(icon_level_filepath))
		Overlay.animation("fade_black", false, true, 1.0)
		
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
	
	var display_level_info = Globals.levelSet_display_level_info.instantiate()
	update_level_info()


func _on_mouse_exited():
	%level_icon.scale = Vector2(1.0, 1.0)
	modulate.b = 1.0
	modulate.g = 1.0
	%glow_root.modulate.a = 1.0
	
	get_parent().get_node("%level_info_container").visible = false

func update_level_info():
	if Globals.levelSet_id == "none" : return
	
	levelSet_id = Globals.levelSet_id
	level_id = levelSet_id + "_" + str(level_number)
	
	level_saved = SaveData.get("saved_" + level_id)
	level_info = SaveData.get("info_" + level_id)
	level_unlock = SaveData.get("unlock_" + level_id)
	level_major_collectibles = SaveData.get("collectibles_" + level_id)
	
	# saved : [state, score, time, major_collectibles]
	# info : [name, icon_id, icon_position_x, icon_position_y, score_target, time_target, creator, message, difficulty, type]
	# unlock : [previous, portal_in_level_id, key_in_level_id, score_in_level_id, score_in_levelSet_id, score_in_overworld_levelSet_id, time_in_level_id, time_in_levelSet_id]
	# collectibles : [[slot 1 - major collectible exists in a level], [slot 2 - major collectible exists in a level], etc.]
	
	print(levelSet_id)
	print(level_number)
	print(level_id)
	level_state = level_saved[0]
	level_score = level_saved[1]
	level_time = level_saved[2]
	level_saved_major_collectibles = level_saved[3]
	
	level_name = level_info[0]
	level_icon_id = level_info[1]
	level_icon_position_x = level_info[2]
	level_icon_position_y = level_info[3]
	level_score_target = level_info[4]
	level_time_target = level_info[5]
	level_creator = level_info[6]
	level_message = level_info[7]
	level_difficulty = level_info[8]
	level_type = level_info[9]
	
	level_unlockMethod_previous = level_unlock[0]
	level_unlockMethod_portal_in_level_id = level_unlock[1]
	level_unlockMethod_key_in_level_id = level_unlock[2]
	level_unlockMethod_score_in_level_id = level_unlock[3]
	level_unlockMethod_score_in_levelSet_id = level_unlock[4]
	level_unlockMethod_score_in_overworld_levelSet_id = level_unlock[5]
	level_unlockMethod_time_in_level_id = level_unlock[6]
	level_unlockMethod_time_in_levelSet_id = level_unlock[7]
	
	level_info_major_collectibles = level_major_collectibles
	
	var level_rank_info = SaveData.calculate_rank_level(level_id)
	level_rank = level_rank_info[0]
	level_rank_value = level_rank_info[1]

func show_display_level_info(display):
	var display_level_info = Globals.scene_levelSet_display_level_info.instantiate()
	
	display_level_info.levelSet_id = levelSet_id
	display_level_info.level_id = level_id
	
	display_level_info.level_state = level_state
	display_level_info.level_score = level_score
	display_level_info.level_time = level_time
	display_level_info.level_saved_major_collectibles = level_saved_major_collectibles
	
	display_level_info.level_name = level_name
	display_level_info.level_icon_id = level_icon_id
	display_level_info.level_icon_position_x = level_icon_position_x
	display_level_info.level_icon_position_y = level_icon_position_y
	display_level_info.level_score_target = level_score_target
	display_level_info.level_time_target = level_time_target
	display_level_info.level_creator = level_creator
	display_level_info.level_message = level_message
	display_level_info.level_difficulty = level_difficulty
	display_level_info.level_type = level_type
	
	display_level_info.level_unlockMethod_previous = level_unlockMethod_previous
	display_level_info.level_unlockMethod_portal_in_level_id = level_unlockMethod_portal_in_level_id
	display_level_info.level_unlockMethod_key_in_level_id = level_unlockMethod_key_in_level_id
	display_level_info.level_unlockMethod_score_in_level_id = level_unlockMethod_score_in_level_id
	display_level_info.level_unlockMethod_score_in_levelSet_id = level_unlockMethod_score_in_level_id
	display_level_info.level_unlockMethod_score_in_overworld_levelSet_id = level_unlockMethod_score_in_overworld_levelSet_id
	display_level_info.level_unlockMethod_time_in_level_id = level_unlockMethod_time_in_level_id
	display_level_info.level_unlockMethod_time_in_levelSet_id = level_unlockMethod_time_in_levelSet_id
	
	display_level_info.level_info_major_collectibles = level_info_major_collectibles
	
	var level_rank_info = SaveData.calculate_rank_level(level_id)
	display_level_info.level_rank = level_rank_info[0]
	display_level_info.level_rank_value = level_rank_info[1]
	
	screen_levelSet.add_child(display_level_info)
