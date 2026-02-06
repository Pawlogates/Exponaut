extends CharacterBody2D

@onready var main_label: Label = $main_label

@export var value : int = 0
@export var gravity_based_on_combo_streak : bool = true
@export var velocity_based_on_combo_streak : bool = true
@export var ignore_gravity : bool = false
@export var slow : bool = false

var rotation_speed : float = 0.0

var add_scale : Vector2 = Vector2(1.0, 1.0)


func _ready() -> void:
	$main_label.text = str(value)
	$main_label/Label.text = str(value)
	$main_label/Label2.text = str(value)
	$main_label/Label3.text = str(value)
	$main_label/Label4.text = str(value)
	$main_label/Label5.text = str(value)
	$main_label/Label6.text = str(value)
	$main_label/Label7.text = str(value)
	$main_label/Label8.text = str(value)
	
	# If velocity was not set at the time of instantiating this scene.
	if not slow:
		if velocity_based_on_combo_streak:
			velocity = Vector2(randi_range(-150, 150) * Globals.combo_streak, randi_range(-250, -750) * clamp(Globals.combo_streak, 0.5, 4) / 4)
		else:
			velocity = Vector2(randi_range(-1000, 1000), randi_range(-750, 250))
	
	else : velocity = Vector2(randi_range(-500, 500), randi_range(-500, -125))
	
	scale *= add_scale
	rotation_speed = randf_range(0, 4)
	
	main_label.material.set_shader_parameter("strength", 0.25 + 0.05 * Globals.combo_streak)

func _physics_process(delta: float) -> void:
	if not ignore_gravity:
		
		velocity.x = move_toward(velocity.x, 0, delta * 10)
		
		if gravity_based_on_combo_streak:
			
			if not slow:
				velocity.y += delta * 100 * Globals.combo_streak
			else:
				velocity.y += delta * 100 * Globals.combo_streak
		
		else:
			
			if not slow:
				
				velocity.y += delta * 250
				
			else:
				velocity.y += delta * 250 
	
	
	if velocity.x > 0:
		$main_label.rotation_degrees += rotation_speed
	else:
		$main_label.rotation_degrees += -rotation_speed
	
	move_and_slide()
	
	$AnimationPlayer.speed_scale -= delta * 20
	if $AnimationPlayer.speed_scale < 0.5 : $AnimationPlayer.speed_scale = 0.5

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "opacity_fade_in":
		await get_tree().create_timer(0.5, false).timeout
		$AnimationPlayer.play("opacity_fade_out")
