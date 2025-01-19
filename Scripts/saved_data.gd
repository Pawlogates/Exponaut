extends Node2D

var never_saved = true

# Called when the node enters the scene tree for the first time.
func _ready():
	savedData_load()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


#saved properties (overworld):
var saved_position_x = 0 # [saved overworld player position, to be applied when loading back into any of the overworld-type levels ("areas")]
var saved_position_y = 0
var saved_score = 0 # [saved overworld score, to be restored when loading back into any of the overworld-type levels]
var saved_last_area_filePath = "res://Levels/empty.tscn"
var saved_weapon = "none"
var saved_weapon_delay = 1.0
var saved_secondaryWeapon = "none"
var saved_secondaryWeapon_delay = 1.0

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

#other
var saved_bg_File_current = "res://Assets/Graphics/backgrounds/bg_cosmos_yellow.png"
var saved_bg_a_File_current = "res://Assets/Graphics/backgrounds/bg_a_jungle.png"
var saved_bg_b_File_current = "res://Assets/Graphics/backgrounds/bg_a_clouds.png"

var saved_bgOffset_target_x = 0
var saved_bgOffset_target_y = 0

var saved_music_file = "res://Assets/Sounds/music/ocean1.mp3"
var saved_ambience_file = "res://Assets/Sounds/ambience/ambience12.mp3"

var saved_music_isPlaying = false
var saved_ambience_isPlaying = false


func savedData_save(save_player_position):
	if save_player_position:
		if $/root/World.last_checkpoint_pos == Vector2(0, 0):
			saved_position_x = $/root/World.player.position[0]
			saved_position_y = $/root/World.player.position[1]
		else:
			saved_position_x = $/root/World.last_checkpoint_pos[0]
			saved_position_y = $/root/World.last_checkpoint_pos[1]
	
	saved_score = Globals.level_score
	saved_weapon = $/root/World.player.weaponType
	saved_weapon_delay = $/root/World.player.timer_attack_cooldown.wait_time
	saved_weapon = $/root/World.player.weaponType
	saved_secondaryWeapon_delay = $/root/World.player.timer_secondary_attack_cooldown.wait_time
	
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
	
	saved_bg_File_current = $/root/World/bg_previous/CanvasLayer/bg_main/bg_main/TextureRect.texture.resource_path
	saved_bg_a_File_current = $/root/World/bg_previous/CanvasLayer/bg_b/bg_b/TextureRect.texture.resource_path
	saved_bg_b_File_current = $/root/World/bg_previous/CanvasLayer/bg_a/bg_a/TextureRect.texture.resource_path
	
	saved_bgOffset_target_x = Globals.bgOffset_target_x
	saved_bgOffset_target_y = Globals.bgOffset_target_y
	
	saved_music_file = $/root/World/"Music Controller"/music.stream.resource_path
	saved_ambience_file = $/root/World/"Ambience Controller"/ambience.stream.resource_path
	
	saved_music_isPlaying = $/root/World/"Music Controller"/music.playing
	saved_ambience_isPlaying = $/root/World/"Ambience Controller"/ambience.playing
	
	
	never_saved = false
	
	#save all previous properties to the save file
	savedData_save_file()


func savedData_reset():
	never_saved = true
	
	#saved properties (overworld):
	saved_position_x = 0 # [saved overworld player position, to be applied when loading back into any of the overworld-type levels ("areas")]
	saved_position_y = 0
	saved_score = 0 # [saved overworld score, to be restored when loading back into any of the overworld-type levels]
	saved_last_area_filePath = "res://Levels/empty.tscn"
	
	#unlocked weapons
	saved_weapon_basic = -1 # [0 if the weapon type was found in the world, making it available for purchase, 1 if purchased, making it permanently selectable using quickselect.]
	saved_weapon_veryFast_speed = -1
	saved_weapon_ice = -1
	saved_weapon_fire = -1
	saved_weapon_destructive_fast_speed = -1
	saved_weapon_short_shotDelay = -1
	saved_weapon_phaser = -1
	saved_secondaryWeapon_basic = -1
	saved_secondaryWeapon_fast = -1
	
	#other
	saved_bg_File_current = CompressedTexture2D
	saved_bg_a_File_current = CompressedTexture2D
	saved_bg_b_File_current = CompressedTexture2D
	
	saved_bgOffset_target_x = 0
	saved_bgOffset_target_x = 0
	
	saved_music_file = AudioStreamMP3
	saved_ambience_file = AudioStreamMP3


func delete_area_states():
	var dir = DirAccess.open("user://")
	
	#general player progress
	if dir.file_exists("user://savedData.save"):
		dir.remove("user://savedData.save")
	
	#level select progress (top scores, level completion states, etc.)
	if dir.file_exists("user://saved_levelSetProgress.save"):
		dir.remove("user://saved_levelSetProgress.save")
	
	#quicksave (non-specific level state)
	if dir.file_exists("user://savegame.save"):
		dir.remove("user://savegame.save")
	
	#overworld area states
	if dir.file_exists("user://savegame_overworld_factory.save"):
		dir.remove("user://savegame_overworld_factory.save")
	if dir.file_exists("user://savegame_overworld_infected_glades.save"):
		dir.remove("user://savegame_overworld_infected_glades.save")
	if dir.file_exists("user://savegame_overworld_glades.save"):
		dir.remove("user://savegame_overworld_glades.save")
	if dir.file_exists("user://savegame_overworld_castle.save"):
		dir.remove("user://savegame_overworld_castle.save")
	if dir.file_exists("user://savegame_overworld_ascent.save"):
		dir.remove("user://savegame_overworld_ascent.save")
	
	if dir.file_exists("user://filename.save"):
		dir.remove("user://filename.save")


