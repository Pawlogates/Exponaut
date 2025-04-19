extends TouchScreenButton

var is_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	is_pressed = true
	modulate.a = 0.5


func _on_released() -> void:
	is_pressed = false
	modulate.a = 1.0
