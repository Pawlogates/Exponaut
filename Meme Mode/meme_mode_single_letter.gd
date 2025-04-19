extends Label

var anim = 0
var anim_speed = 1.0
var random_anim = false

var delay = 1.0

var outline = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = delay
	$Timer.start()
	$AnimationPlayer.speed_scale = anim_speed
	
	if not outline:
		add_theme_constant_override("outline_size", 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if random_anim:
		var rolled_anim = randi_range(0, 2)
		if rolled_anim == 0:
			$AnimationPlayer.play("moveUp")
		elif rolled_anim == 1:
			$AnimationPlayer.play("moveUp_2")
		elif rolled_anim == 2:
			$AnimationPlayer.play("moveUp_3")
	else:
		if anim == 0:
			$AnimationPlayer.play("moveUp")
		elif anim == 1:
			$AnimationPlayer.play("moveUp_2")
		elif anim == 2:
			$AnimationPlayer.play("moveUp_3")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "moveUp":
		queue_free()
