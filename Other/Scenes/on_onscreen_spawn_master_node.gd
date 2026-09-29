#@icon("res://Assets/Graphics/icons/default3.png")
#class_name loader
extends Node

var active : bool = false
var trigger_instantly : bool = false
var number_activated : int = 0
var chunk : Node

var chunk_color : Color

var master_node : Node

var m_scene_filepath : String
var m_position : Vector2
var m_velocity : Vector2
var m_start_pos : Vector2
var m_health_value : int
var m_dead : bool
var m_collected : bool
var m_destroyed : bool
var m_delete_on_load : bool

func _ready() -> void:
	Globals.refreshed1_0.connect(_on_cooldown_check_if_visible_timeout)
	Globals.player_death.connect(on_player_death)
	Globals.player_respawned.connect(on_player_respawned)
	
	await get_tree().create_timer(0.05, true).timeout
	
	active = true


func on_screen_entered() -> void:
	if not is_instance_valid(Globals.World) : return
	if not active : return
	
	#if not trigger_instantly : await get_tree().create_timer(randf_range(0.05, 0.5), true).timeout
	#else : await get_tree().create_timer(randf_range(0.05, 0.1), true).timeout
	
	if number_activated : return
	number_activated += 1
	
	if not active : return
	active = false
	
	#Globals.set_pause(true)
	
	var new_master_node : Node = load(m_scene_filepath).instantiate()
	if "position" in new_master_node : new_master_node.position.x = m_position.x
	if "position" in new_master_node : new_master_node.position.y = m_position.y
	if "velocity" in new_master_node : new_master_node.velocity.x = m_velocity.x
	if "velocity" in new_master_node : new_master_node.velocity.y = m_velocity.y
	if "start_pos" in new_master_node : new_master_node.start_pos.x = m_start_pos.x
	if "start_pos" in new_master_node : new_master_node.start_pos.y = m_start_pos.y
	if "health_value" in new_master_node : new_master_node.health_value = m_health_value
	if "dead" in new_master_node : new_master_node.dead = m_dead
	if "collected" in new_master_node : new_master_node.collected = m_collected
	if "destroyed" in new_master_node : new_master_node.destroyed = m_destroyed
	if "delete_on_load" in new_master_node : new_master_node.delete_on_load = m_delete_on_load
	
	Globals.World.add_child(new_master_node)
	master_node = new_master_node
	if "loader_node" in new_master_node : new_master_node.loader_node = self
	
	if Globals.debug_show_unloader_range : master_node.modulate = chunk_color
	
	if Globals.World.level_type == "debug" and Globals.debug_mode : Globals.loader_spawn_message_object()
	
	#Globals.set_pause(false)
	
	#queue_free()


func _on_cooldown_check_if_visible_timeout() -> void:
	if Globals.level_time_seconds < 10 : return
	if not is_instance_valid(Globals.World) : return
	if not Globals.World.is_ready : return
	
	correct_chunk()
	
	if not active : return
	
	if await is_on_screen() : on_screen_entered()
	
	# a terrible failsafe
	#if not chunk.scenes_active:
		#chunk.scenes_active = true
	
	#if is_instance_valid(scan_visible) : scan_visible.queue_free()
	#if is_instance_valid(cooldown_check_if_visible) : cooldown_check_if_visible.queue_free()

func save():
	var save_dict = {
		"scene_filepath" : get_scene_file_path(),
		"parent_node" : get_parent().get_path(),
		
		"m_scene_filepath" : m_scene_filepath,
		"m_position_x" : m_position.x, # Note: Unfortunately, Vector2 is not supported by JSON.
		"m_position_y" : m_position.y,
		"m_velocity_x" : m_velocity.x,
		"m_velocity_y" : m_velocity.y,
		"m_start_pos_x" : m_start_pos.x,
		"m_start_pos_y" : m_start_pos.y,
		"m_health_value" : m_health_value,
		"m_dead" : m_dead,
		"m_collected" : m_collected,
		"m_destroyed" : m_destroyed,
		"m_delete_on_load" : m_delete_on_load,
	}
	
	return save_dict


func is_on_screen():
	#await get_tree().create_timer(randf_range(0.01, 0.1), true).timeout
	if is_instance_valid(Globals.Player):
		if Globals.player_position.distance_to(m_position) < Globals.settings_level_object_active_range / Globals.Player.camera.zoom.x + Globals.settings_level_object_active_range : return true
		else : return false


func on_player_death():
	pass

func on_player_respawned():
	return
	active = true
	trigger_instantly = true # unused
	if await is_on_screen() : on_screen_entered()


func correct_chunk():
	await Globals.await_timer(randf_range(0.5, 2.0))
	
	if is_instance_valid(chunk):
		if chunk.scenes_active:
			return
	
	else:
		print("deleting loader due to it not having a chunk")
		queue_free()
	
	await Globals.await_timer(randf_range(0.5, 2.0))
	
	if is_instance_valid(chunk):
		if not chunk.scenes_active:
			print(is_instance_valid(chunk))
			chunk.scenes_active = true
