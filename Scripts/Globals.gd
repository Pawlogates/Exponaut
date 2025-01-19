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


signal save_progress
signal progress_loadingFinished
var quicksaves_enabled = false

var mode_scoreAttack = false

var transitioned = false
var next_transition = 0
var load_saved_position = true


var debug_mode = false
var debug_magic_projectiles = false

var delete_saves = false

signal scoreReset


#world states
var just_started_new_game = false
var left_start_area = false
