extends Node2D

# REMINDERS [START]

# Pause a function for a time:
# await get_tree().create_timer(1.0, true).timeout
# (time : float, process_always : bool)

# REMINDERS [END]

var World : Node
var Player : Node


# Folder paths (String) for better readability:
const dirpath_saves = "user://saves"
const d_playerData = dirpath_saves + "/playerData"
const d_levelSet = dirpath_saves + "/levelSet"
const d_levelState = dirpath_saves + "/levelState"

const dirpath_assets = "res://Assets"
const dirpath_graphics = dirpath_assets + "/Graphics"
const d_backgrounds = dirpath_graphics + "/backgrounds"
const d_sprites = dirpath_graphics + "/sprites"
const d_tilesets = dirpath_graphics + "/tilesets"

const dirpath_sounds = dirpath_assets + "/Sounds"
const d_music = dirpath_sounds + "/music"
const d_ambience = dirpath_sounds + "/ambience"


# Various lists (String):
const l_levelSet_id : Array = ["MAIN", "BONUS", "DEBUG"]
const l_levelSet_name : Dictionary = {l_levelSet_id[0] : "Main Levels", l_levelSet_id[1] : "Bonus Levels", l_levelSet_id[2] : "Debug Levels"}
const l_difficulty : Array = ["Beginner", "Intermediate", "Advanced", "Expert", "Grandmaster"]

const l_animation_type : Array = ["general", "gear"] # Only includes animations that are suitable for general decorations (with no specific properties like the CanvasLayer node's "offset").
const l_animation_type_all : Array = ["general, gear, ui"]
const l_animation_name_general : Array = ["rotate_around_y_fade_out", "fade_out_up", "loop_scale", "loop_up_down", "loop_up_down_slight", "loop_right_left", "loop_right_left_x2", "loop_right_left_x4", "loop_right_left_x8"]
const l_animation_name_gear : Array = ["rotate", "rotate_back", "rotate_back_in", "rotate_back_in", "rotate_forwardAndBack"]

const l_animation_type_limited : Array = ["general_limited", "gear_limited"]
const l_animation_type_limited_all : Array = ["general_limited", "gear_limited"]
const l_animation_name_general_limited : Array = ["loop_scale", "loop_up_down", "loop_up_down_slight", "loop_right_left", "loop_right_left_x2", "loop_right_left_x4", "loop_right_left_x8"]
const l_animation_name_gear_limited : Array = ["rotate", "rotate_back", "rotate_back_in", "rotate_back_in", "rotate_forwardAndBack"]

# Reusable sentences (String):
const s_levelSet_unlockedBy_portal = "Unlocked by opening a portal hidden somewhere in "
const s_levelSet_unlockedBy_score = "Unlocked by achieving a score of "
const s_levelSet_unlockedBy_level = "Unlocked by finishing "
const s_levelSet_unlockedBy_portal_overworld = s_levelSet_unlockedBy_portal + "the Overworld's "
const s_levelSet_unlockedBy_portal_level = s_levelSet_unlockedBy_portal + "a level called: "
const s_levelSet_unlockedBy_score_overworld = " in the Overworld"
const s_levelSet_unlockedBy_score_level = "in a level called: "
const s_levelSet_unlockedBy_score_levelSet = " combined across all levels in a level set called: "
const s_levelSet_unlockedBy_level_previous = "the previous level."
const s_levelSet_unlockedBy_level_specific = "a level called: "


# Effects and particles:
const scene_particle_star = preload("res://Other/Particles/star.tscn")
const scene_effect_hit_enemy = preload("res://Other/Effects/hit_enemy.tscn")
const scene_effect_dead_enemy = preload("res://Other/Effects/dead_enemy.tscn")
const scene_effect_oneShot_enemy = preload("res://Other/Effects/oneShot_enemy.tscn")
const scene_particle_special = preload("res://Other/Particles/special.tscn")
const scene_particle_special_multiple = preload("res://Other/Particles/special_multiple.tscn")
const scene_particle_special2 = preload("res://Other/Particles/special2.tscn")
const scene_particle_special2_multiple = preload("res://Other/Particles/special2_multiple.tscn")
const scene_particle_splash = preload("res://Other/Particles/splash.tscn")
const scene_particle_feather_multiple = preload("res://Other/Particles/feather.tscn")
const scene_effect_dust = preload("res://Other/Effects/dust.tscn")
const scene_particle_score = preload("res://Other/Particles/score.tscn")


