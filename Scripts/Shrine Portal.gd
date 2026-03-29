extends Area2D

var active = false
var entered = false

@export var level_id : String = "none"
var level_filePath : String = "none"
@export var particle_quantity = 25

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
	if Globals.level_number == -1 : level_id = "DEBUG_7"
	
	level_filePath = str("res://Levels/%s.tscn" % level_id)
	
	await get_tree().create_timer(0,5, false).timeout
	level_info = SaveData.get("info_"+level_id)
	shrineGem_portal_level_number = int(level_id.split("_")[-1])
	level_displayedName = SaveData.get("info_"+level_id)[0]
	topRankScore = SaveData.get("info_"+level_id)[4]
	level_completionState = SaveData.get("saved_"+level_id)[0]
	level_score = SaveData.get("saved_"+level_id)[1]
	
	print(level_rank)
	print(level_score)
	print(level_displayedName)
	
	#level_completionState = LevelTransition.get_node("%SaveData").get("state_" + level_id)
	#level_score = LevelTransition.get_node("%SaveData").get("score_" + level_id)
	
	level_rank = SaveData.calculate_rank_level(level_id)[0]
	
	%rank.text = str(level_rank)
	print(level_rank)
	print(%rank.text)
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
	
	
	for particle in particle_quantity:
		var portal_particle = Globals.scene_portal_particle.instantiate()
		portal_particle.position = Vector2(randf_range(-5000, 5000), randf_range(-5000, 5000))
		#portal_particle.modulate.b = randf_range(0.1, 1)
		add_child(portal_particle)
	
	await get_tree().create_timer(10, false).timeout
	$AnimationPlayer.play("portal_open")
	$AnimationPlayer2.play("fadeIn_info")

func _process(delta: float) -> void:
	pass


func _on_area_entered(area):
	if not active:
		print("Entered a shrine portal but it was inactive.")
		return
	
	print("Entered an ACTIVE shrine portal")
	
	if not Globals.is_valid_entity(area) : return
	if entered : return
	
	Globals.transition_next = 0
	entered = true
	print(str(level_filePath) + " is the file path of the level this portal is taking you to.")
	
	checkpoint_activated(checkpoint_offset)
	
	Globals.change_main_scene(level_filePath)

#func _physics_process(delta: float) -> void:
	#print(level_info)

func checkpoint_activated(offset):
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
		"level_id" : level_id,
		"level_filePath" : level_filePath,
		"particle_quantity" : particle_quantity,
		
	}
	return save_dict
#SAVE END
