extends Control

@onready var label_info: Label = $label_info

@onready var btn_start_recording: Button = $"VBoxContainer/Control/start recording"
@onready var btn_stop_recording: Button = $"VBoxContainer/Control2/stop recording"
@onready var btn_start_playback: Button = $"VBoxContainer/Control4/start playback"
@onready var btn_stop_playback: Button = $"VBoxContainer/Control5/stop playback"

var input_log : Array = [] # The queued contents of a playback file. It is an Array with Dictionaries inside.
var playback_name : String = "none"
var playback_filename : String = "none.json"
var playback_filepath = Globals.dirpath_recordings + "/" + playback_filename

var recording_active = false
var playback_active = false

var selected_playback_id = 0

var removable = false # If this variable is equal to "true", pressing the "recorder" button (T) will close the recorder.

var dir = DirAccess.open(dirpath)

var log_number = 0 # This variable is only used while determining the input log with the highest id currently present in the recordings folder.


func _ready() -> void:
	Globals.main_scene_changed.connect(on_main_scene_changed)
	Globals.debug_refresh.connect(on_debug_refresh)
	Globals.debug_display_messages_closed.connect(on_debug_display_messages_closed)
	Globals.debug_display_values_closed.connect(on_debug_display_values_closed)
	Globals.player_death.connect(on_player_death)
	
	Globals.checkpoint_activated.connect(upload_files_to_server)
	Globals.gameState_changed.connect(upload_files_to_server)
	
	Globals.set_mouse_mode(true)
	
	await get_tree().create_timer(1.0, true).timeout
	
	if Globals.recording_autostart:
		_on_start_recording_pressed()
		
		for x in range(100):
			position.x -= 25
			position.y -= 10
			await get_tree().create_timer(0.05, true).timeout
		
		visible = false
		
	else:
		removable = true

func _process(delta):
	if removable:
		if Input.is_action_just_pressed("recorder"):
			await get_tree().create_timer(0.25, true).timeout
			queue_free()
	
	if not input_log : return
	
	if not playback_active and not recording_active : return
	#print("playback", playback_index, input_log.size(), input_log[playback_index])
	
	if playback_active:
		if playback_index >= input_log.size():
			playback_active = false
			return
		
		
		var current_entry = input_log[playback_index]
		
		var event : String = "none"
		
		if current_entry["type"] == "input_key":
			event = current_entry["input"]
		
		playback_timer += delta
		var current_time = current_entry["current_time"]
		
		print(playback_timer, " vs ", current_time)
		print(current_entry["type"])
		
		#if playback_timer >= current_time:
		if true:
			
			if current_entry["type"] == "basic":
				apply_basic(current_entry)
				
			
			elif current_entry["type"] == "input_key":
				apply_input_key(current_entry, event)
			
			elif current_entry["type"] == "input_mouse_button":
				apply_input_mouse_button(current_entry, event)
			
			elif current_entry["type"] == "input_mouse_motion":
				apply_input_mouse_motion(current_entry)
			
			elif current_entry["type"] == "end_info":
				print(current_entry["next_playback_number"])
				if current_entry["next_playback_number"] == -1:
					_on_stop_playback_pressed()
					return
				
				else:
					for x in 100:
						if playback_name.ends_with(str(x)):
							_on_stop_playback_pressed()
							Globals.message("New playback segment is starting...")
							await get_tree().create_timer(2.0, true).timeout
							_on_start_playback_pressed(Globals.dirpath_recordings + "/" + playback_name.trim_suffix(str(x)) + str(x + 1) + ".json")
							print(Globals.dirpath_recordings + "/" + playback_name.trim_suffix(str(x)) + str(x + 1) + ".json")
							break
					
					return
			
			elif current_entry["type"] == "start_info":
				set_process(false)
				Globals.change_main_scene(current_entry["scene_filepath"])
				await get_tree().create_timer(2.0, true).timeout
				set_process(true)
	
	if recording_active:
		if input_log[len(input_log)-1]["current_time"] != playback_timer:
			insert_basic()
	
	recording_timer += delta
	playback_index += 1

