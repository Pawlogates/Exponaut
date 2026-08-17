extends Node2D

func _ready() -> void:
	modulate.a -= randf_range(0.1, 1.0)

func _on_timer_timeout():
	queue_free()
