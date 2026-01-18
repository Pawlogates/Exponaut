extends Control

@onready var character: RichTextLabel = $character
@onready var animation_player: AnimationPlayer = $character/animation_general
@onready var sfx: AudioStreamPlayer2D = $sfx
@onready var cooldown_sfx: Timer = $cooldown_sfx

var character_text = "-"
var letter_x = 20
var letter_y = 40


# Code-based letter animation properties:
# Note: The "direction" type of properties will cause them to use "move_toward()" for changing their values, instead of "lerp()".

var anim_pos_start = Vector2(0, 0)
var anim_pos_target = Vector2(0, 0)
var anim_pos_speed = 1.0
var anim_pos_direction = Vector2(0, 0) # Moves in this direction.

var anim_opacity_start = 1.0
var anim_opacity_target = 1.0
var anim_opacity_speed = 0.01
var anim_opacity_direction = 0

var anim_scale_start = 1.0
var anim_scale_target = 1.0
var anim_scale_speed = 0.01
var anim_scale_direction = 0

var anim_rotation_start = 0.0
var anim_rotation_target = 0.0
var anim_rotation_speed = 10
var anim_rotation_direction = 0


func _on_cooldown_sfx_timeout() -> void:
	sfx.play()
