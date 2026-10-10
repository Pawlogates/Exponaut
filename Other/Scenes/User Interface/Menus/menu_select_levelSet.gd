extends menu_general

var current_preview_scene = Globals.scene_screen_decoration_gears


func _ready() -> void:
	for levelSet_id in Globals.l_levelSet_id:
		var f_button = load(Globals.scene_UI_button_general).instantiate()
		
		f_button.button_levelSet_id = levelSet_id
		f_button.button_levelSet_name = Globals.l_levelSet_name[levelSet_id]
		f_button.name = f_button.button_levelSet_name
		f_button.text_manager_message = f_button.button_levelSet_name
		
		f_button.button_clicked.connect(on_levelSet_button_clicked.bind(f_button.button_levelSet_id))
		
		container_buttons.add_child(f_button)
	
	# "All Levels":
	var f2_button = load(Globals.scene_UI_button_general).instantiate()
	
	f2_button.button_levelSet_id = "all"
	f2_button.button_levelSet_name = "ALL (literally every single one) Levels"
	f2_button.name = f2_button.button_levelSet_name
	f2_button.text_manager_message = f2_button.button_levelSet_name
	
	f2_button.button_clicked.connect(on_levelSet_button_clicked.bind(f2_button.button_levelSet_id))
	
	container_buttons.add_child(f2_button)
	
	on_ready()
	
	await get_tree().create_timer(1.0, true).timeout
	
	f2_button.text_manager.scale /= 2
	f2_button.text_manager.position.x += f2_button.text_manager.size.x / 4
	is_ready = true
	ready_show = true


func on_levelSet_button_clicked(levelSet_id : String = "DEBUG"):
	Globals.levelSet_id = levelSet_id
	Globals.change_main_scene(Globals.scene_levelSet_screen)
