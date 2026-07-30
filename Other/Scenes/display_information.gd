extends Control

func _ready() -> void:
	if not Globals.gameState_levelSet_screen:
		if Globals.get_random_bool(75) : queue_free()

func _on_button_pressed() -> void:
	for node in get_children():
		if not (node is Label and node.name == "info_secondary"):
			node.queue_free()
