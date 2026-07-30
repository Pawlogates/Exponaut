extends AnimatedSprite2D

var active : bool = false

var master_node : Node

@export var outline_enabled : bool = true
@export var outline_simple : bool = true
var outline_part_quantity : int = 4 # Simple outline means that there are 4 outline parts, with 4 shadow outline parts.
@export var outline_min_opacity : float = 0.1
@export var outline_width : int = 1
@export var outline_color : Color = Color(-1, -1, -1, -1) # Outline color is randomized by default.


func _ready() -> void:
	if not outline_simple:
		outline_part_quantity = 8
	
	else:
		for x in range(5, 9):
			var outline_segment : Node = get_node("outline" + str(x))
			outline_segment.queue_free()
		
		for x in range(5, 9):
			var outline_segment : Node = get_node("outline_s" + str(x))
			outline_segment.queue_free()
	
	master_node = get_parent()
	
	await get_tree().create_timer(randf_range(0.25, 1), true).timeout
	
	if outline_enabled:
		for x in range(1, outline_part_quantity + 1):
			var outline_segment : Node = get_node("outline" + str(x))
			if outline_width != 1 : outline_segment.position *= outline_width
			var outline_s_segment : Node = get_node("outline_s" + str(x))
			if outline_width != 1 : outline_s_segment.position *= outline_width
		
		for x in range(1, outline_part_quantity + 1):
			var outline_segment : Node = get_node("outline" + str(x))
			#if outline_width != 1 : outline_segment.position *= outline_width
			#outline_segment.sprite_frames = sprite_frames
			
			var rolled_color : Color
			if outline_color == Color(-1, -1, -1, -1) : rolled_color = str(Globals.l_color_all.pick_random()).to_upper()
			else : rolled_color = outline_color
			
			outline_segment.modulate = rolled_color
			outline_segment.modulate *= randf_range(outline_min_opacity, 10)
			outline_segment.modulate.a = randf_range(outline_min_opacity, 2)
			
			outline_segment.visible = true
			
			#outline_segment.position.x += randi_range(-24, 24)
			#outline_segment.position.y += randi_range(-24, 24)
			
			var outline_s_segment : Node = get_node("outline" + str(x))
			outline_s_segment.sprite_frames = sprite_frames
			outline_s_segment.visible = true
	
	else:
		set_process(false)
		
		for x in range(1, outline_part_quantity + 1):
			var outline_segment : Node = get_node("outline" + str(x))
			
			outline_segment.queue_free()

func _process(delta: float) -> void:
	if outline_enabled:
		for x in range(1, outline_part_quantity + 1):
			var outline_segment : Node = get_node("outline" + str(x))
			outline_segment.flip_h = flip_h
			outline_segment.flip_v = flip_v
			outline_segment.animation = animation
			outline_segment.frame = frame
			
			var outline_s_segment : Node = get_node("outline_s" + str(x))
			outline_s_segment.flip_h = flip_h
			outline_s_segment.flip_v = flip_v
			outline_s_segment.animation = animation
			outline_s_segment.frame = frame


func set_active(state : bool = true):
	active = state
	set_process(state)
	set_physics_process(false)
