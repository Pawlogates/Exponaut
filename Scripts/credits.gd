extends Node2D

func _ready():
	get_tree().paused = false
	await LevelTransition.fade_from_black_slow()

func _process(delta):
	if Input.is_action_pressed("jump"):
		$AnimationPlayer.speed_scale = 10
	else:
		$AnimationPlayer.speed_scale = 1


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scroll":
		var mapScreen = load("res://map_screen.tscn")
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(mapScreen)
		await LevelTransition.fade_from_black_slow()
		
