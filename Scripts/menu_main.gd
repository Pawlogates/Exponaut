extends Control

@onready var container_buttons: VBoxContainer = $container_buttons
@onready var timer_destabilized: Timer = $timer_destabilized

@export var randomize_default_preset : bool = true

var l_destabilize_type = ["pos", "rotation", "scale"]
var l_destabilize_values_default = [4000, 180, 20.0]

func _ready() -> void:
	Globals.debug4.connect(debug_destabilize_buttons_randomize)
	
	for button in container_buttons.get_children():
		button.button_ready.connect(on_button_ready)

func _process(delta: float) -> void:
	pass


func destabilize_buttons_randomize(d_pos : bool = true, d_pos_range_x : int = 4000, d_pos_range_y : int = 0, d_rotation : bool = true, d_rotation_range : int = 180, d_scale : bool = true, d_scale_match : bool = true, d_scale_range_x : float = 20, d_scale_range_y : float = 0): # The "d" stands for "destabilize".
	Globals.message_debug("Destabilizing buttons (d_pos = " + str(d_pos) + ", " + "d_pos_range_x = " + str(d_pos_range_x) + ", " + "d_pos_range_y = " + str(d_pos_range_y) + ", " + "d_rotation = " + str(d_rotation) + ", " + "d_rotation_range = " + str(d_rotation_range) + ", " + "d_scale = " + str(d_scale) + "," + "d_scale_match = " + str(d_scale_match) + ", " + "d_scale_range_x = " + str(d_scale_range_x) + ", " + "d_scale_range_y = " + str(d_scale_range_y) + ".")
	timer_destabilized.start()
	
	var destabilize_type = l_destabilize_type.pick_random()
	
	for button in container_buttons.get_children():
		if button.is_in_group("UI_button"):
			
			button.stabilized = false
			
			button.pivot_offset = Vector2(randf_range(0, size.x), randf_range(0, size.y))
			button.pivot_offset *= Vector2(randf_range(-2, 2), randf_range(-2, 2))
			
			if destabilize_type == "pos":
				
				if d_pos:
					
					button.position += Vector2(randi_range(-d_pos_range_x, d_pos_range_x), randi_range(-d_pos_range_y, d_pos_range_y))
					if abs(button.position.x) <= 1600 : button.position.x += randi_range(-d_pos_range_x, d_pos_range_x)
			
			elif destabilize_type == "rotation":
				if d_rotation : button.rotation_degrees += randi_range(-d_rotation_range, d_rotation_range)
			
			elif destabilize_type == "scale":
				if d_scale:
					if d_scale_match:
						button.scale.x += randf_range(0, d_scale_range_x)
						button.scale.y = button.scale.x
					
					else:
						button.scale += Vector2(randf_range(0, d_scale_range_x), randf_range(0, d_scale_range_y))


func _on_timer_destabilized_timeout() -> void:
	for button in container_buttons.get_children():
		if button.is_in_group("UI_button"):
			
			button.stabilized = true


var ready_buttons = 0

func on_button_ready():
	ready_buttons += 1
	
	Globals.message_debug("Ready menu buttons: %s" % ready_buttons)
	if ready_buttons == len(container_buttons.get_children()):
		if randomize_default_preset : destabilize_buttons_randomize() # No arguments means: "default preset".
		ready_buttons = 0

var debug_available = true

func _on_cooldown_debug_available_timeout() -> void:
	debug_available = true


func debug_destabilize_buttons_randomize():
	if not debug_available : return
	
	destabilize_buttons_randomize()
	
	debug_available = false
	$cooldown_debug_available.start()
