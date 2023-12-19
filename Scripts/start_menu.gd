extends CenterContainer

@onready var start_game = %StartGame

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
		
	start_game.grab_focus()




func _on_start_game_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Levels/level1.tscn")
	LevelTransition.fade_from_black()

func _on_quit_pressed():
	get_tree().quit()
	
	
