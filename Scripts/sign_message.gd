extends StaticBody2D

@export var message_text = "none"

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		Globals.sign_message_text = str(message_text)
		
		Globals.sign_message_touched.emit()
