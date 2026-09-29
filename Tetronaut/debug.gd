extends Node2D

func _ready() -> void:
	Globals.gameState_tetronaut = true
	Globals.set_pause(false)
	
	await Overlay.animation("black_fade_out", 1.0, false, false, 0, false, "res://Other/Scenes/transition_gears.tscn", 2.0, Vector2(-2, 0))

func _physics_process(delta: float) -> void:
	pass


func get_random_point_in_range(rect_size_multiplier : Vector2 = Vector2(1.0, 1.0), rect_size_base : Vector2 = Globals.window_size):
	var rect_size : Vector2 = rect_size_base * rect_size_multiplier
	return Vector2(randi_range(-rect_size.x / 2, rect_size.x / 2), randi_range(-rect_size.y / 2, rect_size.y / 2))
