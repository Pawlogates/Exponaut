extends ColorRect


signal retry()
signal next_level()

@onready var retry_btn = %RetryBtn
@onready var next_level_btn = %NextLevelBtn


func _on_retry_btn_pressed():
	retry.emit()


func _on_next_level_btn_pressed():
	next_level.emit()
	

func _ready():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	set_process_mode(PROCESS_MODE_DISABLED)
