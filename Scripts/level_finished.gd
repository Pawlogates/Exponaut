extends CanvasLayer

@onready var sfx_manager: Node2D = $sfx_manager
@onready var container_results: VBoxContainer = $container_results
@onready var label_score: RichTextLabel = $container_results/label_score
@onready var label_score_total: RichTextLabel = $container_results/label_score_total
@onready var label_time: RichTextLabel = $container_results/label_time
@onready var container_majorCollectables: HBoxContainer = %container_majorCollectables
@onready var container_rank: VBoxContainer = %container_rank
@onready var label_rank: RichTextLabel = $container_rank/label_rank
@onready var label_next_rank_score: RichTextLabel = $container_rank/label_next_rank_score
@onready var animation_ui: AnimationPlayer = $animation_ui
@onready var container_level_finished: Control = $container_level_finished
@onready var label_score_previous_best: RichTextLabel = $container_results/label_score_previous_best
@onready var label_time_previous_best: RichTextLabel = $container_results/label_time_previous_best


var level_id : String = "DEBUG_-1"
var levelSet_id : String = "DEBUG"

var level_data : Array = [-1, -1, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

var level_score : float = -1
var level_time : float = -1
var level_majorCollectables : Array = [0, 0, 0]

var level_previous_best_score : float = -1
var level_previous_best_time : float = -1
var total_score : float = 0

var rank : String = "none"
var rank_value : int = -1

var score_current : bool = true # Whether the score was aquired right now, or is just being viewed.


func _ready():
	Globals.gameState_changed.connect(delete)
	
	Globals.set_mouse_mode(true)
	
	set_process(false)
	
	level_data = SaveData.get("saved_" + level_id)
	
	if score_current:
		level_score = Globals.level_score
		level_previous_best_score = int(level_data[1])
	
	else:
		level_score = int(level_data[1])
		label_score_previous_best.queue_free()
	
	
	level_time = level_data[2]
	level_majorCollectables = level_data[3]
	
	total_score = SaveData.get_total_score(levelSet_id)
	
	container_results.modulate.a = 0
	container_majorCollectables.modulate.a = 0
	container_rank.modulate.a = 0
	
	animation_ui.play("show")
	
	var rank_data = SaveData.calculate_rank_level(level_id)
	rank = rank_data[0]
	rank_value = rank_data[1]
	
	label_score_previous_best.text = str(int(level_previous_best_score))
	label_score_previous_best.update_text()
	
	label_rank.text = rank
	label_rank.update_text()
	
	label_score_total.text = str(int(total_score))
	label_score_total.update_text()
	label_time.text = str(level_time / 1000)
	label_time.update_text()


var level_score_displayed = 0

func _process(_delta):
	if Input.is_action_just_pressed("menu") : queue_free()
	handle_count_score()


func delete():
	animation_ui.play("hide")
	await animation_ui.animation_finished
	queue_free()


func _on_cooldown_show_results_timeout() -> void:
	container_results.modulate.a = 1
	container_majorCollectables.modulate.a = 1
	container_level_finished.modulate.a = 0
	
	set_process(true)


var level_score_displayed_set : bool = false

func handle_count_score():
	if level_score_displayed_set : return
	
	if level_score_displayed != level_score:
		if level_score - level_score_displayed <= 50:
			level_score_displayed += 1
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 0.4), randf_range(0.05, 10))
			
		elif level_score - level_score_displayed <= 250:
			level_score_displayed += 3
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 0.5), randf_range(0.05, 10))
		
		elif level_score - level_score_displayed <= 500:
			level_score_displayed += 11
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 0.6), randf_range(0.05, 10))
			
		elif level_score - level_score_displayed <= 2500:
			level_score_displayed += 41
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 0.7), randf_range(0.05, 10))
			
		elif level_score - level_score_displayed <= 10000:
			level_score_displayed += 121
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 0.8), randf_range(0.05, 10))
			
		elif level_score - level_score_displayed <= 25000:
			level_score_displayed += 251
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 0.9), randf_range(0.05, 10))
		
		else:
			level_score_displayed += 1234
			sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 1), randf_range(0.05, 10))
		
		label_score.text = str(int(level_score_displayed))
	
	else:
		if level_score > level_previous_best_score:
			label_score.text = str(int(level_score_displayed)) + " (New best!)"
		else:
			label_score.text = str(int(level_score_displayed))
		label_score.update_text()
		
		container_rank.modulate.a = 1
		
		level_score_displayed_set = true
		total_score = SaveData.get_total_score(levelSet_id)
		label_score_total.text = str(int(total_score))
		label_score_total.update_text()
		await get_tree().create_timer(1.0, true).timeout
		Globals.spawn_menu(Globals.scene_menu_main, ["Start New Game", "Continue", "Resume game", "Select Level Set", "Quit Game", "Back to Overworld", "Enable Score Attack mode", "Settings", "Quit to Main Menu", "Close", "Touch Controls"], Vector2(0, 350))
