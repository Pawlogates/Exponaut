extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	# Creates non repeating inputs, but fails with multiple at once.
	
	#for button in get_tree().get_nodes_in_group("touch_screen_button_general"):
		#var queued_pressed = button.is_pressed
		#var queued_action = button.name
		#
		#
		#if Input.is_action_pressed(queued_action) and queued_pressed:
			#continue
		#if not Input.is_action_pressed(queued_action) and not queued_pressed:
			#continue
		#
		#var action = InputEventAction.new()
		#action.pressed = button.is_pressed
		#action.action = button.name
		#Input.parse_input_event(action)
		#print(str(button.name), " ", str(button.is_pressed))


func _on_timer_timeout() -> void:
	$AnimationPlayer.play("disappear")
	await $AnimationPlayer.animation_finished
	queue_free()


func _input(event):
	if "Screen" in str(event):
		$Timer.start()
