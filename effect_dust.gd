extends AnimatedSprite2D

var anim_slow = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if anim_slow:
		speed_scale = 2
	
	play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
