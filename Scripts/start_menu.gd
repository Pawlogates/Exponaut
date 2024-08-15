extends CenterContainer

var startingArea = preload("res://Levels/overworld_factory.tscn")
var mapScreen = preload("res://Other/Scenes/Level Select/screen_levelSelect.tscn")

func _ready():
	last_area_filePath_load()
	LevelTransition.get_node("%saved_progress").load_game()
	hide_everything()
	correct_toggle_buttons()
	
	#DEBUG
	%main_menu.visible = true
	%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	if SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		%StartGame.grab_focus()
	else:
		%Continue.grab_focus()
	
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	await get_tree().create_timer(0.5, false).timeout
	%fade_animation.play("fade_from_black")
	await get_tree().create_timer(3, false).timeout
	%fade_animation.play("fade_to_black")


var saved_level_filePath = "res://Levels/empty.tscn"
var saved_level = load("res://Levels/empty.tscn")

func start_game(): #starts a brand new playthrough and deletes save files
	delete_saves()
	SavedData.savedData_reset()
	
	Globals.transitioned = false
	Globals.next_transition = 0
	Globals.just_started_new_game = true
	
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(startingArea)


func _on_continue_pressed():
	if SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		return
	
	print(str(saved_level) + " is the file path of the saved last area level that you are loading into.")
	saved_level = load(saved_level_filePath)
	Globals.transitioned = false
	Globals.next_transition = 0
	
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(saved_level)


func _on_levels_pressed():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%episodeSelect_menu.visible = true
	%episodeSelect_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%"Additional Levels".grab_focus()


#SELECTED EPISODE
func _on_episode_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(mapScreen)
	LevelTransition.fade_from_black()


func _on_fade_animation_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		SavedData.savedData_load()
		
		%background.texture = preload("res://Assets/Graphics/backgrounds/bg_forest_dark.png")
		
		%fade_animation.play("fade_from_black")
		
		%menu_deco_bg.visible = true
		%menu_deco_bg.process_mode = Node.PROCESS_MODE_ALWAYS
		
		$AudioStreamPlayer2D.play()


#BUTTONS
func menu_appearance(group_number, anim_number, randomize_value, value_range): # set anim_number to 0 for random animation.
	for button in get_tree().get_nodes_in_group("group" + str(group_number)):
		button.showing_up = false
		button.modulate.a = 0
		
		if button.size.x > 960:
			button.size.x = 960
		button.pivot_offset = Vector2(0, 0)
	
	var button_number = 0
	for button in get_tree().get_nodes_in_group("group" + str(group_number)):
		button_number += 1
		button.moving = true
		
		if anim_number == 0:
			anim_number = randi_range(1, 3)
		
		if randomize_value:
			value_range = randf_range(-value_range, value_range)
			button.pivot_offset = Vector2(randf_range(0, size.x), randf_range(0, size.y))
		
		await get_tree().create_timer(0.025 * button_number, false).timeout
		button.showing_up = true
		
		if anim_number == 1:
			button.position.x = value_range
		elif anim_number == 2:
			if abs(value_range) > 5:
				value_range = 5
			button.rotation = value_range
		elif anim_number == 3:
			if abs(value_range) > 10:
				value_range = 10
			button.scale = Vector2(abs(value_range), abs(value_range))


func _on_start_game_pressed():
	start_game()


func _on_quit_pressed():
	get_tree().quit()


func _on_options_pressed():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Graphics.grab_focus()
	
	menu_appearance(2, 2, false, 5)


func _on_graphics_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-430, -340)
	
	%Resolution.grab_focus()
	
	menu_appearance(3, 2, true, 3)


func _on_resolution_pressed():
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%resolution_menu.visible = true
	%resolution_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.8
	%menu_deco_bg_root.position_target = Vector2(-424, -348)
	
	%AutoResolution.grab_focus()
	
	menu_appearance(8, 1, true, 2000)


func _on_refreshrate_pressed():
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%refreshrate_menu.visible = true
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 0.8
	%menu_deco_bg_root.position_target = Vector2(-452, -196)
	
	%AutoRefreshrate.grab_focus()
	
	menu_appearance(9, 0, true, 2000)


func _on_audio_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%audio_menu.visible = true
	%audio_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.1
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-400, -250)
	
	%"Music +".grab_focus()
	
	menu_appearance(4, 0, true, 2000)


func _on_cheats_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%cheats_menu.visible = true
	%cheats_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.9
	%menu_deco_bg_root.multiplier_H = 0.7
	%menu_deco_bg_root.position_target = Vector2(-160, -240)
	
	%"Toggle Quicksaves".grab_focus()
	
	menu_appearance(7, 3, true, 2)


