extends Node2D

var add_position_x : int = 0
var add_position_y : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_position_x = randi_range(-1000, 2000)
	
	if weather_type == "leaves":
		$Timer.wait_time = randf_range(0.05, 8.0)
		$Timer2.wait_time = randf_range(0.05, 8.0)
		$Timer.start()
		$Timer2.start()

@export var weather_type = "none"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	position.x = Globals.player_position.x + add_position_x
	position.y = Globals.player_position.y - 1200 / Globals.Player.camera.zoom.y


var rng = RandomNumberGenerator.new()
var scene_leaf = preload("res://Other/Particles/leaf.tscn")
var scene_leaf2 = preload("res://Other/Particles/leaf2.tscn")

func _on_timer_timeout():
	$Timer.wait_time = randf_range(0.05, 8.0)
	var leaf = scene_leaf.instantiate()
	get_node("/root/World").add_child(leaf)
	leaf.position = Globals.Player.position + Vector2(randi_range(1200, -1200), randi_range(-600, -1200))

func _on_timer_2_timeout():
	$Timer2.wait_time = randf_range(0.05, 8.0)
	var leaf2 = scene_leaf2.instantiate()
	get_node("/root/World").add_child(leaf2)
	leaf2.position = Globals.Player.position + Vector2(randi_range(1200, -1200), randi_range(-600, -1200))
