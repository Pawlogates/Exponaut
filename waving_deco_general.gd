extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var x =randi_range(1, 3)
	if x == 1:
		$Sprite2D.material = load("res://Themes/wave1.tres")
	elif x == 2:
		$Sprite2D.material = load("res://Themes/wave2.tres")
	elif x == 3:
		$Sprite2D.material = load("res://Themes/wave3.tres")
	
	position += Vector2(randf_range(-10, 10) * x, randf_range(-5, 15) * x)
	scale += Vector2(randf_range(-0.2, 0.2) * x, randf_range(-0.2, 0.2) * x)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
