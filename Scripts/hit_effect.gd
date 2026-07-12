extends Node2D

@onready var hit_effect_root = $"."
@onready var hit_effect = $hit_effect

var rng = RandomNumberGenerator.new()
var x

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_effect_root.scale *= randf_range(0.9, 1.1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	queue_free()
