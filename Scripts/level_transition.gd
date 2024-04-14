extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var blackScreen = $ColorRect


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
	blackScreen.color.a = 0.0
<<<<<<< HEAD
=======
	
	Globals.save_progress.connect(save_progress)
>>>>>>> 862e4b88e92be7211188ca335e5cdca69a93c054
	%saved_progress.load_game()







var mapScreen = load("res://map_screen.tscn")

func _process(_delta):
	#if Input.is_action_just_pressed("quicksave"):
		#%saved_progress.save_game()
		#print("saved")
		#
		#
	#if Input.is_action_just_pressed("quickload"):
		#%saved_progress.load_game()
		#print("loaded")
	
<<<<<<< HEAD
	if Globals.left_start_area and Input.is_action_just_pressed("menu") or Input.is_action_just_pressed("menu") and Input.is_action_pressed("move_UP"):
=======
	if Input.is_action_just_pressed("quickselect"):
>>>>>>> 862e4b88e92be7211188ca335e5cdca69a93c054
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(mapScreen)
		await LevelTransition.fade_from_black_slow()
