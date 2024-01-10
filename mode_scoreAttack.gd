extends CharacterBody2D


@onready var scoreAttack_actualTime = int(get_parent().levelTime_visible)
@onready var scoreAttack_timeLeft = 1000
@onready var scoreAttack_penaltyMultiplier = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Globals.player_pos)
	global_position = Globals.player_pos
	
	Globals.itemCollected.connect(collected_item_reset_penaltyMultiplier)
	Globals.enemyHit.connect(enemyHit_reset_penaltyMultiplier)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(scoreAttack_actualTime)
	print(scoreAttack_penaltyMultiplier)
	print(scoreAttack_timeLeft)
	
	%scoreAttack_timeLeft_display.text = str(scoreAttack_timeLeft)
	
	if scoreAttack_timeLeft <= 0:
		get_parent().retry()
	
	
	


@onready var SPEED = 200.0
@onready var old_v = velocity
@onready var target = Globals.player_pos

func _physics_process(delta):
	target = Globals.player_pos
	
	print(Globals.player_pos)
	print(get_global_mouse_position())
	
	
	if global_position.distance_to(target) > 25:
		velocity = global_position.direction_to(target) * SPEED
	
	
	
	if velocity != Vector2(0, 0):
		old_v = velocity
		
	if global_position.distance_to(target) < 15:
		velocity = old_v * 30
		
		
	
	
	move_and_slide()


func _on_score_attack_penalty_multiplier_timeout():
	scoreAttack_penaltyMultiplier += 1



func collected_item_reset_penaltyMultiplier():
	scoreAttack_penaltyMultiplier = 1
	$scoreAttack_penaltyMultiplier.start()

func enemyHit_reset_penaltyMultiplier():
	scoreAttack_penaltyMultiplier = 1
	$scoreAttack_penaltyMultiplier.start()



func _on_score_attack_time_left_reduction_timeout():
	scoreAttack_timeLeft -= (1 * scoreAttack_penaltyMultiplier) - scoreAttack_actualTime
	

