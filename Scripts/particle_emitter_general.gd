extends GPUParticles2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var anim_fade_in : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#texture.region.position.x = 896
	#texture.region.position.x += 32 * randi_range(0, 3)
	if anim_fade_in:
		modulate = modulate.blend(Color(Globals.l_color_all.pick_random()) / 8)
		modulate.a = 0
		animation_player.speed_scale = randf_range(0.1, 1.25)
		animation_player.play("opacity_fade_in_and_out")
	
	emitting = true

func _physics_process(delta: float) -> void:
	pass
