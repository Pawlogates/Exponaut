extends Node2D

@onready var collision: CollisionShape2D = $scan_entered/collision
@onready var label_list_scene_data: Label = $label_list_scene_data
@onready var rect_size: ColorRect = $rect_size
@onready var scan_entered: Area2D = $scan_entered

var list_scene_data : Array = []

var chunk_number : int = -1
var number_activated : int = 0

func _ready() -> void:
	if chunk_number == 0 : Globals.set_pause(true)
	elif chunk_number == 50 : Globals.set_pause(false)
	
	await Globals.await_timer(0.05 * chunk_number)
	
	if Globals.gameState_debug and Input.is_action_pressed("confirm") : return
	
	if Globals.debug_mode or Globals.debug_hide_screen_transitions:
		rect_size.modulate = Globals.l_color_all.pick_random()
		rect_size.modulate.a = 0.5
	else:
		rect_size.queue_free()
		label_list_scene_data.queue_free()
	
	await Globals.await_timer(0.5)
	
	await create_chunk()
	
	if not Globals.debug_mode:
		if Globals.debug_hide_screen_transitions : await Globals.await_timer(2.0)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not Globals.debug_mode and not Globals.debug_hide_screen_transitions : return
	if not Globals.is_node_valid_player(area) : return
	
	if is_instance_valid(label_list_scene_data):
		label_list_scene_data.text = ""
		
		if list_scene_data != []:
			for x in list_scene_data:
				label_list_scene_data.text += str(x) + "\n"
		
		else:
			label_list_scene_data.text = "INACTIVE"
			rect_size.modulate = Color.RED
			rect_size.modulate.a = 1.0
			label_list_scene_data.scale *= 12
			label_list_scene_data.position *= 12
	
	if Input.is_action_pressed("confirm"):
		await create_chunk()
	
	rect_size.modulate *= 2
	rect_size.modulate.a = 1
	rect_size.color.a = 0.5
	await Globals.await_timer(1.0)
	rect_size.modulate.a = 0


func _on_area_exited(area: Area2D) -> void:
	if not Globals.debug_mode : return
	if not Globals.is_node_valid_player(area) : return
	
	if is_instance_valid(label_list_scene_data) : label_list_scene_data.text = ""


func create_chunk():
	if number_activated : return
	number_activated += 1
	
	for scan_always_active in scan_entered.get_overlapping_areas():
		var scene : Node = scan_always_active.get_parent()
		if not scene.is_in_group("level_object") : continue
		
		# Exclude entities affected by any "reset_puzzle" type entities.
		if "entity_type" in scene:
			if scene.never_unload or scene.effect_thrownAway_active or scene.reset_puzzle or scene.reset_puzzle_inside_zone or scene.entity_editor_preview or scene.on_collected_unlock_item_name != "none":
				continue
		#if scene.is_in_group("entity") : print(scene.start_pos)
		
		if scene.is_in_group("entity") : list_scene_data.append([scene.scene_file_path, "/root/Globals", scene.position.x, scene.position.y, scene.velocity.x, scene.velocity.y, scene.start_pos.x, scene.start_pos.y, scene.health_value, scene.dead, scene.collected, scene.destroyed, scene.delete_on_load])
		else : list_scene_data.append([scene.scene_file_path, "/root/Globals", scene.position.x + scene.get_parent().position.x, scene.position.y + scene.get_parent().position.y, -1, -1, -1, -1, -1, false, false, false, false])
		scene.queue_free()
	
	await Globals.await_timer(0.25)
	
	if Globals.debug_hide_screen_transitions : await _on_area_entered(get_tree().get_first_node_in_group("player_hitbox"))
	
	if list_scene_data == []:
		await Globals.await_timer(2.0)
		return
	
	var new_chunk : Node = load("res://Other/Scenes/on_onscreen_spawn_chunk.tscn").instantiate()
	new_chunk.chunk_position = position
	new_chunk.list_scene_data = list_scene_data
	Globals.add_child(new_chunk)
	#print(list_scene_data)
	
	await Globals.await_timer(0.25)


func is_on_screen():
	await get_tree().create_timer(randf_range(0.05, 0.25), true).timeout
	if is_instance_valid(Globals.Player):
		if Globals.player_position.distance_to(position) < Globals.settings_level_object_active_range / Globals.Player.camera.zoom.x + 1000 : return true
		else : return false
