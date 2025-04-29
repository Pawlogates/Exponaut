extends Node2D

@export var current = true

var changing_color = false

@export var main_r = 1.0
@export var main_g = 1.0
@export var main_b = 1.0
@export var main_a = 1.0

@export var a_r = 1.0
@export var a_g = 1.0
@export var a_b = 1.0
@export var a_a = 1.0

@export var b_r = 1.0
@export var b_g = 1.0
@export var b_b = 1.0
@export var b_a = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/bg_main.visible = true
	$CanvasLayer/bg_b.visible = true
	$CanvasLayer/bg_a.visible = true
	
	$CanvasLayer/bg_main/bg_main/TextureRect.modulate.r = main_r
	$CanvasLayer/bg_main/bg_main/TextureRect.modulate.g = main_g
	$CanvasLayer/bg_main/bg_main/TextureRect.modulate.b = main_b
	$CanvasLayer/bg_main/bg_main/TextureRect.modulate.a = main_a
	
	$CanvasLayer/bg_a/bg_a/TextureRect.modulate.r = a_r
	$CanvasLayer/bg_a/bg_a/TextureRect.modulate.g = a_g
	$CanvasLayer/bg_a/bg_a/TextureRect.modulate.b = a_b
	$CanvasLayer/bg_a/bg_a/TextureRect.modulate.a = a_a
	
	$CanvasLayer/bg_b/bg_b/TextureRect.modulate.r = b_r
	$CanvasLayer/bg_b/bg_b/TextureRect.modulate.g = b_g
	$CanvasLayer/bg_b/bg_b/TextureRect.modulate.b = b_b
	$CanvasLayer/bg_b/bg_b/TextureRect.modulate.a = b_a

@onready var bg_transition = %bg_transition
var transitioning = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if changing_color and %bg_transition.current_animation == "" and %bg_a_transition.current_animation == "" and %bg_b_transition.current_animation == "":
		$CanvasLayer/bg_main/bg_main/TextureRect.modulate.r = main_r
		$CanvasLayer/bg_main/bg_main/TextureRect.modulate.g = main_g
		$CanvasLayer/bg_main/bg_main/TextureRect.modulate.b = main_b
		$CanvasLayer/bg_main/bg_main/TextureRect.modulate.a = main_a
		
		$CanvasLayer/bg_a/bg_a/TextureRect.modulate.r = a_r
		$CanvasLayer/bg_a/bg_a/TextureRect.modulate.g = a_g
		$CanvasLayer/bg_a/bg_a/TextureRect.modulate.b = a_b
		$CanvasLayer/bg_a/bg_a/TextureRect.modulate.a = a_a
		
		$CanvasLayer/bg_b/bg_b/TextureRect.modulate.r = b_r
		$CanvasLayer/bg_b/bg_b/TextureRect.modulate.g = b_g
		$CanvasLayer/bg_b/bg_b/TextureRect.modulate.b = b_b
		$CanvasLayer/bg_b/bg_b/TextureRect.modulate.a = b_a
	
	if not current:
		return
	
	if not transitioning and not bg_transition.current_animation == "bg_show" and not bg_transition.current_animation == "bg_hide":
		transitioning = true
		Globals.bgTransition_finished.emit()
		%bg_transition_buffer_delay.start()


func _on_bg_transition_buffer_delay_timeout():
	if not current:
		return
	
	transitioning = false
