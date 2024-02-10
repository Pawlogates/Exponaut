extends CanvasLayer

@onready var animation_player = $AnimationPlayer


func fade_from_black():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished

func fade_from_black_slow():
	animation_player.play("fade_from_black_slow")
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
	Globals.save_progress.connect(save_progress)
	%saved_progress.load_game()

func save_progress():
	%saved_progress.save_game()






var mapScreen = load("res://map_screen.tscn")

func _process(delta):
	#if Input.is_action_just_pressed("quicksave"):
		#%saved_progress.save_game()
		#print("saved")
		#
		#
	#if Input.is_action_just_pressed("quickload"):
		#%saved_progress.load_game()
		#print("loaded")
	
	if Input.is_action_just_pressed("quickselect"):
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(mapScreen)
		await LevelTransition.fade_from_black_slow()
