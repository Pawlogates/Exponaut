extends Label

var message = "none"
var repeats = 0

@onready var c_remove: Timer = $cooldown_remove
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var display = $/root/Overlay/debug_display_messages
@onready var message_container = $/root/Overlay/debug_display_messages/message_container

var id : int = 0
var cooldown_remove = 4.0

func _ready() -> void:
	text = message
	c_remove.wait_time = cooldown_remove
	c_remove.start()
	
	if text.ends_with("[1]"):
		modulate.r = 0.3
	elif text.ends_with("[2]"):
		modulate.b = 0.3
	elif text.ends_with("[3]"):
		modulate.g = 0.3
	
	await get_tree().create_timer(0.1, true).timeout # The message positions also get corrected after a delay, so it looks best when a new message isn't visible immediately.
	
	visible = true

func _on_cooldown_delay_timeout() -> void:
	animation_player.play("fade_out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		display.active_messages -= 1
		Globals.messages_debug_removed.emit()
		queue_free()


func handle_repeats():
	if repeats > 0:
		text = "(%s) " % str(repeats) + message
		display.update_bg(text, id)
		animation_player.stop()
		animation_player.play("RESET")


func _on_mouse_entered() -> void:
	return
	scale += Vector2(0.5, 0.5)
	c_remove.wait_time = 10
	c_remove.start()

func _on_mouse_exited() -> void:
	return
	scale -= Vector2(0.5, 0.5)
	c_remove.wait_time = 4
	c_remove.start()
