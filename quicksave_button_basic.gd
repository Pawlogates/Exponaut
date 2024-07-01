extends Button

var focused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_focus_entered():
	get_parent().modulate.a = 1
	focused = true


func _on_focus_exited():
	get_parent().modulate.a = 0.2
	focused = false
