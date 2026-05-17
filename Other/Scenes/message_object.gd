extends Node2D

@onready var text_manager: Control = $text_manager
@onready var animation_all: AnimationPlayer = $animation_all


var message_text : String = "none"
var add_position : Vector2 = Vector2(0, 0)


func _ready() -> void:
	text_manager.position += add_position
	text_manager.text_font_size = randi_range(16, 24)
	
	if message_text != "none":
		text_manager.text_full = message_text
		text_manager.create_message()
	
	animation_all.play("general/appear_move_up_slow")
	
	await get_tree().create_timer(10, true).timeout
	
	queue_free()
