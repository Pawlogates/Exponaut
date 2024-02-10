extends Button

@export var episode_select = "none"


func _on_focus_entered():
	modulate.r = 0.5


func _on_focus_exited():
	modulate.r = 1.0


func _on_mouse_entered():
	modulate.r = 0.5


func _on_mouse_exited():
	modulate.r = 1.0





#IF IS AN EPISODE BUTTON

func _on_self_pressed():
	if episode_select != "none":
		Globals.selected_episode = episode_select
