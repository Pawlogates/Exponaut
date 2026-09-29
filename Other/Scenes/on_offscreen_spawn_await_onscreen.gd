#@icon("res://Assets/Graphics/icons/default.png")
#class_name unloader
extends Node

var number_activated : int = 0

var master_node : Node

var position : Vector2


func _ready() -> void:
	if is_instance_valid(Globals.World):
		if not (get_parent().get_parent().is_in_group("World") or get_parent().get_parent().is_in_group("tileset")):
			queue_free()
			return
	
	else:
		queue_free()
		return
	
	master_node = get_parent()
	position = master_node.position
	
	await Globals.await_timer(0.5)
	
	# In large levels, the entity unloading is handled by loader chunks generated at the start of that level, and not these unloaders.
	if Globals.get_node_count("entity") > 100:
		if master_node.is_in_group("entity"):
			if not ("use_own_unloader" in master_node and master_node.use_own_unloader):
				queue_free()
				return
			
			elif ("never_unload" in master_node and master_node.never_unload):
				queue_free()
				return
		
		else:
			queue_free()
			return
	
	if ("never_unload" in master_node and master_node.never_unload):
		queue_free()
		return
	
	Globals.refreshed4_0.connect(unload_if_offscreen)
	
	if Globals.level_time_seconds > 10:
		await get_tree().create_timer(0.05, true).timeout
	else:
		await get_tree().create_timer(1.0, true).timeout
	
	if "mouse_filter" in get_parent() : get_parent().mouse_filter = 2
	
	await get_tree().create_timer(0.25, true).timeout
	
	unload_if_offscreen()
	
	await get_tree().create_timer(4, true).timeout
	
	unload_if_offscreen()
	
	await get_tree().create_timer(12, true).timeout
	
	unload_if_offscreen()

func on_screen_exited():
	delete_if_not_level_object()
	
	if "entity_type" in master_node:
		if master_node.effect_thrownAway_active or master_node.reset_puzzle or master_node.reset_puzzle_inside_zone or master_node.entity_editor_preview or master_node.on_collected_unlock_item_name != "none":
			return
	
	scene_unload()

func scene_unload():
	#return
	
	if number_activated : return
	number_activated += 1
	
	delete_if_not_level_object()
	
	var offscreen_manager = preload("res://Other/Scenes/on_onscreen_spawn_master_node.tscn").instantiate()
	#offscreen_manager.position = master_node.position
	offscreen_manager.m_scene_filepath = master_node.scene_file_path
	
	if "position" in master_node : offscreen_manager.m_position = master_node.position + master_node.get_parent().position
	if "velocity" in master_node : offscreen_manager.m_velocity = master_node.velocity
	if "start_pos" in master_node : offscreen_manager.m_start_pos = master_node.start_pos
	if "health_value" in master_node : offscreen_manager.m_health_value = master_node.health_value
	if "dead" in master_node : offscreen_manager.m_dead = master_node.dead
	if "collected" in master_node : offscreen_manager.m_collected = master_node.collected
	if "destroyed" in master_node : offscreen_manager.m_destroyed = master_node.destroyed
	if "delete_on_load" in master_node : offscreen_manager.m_delete_on_load = master_node.delete_on_load
	
	Globals.add_child(offscreen_manager)
	
	#Globals.spawn_message_object("despawned")
	
	if Globals.World.level_type == "debug" and Globals.debug_show_unloader_range : Globals.unloader_spawn_message_object()
	
	#if Globals.debug_mode:
		#if Globals.level_time > 10.0 or Globals.World.level_type == "debug" : Globals.unloader_spawn_message_object()
	
	#if Globals.level_time > 10.0 or Globals.World.level_type == "debug" : Globals.unloader_spawn_message_object()
	
	if "is_ready" in master_node : master_node.is_ready = false
	master_node.queue_free()


func is_on_screen():
	if Globals.player_position.distance_to(position) < Globals.settings_level_object_active_range / Globals.Player.camera.zoom.x + Globals.settings_level_object_active_range : return true
	else : return false


func unload_if_offscreen():
	if Globals.level_time_seconds < 10 : return
	if not is_instance_valid(Globals.World) : return
	if not Globals.World.is_ready : return
	
	#await get_tree().create_timer(randf_range(0.01, 1.0), true).timeout
	
	if not is_on_screen() : on_screen_exited()

func delete_if_not_level_object():
	#return
	
	if is_instance_valid(Globals.World) and Globals.gameState_level:
		# Exception for decoration that's not part of the level.
		if not (get_parent().get_parent().is_in_group("World") or get_parent().get_parent().is_in_group("tileset")):
			queue_free()
			return
	
	else:
		queue_free()
		return
