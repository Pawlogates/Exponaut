extends CharacterBody2D


var target = Globals.player_pos

var velocityMultiplier = 0.25
var SPEED = 600

@onready var scoreAttack_timeLeft = 1000
@onready var scoreAttack_penaltyMultiplier = 1
@onready var scoreAttack_penaltyTotal = 0

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Globals.player_pos
	
	Globals.itemCollected.connect(collected_item_reset_penaltyMultiplier)
	Globals.enemyHit.connect(enemyHit_reset_penaltyMultiplier)
	



func _physics_process(_delta):
	target = Globals.player_pos
	
	if global_position.distance_to(target) > 150:
		if global_position.distance_to(target) > 800:
			velocityMultiplier = 1
		elif global_position.distance_to(target) > 600:
			velocityMultiplier = 0.8
		elif global_position.distance_to(target) > 400:
			velocityMultiplier = 0.6
		elif global_position.distance_to(target) > 300:
			velocityMultiplier = 0.4
		elif global_position.distance_to(target) > 200:
			velocityMultiplier = 0.2
	else:
			velocityMultiplier = 0.1
		
	
	velocity = global_position.direction_to(target) * SPEED * velocityMultiplier
	
	
	
	%scoreAttack_timeLeft_display.text = str(scoreAttack_timeLeft)
	%scoreAttack_penaltyMultiplier_display.text = str("x", scoreAttack_penaltyMultiplier)
	
	
	if Globals.combo_tier == 5:
		scoreAttack_penaltyMultiplier = 1
		max_combo_tier = true
	
	else:
		max_combo_tier = false
	
	if scoreAttack_timeLeft <= 0:
		game_over = true
		await get_tree().create_timer(0.1, false).timeout
		get_parent().retry()
		
	
	
	move_and_slide()
	





var max_combo_tier = false


func _on_score_attack_penalty_multiplier_timeout():
	if not max_combo_tier:
		scoreAttack_penaltyMultiplier *= 2



func collected_item_reset_penaltyMultiplier():
	if not scoreAttack_penaltyMultiplier <= 1:
		scoreAttack_penaltyMultiplier -= 1
	
	$scoreAttack_penaltyMultiplier.start()

func enemyHit_reset_penaltyMultiplier():
	if not scoreAttack_penaltyMultiplier <= 1:
		scoreAttack_penaltyMultiplier -= 1
		
	$scoreAttack_penaltyMultiplier.start()



func _on_score_attack_time_left_reduction_timeout():
	if not game_over:
		scoreAttack_penaltyTotal += 1 * scoreAttack_penaltyMultiplier
		scoreAttack_timeLeft = 1000 + Globals.level_score - scoreAttack_penaltyTotal
		if scoreAttack_timeLeft <= 0:
			scoreAttack_timeLeft = 0
			
	else:
		scoreAttack_timeLeft = 0
	
	
	if scoreAttack_timeLeft > 10000000:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_8.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -40
	elif scoreAttack_timeLeft > 1000000:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_7.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -52
	elif scoreAttack_timeLeft > 100000:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_6.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -64
	elif scoreAttack_timeLeft > 10000:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_5.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -76
	elif scoreAttack_timeLeft > 1000:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_4.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -88
	elif scoreAttack_timeLeft > 100:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_3.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -100
	elif scoreAttack_timeLeft > 10:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_2.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -112
	else:
		%TextureRect.texture = preload("res://Assets/Graphics/scoreDisplay_1.png")
		%scoreAttack_penaltyMultiplier_display.position.x = -124
