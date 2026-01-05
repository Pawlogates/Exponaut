extends Label

@onready var c_delay: Timer = $cooldown_delay
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var display = $/root/Overlay/debug_display_messages
@onready var text_container = $/root/Overlay/debug_display_messages/text_container

var id : int = 0
var cooldown_delay = 4.0

func _ready() -> void:
	c_delay.wait_time = cooldown_delay
	c_delay.start()

func _on_cooldown_delay_timeout() -> void:
	animation_player.play("fade_out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		display.active_messages -= 1
		display.update_bg("", 0)
		queue_free()
