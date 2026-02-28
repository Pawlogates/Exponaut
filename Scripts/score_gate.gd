extends StaticBody2D

@onready var text_manager_target_score: Control = $text_manager_target_score
@onready var target_score_animation_general: AnimationPlayer = $text_manager_target_score/animation_general
@onready var animation_color: AnimationPlayer = $animation_color
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sfx_manager: Node2D = $sfx_manager

var activated = false
@export var target_score = 1000
@export var respawn_player_on_fail = true

# Called when the node enters the scene tree for the first time.
func _ready():
	text_manager_target_score.text_full = str(target_score)
	text_manager_target_score.create_message()

func _on_area_2d_area_entered(area):
	if area.is_in_group("Player"):
		if activated:
			return
		
		Overlay.HUD.get_node("ScoreDisplay").displayScore = Globals.level_score + Globals.combo_score
		await get_tree().create_timer(0.1, false).timeout
		
		if Globals.level_score >= target_score:
			activated = true
			collision.set_deferred("disabled", true)
			animation_color.play("fade_out")
			$sfx_manager.sfx_play(Globals.sfx_electric_disabled2, 1.0, 0.75)
		
		else:
			animation_color.play("fade_out")
			animation_color.play("pulse_red_normal")
			target_score_animation_general.play("loop_scale")
			$sfx_manager.sfx_play(Globals.sfx_electric_disabled, 1.0, 0.85)
			
			text_manager_target_score.text_full = "[anim_rotate_away_up_right]You need " + str(target_score - Globals.level_score) + " more points to open this gate."
			text_manager_target_score.character_anim_speed_scale = 4
			text_manager_target_score.text_animation_add_offset = 0
			text_manager_target_score.cooldown_next_character = 0.01
			text_manager_target_score.character_bg_simple = true
			text_manager_target_score.text_animation_sync = false
			text_manager_target_score.character_anim_backwards = true
			text_manager_target_score.create_message()
