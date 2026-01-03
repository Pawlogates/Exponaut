extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var screen_black = $screen_black

var world = Node2D

func _ready():
	if Globals.gameState_debug:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	screen_black.color.a = 0.0

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
			Globals.message_debug("Game paused.")
		elif get_tree().paused == true:
			get_tree().paused = false
			Globals.message_debug("Game resumed.")
	
	elif Input.is_action_just_pressed("debug_mode"):
		if Globals.debug_mode == false:
			Globals.debug_mode = true
			Globals.message_debug("Debug mode is active.")
		elif Globals.debug_mode == true:
			Globals.debug_mode = false
			Globals.message_debug("Debug mode is disabled.")
		
		if get_node_or_null("/root/World"): # Execute only if a level is currently loaded.
			world.player_health = 999
	
	elif Input.is_action_just_pressed("debug_console"):
		#add_child(scene)
		Globals.message_debug("Debug mode is active.")


# Called from anywhere outside of this script. Example: animation("fade_black", false, true, 1.0)
func animation(animation_name, play_backwards, speed, await_finished):
	if play_backwards:
		animation_player.play_backwards(str(animation_name))
	else:
		animation_player.play(str(animation_name))
	
	if await_finished : await animation_player.animation_finished
