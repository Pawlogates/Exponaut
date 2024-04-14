extends Area2D

var active = false
var entered = false

@export_file("*.tscn") var target_area: String
@export var particle_amount = 25
@export var level_ID = 0


func _ready():
	for particles in particle_amount:
		var portal_particle = preload("res://shrine_portal_particle.tscn").instantiate()
		portal_particle.position = Vector2(randf_range(-5000, 5000), randf_range(-5000, 5000))
		#portal_particle.modulate.b = randf_range(0.1, 1)
		add_child(portal_particle)
	
	await get_tree().create_timer(10, false).timeout
	$AnimationPlayer.play("portal_open")
	



func _on_area_entered(area):
	print("entered")
	if not active:
		return
	
	if not entered:
		if area.is_in_group("player"):
			Globals.weaponType = "none"
			Globals.next_transition = 0
			entered = true
			print(target_area)
			var next_area:PackedScene = load(target_area)
			
			get_parent().save_game_area()
			await LevelTransition.fade_to_black()
			get_tree().change_scene_to_packed(next_area)
		


#func _on_area_exited(_area):
	#active = true


func _on_timer_timeout():
	active = true
