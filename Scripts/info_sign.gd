extends StaticBody2D



@export var displayedText = "none"
@export var displayedText_size = 0

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		Globals.infoSign_current_text = str(displayedText)
		Globals.infoSign_current_size = displayedText_size
		
		Globals.info_sign_touched.emit()
