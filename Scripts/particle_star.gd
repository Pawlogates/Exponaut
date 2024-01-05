extends Sprite2D

@onready var collect_particles = $".."


var rng = RandomNumberGenerator.new()

var x = rng.randfn(0, 1)
var y = rng.randf_range(0, 3.6) * 100
var z = rng.randf_range(1, 2)



@onready var animation_player = $"../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	while x <= 0.4 and x >= -0.4:
		x = rng.randfn(0, 1)
	
	collect_particles.scale = Vector2(x, x)
	collect_particles.rotation_degrees = (y)
	animation_player.speed_scale = z
	animation_player.play("afterSpawn")




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_animation_player_animation_finished(_anim_name):
	collect_particles.queue_free()
