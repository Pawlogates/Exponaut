extends AnimatedSprite2D

@export var outline_enabled : bool = true


func _ready() -> void:
	if outline_enabled:
		for x in range(1, 9):
			var outline_segment : Node = get_node("outline" + str(x))
			
			outline_segment.sprite_frames = sprite_frames
			outline_segment.visible = true
	
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
