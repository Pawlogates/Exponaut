extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

@onready var bg_transition = %bg_transition


var transitioning = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not transitioning and not bg_transition.current_animation == "bg_show" and not bg_transition.current_animation == "bg_hide":
		transitioning = true
		Globals.bgTransition_finished.emit()
		#print("bg_freed")
		%bg_transition_buffer_delay.start()



func _on_bg_transition_buffer_delay_timeout():
	transitioning = false
