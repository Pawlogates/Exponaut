extends StaticBody2D


var activated = false
@export var target_score = 1000




# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(target_score)




func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		if activated:
			return
		
		get_parent().get_node("%ComboManager").reset_combo_tier()
		get_parent().get_node("%ScoreDisplay/Score").displayScore = Globals.level_score + Globals.combo_score
		await get_tree().create_timer(0.1, false).timeout
		
		if Globals.level_score >= target_score:
			activated = true
			$CollisionShape2D.set_deferred("disabled", true)
			$AnimationPlayer.play("unlock")
		
		else:
			$AnimationPlayer.play("locked")
			get_parent().retry_scoreGate()
