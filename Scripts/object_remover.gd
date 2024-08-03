extends Area2D

var active = false
var finished = false
var node = Node2D
@export var object_to_remove = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not finished and active:
		node.modulate.a = move_toward(node.modulate.a, 0, delta)
		


func _on_body_entered(body):
	if body.is_in_group("player"):
		if active:
			return
			
		node = get_parent().get_node(object_to_remove)
		active = true
		$Timer.start()
		set_process(true)


func _on_timer_timeout():
	set_process(false)
	finished = true
	node.queue_free()
