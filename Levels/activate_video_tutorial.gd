extends Area2D

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		if not active:
			active = true
			await get_tree().create_timer(60, false).timeout
			$VideoStreamPlayer.play()
		
