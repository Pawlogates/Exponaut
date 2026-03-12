extends Node2D

const node_scene_filepath = preload("res://Other/Scenes/recorder.tscn")

const node_name = "recorder"
const node_group_name = "recorder"

const action_name = "recorder"


func _ready() -> void:
	await get_tree().create_timer(1.0, true).timeout
	if Globals.recording_autostart:
		var instance = node_scene_filepath.instantiate()
		Overlay.add_child.call_deferred(instance)
		print("adding recorder")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(action_name):
		if not has_node("./" + node_name):
			if len(get_tree().get_nodes_in_group(node_group_name)) : return
			
			var instance = node_scene_filepath.instantiate()
			Overlay.add_child(instance)
		
		Globals.debug_refresh.emit()
