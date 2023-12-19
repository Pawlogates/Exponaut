extends Sprite2D

@onready var node_2d = $".."
@onready var hit_effect = $"."


var rng = RandomNumberGenerator.new()
var x

# Called when the node enters the scene tree for the first time.
func _ready():
	x = rng.randf_range(-100, 100)
	hit_effect.offset.x = x
	hit_effect.offset.y = x
	node_2d.scale.x = clamp(abs(x/50), 0.5, 1)
	node_2d.scale.y = clamp(abs(x/50), 0.5, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
