#@icon("res://Assets/Graphics/icons/default3.png")
#class_name loader
extends Node

var trigger_instantly : bool = false
var number_activated : int = 0
var active : bool = true

# NOTE: The rare instances of loader duplication are most likely caused by short and slightly randomized delays.

var chunk_position : Vector2 = Vector2(-1, -1)
var chunk : Node

var chunk_color : Color

#var m_scene_filepath : String
#var m_position : Vector2
#var m_velocity : Vector2
#var m_start_pos : Vector2
#var m_health_value : int
#var m_dead : bool
#var m_collected : bool
#var m_destroyed : bool
#var m_delete_on_load : bool


var scene_data : Array = ["m_scene1_filepath", "/root/Globals", Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), -1, false, false, false, false]

var list_scene_data : Array = [
	["m_scene1_filepath", "/root/Globals", Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), -1, false, false, false, false],
	["m_scene1_filepath", "/root/Globals", Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), -1, false, false, false, false]
]

var scenes_active : bool = false # Whether the chunk is currently loaded.
var spawned_scenes : Array = [] # All active scenes (loaders) assigned to this chunk, to be deleted when it becomes inactive.

func _ready() -> void:
	Globals.refreshed1_0.connect(_on_cooldown_check_if_visible_timeout)
	#Globals.player_death.connect(on_player_death)
	#Globals.player_respawned.connect(on_player_respawned)
	
	chunk_color = Globals.l_color_all.pick_random()
	chunk_color *= randf_range(0.1, 4.0)
	
	#await get_tree().create_timer(0.05, true).timeout
	
	#await get_tree().create_timer(randf_range(0.25, 1.0), true).timeout
	#
	#_on_cooldown_check_if_visible_timeout()
	#
	#await get_tree().create_timer(randf_range(8, 12), true).timeout
	#
	#_on_cooldown_check_if_visible_timeout()


func on_screen_entered() -> void:
	#print(list_scene_data)
	print("A chunk has entered ACTIVE range.")
	scenes_active = true
	active = false
	
	if not is_instance_valid(Globals.World) : return
	
	
	if len(spawned_scenes) > 0:
		#print(len(spawned_scenes))
		#if len(spawned_scenes) > 50 : Globals.set_pause(true)
		
		for scene in spawned_scenes:
			#spawned_scenes.erase(scene)
			if is_instance_valid(scene) : scene.queue_free()
	
	
	#for f_scene_data in list_scene_data:
		#if active:
			#Globals.smo(str(f_scene_data).replace("[", ">").replace("]", ">"), 4.0, Globals.World, Globals.Player.position * randf_range(-0.25, 0.25), Vector2(4, 4))
			#Globals.await_timer(0.5)
	
	#if number_activated : return
	
	#if not trigger_instantly : await get_tree().create_timer(randf_range(0.05, 1.0), true).timeout
	#else : await get_tree().create_timer(randf_range(0.05, 0.1), true).timeout
	
	#if number_activated : return
	#number_activated += 1
	
	#if not active : return
	#active = false
	
	for f_scene_data in list_scene_data:
		scene_data = f_scene_data
		
		var new_loader : Node = load("res://Other/Scenes/on_onscreen_spawn_master_node.tscn").instantiate()
		
		if len(scene_data) >= 3 and scene_data[2] is Vector2 and scene_data[2] != Vector2(-1, -1): # If the scene is an entity.
			if "m_scene_filepath" in new_loader : new_loader.m_scene_filepath = scene_data[0]
			# This spot is taken by node path.
			if "m_position" in new_loader : new_loader.m_position.x = scene_data[2]
			if "m_position" in new_loader : new_loader.m_position.y = scene_data[3]
			if "m_velocity" in new_loader : new_loader.m_velocity.x = scene_data[4]
			if "m_velocity" in new_loader : new_loader.m_velocity.y = scene_data[5]
			if "m_start_pos" in new_loader : new_loader.m_start_pos_x = scene_data[6]
			if "m_start_pos" in new_loader : new_loader.m_start_pos_y = scene_data[7]
			if "m_health_value" in new_loader : new_loader.m_health_value = scene_data[8]
			if "m_dead" in new_loader : new_loader.m_dead = scene_data[9]
			if "m_collected" in new_loader : new_loader.m_collected = scene_data[10]
			if "m_destroyed" in new_loader : new_loader.m_destroyed = scene_data[11]
			if "m_delete_on_load" in new_loader : new_loader.m_delete_on_load = scene_data[12]
		
		else: # If the scene is not an entity (so its most likely a deco tile or block).
			if "m_scene_filepath" in new_loader : new_loader.m_scene_filepath = scene_data[0]
			if "m_position" in new_loader : new_loader.m_position.x = scene_data[2]
			if "m_position" in new_loader : new_loader.m_position.y = scene_data[3]
		
		new_loader.chunk_color = chunk_color
		
		Globals.add_child(new_loader)
		new_loader.chunk = self
		spawned_scenes.append(new_loader)
		
		# The timer below causes only a few of the queued scenes to spawn every Global 1.0s refresh, and I have no idea why.
		#await get_tree().create_timer(randf_range(0.01, 0.1), true).timeout
		
		#if Globals.World.level_type == "debug" and Globals.debug_mode : Globals.loader_spawn_message_object()
	
	#await get_tree().create_timer(randf_range(0.05, 0.1), true).timeout
	
	#scenes_active = true
	active = true
	
	#Globals.set_pause(false)
	
	#queue_free()

