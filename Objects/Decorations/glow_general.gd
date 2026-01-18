extends Node2D

func _ready() -> void:
	for glow in get_children():
		glow.range_z_max = 0
		glow.range_z_min = 0
		
		glow.range_z_max += 20 + (5 * get_parent().get_parent().get_parent().get_parent().id)
		glow.range_z_min + glow.range_z_min - 5