func _input(event):
	set_process(true)
	if not recording_active : return
	
	if event is InputEventKey:
		# Store the input event along with a timestamp
		input_log.append({
		"type": "input_key",
		"current_time": recording_timer,
		"input": event,
		})
	
	# Detect mouse click
	elif event is InputEventMouseButton:
		if event.pressed:
			input_log.append({
			"type": "input_mouse_button",
			"current_time": recording_timer,
			"input": event,
			"button_index": event.button_index,
			"button_position_x": event.position.x,
			"button_position_y": event.position.y,
			})
		else:
			print("Mouse button ", event.button_index, " released at ", event.position)
	
	# Detect mouse movement
	elif event is InputEventMouseMotion:
		#print("Mouse moved to: ", event.position)
		input_log.append({
			"type": "input_mouse_motion",
			"current_time": recording_timer,
			"input": event,
			"button_position_x": event.position.x,
			"button_position_y": event.position.y,
			})


func input_log_save():
	print("SAVING RECORDING")
	create_dir_recordings()
	
	if input_log == []:
		return
	
	if Globals.recording_autostart:
		log_number = get_current_max_input_log_number() + 1
	else:
		log_number = selected_playback_id
	
	# Define the file path
	playback_filename = "playback_" + SaveData.player_name + "_" + str(selected_playback_id) + "_" + str(playback_number) + ".json"
	playback_filepath = Globals.dirpath_recordings + "/" + playback_filename
	
	# Attempt to open the file for writing
	var file = FileAccess.open(playback_filepath, FileAccess.WRITE)
	if file == null:
		print("Failed to open file for writing: ", playback_filepath)
		return
	
	# Store the JSON data in the file with pretty print
	file.store_string(JSON.stringify(input_log, "\t"))
	file.close()
	
	print("Input log saved! ", len(input_log), " entries.")
	
	# Check if the file exists
	if FileAccess.file_exists(playback_filepath):
		# Open the file for reading
		file = FileAccess.open(playback_filepath, FileAccess.READ)
		if file == null:
			print("Failed to open file for reading: ", playback_filepath)
			return
		
		if file:
			var _file_data = file.get_buffer(file.get_length())
			file.close()
	
	else:
		print("Playback file not found.")

func get_current_max_input_log_number():
	var dirpath = Globals.dirpath_recordings
	var dir = DirAccess.open(dirpath)
	
	var existing_playback_number : int = 0
	
	if dir != null:
		var filenames = dir.get_files()
		
		for filename in filenames:
			if "playback_" + SaveData.player_name + "_" in filename:
				existing_playback_number += 1
		
		return existing_playback_number
	
	return -1
	
	#var max_file_number = 0
#
	## Create a DirAccess object
	#var dir = DirAccess.open(dirpath)
	#
	#if dir != null:
		#dir.list_dir_begin()
		#
		#var any_recording_exists = false
		#
		#var file_name = dir.get_next()
		#while file_name != "":
			## Check if the file name matches the pattern "input_logX.json"
			#if file_name.begins_with("input_log") and file_name.ends_with(".json"):
				#any_recording_exists = true
				## Extract the part of the filename after "input_log" and before ".json"
				#var number_str = file_name.substr(9, file_name.length() - 14)  # Start at index 9 to skip "input_log"
				#var file_number = int(number_str)  # Convert the string to an integer
				#
				## Keep track of the highest number found
				#if file_number > max_file_number:
					#max_file_number = file_number
			#
			## Get the next file
			#file_name = dir.get_next()
		#
		#dir.list_dir_end()  # End the listing
		#
		#if not any_recording_exists:
			#max_file_number = -1
		#
		#print("The highest file number is: ", max_file_number)
		#return max_file_number
	#else:
		#print("Failed to open directory.")


