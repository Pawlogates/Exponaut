extends Node2D

var starParticleScene = preload("res://particles_special.tscn")
var starParticle2Scene = preload("res://particles_star.tscn")
var starParticle = starParticleScene.instantiate()
var starParticle2 = starParticle2Scene.instantiate()

var collected = false
var removable = false


@onready var collect_1 = %collect1
@onready var timer = %Timer
@onready var animation_player = %AnimationPlayer
@onready var animation_player_2 = %AnimationPlayer2
@onready var sprite = %AnimatedSprite2D


@export var collectibleScoreValue = 0



#OFFSCREEN START

func _ready():
	add_to_group("loadingZone0")
	
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	animation_player_2.active = false
	$Area2D.set_monitorable(false)
	
	
	#OFFSCREEN END
	
	
	
	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	
	Globals.saveState_loaded.connect(saveState_loaded)



func saveState_loaded():
	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	




#IS IN VISIBLE RANGE?

func offScreen_unload():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	animation_player_2.active = false
	$Area2D.set_monitorable(false)
	
	
	

func offScreen_load():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	sprite.play()
	sprite.visible = true
	animation_player.active = true
	animation_player_2.active = true
	
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.set_monitorable(true)
	$Area2D.set_monitoring(true)
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if removable or collected and not animation_player_2.current_animation == "score_value":
		queue_free()


var bonus_material = preload("res://Collectibles/bonus_material.tres")

func _on_collectible_entered(body):
	if body.is_in_group("player") and not collected or body.is_in_group("player_projectile") and not collected:
		collected = true
		
		%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
		
		timer.start()
		animation_player.play("remove")
		animation_player_2.play("score_value")
		
		
		if Globals.collected_in_cycle == 0:
			Globals.level_score += collectibleScoreValue
		
		else:
			Globals.level_score += collectibleScoreValue
			Globals.combo_score += collectibleScoreValue * Globals.combo_tier
		
		Globals.itemCollected.emit()
		
		
		
		add_child(starParticleScene.instantiate())
		if Globals.combo_tier > 1:
			add_child(starParticleScene.instantiate())
			%collect1.pitch_scale = 1.1
			if Globals.combo_tier > 2:
				add_child(starParticleScene.instantiate())
				%collect1.pitch_scale = 1.2
				if Globals.combo_tier > 3:
					add_child(starParticleScene.instantiate())
					%collect1.pitch_scale = 1.3
					if Globals.combo_tier > 4:
						add_child(starParticle2Scene.instantiate())
						%collect1.pitch_scale = 1.4
						bonus_material.set_shader_parameter("strength", 0.5)
						
		else:
			%collect1.pitch_scale = 1
			bonus_material.set_shader_parameter("strength", 0.0)
				
		collect_1.play()



#SAVE START

var loadingZone = "loadingZone0"

func save():
	var save_dict = {
		"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"collected" : collected,
		
	}
	return save_dict

#SAVE END



func _on_timer_timeout():
	queue_free()


func _on_animation_player_2_animation_finished(_anim_name):
	removable = true




#SAVE START

func _on_collectible_area_entered(area):
	if area.is_in_group("loadingZone_area"):
	
		remove_from_group("loadingZone0")
		remove_from_group("loadingZone1")
		remove_from_group("loadingZone2")
		remove_from_group("loadingZone3")
		remove_from_group("loadingZone4")
		remove_from_group("loadingZone5")
		
		loadingZone = area.loadingZone_ID
		add_to_group(loadingZone)
		
		#print("this object is in: ", loadingZone)
	
	#SAVE END

