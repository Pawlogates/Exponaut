extends Sprite2D

@onready var collect_particles = $".."


var x
var y
var variable_time

var rng = RandomNumberGenerator.new()

@onready var animation_player = $"../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	x = rng.randf_range(-2, 2)
	y = x * 100
	variable_time = x
	
	collect_particles.scale = Vector2(x, x)
	collect_particles.rotation_degrees = (y)
	animation_player.speed_scale = abs(variable_time)
	animation_player.play("afterSpawn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_animation_player_animation_finished(anim_name):
	collect_particles.queue_free()
