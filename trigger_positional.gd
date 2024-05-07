extends Area2D

var width = 0.0
var trigger_value = 0.0
var distance_X = 0.0

var zoomValue = 1


@export var moveCamera = true
@export var camera_baseOffset = 250
@export var zoomCamera = true
@export var camera_baseZoom = 1
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
			trigger_value = distance_X / width / scale[0] * 2
	
			#$Label.text = str(area.get_parent().position[0] - position.x)
			#$Label2.text = str(trigger_value)
			#$Label3.text = str(area.get_parent().position[0])
			
			#$/root/World.music.volume_db = trigger value

			if moveCamera:
				$/root/World.camera.position[0] = camera_baseOffset * trigger_value
			
			if zoomCamera:
				zoomValue = clamp(camera_baseZoom * trigger_value, minZoom, maxZoom)
				$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(zoomValue, zoomValue), delta)
