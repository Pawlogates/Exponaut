extends StaticBody2D

var active = false


func _ready():
	await get_tree().create_timer(5, false).timeout
	active = true


func _on_area_2d_area_entered(area):
	print(active)
	if active:
		if area.is_in_group("Player"):
			Globals.dm("Player has entered a checkpoint at position: " + str(position))
			reset_all_checkpoints()
			active = false
			#await get_tree().create_timer(1, false).timeout
			checkpoint_activated()
			Globals.checkpoint_activated.emit()


# If tutorial area's checkpoints are acting weird, it's because they are not inheriting from base scene.
func reset_all_checkpoints():
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.active = true


func checkpoint_activated():
	Globals.message("Saving...", 4.0)
	
	Globals.Player.last_checkpoint_pos = position
	
	if Globals.World.level_type == "overworld":
		SaveData.save_levelState(Globals.level_id)
		SaveData.save_playerData(true) # The argument affects whether or not the saved overworld position will also be updated.
	
	else:
		SaveData.save_levelState(Globals.level_id)
