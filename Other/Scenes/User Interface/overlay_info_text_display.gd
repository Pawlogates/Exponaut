extends Control

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


#var displaying = false
var display_text = "empty"
var display_size = 0

func display_show(display_text, display_size):
	%info_text.text = str(display_text)
	
	if display_size == 0:
		animation_player.play("show_0")
	elif display_size == 1:
		animation_player.play("show_1")
	elif display_size == 2:
		animation_player.play("show_2")
	elif display_size == 3:
		animation_player.play("show_3")
	
	$Control/Timer.wait_time = 7.5 * display_size
	$Control/Timer.start()
	
	print("Showing debug display. " + str(display_size) + " " + str(display_text))


func _on_timer_timeout():
	if display_size == 0:
		animation_player.play("hide_0")
	elif display_size == 1:
		animation_player.play("hide_1")
	elif display_size == 2:
		animation_player.play("hide_2")
	elif display_size == 3:
		animation_player.play("hide_3")
