extends Button

@onready var icon_main: Sprite2D = %icon_main
@onready var decoration_glow: Sprite2D = %decoration_glow
@onready var icon_state_finished: Sprite2D = %icon_state_finished
@onready var icon_state_all_major_collectibles: Sprite2D = %icon_state_allMajorCollectibles
@onready var icon_state_all_collectibles: Sprite2D = %icon_state_allCollectibles
@onready var icon_rank: Sprite2D = $icon_rank

@onready var screen_levelSet = get_parent().get_parent()
@onready var container_level_button = get_parent()


@export var icon_image_id = 0
@export var icon_position = Vector2(0, 0)
@export var icon_level_filepath : String

var level_saved = SaveData.default_saved_level # The saved (in the "SaveData" global node, and the "levelSet" save files) array of best results for each category achieved by the player.
var level_info = SaveData.default_info_level
var level_unlock = SaveData.default_unlock_level
var level_major_collectibles = SaveData.default_collectibles_level

var levelSet_id = "none"

var level_number = 0
var level_id = "none" # Example: "MAIN_1".

var level_state = -1
var level_score = -1
var level_score_target = -1
var level_time = -1
var level_time_target = -1
var level_rank = "none"
var level_rank_value = -1
var level_name = "none"
var level_type = "none"
var level_creator = "none"
var level_message = "none"
var level_difficulty = "none"

var level_icon_id = 0
var level_icon_position_x = 0
var level_icon_position_y = 0

var level_unlockMethod_previous = true
var level_unlockMethod_portal_in_level_id = "none"
var level_unlockMethod_key_in_level_id = "none"
var level_unlockMethod_score_in_level_id = "none"
var level_unlockMethod_score_in_levelSet_id = "none"
var level_unlockMethod_score_in_overworld_levelSet_id = "none"
var level_unlockMethod_time_in_level_id = "none"
var level_unlockMethod_time_in_levelSet_id = "none"

var level_saved_major_collectibles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var level_info_major_collectibles = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # Each value represents a major collectible SLOT, which should always match a major collectible placed in the matching level.

var unlocked = false

var level_missing : bool = false # Whether the level filepath points to a missing file.


func _ready():
	if level_number == -1:
		level_name = icon_level_filepath
		position = Vector2(randi_range(-800, 800), randi_range(-400, 400))
		level_icon_id = randi_range(0, 10)
		if is_instance_valid(icon_main) : icon_main.region_rect = Rect2(128 * level_icon_id, 640, 128, 128)
		%AnimationPlayer.advance((abs(position.x) / 100))
		Globals.spawn_message_object(icon_level_filepath.replace("res://Levels/", ""), 0.5, self, Vector2(200, 0), Vector2(-0.5, -0.5))
		if "TUTORIAL" in icon_level_filepath : modulate = Color.PINK
		elif "MAIN" in icon_level_filepath : modulate = Color.BLUE
		elif "BONUS" in icon_level_filepath : modulate = Color.PURPLE
		elif "DEBUG" in icon_level_filepath : modulate = Color.GOLD
		return
	
	await get_tree().create_timer(0.5, true).timeout
	
	update_level_info()
	
	icon_level_filepath = "res://Levels/" + level_id + ".tscn"
	
	position = Vector2(level_icon_position_x, level_icon_position_y)
	
	if level_state > -1 : unlocked = true
	
	elif SaveData.get("unlock_" + level_id)[0] and level_number == 1:
		if level_state == -1 : level_state = 0
		unlocked = true
	
	# If every single unlock condition is disabled, the level is unlocked automatically.
	elif not SaveData.get("unlock_" + level_id)[0]:
		
		var unlock_level : bool = true
		
		for x in SaveData.get("unlock_" + level_id):
			if x is bool:
				if not x : continue
				else : unlock_level = false
			
			elif x is String:
				if x == "none" : continue
				else : unlock_level = false
		
		if unlock_level : unlocked = true
	
	position = icon_position
	if is_instance_valid(icon_main) : icon_main.region_rect = Rect2(128 * level_number, 640, 128, 128)
	%AnimationPlayer.advance((abs(position.x) / 100))
	
	position = Vector2(level_icon_position_x, level_icon_position_y)
	
	if level_state == 0:
		pass
	elif level_state == 1:
		%icon_state_finished.visible = true
	elif level_state == 2:
		%icon_state_allMajorCollectibles.visible = true
	elif level_state == 3:
		%icon_state_allCollectibles.visible = true
	
	if level_state > 0:
		modulate = Color.GREEN
	elif level_state == -1:
		modulate = Color.DARK_RED
	
	await get_tree().create_timer(randf_range(0.5, 2), true).timeout
	
	if not FileAccess.file_exists(icon_level_filepath):
		Globals.spawn_scenes(container_level_button, Globals.scene_particle_special, 3, position + size / 2)
		Globals.spawn_scenes(container_level_button, Globals.scene_effect_oneShot_enemy, 1, position + size / 2)
		
		var error_message = load("res://Other/Scenes/message_object.tscn").instantiate()
		error_message.position = position
		error_message.add_position = Vector2(randi_range(-64, 64), randi_range(-128, 128))
		error_message.message_text = "This level doesn't exist."
		container_level_button.add_child(error_message)
		
		queue_free()