func assign_event_name(event):
	var return_name = ""
	var return_name_menu = ""
	
	if "(Left)" in event or "(A)" in event:
		return_name = "move_left"
		return_name_menu = "ui_left"
	elif "(Right)" in event or "(D)" in event:
		return_name = "move_right"
		return_name_menu = "ui_right"
	elif "(Up)" in event or "(W)" in event:
		return_name = "move_up"
		return_name_menu = "ui_up"
	elif "(Down)" in event or "(S)" in event:
		return_name = "move_down"
		return_name_menu = "ui_down"
	elif "(Z)" in event or "(Space)" in event or "(Enter)" in event:
		return_name = "jump"
		return_name_menu = "ui_accept"
	elif "(C)" in event or "(Shift)" in event:
		return_name = "dash"
	#elif "(X)" in event or "index=0" in event:
		#return_name = "attack_main"
	#elif "(V)" in event or "index=1" in event:
		#return_name = "attack_secondary"
	elif "(Escape)" in event:
		return_name = "menu"
		return_name_menu = "ui_cancel"
	elif "(QuoteLeft)" in event:
		return_name = "debug_tools"
	
	return [return_name, return_name_menu]

func assign_event_pressed(event):
	var return_pressed = false
	
	if "pressed=true" in event:
		return_pressed = true
	elif "pressed=false" in event:
		return_pressed = false
	
	return return_pressed


#var next_scene = preload("res://Levels/MAIN_1.tscn")

#func restart_game():
	#await LevelTransition.fade_to_black()
	#get_tree().change_scene_to_packed(next_scene)
	#await LevelTransition.fade_from_black_slow()


func simulate_mouse_click(mouse_position: Vector2, button_index: int):
	var click_event = InputEventMouseButton.new()
	print("THIS button index: " + str(button_index))
	click_event.button_index = button_index
	click_event.position = mouse_position
	click_event.pressed = true
	Input.parse_input_event(click_event) # Simulate button press
	
	await get_tree().create_timer(0.1, true).timeout
	
	# Simulate button release
	var release_event = click_event.duplicate()
	release_event.pressed = false
	Input.parse_input_event(release_event)


@onready var timer_block_upload_files_to_server: Timer = $timer_block_upload_files_to_server

func upload_files_to_server():
	if block_upload_files_to_server : return
	else : block_upload_files_to_server = true
	timer_block_upload_files_to_server.start()
	
	input_log_save()
	
	await get_tree().create_timer(1, true).timeout
	
	print("UPLOADING GAMEPLAY RECORDINGS TO SERVER")
	var amount := 20
	for file_ID in amount:
		var file_path = str(dirpath + "/" + "input_log%s.json" % file_ID)
		if FileAccess.file_exists(file_path):
			var file := FileAccess.open(file_path, FileAccess.READ)
			var content := file.get_buffer(file.get_length())
			
			var http := HTTPRequest.new()
			add_child(http)

			var boundary := "----GodotBoundary123"
			var headers := PackedStringArray([
				"Content-Type: multipart/form-data; boundary=" + boundary
			])

			var body_parts := []
			body_parts.append("--" + boundary + "\r\n")
			body_parts.append("Content-Disposition: form-data; name=\"file\"; filename=\"input_log%d.json\"\r\n" % file_ID)
			body_parts.append("Content-Type: application/json\r\n\r\n")
			body_parts.append(content)
			body_parts.append("\r\n--" + boundary + "--\r\n")

			var final_body := PackedByteArray()
			for part in body_parts:
				if typeof(part) == TYPE_STRING:
					final_body += part.to_utf8_buffer()
				elif typeof(part) == TYPE_PACKED_BYTE_ARRAY:
					final_body += part
			
			http.request_raw("https://gameplay-recording-downloader.onrender.com/upload", headers, HTTPClient.METHOD_POST, final_body)


var recording_timer = 0.0
var playback_timer = 0.0
var playback_index = 0

func _on_start_recording_pressed() -> void:
	Globals.update_player_info()
	
	btn_stop_recording.disabled = false
	btn_start_recording.disabled = true
	btn_stop_playback.disabled = true
	btn_start_playback.disabled = true
	
	set_process(true)
	recording_timer = 0.0
	print("Recording started.")
	
	input_log = []
	
	input_log.append({
		"type": "start_info",
		"current_time": recording_timer,
		"scene_filepath": get_tree().current_scene.scene_file_path,
		"player_name": SaveData.player_name,
		"screen_refreshrate": DisplayServer.screen_get_refresh_rate(),
		"screen_resolution": DisplayServer.screen_get_size(),
		"processor_name": OS.get_processor_name(),
		})
		
	playback_active = false
	recording_active = true
	label_info.visible = false


