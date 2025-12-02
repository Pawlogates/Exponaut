extends Node

var player_health = 5

var player_position = Vector2(0, 0)
var player_velocity = Vector2(0, 0)

var player_direction = 0
var player_direction_active = 1

var level_score = 0
var combo_score = 0
var combo_tier = 1
var collected_in_cycle = 0 # Combo cycle starts on collecting a collectible, damaging an enemy or various other actions performed by the player. It lasts a different amount of time depending on the action that started/prolonged it. The cycle can be prolonged if player performs another action while it's already active, resetting the cycle timer.

var total_score = 0

var collected_collectibles = 0 # Collectibles collected in the current level.
var collectibles_in_this_level = 0 # Total collectibles in the current level, counted on entering a level and updated occasionally during gameplay (For instance, when destroying a box containing collectibles).

var collected_goldenApples = 0
var collected_blueApples = 0
var collected_redApples = 0

var player_weaponType = "none"


# Signals:
# Combo streak extenders:
signal itemCollected
signal enemyHit
signal boxBroken
signal specialAction

# These signals are emitted after an action related to the player is performed.
signal shot
signal shot_charged
signal exitReached
signal comboReset
signal scoreReduced
signal scoreReset
signal canStandUp
signal powerUpActivated
signal playerTransformed
signal maxScoreMultiplierReached
signal level_entered
signal level_finished
signal checkpoint_activated

signal weapon_collected
signal secondaryWeapon_collected

# These signals are emitted after an action is performed.
signal save_levelState_saved # Only one level is saved here at a time. Level State refers to objects (and their state) inside of a level and other persistent aspects of it, to be restored when player comes back to an already visited overworld level, or loading a quicksave.
signal save_levelState_loaded
signal save_playerData_saved # Various otherworld player info like health, score, unlocks, etc.
signal save_playerData_loaded
signal save_levelSetProgress_saved # Information about every Level Set in the game.
signal save_levelSetProgress_loaded

# Emitting these signals from anywhere will cause the game to perform an action.
signal player_damage(value)
signal player_kill
signal player_heal(value)

signal save_progress

var quicksaves_enabled = false

var game_is_saving = false


var save_player_position_x = player_position[0]
var save_player_position_y = player_position[1]
var save_level_score = level_score


# Background changes during gameplay.
signal bgChange_trigger_entered
signal bgChange_finished
signal bgMove_trigger_entered

var bg_file_previous = "res://Assets/Graphics/backgrounds/bg_fields.png"
var bg_file_current = "res://Assets/Graphics/backgrounds/bg_fields.png"

var bg_a_file_previous = "res://Assets/Graphics/backgrounds/bg_a_fields.png"
var bg_a_file_current = "res://Assets/Graphics/backgrounds/bg_a_fields.png"

var bg_b_file_previous = "res://Assets/Graphics/backgrounds/bg_b_fields.png"
var bg_b_file_current = "res://Assets/Graphics/backgrounds/bg_b_fields.png"

var bg_offset_target_x = 0
var bg_offset_target_y = 0

var bg_a_offset_target_x = 0
var bg_a_offset_target_y = 0

var bg_b_offset_target_x = 0
var bg_b_offset_target_y= 0


# Debug values displayed on the debug screen.
var test = 0
var test2 = 0
var test3 = 0
var test4 = "none"


# Inventory appears in the bottom left corner of the screen on collecting an active item. Only one can be selected at a time.
var inventory_selectedItem = 1
var inventory_onSpawn_scene = null

# Message sign is an entity that when touched, causes a message box to appear on the screen.
signal sign_message_touched
var sign_message_text = "none"
var sign_message_size = Vector2(0, 0)


# Level Set is the screen where you can select a level to play.
var levelSet_name = "Main Levels"
var levelSet_id = "MAIN"
var levelSet_nextLevel = -1 # This should have a value of the FURTHEST level finished in a Level Set + 1, so the game knows which level is the latest unlocked by the player (All levels up to this one will be unlocked on the Level Set screen).
var level_name = "error"
var level_id = "MAIN_1" # Each level ID follows this naming method: [LEVEL SET ID]_[LEVEL_ID].
var level_number = -1
var level_topRankScore = -1


var mode_scoreAttack = false

var transitioned = false # True if player has left a level through a level transition (overworld areas are connected through transitions). Is set back to False when starting a level, right after the level checks whether to spawn the player at a transition or a checkpoint/start point.
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

# Recording
var recording_autostart = false

signal start_recording
signal start_playback
signal stop_recording
signal stop_playback


