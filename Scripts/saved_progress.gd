extends Node2D

#states 1: 0 - unfinished, 1 - finished, 2 - all big apples collected, 3 - all collectibles collected, -1 - unlocked (main game exclusive)

# Additional levels
var state_RI1_1 = 0
var state_RI1_2 = 0
var state_RI1_3 = 0
var state_RI1_4 = 0
var state_RI1_5 = 0
var state_RI1_6 = 0
var state_RI1_7 = 0
var state_RI1_8 = 0
var state_RI1_9 = 0
var state_RI1_10 = 0
var state_RI1_11 = 0

var score_RI1_1 = 0
var score_RI1_2 = 0
var score_RI1_3 = 0
var score_RI1_4 = 0
var score_RI1_5 = 0
var score_RI1_6 = 0
var score_RI1_7 = 0
var score_RI1_8 = 0
var score_RI1_9 = 0
var score_RI1_10 = 0
var score_RI1_11 = 0

var total_score_RI1 = 0
var next_level_RI1 = 1


# Main Levels
var state_MAIN_1 = 0
var state_MAIN_2 = 0
var state_MAIN_3 = 0
var state_MAIN_4 = 0
var state_MAIN_5 = 0
var state_MAIN_6 = 0
var state_MAIN_7 = 0
var state_MAIN_8 = 0
var state_MAIN_9 = 0
var state_MAIN_10 = 0
var state_MAIN_11 = 0
var state_MAIN_12 = 0
var state_MAIN_13 = 0

var score_MAIN_1 = 0
var score_MAIN_2 = 0
var score_MAIN_3 = 0
var score_MAIN_4 = 0
var score_MAIN_5 = 0
var score_MAIN_6 = 0
var score_MAIN_7 = 0
var score_MAIN_8 = 0
var score_MAIN_9 = 0
var score_MAIN_10 = 0
var score_MAIN_11 = 0
var score_MAIN_12 = 0
var score_MAIN_13 = 0

var total_score_MAIN = 0
var next_level_MAIN = -1






func _ready():
	Globals.save_progress.connect(save_progress)

func save_progress():
	save_game()


var current_level = 0

func count_total_score(current_levelSet, level_count):
	print(current_levelSet)
	var total_score = 0
	current_level = 0
	
	while current_level < level_count:
		current_level += 1
		total_score += get("score_" + current_levelSet + "_" + str(current_level))
	
	set("total_score_" + current_levelSet, total_score)


#Save progress

func save_game():
	var saved_progress_file = FileAccess.open("user://saved_progress.save", FileAccess.WRITE)
	var saved_progress_data = call("save")

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(saved_progress_data)

	# Store the save dictionary as a new line in the save file.
	saved_progress_file.store_line(json_string)
	




func load_game():
	if not FileAccess.file_exists("user://saved_progress.save"):
		print("Couldn't find the save file (saved_progress - All of the LEVEL SET level completion states and scores).")
		return # Error! We don't have a save to load.
		
	var saved_progress_file = FileAccess.open("user://saved_progress.save", FileAccess.READ)
	while saved_progress_file.get_position() < saved_progress_file.get_length():
		var json_string = saved_progress_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var data = json.get_data()
		
		#LOAD PROGRESS
		
		#RI1
		state_RI1_1 = data["state_RI1_1"]
		state_RI1_2 = data["state_RI1_2"]
		state_RI1_3 = data["state_RI1_3"]
		state_RI1_4 = data["state_RI1_4"]
		state_RI1_5 = data["state_RI1_5"]
		state_RI1_6 = data["state_RI1_6"]
		state_RI1_7 = data["state_RI1_7"]
		state_RI1_8 = data["state_RI1_8"]
		state_RI1_9 = data["state_RI1_9"]
		state_RI1_10 = data["state_RI1_10"]
		state_RI1_11 = data["state_RI1_11"]
		
		score_RI1_1 = data["score_RI1_1"]
		score_RI1_2 = data["score_RI1_2"]
		score_RI1_3 = data["score_RI1_3"]
		score_RI1_4 = data["score_RI1_4"]
		score_RI1_5 = data["score_RI1_5"]
		score_RI1_6 = data["score_RI1_6"]
		score_RI1_7 = data["score_RI1_7"]
		score_RI1_8 = data["score_RI1_8"]
		score_RI1_9 = data["score_RI1_9"]
		score_RI1_10 = data["score_RI1_10"]
		score_RI1_11 = data["score_RI1_11"]
		
		next_level_RI1 = data["next_level_RI1"]
		
		
		#MAIN
		state_MAIN_1 = data["state_MAIN_1"]
		state_MAIN_2 = data["state_MAIN_2"]
		state_MAIN_3 = data["state_MAIN_3"]
		state_MAIN_4 = data["state_MAIN_4"]
		state_MAIN_5 = data["state_MAIN_5"]
		state_MAIN_6 = data["state_MAIN_6"]
		state_MAIN_7 = data["state_MAIN_7"]
		state_MAIN_8 = data["state_MAIN_8"]
		state_MAIN_9 = data["state_MAIN_9"]
		state_MAIN_10 = data["state_MAIN_10"]
		state_MAIN_11 = data["state_MAIN_11"]
		state_MAIN_12 = data["state_MAIN_12"]
		state_MAIN_13 = data["state_MAIN_13"]
		
		score_MAIN_1 = data["score_MAIN_1"]
		score_MAIN_2 = data["score_MAIN_2"]
		score_MAIN_3 = data["score_MAIN_3"]
		score_MAIN_4 = data["score_MAIN_4"]
		score_MAIN_5 = data["score_MAIN_5"]
		score_MAIN_6 = data["score_MAIN_6"]
		score_MAIN_7 = data["score_MAIN_7"]
		score_MAIN_8 = data["score_MAIN_8"]
		score_MAIN_9 = data["score_MAIN_9"]
		score_MAIN_10 = data["score_MAIN_10"]
		score_MAIN_11 = data["score_MAIN_11"]
		score_MAIN_12 = data["score_MAIN_12"]
		score_MAIN_13 = data["score_MAIN_13"]
		
		#next_level_MAIN = data["next_level_MAIN"]
		
		#LOAD PROGRESS END









