extends Node2D

@onready var cooldown_spawn_particle: Timer = $cooldown_spawn_particle
@onready var collision : CollisionShape2D

var decoration_size : Vector2

@export var particle_multiplier : float = 1.0
@export var particle_rate : float = 0.01
@export var particle_base_scale : Vector2 = Vector2(1, 1)
@export var particle_base_anim_speed : float = 1.0

var active : bool = false


func _ready():
	collision = get_parent()
	
	decoration_size = collision.shape.size
	
	cooldown_spawn_particle.wait_time = particle_rate
	cooldown_spawn_particle.start()

func _physics_process(delta: float) -> void:
	if not active : return
	
	decoration_size = collision.shape.size

func _on_cooldown_spawn_particle_timeout() -> void:
	if not active : return
	
	var rolled_size : float = particle_base_scale.x * randf_range(1.0, 4.0)
	
	Globals.spawn_scenes(self, Globals.scene_particle_homing_square, randi_range(2, 6), Vector2(randi_range(-decoration_size.x / 2, decoration_size.x / 2), randi_range(-decoration_size.y / 2, decoration_size.y / 2)), 0.25, Color(0, -1, -1, randf_range(-0.75, -0.9)), Vector2(-rolled_size, -rolled_size))


func set_state(state : bool):
	if state:
		active = true
		visible = true
		cooldown_spawn_particle.paused = false
		#cooldown_spawn_particle.start()
		set_physics_process(true)
	else:
		active = false
		visible = false
		cooldown_spawn_particle.paused = true
		set_physics_process(false)
