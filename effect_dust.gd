extends AnimatedSprite2D

@export var anim_slow = false
@export var moveUp = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if anim_slow:
		speed_scale = 0.5
		$Timer.wait_time = 4
	
	play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moveUp:
		position.y -= 1


func _on_timer_timeout():
	queue_free()
