extends StaticBody2D

@export var message_text = "none"

func _on_area_2d_area_entered(area):
	if area.is_in_group("Player"):
		Globals.message(str(message_text))
