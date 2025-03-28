extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var blackScreen = $ColorRect

@onready var info_text_display = $info_textDisplay_root


func fade_from_black():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished

func fade_from_black_slow():
	animation_player.play("fade_from_black_slow")
	await animation_player.animation_finished


func fade_to_black_verySlow():
	animation_player.play("fade_to_black_verySlow")
	await animation_player.animation_finished

func fade_to_black():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished

func fade_to_black_fast():
	animation_player.play("fade_to_black_fast")
	await animation_player.animation_finished

func fade_to_black_slow():
	animation_player.play("fade_to_black_slow")
	await animation_player.animation_finished


func _ready():
	blackScreen.color.a = 0.0
	#%saved_progress.load_game()


#func _unhandled_input(event):
	#print(event)
