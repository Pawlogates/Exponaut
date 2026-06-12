extends Node2D

func _ready() -> void:
	if len(get_tree().get_nodes_in_group("hint_scroll_down")) >= 2:
		queue_free()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("tab"):
		queue_free()
