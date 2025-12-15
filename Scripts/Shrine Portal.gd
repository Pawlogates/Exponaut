extends Area2D

var active = false
var entered = false

@export var level_ID = "none"
@export_file("*.tscn") var level_filePath: String
@export var particle_amount = 25

var saved_progress : Node
var level_info : Array

var shrineGem_portal_level_number = -1
var level_displayedName = "unassigned"
var topRankScore = -1
var level_completionState = -1
var level_score = -1

var level_rank = "D"
var level_rank_value = 1

@export var checkpoint_offset = Vector2(320, -64)

func _ready():
	await get_tree().create_timer(0,5, false).timeout
	
	saved_progress = SaveData
	level_info = saved_progress.get("info_"+str(level_ID))
	
	shrineGem_portal_level_number = int(level_ID.split("_")[-1])
	level_displayedName = level_info[0]
	topRankScore = level_info[4]
	level_completionState = saved_progress.get("state_"+str(level_ID))
	level_score = saved_progress.get("score_"+str(level_ID))
	

	print(level_rank)
	print(level_score)
	print(level_displayedName)
	
	#level_completionState = LevelTransition.get_node("%saved_progress").get("state_" + level_ID)
	#level_score = LevelTransition.get_node("%saved_progress").get("score_" + level_ID)
	
	set_level_rank_values()
	
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
		var portal_particle = Globals.portal_particle.instantiate()
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
			print(str(level_filePath) + " is the file path of the level this portal is taking you to.")
			var next_area:PackedScene = load(level_filePath)
			
			checkpoint_activated(checkpoint_offset)
			Overlay.animation("fade_black", false, 1.0, true)
			get_tree().change_scene_to_packed(next_area)

#func _physics_process(delta: float) -> void:
	#print(level_info)

func checkpoint_activated(offset):
	$/root/World.last_checkpoint_pos = position + offset
	$/root/World.save_game()
	$/root/World.save_game_area()
	
	if Globals.World.level_type == "overworld":
		SaveData.save_playerData(true)


func _on_timer_timeout():
	active = true


#SAVE
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"level_ID" : level_ID,
		"level_filePath" : level_filePath,
		"particle_amount" : particle_amount,
		
	}
	return save_dict
#SAVE END


func set_level_rank_values():
	var rating_top = topRankScore
	var rating_6 = rating_top * 0.8
	var rating_5 = rating_top * 0.6
	var rating_4 = rating_top * 0.4
	var rating_3 = rating_top * 0.2
	var rating_2 = rating_top * 0.1
	var rating_1 = 0
	
	if level_score >= rating_top:
		level_rank = "S+"
		level_rank_value = 7
	elif level_score >= rating_6:
		level_rank = "S"
		level_rank_value = 6
	elif level_score >= rating_5:
		level_rank = "A"
		level_rank_value = 5
	elif level_score >= rating_4:
		level_rank = "B"
		level_rank_value = 4
	elif level_score >= rating_3:
		level_rank = "C"
		level_rank_value = 3
	elif level_score >= rating_2:
		level_rank = "D"
		level_rank_value = 2
	elif level_score >= rating_1:
		level_rank = "none"
		level_rank_value = 1
