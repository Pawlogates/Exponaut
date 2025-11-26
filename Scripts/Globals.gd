extends Node

var direction = 1

var level_score = 0
var combo_score = 0
var combo_tier = 1
var collected_in_cycle = 0

var total_score = 0


var collected_goldenApples = 0
var collected_blueApples = 0
var collected_redApples = 0


var playerHP = 15

var player_pos = Vector2(0, 0)
var player_posX = 0
var player_posY = 0

var player_velocity = Vector2(0, 0)

#SIGNALS
signal itemCollected
signal enemyHit
signal boxBroken
signal specialAction

signal playerHit1
signal playerHit2
signal playerHit3
signal kill_player
signal increaseHp1
signal increaseHp2

signal shot
signal shot_charged
signal exitReached
signal comboReset
signal can_stand_up

var weaponType = "none"
signal weapon_collected
signal secondaryWeapon_collected

signal powerup_activated

signal score_reduced

signal player_transformed

#unused?
signal saveState_loaded
signal saveState_saved
signal save

signal max_score_multiplier_reached


var is_saving = false

var saved_player_posX = player_posX
var saved_player_posY = player_posY

var saved_level_score = level_score


#Background change
signal bgChange_entered
signal bgMove_entered
signal bgTransition_finished

var bg_File_previous = "res://Assets/Graphics/backgrounds/bg_fields.png"
var bg_File_current = "res://Assets/Graphics/backgrounds/bg_fields.png"

var bg_a_File_previous = "res://Assets/Graphics/backgrounds/bg_a_fields.png"
var bg_a_File_current = "res://Assets/Graphics/backgrounds/bg_a_fields.png"

var bg_b_File_previous = "res://Assets/Graphics/backgrounds/bg_b_fields.png"
var bg_b_File_current = "res://Assets/Graphics/backgrounds/bg_b_fields.png"

var bgOffset_target_x = 0
var bgOffset_target_y = 0

var bg_a_Offset_target_x = 0
var bg_a_Offset_target_y = 0

var bg_b_Offset_target_x = 0
var bg_b_Offset_target_y= 0
#Background change end


var test = 0
var test2 = 0
var test3 = 0
var test4 = "none"

var collected_collectibles = 0
var collectibles_in_this_level = 0


var inventory_selectedItem = 1
var inventory_onSpawn_scene = null

var infoSign_current_text = "none"
var infoSign_current_size = 0
signal info_sign_touched


var selected_episode = "Main Levels"
var current_levelSet_ID = "MAIN"
var next_level = -1
var current_level_ID = "none"
var current_level_number = -1

var current_topRankScore = 100000

signal scoreReset


signal save_progress
signal progress_loadingFinished
var quicksaves_enabled = false

var mode_scoreAttack = false

var transitioned = false
var next_transition = 0
var load_saved_position = true

#debug
var gameState_debug = true

var debug_mode = false
var debug_magic_projectiles = false

var delete_saves = false

# world state
var just_started_new_game = false
var left_start_area = false

# recording
signal start_recording
signal start_playback
signal stop_recording
signal gameplay_recorder_entered_level

var recording_autostart = false


var mapScreen = preload("res://Other/Scenes/Level Select/screen_levelSelect.tscn")

func _process(_delta):
	handle_actions()

func handle_actions():
	if get_node_or_null("/root/World") : return
	
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
		elif get_tree().paused == true:
			get_tree().paused = false
	
	elif Input.is_action_just_pressed("menu_start"):
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(preload("res://Other/Scenes/menu_start.tscn"))
		await LevelTransition.fade_from_black_slow()
	
	elif Input.is_action_just_pressed("menu"):
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(mapScreen)
		await LevelTransition.fade_from_black_slow()
	
	
	elif Input.is_action_pressed("debug_mode"):
		if Input.is_action_just_pressed("move_UP"):
			Globals.debug_mode = true
			
			if not get_node_or_null("/root/World"):
				return
			
			Globals.playerHP = 99999
			if get_node_or_null("/root/World/HUD/Debug Screen"):
				$/root/World/HUD/"Debug Screen"._on_toggle_ambience_pressed()
				$/root/World/HUD/"Debug Screen"._on_toggle_music_pressed()
			
			Globals.infoSign_current_text = str("Debug mode has been activated!")
			Globals.infoSign_current_size = 0
			Globals.info_sign_touched.emit()
		
		#elif Input.is_action_just_pressed("move_DOWN"):
			#pass


signal switch_signal_activated(switch_signal_ID)

signal checkpoint_activated
