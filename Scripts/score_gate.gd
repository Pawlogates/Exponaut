extends StaticBody2D

@onready var l_target_score: Label = $label_target_score
@onready var l_target_score_animation_general: AnimationPlayer = $label_target_score/animation_general
@onready var animation_color: AnimationPlayer = $animation_color

var activated = false
@export var target_score = 1000
@export var respawn_player_on_fail = true

# Called when the node enters the scene tree for the first time.
func _ready():
	l_target_score.text = str(target_score)

func _on_area_2d_area_entered(area):
	if area.is_in_group("Player"):
		if activated:
			return
		
		Overlay.HUD.get_node("ScoreDisplay").displayScore = Globals.level_score + Globals.combo_score
		await get_tree().create_timer(0.1, false).timeout
		
		if Globals.level_score >= target_score:
			activated = true
			$CollisionShape2D.set_deferred("disabled", true)
			animation_color.play("pulse_red_normal")
			l_target_score_animation_general.play("loop_scale")
		
		else:
			animation_color.play("fade_out")