# Sound effects:
var sfx_player_jump = load("res://Assets/Sounds/sfx/jump.wav")
var sfx_player_wall_jump = load("res://Assets/Sounds/sfx/jump.wav")
var sfx_player_shoot = load("res://Assets/Sounds/sfx/projectile_shoot.wav")
var sfx_player_damage = load("res://Assets/Sounds/sfx/robot_damage.wav")
var sfx_player_death = load("res://Assets/Sounds/sfx/rabbit_death.wav")
var sfx_player_heal = load("res://Assets/Sounds/sfx/heal.wav")
var sfx_collect = load("res://Assets/Sounds/sfx/collect.wav")
var sfx_mechanical = load("res://Assets/Sounds/sfx/mechanical.wav")
var sfx_mechanical2 = load("res://Assets/Sounds/sfx/mechanical2.wav")
var sfx_mechanical3 = load("res://Assets/Sounds/sfx/mechanical3.wav")
var sfx_powerUp = load("res://Assets/Sounds/sfx/powerUp.wav")
var sfx_powerUp2 = load("res://Assets/Sounds/sfx/powerUp2.wav")


# Other files:
const material_rainbow = preload("res://Other/Materials/rainbow.tres")
const material_rainbow2 = preload("res://Other/Materials/rainbow2.tres")
const material_rainbow2_slowSlight = preload("res://Other/Materials/rainbow2_slowSlight.tres")
const material_player_rainbow = preload("res://Other/Materials/player_rainbow.tres")
const material_wave1 = preload("res://Other/Materials/wave1.tres")
const material_wave2 = preload("res://Other/Materials/wave2.tres")
const material_wave3 = preload("res://Other/Materials/wave3.tres")
const material_godrays = preload("res://Other/Materials/godrays.tres")
const material_hueShift = preload("res://Other/Materials/hueShift.tres")
const material_cycle_darkBlue_purple = preload("res://Other/Materials/cycle_darkBlue_purple.tres")
const material_cycle_yellow_orange = preload("res://Other/Materials/cycle_yellow_orange.tres")
const material_neon_hueShift = preload("res://Other/Materials/neon_hueShift.tres")


# Main scenes:
const scene_start_screen = preload("res://Other/Scenes/start_screen.tscn")
const scene_levelSet_screen = preload("res://Other/Scenes/Level Set/levelSet_screen.tscn")


# Other scenes:
const scene_portal = preload("res://Objects/shrine_portal.tscn")
const scene_debug_message = preload("res://Other/Scenes/User Interface/Debug/debug_message.tscn")
const scene_levelSet_display_level_info = preload("res://Other/Scenes/Level Set/levelSet_display_level_info.tscn")
const scene_levelSet_level_icon = preload("res://Other/Scenes/Level Set/levelSet_level_icon.tscn")
const scene_text_manager = preload("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn")
const scene_text_manager_character = preload("res://Other/Scenes/User Interface/Text Manager/character.tscn")
const scene_decoration_core = preload("res://Other/Scenes/decoration_core.tscn")
const scene_gear = preload("res://Objects/Decorations/gear.tscn")
const scene_gear2 = preload("res://Objects/Decorations/gear2.tscn")
const scene_gear3 = preload("res://Objects/Decorations/gear3.tscn")
const scene_gear4 = preload("res://Objects/Decorations/gear4.tscn")
const scene_gear5 = preload("res://Objects/Decorations/gear5.tscn")
var scene_UI_button_general = load("res://Other/Scenes/User Interface/General/UI_button_general.tscn")
var scene_UI_button_general_decoration_right_round = load("res://Other/Scenes/User Interface/General/UI_button_general_decoration_right_round.tscn")
var scene_UI_button_general_decoration_right_slope = load("res://Other/Scenes/User Interface/General/UI_button_general_decoration_right_slope.tscn")
const scene_animation_general = preload("res://Other/Scenes/animation_general.tscn")
const scene_animation_gear = preload("res://Other/Scenes/animation_gear.tscn")
var scene_menu_main = load("res://Other/Scenes/User Interface/Menus/menu_main.tscn")
var scene_menu_settings = load("res://Other/Scenes/User Interface/Menus/menu_settings.tscn")
var scene_menu_select_levelSet = load("res://Other/Scenes/User Interface/Menus/menu_select_levelSet.tscn")

const scene_start_area = preload("res://Levels/overworld_factory.tscn")


# Various lists (General):
# Note: This section needs to be at the bottom because it creates references to many variables, and needs them all to be ready at the time of its turn.
var l_sfx_menu_stabilize : Array = [sfx_mechanical, sfx_mechanical2, sfx_mechanical2, sfx_powerUp, sfx_powerUp2]


