extends Area2D

@onready var cooldown_spawn_particle: Timer = $cooldown_spawn_particle
@onready var collision_patrolling: CollisionShape2D = $collision_patrolling

var vision_size : Vector2

var particle_multiplier : float = 1.0
var particle_rate : float = 0.01
var particle_base_scale : Vector2 = Vector2(1, 1)
var particle_base_anim_speed : float = 1.0


func _ready():
	vision_size = collision_patrolling.shape.size
	
	cooldown_spawn_particle.wait_time = particle_rate
	cooldown_spawn_particle.start()

func _on_cooldown_spawn_particle_timeout() -> void:
	var rolled_size : float = randf_range(2, 6)
	
	Globals.spawn_scenes(collision_patrolling, Globals.scene_particle_score, 1, Vector2(randi_range(-vision_size.x / 2, vision_size.x / 2), randi_range(-vision_size.y / 2, vision_size.y / 2)), 0.25, Color(0, -1, -1, randf_range(-0.5, -0.9)), Vector2(-rolled_size, -rolled_size))
