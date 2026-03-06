extends Area2D

var active = false

var trigger_value = 0.0

var width = 0.0
var height = 0.0
var distance_x = 0.0 # Distance between the player and the trigger's edge.
var distance_y = 0.0

var offsetValue = 0.0
var offsetValue_Y = 0.0
var zoomValue = 1.0

@export var reset_camera_offset = false
@export var reset_camera_zoom = false

@export var horizontal = true # The left edge of the trigger applies the value of "0", while the right edge applies the value of "1".
@export var vertical = false  # The bottom edge of the trigger applies the value of "0", while the top edge applies the value of "1".

@export var right_to_left = false # By default, the starting point (value of "0") is considered to be the left side, and the end point is the right side (value of "1"). This property will reverse that relation.
@export var top_to_bottom = false # By default, the starting point (value of "0") is considered to be the bottom side.

@export var camera_offset = true
@export var camera_target_offset : Vector2 = Vector2(256, -128)

@export var camera_zoom = false
@export var camera_target_zoom : Vector2 = Vector2(2, 2)


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.0, true).timeout
	active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not active:
		return
	
	$Label.text = str(trigger_value)
	
	for area in get_overlapping_areas():
		if Globals.is_valid_entity(area):
			if horizontal:
				if not right_to_left:
					width = %shape.shape.size.x
					distance_x = area.get_parent().position.x - (position.x - (width / 2 * scale.x))
					#trigger_value = clamp(1.2 * distance_X / width / scale[0] * 2, -1, 1) * -1
					trigger_value = clamp(distance_x / (width * scale.x), 0, 1)
			
			if vertical:
				if not top_to_bottom:
					height = %shape.shape.size.y
					distance_y = area.get_parent().position.y - (position.y - (height / 2 * scale.y))
					#trigger_value = clamp(1.2 * distance_X / width / scale[0] * 2, -1, 1) * -1
					trigger_value = clamp(distance_y / (height * scale.y), 0, 1)
			
			if reset_camera_offset:
				Globals.Player.camera.effect(Vector2(0, 0), Vector2(-1, -1))
				return
				
			if reset_camera_zoom:
				Globals.Player.camera.effect(Vector2(-1, -1), Vector2(1, 1))
				return
			
			if camera_offset:
				Globals.Player.camera.effect(camera_target_offset * trigger_value, Vector2(-1, -1), 0, 1)
			
			if camera_zoom:
				Globals.Player.camera.effect(Vector2(-1, -1), camera_target_zoom * trigger_value, 0, 1)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		$Timer.stop()
		active = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		$Timer.start()

func _on_timer_timeout():
	active = false