func _ready() -> void:
	gameState_changed.connect(on_gameState_changed)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	reassign_general()

func _physics_process(_delta):
	handle_actions() # Handles global functions executed on triggering an action.
	get_mouse_position()


func handle_actions():
	if Input.is_action_just_pressed("menu_start_screen"):
		change_main_scene(scene_start_screen)
	
	elif Input.is_action_just_pressed("menu_levelSet_screen"):
		change_main_scene(scene_levelSet_screen)
	
	if Input.is_action_just_pressed("menu"):
		handle_spawn_menu(gameState_debug, gameState_level, gameState_levelSet_screen, gameState_start_screen)
	
	if Input.is_action_just_pressed("pause"):
		handle_pause()
	
	
	elif Input.is_action_just_pressed("debug_console"):
		if Globals.debug_mode == false:
			Globals.debug_mode = true
			Globals.message_debug("Debug mode is active.")
		elif Globals.debug_mode == true:
			Globals.debug_mode = false
			Globals.message_debug("Debug mode is disabled.")
		
		if get_node_or_null("/root/World"): # Execute only if a level is currently loaded.
			World.player_health = 999
	
	handle_debug_actions()


func reassign_general():
	if has_node("/root/World") : World = $/root/World
	if has_node("/root/World/Player") : Player = $/root/World/Player
	
	return [World, Player]
	
	window_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))


func change_main_scene(scene, instant : bool = false, anim_name : String = "black_fade_in"):
	if debug_mode : anim_name = "none" ; instant = true
	Globals.message_debug("Changing the Main Scene to %s" % scene)
	
	if anim_name != "none" : Overlay.animation(anim_name, 1.0, false, opposite_bool(instant))
	get_tree().change_scene_to_packed(scene)


# Important gameplay-related properties.

# Player:
var player_health = 100

var player_position = Vector2(0, 0)
var player_velocity = Vector2(0, 0)

var player_direction_x = 0 # Only horizontal.
var player_direction_x_active = 1 # Can never be equal to 0 (standing still).
var player_direction_y = 0 # Only vertical.
var player_direction_y_active = -1 # Can never be equal to 0 (floating in place).

# Score:
var level_score = 0 # Current level's score.
var score_multiplier = 1 # Main score multiplier, increased by means other than the combo system. It affects both combo score as well as the actual score.
var combo_score = 0
var combo_streak = 0 # Combo starts on collecting a collectible, damaging an enemy or various other actions performed by the player. It lasts a different amount of time depending on the action that started/prolonged it. The combo can be prolonged if player performs another action while it's already active, resetting the combo timer.
var combo_tier = 1
var combo_multiplier = 1 # Increases by 1 every 5 collectibles collected (or other specific actions performed) by the player during a combo, up to 10. (x1 during 1-5, x2 during 6-10, x3 during 11-15, x4 during 16-20, x5 during 21-25, x6 during 26-30, x7 during 31-35, x8 during 36-40, x9 during 41-45, and finally x10 during 46-50. The final - x11

var total_score = 0 # Current save slot's total score, combined across all overworld segments and all of the overworld's level set levels.

var collected_collectibles = 0 # Collectibles collected in the current level.
var collected_majorCollectibles_module = 0
var collected_majorCollectibles_key = 0
var killed_enemies = 0

var total_collectibles_in_currentLevel = 0 # Total collectibles in the current level, counted on entering a level and updated occasionally during gameplay (for instance, when destroying a box containing collectibles).
var total_majorCollectibles_module_in_currentLevel = 0
var total_majorCollectibles_key_in_currentLevel = 0
var total_enemies_in_currentLevel = 0

var player_weaponType = "none"

var gravity = 1.0

var level_time = 0.0


# Signals:
# Combo streak extenders:
signal combo_refreshed(time)

signal entity_collected # 2 seconds.
signal entity_hit # 0.5 seconds.
signal entity_killed # 6 seconds. Should not apply if the death is a box being broken.

# These signals are emitted after an action related to the player is performed.
signal projectile_shot
signal projectile_charged
signal checkpoint_activated
signal exit_activated
signal powerUp_activated
signal transformation_activated
signal combo_reset
signal combo_reduced
signal score_reset
signal score_reduced
signal can_standUp # Used in the player dash logic.
signal max_scoreMultiplier_reached
signal max_score_reached
signal level_started
signal level_finished

signal collected_weapon
signal collected_secondary

