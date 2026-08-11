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
	if bg_simple:
		Globals.dm("Made a Text Manager Character's simple background visible.", "GREEN")
		bg.visible = true
		bg.color = bg_simple_color
		bg.size.x *= 2
	else:
		Globals.dm("Deleted a Text Manager Character's simple background.", "RED")
		bg.queue_free()
	
	await get_tree().create_timer(0.05, true).timeout
	
	visible = true
	
	await get_tree().create_timer(0.5, true).timeout
	
	if character.text.is_valid_int():
		custom_minimum_size.x = 20
		character.theme = load("res://Other/Themes/text_score_display.tres")
	
	if character.text == "m" or character.text == "C":
		custom_minimum_size.x = 28
	elif character.text == "w":
		custom_minimum_size.x = 26
	elif character.text == "i" or character.text == "I" or character.text == "." or character.text == "," or character.text == ":" or character.text == "-":
		custom_minimum_size.x = 14
	elif character.text == "M" or character.text == "O" or character.text == "W":
		custom_minimum_size.x = 34
	elif character.text == "H" or character.text == "Q" or character.text == "S" or character.text == "L":
		custom_minimum_size.x = 24
	elif character.text == "N" or character.text == "R" or character.text == "G" or character.text == "E":
		custom_minimum_size.x = 28
	elif character.text == "X" or character.text == "G":
		custom_minimum_size.x = 26
	elif character.text == "D" or character.text == "U" or character.text == "A":
		custom_minimum_size.x = 28
	elif character.text == "T" or character.text == "F" or character.text == "P" or character.text == "K" or character.text == "Y" or character.text == "V":
		custom_minimum_size.x = 26
	
	if not character["theme_override_font_sizes/normal_font_size"] == 46 and not character.text.is_valid_int():
		if custom_minimum_size.x >= 16:
			custom_minimum_size.x = 16
		if character.text in ["i", "t", "l", "r"] : custom_minimum_size.x = 10
		elif character.text in ["d", "c", "k"] : custom_minimum_size.x = 12
		elif character.text in ["o"] : custom_minimum_size.x = 16

func _process(delta: float) -> void:
	if removable:
		character.modulate.a = move_toward(character.modulate.a, 0, delta * 2)
		character.rotation_degrees = move_toward(character.rotation_degrees, rolled_rotation, delta * 10)
		character.pivot_offset.x = move_toward(character.pivot_offset.x, rolled_pivot_offset.x, delta * 10)
		character.pivot_offset.y = move_toward(character.pivot_offset.y, rolled_pivot_offset.y, delta * 10)


func _on_cooldown_sfx_timeout() -> void:
	sfx.play()
