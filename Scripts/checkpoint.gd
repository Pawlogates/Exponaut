extends StaticBody2D

func _ready():
	await get_tree().create_timer(5, false).timeout
	active = true

var active = false
func _on_area_2d_area_entered(area):
	if active:
		if area.get_parent().is_in_group("player"):
			reset_all_checkpoints()
			active = false
			#await get_tree().create_timer(1, false).timeout
			checkpoint_activated()
			Globals.checkpoint_activated.emit()


func reset_all_checkpoints():
	for checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		checkpoint.active = true


func checkpoint_activated():
	$/root/World.last_checkpoint_pos = position
	$/root/World.save_game()
	$/root/World.save_game_area()
	
	if not $/root/World.regular_level and not $/root/World.shrine_level:
		SaveData.save_playerData(true)
