extends Area2D

var active = false # Used to prevent transitioning right after being loaded into a level.
var entered = false # Each transition can only be entered once before changing the loaded level.
var enabled = true # Whether or not the transition should be one-way.

@export_file("*.tscn") var target_level_filepath : String = "res://Levels/debug_level.tscn"
@export var transition_next = -1
@export var transition_pos_offset = Vector2(0, 0)
@export var valid_target : bool = true


func _ready() -> void:
	if valid_target : add_to_group("level_transition" + str(transition_next))


func _on_area_entered(area):
	if not Globals.is_valid_entity(area) : return
	if not active or entered : return
	entered = true
	
	var target_level : PackedScene = load(target_level_filepath)
	
	Globals.transition_triggered = true
	SaveData.save_playerData(false)
	
	Overlay.animation("black_fade_in")
	get_tree().change_scene_to_packed(target_level)
	
	Globals.dm("Player has entered a level transition leading to: " + str(target_level_filepath))
	
	Globals.transition_next = transition_next


func _on_area_exited(_area):
	active = true

func _on_timer_timeout():
	active = true
