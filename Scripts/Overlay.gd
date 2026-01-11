extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var screen_black = $screen_black

var world = Node2D

func _ready():
	if Globals.gameState_debug:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	screen_black.color.a = 0.0

func _physics_process(_delta: float) -> void:
	pass


# Called from anywhere outside of this script. Example: animation("black_fade_in", 1.0, false, true)
func animation(name : String, speed : float, play_backwards : bool, await_finished : bool):
	animation_player.speed_scale = speed
	
	if play_backwards:
		animation_player.play_backwards(str(name))
	else:
		animation_player.play(str(name))
	
	if await_finished : await animation_player.animation_finished
