extends Node2D

var state_empty = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# Level Info:
# States: -1 - Locked. 0 - Unfinished. 1 - Finished. 2 - All major collectibles collected. 3 - All collectibles collected.

# Main Levels.
var state_MAIN_1 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # [state, score, time, major_collectibles] Note: Values in major_collectibles represent: 0 - Not collected. 1 - Collected. / hopefully get_nodes_in_group() gets the nodes in a consistent order, otherwise this will be hard to get right without hardcoding... delete this _on_i_told_you_so() /
var state_MAIN_2 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_MAIN_3 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_MAIN_4 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_MAIN_5 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_MAIN_6 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_MAIN_7 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

#var score_MAIN_1 = 0
#var score_MAIN_2 = 0
#var score_MAIN_3 = 0
#var score_MAIN_4 = 0
#var score_MAIN_5 = 0
#var score_MAIN_6 = 0
#var score_MAIN_7 = 0

var state_MAIN = [true] # [(-1 - locked, 0 - unfinished, 1 - finished, 2 - all major collectibles collected, 3 - all collectibles collected), (0 - some levels are not finished so no score rank, 1 - all levels are finished and the lowest possible overall score rank is: F-, 2 - overall score rank: F, 3 - osr: F+, 4 - E-, 5 - E, 6 - E+, 7 - D-, 8 - D, 9 - D+, 10 - C-, 11 - C, 12 - C+, 13 - B-, 14 - B, 15 - B+, 16 - A-, 17 - A, 18 - A+, 19 - S-, 20 - S, 21 - S+), (0 - some levels are not finished so no time rank, 1 - all levels are finished and the lowest possible overall time rank is: F-, 2 - overall time rank: F, 3 - otr: F+, 4 - E-, 5 - E, 6 - E+, 7 - D-, 8 - D, 9 - D+, 10 - C-, 11 - C, 12 - C+, 13 - B-, 14 - B, 15 - B+, 16 - A-, 17 - A, 18 - A+, 19 - S-, 20 - S, 21 - S+)]

# Bonus Levels.
var state_BONUS_1 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_BONUS_2 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_BONUS_3 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_BONUS_4 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_BONUS_5 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_BONUS_6 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var state_BONUS_7 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

#var score_BONUS_1 = 0
#var score_BONUS_2 = 0
#var score_BONUS_3 = 0
#var score_BONUS_4 = 0
#var score_BONUS_5 = 0
#var score_BONUS_6 = 0
#var score_BONUS_7 = 0

var total_score_BONUS = 0
var next_BONUS = 1


# Level information (static):

# info_[levelSet_id] : [levelSet_name, levelSet_background_filepath, levelSet_decoration_filepath, level_quantity, level_author, unlockMethod_levelSet_previous, unlockMethod_key_in_overworld, unlockMethod_key_in_level, unlockMethod_score_in_overworld, unlockMethod_score_in_level, unlockMethod_score_in_levelSet] Note: Set an unlock method to "none" if it should be ignored. If all are set to "none", the level set will be unlocked from the start.
# info_[levelSet_id]_[level_number] : [name, icon_id, icon_position_x, icon_position_y, difficulty, author, score_target, time_target, unlockMethod_level_previous, unlockMethod_portal_in_overworld_level_id, unlockMethod_portal_in_level_level_id, unlockMethod_score_in_overworld_level_id, unlockMethod_score_in_level_level_id, unlockMethod_score_in_levelSet_levelSet_id, unlock_score_level, unlock_score_levelSet, unlock_time_level, unlock_time_levelSet]
# Note that the values (int) in major_collectibles here represent: 0 - Leave this major collectible spot empty. 1 - Assign a major collectible to this spot of the level.


# Main Levels.
var info_MAIN = ["Main Levels", Globals.d_backgrounds + "/bg_levelSet_MAIN.png", "res://Other/Scenes/Level Set/levelSet_decoration_MAIN.tscn", 12, "none", "Pawlogates", false, false, false, false, false, false]

