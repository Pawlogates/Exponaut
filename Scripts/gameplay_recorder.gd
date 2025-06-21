extends Node2D

var input_log = []  # Stores all inputs

var recording_active = false
var playback_active = false

var log_number = 0

@onready var player = Node2D
@onready var world = Node2D

@onready var label: Label = $CanvasLayer/Label

func start_recording():
	set_process(true)
	recording_timer = 0.0
	print("Recording started.")
	input_log = []
	#restart_game()
	playback_active = false
	recording_active = true
	label.visible = false

func _input(event):
	if not recording_active : return
	
	if not event is InputEventMouseButton and not event is InputEventMouseMotion:
		#print(event)
		# Store the input event along with a timestamp
		input_log.append({
		"event": event,
		"timestamp": recording_timer,
		"player_posX": Globals.player_posX,
		"player_posY": Globals.player_posY
		})
	
	# Detect mouse click
	elif event is InputEventMouseButton:
		if event.pressed:
			print("Mouse button ", event.button_index, " pressed at ", event.position)
			input_log.append({
			"event": event,
			"timestamp": recording_timer,
			"player_posX": Globals.player_posX,
			"player_posY": Globals.player_posY,
			"button_index": event.button_index,
			"button_positionX": event.position.x,
			"button_positionY": event.position.y
			})
		else:
			print("Mouse button ", event.button_index, " released at ", event.position)

	# Detect mouse movement
	elif event is InputEventMouseMotion:
		print("Mouse moved to: ", event.position)
		input_log.append({
			"event": event,
			"timestamp": recording_timer,
			"player_posX": Globals.player_posX,
			"player_posY": Globals.player_posY,
			"button_positionX": event.position.x,
			"button_positionY": event.position.y
			})


func _notification(type):
	# Send recordings to a server when the game stops.
	if type == NOTIFICATION_WM_CLOSE_REQUEST or type == NOTIFICATION_PREDELETE:
		if recording_active:
			stop_recording()
		
		upload_files_to_server()


func stop_recording():
	set_process(false)
	recording_active = false
	playback_active = false
	recording_timer = 0.0
	playback_index = 0
	input_log_save()
	label.visible = false
	upload_files_to_server()

func input_log_save():
	if input_log == []:
		return
	
	if Globals.recording_autostart:
		log_number = get_current_max_input_log_number() + 1
	else:
		log_number = selected_playback_id
	
	# Define the file path
	var file_path = "user://input_log" + str(log_number) + ".json"
	
	print("user://input_log" + str(log_number) + ".json")
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
	var folder_path = "user://"  # You can change this to the appropriate folder path
	var max_file_number = 0

	# Create a DirAccess object
	var dir = DirAccess.open(folder_path)  # Use DirAccess to open the directory
	
	if dir != null:
		dir.list_dir_begin()  # Start listing files (no arguments needed)
		
		var any_recording_exists = false
		
		var file_name = dir.get_next()  # Get the first file name
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


var playback_index = 0
var playback_timer = 0.0
var recording_timer = 0.0

var selected_playback_id = 0

func start_playback():
	if recording_active:
		stop_recording()
	
	label.visible = true
	label.text = str("Current playback filepath: " + "user://input_log" + str(selected_playback_id) + ".json")
	
	if not FileAccess.file_exists("user://input_log" + str(selected_playback_id) + ".json"):
		label.text = str("Recording file doesn't exist: " + "user://input_log" + str(selected_playback_id) + ".json")
		return
	
	print("Playback started.", "user://input_log" + str(selected_playback_id) + ".json")
	
	input_log = JSON.parse_string(FileAccess.get_file_as_string("user://input_log" + str(selected_playback_id) + ".json"))
	#restart_game()
	recording_active = false
	playback_active = true
	
	playback_index = 0
	playback_timer = 0.0
	set_process(true)

func _process(delta):
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
	var event = event_data["event"]
	var event_time = event_data["timestamp"]
	
	#print(playback_timer, " ", event_time)
	if playback_timer >= event_time:
		
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
				
				player.position = Vector2(event_data["player_posX"], event_data["player_posY"])
			
			# Handle menu inputs.
			else:
				var trigger_event = InputEventAction.new()
				trigger_event.action = event_name_menu
				trigger_event.pressed = event_pressed
				Input.parse_input_event(trigger_event)
				print("Generating menu input: ", event_name_menu)
		
		elif "MouseButton" in event:
			#print("MB")
			simulate_mouse_click(Vector2(event_data["button_positionX"], event_data["button_positionY"]), event_data["button_index"])
		
		elif "MouseMotion" in event:
			#print("MM")
			Input.warp_mouse(Vector2(event_data["button_positionX"], event_data["button_positionY"]))
		
		playback_index += 1


func assign_event_name(event):
	var return_name = ""
	var return_name_menu = ""
	if "(Left)" in event or "(A)" in event:
		return_name = "move_L"
		return_name_menu = "ui_left"
	elif "(Right)" in event or "(D)" in event:
		return_name = "move_R"
		return_name_menu = "ui_right"
	elif "(Up)" in event or "(W)" in event:
		return_name = "move_UP"
		return_name_menu = "ui_up"
	elif "(Down)" in event or "(S)" in event:
		return_name = "move_DOWN"
		return_name_menu = "ui_down"
	elif "(Z)" in event or "(Space)" in event or "(Enter)" in event:
		return_name = "jump"
		return_name_menu = "ui_accept"
	elif "(C)" in event or "(Shift)" in event:
		return_name = "dash"
	elif "(X)" in event or "(LMB)" in event:
		return_name = "attack_main"
	elif "(V)" in event or "(RMB)" in event:
		return_name = "attack_secondary"
	elif "(Escape)" in event:
		return_name = "menu"
		return_name_menu = "ui_cancel"
	elif "(QuoteLeft)" in event:
		return_name = "show_debugInfo"
	
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.start_recording.connect(start_recording)
	Globals.start_playback.connect(start_playback)
	Globals.stop_recording.connect(stop_recording)
	Globals.gameplay_recorder_entered_level.connect(reassign_level_objects)
	Globals.checkpoint_activated.connect(upload_files_to_server)
	
	#await get_tree().create_timer(4, false).timeout


func reassign_level_objects():
	if get_node_or_null("/root/World") : world = $/root/World
	if get_node_or_null("/root/World/Player") : player = $/root/World.player


func simulate_mouse_click(mouse_position: Vector2, button_index: int):
	var click_event = InputEventMouseButton.new()
	click_event.button_index = button_index
	click_event.position = mouse_position
	click_event.pressed = true
	Input.parse_input_event(click_event)  # Simulate button press
	
	# Simulate button release
	var release_event = click_event.duplicate()
	release_event.pressed = false
	Input.parse_input_event(release_event)


func upload_files_to_server():
	print("UPLOADING GAMEPLAY RECORDINGS TO SERVER")
	var amount := 20
	for file_ID in amount:
		var file_path := "user://input_log%d.json" % file_ID
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