# These signals are emitted after an action is performed.
signal HUD_update_general
signal levelState_saved # Only one level is saved here at a time. Level State refers to objects (and their state) inside of a level and other persistent aspects of it, to be restored when player comes back to an already visited overworld level, or loading a quicksave.
signal levelState_loaded
signal playerData_saved # Various otherworld player info like health, score, unlocks, etc.
signal playerData_loaded
signal levelSet_saved # Information about every Level Set in the game.
signal levelSet_loaded

# Emitting these signals from anywhere will cause the game to perform an action.
signal player_damage(value)
signal player_kill
signal player_heal(value)
signal update_player_health

signal save_playerData
signal save_levelSet(levelSet_name)
signal save_levelState(levelState_name)

signal quicksave(slot_number : int)
signal quickload(slot_number : int)

signal play_music_random

signal gameState_changed

var settings_quicksaves = false
var settings_volume_music = 0.2
var settings_volume_sfx = 0.6

var save_player_position_x = player_position[0]
var save_player_position_y = player_position[1]
var save_level_score = level_score


# Background changes during gameplay.
signal trigger_bg_change_entered
signal trigger_bg_move_entered
signal bg_change_finished

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


# Main scene refers to the current root scene (the parent node at the top of the node tree).
@onready var mainScene = get_parent()
@onready var mainScene_name = mainScene.name
@onready var mainScene_filePath = mainScene.scene_file_path

# World states:
var worldState_justStartedNewGame = false
var worldState_leftStartArea = false

# Game states:
var gameState_level = false
var gameState_levelSet_screen = false
var gameState_start_screen = false

var gameState_debug = true


# Sound effects manager should be the main way used to play short sounds. Note that each entity has its own sound manager, and that the world node has a single music manager, as well as one ambience manager.
# Use this signal to request a global sound effect to be played. For entities, call each entity's local "sfx_play(file, volume, pitch, fade)" function when you want it to play one or multiple sound effects.
signal sfx(file, volume, pitch)
signal sfx_combined(file1, volume1, pitch1, file2, volume2, pitch2, file3, volume3, pitch3, file4, volume4, pitch4) # Use this signal to create a global "combined" sound effect (see the sfx manager's "sfx_combined_play(file1, volume1, pitch1, fade1, file2, pitch2, etc.)" function to see how it's created.


# Inventory appears in the bottom left corner of the screen on collecting an active item. Only one can be selected at a time.
var inventory_selected = 1
var inventory_item_scene = null
var inventory_item_icon = null


# Message sign is an entity that when touched, causes a message box to appear on the screen.
signal sign_message_touched
var sign_message_text = "none"


# Level Set is the screen where you can select a level to play.
var levelSet_name = "Main Levels"
var levelSet_id = "MAIN"
var levelSet_nextLevel = -1 # This should have a value of the FURTHEST level finished in a Level Set + 1, so the game knows which level is the latest unlocked by the player (All levels up to this one will be unlocked on the Level Set screen).
var level_name = "none"
var level_id = "MAIN_1" # Each level ID follows this naming method: [LEVEL SET ID]_[LEVEL_ID].
var level_number = 1
var level_topRankScore = -1


# Game modes:
var mode_scoreAttack = false


# Transition refers to a trigger that is usually placed at the borders of overworld levels to connect them. Note that the transition trigger needs to be named %"Transition[id]", and its id (int) has to match the id of the transition placed in another overworld level.
var transition_triggered = false # True if player has just left a level through a level transition (overworld areas are connected through transitions). The value is set back to false when starting a level, right after the level checks whether to spawn the player at a transition or a checkpoint/start point.
var transition_next = 0 # The player will be placed at the transition with this id (%"Transition[id]").
var transition_offset = Vector2(0, 0) # Spawn position offset.


# Debug:
var debug_mode = false

var debug_magicProjectiles = false
var debug_deleteSaves = false

# Debug values displayed on the debug screen.
var test
var test2
var test3
var test4


# Recording:
var recording_autostart = false

signal start_recording
signal start_playback
signal stop_recording
signal stop_playback


# Text displays:
# Only one message can be displayed at a time. Message display is located in the (global) Overlay node.
var display_messages_queued : Array = []
signal messages_refresh # Forces all message displays to refresh when emitted.
signal messages_added
signal messages_removed
signal messages_debug_added
signal messages_debug_removed

func message(text):
	display_messages_queued.append(str(text))
	messages_added.emit() # This is a signal from this script (Globals.gd).

