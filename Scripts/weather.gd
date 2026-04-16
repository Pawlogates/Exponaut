extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	position.y = -2000
	
	if weather_type == "leaves":
		$Timer.start()
		$Timer2.start()

@export var weather_type = "none"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position.x = Globals.player_position.x
	pass


var rng = RandomNumberGenerator.new()
var scene_leaf = preload("res://Other/Particles/leaf.tscn")
var scene_leaf2 = preload("res://Other/Particles/leaf2.tscn")

func _on_timer_timeout():
	var leaf = scene_leaf.instantiate()
	get_node("/root/World").add_child(leaf)
	leaf.position = global_position + Vector2(rng.randf_range(400.0, -400.0), 0)

func _on_timer_2_timeout():
	var leaf2 = scene_leaf2.instantiate()
	get_node("/root/World").add_child(leaf2)
	leaf2.position = global_position + Vector2(rng.randf_range(400.0, -400.0), 0)