var info_MAIN_1 = ["Training Tunnel", 0, -460, 40, 180000, 60, "Pawlogates", "beginner"]
var info_MAIN_2 = ["Valley of Vigor", 2, -360, 80, 75000, 60, "Pawlogates", "beginner"]
var info_MAIN_3 = ["Toggle Land", 1, 280, 60, 250000, 60, "Pawlogates", "beginner"]
var info_MAIN_4 = ["Carrots and Sticks", 1, 180, 40, 80000, 60, "Pawlogates", "beginner"]
var info_MAIN_5 = ["Chilling Exercise", 1, -120, -100, 4000, 60, "Pawlogates", "beginner"]
var info_MAIN_6 = ["Daring Dash", 1, 700, 80, 25000, 60, "Pawlogates", "beginner"]
var info_MAIN_7 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "Pawlogates", "intermediate"]
var info_MAIN_8 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "Pawlogates", "intermediate"]
var info_MAIN_9 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "Pawlogates"]
var info_MAIN_10 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "Pawlogates"]

# Bonus Levels.
var info_BONUS = ["Main Levels", Globals.d_backgrounds + "/bg_levelSet_MAIN.png", 12, true, "Pawlogates", "res://Other/Scenes/Level Set/levelSet_decoration_MAIN.tscn"]

var info_BONUS_1 = ["Unnamed", 1, 100000, 60]
var info_BONUS_2 = ["Unnamed", 1, 100000, 60]
var info_BONUS_3 = ["Unnamed", 1, 100000, 60]
var info_BONUS_4 = ["Unnamed", 1, 100000, 60]
var info_BONUS_5 = ["Unnamed", 1, 100000, 60]
var info_BONUS_6 = ["Unnamed", 1, 100000, 60]
var info_BONUS_7 = ["Unnamed", 1, 100000, 60]

# Debug Levels.
var info_DEBUG_1 = ["test_collectibles", 1, -400, 64, -1, -1]
var info_DEBUG_2 = ["test_physics_objects", 1, -350, 64, -1, -1]
var info_DEBUG_3 = ["test_zones", 1, -300, 64, -1, -1]
var info_DEBUG_4 = ["test_random_objects", 1, -250, 64, -1, -1]
var info_DEBUG_5 = ["test_weapons", 1, -200, 64, -1, -1]
var info_DEBUG_6 = ["test_switches", 1, -150, 64, -1, -1]
var info_DEBUG_7 = ["test_random_enemy", 1, -100, 64, -1, -1]
var info_DEBUG_8 = ["test_lethalBall", 1, -50, 64, -1, -1]
var info_DEBUG_9 = ["test_meme_mode", 1, 0, 64, -1, -1]
var info_DEBUG_10 = ["test_object_saved_state", 1, 50, 64, -1, -1]
var info_DEBUG_11 = ["test_random_decoration", 1, 100, 64, -1, -1]
var info_DEBUG_12 = ["area_factory", 2, 0, 0, -1, -1]
var info_DEBUG_13 = ["area_infected_glades", 2, 0, 0, -1, -1]
var info_DEBUG_14 = ["area_glades", 2, 0, 0, -1, -1]
var info_DEBUG_15 = ["area_castle", 2, 0, 0, -1, -1]
var info_DEBUG_16 = ["area_ascent", 2, 0, 0, -1, -1]


#Called when the node enters the scene tree for the first time.
#func _ready():
	#pass


#Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#pass


# Saved player-related properties (overworld):
var saved_last_level_filepath = "none"

var saved_position_x = 0 # Saved overworld player position, to be applied when loading back into any of the overworld-type levels.
var saved_position_y = 0
var saved_health = 0
var saved_score = 0 # Saved overworld score, to be restored when loading back into any of the overworld-type levels.
var saved_module_points = 0

