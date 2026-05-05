extends Node2D

func _on_area_entered(area):
	if not area.is_in_group("player_hitbox") : return
	
	Globals.exit_activated.emit()
	Globals.level_finished.emit()