func _physics_process(delta: float) -> void:
	if level_missing:
		scale = scale.move_toward(Vector2(0, 0), delta)

func _on_pressed():
	if unlocked or Globals.debug_mode or Globals.gameState_debug:
		if FileAccess.file_exists(icon_level_filepath):
			%sfx_start.play()
			Globals.transition_next = 0
			Globals.level_id = level_id
			Globals.levelSet_id = levelSet_id
			Globals.change_main_scene(icon_level_filepath)
		
		else:
			%sfx_locked.play()
			Globals.message("The selected level doesn't exist. bummer! try other ones cause i had to abandon random ones due to some being more tied to stuff removed/remade during the major refactor. gotta rebuild them from scratch later ig")
	
	else:
		%sfx_locked.play()


func _on_focus_entered():
	%level_icon.scale = Vector2(1.1, 1.1)
	
	if unlocked:
		modulate.b = 0.5
	else:
		modulate.b = 0.3
		modulate.g = 0.3
		
	%glow_root.modulate.a = 0.5
	
	get_parent().get_node("%level_info_container").visible = true
	update_level_info()

func _on_focus_exited():
	%level_icon.scale = Vector2(1.0, 1.0)
	modulate.b = 1.0
	modulate.g = 1.0
	%glow_root.modulate.a = 1.0


func _on_mouse_entered():
	if is_instance_valid(icon_main) : icon_main.scale = Vector2(0.6, 0.6)
	
	if unlocked:
		modulate = Color.GOLD
		Globals.message("This level is unlocked.")
	else:
		modulate = Color.DARK_RED
		Globals.message("This level is locked.")
	
	%decoration_glow.modulate.a = 0.5
	
	update_level_info()
	show_display_level_info()

func _on_mouse_exited():
	if is_instance_valid(icon_main) : icon_main.scale = Vector2(0.5, 0.5)
	
	if unlocked:
		modulate = Color.WHITE
		Globals.message("This level is unlocked.")
	else:
		modulate = Color.INDIAN_RED
		Globals.message("This level is locked.")
	
	%decoration_glow.modulate.a = 1.0
	
	if screen_levelSet.has_node("display_level_info"):
		for display in get_tree().get_nodes_in_group("levelSet_display"):
			display.queue_free()
			Globals.message_debug("Display removed.")
	else:
		Globals.message_debug("No level display to remove.")


