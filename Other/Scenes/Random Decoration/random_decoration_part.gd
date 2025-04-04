extends Sprite2D

@export var pool_start_x = 0
@export var pool_start_y = 0
@export var pool_end_x = 12
@export var pool_end_y = 6

@export var randomize_opacity = false
@export var randomize_rotation = false
@export var randomize_scale = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rolled_offset_x = randi_range(pool_start_x, pool_end_x)
	var rolled_offset_y = randi_range(pool_start_y, pool_end_y)
	region_rect = Rect2(64 * rolled_offset_x, 64 * rolled_offset_y, 64, 64)
	
	if randomize_opacity : modulate.a = randf_range(0, 0.5)
	if randomize_rotation : rotation_degrees = randi_range(0, 360)
	if randomize_scale : scale = Vector2(randf_range(0.5, 1.5), randf_range(-1.5, 1.5))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
