extends Button

@export var menu_name = "StartMenu"

var ignore_mouse = false

@export var enable_deco = true
@export var polygon1_position = Vector2(488, -40)
@export var polygon2_position = Vector2(488, 40)
@export var polygon3_position = Vector2(-488, 40)
@export var polygon4_position = Vector2(-488, -40)

@export var episode_select = "none"

var moving = false
var showing_up = true

var button_deco : Node

func _ready():
	if not is_connected("mouse_entered", _on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not is_connected("mouse_exited", _on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	if not is_connected("focus_entered", _on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not is_connected("focus_exited", _on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	
	if not is_connected("pressed", _on_pressed):
		pressed.connect(_on_pressed)
	
	
	if enable_deco:
		self_modulate.a = 0
		var deco = preload("res://Other/Scenes/button_deco.tscn").instantiate()
		deco.polygon1_position = polygon1_position
		deco.polygon2_position = polygon2_position
		deco.polygon3_position = polygon3_position
		deco.polygon4_position = polygon4_position
		deco.menu_name = menu_name
		add_child(deco)
		
		button_deco = $button_deco

func _on_focus_entered():
	if not disabled:
		modulate.r = 0.5
		modulate.g = 1.0
		modulate.b = 1.0
		
		if enable_deco:
			button_deco.scale = Vector2(1.2, 1.2)
			button_deco.on_focused()

func _on_focus_exited():
	if not disabled:
		modulate.r = 1.0
		modulate.g = 1.0
		modulate.b = 1.0

func _on_mouse_entered():
	if not disabled:
		modulate.r = 0.5
		modulate.g = 1.0
		modulate.b = 1.0
		
		if enable_deco and not ignore_mouse:
			button_deco.scale = Vector2(1.2, 1.2)
			button_deco.on_focused()
			
			ignore_mouse = true
			await get_tree().create_timer(0.3, false).timeout
			ignore_mouse = false

func _on_mouse_exited():
	if not disabled:
		modulate.r = 1.0
		modulate.g = 1.0
		modulate.b = 1.0

func _on_pressed():
	pass


#IF IS AN EPISODE BUTTON
func _on_self_pressed():
	if episode_select != "none":
		Globals.levelSet_id = episode_select


func _process(delta):
	if moving:
		position = lerp(position, Vector2(0, 0), delta * 5)
		rotation = lerp(rotation, 0.0, delta * 5)
		scale = lerp(scale, Vector2(1, 1), delta * 5)
		
		if enable_deco:
			button_deco.scale = lerp(button_deco.scale, Vector2(1, 1), delta * 5)
	
	if showing_up:
		modulate.a = move_toward(modulate.a, 1, delta * 2)
	
	if size.x > 960:
		size.x = 960
