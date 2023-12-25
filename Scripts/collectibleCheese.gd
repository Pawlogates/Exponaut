extends Area2D

signal cheese_collected

@onready var collect_1 = $collect1
@onready var timer = $Timer


@onready var animation_player = $AnimationPlayer
@onready var animation_player2 = %AnimationPlayer
var collected = false


func _ready():

	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	

func _on_collectible_entered(body):
	if body.is_in_group("player") and not collected or body.is_in_group("player_projectile") and not collected:
		collected = true
		
		timer.start()
		animation_player.play("remove")
		animation_player2.play("score_value")
		collect_1.play()
		
		
		if Globals.collected_in_cycle == 0:
			Globals.level_score += 100
			
		else:
			Globals.level_score += 100
			Globals.combo_score += 100 * Globals.combo_tier
			
			
		Globals.cheese_collected.emit()
	
	
	
	
	
func _on_timer_timeout():
	
	queue_free()



