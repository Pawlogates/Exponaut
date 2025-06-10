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
	if Globals.delete_saves:
		SavedData.saved_last_area_filePath = "res://Levels/overworld_infected_glades.tscn"
	
	elif SavedData.saved_last_area_filePath == "res://Levels/empty.tscn":
		_on_level_select_btn_pressed()
		return
	
	var saved_level = load(SavedData.saved_last_area_filePath)
	await LevelTransition.fade_to_black()
	Globals.transitioned = false
	get_tree().change_scene_to_packed(saved_level)

var mapScreen = load("res://Other/Scenes/Level Select/screen_levelSelect.tscn")
func _on_level_select_btn_pressed():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(mapScreen)
	await LevelTransition.fade_from_black_slow()


var score_counted_emitted = false
signal score_counted()

func _ready():
	saved_progress = LevelTransition.get_node("%saved_progress")
	
	set_process(false)
	score_counted.connect(after_score_counted)
	
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
	var level_saved_state = saved_progress.get("state_" + Globals.current_level_ID)
	var level_saved_score = saved_progress.get("state_" + Globals.current_level_ID)
	
	var level_info = saved_progress.get("info_" + Globals.current_level_ID)
	
	level_score = Globals.level_score
	topRankScore = level_info[4]
	
	%top_rank_label.text = "Top Rank: " + str(topRankScore)
	
	
	if not Globals.mode_scoreAttack and not Globals.selected_episode == "Debug Levels":
		if level_saved_state < 1:
			first_time_clear = true
		
		if get_tree().get_nodes_in_group("Collectibles").size() == 0:
			if level_saved_state < 3:
				saved_progress.set("state_" + str(Globals.current_level_ID), 3)
		
		elif get_tree().get_nodes_in_group("specialCollectible").size() <= 0:
			if level_saved_state < 2:
				saved_progress.set("state_" + str(Globals.current_level_ID), 2)
		
		elif get_tree().get_nodes_in_group("Collectibles").size() >= 0:
			if level_saved_state < 1:
				saved_progress.set("state_" + str(Globals.current_level_ID), 1)
		
		if level_saved_score < level_score:
			saved_progress.set("score_" + str(Globals.current_level_ID), level_score)
	
	
		if Globals.selected_episode == "Bonus Levels":
			if Globals.current_level_number == saved_progress.next_level_BONUS:
				saved_progress.next_level_BONUS += 1
	
	
		Globals.save_progress.emit()
	
	
	if $/root/World.final_level:
		if first_time_clear:
			await LevelTransition.fade_to_black_verySlow()
			await get_tree().create_timer(2, true).timeout
			var credits = load("res://Other/Scenes/screen_credits.tscn")
			get_tree().change_scene_to_packed(credits)
			
			return
	
	$AudioStreamPlayer.play()
	$level_finished_text_hide.start()
	await $level_finished_text_hide.timeout
	await LevelTransition.fade_to_black()
	%"Level Finished Label".visible = false
	%"Button Container".visible = true
	%Background.visible = true
	%"End Screen".visible = true
	%"End Screen Values".visible = true
	await LevelTransition.fade_from_black_slow()
	%ContinueBtn.grab_focus()
	
	set_process(true)
	calculate_rank()


var rank = "D" #possible ranks: D, C, B, A, S (no reward), S+ (no reward)
var rank_value = -1

func calculate_rank():
	var rank_info = saved_progress.calculate_rank(topRankScore, level_score)
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


func after_score_counted():
	if Globals.current_levelSet_ID == "MAIN":
		saved_progress.count_total_score(Globals.current_levelSet_ID, 7)
	elif Globals.current_levelSet_ID == "BONUS":
		saved_progress.count_total_score(Globals.current_levelSet_ID, 99)
	
	await get_tree().create_timer(1, true).timeout
	if Globals.current_levelSet_ID != "DEBUG":
		displayed_totalScore = saved_progress.get("total_score_" + Globals.current_levelSet_ID)
	
	#print(LevelTransition.get_node("%saved_progress").get("total_score_" + Globals.current_levelSet_ID))
	#print(("total_score_" + Globals.current_levelSet_ID))
	
	#if mode is something: then count various stuff and give points for them
		#await get_tree().create_timer(0.5, true).timeout
		#count_hp()
		#await get_tree().create_timer(0.5, true).timeout
		#count_inventoryItems()


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
