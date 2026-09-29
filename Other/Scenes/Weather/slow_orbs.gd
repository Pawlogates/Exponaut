extends Node2D

@onready var cooldown_spawn_slow_orb: Timer = $cooldown_spawn_slow_orb


func _ready() -> void:
	restart_cooldown_spawn_slow_orb()

func _on_cooldown_spawn_slow_orb_timeout() -> void:
	Globals.spawn_scenes(Globals.World, load("res://Other/Particles/slow_orb.tscn"), randi_range(1, 4), Globals.player_position + Vector2(randf_range(-Globals.window_size.x, Globals.window_size.x), randf_range(-Globals.window_size.y, Globals.window_size.y)) / 2, 60, Color(0, 0, 0, 0), Vector2(0, 0), randi_range(-25, 50))
	restart_cooldown_spawn_slow_orb()

func restart_cooldown_spawn_slow_orb():
	cooldown_spawn_slow_orb.wait_time = randf_range(0.01, 2.0)
	cooldown_spawn_slow_orb.start()
