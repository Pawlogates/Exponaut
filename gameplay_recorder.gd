extends Node2D

var input_log = []  # Stores all inputs

var recording_active = false
var playback_active = false

func start_recording():
	set_process(true)
	recording_timer = 0.0
	print("Recording started.")
	input_log = []
	restart_game()
	playback_active = false
	recording_active = true

func _input(event):
	if not recording_active : return
	if event is InputEventMouseButton or event is InputEventMouseMotion : return
	#print(event)
	# Store the input event along with a timestamp
	input_log.append({
	"event": event,
	"timestamp": recording_timer
	})

func _notification(type):
	# Save inputs to a file when the game stops
	if type == NOTIFICATION_WM_CLOSE_REQUEST or type == NOTIFICATION_PREDELETE:
		input_log_save()

func input_log_save():
	var file = FileAccess.open("user://input_log.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(input_log, "\t"))  # Pretty print
	file.close()
	print("Input log saved! ", len(input_log), " entries.")


var playback_index = 0
var playback_timer = 0.0
var recording_timer = 0.0

func start_playback():
	input_log_save()
	print("Playback started.")
	input_log = JSON.parse_string(FileAccess.get_file_as_string("user://input_log.json"))
	restart_game()
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
		#var action_name = ""
		
		var event_name = assign_event_name(event)
		var event_pressed = assign_event_pressed(event)
		
		#for action in InputMap.get_actions():
			#if event_name.is_action(action):
				#action_name = action
		var trigger_event = InputEventAction.new()
		#print(event)
		trigger_event.action = event_name
		trigger_event.pressed = event_pressed
		Input.parse_input_event(trigger_event)
		print("Generating input: ", trigger_event)
		playback_index += 1

func assign_event_name(event):
	var return_name = ""
	if "(Left)" in event:
		return_name = "move_L"
	elif "(Right)" in event:
		return_name = "move_R"
	elif "(Up)" in event:
		return_name = "move_UP"
	elif "(Down)" in event:
		return_name = "move_DOWN"
	elif "(Space)" in event or "(Z)" in event:
		return_name = "jump"
	elif "(C)" in event:
		return_name = "dash"
	elif "(X)" in event:
		return_name = "attack_main"
	elif "(V)" in event:
		return_name = "attack_secondary"
	
	return return_name

func assign_event_pressed(event):
	var return_pressed = false
	if "pressed=true" in event:
		return_pressed = true
	elif "pressed=false" in event:
		return_pressed = false
	
	return return_pressed


var next_scene = preload("res://Levels/MAIN_1.tscn")

func restart_game():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(next_scene)
	await LevelTransition.fade_from_black_slow()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.start_recording.connect(start_recording)
	Globals.start_playback.connect(start_playback)
	Globals.stop_recording.connect(input_log_save)
	input_log = JSON.parse_string(FileAccess.get_file_as_string("user://input_log.json"))
