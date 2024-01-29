extends Area2D


#tilesets: "day", "night"
@export var tileset = "none"

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
		if tileset == "day":
			get_parent().set_day()
		if tileset == "night":
			get_parent().set_night()
