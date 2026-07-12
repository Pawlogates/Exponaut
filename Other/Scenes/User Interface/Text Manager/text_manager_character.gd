extends Control

@onready var character: RichTextLabel = $character
@onready var animation_player: AnimationPlayer = $character/animation_general
@onready var sfx: AudioStreamPlayer2D = $sfx
@onready var cooldown_sfx: Timer = $cooldown_sfx
@onready var bg: ColorRect = $character/bg

@export var bg_simple = false
@export var bg_simple_color = Color("BLACK")

var character_text = "-"
var letter_x = 20
var letter_y = 40

var removable = false


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


var rolled_opacity_multiplier = randf_range(0.25, 4)
var rolled_rotation = randi_range(-720, 720)
var rolled_pivot_offset = Vector2(randi_range(-1000, 1000), randi_range(-1000, 1000))


func _ready() -> void:
	await get_tree().create_timer(0.25, true).timeout
	
	if bg_simple:
		Globals.dm("Made a Text Manager Character's simple background visible.", "GREEN")
		bg.visible = true
		bg.color = bg_simple_color
		bg.size.x += 4
	else:
		Globals.dm("Deleted a Text Manager Character's simple background.", "RED")
		bg.queue_free()
	
	if is_inside_tree() : await get_tree().create_timer(0.25, true).timeout
	
	if character.text.is_valid_int():
		custom_minimum_size.x = 22
		character.theme = load("res://Other/Themes/text_score_display.tres")
	
	if character.text == "m":
		custom_minimum_size.x = 22
	
	visible = true

func _process(delta: float) -> void:
	if removable:
		character.modulate.a = move_toward(character.modulate.a, 0, delta * 2)
		character.rotation_degrees = move_toward(character.rotation_degrees, rolled_rotation, delta * 10)
		character.pivot_offset.x = move_toward(character.pivot_offset.x, rolled_pivot_offset.x, delta * 10)
		character.pivot_offset.y = move_toward(character.pivot_offset.y, rolled_pivot_offset.y, delta * 10)


func _on_cooldown_sfx_timeout() -> void:
	sfx.play()
