extends Control

@onready var label_info: Label = $label_info

var input_log = []  # Stores all inputs

var recording_active = false
var playback_active = false

var selected_playback_id = 0

var removable = false # If this variable is equal to "true", pressing the "recorder" button (T) will close the recorder.

var dir = DirAccess.open(dirpath)

var log_number = 0 # This variable is only used while determining the input log with the highest id currently present in the recordings folder.


func _ready() -> void:
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
	if recording_active : insert_basic()
	
	if removable:
		if Input.is_action_just_pressed("recorder"):
			await get_tree().create_timer(0.25, true).timeout
			queue_free()
	
	if not input_log : return
	
	recording_timer += delta
	
	if not playback_active : return
	#print("playback", playback_index, input_log.size(), input_log[playback_index])
	
	if playback_index >= input_log.size():
		set_process(false)
		return
	else:
		set_process(true)
	
	playback_timer += delta
	
	var event_data = input_log[playback_index]
	
	var event : String = "none"
	if "event" in event_data : event = event_data["event"]
	
	var time = event_data["time"]
	
	if playback_timer >= time:
		
		if "state" in event_data:
			if event_data["state"] == "stop":
				_on_stop_playback_pressed()
				return
		
		if "player_pos_x" in event_data:
			if is_instance_valid(Globals.Player):
				Globals.Player.position = Vector2(event_data["player_pos_x"], event_data["player_pos_y"])
				Globals.Player.velocity = Vector2(0, 0)
		
		if "Key" in event:
			var event_name = assign_event_name(event)[0]
			var event_pressed = assign_event_pressed(event)
			var event_name_menu = assign_event_name(event)[1]
			
			# Handle gameplay inputs.
			if get_node_or_null("/root/World"): # If currently loaded into a level.
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
		
		elif "MouseButton" in event:
			print("MB")
			simulate_mouse_click(Vector2(event_data["button_position_x"], event_data["button_position_y"]), event_data["button_index"])
			
			var event_name = assign_event_name(event)[0]
			var event_pressed = assign_event_pressed(event)
			var event_name_menu = assign_event_name(event)[1]
			print(event_name)
			if event_pressed:
				Input.action_press(event_name)
			else:
				Input.action_release(event_name)
		
		elif "MouseMotion" in event:
			#print("MM")
			Input.warp_mouse(Vector2(event_data["button_position_x"], event_data["button_position_y"]))
		
		playback_index += 1

