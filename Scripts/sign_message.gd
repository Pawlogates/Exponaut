extends StaticBody2D

@onready var t_effect_inactive: Timer = $timer_effect_inactive


@export var message_text = "none"
@export var message_add_pos : Vector2 = Vector2(0, 0)

@export var anim_hide_cooldown : float = 8.0
@export var anim_speed_scale : float = 1.0

@export var pause_duration : float = 6.0

@export var camera_target_offset : Vector2 = Vector2(64, 64)
@export var camera_target_zoom : Vector2 = Vector2(3, 3)
@export var camera_target_rotation : float = 10.0
@export var camera_start_speed_multiplier : float = 0.01


var effect_active = true # Must be equal to "true" for the pause and camera-based effects to be triggered.


func _on_area_2d_area_entered(area):
	if not Globals.is_valid_entity(area) : return
	
	if effect_active : Globals.message(str(message_text), pause_duration, message_add_pos, anim_hide_cooldown, anim_speed_scale, camera_target_offset, camera_target_zoom, camera_target_rotation, camera_start_speed_multiplier)
	else : Globals.message(str(message_text), 0.0)
	
	effect_active = false
	t_effect_inactive.start()


func _on_timer_effect_inactive_timeout() -> void:
	effect_active = true
