extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = randf_range(0.5, 4)
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()
