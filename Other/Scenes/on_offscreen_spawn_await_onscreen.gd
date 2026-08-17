extends Node2D

var active : bool = false
var number_activated : int = 0

var master_node : Node

@onready var scan_visible: VisibleOnScreenNotifier2D = $scan_visible

func _ready() -> void:
	master_node = get_parent()
	#scan_visible.screen_exited.connect(on_screen_exited)
	
	visible = true
	
	await get_tree().create_timer(0.05, true).timeout
	
	active = true
	visible = true
	
	if "mouse_filter" in get_parent() : get_parent().mouse_filter = 2
	
	await get_tree().create_timer(0.25, true).timeout
	
	if not scan_visible.is_on_screen() : on_screen_exited()

func on_screen_exited():
	if not active : return
	
	if "entity_type" in master_node:
		if master_node.effect_thrownAway_active or master_node.reset_puzzle or master_node.reset_puzzle_inside_zone or master_node.entity_editor_preview:
			return
	
	scene_unload()

func scene_unload():
	if number_activated > 0 : return
	number_activated += 1
	
	var offscreen_manager = load("res://Other/Scenes/on_onscreen_spawn_master_node.tscn").instantiate()
	offscreen_manager.position = master_node.position
	offscreen_manager.m_scene_filepath = master_node.scene_file_path
	
	if "position" in master_node : offscreen_manager.m_position = master_node.position
	if "velocity" in master_node : offscreen_manager.m_velocity = master_node.velocity
	if "start_pos" in master_node : offscreen_manager.m_start_pos = master_node.start_pos
	if "health_value" in master_node : offscreen_manager.m_health_value = master_node.health_value
	if "dead" in master_node : offscreen_manager.m_dead = master_node.dead
	if "collected" in master_node : offscreen_manager.m_collected = master_node.collected
	if "destroyed" in master_node : offscreen_manager.m_destroyed = master_node.destroyed
	if "delete_on_load" in master_node : offscreen_manager.m_delete_on_load = master_node.delete_on_load
	
	Globals.World.add_child(offscreen_manager)
	
	#Globals.spawn_message_object("despawned")
	
	if Globals.World.level_type == "debug" and Globals.debug_mode : Globals.unloader_spawn_message_object()
	
	#if Globals.debug_mode:
		#if Globals.level_time > 10.0 or Globals.World.level_type == "debug" : Globals.unloader_spawn_message_object()
	
	#if Globals.level_time > 10.0 or Globals.World.level_type == "debug" : Globals.unloader_spawn_message_object()
	
	master_node.queue_free()
