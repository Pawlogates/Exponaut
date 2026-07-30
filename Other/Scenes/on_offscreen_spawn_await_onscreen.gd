extends Node2D

@onready var scan_visible: VisibleOnScreenNotifier2D = $scan_visible

func _ready() -> void:
	scan_visible.screen_exited.connect(on_screen_exited)
	
	await get_tree().create_timer(0.5, true).timeout
	
	if "mouse_filter" in get_parent() : get_parent().mouse_filter = 2
	
	if not scan_visible.is_on_screen() : scene_unload()

func on_screen_exited():
	return
	scene_unload()

func scene_unload():
	var offscreen_manager = load("res://Other/Scenes/on_onscreen_spawn_master_node.tscn").instantiate()
	offscreen_manager.master_filepath = get_parent().scene_file_path
	offscreen_manager.master_position = get_parent().position
	#offscreen_manager.master_velocity = velocity
	#offscreen_manager.master_health_value = health_value
	offscreen_manager.position = get_parent().position
	Globals.World.add_child(offscreen_manager)
	get_parent().queue_free()
