extends Node2D

@onready var timer_combo_streak_active: Timer = $timer_combo_streak_active

@onready var sfx_manager: Node2D = $sfx_manager

func _ready():
	Globals.entity_collected.connect(on_entity_collected)
	Globals.entity_hit.connect(on_entity_hit)
	Globals.entity_killed.connect(on_entity_killed)
	Globals.combo_refreshed.connect(on_combo_refreshed)


func check_combo_tier():
	if Globals.combo_streak > 20:
		Globals.combo_tier = 5
		
	elif Globals.combo_streak > 15:
		Globals.combo_tier = 4
	
	elif Globals.combo_streak > 10:
		Globals.combo_tier = 3
	
	elif Globals.combo_streak > 5:
		Globals.combo_tier = 2
	
	elif Globals.combo_streak >= 0:
		Globals.combo_tier = 1
	
	
	if Globals.combo_streak == 20:
		Globals.max_scoreMultiplier_reached.emit()


func reset_combo_tier():
	Globals.combo_streak = 0
	check_combo_tier()
	
	sfx_manager.sfx_play(Globals.sfx_combo_streak_finished)
	
	Globals.combo_reset.emit()
	
	Globals.level_score += Globals.combo_score
	Globals.combo_score = 0


func refresh_combo_streak_timer(duration : float = 2.0):
	timer_combo_streak_active.wait_time = duration
	timer_combo_streak_active.start()


func itemCollected_reset_combo_cycle():
	Globals.collected_in_cycle += 1
	check_combo_tier()
	refresh_combo_streak_timer()


func enemyHit_reset_combo_cycle():
	check_combo_tier()
	refresh_combo_streak_timer()


func boxBroken_reset_combo_cycle():
	check_combo_tier()
	refresh_combo_streak_timer()


func reset_combo_cycle_long():
	check_combo_tier()
	refresh_combo_streak_timer()


func _on_timer_combo_streak_active_timeout():
	var combo_score_value_display = Globals.scene_effect_score_bonus.instantiate()
	combo_score_value_display.value = Globals.combo_score
	combo_score_value_display.position = Globals.Player.position
	
	if Globals.combo_streak == 1 : combo_score_value_display.gravity_based_on_combo_streak = false ; combo_score_value_display.ignore_gravity = true ; combo_score_value_display.slow = true ; combo_score_value_display.gravity_based_on_combo_streak = false
	elif Globals.combo_streak < 5 : combo_score_value_display.gravity_based_on_combo_streak = false ; combo_score_value_display.ignore_gravity = false ; combo_score_value_display.slow = true ; combo_score_value_display.gravity_based_on_combo_streak = false
	else : combo_score_value_display.gravity_based_on_combo_streak = false ; combo_score_value_display.ignore_gravity = false ; combo_score_value_display.slow = true ; combo_score_value_display.gravity_based_on_combo_streak = false
	
	Globals.World.add_child(combo_score_value_display)
	
	reset_combo_tier()
	Globals.dm("Combo streak finished.")


func on_entity_collected():
	check_combo_tier()
	refresh_combo_streak_timer()

func on_entity_hit():
	check_combo_tier()
	refresh_combo_streak_timer(0.5)

func on_entity_killed():
	check_combo_tier()
	refresh_combo_streak_timer(5.0)

func on_combo_refreshed(time):
	pass