func on_screen_exited():
	#print(list_scene_data)
	print("A chunk has left ACTIVE range.")
	scenes_active = false
	active = false
	
	#await get_tree().create_timer(randf_range(0.01, 0.1), true).timeout
	
	#Globals.set_pause(true)
	
	for scene in spawned_scenes:
		scenes_active = false
		if is_instance_valid(scene):
			if is_instance_valid(scene.master_node) : scene.master_node.queue_free()
			else : print("A chunk tried deleting one of its spawned entity loaders' master node, but it wasn't in the scene tree. This should never happen, but lets proceed anyway.")
			scene.queue_free()
		
		print("A chunk has fully deleted one of its entity loaders (alongside its master node).")
	
	#spawned_scenes = []
	#scenes_active = false
	active = true
	print("A chunk has been made inactive, meaning it had deleted every single one of its entity loaders.")
	
	#await get_tree().create_timer(0.1, true).timeout
	
	#Globals.set_pause(false)
	active = true

func _on_cooldown_check_if_visible_timeout() -> void:
	#for scene in spawned_scenes:
		#if is_instance_valid(scene):
			#if is_instance_valid(scene.master_node):
				#scene.master_node.modulate = Color.RED * randf_range(0.1, 1.0)
	
	#if Globals.debug_mode and Input.is_action_pressed("alt"):
		#on_screen_entered()
	
	if not active : return
	if Globals.level_time_seconds < 10 : return
	if not is_instance_valid(Globals.World) : return
	if not Globals.World.is_ready : return
	
	if await is_on_screen():
	
		if not active : return
		if not scenes_active:
			
			await on_screen_entered()
	
	elif scenes_active:
		if not active : return
		
		await on_screen_exited()
	
	#handle_force_state()
	
	#if is_instance_valid(scan_visible) : scan_visible.queue_free()
	#if is_instance_valid(cooldown_check_if_visible) : cooldown_check_if_visible.queue_free()

func save():
	var save_dict = {
		"scene_filepath" : get_scene_file_path(),
		"parent_node" : get_parent().get_path(),
		
		"chunk_position_x" : chunk_position.x,
		"chunk_position_y" : chunk_position.y,
		"list_scene_data" : list_scene_data
	}
	
	return save_dict


func is_on_screen():
	if Globals.debug_mode:
		if Globals.player_position.distance_to(chunk_position) < 2500:
			#print(Globals.player_position.distance_to(chunk_position))
			if Globals.get_random_bool(50):
				await Globals.await_timer(randf_range(0.5, 4))
				Globals.World.spawn_line(Globals.player_position, chunk_position)
				Globals.World.queue_redraw()
				Globals.smo(str(int(Globals.player_position.distance_to(chunk_position))), 4, Globals.World, Globals.player_position + Vector2(randi_range(-100, 100), randi_range(-100, 100)))
				Globals.spawn_scenes(Globals.World, Globals.scene_particle_special, 1, chunk_position, 0.5, Color.RED, Vector2(7, 7))
	
	#await get_tree().create_timer(randf_range(0.05, 0.25), true).timeout
	
	if is_instance_valid(Globals.Player):
		
		if scenes_active:
			if Globals.player_position.distance_to(chunk_position) < Globals.settings_level_object_active_range / Globals.Player.camera.zoom.x + Globals.settings_level_object_active_range * 1.1 : return true
			else : return false
		
		else:
			if Globals.player_position.distance_to(chunk_position) < Globals.settings_level_object_active_range / Globals.Player.camera.zoom.x + Globals.settings_level_object_active_range : return true
			else : return false


#func on_player_death():
	#pass
#
#func on_player_respawned():
	#pass
	#active = true
	#trigger_instantly = true # unused
	#if is_on_screen() : on_screen_entered()


func handle_force_state():
	await Globals.await_timer(randf_range(0.05, 1.0))
	
	var all_nodes_deleted : bool = true
	for loader in spawned_scenes:
		if is_instance_valid(loader) : all_nodes_deleted = false
	
	if all_nodes_deleted : scenes_active = false
