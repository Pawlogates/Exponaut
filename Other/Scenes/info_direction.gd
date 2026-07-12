extends Node2D

@onready var arrow_up: Node2D = $arrow_up
@onready var arrow_down: Node2D = $arrow_down
@onready var attack_main: Node2D = $attack_main


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		arrow_up.modulate.a = 1
	else:
		arrow_up.modulate.a = 0.5
	
	if Input.is_action_pressed("move_down"):
		arrow_down.modulate.a = 1
	else:
		arrow_down.modulate.a = 0.5
	
	if Input.is_action_pressed("attack_secondary"):
		attack_main.modulate.a = 1
	else:
		attack_main.modulate.a = 0.5