# Debug display loads in only when this array has any value inside of it. The values will get added to the display's text container one after another, and when there are none to add anymore, it will disappear after a time.
@onready var display_messages_debug_queued : Array = ["Welcome to the debug message display!", "All debug messages will be shown here for a while, as well as printed to the console."]

func message_debug(text, importance : int = 0):
	display_messages_debug_queued.append(str(text) + str("[%s]" % importance))
	Globals.messages_debug_added.emit()


# Lists (Array) of various entity properties, used for randomization purposes.
# These lists contain word based properties (String).
const l_entity_movement = ["stationary", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_X", "wave_Y", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted"]
const l_entity_movement_limited = ["stationary", "move_x", "follow_player_x", "wave_X", "move_around_startPosition_xy_if_not_spotted"]
const l_loop_anim = ["none", "loop_upDown", "loop_upDown_slight", "loop_scale"]
const l_level_id = ["MAIN_1", "MAIN_2", "MAIN_3", "MAIN_4", "MAIN_5", "MAIN_6", "MAIN_7", "MAIN_8"]
const l_majorCollectible = ["red", "blue", "golden"]
const list_temporary_powerUp = ["none", "higher_jump", "increased_speed", "teleport_forward_on_airJump"]

#@onready var list_weapon = ["basic", "short_shotDelay", "ice", "fire", "destructive_fast_speed", "veryFast_speed", "phaser"]
#@onready var list_secondaryWeapon = ["basic", "fast"]
#@onready var list_potion = ["rooster", "bird", "chicken"]

# These lists contain every single entity scene from their respective folders.
# Scenes:
@onready var l_collectible = []
@onready var l_enemy = []
@onready var l_box = []
@onready var l_projectile = []
# Packed animation sets:
@onready var l_sprite_collectible = []
@onready var l_sprite_enemy = []
@onready var l_sprite_box = []
@onready var l_sprite_projectile = []

# Alternative lists with some types of entities excluded (Used when spawning large amounts of said entity type would otherwise cause issues).
@onready var l_onDeath_item_scene = []
@onready var l_onDeath_item_blacklist_enemy_scene = []
@onready var l_onDeath_projectile_scene = []
@onready var l_onDeath_secondaryProjectile_scene = []
@onready var l_onHit_item_scene = []
@onready var l_onHit_item_blacklist_enemy_scene = []
@onready var l_onSpotted_item_scene = []
@onready var l_onSpotted_item_blacklist_enemy_scene = []
@onready var l_onSpotted_projectile_scene = []
@onready var l_onSpotted_secondaryProjectile_scene = []
@onready var l_onTimer_item_scene = []
@onready var l_onTimer_item_blacklist_enemy_scene = []
@onready var l_onTimer_projectile_scene = []
@onready var l_onTimer_secondaryProjectile_scene = []
@onready var l_bonusBox_item_scene = []
@onready var l_bonusBox_item_blacklist_enemy_scene = []


func spawn_scenes(target : Node, file, quantity : int = 1, pos_offset : Vector2 = Vector2(0, 0), remove_cooldown : float = -1, add_modulate : Color = Color(0, 0, 0, 0), add_scale : Vector2 = Vector2(0, 0), add_z_index : int = 0, add_properties_name : Array = ["position"], add_properties_value : Array = [Vector2(0, 0)]): # Quantity of -1 will randomize the number of spawned scenes.
	var spawned_nodes : Array
	
	for x in range(quantity):
		var node = file.instantiate()
		node.position += pos_offset
		print(node.position)
		node.modulate += add_modulate
		node.scale += add_scale
		node.z_index += add_z_index
		
		var y = -1
		for p_name in add_properties_name:
			y += 1
			
			#var add_property : Dictionary = {add_properties_name[y] : add_properties_value[y]}
			node.set(add_properties_name[y], add_properties_value[y])
		
		target.add_child(node)
		
		spawned_nodes.append(node)
	
	if remove_cooldown != -1:
		
		await get_tree().create_timer(remove_cooldown, true).timeout
		
		for node in spawned_nodes:
			if node:
				node.queue_free()


