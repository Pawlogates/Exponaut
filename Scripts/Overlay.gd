extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var screen_black = $blackScreen

var scene_display_message = preload("res://Other/Scenes/User Interface/display_message.tscn")
var scene_debug_display_message = preload("res://Other/Scenes/User Interface/Debug/debug_display_message.tscn")
var display_message : Control
var debug_display_message: Control

var world = Node2D


func _ready():
	Globals.refresh_info.connect(display_message_check)
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


# Called from anywhere outside of this script.
func animation(animation_name, play_backwards, await_finished, speed):
	if play_backwards:
		animation_player.play_backwards(str(animation_name))
	else:
		animation_player.play(str(animation_name))
	
	if await_finished : await animation_player.animation_finished


func display_message_check():
	if not Globals.display_message_textQueue.is_empty() and not get_node_or_null("$display_message"):
		add_child(scene_display_message.instantiate())
		display_message = $display_message
	
	if not Globals.display_debug_message_textQueue.is_empty() and not get_node_or_null("$debug_display_message"):
		add_child(scene_debug_display_message.instantiate())
		debug_display_message = $debug_display_message
