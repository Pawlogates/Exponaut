extends Node2D

@onready var text_manager: Control = $text_manager
@onready var animation_all: AnimationPlayer = $text_manager/animation_all


var message_text : String = "none"
var add_position : Vector2 = Vector2(0, 0)
var add_scale : Vector2 = Vector2(0, 0)
var randomize_effects : bool = false


func _ready() -> void:
	position += add_position
	scale += add_scale
	
	if randomize_effects : text_manager.text_font_size = randi_range(16, 24)
	
	if message_text != "none":
		if randomize_effects and Globals.random_bool(1, 1):
			text_manager.text_full = "[anim_rotate_away_up_right]" + message_text
			text_manager.character_anim_backwards = true
			text_manager.character_anim_speed_scale = randf_range(1, 2.0)
			text_manager.text_animation_sync = Globals.random_bool(1, 1)
		else:
			text_manager.text_full = message_text
		
		text_manager.create_message()
	
	
	if randomize_effects : animation_all.speed_scale = randf_range(1, 2.0)
	animation_all.play("general/appear_move_up_slow")
	
	await get_tree().create_timer(10, true).timeout
	
	queue_free()