var item_unlock_state
func save_item_unlock_state(item):
	item_unlock_state = $/root/World/HUD/quickselect_screen.get("unlock_state_" + item)
	set("saved_" + item, item_unlock_state)

func savedData_save_file():
	var savedData_file = FileAccess.open("user://savedData.save", FileAccess.WRITE)
	var savedData_data = call("savedData_save_dictionary")
	
	var json_string = JSON.stringify(savedData_data)
	
	# Store the save dictionary as a new line in the save file.
	savedData_file.store_line(json_string)


func savedData_load():
	if not FileAccess.file_exists("user://savedData.save"):
		print("Couldn't find the save file (savedData - All of the overworld progress).")
		return # Error! We don't have a save to load.
		
	var savedData_file = FileAccess.open("user://savedData.save", FileAccess.READ)
	while savedData_file.get_position() < savedData_file.get_length():
		var json_string = savedData_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var data = json.get_data()
		
		#LOAD SAVED PROPERTIES
		
		saved_last_area_filePath = data["saved_last_area_filePath"]
		
		saved_position_x = data["saved_position_x"]
		saved_position_y = data["saved_position_y"]
		saved_score = data["saved_score"]
		
		saved_weapon = data["saved_weapon"]
		saved_weapon_delay = data["saved_weapon_delay"]
		saved_secondaryWeapon = data["saved_secondaryWeapon"]
		saved_secondaryWeapon_delay = data["saved_secondaryWeapon_delay"]
		
		saved_weapon_basic = data["saved_weapon_basic"]
		saved_weapon_veryFast_speed = data["saved_weapon_veryFast_speed"]
		saved_weapon_ice = data["saved_weapon_ice"]
		saved_weapon_fire = data["saved_weapon_fire"]
		saved_weapon_destructive_fast_speed = data["saved_weapon_destructive_fast_speed"]
		saved_weapon_short_shotDelay = data["saved_weapon_short_shotDelay"]
		saved_weapon_phaser = data["saved_weapon_phaser"]
		saved_secondaryWeapon_basic = data["saved_secondaryWeapon_basic"]
		saved_secondaryWeapon_fast = data["saved_secondaryWeapon_fast"]
		
		saved_bg_File_current = data["saved_bg_File_current"]
		saved_bg_a_File_current = data["saved_bg_a_File_current"]
		saved_bg_b_File_current = data["saved_bg_b_File_current"]
		saved_bgOffset_target_x = data["saved_bgOffset_target_x"]
		saved_bgOffset_target_y = data["saved_bgOffset_target_y"]
		saved_music_file = data["saved_music_file"]
		saved_ambience_file = data["saved_ambience_file"]
		saved_music_isPlaying = data["saved_music_isPlaying"]
		saved_ambience_isPlaying = data["saved_ambience_isPlaying"]
		
		#saved_propertyName = data["saved_propertyName"]
		
		never_saved = data["never_saved"]
		
		#LOAD SAVED PROPERTIES END



#SAVE START

func savedData_save_dictionary():
	var save_dict = {
		#saved properties
		"saved_last_area_filePath" : saved_last_area_filePath,
		
		"saved_position_x" : saved_position_x,
		"saved_position_y" : saved_position_y,
		"saved_score" : saved_score,
		
		"saved_weapon" : saved_weapon,
		"saved_weapon_delay" : saved_weapon_delay,
		"saved_secondaryWeapon" : saved_secondaryWeapon,
		"saved_secondaryWeapon_delay" : saved_secondaryWeapon_delay,
		
		"saved_weapon_basic" : saved_weapon_basic,
		"saved_weapon_veryFast_speed" : saved_weapon_veryFast_speed,
		"saved_weapon_ice" : saved_weapon_ice,
		"saved_weapon_fire" : saved_weapon_fire,
		"saved_weapon_destructive_fast_speed" : saved_weapon_destructive_fast_speed,
		"saved_weapon_short_shotDelay" : saved_weapon_short_shotDelay,
		"saved_weapon_phaser" : saved_weapon_phaser,
		"saved_secondaryWeapon_basic" : saved_secondaryWeapon_basic,
		"saved_secondaryWeapon_fast" : saved_secondaryWeapon_fast,
		
		"saved_bg_File_current" : saved_bg_File_current,
		"saved_bg_a_File_current" : saved_bg_a_File_current,
		"saved_bg_b_File_current" : saved_bg_b_File_current,
		"saved_bgOffset_target_x" : saved_bgOffset_target_x,
		"saved_bgOffset_target_y" : saved_bgOffset_target_y,
		"saved_music_file" : saved_music_file,
		"saved_ambience_file" : saved_ambience_file,
		"saved_music_isPlaying" : saved_music_isPlaying,
		"saved_ambience_isPlaying" : saved_ambience_isPlaying,
		
		#"saved_propertyName" : saved_propertyName,
		
		"never_saved" : never_saved,
	
	}
	return save_dict

#SAVE END
