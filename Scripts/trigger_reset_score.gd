extends Area2D

func _on_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		Globals.Player.combo_manager.reset_combo_tier()
		Globals.combo_score = 0
		Globals.level_score = 0
