extends CanvasLayer

@onready var sfx_manager: Node2D = $sfx_manager
@onready var container_results: VBoxContainer = $container_results
@onready var label_score: RichTextLabel = $container_results/label_score
@onready var label_score_total: RichTextLabel = $container_results/label_score_total
@onready var label_time: RichTextLabel = $container_results/label_time
@onready var label_time_total: RichTextLabel = $container_results/label_time_total
@onready var container_majorCollectables: HBoxContainer = %container_majorCollectables

@onready var container_rank: VBoxContainer = %container_rank
@onready var label_rank: RichTextLabel = $container_rank/label_rank
@onready var label_score_segment: RichTextLabel = $container_rank/label_score_segment
@onready var label_score_target: RichTextLabel = $container_rank/label_score_target

@onready var animation_ui: AnimationPlayer = $animation_ui
@onready var container_level_finished: Control = $container_level_finished
@onready var label_level_finished: Control = $container_level_finished/text_core
@onready var label_score_previous_best: RichTextLabel = $container_results/label_score_previous_best
@onready var label_time_previous_best: RichTextLabel = $container_results/label_time_previous_best


var level_id : String = "DEBUG_-1"
var levelSet_id : String = "DEBUG"

var level_data : Array = [-1, -1, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

var level_score : int = -1
var level_time : int = -1
var level_majorCollectables : Array = [0, 0, 0]

var level_previous_best_score : int = -1
var level_previous_best_time : int = -1
var total_score : int = 0
var total_time : int = 0

var rank : String = "none"
var rank_value : int = -1

var score_current : bool = true # Whether the score was aquired right now, or is just being viewed.

var show_results_active : bool = false

func _ready():
	if level_failed:
		if Globals.get_random_bool(50):
			label_level_finished.text_main = "YOU RAN OUT OF SCORE..."
			label_level_finished.update_text()
		elif Globals.get_random_bool(50):
			label_level_finished.text_main = "YOU NEED TO SCORE BETTER!"
			label_level_finished.update_text()
		elif Globals.get_random_bool(50):
			label_level_finished["theme_override_font_sizes/normal_font_size"] = 100
			label_level_finished.text_main = "YOU REAP WHAT YOU SCORE..."
			label_level_finished.update_text()
		elif Globals.get_random_bool(50):
			label_level_finished["theme_override_font_sizes/normal_font_size"] = 90
			label_level_finished.text_main = "THAT SCORE REALLY GOT TO YOU, HUH?"
			label_level_finished.update_text()
		else:
			label_level_finished["theme_override_font_sizes/normal_font_size"] = 80
			label_level_finished.text_main = "YOU GOT SCORE ATTACKED TO DEATH, BUMMER!"
			label_level_finished.update_text()
	
	else:
		if Globals.get_random_bool(50):
			label_level_finished.text_main = "LEVEL FINISHED!"
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished.text_main = "GOOD JOB!"
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished.text_main = "YOU DID IT!"
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished.text_main = "WHAT TOOK YOU SO LONG?"
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished.text_main = "YOU CALL THAT A SCORE?"
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished["theme_override_font_sizes/normal_font_size"] = 80
			label_level_finished.text_main = "DAMN, I WAS STARTING TO LOSE HOPE HONESTLY..."
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished.text_main = "FINALLY..."
			label_level_finished.update_text()
		elif Globals.get_random_bool(25):
			label_level_finished.text_main = "WHATEVER..."
			label_level_finished.update_text()
		else:
			label_level_finished.text_main = "I GUESS..."
			label_level_finished.update_text()
	
	if level_failed:
		$text_manager.cooldown_create_message = randf_range(0.5, 2.5)
		$text_manager.character_anim_speed_scale = randf_range(1.0, 8.0)
		var l_animation_name : Array = ["rotate_around_y_fade_out", "rotate_away_up_right", "rotate_away_up_right_scale_up"]
		$text_manager.text_full = $text_manager.text_full.replace("rotate_around_y_fade_out", l_animation_name.pick_random())
		$text_manager.character_bg_simple = Globals.get_random_bool(25)
		
		if Globals.get_random_bool(10) : $text_manager.cooldown_next_character = randf_range(0.01, 0.25)
		else : $text_manager.cooldown_next_character = randf_range(0.005, 0.1)
		var list_message_end : Array = [" TRY AGAIN...", " RESTART.", " RETRY.", " RESTART THE LEVEL.", " TRY AGAIN. YOU CAN DO IT!", " GIVE AN ENCORE!", "... ENCORE?", " HAVE ANOTHER CRACK AT THIS!", " SHOW HOW MUCH THIS WAS SIMPLY A ONE-TIME ACCIDENT.", " DO IT CORRECTLY THIS TIME... HOPEFULLY.", " TO MAKE UP FOR THIS... TRULY HORRID PERFORMANCE.", "... MAN, AT THIS POINT I GOTTA SAY, ITS PRETTY HOPELESS.", "... OH COME ON! THERE'S NO WAY YOU FUMBLED IT QUITE THIS BADLY ON ACCIDENT... RIGHT?"]
		var message_end : String
		if Globals.get_random_bool(20) : message_end = [" TRY AGAIN...", " RESTART.", " RETRY.", " RESTART THE LEVEL.", " TRY AGAIN. YOU CAN DO IT!"].pick_random()
		elif Globals.get_random_bool(10) : message_end = [" TRY AGAIN...", " RESTART.", " RETRY.", " RESTART THE LEVEL.", " TRY AGAIN. YOU CAN DO IT!", " TO GIVE AN ENCORE!", "... ENCORE?", " HAVE ANOTHER CRACK AT THIS!", " SHOW HOW MUCH THIS WAS SIMPLY A ONE-TIME ACCIDENT.", " DO IT CORRECTLY THIS TIME... HOPEFULLY."].pick_random()
		else : message_end = list_message_end.pick_random()
		if len(message_end) > 40 : $text_manager.text_font_size = 26 ; $text_manager.scale *= 0.85 ; $text_manager.position.x += 110
		else : $text_manager.text_font_size = 46
		
		$text_manager.text_full = $text_manager.text_full.replace(" CONTINUE...", message_end)
		$text_manager.create_message()
	
	else:
		if Globals.level_id == "TUTORIAL_6" : $text_manager.queue_free()
	
	Globals.gameState_changed.connect(delete)
	
	Globals.set_mouse_mode(true)
	
	set_physics_process(false)
	
	level_data = SaveData.get("saved_" + level_id)
	
	if score_current:
		level_score = Globals.level_score
		level_previous_best_score = int(level_data[1])
		level_time = Globals.level_time
		level_previous_best_time = int(level_data[2])
	
	else:
		level_score = int(level_data[1])
		label_score_previous_best.queue_free()
	
	level_majorCollectables = level_data[3]
	
	total_score = SaveData.get_total_score(levelSet_id)
	total_time = SaveData.get_total_time(levelSet_id)
	
	container_results.modulate.a = 0
	container_majorCollectables.modulate.a = 0
	container_rank.modulate.a = 0
	
	animation_ui.play("show")
	
	label_score_previous_best.text = str(int(level_previous_best_score))
	label_score_previous_best.update_text()
	
	if level_previous_best_time != -1:
		label_time_previous_best.text = str(int(level_previous_best_time / 1000)) + " s"
		label_time_previous_best.update_text()
	else:
		label_time_previous_best.text = "Not Set"
		label_time_previous_best.update_text()
	
	
	label_score_total.text = str(int(total_score))
	label_score_total.update_text()
	
	label_time.text = str(int(level_time / 1000)) + " s"
	label_time.update_text()
	
	await get_tree().create_timer(0.1, false).timeout
	
	visible = true
	
	if Globals.random_bool(3, 1) or Globals.level_id == "TUTORIAL_2" or Globals.level_id == "TUTORIAL_3":
		Globals.server_to_dirpath(Globals.d_recordings_online)
		await get_tree().create_timer(2.0, false).timeout
		Globals.update_recordings_best()
		await get_tree().create_timer(4.0, false).timeout
		Globals.dirpath_to_server(Globals.d_recordings_local_best, "leaderboard/upload")


var level_score_displayed = 0

func _physics_process(delta):
	if Globals.level_time_seconds < 2 : return
	
	if show_results_active and level_failed:
		container_level_finished.position.y = lerp(container_level_finished.position.y, -290.0, delta * 2)
	
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_up") : return
		
		if Globals.level_id == "TUTORIAL_6" : return
		
		if SaveData.player_name != "none":
			if is_instance_valid(Globals.World) and SaveData.player_name != "none" and Globals.level_score != 0 and level_score_displayed > 0 or is_instance_valid(Globals.World) and Globals.levelSet_id != "TUTORIAL" or level_failed:
				
				if level_failed:
					Globals.restart_level()
				
				else:
					if Globals.level_id == "TUTORIAL_6":
						await Globals.change_main_scene(Globals.scene_levelSet_screen)
						queue_free()
					
					else:
						await Globals.change_main_scene(Globals.World.next_level_filepath)
						queue_free()
			
		else:
			Globals.message("Press ENTER to confirm the player name and continue.")
	
	if level_failed : return
	
	if Input.is_action_just_pressed("menu"):
		if not Globals.node_exists("leaderboard"):
			queue_free()
	
	handle_count_score()
	
	label_score.modulate.r = move_toward(label_score.modulate.r, 1, delta)
	label_score.modulate.g = move_toward(label_score.modulate.g, 1, delta)
	label_score.modulate.b = move_toward(label_score.modulate.b, 1, delta)
	
	label_score.visible = true


func delete():
	animation_ui.play("hide")
	await animation_ui.animation_finished
	queue_free()


@export var level_failed : bool = false

func _on_cooldown_show_results_timeout() -> void:
	show_results_active = true
	
	if level_failed:
		if Globals.get_random_bool(25) and Globals.level_collected_collectibles:
			Globals.restart_level()
			$text_manager.text_full = "TRY AGAIN!"
			$text_manager.cooldown_create_message = randf_range(0.05, 0.5)
			$text_manager.character_anim_speed_scale = randf_range(4.0, 8.0)
			$text_manager.cooldown_next_character = randf_range(0.005, 0.01)
			$text_manager.create_message()
			return
		
		else:
			Globals.spawn_menu(Globals.scene_menu_main, ["Start New Game", "Continue", "Resume game", "Select Level Set", "Back to Overworld", "Settings", "Quit to Main Menu", "Close", "Touch Controls"], Vector2(0, 300), Vector2(1, 1), false)
	
	else:
		container_results.modulate.a = 1
		container_majorCollectables.modulate.a = 1
		container_level_finished.modulate.a = 0
	
	set_physics_process(true)


var level_score_displayed_set : bool = false

func handle_count_score():
	if level_score_displayed_set : return
	
	if level_score_displayed > 500000 : effects_count_segment_break(3, 80)
	elif level_score_displayed > 400000 : effects_count_segment_break(3, 76)
	elif level_score_displayed > 300000 : effects_count_segment_break(3, 72)
	elif level_score_displayed > 200000 : effects_count_segment_break(2, 68)
	elif level_score_displayed > 100000 : effects_count_segment_break(2, 56)
	elif level_score_displayed > 10000 : effects_count_segment_break(2, 40)
	elif level_score_displayed > 5000 : effects_count_segment_break(1, 32)
	elif level_score_displayed > 1000 : effects_count_segment_break(1, 28)
	else : effects_count_segment_break(1, 24)
	
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
		on_score_displayed_set()

func on_score_displayed_set():
	if level_score > level_previous_best_score:
		label_score.text = str(int(level_score_displayed)) + "[font_size=32] (New best!)[/font_size]"
	else:
		label_score.text = str(int(level_score_displayed))
	label_score.update_text()
	
	if level_time < level_previous_best_time:
		label_time.text = str(int(level_time / 1000)) + " s" + "[font_size=32] (New best!)[/font_size]"
	else:
		label_time.text = str(int(level_time / 1000)) + " s"
	label_time.update_text()
	
	container_rank.modulate.a = 1
	
	level_score_displayed_set = true
	
	total_score = SaveData.get_total_score(levelSet_id)
	label_score_total.text = str(int(total_score))
	label_score_total.update_text()
	
	total_time = SaveData.get_total_time(levelSet_id)
	label_time_total.text = str(int(total_time / 1000)) + " s"
	label_time_total.update_text()
	
	
	var rank_data = SaveData.calculate_rank_level(level_id)
	rank = rank_data[0]
	rank_value = rank_data[1]
	var rank_score = rank_data[2]
	var rank_score_target = rank_data[3]
	var rank_score_segment = rank_data[4]
	
	label_rank.text = rank
	label_rank.update_text()
	
	label_score_target.text = str(int(rank_score)) + "/" + str(rank_score_target) + " (the score needed for acquiring the maximum rank - 'Exponaut')"
	label_score_target.update_text()
	
	label_score_segment.text = str(rank_score_segment) + " (the score difference between each rank)"
	label_score_segment.update_text()
	
	
	await get_tree().create_timer(2.0, true).timeout
	
	#Globals.spawn_scenes(Overlay, load("res://Other/Scenes/User Interface/Menus/menu_leaderboard_level.tscn"), 1, Vector2(0, 0), -1)
	Globals.spawn_menu(Globals.scene_menu_main, ["Start New Game", "Continue", "Resume game", "Select Level Set", "Back to Overworld", "Settings", "Quit to Main Menu", "Close", "Touch Controls"], Vector2(0, 300), Vector2(1, 1), false)


@onready var count_sfx_manager: Node2D = $count_sfx_manager

func effects_count_segment_break(type : int = 1, font_size : int = 48):
	if label_score["theme_override_font_sizes/normal_font_size"] == font_size : return
	
	label_score["theme_override_font_sizes/normal_font_size"] = font_size
	label_score.modulate *= 1 + (0.25 * type * type)
	
	if type == 1:
		count_sfx_manager.sfx_play(Globals.sfx_jewel_collect)
		Globals.spawn_scenes(label_score, Globals.scene_particle_star, 1, label_score.size / 2)
	elif type == 2:
		count_sfx_manager.sfx_play(Globals.sfx_jewel_collect2)
		Globals.spawn_scenes(label_score, Globals.scene_particle_star, 4, label_score.size / 2)
	elif type == 3:
		count_sfx_manager.sfx_play(Globals.sfx_jewel_collect3)
		Globals.spawn_scenes(label_score, Globals.scene_particle_star, 8, label_score.size / 2)
