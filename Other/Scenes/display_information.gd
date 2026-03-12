extends Control

func _ready() -> void:
	if Globals.gameState_level:
		queue_free()


func _on_button_pressed() -> void:
	queue_free()
