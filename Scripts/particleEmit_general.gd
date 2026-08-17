extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	scale *= randf_range(2.85, 5.15)
