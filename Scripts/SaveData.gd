extends Node2D

const default_saved_levelSet = [-1, 0, 0]
const default_saved_level = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const default_info_levelSet = ["Main Levels", 12, "Pawlogates", "none", "none", Globals.d_backgrounds + "/bg_levelSet_MAIN.png", "res://Other/Scenes/Level Set/levelSet_decoration_MAIN.tscn"]
const default_info_level = ["Training Tunnel", 0, -460, 40, 180000, 60, "Calm before the storm?", "Pawlogates", "beginner", "regular"]
const default_unlock_levelSet = [false, "none", "none", "none", "none", "none", "none", "none"]
const default_unlock_level = [false, "none", "none", "none", "none", "none", "none", "none"]
const default_collectibles_level = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # A levelSet counterpart is not needed.

# ==========> Level set: "MAIN" - START <============

# Saved level set progress:
# saved_[levelSet_id] : [(-1 - locked, 0 - unfinished, 1 - finished, 2 - all major collectibles collected, 3 - all collectibles collected), (0 - some levels are not finished so no score rank, 1 through 25 - all levels are finished and the value represents the score rank value (F- through S+, S++, S++, and finally: EXPONAUT)), (0 - some levels are not finished so no time rank, 1 through 25 - all levels are finished and the value represents the time rank value (F- through S+, S++, S++, and finally: EXPONAUT))
var saved_MAIN = [-1, 0, 0] # [unlock state, score rank, time rank]

# Saved level progress:
# saved_[levelSet_id]_[level_number] : [state, score, time, major_collectibles] States: -1 - Locked. 0 - Unfinished. 1 - Finished. 2 - All major collectibles collected. 3 - All collectibles collected. Note: Values in major_collectibles represent: 0 - Not collected. 1 - Collected.
var saved_MAIN_1 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_2 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_3 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_4 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_5 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_6 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_7 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_8 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_9 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_MAIN_10 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# Level set information (static):
# info_[levelSet_id] : [levelSet_name, level_quantity, levelSet_author, levelSet_message, levelSet_difficulty, levelSet_background_filepath, levelSet_decoration_filepath]
var info_MAIN = ["Main Levels", 10, "Pawlogates", "none", "none", Globals.d_backgrounds + "/bg_levelSet_MAIN.png", "res://Other/Scenes/Level Set/levelSet_decoration_MAIN.tscn"]

# Level information (static):
# info_[levelSet_id]_[level_number] : [name, icon_id, icon_position_x, icon_position_y, score_target, time_target, creator, message, difficulty]
const info_MAIN_1 = ["Training Tunnel", 0, -460, 40, 180000, 60, "Calm before the storm?", "Pawlogates", "beginner", "regular"]
const info_MAIN_2 = ["Valley of Vigor", 2, -360, 80, 75000, 60, "something", "Pawlogates", "beginner", "regular"]
const info_MAIN_3 = ["Toggle Land", 1, 280, 60, 250000, 60, "hello", "Pawlogates", "beginner", "regular"]
const info_MAIN_4 = ["Carrots and Sticks", 1, 180, 40, 80000, 60, "will update later idk", "Pawlogates", "beginner", "regular"]
const info_MAIN_5 = ["Chilling Exercise", 1, -120, -100, 4000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_MAIN_6 = ["Daring Dash", 1, 700, 80, 25000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_MAIN_7 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "intermediate", "regular"]
const info_MAIN_8 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "intermediate", "regular"]
const info_MAIN_9 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_MAIN_10 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "beginner", "regular"]

# Level set unlock methods (static):
# unlock_[levelSet_id] : [previous, portal_in_level_id, key_in_level_id, score_in_level_id, score_in_levelSet_id, score_in_overworld_levelSet_id, time_in_level_id, time_in_levelSet_id] Note: Set an unlock method to "false" or "none" if it should be ignored. If all are set to "false" or "none", the level set will be unlocked from the start.
const unlock_MAIN = [false, "none", "none", "none", "none", "none", "none", "none"]