func _input(event):
	if not recording_active : return
	
	if not event is InputEventMouseButton and not event is InputEventMouseMotion:
		# Store the input event along with a timestamp
		input_log.append({
		"time": recording_timer,
		"event": event
		})
	
	# Detect mouse click
	elif event is InputEventMouseButton:
		if event.pressed:
			input_log.append({
			"time": recording_timer,
			"event": event,
			"button_index": event.button_index,
			"button_position_x": event.position.x,
			"button_position_y": event.position.y
			})
		else:
			print("Mouse button ", event.button_index, " released at ", event.position)
	
	# Detect mouse movement
	elif event is InputEventMouseMotion:
		#print("Mouse moved to: ", event.position)
		input_log.append({
			"time": recording_timer,
			"event": event,
			"button_position_x": event.position.x,
			"button_position_y": event.position.y
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
	var file_path = dirpath + "/" + "input_log" + str(log_number) + ".json"
	
	print(dirpath + "/" + "input_log" + str(log_number) + ".json")
	# Attempt to open the file for writing
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("Failed to open file for writing: ", file_path)
		return
	
	# Store the JSON data in the file with pretty print
	file.store_string(JSON.stringify(input_log, "\t"))
	file.close()
	
	print("Input log saved! ", len(input_log), " entries.")
	
	# Check if the file exists
	if FileAccess.file_exists(file_path):
		# Open the file for reading
		file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			print("Failed to open file for reading: ", file_path)
			return
		
		
		if file:
			var _file_data = file.get_buffer(file.get_length())
			file.close()
	
	else:
		print("input_log.json not found.")

func get_current_max_input_log_number():
	var max_file_number = 0

	# Create a DirAccess object
	var dir = DirAccess.open(dirpath)
	
	if dir != null:
		dir.list_dir_begin()
		
		var any_recording_exists = false
		
		var file_name = dir.get_next()
		while file_name != "":
			# Check if the file name matches the pattern "input_logX.json"
			if file_name.begins_with("input_log") and file_name.ends_with(".json"):
				any_recording_exists = true
				# Extract the part of the filename after "input_log" and before ".json"
				var number_str = file_name.substr(9, file_name.length() - 14)  # Start at index 9 to skip "input_log"
				var file_number = int(number_str)  # Convert the string to an integer
				
				# Keep track of the highest number found
				if file_number > max_file_number:
					max_file_number = file_number
			
			# Get the next file
			file_name = dir.get_next()
		
		dir.list_dir_end()  # End the listing
		
		if not any_recording_exists:
			max_file_number = -1
		
		print("The highest file number is: ", max_file_number)
		return max_file_number
	else:
		print("Failed to open directory.")


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
	Input.parse_input_event(click_event)  # Simulate button press
	
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
	$"VBoxContainer/Control/start recording".disabled = true
	
	set_process(true)
	recording_timer = 0.0
	print("Recording started.")
	input_log = []
	playback_active = false
	recording_active = true
	label_info.visible = false


func _on_stop_recording_pressed() -> void:
	input_log.append({
		"time": recording_timer,
		"state": "stop",
		})
	
	$"VBoxContainer/Control/start recording".disabled = false
	
	set_process(false)
	recording_active = false
	playback_active = false
	recording_timer = 0.0
	playback_index = 0
	input_log_save()
	label_info.visible = false
	upload_files_to_server()


func _on_start_playback_pressed() -> void:
	$"VBoxContainer/Control4/start playback".disabled = true
	
	if recording_active:
		_on_stop_recording_pressed()
	
	label_info.visible = true
	label_info.text = str("Current playback filepath: " + dirpath + "/" + "input_log" + str(selected_playback_id) + ".json")
	
	if not FileAccess.file_exists(dirpath + "/" + "input_log" + str(selected_playback_id) + ".json"):
		label_info.text = str("Recording file doesn't exist: " + dirpath + "/" + "input_log" + str(selected_playback_id) + ".json")
		return
	
	print("Playback started.", dirpath + "/" + "input_log" + str(selected_playback_id) + ".json")
	
	input_log = JSON.parse_string(FileAccess.get_file_as_string(dirpath + "/" + "input_log" + str(selected_playback_id) + ".json"))
	
	recording_active = false
	playback_active = true
	
	playback_index = 0
	playback_timer = 0.0
	set_process(true)


func _on_stop_playback_pressed() -> void:
	$"VBoxContainer/Control4/start playback".disabled = false
	
	set_process(false)
	playback_active = false
	playback_index = 0
	playback_timer = 0.0
	label_info.visible = false


func _on_playback_forward_pressed() -> void:
	selected_playback_id += 1
	
	$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".text = str(selected_playback_id)
	
	if not FileAccess.file_exists(dirpath + "/" + "input_log" + str(selected_playback_id) + ".json"):
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.RED
	else:
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.GREEN

func _on_playback_back_pressed() -> void:
	selected_playback_id -= 1
	
	$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".text = str(selected_playback_id)
	
	if not FileAccess.file_exists(dirpath + "/" + "input_log" + str(selected_playback_id) + ".json"):
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.RED
	else:
		$"VBoxContainer/Control3/HBoxContainer/Control2/playback id".modulate = Color.GREEN

func _on_playback_id_pressed() -> void:
	SaveData.delete_file("input_log" + str(selected_playback_id), dir)


func _on_btn_close_pressed() -> void:
	queue_free()


var dirpath : String = "user://recordings"

func create_dir_recordings():
	var dir = DirAccess.open("user://")
	dir.make_dir("recordings")


func insert_basic():
	input_log.append({
		"time": recording_timer,
		"player_pos_x": Globals.player_position.x,
		"player_pos_y": Globals.player_position.y
		})
	
	playback_index += 1


var block_upload_files_to_server = true

func _on_timer_timeout() -> void:
	block_upload_files_to_server = false
