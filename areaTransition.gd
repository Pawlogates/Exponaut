extends Area2D

var active = false
var entered = false

@export_file("*.tscn") var target_area: String
@export var next_transition = 0


func _on_area_entered(area):
	if not active:
		return
	
	if not entered:
		if area.is_in_group("player"):
			entered = true
			var next_area:PackedScene = load(target_area)
			
			get_parent().save_game_area()
			await LevelTransition.fade_to_black()
			get_tree().change_scene_to_packed(next_area)
		else:
			print("no")
		
		Globals.next_transition = next_transition


func _on_area_exited(area):
	active = true


func _on_timer_timeout():
	active = true
