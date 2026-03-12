extends ColorRect

signal retry()

@onready var retry_btn = %RetryBtn
@onready var level_select_btn = %LevelSelectBtn

var level_score = 0
var displayed_totalScore = 0
var displayed_score = 0

var saved_progress = Node2D

func _on_retry_btn_pressed():
	retry.emit()

func _on_continue_btn_pressed():
	Globals.change_main_scene(SaveData.saved_last_level_filepath)

func _on_level_select_btn_pressed():
	Globals.change_main_scene(Globals.scene_levelSet_screen)


var score_counted_emitted = false
signal score_counted()

func _ready():
	Globals.gameState_changed.connect(on_gameState_changed)
	
	Globals.set_mouse_mode(true)
	
	saved_progress = SaveData
	
	set_process(false)
	
	%"Golden Apple Reward 1".modulate.a = 0.2
	%"Golden Apple Reward 2".modulate.a = 0.2
	%"Golden Apple Reward 3".modulate.a = 0.2
	%"Golden Apple Reward 4".modulate.a = 0.2
	%"Golden Apple Reward 5".modulate.a = 0.2


func _process(_delta):
	if displayed_score != level_score and level_score - displayed_score <= 10:
		displayed_score += 1
		
	if displayed_score != level_score and level_score - displayed_score <= 100 and level_score - displayed_score > 10:
		displayed_score += 3
	
	if displayed_score != level_score and level_score - displayed_score <= 1000 and level_score - displayed_score > 100:
		displayed_score += 11
		
	if displayed_score != level_score and level_score - displayed_score > 1000:
		displayed_score += 41
		
	if displayed_score != level_score and level_score - displayed_score > 10000:
		displayed_score += 121
		
	if displayed_score != level_score and level_score - displayed_score > 25000:
		displayed_score += 251
	
	
	%"Level Score Label".text = str(displayed_score)
	%"Total Score Label".text = str(displayed_totalScore)
	
	
	if not score_counted_emitted and displayed_score == level_score:
		score_counted.emit()
		score_counted_emitted = true


var first_time_clear = false
var topRankScore = 0

func exit_reached():
	var level_saved_state = saved_progress.get("saved_" + Globals.level_id)[0]
	var level_saved_score = saved_progress.get("saved_" + Globals.level_id)[1]
	
	var level_info = saved_progress.get("info_" + Globals.level_id)
	
	level_score = Globals.level_score
	topRankScore = level_info[4]
	
	%top_rank_label.text = "Top Rank: " + str(topRankScore)
	
	
	if $/root/World.final_level:
		if first_time_clear:
			Overlay.animation("fade_black", 0, 1.0, true)
			await get_tree().create_timer(2, true).timeout
			var credits = load("res://Other/Scenes/screen_credits.tscn")
			get_tree().change_scene_to_packed(credits)
			
			return
	
	$AudioStreamPlayer.play()
	$level_finished_text_hide.start()
	await $level_finished_text_hide.timeout
	Overlay.animation("fade_black", 0, 1.0, true)
	%"Level Finished Label".visible = false
	%"Button Container".visible = true
	%Background.visible = true
	%"End Screen".visible = true
	%"End Screen Values".visible = true
	Overlay.animation("fade_black", 0, 1.0, true)
	%ContinueBtn.grab_focus()
	
	set_process(true)
	calculate_rank()


var rank = "D" #possible ranks: D, C, B, A, S (no reward), S+ (no reward)
var rank_value = -1

func calculate_rank():
	var rank_info = saved_progress.calculate_rank_level(Globals.level_id)
	rank = rank_info[0]
	rank_value = rank_info[1]
	
	%achieved_rank_label.text = rank
	
	if rank_value >= 1:
		await get_tree().create_timer(0.5, true).timeout
		%"Golden Apple Reward 1".modulate.a = 1.0
	if rank_value >= 2:
		await get_tree().create_timer(0.5, true).timeout
		%"Golden Apple Reward 2".modulate.a = 1.0
	if rank_value >= 3:
		await get_tree().create_timer(0.5, true).timeout
		%"Golden Apple Reward 3".modulate.a = 1.0
	if rank_value >= 4:
		await get_tree().create_timer(0.5, true).timeout
		%"Golden Apple Reward 4".modulate.a = 1.0
	if rank_value >= 5:
		await get_tree().create_timer(0.5, true).timeout
		%"Golden Apple Reward 5".modulate.a = 1.0


var displayedBonus_hp = 0
var displayedBonus_time = 0
var displayedBonus_items = 0

func count_hp():
	while Globals.playerHP > 0:
		print(Globals.playerHP)
		Globals.playerHP -= 1
		displayedBonus_hp += 1000
		await get_tree().create_timer(0.5, true).timeout


func count_inventoryItems():
	if Globals.inventory_currentItemCount > 0:
		displayedBonus_items += 1000


func on_gameState_changed():
	visible = false
