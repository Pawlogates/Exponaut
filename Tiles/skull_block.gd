extends StaticBody2D

@export var is_active = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_active:
		%Sprite2D.region_rect = Rect2(384, 896, 64, 64)
		%CollisionShape2D.disabled = false
	
	else:
		%Sprite2D.region_rect = Rect2(448, 896, 64, 64)
		%CollisionShape2D.disabled = true



func skull_block_toggle():
	if not is_active:
		%Sprite2D.region_rect = Rect2(384, 896, 64, 64)
		%CollisionShape2D.disabled = false
		is_active = true
	
	else:
		%Sprite2D.region_rect = Rect2(448, 896, 64, 64)
		%CollisionShape2D.disabled = true
		is_active = false


func deferred_skull_block_toggle():
	call_deferred("skull_block_toggle")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
