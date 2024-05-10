extends Area2D

@export var delay = 0
@export var video_file = VideoStreamTheora

var active = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		if active:
			return
		
		active = true
		if delay != 0:
			await get_tree().create_timer(delay, false).timeout
		
		$VideoStreamPlayer.play()
		$AnimationPlayer.play("fade_in")
		

func _ready():
	$AnimationPlayer.play("RESET")
	$VideoStreamPlayer.stream = video_file
