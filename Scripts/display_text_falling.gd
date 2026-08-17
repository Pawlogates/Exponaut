extends CharacterBody2D

@onready var container_main: Control = $container_main
@onready var label_text: Label = $container_main/label_text
@onready var outline: Control = $container_main/label_text/outline
@onready var animation_all: AnimationPlayer = $container_main/label_text/animation_all


@export var text_message : String = "none"
@export var gravity_copy_combo_streak : bool = false
@export var velocity_copy_combo_streak : bool = false
@export var gravity : float = 1000.0
@export var animation_name : String = "none"
@export var randomize_velocity : bool = false
@export var font_basic : bool = false

var rotation_speed : float = 0.0

var list_animation_name_all : Array = []


func _ready() -> void:
	if font_basic:
		label_text.theme = load("res://Other/Themes/basic.tres")
		label_text.material = null
		outline.queue_free()
	
	for animation_library in animation_all.get_animation_library_list():
		for animation_name in animation_all.get_animation_library(animation_library).get_animation_list():
			list_animation_name_all.append(animation_library + "/" + animation_name)
	
	label_text.text = str(text_message)
	$container_main/label_text/outline/outline.text = str(text_message)
	$container_main/label_text/outline/outline2.text = str(text_message)
	$container_main/label_text/outline/outline3.text = str(text_message)
	$container_main/label_text/outline/outline4.text = str(text_message)
	$container_main/label_text/outline/outline5.text = str(text_message)
	$container_main/label_text/outline/outline6.text = str(text_message)
	$container_main/label_text/outline/outline7.text = str(text_message)
	$container_main/label_text/outline/outline8.text = str(text_message)
	
	if velocity_copy_combo_streak:
		velocity = Vector2(randi_range(-150, 150) * Globals.combo_streak, randi_range(-250, -750) * clamp(Globals.combo_streak, 0.5, 4) / 4)
	elif randomize_velocity:
		velocity = Vector2(randi_range(-1000, 1000), randi_range(-750, 250))
	
	#label_text.material.set_shader_parameter("strength", 0.25 + 0.05 * Globals.combo_streak)
	
	if animation_name != "none" : animation_all.play(animation_name)
	else : animation_all.play("color/scale_and_opacity_up")

func _physics_process(delta: float) -> void:
	rotation_speed *= 0.99
	
	if gravity: # If the value is not equal to 0.
		velocity.y += gravity * delta
	
	if velocity.x > 0:
		label_text.rotation_degrees += rotation_speed
	else:
		label_text.rotation_degrees -= rotation_speed
	
	move_and_slide()
	
	animation_all.speed_scale -= delta * 20
	if animation_all.speed_scale < 0.5 : animation_all.speed_scale = 0.5

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "opacity_fade_in":
		await get_tree().create_timer(0.5, false).timeout
		animation_all.play("opacity_fade_out")


func _on_animation_all_animation_finished(anim_name: StringName) -> void:
	if anim_name == "general/fade_out_up":
		queue_free()
	
	if anim_name == "color/scale_and_opacity_up":
		await get_tree().create_timer(0.5, false).timeout
		animation_all.play("general/fade_out_up")
