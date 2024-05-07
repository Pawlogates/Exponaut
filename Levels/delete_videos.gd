extends Area2D

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if active:
		return
		
	if body.is_in_group("player"):
		active = true
		$"../Area2D".queue_free()
		$"../Area2D2".queue_free()
