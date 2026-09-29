extends Camera2D

var speed_multiplier : float = 0.01
var target_offset : Vector2 = Vector2(0, 0)
var target_zoom : Vector2 = Vector2(1, 1)
var target_rotation : float = 0.0


func _ready() -> void:
	if Globals.debug_force_camera_zoom or (is_instance_valid(Globals.World) and Globals.World.debug_force_camera_zoom):
		zoom = Vector2(Globals.debug_force_camera_zoom_value, Globals.debug_force_camera_zoom_value)
		rotation = 0

func _process(delta: float) -> void:
	handle_camera(delta)

func handle_camera(delta):
	if Globals.debug_force_camera_zoom:
		if not Input.is_action_pressed("ctrl"):
			zoom = Vector2(Globals.debug_force_camera_zoom_value, Globals.debug_force_camera_zoom_value)
			rotation = 0
			return
		#position.x = 0
		#position.y = 0
	
	if speed_multiplier == -0.1 : return
	
	offset = lerp(offset, target_offset, delta * speed_multiplier)
	if Globals.level_time_seconds > 15 : zoom = lerp(zoom, target_zoom + Vector2(0.5, 0.5), delta * speed_multiplier)
	else : zoom = lerp(zoom, target_zoom, delta * speed_multiplier)
	rotation_degrees = lerp(rotation_degrees, target_rotation, delta * speed_multiplier * 2)
	
	speed_multiplier *= 1.1
	if speed_multiplier > 1.0 : speed_multiplier = 1.0


func effect(camera_target_offset : Vector2 = Vector2(-1, -1), camera_target_zoom : Vector2 = Vector2(-1, -1), camera_target_rotation : float = -1, start_speed_multiplier : float = -1):
	if speed_multiplier == -0.1:
		if Globals.get_random_bool(0.05):
			await Globals.await_timer(20.0)
			speed_multiplier = 0.01
		
		return
	
	if start_speed_multiplier != -1 : speed_multiplier = start_speed_multiplier
	
	if camera_target_offset != Vector2(-1, -1) : target_offset = camera_target_offset
	if camera_target_zoom != Vector2(-1, -1) : target_zoom = camera_target_zoom
	if camera_target_rotation != -1 : target_rotation = camera_target_rotation
	
	#if camera_target_rotation != -1 and camera_target_rotation:
		#if is_instance_valid(Globals.World):
			#Globals..World.background.on_player_melee_hit(-camera_target_rotation / 4)
