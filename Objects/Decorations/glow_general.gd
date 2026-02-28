extends Node2D

func _ready() -> void:
	await get_tree().create_timer(1.0, true).timeout
	
	for glow in get_children():
		glow.range_z_max = 0
		glow.range_z_min = 0
		
		if not Globals.gameState_levelSet_screen : return
		
		glow.range_z_max += 20 + (5 * get_parent().get_parent().get_parent().get_parent().id)
		glow.range_z_min + glow.range_z_min - 5
