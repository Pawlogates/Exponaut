extends CenterContainer

var startingArea = preload("res://Levels/overworld_factory.tscn")
var mapScreen = preload("res://Other/Scenes/Level Select/screen_levelSelect.tscn")

var block_button_sounds = true 

func _ready():
	LevelTransition.get_node("%saved_progress").load_game()
	last_area_filePath_load()
	
	hide_everything()
	correct_toggle_buttons()
	
	LevelTransition.fade_from_black()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#DEBUG
	%main_menu.visible = true
	%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_appearance(1, 1, true, 2000)
	
	if SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		%StartGame.grab_focus()
	else:
		%Continue.grab_focus()
	
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	await get_tree().create_timer(0.5, false).timeout
	%fade_animation.play("fade_from_black")
	correct_button_ordering()
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


#SELECTED EPISODE
func _on_episode_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(mapScreen)
	LevelTransition.fade_from_black()


func _on_fade_animation_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		SavedData.savedData_load()
		
		#%background.texture = preload("res://Assets/Graphics/backgrounds/bg_forest_dark.png")
		
		%fade_animation.play("fade_from_black")
		
		%menu_deco_bg.visible = true
		%menu_deco_bg.process_mode = Node.PROCESS_MODE_ALWAYS
		
		$AudioStreamPlayer2D.play()


func menu_appearance(group_number, anim_number, randomize_value, value_range): # Set anim_number to 0 for random animation.
	for button in get_tree().get_nodes_in_group("buttons"):
		button.showing_up = false
		button.moving = false
	
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


#BUTTONS
func _on_start_game_pressed():
	start_game()

func _on_quit_pressed():
	get_tree().quit()

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
	
	menu_appearance(6, 0, true, 2000)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%"Additional Levels".grab_focus()

func _on_options_pressed():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.5
	%menu_deco_bg_root.multiplier_H = 1.5
	%menu_deco_bg_root.position_target = Vector2(25, -325)
	
	menu_appearance(2, 2, false, 5)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%Graphics.grab_focus()

func _on_graphics_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-430, -340)
	
	menu_appearance(3, 2, true, 3)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%Resolution.grab_focus()

func _on_resolution_pressed():
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%resolution_menu.visible = true
	%resolution_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.8
	%menu_deco_bg_root.multiplier_H = 1.2
	%menu_deco_bg_root.position_target = Vector2(-380, -340)
	
	menu_appearance(8, 1, true, 2000)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%AutoResolution.grab_focus()

func _on_refreshrate_pressed():
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%refreshrate_menu.visible = true
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.1
	%menu_deco_bg_root.multiplier_H = 0.7
	%menu_deco_bg_root.position_target = Vector2(-300, -100)
	
	menu_appearance(9, 0, true, 2000)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%AutoRefreshrate.grab_focus()

func _on_audio_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%audio_menu.visible = true
	%audio_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.1
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-375, -200)
	
	menu_appearance(4, 0, true, 2000)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%"Music +".grab_focus()

func _on_cheats_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%cheats_menu.visible = true
	%cheats_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.9
	%menu_deco_bg_root.multiplier_H = 0.7
	%menu_deco_bg_root.position_target = Vector2(-400, -150)
	
	menu_appearance(7, 3, true, 2)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%"Toggle Quicksaves".grab_focus()

func _on_other_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%other_menu.visible = true
	%other_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-400, -350)
	
	menu_appearance(5, 0, true, 2000)
	deco_correct_polygons()
	
	await get_tree().create_timer(0.2, false).timeout
	%"User Interface Type".grab_focus()




#RETURN BUTTONS
func _on_returnOptions_pressed():
	%main_menu.visible = true
	%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 1
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-350, -200)
	
	menu_appearance(1, 1, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	if SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		%StartGame.grab_focus()
	else:
		%Continue.grab_focus()

func _on_returnGraphics_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.8
	%menu_deco_bg_root.multiplier_H = 1.2
	%menu_deco_bg_root.position_target = Vector2(-120, -348)
	
	menu_appearance(2, 0, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	%Graphics.grab_focus()

func _on_return_resolution_pressed():
	%resolution_menu.visible = false
	%resolution_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.1
	%menu_deco_bg_root.multiplier_H = 0.9
	%menu_deco_bg_root.position_target = Vector2(-375, -275)
	
	menu_appearance(3, 0, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	%Resolution.grab_focus()

func _on_return_refreshrate_pressed():
	%refreshrate_menu.visible = false
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.8
	%menu_deco_bg_root.multiplier_H = 0.6
	%menu_deco_bg_root.position_target = Vector2(-400, -300)
	
	menu_appearance(3, 0, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	%Refreshrate.grab_focus()

func _on_return_audio_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%audio_menu.visible = false
	%audio_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 1
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-350, -350)
	
	menu_appearance(2, 0, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	%Audio.grab_focus()

func _on_return_other_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%other_menu.visible = false
	%other_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.4
	%menu_deco_bg_root.position_target = Vector2(-360, -320)
	
	menu_appearance(2, 0, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	%Cheats.grab_focus()

func _on_return_cheats_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%cheats_menu.visible = false
	%cheats_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.8
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(0, -348)
	
	menu_appearance(2, 0, true, 2000)
	
	await get_tree().create_timer(0.2, false).timeout
	%Cheats.grab_focus()


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
	if dir.file_exists("user://savegame_overworld_factory.save"):
		dir.remove("user://savegame_overworld_factory.save")
	if dir.file_exists("user://savegame_overworld_glades.save"):
		dir.remove("user://savegame_overworld_glades.save")
	if dir.file_exists("user://savegame_overworld_infected_glades.save"):
		dir.remove("user://savegame_overworld_infected_glades.save")
	
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


func correct_button_ordering():
	var x = 0
	for button in get_tree().get_nodes_in_group("buttons_root") + get_tree().get_nodes_in_group("buttons_deco"):
		button.z_index = x
		x += 1

func deco_correct_polygons():
	for button in get_tree().get_nodes_in_group("buttons"):
		if button.has_method("correct_polygons()"):
			button.correct_polygons()


func _process(_delta):
	pass
	#if Input.is_action_just_pressed("show_debugInfo"):
		#var x = 0
		#for button in get_tree().get_nodes_in_group("buttons"):
			#button.z_index = x
			#print(button.z_index)
			#x += 1


@onready var block_button_sounds_timer = $block_button_sounds

func _on_block_button_sounds_timeout() -> void:
	print("Button sounds no longer blocked.")
	block_button_sounds = false
