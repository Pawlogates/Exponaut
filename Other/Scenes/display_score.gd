extends Node2D

@onready var entity = get_parent()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_score: Label = $label_score

var score_value = 0

func _ready() -> void:
	entity.display_score.connect(display_score)

func display_score():
	label_score.text = str(score_value)
	animation_player.play("show_score")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
