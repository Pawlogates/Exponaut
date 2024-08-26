extends CharacterBody2D

var score = 0
var rotation_speed = 0

func _ready() -> void:
	$main_label.text = str(score)
	$main_label/Label.text = str(score)
	$main_label/Label2.text = str(score)
	$main_label/Label3.text = str(score)
	$main_label/Label4.text = str(score)
	$main_label/Label5.text = str(score)
	$main_label/Label6.text = str(score)
	$main_label/Label7.text = str(score)
	$main_label/Label8.text = str(score)
	velocity = Vector2(randi_range(-250, 250), randi_range(-600, -200))
	rotation_speed = randf_range(0, 1)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta / 3
		velocity.x = move_toward(velocity.x, 0, delta * 10)
	
	if velocity.x > 0:
		$main_label.rotation_degrees += rotation_speed / 2
	else:
		$main_label.rotation_degrees += -rotation_speed / 2
	
	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "opacity_fade_in":
		await get_tree().create_timer(0.5, false).timeout
		$AnimationPlayer.play("opacity_fade_out")
