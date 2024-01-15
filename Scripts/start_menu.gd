extends CenterContainer

@onready var start_game_btn = %StartGame
@onready var time_attack_mode_btn = %"Time Attack Mode"
@onready var quit_btn = %Quit

@onready var startScene = preload("res://Levels/level1.tscn")


func _ready():
	#debug below
	#get_tree().change_scene_to_packed(preload("res://Levels/level1.tscn"))
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	time_attack_mode_btn.grab_focus()



#BUTTONS

func _on_start_game_pressed():
	start_game()

func _on_quit_pressed():
	get_tree().quit()
	

func _on_time_attack_mode_pressed():
	Globals.mode_timeAttack = true
	start_game()




func start_game():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(startScene)
	LevelTransition.fade_from_black()
