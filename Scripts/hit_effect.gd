extends Node2D

@onready var hit_effect_root = $"."
@onready var hit_effect = $hit_effect


var rng = RandomNumberGenerator.new()
var x

# Called when the node enters the scene tree for the first time.
func _ready():
	x = rng.randf_range(-100, 100)
	hit_effect.offset.x = x
	hit_effect.offset.y = x
	hit_effect_root.scale.x = clamp(abs(x/50), 0.5, 1)
	hit_effect_root.scale.y = clamp(abs(x/50), 0.5, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	queue_free()
