extends Node2D

var starParticleScene = preload("res://particles_star.tscn")
var starParticle = starParticleScene.instantiate()

var collected = false
var removable = false

@onready var collect_1 = %collect1
@onready var timer = %Timer
@onready var animation_player = %AnimationPlayer
@onready var animation_player_2 = %AnimationPlayer2

@export var collectibleScoreValue = 10000

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	
	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	
	Globals.saveState_loaded.connect(saveState_loaded)


func saveState_loaded():
	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	



#IS IN VISIBLE RANGE?

func offScreen_unload():
	set_physics_process(false)
	

func offScreen_load():
	set_physics_process(true)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if removable or collected and not animation_player_2.current_animation == "score_value":
		queue_free()


func _on_collectible_entered(body):
	if body.is_in_group("player") and not collected or body.is_in_group("player_projectile") and not collected:
		collected = true
		
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		
		
		%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
		
		timer.start()
		animation_player.play("remove")
		animation_player_2.play("score_value")
		collect_1.play()
		
		if Globals.collected_in_cycle == 0:
			Globals.level_score += collectibleScoreValue
		
		else:
			Globals.level_score += collectibleScoreValue
			Globals.combo_score += collectibleScoreValue * Globals.combo_tier
		
		Globals.apple_collected.emit()


func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"collected" : collected,
		
	}
	return save_dict



func _on_timer_timeout():
	queue_free()


func _on_animation_player_2_animation_finished(anim_name):
	removable = true
