extends StaticBody2D

var active = true
func _on_area_2d_area_entered(area):
	if active:
		if area.get_parent().is_in_group("player"):
			active = false
			await get_tree().create_timer(1, false).timeout
			#await get_tree().create_timer(1, false).timeout
			$/root/World.save_game()
			$/root/World.save_game_area()
			
			if $/root/World.regular_level:
				SavedData.save_game(false)
			else:
				SavedData.save_game(true)
			
