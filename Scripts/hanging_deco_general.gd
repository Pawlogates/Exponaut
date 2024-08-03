extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



var movement_active = false
var lastSegment_velocity_x = 0
var speedBuildUp = 1

func _process(delta):
	if movement_active:
		lastSegment_velocity_x = %Segment4.linear_velocity.x
		%Segment4.linear_velocity.x = move_toward(lastSegment_velocity_x, 500, speedBuildUp * delta)


func _on_timer_timeout():
	$Timer.wait_time = randi_range(2, 10)
	speedBuildUp = randi_range(5, 15)
	if movement_active:
		movement_active = false
	else:
		movement_active = true