func anim_glow(target : Node, material, duration):
	var tween1 = Tween
	var tween2 = Tween
	var tween3 = Tween
	var tween4 = Tween
	
	var random_scale = randi_range(0.25, 2)
	
	target.material = material
	
	tween1 = get_tree().create_tween().bind_node(target).set_trans(Tween.TRANS_LINEAR)
	tween2 = get_tree().create_tween().bind_node(target).set_trans(Tween.TRANS_BACK)
	tween3 = get_tree().create_tween().bind_node(target).set_trans(Tween.TRANS_SPRING)
	tween4 = get_tree().create_tween().bind_node(target).set_trans(Tween.TRANS_LINEAR)

	tween1.tween_property(target, "position:x", randi_range(-2000, 2000), randf_range(2, 4))
	tween2.tween_property(target, "position:y", randi_range(1000, 2000), randf_range(1.5, 3))
	tween3.tween_property(target, "rotation_degrees", randi_range(-720, 720), randf_range(1, 2))
	tween4.tween_property(target, "scale", Vector2(random_scale, random_scale), randf_range(1, 2))
	tween1.tween_property(target, "visible", false, 0)


func wait(time : float): # Not working for some reason.
	await get_tree().create_timer(time, true).timeout


var mouse_pos = Vector2(0, 0)

func get_mouse_position():
	mouse_pos = get_global_mouse_position()


func list_files_in_dirpath(directory_path : String, exclude : Array):
	var dir_path = "res://" + directory_path
	var dir = DirAccess.open(dir_path)
	var list = []
	
	if dir != null:
		var filenames = dir.get_files()
		
		for filename in filenames:
			if not filename.ends_with(".import") and not filename.ends_with(".gd") and not filename.ends_with(".uid"):
				list.append(dir_path + "/" + filename)
		
		var count = -1
		for exclusion in exclude:
			count += 1
			for filename in list:
				if filename.contains(exclude[count]):
					list.erase(filename)
	
	return list


# General tools - [START]

func random_bool(false_probability, true_probability):
	var randomized_number = randf_range(-false_probability, true_probability)
	if randomized_number <= 0 : return false
	else : return true

func opposite_bool(start_bool):
	if start_bool:
		return false
	else:
		return true

# Below function is useless as its a repeat of "pick_random()".
func random_from_list(list_name, list_length): #list length of -1 will include everything.
	var list = get(str(list_name))
	var randomized_ID : int
	
	if list_length != -1:
		randomized_ID = randi_range(0, list_length)
	else:
		randomized_ID = randi_range(0, len(list) - 1)
	
	var randomized_property = list[randomized_ID]
	return randomized_property

# General tools - [END]


func handle_debug_actions():
	if debug_mode:
		for x in range(1, 5): # Should eventually be 10 (which doesn't include the last - "10" value).
			if Input.is_action_just_pressed(str(x)):
				call("on_action_%s" % x)
				Globals.message_debug("Pressed %s while debug mode is active. Executing assigned debug function..." % x)

signal debug1
signal debug2
signal debug3
signal debug4

func on_action_1():
	debug1.emit()

func on_action_2():
	debug2.emit()

func on_action_3():
	debug3.emit()

func on_action_4():
	debug4.emit()


@onready var window_size : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))


func handle_pause():
	if get_tree().paused == false:
		get_tree().paused = true
		Globals.message_debug("Game paused.")
	elif get_tree().paused == true:
		get_tree().paused = false
		Globals.message_debug("Game resumed.")


func spawn_menu(menu_scene = scene_menu_main, l_disable_buttons : Array = ["none"], add_position : Vector2 = window_size * 0, button_size_multiplier : Vector2 = Vector2(1, 1)):
	spawn_scenes(Overlay, menu_scene, 1, add_position, -1, Color(0, 0, 0, 0), Vector2(0, 0), 0, ["l_disable_buttons", "button_size_multiplier"], [l_disable_buttons, button_size_multiplier])

func handle_spawn_menu(p_gameState_debug : bool = true, p_gameState_level : bool = false, p_gameState_levelSet_screen : bool = false, p_gameState_start_screen : bool = false): # The "p" stands for "passed".
	for menu in get_tree().get_nodes_in_group("menu_main") : menu.queue_free()
	
	if p_gameState_debug and debug_mode:
		spawn_menu()
		return
	
	if p_gameState_level:
		spawn_menu()
	elif p_gameState_levelSet_screen:
		spawn_menu(scene_menu_main, ["Start New Game", "Continue", "Resume game", "Level Set screen", "Select Level Set", "Quit Game"], Vector2(window_size.x / -3.5, window_size.y / 3), Vector2(0.75, 0.75))
	elif p_gameState_start_screen:
		spawn_menu(scene_menu_main, ["Resume Game", "Select Set screen", "Quit to Main Menu"])


func on_gameState_changed():
	handle_spawn_menu(gameState_debug, gameState_level, gameState_levelSet_screen, gameState_start_screen)