# Level unlock methods (static):
# unlock_[levelSet_id]_[level_number] : exactly the same as above
const unlock_MAIN_1 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_2 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_3 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_4 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_5 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_6 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_7 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_8 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_9 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_MAIN_10 = [false, "none", "none", "none", "none", "none", "none", "none"]

# Level major collectibles (static):
# collectibles_[level_id] : [[slot 1 - major collectible exists in a level], [slot 2 - major collectible exists in a level], etc.]
# There is no level set variant of this, as it is not needed. Note that the values (int) in this "collectibles_[level_id]" (array) represent: 0 - Leave this major collectible slot empty. 1 - Assign a major collectible to this slot of the level. If a specific slot here has a value of "1", make sure that the matching level scene contains a major collectible, with an id (int) set to the matching slot.
const collectibles_MAIN_1 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_2 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_3 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_4 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_5 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_6 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_7 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_8 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_9 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_MAIN_10 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# ==========> Level set: "MAIN" - END <==============

# ==========> Level set: "BONUS" - START <===========

# Saved level set progress:
# saved_[levelSet_id] : [(-1 - locked, 0 - unfinished, 1 - finished, 2 - all major collectibles collected, 3 - all collectibles collected), (0 - some levels are not finished so no score rank, 1 through 25 - all levels are finished and the value represents the score rank value (F- through S+, S++, S++, and finally: EXPONAUT)), (0 - some levels are not finished so no time rank, 1 through 25 - all levels are finished and the value represents the time rank value (F- through S+, S++, S++, and finally: EXPONAUT))
var saved_BONUS = [-1, 0, 0] # [unlock state, score rank, time rank]

# Saved level progress:
# saved_[levelSet_id]_[level_number] : [state, score, time, major_collectibles] States: -1 - Locked. 0 - Unfinished. 1 - Finished. 2 - All major collectibles collected. 3 - All collectibles collected. Note: Values in major_collectibles represent: 0 - Not collected. 1 - Collected.
var saved_BONUS_1 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_2 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_3 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_4 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_5 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_6 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_7 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_8 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_9 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_BONUS_10 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# Level set information (static):
# info_[levelSet_id] : [levelSet_name, level_quantity, levelSet_author, levelSet_message, levelSet_difficulty, levelSet_background_filepath, levelSet_decoration_filepath]
var info_BONUS = ["BONUS Levels", 10, "Pawlogates", "none", "none", Globals.d_backgrounds + "/bg_levelSet_BONUS.png", "res://Other/Scenes/Level Set/levelSet_decoration_BONUS.tscn"]

# Level information (static):
# info_[levelSet_id]_[level_number] : [name, icon_id, icon_position_x, icon_position_y, score_target, time_target, creator, message, difficulty]
const info_BONUS_1 = ["Training Tunnel", 0, -460, 40, 180000, 60, "Calm before the storm?", "Pawlogates", "beginner", "regular"]
const info_BONUS_2 = ["Valley of Vigor", 2, -360, 80, 75000, 60, "something", "Pawlogates", "beginner", "regular"]
const info_BONUS_3 = ["Toggle Land", 1, 280, 60, 250000, 60, "hello", "Pawlogates", "beginner", "regular"]
const info_BONUS_4 = ["Carrots and Sticks", 1, 180, 40, 80000, 60, "will update later idk", "Pawlogates", "beginner", "regular"]
const info_BONUS_5 = ["Chilling Exercise", 1, -120, -100, 4000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_BONUS_6 = ["Daring Dash", 1, 700, 80, 25000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_BONUS_7 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "intermediate", "regular"]
const info_BONUS_8 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "intermediate", "regular"]
const info_BONUS_9 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_BONUS_10 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "beginner", "regular"]

# Level set unlock methods (static):
# unlock_[levelSet_id] : [previous, portal_in_level_id, key_in_level_id, score_in_level_id, score_in_levelSet_id, score_in_overworld_levelSet_id, time_in_level_id, time_in_levelSet_id] Note: Set an unlock method to "false" or "none" if it should be ignored. If all are set to "false" or "none", the level set will be unlocked from the start.
const unlock_BONUS = [false, "none", "none", "none", "none", "none", "none", "none"]