var saved_weapon = Array()
var saved_secondaryWeapon = Array()

var saved_bg_current_filepath = "none"
var saved_bg_a_current_filepath = "none"
var saved_bg_b_current_filepath = "none"

var saved_bg_previous_filepath = "none"
var saved_bg_a_previous_filepath = "none"
var saved_bg_b_previous_filepath = "none"

var saved_bg_offset_target_x = 0
var saved_bg_offset_target_y = 0

var saved_music_filepath = "none"
var saved_ambience_filepath = "none"

var saved_music_active = false
var saved_ambience_active = false

# True if the player's progress has never been saved.
var never_saved = true


# Player-related information, mostly used in the overworld levels.
func save_playerData(save_player_position):
	Globals.reassign_general()
	
	if save_player_position: # Doesn't save current player position if a save is triggered by entering a portal.
		if Globals.player.last_checkpoint_position == Vector2(0, 0):
			saved_position_x = Globals.player.position[0]
			saved_position_y = Globals.player.position[1]
		else:
			saved_position_x = Globals.player.last_checkpoint_position[0]
			saved_position_y = Globals.player.last_checkpoint_position[1]
	
	saved_health = int(Globals.player_health)
	saved_score = Globals.level_score
	saved_module_points = Globals.module_points
	
	saved_weapon = Globals.player.weapon
	saved_secondaryWeapon = Globals.player.secondaryWeapon
	
	saved_bg_current_filepath = Globals.world.bg_current.texture.resource_path
	saved_bg_a_current_filepath = Globals.world.bg_a_current.texture.resource_path
	saved_bg_b_current_filepath = Globals.world.bg_b_current.texture.resource_path
	
	saved_bg_previous_filepath = Globals.world.bg_previous.texture.resource_path
	saved_bg_a_previous_filepath = Globals.world.bg_a_previous.texture.resource_path
	saved_bg_b_previous_filepath = Globals.world.bg_b_previous.texture.resource_path
	
	saved_bg_offset_target_x = Globals.World.bg_offset_target_x
	saved_bg_offset_target_y = Globals.World.bg_offset_target_y
	
	if Globals.World.music.stream != null:
		saved_music_filepath = Globals.World.music.stream.resource_path
	else:
		saved_music_filepath = "none"
	
	if Globals.World.ambience.stream != null:
		saved_ambience_filepath = Globals.World.ambience.stream.stream.resource_path
	else:
		saved_music_filepath = "none"
	
	saved_music_active = Globals.World.music.playing
	saved_ambience_active = Globals.World.ambience.playing
	
	
	never_saved = false
	
	# Save all above properties to the playerData.save file.
	save_file("user://playerData.save", "data_playerData")


func load_playerData():
	if not FileAccess.file_exists("user://saves/playerData/playerData.save"):
		print("Couldn't find the playerData.save file.")
		return
		
	var file = FileAccess.open("user://saves/playerData.save", FileAccess.READ)
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var json_line = file.get_line() # A "line" in this case refers to the entirety of json's contents.
		var parse_result = json.parse(json_line)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_line, " at line ", json.get_error_line())
			continue
		
		var data = json.get_data()
		
		# Apply the loaded property values.
		saved_last_level_filepath = data["saved_last_level_filepath"]
		
		saved_position_x = data["saved_position_x"]
		saved_position_y = data["saved_position_y"]
		saved_health = data["saved_health"]
		saved_score = data["saved_score"]
		saved_module_points = data["saved_module_points"]
		
		saved_weapon = data["saved_weapon"]
		saved_secondaryWeapon = data["saved_secondaryWeapon"]
		
		saved_bg_current_filepath = data["saved_bg_current_filepath"]
		saved_bg_a_current_filepath = data["saved_bg_a_current_filepath"]
		saved_bg_b_current_filepath = data["saved_bg_b_current_filepath"]
		
		saved_bg_previous_filepath = data["saved_bg_previous_filepath"]
		saved_bg_a_previous_filepath = data["saved_bg_a_previous_filepath"]
		saved_bg_b_previous_filepath = data["saved_bg_b_previous_filepath"]
		
		saved_bg_offset_target_x = data["saved_bg_offset_target_x"]
		saved_bg_offset_target_y = data["saved_bg_offset_target_y"]
		
		saved_music_filepath = data["saved_music_filepath"]
		saved_ambience_filepath = data["saved_ambience_filepath"]
		
		saved_music_active = data["saved_music_active"]
		saved_ambience_active = data["saved_ambience_active"]
		
		#saved_propertyName = data["saved_propertyName"]
		
		never_saved = data["never_saved"]


