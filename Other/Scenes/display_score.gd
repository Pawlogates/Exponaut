extends Node2D

@onready var entity = get_parent()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_score: Label = $label_score

var value = 0

func _ready() -> void:
	display_score()
	
	if Globals.combo_tier >= 5:
		label_score.material = Globals.material_score_value_rainbow2
		label_score.material.set_shader_parameter("strength", 0.5)

func display_score():
	label_score.text = str(value)
	animation_player.play("show_score")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
