extends Node2D

var type = "gear"

@onready var animation_player: AnimationPlayer = $animation_gear

@export var anim_name : String = "rotate"
@export var anim_speed : float = 1.0
@export var anim_reverse : bool = false

@export var randomize_anim_name : bool = false
@export var randomize_anim_speed : bool = false
@export var randomize_anim_reverse : bool = false

var list_anim_name = ["rotate", "rotate_back", "rotate_back_in", "rotate_back_in", "rotate_forwardAndBack"]


func _ready() -> void:
	await get_tree().create_timer(0.1, true).timeout
	if not animation_player.is_playing() : play_anim(false)


func play_anim(randomize_everything):
	if randomize_everything:
		randomize_anim_name = true
		randomize_anim_reverse = true
		randomize_anim_speed = true
		if Globals.random_bool(10, 5):
			modulate = Color(0, 0, 0, 1)
	
	await get_tree().create_timer(0.1, true).timeout
	randomize_anim()
	animation_player.speed_scale = anim_speed
	if anim_reverse:
		animation_player.play_backwards(anim_name)
	else:
		animation_player.play(anim_name)

func randomize_anim():
	if randomize_anim_name : anim_name = list_anim_name.pick_random()
	if randomize_anim_speed : anim_speed = randf_range(0.25, 2)
	if randomize_anim_reverse : anim_reverse = Globals.random_bool(1, 1)
