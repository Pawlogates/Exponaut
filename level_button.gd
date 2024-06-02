extends Node2D

@export var icon_ID = 0
@export var icon_position = Vector2(0, 0)
@export var icon_level_filePath = preload("res://Levels/RI1_1.tscn")

var level_number = 0

var level_state = 0
var level_score = 0
var topRankScore = 0

var unlocked = false
var is_main_level = false

func _ready():
	%level_icon.region_rect = Rect2(64 * icon_ID, 448, 64, 64)
	position = icon_position
	
	var xpos = self.global_position.x
	%AnimationPlayer.advance(abs(xpos) / 200)
	
	%icon_levelFinished.visible = false
	
	
	
	#set level button state
	await Globals.progress_loadingFinished
	if not is_main_level and level_number <= Globals.next_level:
		unlocked = true
		
	elif level_state != 0:
		unlocked = true
		
	
	print(level_state)
	
	if level_state == 0:
		pass
	elif level_state == 1:
		%icon_levelFinished.visible = true
	elif level_state == 2:
		%icon_levelAllBigApplesCollected.visible = true
	elif level_state == 3:
		%icon_levelAllCollectiblesCollected.visible = true
	
	
	if Globals.selected_episode == "Additional Levels":
		if level_number == 1:
			topRankScore = 50000
		elif level_number == 2:
			topRankScore = 50000
		elif level_number == 3:
			topRankScore = 50000
		elif level_number == 4:
			topRankScore = 50000
		elif level_number == 5:
			topRankScore = 50000
		elif level_number == 6:
			topRankScore = 50000
		elif level_number == 7:
			topRankScore = 50000
		elif level_number == 8:
			topRankScore = 50000
		elif level_number == 9:
			topRankScore = 50000
		elif level_number == 10:
			topRankScore = 50000
		elif level_number == 11:
			topRankScore = 50000
	
	elif Globals.selected_episode == "Main Levels":
		if level_number == 1:
			topRankScore = 50000
		elif level_number == 2:
			topRankScore = 50000
		elif level_number == 3:
			topRankScore = 50000
		elif level_number == 4:
			topRankScore = 50000
		elif level_number == 5:
			topRankScore = 50000
		elif level_number == 6:
			topRankScore = 50000
		elif level_number == 7:
			topRankScore = 50000
		elif level_number == 8:
			topRankScore = 50000
		elif level_number == 9:
			topRankScore = 50000
		elif level_number == 10:
			topRankScore = 50000
		elif level_number == 11:
			topRankScore = 50000
		elif level_number == 12:
			topRankScore = 50000
		elif level_number == 13:
			topRankScore = 50000
	
	
	
	
	
	%level_button.mouse_filter = 1




func _on_pressed():
	if unlocked:
		Globals.next_transition = 0
		%level_start.play()
		await LevelTransition.fade_to_black_slow()
		get_tree().change_scene_to_packed(icon_level_filePath)
		LevelTransition.fade_from_black_slow()
		
		if Globals.selected_episode == "Additional Levels":
			Globals.current_level_ID = str("RI1_", level_number)
			Globals.current_level_number = level_number
			
		elif Globals.selected_episode == "Main Levels":
			Globals.current_level_ID = str("MAIN_", level_number)
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
	get_parent().get_node("%score").text = str(level_score)


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
	get_parent().get_node("%level_info_container").visible = true
	get_parent().get_node("%score").text = str(level_score)


func _on_mouse_exited():
	%level_icon.scale = Vector2(1.0, 1.0)
	modulate.b = 1.0
	modulate.g = 1.0
	%glow_root.modulate.a = 1.0
	get_parent().get_node("%level_info_container").visible = false
	
