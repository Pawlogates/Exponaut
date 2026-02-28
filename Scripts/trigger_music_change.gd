extends Area2D

@export_file("*.mp3", "*.wav") var music_file = "res://Assets/Sounds/ambience/ambience_loop1.mp3"

@export var set_volume = false # The volume is handled just fine without this property being equal to "true". Setting it to "true" will disable smooth music transition.
@export var set_volume_value = 1.0


func _on_area_entered(area):
	if not area.is_in_group("Player") : return
	Globals.dm("A 'music_change' trigger has been entered by the player.", "RED")
	
	if not Globals.mode_scoreAttack:
		Globals.World.music_manager.music_change(music_file, Globals.opposite_bool(set_volume), set_volume_value)
