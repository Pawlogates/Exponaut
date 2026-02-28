extends Area2D

var active = false

var trigger_value = 0.0

var trigger_value_X = 0.0
var trigger_value_Y = 0.0

var width = 0.0
var height = 0.0
var distance_X = 0.0
var distance_Y = 0.0

var offsetValue = 0.0
var offsetValue_Y = 0.0
var zoomValue = 1.0

@export var RESET_OFFSET = false
@export var RESET_ZOOM = false

@export var horizontal = true
@export var vertical = false

@export var right_to_left = false
@export var bottom_to_top = false

@export var moveCamera = true
@export var camera_baseOffset = 250
@export var minOffset = -250
@export var maxOffset = 250
@export var camera_baseOffset_Y = 250
@export var minOffset_Y = -250
@export var maxOffset_Y = 250

@export var zoomCamera = true
@export var camera_baseZoom = 2.0
@export var minZoom = 0.5
@export var maxZoom = 1.5


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.0, true).timeout
	active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not active:
		return
	
	for area in get_overlapping_areas():
		if area.is_in_group("Player"):
			if horizontal:
				distance_X = area.get_parent().position[0] - position.x
				width = %shape.shape.size[0]
				trigger_value = clamp(distance_X / width / scale[0] * 2, -1, 1) * -1
				if right_to_left:
					trigger_value *= -1
				trigger_value_X = trigger_value
					
			if vertical:
				distance_Y = area.get_parent().position[1] - position.y
				height = %shape.shape.size[1]
				trigger_value = clamp(distance_Y / height / scale[1] * 2, -1, 1)
				if bottom_to_top:
					trigger_value *= -1
				trigger_value_Y = trigger_value
			
			if horizontal and vertical:
				trigger_value = (trigger_value_X + trigger_value_Y) / 2
	
			#$Label.text = str(area.get_parent().position[0] - position.x)
			#$Label2.text = str(trigger_value)
			#$Label3.text = str(area.get_parent().position[0])
			
			#$/root/World.music.volume_db = trigger value
			
			if RESET_OFFSET and RESET_ZOOM:
				Globals.World.camera.position[0] = lerp(Globals.World.camera.position[0], 0.0, delta * 20)
				Globals.World.camera.position[1] = lerp(Globals.World.camera.position[1], 0.0, delta * 20)
				Globals.World.camera.zoom = Globals.World.camera.zoom.lerp(Vector2(1.0, 1.0), delta * 20)
				return
			
			if RESET_OFFSET:
				$/root/World.camera.position[0] = lerp($/root/World.camera.position[0], 0.0, delta * 20)
				$/root/World.camera.position[1] = lerp($/root/World.camera.position[1], 0.0, delta * 20)
				return
				
			if RESET_ZOOM:
				$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(1.0, 1.0), delta * 20)
				return
			
			if moveCamera:
				offsetValue = float(clamp(camera_baseOffset * trigger_value, minOffset, maxOffset))
				offsetValue_Y = float(clamp(camera_baseOffset_Y * trigger_value, minOffset_Y, maxOffset_Y))
				$/root/World.camera.position[0] = lerp($/root/World.camera.position[0], offsetValue, 5 * delta)
				$/root/World.camera.position[1] = lerp($/root/World.camera.position[1], offsetValue_Y, 5 * delta)
			
			if zoomCamera:
				zoomValue = clamp(camera_baseZoom * trigger_value, minZoom, maxZoom)
				$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(zoomValue, zoomValue), delta)
			
			return
	
	#if RESET_OFFSET and RESET_ZOOM:
		#$/root/World.camera.position[0] = lerp($/root/World.camera.position[0], 0.0, delta)
		#$/root/World.camera.position[1] = lerp($/root/World.camera.position[1], 0.0, delta)
		#$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(1.0, 1.0), delta)
		#return
#
	#if RESET_OFFSET:
		#$/root/World.camera.position[0] = lerp($/root/World.camera.position[0], 0.0, delta)
		#$/root/World.camera.position[1] = lerp($/root/World.camera.position[1], 0.0, delta)
		#return
		#
	#if RESET_ZOOM:
		#$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(1.0, 1.0), delta)
		#return
	#
	#
	#if moveCamera:
		#if $/root/World.camera.position[0] != offsetValue:
			#$/root/World.camera.position[0] = lerp($/root/World.camera.position[0], offsetValue, delta)
		#if $/root/World.camera.position[1] != offsetValue_Y:
			#$/root/World.camera.position[1] = lerp($/root/World.camera.position[1], offsetValue_Y, delta)
	#if zoomCamera:
		#if $/root/World.camera.zoom != Vector2(zoomValue, zoomValue):
			#$/root/World.camera.zoom = $/root/World.camera.zoom.lerp(Vector2(zoomValue, zoomValue), delta)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		$Timer.stop()
		active = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		$Timer.start()

func _on_timer_timeout():
	active = false
