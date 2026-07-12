extends Node2D

@onready var cooldown_spawn_particle: Timer = $cooldown_spawn_particle
@onready var collision : CollisionShape2D

var decoration_size : Vector2

var particle_multiplier : float = 1.0
var particle_rate : float = 0.01
var particle_base_scale : Vector2 = Vector2(1, 1)
var particle_base_anim_speed : float = 1.0


func _ready():
	collision = get_parent()
	
	decoration_size = collision.shape.size
	
	cooldown_spawn_particle.wait_time = particle_rate
	cooldown_spawn_particle.start()

func _physics_process(delta: float) -> void:
	decoration_size = collision.shape.size

func _on_cooldown_spawn_particle_timeout() -> void:
	var rolled_size : float = randf_range(2, 4)
	
	Globals.spawn_scenes(self, Globals.scene_particle_homing_square, randi_range(2, 6), Vector2(randi_range(-decoration_size.x / 2, decoration_size.x / 2), randi_range(-decoration_size.y / 2, decoration_size.y / 2)), 0.25, Color(0, -1, -1, randf_range(-0.75, -0.9)), Vector2(-rolled_size, -rolled_size))