var playback_number : int = 0 # The amount of main scene transitions made while the playback is still being recorded. Every main scene transition will split the playback into another, separate file, which will be connected to it by the filename ("[name]_5" will be played right after "[name]_4" has finished, etc.).

func _on_stop_recording_pressed() -> void:
	input_log.append({
		"type": "end_info",
		"current_time": recording_timer,
		"next_playback_number": -1,
		})
	
	btn_stop_recording.disabled = true
	btn_start_recording.disabled = false
	btn_stop_playback.disabled = false
	btn_start_playback.disabled = false
	
	set_process(false)
	recording_active = false
	playback_active = false
	recording_timer = 0.0
	playback_index = 0
	input_log_save()
	label_info.visible = false
	upload_files_to_server()
	
	playback_number = 0
	
	update_playback("none")


func _on_start_playback_pressed(filepath : String = "none") -> void:
	print("PROVIDED FP: ", filepath)
	
	update_playback(filepath)
	
	if recording_active:
		_on_stop_recording_pressed()
	
	label_info.visible = true
	label_info.text = str("Current playback filepath: " + playback_filepath)
	
	if not FileAccess.file_exists(playback_filepath):
		label_info.text = str("Recording file doesn't exist: " + playback_filepath)
		return
	
	btn_stop_recording.disabled = true
	btn_start_recording.disabled = true
	btn_stop_playback.disabled = false
	btn_start_playback.disabled = true
	
	print("Playback started.", filepath)
	
	input_log = JSON.parse_string(FileAccess.get_file_as_string(playback_filepath))
	
	Globals.message("Playback starting...")
	await get_tree().create_timer(2.0, true).timeout
	
	recording_active = false
	playback_active = true
	
	playback_index = 0
	playback_timer = 0.0
	set_process(true)


func _on_stop_playback_pressed() -> void:
	btn_stop_recording.disabled = false
	btn_start_recording.disabled = false
	btn_stop_playback.disabled = true
	btn_start_playback.disabled = false
	
	set_process(false)
	playback_active = false
	playback_index = 0
	playback_timer = 0.0
	label_info.visible = false
	
	Globals.message("Playback finished...")


func _on_playback_forward_pressed() -> void:
	selected_playback_id += 1
	
	$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".text = str(selected_playback_id)
	
	update_playback()
	
	if not FileAccess.file_exists(playback_filepath):
		label_info.text = str("Playback file doesn't exist: " + playback_filepath)
	
	else:
		label_info.text = str("Found playback file: " + playback_filepath)
	
	
	if not FileAccess.file_exists(playback_filepath):
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.RED
	else:
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.GREEN

func _on_playback_back_pressed() -> void:
	selected_playback_id -= 1
	
	$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".text = str(selected_playback_id)
	
	update_playback()
	
	if not FileAccess.file_exists(playback_filepath):
		label_info.text = str("Playback file doesn't exist: " + playback_filepath)
	
	else:
		label_info.text = str("Found playback file: " + playback_filepath)
	
	
	if not FileAccess.file_exists(playback_filepath):
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.RED
	else:
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.GREEN

func _on_playback_id_pressed() -> void:
	SaveData.delete_file(playback_filepath, "none")
	
	update_playback()
	
	if not FileAccess.file_exists(playback_filepath):
		label_info.text = str("Playback file doesn't exist: " + playback_filepath)
	
	else:
		label_info.text = str("Found playback file: " + playback_filepath)
	
	
	if not FileAccess.file_exists(playback_filepath):
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.RED
	else:
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.GREEN


func _on_btn_close_pressed() -> void:
	queue_free()


var dirpath : String = "user://recordings"

func create_dir_recordings():
	var dir = DirAccess.open("user://")
	dir.make_dir("recordings")


func insert_basic():
	input_log.append({
		"type": "basic",
		"current_time": recording_timer,
		"player_pos_x": Globals.player_position.x,
		"player_pos_y": Globals.player_position.y,
		})
	
	playback_index += 1

