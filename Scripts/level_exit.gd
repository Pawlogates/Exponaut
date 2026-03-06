extends Node2D

func _on_area_entered(area):
	print(9)
	if Globals.is_valid_entity(area):
		Globals.exit_activated.emit()
