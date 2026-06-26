extends AnimatedSprite2D

var master_node : Node

@export var outline_enabled : bool = true
@export var outline_min_opacity : float = 0.1


func _ready() -> void:
	master_node = get_parent()
	
	await get_tree().create_timer(randf_range(0.25, 1), true).timeout
	
	if outline_enabled:
		for x in range(1, 9):
			
			var outline_segment : Node = get_node("outline" + str(x))
			outline_segment.sprite_frames = sprite_frames
			
			var rolled_color : String = str(Globals.l_color_all.pick_random()).to_upper()
			
			if Globals.random_bool(1, 111) : outline_segment.modulate = rolled_color
			outline_segment.modulate *= randf_range(outline_min_opacity, 10)
			outline_segment.modulate.a = randf_range(outline_min_opacity, 2)
			
			outline_segment.visible = true
			
			#outline_segment.position.x += randi_range(-24, 24)
			#outline_segment.position.y += randi_range(-24, 24)
	
	else:
		set_process(false)
		
		for x in range(1, 9):
			var outline_segment : Node = get_node("outline" + str(x))
			
			outline_segment.queue_free()

func _process(delta: float) -> void:
	if outline_enabled:
		for x in range(1, 9):
			var outline_segment : Node = get_node("outline" + str(x))
			outline_segment.flip_h = flip_h
			outline_segment.flip_v = flip_v
			outline_segment.animation = animation
			outline_segment.frame = frame
