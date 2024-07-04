extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var blackScreen = $ColorRect


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
	%saved_progress.load_game()


var mapScreen = load("res://map_screen.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		if not Input.is_action_pressed("move_UP"):
			await LevelTransition.fade_to_black()
			get_tree().change_scene_to_packed(mapScreen)
			await LevelTransition.fade_from_black_slow()
		
		else:
			await LevelTransition.fade_to_black()
			get_tree().change_scene_to_packed(load("res://start_menu.tscn"))
			await LevelTransition.fade_from_black_slow()
