extends CenterContainer

@onready var menu_btn = $VBoxContainer/MenuBtn


func _ready():
	LevelTransition.fade_from_black()
	menu_btn.grab_focus()

func _on_menu_btn_pressed():
	get_tree().change_scene_to_file("res://start_menu.tscn")
	Globals.total_score = 0
