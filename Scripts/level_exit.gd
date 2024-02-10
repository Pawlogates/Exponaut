extends Node2D

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
		Globals.exitReached.emit()
		