var levelSelect = preload("res://Other/Scenes/Level Select/levelSelect_screen.tscn")
var startMenu = preload("res://Other/Scenes/Level Select/levelSelect_screen.tscn")

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
		Overlay.animation("fade_black", false, true, 1)
		get_tree().change_scene_to_packed(startMenu)
		Overlay.animation("fade_black", true, true, 1)
	
	elif Input.is_action_just_pressed("menu"):
		Overlay.animation("fade_black", false, true, 1)
		get_tree().change_scene_to_packed(levelSelect)
		Overlay.animation("fade_black", true, true, 1)
	
	
	elif Input.is_action_pressed("debug_mode"):
		Globals.debug_mode = true
		
		if not get_node_or_null("/root/World"):
			return
		
		#world.player.player_health = 999
		
		if get_node_or_null("/root/World/HUD/Debug Screen"):
			$/root/World/HUD/"Debug Screen"._on_toggle_ambience_pressed()
			$/root/World/HUD/"Debug Screen"._on_toggle_music_pressed()


# Lists (Array) of various entity properties, used for randomization purposes.
# These lists contain word based properties (String).
@onready var list_movementType = ["normal", "followPlayerX", "followPlayerY", "followPlayerXY", "followPlayerX_whenSpotted", "followPlayerY_whenSpotted", "followPlayerXY_whenSpotted", "chasePlayerX", "chasePlayerX_whenSpotted", "chasePlayerY", "chasePlayerY_whenSpotted", "chasePlayerXY", "chasePlayerXY_whenSpotted", "stationary", "wave_H", "wave_V", "moveAround_startPosition_XY_when_notSpotted", "moveAround_startPosition_X_when_notSpotted", "moveAround_startPosition_Y_when_notSpotted"]
@onready var list_movementType_limited = ["normal", "followPlayerX", "wave_H", "wave_V", "moveAround_startPosition_XY_when_notSpotted"]
@onready var list_loop_anim = ["none", "loop_upDown", "loop_upDown_slight", "loop_scale"]
@onready var list_level_ID = ["MAIN_1", "MAIN_2", "MAIN_3", "MAIN_4", "MAIN_5", "MAIN_6", "MAIN_7", "MAIN_8"]
@onready var list_special_apple_type = ["red", "blue", "golden"]
@onready var list_temporary_powerup = ["none", "higher_jump", "increased_speed", "teleport_forward_on_airJump"]
@onready var list_weapon = ["basic", "short_shotDelay", "ice", "fire", "destructive_fast_speed", "veryFast_speed", "phaser"]
@onready var list_secondaryWeapon = ["basic", "fast"]
@onready var list_potion = ["rooster", "bird", "chicken"]

# These lists contain every single entity scene from their respective folders.
# Scenes:
@onready var list_collectible = []
@onready var list_enemy = []
@onready var list_box = []
@onready var list_projectile = []
# Packed animation sets:
@onready var list_sprite_collectible = []
@onready var list_sprite_enemy = []
@onready var list_sprite_box = []
@onready var list_sprite_projectile = []

# Alternative lists with some types of entities excluded (Used when spawning large amounts of said entity type would otherwise cause issues).
@onready var list_onDeath_item_scene = []
@onready var list_onDeath_item_blacklist_enemy_scene = []
@onready var list_onDeath_projectile_scene = []
@onready var list_onDeath_secondaryProjectile_scene = []
@onready var list_onHit_item_scene = []
@onready var list_onHit_item_blacklist_enemy_scene = []
@onready var list_onSpotted_item_scene = []
@onready var list_onSpotted_item_blacklist_enemy_scene = []
@onready var list_onSpotted_projectile_scene = []
@onready var list_onSpotted_secondaryProjectile_scene = []
@onready var list_onTimer_item_scene = []
@onready var list_onTimer_item_blacklist_enemy_scene = []
@onready var list_onTimer_projectile_scene = []
@onready var list_onTimer_secondaryProjectile_scene = []
@onready var list_bonusBox_item_scene = []
@onready var list_bonusBox_item_blacklist_enemy_scene = []


# Text displays:
# Only one message can be displayed at a time. Message display is located in the (global) Overlay node.
var display_message_textQueue : Array = []
signal refresh_info

func message(text, time):
	display_message_textQueue.append([str(text), time])
	Globals.refresh_info.emit()

# Debug display loads in only when this array has any value inside of it. The values will get added to the display's text container one after another, and when there are none to add anymore, it will disappear after a time.
var display_message_debug_textQueue : Array = ["Welcome to the debug display!", "Type in '!help' to see available commands and shortcuts."]

func message_debug(text):
	display_message_debug_textQueue.append(str(text))
	Globals.refresh_info.emit()
