extends Node2D

@onready var scan_visible: VisibleOnScreenNotifier2D = $scan_visible

var active : bool = false

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
	visible = true
	
	await get_tree().create_timer(0.05, true).timeout
	
	active = true


func on_screen_entered() -> void:
	if not active : return
	active = false
	
	var new_master_node : Node = load(m_scene_filepath).instantiate()
	if "position" in new_master_node : new_master_node.position = m_position
	if "velocity" in new_master_node : new_master_node.velocity = m_velocity
	if "start_pos" in new_master_node : new_master_node.start_pos = m_start_pos
	if "health_value" in new_master_node : new_master_node.health_value = m_health_value
	if "dead" in new_master_node : new_master_node.dead = m_dead
	if "collected" in new_master_node : new_master_node.collected = m_collected
	if "destroyed" in new_master_node : new_master_node.destroyed = m_destroyed
	if "delete_on_load" in new_master_node : new_master_node.delete_on_load = m_delete_on_load
	
	Globals.World.add_child(new_master_node)
	
	#Globals.spawn_message_object("spawned")
	
	if Globals.World.level_type == "debug" and Globals.debug_mode : Globals.loader_spawn_message_object()
	queue_free()


func _on_cooldown_check_if_visible_timeout() -> void:
	if scan_visible.is_on_screen() : on_screen_entered()


func save():
	var save_dict = {
		"scene_filepath" : get_scene_file_path(),
		"parent_node" : get_parent().get_path(),
		
		"m_scene_filepath" : m_scene_filepath,
		"m_position_x" : m_position.x, # Note: Unfortunately, Vector2 is not supported by JSON.
		"m_position_y" : m_position.y,
		"m_start_pos_x" : m_start_pos.x,
		"m_start_pos_y" : m_start_pos.y,
		"m_health_value" : m_health_value,
		"m_dead" : m_dead,
		"m_collected" : m_collected,
		"m_destroyed" : m_destroyed,
		"m_delete_on_load" : m_delete_on_load,
	}
	
	return save_dict
