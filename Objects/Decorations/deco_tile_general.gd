extends Node2D

func _ready() -> void:
	add_to_group("level_object")
	var scan_always_active : Node = load("res://Other/Scenes/scan_always_active.tscn").instantiate()
	add_child(scan_always_active)
