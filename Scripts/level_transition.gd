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
		
		
	elif Input.is_action_pressed("show_debugInfo"):
		if Input.is_action_just_pressed("move_UP"):
			Globals.debug_mode = true
			
			if not get_node_or_null("/root/World"):
				return
			
			Globals.infoSign_current_text = str("Debug mode has been activated!")
			Globals.infoSign_current_size = 0
			Globals.info_sign_touched.emit()
			
			$/root/World/HUD/"Debug Screen"._on_mute_ambience_pressed()
			$/root/World/HUD/"Debug Screen"._on_mute_music_pressed()
			Globals.playerHP = 99999
			$/root/World/HUD/"Debug Screen"._on_delete_all_save_files_pressed()
		
		elif Input.is_action_just_pressed("move_DOWN"):
			pass