func insert_start_info():
	input_log.append({
		"type": "start_info",
		"current_time": recording_timer,
		"scene_filepath": get_tree().current_scene.scene_file_path,
		"player_name": SaveData.player_name,
		"screen_refreshrate": DisplayServer.screen_get_refresh_rate(),
		"screen_resolution": DisplayServer.screen_get_size(),
		"processor_name": OS.get_processor_name(),
		})
	
	playback_index += 1

func insert_end_info():
	input_log.append({
		"type": "end_info",
		"current_time": recording_timer,
		"next_playback_number": playback_number + 1,
		"level_score": Globals.level_score,
		"level_time": Globals.level_time,
		"level_damage_taken": Globals.level_damage_taken,
		})
	
	playback_index += 1

func insert_input_mouse_motion():
	pass

func insert_input_mouse_button():
	pass

func insert_input_key():
	pass


func apply_basic(current_entry : Dictionary):
	if is_instance_valid(Globals.Player):
		Globals.Player.position = Vector2(current_entry["player_pos_x"], current_entry["player_pos_y"])
		Globals.Player.velocity = Vector2(0, 0)

func apply_input_mouse_motion(current_entry : Dictionary):
	#print("MM")
	Input.warp_mouse(Vector2(current_entry["button_position_x"], current_entry["button_position_y"]))

func apply_input_mouse_button(current_entry : Dictionary, event):
	print("MB")
	simulate_mouse_click(Vector2(current_entry["button_position_x"], current_entry["button_position_y"]), current_entry["button_index"])
	
	var event_name = assign_event_name(event)[0]
	var event_pressed = assign_event_pressed(event)
	var event_name_menu = assign_event_name(event)[1]
	
	if event_pressed:
		Input.action_press(event_name)
	else:
		Input.action_release(event_name)

func apply_input_key(current_entry : Dictionary, event):
	var event_name = assign_event_name(event)[0]
	var event_pressed = assign_event_pressed(event)
	var event_name_menu = assign_event_name(event)[1]
	
	# Handle gameplay inputs.
	if Globals.gameState_level or get_tree().get_first_node_in_group("World"): # If currently loaded into a level.
		if event_pressed:
			Input.action_press(event_name)
		else:
			Input.action_release(event_name)
		
		print("Generating gameplay input: ", event_name)
	
	# Handle menu inputs.
	else:
		var trigger_event = InputEventAction.new()
		trigger_event.action = event_name_menu
		trigger_event.pressed = event_pressed
		Input.parse_input_event(trigger_event)
		print("Generating menu input: ", event_name_menu)


var block_upload_files_to_server = true

func _on_timer_timeout() -> void:
	block_upload_files_to_server = false


func on_main_scene_changed():
	if not recording_active : return
	
	insert_end_info()
	
	input_log_save()
	
	playback_number += 1
	
	set_process(false)
	recording_active = false
	playback_active = false
	recording_timer = 0.0
	playback_index = 0
	input_log_save()
	label_info.visible = false
	upload_files_to_server()
	
	
	await Globals.gameState_changed
	
	
	Globals.update_player_info()
	
	input_log = []
	
	insert_start_info()
	
	set_process(true)
	recording_timer = 0.0
	print("Recording started.")
	
	playback_active = false
	recording_active = true
	label_info.visible = false

func on_debug_refresh():
	pass
func on_debug_display_messages_closed():
	pass
func on_debug_display_values_closed():
	pass
func on_player_death():
	pass


func update_playback(filepath : String = "none"):
	if filepath == "none":
		filepath = Globals.dirpath_recordings + "/" + "playback_" + SaveData.player_name + "_" + str(selected_playback_id) + "_" + "0" + ".json"
	
	playback_filepath = filepath
	if Globals.dirpath_recordings + "/" in playback_filepath:
		playback_filename = filepath.replace(Globals.dirpath_recordings + "/", "")
	if playback_filename.ends_with(".json"):
		playback_name = playback_filename.replace(".json", "")
	
	
	if not FileAccess.file_exists(playback_filepath):
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.RED
	else:
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.GREEN