# Level unlock methods (static):
# unlock_[levelSet_id]_[level_number] : exactly the same as above
const unlock_BONUS_1 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_2 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_3 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_4 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_5 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_6 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_7 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_8 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_9 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_BONUS_10 = [false, "none", "none", "none", "none", "none", "none", "none"]

# Level major collectibles (static):
# collectibles_[level_id] : [[slot 1 - major collectible exists in a level], [slot 2 - major collectible exists in a level], etc.]
# There is no level set variant of this, as it is not needed. Note that the values (int) in this "collectibles_[level_id]" (array) represent: 0 - Leave this major collectible slot empty. 1 - Assign a major collectible to this slot of the level. If a specific slot here has a value of "1", make sure that the matching level scene contains a major collectible, with an id (int) set to the matching slot.
const collectibles_BONUS_1 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_2 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_3 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_4 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_5 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_6 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_7 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_8 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_9 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_BONUS_10 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# ==========> Level set: "BONUS" - END <=============

# ==========> Level set: "DEBUG" - START <===========

# Saved level set progress:
# saved_[levelSet_id] : [(-1 - locked, 0 - unfinished, 1 - finished, 2 - all major collectibles collected, 3 - all collectibles collected), (0 - some levels are not finished so no score rank, 1 through 25 - all levels are finished and the value represents the score rank value (F- through S+, S++, S++, and finally: EXPONAUT)), (0 - some levels are not finished so no time rank, 1 through 25 - all levels are finished and the value represents the time rank value (F- through S+, S++, S++, and finally: EXPONAUT))
var saved_DEBUG = [-1, 0, 0] # [unlock state, score rank, time rank]

# Saved level progress:
# saved_[levelSet_id]_[level_number] : [state, score, time, major_collectibles] States: -1 - Locked. 0 - Unfinished. 1 - Finished. 2 - All major collectibles collected. 3 - All collectibles collected. Note: Values in major_collectibles represent: 0 - Not collected. 1 - Collected.
var saved_DEBUG_1 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_2 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_3 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_4 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_5 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_6 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_7 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_8 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_9 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
var saved_DEBUG_10 = [-1, 0, -1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# Level set information (static):
# info_[levelSet_id] : [levelSet_name, level_quantity, levelSet_author, levelSet_message, levelSet_difficulty, levelSet_background_filepath, levelSet_decoration_filepath]
var info_DEBUG = ["DEBUG Levels", 10, "Pawlogates", "none", "none", Globals.d_backgrounds + "/bg_levelSet_DEBUG.png", "res://Other/Scenes/Level Set/levelSet_decoration_DEBUG.tscn"]

# Level information (static):
# info_[levelSet_id]_[level_number] : [name, icon_id, icon_position_x, icon_position_y, score_target, time_target, creator, message, difficulty]
const info_DEBUG_1 = ["Training Tunnel", 0, -460, 40, 180000, 60, "Calm before the storm?", "Pawlogates", "beginner", "regular"]
const info_DEBUG_2 = ["Valley of Vigor", 2, -360, 80, 75000, 60, "something", "Pawlogates", "beginner", "regular"]
const info_DEBUG_3 = ["Toggle Land", 1, 280, 60, 250000, 60, "hello", "Pawlogates", "beginner", "regular"]
const info_DEBUG_4 = ["Carrots and Sticks", 1, 180, 40, 80000, 60, "will update later idk", "Pawlogates", "beginner", "regular"]
const info_DEBUG_5 = ["Chilling Exercise", 1, -120, -100, 4000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_DEBUG_6 = ["Daring Dash", 1, 700, 80, 25000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_DEBUG_7 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "intermediate", "regular"]
const info_DEBUG_8 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "intermediate", "regular"]
const info_DEBUG_9 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "beginner", "regular"]
const info_DEBUG_10 = ["Puzzlin' Around", 1, 200, -40, 15000, 60, "none", "Pawlogates", "beginner", "regular"]

