extends Area2D

var width = 0.0
var trigger_value = 0.0
var distance_X = 0.0

var offsetValue = 0
var offsetValue_Y = 0
var zoomValue = 1


@export var left_to_right = true

@export var moveCamera = true
@export var camera_baseOffset = 250
@export var minOffset = -250
@export var maxOffset = 250
@export var camera_baseOffset_Y = 250
@export var minOffset_Y = -250
@export var maxOffset_Y = 250

@export var zoomCamera = true
@export var camera_baseZoom = 2
@export var minZoom = 0.5
@export var maxZoom = 1.5



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for area in get_overlapping_areas():
		if area.get_parent().is_in_group("player"):
			distance_X = area.get_parent().position[0] - position.x
			width = %shape.shape.size[0]
			trigger_value = clamp(distance_X / width / scale[0] * 2, -1, 1)
			if not left_to_right:
				trigger_value *= -1
	
			#$Label.text = str(area.get_parent().position[0] - position.x)
			#$Label2.text = str(trigger_value)
			#$Label3.text = str(area.get_parent().position[0])
			
			#$/root/World.music.volume_db = trigger value

			if moveCamera:
				offsetValue = float(clamp(camera_baseOffset * trigger_value, minOffset, maxOffset))
				offsetValue_Y = float(clamp(camera_baseOffset_Y * trigger_value, minOffset_Y, maxOffset_Y))
				$/root/World.camera.position[0] = lerp($/root/World.camera.position[0], offsetValue, 5 * delta)
				$/root/World.camera.position[1] = lerp($/root/World.camera.position[1], offsetValue_Y, 5 * delta)
			
			if zoomCamera:
				zoomValue = clamp(camera_baseZoom * trigger_value, minZoom, maxZoom)
				$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(zoomValue, zoomValue), delta)
