extends Node2D

@onready var sfx_manager: Node2D = $sfx_manager

func _on_area_entered(area):
	if not area.is_in_group("player_hitbox") : return
	if Globals.node_exists("screen_results_level") : return
	
	Globals.exit_activated.emit()

func _physics_process(delta: float) -> void:
	modulate.r = move_toward(modulate.r, 1.0, delta)
	modulate.g = move_toward(modulate.g, 1.0, delta)
	modulate.b = move_toward(modulate.b, 1.0, delta)
