extends Node2D

func _on_area_entered(area):
	if not Globals.is_valid_entity(area) : return
	
	if Globals.is_valid_entity(area):
		Globals.exit_activated.emit()
		Globals.level_finished.emit()
