extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



#saved properties:
var saved_position = Vector2(0, 0) # [saved overworld player position, to be applied when loading back into any of the overworld-type levels ("areas")]
var saved_score = 0 # [saved overworld score, to be restored when loading back into any of the overworld-type levels]

#unlocked weapons
var saved_weapon_basic = [false, false] # [true if the weapon type was found in the world, making it available for purchase.], [true if purchased, making it permanently selectable using quickselect.]
var saved_weapon_veryFast_speed = [false, false] # [], []
var saved_weapon_short_shotDelay = [false, false] # [], []





func save_data():
	var saved_progress_file = FileAccess.open("user://saved_data.save", FileAccess.WRITE)
	var saved_progress_data = call("save")

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(saved_progress_data)

	# Store the save dictionary as a new line in the save file.
	saved_progress_file.store_line(json_string)
	


func load_game():
	if not FileAccess.file_exists("user://saved_data.save"):
		print("no save")
		return # Error! We don't have a save to load.
		
	var saved_progress_file = FileAccess.open("user://saved_data.save", FileAccess.READ)
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
		saved_position = data["saved_position"]
		#LOAD PROGRESS END



#SAVE START

func save():
	var save_dict = {
		#saved data
		"saved_position" : saved_position,
		
	}
	return save_dict

#SAVE END
