extends TileMap

@export var randomize_modulate : bool = false
@export var randomize_modulate_dark : bool = false

func _ready() -> void:
	if randomize_modulate_dark:
		modulate *= randf_range(0.5, 1.0)
		modulate.a = 1.0
