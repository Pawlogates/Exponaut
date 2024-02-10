extends Node2D

@export var episode = "Rooster Island"




#states 1: 0 - unfinished, 1 - finished, 2 - all big apples collected, 3 - all collectibles collected
#states 2: 0 - none, 1 - finished with no damage taken
#states 3: 0 - none, 1 - finished under target time
#states 4: 0 - none, 1 - score attack mode finished, 2 - score rank D, 3 - score rank C, 4 - score rank B, 5 - score rank A, 6 - score rank S, 7 - score rank S+


#ROOSTER ISLAND 1
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

var next_level_RI1 = 1


#ROOSTER ISLAND 2
var state_RI2_1 = 0
var state_RI2_2 = 0
var state_RI2_3 = 0
var state_RI2_4 = 0
var state_RI2_5 = 0
var state_RI2_6 = 0
var state_RI2_7 = 0
var state_RI2_8 = 0
var state_RI2_9 = 0
var state_RI2_10 = 0
var state_RI2_11 = 0
var state_RI2_12 = 0
var state_RI2_13 = 0

var score_RI2_1 = 0
var score_RI2_2 = 0
var score_RI2_3 = 0
var score_RI2_4 = 0
var score_RI2_5 = 0
var score_RI2_6 = 0
var score_RI2_7 = 0
var score_RI2_8 = 0
var score_RI2_9 = 0
var score_RI2_10 = 0
var score_RI2_11 = 0
var score_RI2_12 = 0
var score_RI2_13 = 0

var next_level_RI2 = 1











#Save progress

func save_game():
	var saved_progress_file = FileAccess.open("user://saved_progress.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	var saved_progress_data = call("save")

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(saved_progress_data)

	# Store the save dictionary as a new line in the save file.
	saved_progress_file.store_line(json_string)
	




func load_game():
	if not FileAccess.file_exists("user://saved_progress.save"):
		print("no save")
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
		
		
		state_RI2_1 = data["state_RI2_1"]
		state_RI2_2 = data["state_RI2_2"]
		state_RI2_3 = data["state_RI2_3"]
		state_RI2_4 = data["state_RI2_4"]
		state_RI2_5 = data["state_RI2_5"]
		state_RI2_6 = data["state_RI2_6"]
		state_RI2_7 = data["state_RI2_7"]
		state_RI2_8 = data["state_RI2_8"]
		state_RI2_9 = data["state_RI2_9"]
		state_RI2_10 = data["state_RI2_10"]
		state_RI2_11 = data["state_RI2_11"]
		state_RI2_12 = data["state_RI2_12"]
		state_RI2_13 = data["state_RI2_13"]
		
		score_RI2_1 = data["score_RI2_1"]
		score_RI2_2 = data["score_RI2_2"]
		score_RI2_3 = data["score_RI2_3"]
		score_RI2_4 = data["score_RI2_4"]
		score_RI2_5 = data["score_RI2_5"]
		score_RI2_6 = data["score_RI2_6"]
		score_RI2_7 = data["score_RI2_7"]
		score_RI2_8 = data["score_RI2_8"]
		score_RI2_9 = data["score_RI2_9"]
		score_RI2_10 = data["score_RI2_10"]
		score_RI2_11 = data["score_RI2_11"]
		score_RI2_12 = data["score_RI2_12"]
		score_RI2_13 = data["score_RI2_13"]
		
		next_level_RI2 = data["next_level_RI2"]
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
		
		
		#RI2
		"state_RI2_1" : state_RI2_1,
		"state_RI2_2" : state_RI2_2,
		"state_RI2_3" : state_RI2_3,
		"state_RI2_4" : state_RI2_4,
		"state_RI2_5" : state_RI2_5,
		"state_RI2_6" : state_RI2_6,
		"state_RI2_7" : state_RI2_7,
		"state_RI2_8" : state_RI2_8,
		"state_RI2_9" : state_RI2_9,
		"state_RI2_10" : state_RI2_10,
		"state_RI2_11" : state_RI2_11,
		"state_RI2_12" : state_RI2_12,
		"state_RI2_13" : state_RI2_13,
		
		"score_RI2_1" : score_RI2_1,
		"score_RI2_2" : score_RI2_2,
		"score_RI2_3" : score_RI2_3,
		"score_RI2_4" : score_RI2_4,
		"score_RI2_5" : score_RI2_5,
		"score_RI2_6" : score_RI2_6,
		"score_RI2_7" : score_RI2_7,
		"score_RI2_8" : score_RI2_8,
		"score_RI2_9" : score_RI2_9,
		"score_RI2_10" : score_RI2_10,
		"score_RI2_11" : score_RI2_11,
		"score_RI2_12" : score_RI2_12,
		"score_RI2_13" : score_RI2_13,
		
		"next_level_RI2" : next_level_RI2,
		
	}
	return save_dict

#SAVE END