func update_level_info():
	if Globals.levelSet_id == "none" : return
	if level_number == -1 : return
	
	levelSet_id = Globals.levelSet_id
	level_id = levelSet_id + "_" + str(level_number)
	
	level_saved = SaveData.get("saved_" + level_id)
	level_info = SaveData.get("info_" + level_id)
	level_unlock = SaveData.get("unlock_" + level_id)
	level_major_collectibles = SaveData.get("collectibles_" + level_id)
	
	# saved : [state, score, time, major_collectibles]
	# info : [name, icon_id, icon_position_x, icon_position_y, score_target, time_target, creator, message, difficulty, type]
	# unlock : [previous, portal_in_level_id, key_in_level_id, score_in_level_id, score_in_levelSet_id, score_in_overworld_levelSet_id, time_in_level_id, time_in_levelSet_id]
	# collectibles : [[slot 1 - major collectible exists in a level], [slot 2 - major collectible exists in a level], etc.]
	
	level_state = level_saved[0]
	level_score = level_saved[1]
	level_time = level_saved[2]
	level_saved_major_collectibles = level_saved[3]
	
	level_name = level_info[0]
	level_icon_id = level_info[1]
	level_icon_position_x = level_info[2]
	level_icon_position_y = level_info[3]
	level_score_target = level_info[4]
	level_time_target = level_info[5]
	level_creator = level_info[6]
	level_message = level_info[7]
	level_difficulty = level_info[8]
	level_type = level_info[9]
	
	level_unlockMethod_previous = level_unlock[0]
	level_unlockMethod_portal_in_level_id = level_unlock[1]
	level_unlockMethod_key_in_level_id = level_unlock[2]
	level_unlockMethod_score_in_level_id = level_unlock[3]
	level_unlockMethod_score_in_levelSet_id = level_unlock[4]
	level_unlockMethod_score_in_overworld_levelSet_id = level_unlock[5]
	level_unlockMethod_time_in_level_id = level_unlock[6]
	level_unlockMethod_time_in_levelSet_id = level_unlock[7]
	
	level_info_major_collectibles = level_major_collectibles
	
	var level_rank_info = SaveData.calculate_rank_level(level_id)
	level_rank = level_rank_info[0]
	level_rank_value = level_rank_info[1]

func show_display_level_info():
	var display_level_info = Globals.scene_levelSet_display_level_info.instantiate()
	
	display_level_info.levelSet_id = levelSet_id
	display_level_info.level_id = level_id
	
	display_level_info.level_state = level_state
	display_level_info.level_score = level_score
	display_level_info.level_time = level_time
	display_level_info.level_saved_major_collectibles = level_saved_major_collectibles
	
	display_level_info.level_name = level_name
	display_level_info.level_icon_id = level_icon_id
	display_level_info.level_icon_position_x = level_icon_position_x
	display_level_info.level_icon_position_y = level_icon_position_y
	display_level_info.level_score_target = level_score_target
	display_level_info.level_time_target = level_time_target
	display_level_info.level_creator = level_creator
	display_level_info.level_message = level_message
	display_level_info.level_difficulty = level_difficulty
	display_level_info.level_type = level_type
	
	display_level_info.level_unlockMethod_previous = level_unlockMethod_previous
	display_level_info.level_unlockMethod_portal_in_level_id = level_unlockMethod_portal_in_level_id
	display_level_info.level_unlockMethod_key_in_level_id = level_unlockMethod_key_in_level_id
	display_level_info.level_unlockMethod_score_in_level_id = level_unlockMethod_score_in_level_id
	display_level_info.level_unlockMethod_score_in_levelSet_id = level_unlockMethod_score_in_level_id
	display_level_info.level_unlockMethod_score_in_overworld_levelSet_id = level_unlockMethod_score_in_overworld_levelSet_id
	display_level_info.level_unlockMethod_time_in_level_id = level_unlockMethod_time_in_level_id
	display_level_info.level_unlockMethod_time_in_levelSet_id = level_unlockMethod_time_in_levelSet_id
	
	display_level_info.level_info_major_collectibles = level_info_major_collectibles
	
	display_level_info.level_rank = level_rank
	display_level_info.level_rank_value = level_rank_value
	
	screen_levelSet.add_child(display_level_info)
	Globals.message_debug("Display added.")
