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
var saved_weapon_basic = -1 # [0 if the weapon type was found in the world, making it available for purchase, 1 if purchased, making it permanently selectable using quickselect.]
var saved_weapon_veryFast_speed = -1
var saved_weapon_ice = -1
var saved_weapon_fire = -1
var saved_weapon_destructive_fast_speed = -1
var saved_weapon_short_shotDelay = -1
var saved_weapon_phaser = -1
var saved_secondaryWeapon_basic = -1
var saved_secondaryWeapon_fast = -1

func save_game(save_player_position):
	if save_player_position:
		saved_position = $/root/World.player.position
	saved_score = Globals.level_score
	#save item unlock states
	save_item_unlock_state("weapon_basic")
	save_item_unlock_state("weapon_veryFast_speed")
	save_item_unlock_state("weapon_ice")
	save_item_unlock_state("weapon_fire")
	save_item_unlock_state("weapon_destructive_fast_speed")
	save_item_unlock_state("weapon_short_shotDelay")
	save_item_unlock_state("weapon_phaser")
	save_item_unlock_state("secondaryWeapon_basic")
	save_item_unlock_state("secondaryWeapon_fast")
	

var item_unlock_state
func save_item_unlock_state(item):
	item_unlock_state = $/root/World/HUD/quickselect_screen.get("unlock_state_" + item)
	set("saved_" + item, item_unlock_state)

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
