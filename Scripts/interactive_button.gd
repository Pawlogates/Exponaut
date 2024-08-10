extends Button

@export var episode_select = "none"
var moving = false
var showing_up = true

func _ready():
	if not is_connected("mouse_entered", _on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not is_connected("mouse_exited", _on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

#func _on_focus_entered():
	#modulate.a = 1.0

#func _on_focus_exited():
	#modulate.a = 1.0

func _on_mouse_entered():
	if not disabled:
		modulate.r = 0.5

func _on_mouse_exited():
	if not disabled:
		modulate.r = 1.0


#IF IS AN EPISODE BUTTON
func _on_self_pressed():
	if episode_select != "none":
		Globals.selected_episode = episode_select


func _physics_process(delta):
	if moving:
		position = lerp(position, Vector2(0, 0), delta * 5)
		rotation = lerp(rotation, 0.0, delta * 5)
		scale = lerp(scale, Vector2(1, 1), delta * 5)
	if showing_up:
		modulate.a = move_toward(modulate.a, 1, delta * 2)
	
	if size.x > 960:
		size.x = 960
