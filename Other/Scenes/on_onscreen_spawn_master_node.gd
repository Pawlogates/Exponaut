extends Node2D

var active : bool = false

var master_filepath : String
var master_position : Vector2
var master_velocity : Vector2
var master_health_value : int

func _ready() -> void:
	await get_tree().create_timer(0.05, true).timeout
	active = true


func _on_scan_visible_screen_entered() -> void:
	if not active : return
	active = false
	
	var new_master_node : Node = load(master_filepath).instantiate()
	if "position" in new_master_node : new_master_node.position = master_position
	if "velocity" in new_master_node : new_master_node.velocity = master_velocity
	if "health_value" in new_master_node : new_master_node.health_value = master_health_value
	if "velocity" in new_master_node : new_master_node.velocity = master_velocity
	Globals.World.add_child(new_master_node)
	queue_free()
