extends recorder

@onready var c_start_recording: Timer = $cooldown_start_recording
@onready var c_stop_recording: Timer = $cooldown_stop_recording


var cooldown_start_recording : float = 2.0
var cooldown_stop_recording : float = 0.5


func _ready() -> void:
	Globals.level_started.connect(on_level_started)
	Globals.level_finished.connect(on_level_finished)
	
	await get_tree().create_timer(5, false).timeout
	Globals.update_recordings_best()
	await get_tree().create_timer(2, false).timeout
	Globals.dirpath_to_server(Globals.d_recordings_local, "upload")


func on_level_started():
	if Globals.recorder_playback_active:
		label_info.visible = true
		return
	
	c_start_recording.wait_time = cooldown_start_recording
	c_start_recording.start()

func on_level_finished():
	if Globals.recorder_playback_active:
		label_info.visible = false
		return
	
	if Globals.World.level_finished_active:
		Globals.handle_spawn_menu(true)
		Globals.message("You're a clever little gamer arent you...")
		return
	
	c_stop_recording.wait_time = cooldown_stop_recording
	c_stop_recording.start()


func _on_cooldown_start_recording_timeout() -> void:
	start_recording()


func _on_cooldown_stop_recording_timeout() -> void:
	update_playback_filepath("level")
	stop_recording()
	
	await get_tree().create_timer(1.0, false).timeout
	Globals.update_recordings_best()
	await get_tree().create_timer(2.0, false).timeout
	Globals.dirpath_to_server(Globals.d_recordings_local, "upload")
