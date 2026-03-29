extends Timer

func _ready():
	if Globals.random_bool(9, 1) : $"../Label".queue_free()
	wait_time = randf_range(4, 30)
	start()
	await get_tree().create_timer(8.0, true).timeout
	if get_node("../Label") : $"../Label".visible = true

func _on_timeout() -> void:
	Globals.World.retry()
