extends Button

var is_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_down() -> void:
	is_pressed = true


func _on_button_up() -> void:
	is_pressed = false


func _on_focus_entered() -> void:
	modulate.a = 0.5


func _on_focus_exited() -> void:
	modulate.a = 1.0
