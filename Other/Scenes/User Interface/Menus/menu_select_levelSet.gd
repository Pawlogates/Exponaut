extends menu_general

var current_preview_scene = Globals.scene_screen_decoration_gears


func _ready() -> void:
	for levelSet_id in Globals.l_levelSet_id:
		var button = load(Globals.scene_UI_button_general).instantiate()
		
		button.button_levelSet_id = levelSet_id
		button.button_levelSet_name = Globals.l_levelSet_name[levelSet_id]
		button.name = button.button_levelSet_name
		button.text_manager_message = button.button_levelSet_name
		
		button.button_clicked.connect(on_levelSet_button_clicked.bind(button.button_levelSet_id))
		
		container_buttons.add_child(button)
	
	# "All Levels":
	var button = load(Globals.scene_UI_button_general).instantiate()
	
	button.button_levelSet_id = "all"
	button.button_levelSet_name = "ALL (literally every single one) Levels"
	button.name = button.button_levelSet_name
	button.text_manager_message = button.button_levelSet_name
	
	button.button_clicked.connect(on_levelSet_button_clicked.bind(button.button_levelSet_id))
	
	container_buttons.add_child(button)
	
	on_ready()
	
	await get_tree().create_timer(1.0, true).timeout
	
	button.text_manager.scale /= 2
	button.text_manager.position.x += button.text_manager.size.x / 4
	is_ready = true
	ready_show = true


func on_levelSet_button_clicked(levelSet_id : String = "DEBUG"):
	Globals.levelSet_id = levelSet_id
	Globals.change_main_scene(Globals.scene_levelSet_screen)
