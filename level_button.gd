extends Node2D

@export var icon_ID = 0
@export var icon_position = Vector2(0, 0)
@export var icon_level_filePath = preload("res://Levels/RI1_1.tscn")

var level_ID = 0

var level_state = 0
var level_score = 0
var topRankScore = 0

var unlocked = false

func _ready():
	%level_icon.region_rect = Rect2(64 * icon_ID, 448, 64, 64)
	position = icon_position
	
	var xpos = self.global_position.x
	%AnimationPlayer.advance(abs(xpos) / 200)
	
	%icon_levelFinished.visible = false
	
	
	
	#set level button state
	await Globals.progress_loadingFinished
	if level_ID <= Globals.next_level:
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
	
	
	if Globals.selected_episode == "rooster_island":
		if level_ID == 1:
			topRankScore = 50000
		elif level_ID == 2:
			topRankScore = 50000
		elif level_ID == 3:
			topRankScore = 50000
		elif level_ID == 4:
			topRankScore = 50000
		elif level_ID == 5:
			topRankScore = 50000
		elif level_ID == 6:
			topRankScore = 50000
		elif level_ID == 7:
			topRankScore = 50000
		elif level_ID == 8:
			topRankScore = 50000
		elif level_ID == 9:
			topRankScore = 50000
		elif level_ID == 10:
			topRankScore = 50000
		elif level_ID == 11:
			topRankScore = 50000
	
	elif Globals.selected_episode == "rooster_island_2":
		if level_ID == 1:
			topRankScore = 50000
		elif level_ID == 2:
			topRankScore = 50000
		elif level_ID == 3:
			topRankScore = 50000
		elif level_ID == 4:
			topRankScore = 50000
		elif level_ID == 5:
			topRankScore = 50000
		elif level_ID == 6:
			topRankScore = 50000
		elif level_ID == 7:
			topRankScore = 50000
		elif level_ID == 8:
			topRankScore = 50000
		elif level_ID == 9:
			topRankScore = 50000
		elif level_ID == 10:
			topRankScore = 50000
		elif level_ID == 11:
			topRankScore = 50000
		elif level_ID == 12:
			topRankScore = 50000
		elif level_ID == 13:
			topRankScore = 50000
	
	
	
	
	
	%level_button.mouse_filter = 1




func _on_pressed():
	if unlocked:
		%level_start.play()
		await LevelTransition.fade_to_black_slow()
		get_tree().change_scene_to_packed(icon_level_filePath)
		LevelTransition.fade_from_black_slow()
		Globals.next_transition = 0
		
		if Globals.selected_episode == "rooster_island":
			Globals.current_level = str("RI1_", level_ID)
			Globals.current_level_ID = level_ID
			
		elif Globals.selected_episode == "rooster_island_2":
			Globals.current_level = str("RI2_", level_ID)
			Globals.current_level_ID = level_ID
		
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
	