# Resets saved player-related properties (applied in overworld levels):
func reset_playerData():
	saved_last_level_filepath = "none"
	
	saved_position_x = 0 # Saved overworld player position, to be applied when loading back into any of the overworld-type levels.
	saved_position_y = 0
	saved_health = 0
	saved_score = 0 # Saved overworld score, to be restored when loading back into any of the overworld-type levels.
	saved_module_points = 0
	
	saved_weapon = []
	saved_secondaryWeapon = []
	
	saved_bg_current_filepath = "none"
	saved_bg_a_current_filepath = "none"
	saved_bg_b_current_filepath = "none"
	
	saved_bg_previous_filepath = "none"
	saved_bg_a_previous_filepath = "none"
	saved_bg_b_previous_filepath = "none"
	
	saved_bg_offset_target_x = 0
	saved_bg_offset_target_y = 0
	
	saved_music_filepath = AudioStreamMP3
	saved_ambience_filepath = AudioStreamMP3
	
	saved_music_active = false
	saved_ambience_active = false
	
	never_saved = true


func delete_playerData(target : String):
	var dir = DirAccess.open("user://saves/playerData")
	
	if target == "all":
		for filename in dir.get_files():
			delete_file(filename, dir)
	
	else:
		delete_file(target, dir)


# Data is what you get when opening a json. This function is called at the end of a main save/load function.
func data_playerData():
	var contents = {
		# Saved player-related properties.
		"saved_last_level_filepath" : saved_last_level_filepath,
		
		"saved_position_x" : saved_position_x,
		"saved_position_y" : saved_position_y,
		"saved_health" : saved_health,
		"saved_score" : saved_score,
		"saved_module_points" : saved_module_points,
		
		"saved_weapon" : saved_weapon,
		"saved_secondaryWeapon" : saved_secondaryWeapon,
		
		"saved_bg_current_filepath" : saved_bg_current_filepath,
		"saved_bg_a_current_filepath" : saved_bg_a_current_filepath,
		"saved_bg_b_current_filepath" : saved_bg_b_current_filepath,
		
		"saved_bg_previous_filepath" : saved_bg_previous_filepath,
		"saved_bg_a_previous_filepath" : saved_bg_a_previous_filepath,
		"saved_bg_b_previous_filepath" : saved_bg_b_previous_filepath,
		
		"saved_bg_offset_target_x" : saved_bg_offset_target_x,
		"saved_bg_offset_target_y" : saved_bg_offset_target_y,
		
		"saved_music_filepath" : saved_music_filepath,
		"saved_ambience_filepath" : saved_ambience_filepath,
		
		"saved_music_active" : saved_music_active,
		"saved_ambience_active" : saved_ambience_active,
		
		#"saved_propertyName" : saved_propertyName,
		
		"never_saved" : never_saved,
	
	}
	return contents


# Level sets are collections of levels, shown together on their level set screen.
# Each level set has its own save files ("levelSet.save") to store its level states (separate from the actual level's collectibles, enemies, etc. state files - "levelState.save"). Level set's level state refers to whether each level has been unlocked, finished, fully cleared, etc.
func save_levelSet(list_levelSet_id):
	for levelSet_id in list_levelSet_id:
		# Save all above properties to the "levelSet[id].save" file.
		save_file(Globals.d_levelSet + "/levelSet_" + levelSet_id + ".save", "data_levelSet")


