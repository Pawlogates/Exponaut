extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var anim_speed : float = 1.0

func _ready() -> void:
	animation_player.speed_scale = anim_speed
	animation_player.play("move_right")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
