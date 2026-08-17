extends Area2D

@export_file("*.mp3", "*.wav") var music_file = "none"

var number_activated : int = 0 # The number of times this trigger was touched by a valid entity (the player character's hitbox).

@export var set_volume = false # The volume is handled just fine without this property being equal to "true". Setting it to "true" will disable smooth music transition.
@export var set_volume_value = 1.0

@export var single_use : bool = false


func _on_area_entered(area):
	if not Globals.is_node_valid_player(area) : return
	Globals.dm("A 'music_change' trigger has been entered by the player.", "RED")
	
	if single_use and number_activated > 0 : return
	number_activated += 1
	
	if not Globals.mode_score_attack_active:
		Globals.World.music_manager.music_change(music_file, Globals.opposite_bool(set_volume), set_volume_value)
