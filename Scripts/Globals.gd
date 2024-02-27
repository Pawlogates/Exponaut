extends Node


#variables

var direction = 1

var level_score = 0
var combo_score = 0
var combo_tier = 1
var collected_in_cycle = 0

var total_score = 0


var playerHP

var player_pos
var player_posX
var player_posY



#signals

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


#Save state

signal saveState_loaded
signal saveState_saved
signal save

var is_saving = false



var saved_player_posX = player_posX
var saved_player_posY = player_posY

var saved_level_score = level_score

var loadingZone_current = "none"



#Background change

signal bgChange_entered
signal bgMove_entered
signal bgTransition_finished

var bgFile_previous = preload("res://Assets/Graphics/bg1.png")
var bgFile_current = preload("res://Assets/Graphics/bg1.png")

var bg_a_File_previous = preload("res://Assets/Graphics/bg1a.png")
var bg_a_File_current = preload("res://Assets/Graphics/bg1a.png")

var bg_b_File_previous = preload("res://Assets/Graphics/bg1b.png")
var bg_b_File_current = preload("res://Assets/Graphics/bg1b.png")

var bgOffset_target_x = 0
var bgOffset_target_y = 0


var test = 0
var test2 = 0
var test3 = 0
var test4 = "none"

var collected_collectibles = 0


var inventory_selectedItem = 1
var inventory_onSpawn_scene = null

var infoSign_current_text = "none"
var infoSign_current_size = 0
signal info_sign_touched



var selected_episode = "rooster_island"
var next_level = -1
var current_level = "none"
var current_level_ID = -1

signal save_progress


signal progress_loadingFinished





var quicksaves_enabled = false

var mode_scoreAttack = false



var next_transition = 0







var debug_mode = false

signal cheated
var cheated_state = false
