extends Node2D

@export var on_spawn_delete_if_stuck : bool = true

@onready var scan: RayCast2D = $scan

func _ready() -> void:
	await get_tree().create_timer(1.0, true).timeout
	
	if get_parent().on_spawn_delete_if_stuck:
		if Globals.World.level_time_seconds <= 4:
			if scan.is_colliding():
				Globals.spawn_scenes(Globals.World, load("res://Collectibles/apple.tscn"), 12, get_parent().position, -1, Color.BLUE, Vector2(1, 1), 100, ["on_spawn_delete_if_stuck"], [false])
				get_parent().queue_free()
	
	else:
		queue_free()
