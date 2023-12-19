extends Sprite2D

@onready var collect_particles = $".."


var x
var y
var z

var rng = RandomNumberGenerator.new()

@onready var animation_player = $"../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	x = rng.randf_range(0.5, 3)
	y = rng.randf_range(0, 3.6) * 100
	z = rng.randf_range(2, 4)
	
	collect_particles.scale = Vector2(x, x)
	collect_particles.rotation_degrees = (y)
	animation_player.speed_scale = z
	animation_player.play("afterSpawn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

