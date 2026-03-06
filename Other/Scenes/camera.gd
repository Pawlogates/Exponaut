extends Camera2D

var speed_multiplier : float = 0.01
var target_offset : Vector2 = Vector2(0, 0)
var target_zoom : Vector2 = Vector2(1, 1)
var target_rotation : float = 0.0


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	handle_camera(delta)

func handle_camera(delta):
	offset = lerp(offset, target_offset, delta * speed_multiplier)
	zoom = lerp(zoom, target_zoom, delta * speed_multiplier)
	rotation_degrees = lerp(rotation_degrees, target_rotation, delta * speed_multiplier)
	
	speed_multiplier *= 1.1
	if speed_multiplier > 1.0 : speed_multiplier = 1.0


func effect(camera_target_offset : Vector2 = Vector2(-1, -1), camera_target_zoom : Vector2 = Vector2(-1, -1), camera_target_rotation : float = -1, start_speed_multiplier : float = 0.01):
	if start_speed_multiplier != -1 : speed_multiplier = start_speed_multiplier
	
	if camera_target_offset != Vector2(-1, -1) : target_offset = camera_target_offset
	if camera_target_zoom != Vector2(-1, -1) : target_zoom = camera_target_zoom
	if camera_target_rotation != -1 : target_rotation = camera_target_rotation