func load_levelSet():
	if not FileAccess.file_exists("user://levelSet.save"):
		print("Couldn't find the save file (levelSet.save - All of the LEVEL SET level completion states and scores).")
		return
		
	var saved_progress_file = FileAccess.open("user://saved_levelSetProgress.save", FileAccess.READ)
	while saved_progress_file.get_position() < saved_progress_file.get_length():
		var json_string = saved_progress_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var data = json.get_data()
		
		# Main Levels:
		state_MAIN = data["state_MAIN"]
		state_MAIN_1 = data["state_MAIN_1"]
		state_MAIN_2 = data["state_MAIN_2"]
		state_MAIN_3 = data["state_MAIN_3"]
		state_MAIN_4 = data["state_MAIN_4"]
		state_MAIN_5 = data["state_MAIN_5"]
		state_MAIN_6 = data["state_MAIN_6"]
		
		#state_MAIN_7 = int(data["state_MAIN_7"])


func reset_levelSet(id):
	for level_number in get("info_" + str(id)):
		set("state_" + str(id) + "_" + str(level_number), state_empty)


func data_levelSet(id): # Example id: "MAIN, "BONUS", etc.
	var contents : Dictionary = {}
	
	for level_number in info_MAIN[2]:
		print("Saving levelSet state for " + str(id) + "_" + str(level_number))
		contents.get_or_add({
			# Saved states and scores of levels from various level sets.
			"state_" + str(id) + "_" + str(level_number) : get("state_" + str(id) + "_" + str(level_number))
		}) # !!! add "null" as first parameter if this doesnt work
	
	
	return contents


func save_levelState(level_id):
	if Globals.World.level_overworld_id == "none" : return
	
	var file = FileAccess.open(Globals.d_levelState + "/levelState_" + level_id + ".save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		file.store_line(json_string)
	
	
	Globals.saved_level_score = Globals.level_score
	
	Globals.reassign_player()
	
	if Globals.World.last_checkpoint_pos == Vector2(0, 0):
		Globals.saved_player_pos_x = Globals.Player.position.x
		Globals.saved_player_pos_x = Globals.Player.position.y
	else:
		Globals.saved_player_pos_x = Globals.World.last_checkpoint_position[0]
		Globals.saved_player_pos_y = Globals.World.last_checkpoint_pos[1]
	
	
	%quicksavedDisplay/Label/AnimationPlayer.play("on_justQuicksaved")
	
	Globals.saveState_saved.emit()
	
	
	await get_tree().create_timer(0.1, false).timeout
	Globals.is_saving = false


# Set the "quicksave" property value to 0 for normal behaviour.
func load_levelState(quicksave): # Value of "0" will cause it to load a state file matching the current level's overworld id, while values from 1 to 4 will cause it to load a matching quicksave file (levelState_quicksave1, levelState_quicksave2, etc.)
	pass


func save_file(filepath : String, data_function : String):
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	var data = call(data_function)
	var json_contents = JSON.stringify(data)
	
	file.store_line(json_contents)


func save_file_levelState(level_id):
	pass


# Functions that delete the game's save files.
func delete_levelState(target : String): # Target is a filename (levelSet_MAIN.json, levelSet_BONUS.json, etc.).
	var dir = DirAccess.open("user://levelState")
	
	if target == "all":
		for filename in dir.get_files():
			delete_file(filename, dir)
	
	else:
		delete_file(target, dir)

func delete_levelSet(target : String):
	var dir = DirAccess.open(Globals.d_levelSet)
	
	if target == "all":
		for filename in dir.get_files():
			delete_file(filename, dir)
	
	else:
		delete_file(target, dir)

func delete_file(filename, dir):
	if not dir.file_exists(filename) : return
	
	dir.remove(filename)
