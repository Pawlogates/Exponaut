extends CenterContainer

var can_quit = true

func _ready():
	Globals.gameState_start_screen = true
	Globals.gameState_levelSet_screen = false
	Globals.gameState_level = false
	Globals.gameState_changed.emit()
	
	Overlay.animation("black_fade_out", 1.0, false, false)
	
	#SaveData.gameplay_recorder.selected_playback_id = 0
	
	#SaveData.load_game_all()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#if SaveData.saved_last_level_filepath == "res://Levels/empty.tscn":
		#$"btn_Start Game".grab_focus()
	#else:
		#$Continue.grab_focus()
	
	RenderingServer.set_default_clear_color(Color.BLACK)


func start_new_game(): #starts a brand new playthrough and deletes save files
	SaveData.reset_levelState()
	SaveData.reset_playerData()
	SaveData.saved_levelState()
	
	Globals.transitioned = false
	Globals.next_transition = 0
	Globals.just_started_new_game = true
	
	Overlay.animation("fade_black", 0, 1.0, true)
	get_tree().change_scene_to_packed(Globals.scene_start_area)


func display_stretch_viewport_on():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	print(get_window().content_scale_mode)


func display_stretch_viewport_off():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	print(get_window().content_scale_mode)


func last_area_filePath_load():
	if SaveData.saved_last_level_filepath == "res://Levels/empty.tscn":
		print("The saved_last_area_filePath property is default (res://Levels/empty.tscn), so the Continue option is blocked.")
		#%Continue.process_mode = Node.PROCESS_MODE_DISABLED
		%Continue.disabled = true
		%Continue.get_parent().modulate.b = 0.3
		%Continue.get_parent().modulate.g = 0.3
		%Continue.get_parent().modulate.a = 0.5
		
		return


#func delete_saves():
	#var dir = DirAccess.open("user://")
	#
	##general player progress
	#if dir.file_exists("user://savedData.save"):
		#dir.remove("user://savedData.save")
	#
	##level select progress (top scores, level completion states, etc.)
	#if dir.file_exists("user://saved_progress.save"):
		#dir.remove("user://saved_progress.save")
	#
	##quicksave (non-specific level state)
	#if dir.file_exists("user://savegame.save"):
		#dir.remove("user://savegame.save")
	#
	##overworld area states
	#if dir.file_exists("user://savegame_overworld_factory.save"):
		#dir.remove("user://savegame_overworld_factory.save")
	#if dir.file_exists("user://savegame_overworld_glades.save"):
		#dir.remove("user://savegame_overworld_glades.save")
	#if dir.file_exists("user://savegame_overworld_infected_glades.save"):
		#dir.remove("user://savegame_overworld_infected_glades.save")
	#
	#if dir.file_exists("user://filename.save"):
		#dir.remove("user://filename.save")


func correct_toggle_buttons():
	if Globals.settings_quicksaves == true:
		%"Toggle Quicksaves"/RichTextLabel.text = "[wave amp=50.0 freq=10.0 connected=1]Disable Quicksaves[/wave]"
	
	elif Globals.settings_quicksaves == false:
		%"Toggle Quicksaves"/RichTextLabel.text = "[wave amp=50.0 freq=10.0 connected=1]Enable Quicksaves[/wave]"


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
	if Input.is_action_just_pressed("back"):
		if not $Recording.visible:
			$Recording.visible = true
		else:
			$Recording.visible = false


@onready var block_button_sounds_timer = $block_button_sounds

var block_button_sounds = true 
func _on_block_button_sounds_timeout() -> void:
	print("Button sounds no longer blocked.")
	block_button_sounds = false


# If "buttons_blocked" property is true, then stop button behaviour. A timer resets the property to false.
var buttons_blocked = false
func check_if_buttons_blocked():
	if buttons_blocked:
		print("Buttons are blocked.")
		return true
	
	else:
		return false

func _on_buttons_blocked_timeout() -> void:
	print("Button are no longer blocked.")
	buttons_blocked = false


func _on_start_recording_pressed() -> void:
	Globals.start_recording.emit()
	%StartGame.grab_focus()
	
	#$"Recording/VBoxContainer/Control/start recording".visible = false


func _on_start_playback_pressed() -> void:
	Globals.start_playback.emit()
	%StartGame.grab_focus()
	
	#$"Recording/VBoxContainer/Control/start recording".visible = true


func _on_stop_recording_pressed() -> void:
	Globals.stop_recording.emit()
	%StartGame.grab_focus()
	
	#$"Recording/VBoxContainer/Control/start recording".visible = true


@onready var selected_playback_id_display = $"Recording/VBoxContainer/Control3/HBoxContainer/Control2/playback id"
@onready var selected_playback_minus_display = $"Recording/VBoxContainer/Control3/HBoxContainer/Control/playback -"
@onready var selected_playback_plus_display = $"Recording/VBoxContainer/Control3/HBoxContainer/Control3/playback +"

var selected_playback_id = 0

func _on_playback_id_pressed() -> void:
	Globals.recording_autostart = true
	_on_start_recording_pressed()
	playback_button_general()
	Globals.message("Automatic recording is now ENABLED.")

func _on_playback_minus_pressed() -> void:
	selected_playback_id -= 1
	playback_button_general()

func _on_playback_plus_pressed() -> void:
	selected_playback_id += 1
	playback_button_general()

func playback_button_general():
	if selected_playback_id <= -1:
		selected_playback_id = 0
	
	selected_playback_id_display.text = str(selected_playback_id)
	SaveData.gameplay_recorder.selected_playback_id = selected_playback_id


func _on_quit_delay_timeout() -> void:
	can_quit = true


#framerate
func set_maximum_framerate(fps : int, vsync : int):
	DisplayServer.window_set_vsync_mode(vsync)
	Engine.max_fps = fps


func display_framerate_unlocked() -> void:
	set_maximum_framerate(0, 1)

func display_framerate_30() -> void:
	set_maximum_framerate(30, 0)

func display_framerate_60() -> void:
	set_maximum_framerate(60, 0)

func display_framerate_75() -> void:
	set_maximum_framerate(75, 0)

func display_framerate_100() -> void:
	set_maximum_framerate(100, 0)

func display_framerate_120() -> void:
	set_maximum_framerate(120, 0)

func display_framerate_144() -> void:
	set_maximum_framerate(144, 0)
