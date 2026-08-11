extends CharacterBody2D

@onready var cooldown_penalty_multiplier: Timer = $cooldown_penalty_multiplier
@onready var cooldown_reduce_score: Timer = $cooldown_reduce_score
@onready var score_counter: TextureRect = $score_counter
@onready var label_score: Label = $label_score
@onready var label_penalty_multiplier: Label = $label_penalty_multiplier

@onready var penalty_multiplier_bg: TextureRect = $label_penalty_multiplier/bg

var target_pos : Vector2 = Vector2(0, 0)

#var velocityMultiplier = 0.25
#var SPEED = 600

@onready var score : int = 1000
@onready var penalty_multiplier : float = 1.0
@onready var penalty_total : int = 0

var active : bool = false
var game_over = false

var penalty_base : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	for node in get_tree().get_nodes_in_group("mode_score_attack"):
		if node != self:
			node.queue_free()
	
	global_position = Globals.player_position
	
	Globals.entity_collected.connect(collected_item_reset_penaltyMultiplier)
	Globals.entity_hit.connect(enemyHit_reset_penaltyMultiplier)
	
	if Globals.level_collectibles in [0, -1]:
		await get_tree().create_timer(2.5, true).timeout
	else:
		await get_tree().create_timer(0.5, true).timeout
	
	active = true
	visible = true


func _process(delta):
	if not active : return
	
	if game_over:
		target_pos = Globals.player_position + Vector2(680, 320)
		position = lerp(position, target_pos, delta)
		scale = scale.lerp(Vector2(4, 4), delta)
	
	else:
		target_pos = Globals.player_position
		position = lerp(position, target_pos, delta)
	
	#if global_position.distance_to(target) > 150:
		#if global_position.distance_to(target) > 800:
			#velocityMultiplier = 1
		#elif global_position.distance_to(target) > 600:
			#velocityMultiplier = 0.8
		#elif global_position.distance_to(target) > 400:
			#velocityMultiplier = 0.6
		#elif global_position.distance_to(target) > 300:
			#velocityMultiplier = 0.4
		#elif global_position.distance_to(target) > 200:
			#velocityMultiplier = 0.2
	#else:
			#velocityMultiplier = 0.1
	
	#velocity = global_position.direction_to(target) * SPEED * velocityMultiplier
	
	label_score.text = str(score)
	if score == 0 : label_score.modulate = Color.RED
	label_penalty_multiplier.text = str("x", int(penalty_multiplier))
	if penalty_multiplier == 1 : label_penalty_multiplier.modulate = Color.GREEN
	else : label_penalty_multiplier.modulate = Color.YELLOW
	
	if penalty_multiplier > 64 : label_penalty_multiplier.modulate = Color.ORANGE
	if game_over : label_penalty_multiplier.modulate = Color.RED
	
	if Globals.combo_tier == 5:
		
		if penalty_multiplier != 1:
			Globals.spawn_scenes(self, Globals.scene_particle_special2_multiple)
			Globals.spawn_scenes(self, Globals.scene_particle_star, 4)
			Globals.spawn_scenes(self, Globals.scene_particle_special_multiple)
		
		penalty_multiplier = 1
		max_combo_tier = true
	
	else:
		max_combo_tier = false
	
	if score <= 0:
		if game_over : return
		game_over = true
		await get_tree().create_timer(0.1, false).timeout
		Globals.World.level_failed()
	
	if not Globals.mode_score_attack_active:
		Globals.World.mode_score_attack_active = false
		Globals.spawn_scenes(Globals.World, Globals.scene_particle_special, 24, position)
		Globals.spawn_scenes(Globals.World, Globals.scene_effect_dust, 1, position, 4, Color(0, 0, 0, 0), Vector2(0, 0), 10)
		queue_free()


var max_combo_tier = false

func _on_score_attack_penalty_multiplier_timeout():
	if game_over : return
	
	if not max_combo_tier:
		penalty_multiplier *= 2
		if penalty_multiplier > 64:
			label_penalty_multiplier.position.x -= 16
	
	label_penalty_multiplier["theme_override_font_sizes/font_size"] = 24 + (penalty_multiplier * 0.15)
	Globals.spawn_scenes(label_penalty_multiplier, Globals.scene_particle_special_multiple, 1, Vector2(128, 160), 4, Color.WHITE, Vector2(-2, 1))
	
	restart_cooldown_penalty_multiplier()

func restart_cooldown_penalty_multiplier():
	if penalty_multiplier == 1:
		cooldown_penalty_multiplier.wait_time = 2.0
	elif penalty_multiplier > 512:
		cooldown_penalty_multiplier.wait_time = 3.0
	elif penalty_multiplier > 256:
		cooldown_penalty_multiplier.wait_time = 2.5
	elif penalty_multiplier > 128:
		cooldown_penalty_multiplier.wait_time = 2.0
	elif penalty_multiplier > 64:
		cooldown_penalty_multiplier.wait_time = 1.75
	elif penalty_multiplier > 32:
		cooldown_penalty_multiplier.wait_time = 1.5
	elif penalty_multiplier > 16:
		cooldown_penalty_multiplier.wait_time = 1.25
	else:
		cooldown_penalty_multiplier.wait_time = 1.0
	
	if Globals.level_collectibles < 50 : cooldown_penalty_multiplier.wait_time *= 4
	
	cooldown_penalty_multiplier.start()

func collected_item_reset_penaltyMultiplier():
	if not penalty_multiplier <= 1:
		penalty_multiplier -= 1
	
	restart_cooldown_penalty_multiplier()

func enemyHit_reset_penaltyMultiplier():
	if not penalty_multiplier <= 1:
		penalty_multiplier -= 1
		
	restart_cooldown_penalty_multiplier()


func _on_score_attack_time_left_reduction_timeout():
	if not game_over:
		penalty_total += penalty_base * penalty_multiplier
		score = 1000 + Globals.level_score - penalty_total
		if score < 0 : score = 0
	
	else : score = 0
	
	if game_over:
		penalty_multiplier -= penalty_multiplier / 5
		if penalty_multiplier < 0 : penalty_multiplier = 0
		return
	
	
	if score > 10000000:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_8.png")
	elif score > 1000000:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_7.png")
		
	elif score > 100000:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_6.png")
		
	elif score > 10000:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_5.png")
		
	elif score > 1000:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_4.png")
		
	elif score > 100:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_3.png")
		
	elif score > 10:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_2.png")
		
	else:
		score_counter.texture = preload("res://Assets/Graphics/other/scoreDisplay_1.png")
