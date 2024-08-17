extends Area2D

var active = false
var entered = false

@export_file("*.tscn") var target_area: String
@export var particle_amount = 25
@export var level_ID = "none"
@export var level_number = 0

@export var level_score = 0
@export var level_completionState = 0
@export var level_rank = "D"
@export var level_rank_value = 1

@export var level_displayedName = "level name"

func _ready():
	%rank.text = str(level_rank)
	%score.text = str(level_score)
	%name.text = str(level_displayedName)
	
	if level_completionState == 0:
		pass
	elif level_completionState == 1:
		%icon_levelFinished.visible = true
		%unbeaten_label.visible = false
	elif level_completionState == 2:
		%icon_levelAllBigApplesCollected.visible = true
		%unbeaten_label.visible = false
	elif level_completionState == 3:
		%icon_levelAllCollectiblesCollected.visible = true
		%unbeaten_label.visible = false
	
	
	for particles in particle_amount:
		var portal_particle = preload("res://Particles/shrine_portal_particle.tscn").instantiate()
		portal_particle.position = Vector2(randf_range(-5000, 5000), randf_range(-5000, 5000))
		#portal_particle.modulate.b = randf_range(0.1, 1)
		add_child(portal_particle)
	
	await get_tree().create_timer(10, false).timeout
	$AnimationPlayer.play("portal_open")
	$AnimationPlayer2.play("fadeIn_info")


func _on_area_entered(area):
	if not active:
		print("Entered a shrine portal but it was inactive.")
		return
	
	print("Entered an ACTIVE shrine portal")
	
	if not entered:
		if area.is_in_group("player"):
			Globals.weaponType = "none"
			Globals.next_transition = 0
			entered = true
			print(str(target_area) + " is the file path of the level this portal is taking you to.")
			var next_area:PackedScene = load(target_area)
			
			get_parent().save_game_area()
			await LevelTransition.fade_to_black()
			get_tree().change_scene_to_packed(next_area)


func _on_timer_timeout():
	active = true
