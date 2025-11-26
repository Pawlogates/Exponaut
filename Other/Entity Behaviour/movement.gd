extends Node2D

func _process(delta):
	movement()


var movement_type_id = 0

func movement():
	if movement_type_id == 0 : return
	
	elif movement_type_id == 1:
		pass
