extends Node2D

var collected = false
var removable = false

@onready var world = $/root/World
@onready var player = $/root/World.player

@onready var sfx_collect1 = %collect1
@onready var timer = %Timer
@onready var animation_player = %AnimationPlayer
@onready var animation_player2 = %AnimationPlayer2
@onready var sprite = %AnimatedSprite2D

@export var collectibleScoreValue = 0

@export var type : String

#OFFSCREEN START
func _ready():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	animation_player2.active = false
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
	animation_player2.active = false
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
	animation_player2.active = true
	
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.set_monitorable(true)
	$Area2D.set_monitoring(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if removable or collected and not animation_player2.current_animation == "score_value":
		queue_free()


var bonus_material = preload("res://Other/Materials/bonus_material.tres")

func _on_collectible_entered(body):
	if not body.is_in_group("player") and not body.is_in_group("player_projectile"):
		return
	
	collected = true
	Globals.itemCollected.emit()
	
	%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
	
	timer.start()
	animation_player.play("remove")
	animation_player2.play("score_value")
	
	print(str(Globals.collected_in_cycle) + " is the current collectible streak.")
	
	Globals.level_score += collectibleScoreValue
	
	if Globals.collected_in_cycle > 1:
		Globals.combo_score += collectibleScoreValue * Globals.combo_tier
	
	add_child(Globals.scene_particle_star.instantiate())
	if Globals.combo_tier > 1:
		add_child(Globals.scene_particle_star.instantiate())
		%collect1.pitch_scale = 1.1
		if Globals.combo_tier > 2:
			add_child(Globals.scene_particle_star.instantiate())
			%collect1.pitch_scale = 1.2
			if Globals.combo_tier > 3:
				add_child(Globals.scene_particle_star.instantiate())
				%collect1.pitch_scale = 1.3
				if Globals.combo_tier > 4:
					add_child(Globals.scene_particle_star.instantiate())
					%collect1.pitch_scale = 1.4
					bonus_material.set_shader_parameter("strength", 0.5)
	
	else:
		%collect1.pitch_scale = 1
		bonus_material.set_shader_parameter("strength", 0.0)
	
	sfx_collect1.play()
	
	%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
	%collectedDisplay.position += Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	animation_player.play("remove")
	animation_player2.play("score_value")
	
	#Handle visual effect of collecting the 20th collectible in a streak (resulting in a x5 multiplier).
	if Globals.collected_in_cycle == 20:
		var max_multiplier_particle_amount = 50
		while max_multiplier_particle_amount > 0:
			max_multiplier_particle_amount -= 1
			call_deferred("spawn_particle_score", 2)
	
	# Handle double score particles (while a temporary powerup is active).
	if get_node_or_null("$/root/World/player"):
		if not player.double_score:
			return
		
		var effective_score = collectibleScoreValue * Globals.combo_tier
		var particle_amount : int
		
		if collectibleScoreValue * Globals.combo_tier < 25:
			particle_amount = effective_score
		else:
			particle_amount = 25
		
		while particle_amount > 0:
			particle_amount -= 1
			call_deferred("spawn_particle_score", 1)

func spawn_particle_score(scale_multiplier : int):
	var particle = Globals.scene_particle_star.instantiate()
	particle.position = position
	particle.scale = Vector2(scale_multiplier, scale_multiplier)
	world.add_child(particle)


#SAVE
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"collected" : collected,
		
	}
	return save_dict
#SAVE END


func _on_timer_timeout():
	queue_free()


func _on_animation_player_2_animation_finished(_anim_name):
	removable = true
