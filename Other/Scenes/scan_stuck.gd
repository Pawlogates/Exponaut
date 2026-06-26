extends Node2D

@onready var scan: RayCast2D = $scan

@export var on_spawn_delete_if_stuck : bool = true

var master_node : Node

func _ready() -> void:
	master_node = get_parent()

func _physics_process(delta: float) -> void:
	if scan.is_colliding():
		if is_instance_valid(master_node) and "block_movement" in master_node:
			master_node.block_movement = true
			master_node.position.x += randi_range(-4, 4)
			master_node.position.y += randi_range(-12, 4)
	
	else:
		if is_instance_valid(Globals.World) and Globals.World.level_time_seconds < 4:
			if is_instance_valid(master_node) and "block_movement" in master_node:
				master_node.block_movement = false
