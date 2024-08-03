extends Area2D


#tilesets: "day", "night", "night2", "night3"
@export var tileset = "none"

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
		if tileset == "day":
			get_parent().set_day()
		elif tileset == "night":
			get_parent().set_night()
		elif tileset == "night2":
			get_parent().set_night2()
		elif tileset == "night3":
			get_parent().set_night3()
