extends Node2D

const node_name = "debug_display_messages"
const node2_name = "debug_display_values"

const scene = preload("res://Other/Scenes/User Interface/Debug/debug_display_messages.tscn")
const scene2 = preload("res://Other/Scenes/User Interface/Debug/debug_display_values.tscn")

const action_name = "debug_tools"

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(action_name) and not Input.is_action_just_pressed("debug_mode"):
		if not has_node("./" + node_name):
			if len(get_tree().get_nodes_in_group(node_name)) : return
			
			var instance = scene.instantiate()
			Overlay.add_child(instance)
		
		if not has_node("./" + node2_name):
			if len(get_tree().get_nodes_in_group(node2_name)) : return
			
			var instance2 = scene2.instantiate()
			Overlay.add_child(instance2)
		
		Globals.debug_refresh.emit()