# Level set unlock methods (static):
# unlock_[levelSet_id] : [previous, portal_in_level_id, key_in_level_id, score_in_level_id, score_in_levelSet_id, score_in_overworld_levelSet_id, time_in_level_id, time_in_levelSet_id] Note: Set an unlock method to "false" or "none" if it should be ignored. If all are set to "false" or "none", the level set will be unlocked from the start.
const unlock_DEBUG = [false, "none", "none", "none", "none", "none", "none", "none"]

# Level unlock methods (static):
# unlock_[levelSet_id]_[level_number] : exactly the same as above
const unlock_DEBUG_1 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_2 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_3 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_4 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_5 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_6 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_7 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_8 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_9 = [false, "none", "none", "none", "none", "none", "none", "none"]
const unlock_DEBUG_10 = [false, "none", "none", "none", "none", "none", "none", "none"]

# Level major collectibles (static):
# collectibles_[level_id] : [[slot 1 - major collectible exists in a level], [slot 2 - major collectible exists in a level], etc.]
# There is no level set variant of this, as it is not needed. Note that the values (int) in this "collectibles_[level_id]" (array) represent: 0 - Leave this major collectible slot empty. 1 - Assign a major collectible to this slot of the level. If a specific slot here has a value of "1", make sure that the matching level scene contains a major collectible, with an id (int) set to the matching slot.
const collectibles_DEBUG_1 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_2 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_3 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_4 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_5 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_6 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_7 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_8 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_9 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
const collectibles_DEBUG_10 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

# ==========> Level set: "DEBUG" - END <=============


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
		Globals.message_debug("Couldn't find the playerData.save file.")
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


func load_levelSet(list_levelSet_id):
	for levelSet in list_levelSet_id:
		var save_filepath = Globals.dirpath_saves + "/levelSet_" + levelSet
		if not FileAccess.file_exists(save_filepath):
			Globals.message_debug("Couldn't find the save file (levelSet.save - All of the LEVEL SET level completion states, scores, etc.) at " + save_filepath)
			return
			
		var save_file = FileAccess.open(save_filepath, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			
			var data = json.get_data()
			
			var level_number = 0
			
			for level_info in data:
				level_number += 1
				if level_number > get("info_" + levelSet)[1]:
					break
				else:
					set("saved_" + levelSet + str(level_number), data[("saved_" + levelSet + str(level_number))])


func reset_levelSet(id): # Example id: "MAIN, "BONUS", etc.
	set("saved_" + id, default_saved_levelSet)
	for level_number in range(get("info_" + id)[2]):
		set("saved_" + id + str(level_number), default_saved_level)


func data_levelSet(id):
	var contents : Dictionary = {}
	
	for level_number in range(get("info_" + id)[2]):
		Globals.message_debug("Saving levelSet state for " + str(id) + "_" + str(level_number))
		contents.get_or_add({
			# Saved states and scores of levels from various level sets.
			"state_" + str(id) + "_" + str(level_number) : get("state_" + str(id) + "_" + str(level_number))
		})
	
	
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

# Returns a score rank (or its int value), depending on target score (score needed for maximum rank).
@onready var list_ranks = ["none", "F-", "F", "F+", "E-", "E", "E+", "D-", "D", "D+", "C-", "C", "C+", "B-", "B", "B+", "A-", "A", "A+", "S-", "S", "S+", "S+", "S++", "S+++", "EXPONAUT"]

func calculate_rank_level(level_id):
	
	var score = get("saved_" + level_id)[1]
	var score_target = get("info_" + level_id)[4]
	var score_segment = int(score_target / len(list_ranks))
	
	Globals.message_debug("Calculating score rank, with score of " + str(score) + " and target score of " + str(score_target) + " " + "Possible ranks: " + str(list_ranks) + ".")
	
	var rank_value = 0
	
	if score <= 0:
		rank_value = 0
	else:
		rank_value = int((score_target / score_segment) / score) + 1
	
	var rank = list_ranks[rank_value]
	
	Globals.message_debug("Rank result: " + rank + " (" + str(rank_value) + "), with score segment of " + str(score_segment) + ".")
	
	return [rank, rank_value]