func _on_other_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%other_menu.visible = true
	%other_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%"User Interface Type".grab_focus()
	
	menu_appearance(5, 0, true, 2000)




#RETURN BUTTONS
func _on_returnOptions_pressed():
	%main_menu.visible = true
	%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 1
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-400, -348)
	
	if SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		%StartGame.grab_focus()
	else:
		%Continue.grab_focus()
	
	menu_appearance(1, 1, true, 2000)


func _on_returnGraphics_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.9
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-120, -348)
	
	%Graphics.grab_focus()
	
	menu_appearance(2, 0, true, 2000)


func _on_return_resolution_pressed():
	%resolution_menu.visible = false
	%resolution_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%Resolution.grab_focus()
	
	menu_appearance(3, 0, true, 2000)


func _on_return_refreshrate_pressed():
	%refreshrate_menu.visible = false
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%Refreshrate.grab_focus()
	
	menu_appearance(3, 0, true, 2000)


func _on_return_audio_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%audio_menu.visible = false
	%audio_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 1
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Audio.grab_focus()
	
	menu_appearance(2, 0, true, 2000)


func _on_return_other_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%other_menu.visible = false
	%other_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.4
	%menu_deco_bg_root.position_target = Vector2(-360, -320)
	
	%Cheats.grab_focus()
	
	menu_appearance(2, 0, true, 2000)


func _on_return_cheats_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%cheats_menu.visible = false
	%cheats_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.8
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(0, -348)
	
	%Cheats.grab_focus()
	
	menu_appearance(2, 0, true, 2000)


func _on_toggle_quicksaves_pressed():
	if Globals.quicksaves_enabled == true:
		Globals.quicksaves_enabled = false
		%"Toggle Quicksaves"/RichTextLabel.text = "[wave amp=50.0 freq=10.0 connected=1]Enable Quicksaves[/wave]"
	
	elif Globals.quicksaves_enabled == false:
		Globals.quicksaves_enabled = true
		%"Toggle Quicksaves"/RichTextLabel.text = "[wave amp=50.0 freq=10.0 connected=1]Disable Quicksaves[/wave]"


func display_stretch_viewport_on():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT


func display_stretch_viewport_off():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED


func last_area_filePath_load():
	if SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		print("The saved_last_area_filePath property is default (res://Levels/empty.tscn), so the Continue option is blocked.")
		#%Continue.process_mode = Node.PROCESS_MODE_DISABLED
		%Continue.disabled = true
		%Continue.get_parent().modulate.b = 0.3
		%Continue.get_parent().modulate.g = 0.3
		%Continue.get_parent().modulate.a = 0.5
		
		return
	
	saved_level_filePath = SavedData.saved_last_area_filePath


func delete_saves():
	var dir = DirAccess.open("user://")
	
	#general player progress
	if dir.file_exists("user://savedData.save"):
		dir.remove("user://savedData.save")
	
	#level select progress (top scores, level completion states, etc.)
	if dir.file_exists("user://saved_progress.save"):
		dir.remove("user://saved_progress.save")
	
	#quicksave (non-specific level state)
	if dir.file_exists("user://savegame.save"):
		dir.remove("user://savegame.save")
	
	#area states
	if dir.file_exists("user://savegame_theBeginning.save"):
		dir.remove("user://savegame_theBeginning.save")
	if dir.file_exists("user://savegame_overworld.save"):
		dir.remove("user://savegame_overworld.save")
	if dir.file_exists("user://savegame_overworld.save"):
		dir.remove("user://savegame_overworld2.save")
	
	if dir.file_exists("user://filename.save"):
		dir.remove("user://filename.save")


func hide_everything():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%resolution_menu.visible = false
	%resolution_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%refreshrate_menu.visible = false
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%audio_menu.visible = false
	%audio_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%cheats_menu.visible = false
	%cheats_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%other_menu.visible = false
	%other_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%ColorRect.visible = true
	
	%menu_deco_bg.visible = false
	%menu_deco_bg.process_mode = Node.PROCESS_MODE_DISABLED


func correct_toggle_buttons():
	if Globals.quicksaves_enabled == true:
		%"Toggle Quicksaves"/RichTextLabel.text = "[wave amp=50.0 freq=10.0 connected=1]Disable Quicksaves[/wave]"
	
	elif Globals.quicksaves_enabled == false:
		%"Toggle Quicksaves"/RichTextLabel.text = "[wave amp=50.0 freq=10.0 connected=1]Enable Quicksaves[/wave]"


func _on_user_interface_type_pressed():
	pass # Replace with function body.
