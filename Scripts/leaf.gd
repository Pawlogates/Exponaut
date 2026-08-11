extends AnimatedSprite2D

func _ready() -> void:
	if Globals.get_random_bool(75) : $AnimationPlayer.play("falling")
	else :  $AnimationPlayer.play("falling" + str(randi_range(2, 6)))

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
