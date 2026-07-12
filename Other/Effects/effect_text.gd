extends Node2D

@onready var animation_all: AnimationPlayer = $label_message/animation_all
@onready var label_message: Label = $label_message


var text_message : String = "none"

var list_effect_name : Array = ["general/rotate_away_up_right", "general/rotate_away_up_right_scale_up", "general/rotate_around_y_fade_out", "general/reflect_straight", "general/fade_out_up", "general/move_down_back_in_fade_out"]

var effect_name_number : int = 1
var effect_speed : float = 1.0
var effect_reverse : bool = false


func _ready() -> void:
	label_message.text = str(text_message)
	label_message.visible = true
	
	#effect_name_number = randi_range(0, 1)
	#animation_all.play(list_effect_name[effect_name_number])
	
	animation_all.speed_scale = effect_speed
	animation_all.play("general/move_down_back_in_fade_out")


func _on_animation_all_animation_finished(anim_name: StringName) -> void:
	queue_free()
