extends StaticBody2D

var active = true
func _on_area_2d_area_entered(area):
	if active:
		if area.get_parent().is_in_group("player"):
			active = false
			get_parent().get_parent().save_game()
			get_parent().get_parent().save_game_area()
