extends Area2D

var active = false # Used to prevent transitioning right after being loaded into a level.
var entered = false # Each transition can only be entered once before changing the loaded level.
var enabled = true # Whether or not the transition should be one-way.

@export_file("*.tscn") var target_area: String
@export var next_transition = 0
@export var spawn_position = Vector2(0, 0)


func _on_area_entered(area):
	if not active:
		return
	
	if not entered:
		if area.is_in_group("player"):
			Globals.transitioned = true
			SaveData.saved_weapon = area.get_parent().weaponType
			entered = true
			var next_area:PackedScene = load(target_area)
			
			SaveData.save_playerData(false)
			
			get_parent().save_game_area()
			Overlay.animation("fade_black", 0, 1.0, true)
			get_tree().change_scene_to_packed(next_area)
		else:
			print("A non-player entity has entered a level transition leading to: " + str(target_area))
		
		Globals.next_transition = next_transition


func _on_area_exited(_area):
	active = true


func _on_timer_timeout():
	active = true