#SAVE START

func save():
	var save_dict = {
		
		#RI1
		"state_RI1_1" : state_RI1_1,
		"state_RI1_2" : state_RI1_2,
		"state_RI1_3" : state_RI1_3,
		"state_RI1_4" : state_RI1_4,
		"state_RI1_5" : state_RI1_5,
		"state_RI1_6" : state_RI1_6,
		"state_RI1_7" : state_RI1_7,
		"state_RI1_8" : state_RI1_8,
		"state_RI1_9" : state_RI1_9,
		"state_RI1_10" : state_RI1_10,
		"state_RI1_11" : state_RI1_11,
		
		"score_RI1_1" : score_RI1_1,
		"score_RI1_2" : score_RI1_2,
		"score_RI1_3" : score_RI1_3,
		"score_RI1_4" : score_RI1_4,
		"score_RI1_5" : score_RI1_5,
		"score_RI1_6" : score_RI1_6,
		"score_RI1_7" : score_RI1_7,
		"score_RI1_8" : score_RI1_8,
		"score_RI1_9" : score_RI1_9,
		"score_RI1_10" : score_RI1_10,
		"score_RI1_11" : score_RI1_11,
		
		"next_level_RI1" : next_level_RI1,
		
		
		#MAIN
		"state_MAIN_1" : state_MAIN_1,
		"state_MAIN_2" : state_MAIN_2,
		"state_MAIN_3" : state_MAIN_3,
		"state_MAIN_4" : state_MAIN_4,
		"state_MAIN_5" : state_MAIN_5,
		"state_MAIN_6" : state_MAIN_6,
		"state_MAIN_7" : state_MAIN_7,
		"state_MAIN_8" : state_MAIN_8,
		"state_MAIN_9" : state_MAIN_9,
		"state_MAIN_10" : state_MAIN_10,
		"state_MAIN_11" : state_MAIN_11,
		"state_MAIN_12" : state_MAIN_12,
		"state_MAIN_13" : state_MAIN_13,
		
		"score_MAIN_1" : score_MAIN_1,
		"score_MAIN_2" : score_MAIN_2,
		"score_MAIN_3" : score_MAIN_3,
		"score_MAIN_4" : score_MAIN_4,
		"score_MAIN_5" : score_MAIN_5,
		"score_MAIN_6" : score_MAIN_6,
		"score_MAIN_7" : score_MAIN_7,
		"score_MAIN_8" : score_MAIN_8,
		"score_MAIN_9" : score_MAIN_9,
		"score_MAIN_10" : score_MAIN_10,
		"score_MAIN_11" : score_MAIN_11,
		"score_MAIN_12" : score_MAIN_12,
		"score_MAIN_13" : score_MAIN_13,
		
		#"next_level_MAIN" : next_level_MAIN,
		
	}
	return save_dict

#SAVE END
