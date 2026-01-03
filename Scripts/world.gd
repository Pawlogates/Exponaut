extends Node2D

@export var next_level: PackedScene

@onready var Player = $Player
@onready var camera = Player.camera
@onready var hud = Node

var debug_screen: Control # Added and deleted on demand.

@onready var screen_levelFinished = Node

@onready var hud_level_time = Node
@onready var hud_player_health = Node
@onready var hud_collected_keys = Node
@onready var hud_total_keys = Node

#@export_file("*.tscn") var level_filePath: String
var level_filepath = scene_file_path

# Change this value (String) only if its an overworld level.
var level_overworld_id = "none" # Leave it unchanged if its a levelSet level, so that the name will be fetched from "SaveData".

var level_time = 0
var level_time_displayed = 0
var level_start_time = 0.0

@onready var music_manager = $"Music Manager"
@onready var ambience_manager = $"Ambience Manager"

@onready var tileset_main = $tileset_main
@onready var tileset_objects = Node
@onready var tileset_objects_precise = Node

@export var camera_boundary_left = 0.0
@export var camera_boundary_right = 0.0
@export var camera_boundary_bottom = 0.0
@export var camera_boundary_top = 0.0

@export_enum("levelSet", "overworld", "debug") var level_type : String = "levelSet"

@export var final_level = false

@export var player_start_health = 3

var total_keys = 0
var total_collectibles = 0
var total_majorCollectibles = 0

var collected_keys = 0
var collected_collectibles = 0
var collected_majorCollectibles = 0

var bg_instant_transitions = true
var bg_instant_offset = true

@export var night = 0.0 # This variable affects the day-night cycle's visual and gameplay effects.

# Weather effects:
var scene_rain = preload("res://Other/Scenes/Weather/rain.tscn")
var scene_leaves = preload("res://Other/Scenes/Weather/leaves.tscn")

@export var weather_rain = false
@export var weather_leaves = false


# Main level info:
@export var levelSet_id = "none"
@export var level_number = -1


@export var force_mode_scoreAttack = false
@export var force_mode_memeMode = false

@export var delete_background_layers = false

@export var neon_hueShift = 0.6
@export var neon_fade = false
@export var neon_fade_cooldown = 15.0
@export var neon_rainbow = false

var neon_fade_in = false # The value of "true" means that neon blocks are fading into their assigned color, while "false" means they are going back to normal.

@export var background_color : Color = Color(0, 0, 0, 0) # Note that this doesn't affect the image-based background layers.

@export var scoreAttack_target_collectible_amount = -1
@export var scoreAttack_target_time = -1

var quickload_blocked = true
var quicksave_blocked = true


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.level_started.emit()
	
	#if Globals.gameState_debug: # False if the game is currently being worked on.
		#SaveData.delete_progress()
		#Globals.message_debug("Deleted all save files on entering a level.")
	
	if level_type == "levelSet":
		Globals.levelSet_id = levelSet_id
		Globals.level_number = level_number
		Globals.level_id = levelSet_id + "_" + str(level_number)
		Globals.level_name = SaveData.get("info" + Globals.level_id)
	
	elif level_type == "overworld":
		Globals.levelSet_id = levelSet_id
		Globals.level_number = -1 # Because its an overworld segment.
		Globals.level_id = level_overworld_id # Because its an overworld segment.
		Globals.level_name = "none" # Because its an overworld segment.
	
	elif level_type == "debug":
		pass
	
	if level_overworld_id != "none":
		Globals.level_id = level_overworld_id
	
	Globals.material_neon_hueShift.set_shader_parameter("Shift_Hue", neon_hueShift)
	
	if random_music:
		play_music_random()
	
	Overlay.screen_black.color.a = 1.0
	
	
	if Globals.level_id != "factory_a_1": # This should not be the main way to check whether the current game was started for the first time.
		Globals.worldState_leftStartArea = true
	
	
	last_area_filePath_save()
	
	if Globals.mode_scoreAttack:
		var mode_scoreAttack_manager = load("res://Other/Scenes/Game Modes/mode_score_attack.tscn").instantiate()
		add_child(mode_scoreAttack_manager)
		%music.stream = preload("res://Assets/Sounds/music/mode_scoreAttack.mp3")
		%music.volume_db = -3
		%music.play()
	
	#%bg_current.queue_free() #DEBUG
	#%bg_previous.queue_free() #DEBUG
	
	#$tileset_objects.queue_free() #DEBUG
	#$tileset_objectsSmall.queue_free() #DEBUG
	
	if camera_boundary_left != 0.0 or camera_boundary_right != 0.0 or camera_boundary_top != 0.0 or camera_boundary_bottom != 0.0:
		Player.camera.limit_left = camera_boundary_left
		Player.camera.limit_right = camera_boundary_right
		Player.camera.limit_bottom = camera_boundary_bottom
		Player.camera.limit_top = camera_boundary_top
	
	
	get_tree().paused = false
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_streak = 0
	Globals.combo_tier = 0
	
	#tileset_objects.set_layer_enabled(0, true)
	#tileset_objects.set_layer_enabled(1, true)
	#tileset_objects.set_layer_enabled(2, true)
	#tileset_objects.set_layer_enabled(3, true)
	#tileset_objects.set_layer_enabled(4, true)
	
	#tileset_objects_precise.set_layer_enabled(0, true)
	#tileset_objects_precise.set_layer_enabled(1, true)
	#tileset_objects_precise.set_layer_enabled(2, true)
	#tileset_objects_precise.set_layer_enabled(3, true)
	#tileset_objects_precise.set_layer_enabled(4, true)
	
	Globals.player_health = player_start_health
	Globals.update_player_health.emit()
	
	#if not Player.scale.x == 1 or not Player.scale.y == 1:
		#Player.scale.x = 1
		#Player.scale.y = 1
	
	
	level_start_time = Time.get_ticks_msec()
	
	Globals.level_finished.connect(show_screen_levelFinished)
	
	
	Globals.bg_file_previous = "res://Assets/Graphics/backgrounds/bg_fields.png"
	Globals.bg_file_current = "res://Assets/Graphics/backgrounds/bg_fields.png"
	
	Globals.trigger_bg_change_entered.connect(bg_change_check)
	Globals.trigger_bg_move_entered.connect(bg_move_check)
	
	
	Globals.transformation_activated.connect(reassign_player)
	
	#if not next_level is PackedScene:
		#level_finished.next_level_btn.text = "Results"
		#next_level = preload("res://VictoryScreen.tscn")
	
	
	RenderingServer.set_default_clear_color(background_color)
	
	
	if Globals.debug_mode:
		Globals.playerHP = 250
	
	if weather_rain == true:
		Player.camera.add_child(scene_rain.instantiate())
	if weather_leaves == true:
		Player.camera.add_child(scene_leaves.instantiate())
	
	#Globals.cheated_state = false
	
	if bg_instant_transitions:
		%bg_previous/bg_transition.speed_scale = 20
		%bg_previous/bg_a_transition.speed_scale = 20
		%bg_previous/bg_b_transition.speed_scale = 20
	
		%bg_current/bg_transition.speed_scale = 20
		%bg_current/bg_a_transition.speed_scale = 20
		%bg_current/bg_b_transition.speed_scale = 20
	
	
	# REMEMBER TO GIVE EACH TRANSITION A UNIQUE NAME (%) AND HAVE ITS ID BE IN THE NAME AT THE END TOO (areaTransition1, areaTransition2, etc.).
	if not level_type == "levelSet" and Globals.transitioned and Globals.next_transition != 0:
		var areaTransition = get_node("%areaTransition" + str(Globals.next_transition))
		if areaTransition.spawn_position != Vector2(0, 0):
			print(areaTransition.spawn_position)
			Player.position = areaTransition.spawn_position
		else:
			print(areaTransition.position)
			Player.position = areaTransition.position
	
	
	if not level_type == "levelSet" and not Globals.worldState_justStartedNewGame: 
		SaveData.load_playerData() # Loads player related progress, doesn't conflict with load_levelState().
	
	
	Player.camera.position_smoothing_enabled = false
	
	
	if force_mode_memeMode:
		$/root/World/HUD.visible = false
		
		var meme_mode_SubViewportContainer = SubViewportContainer
		var meme_mode_SubViewportContainer_spawned = meme_mode_SubViewportContainer.new()
		meme_mode_SubViewportContainer_spawned.name = "SubViewportContainer"
		meme_mode_SubViewportContainer_spawned.size = Vector2(1920, 1080)
		var meme_mode_SubViewport = SubViewport
		var meme_mode_SubViewport_spawned = meme_mode_SubViewport.new()
		meme_mode_SubViewport_spawned.name = "SubViewport"
		meme_mode_SubViewport_spawned.size = Vector2(1920, 1080)
		meme_mode_SubViewportContainer_spawned.add_child(meme_mode_SubViewport_spawned)
		add_child(meme_mode_SubViewportContainer_spawned)
		
		var memeMode_controller = preload("res://Other/Game Modes/Meme Mode/meme_mode_controller.tscn").instantiate()
		add_child(memeMode_controller)
	
	
	if neon_rainbow:
		if neon_fade_in:
			$whiteBlocks_make_rainbow.play("fade_out")
			$whiteBlocks_make_rainbow/Timer.wait_time = neon_fade_cooldown
			$whiteBlocks_make_rainbow/Timer.start()
		else:
			$whiteBlocks_make_rainbow.play("fade_in")
	
	await get_tree().create_timer(0.2, false).timeout
	
	if not Globals.transition_triggered:
		save_game()
	
	Globals.transition_triggered = false
	
	if level_overworld_id != "none":
		SaveData.load_levelState(level_overworld_id) # Loads states for all level objects, doesn't conflict with load_saved_playerData().
	
	handle_night()
	
	Player.camera.position_smoothing_enabled = true
	
	if delete_background_layers:
		bg_deleted = true
		%bg_current.queue_free()
		%bg_previous.queue_free()
		$ParallaxBackgroundGradient.queue_free()
	
	if force_mode_memeMode:
		var memeMode_background_video_player = preload("res://Other/Game Modes/Meme Mode/background_video_Player.tscn").instantiate()
		memeMode_background_video_player.position = Player.position + Vector2(-960, -540)
		add_child(memeMode_background_video_player)
	
	await Overlay.animation("fade_black", false, true, 1.0)
	
	teleporter_assign_ID()
	
	bg_instant_transitions = false
	
	if not bg_deleted:
		%bg_previous/bg_transition.speed_scale = 1
		%bg_previous/bg_a_transition.speed_scale = 1
		%bg_previous/bg_b_transition.speed_scale = 1
		
		%bg_current/bg_transition.speed_scale = 1
		%bg_current/bg_a_transition.speed_scale = 1
		%bg_current/bg_b_transition.speed_scale = 1
	
	#await get_tree().create_timer(0.2, false).timeout
	
	if level_type == "overworld":
		SaveData.save_levelState("quicksave")
	
	quickload_blocked = false
	$QuickloadLimiter.start()
	
	Globals.worldState_justStartedNewGame = false
	
	if level_overworld_id != "overworld_factory":
		SaveData.never_saved = false


#MAIN START
func _physics_process(delta):
	get_tree().paused = false
	
	# Current level's playtime.
	level_time = Time.get_ticks_msec() - level_start_time
	level_time_displayed = level_time / 1000.0
	Globals.level_time = level_time_displayed
	
	#if level_time_displayed > 10000:
		#level_timeDisplay.visible_characters = 7
	#elif level_time_displayed > 1000:
		#level_timeDisplay.visible_characters = 6
	#elif level_time_displayed > 100:
		#level_timeDisplay.visible_characters = 5
	#elif level_time_displayed > 10:
		#level_timeDisplay.visible_characters = 4
	#else:
		#level_timeDisplay.visible_characters = 3
	
	
	if Globals.settings_quicksaves and Input.is_action_just_pressed("quicksave") and not quickload_blocked:
		quickload_blocked = true
		save_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
		
		await get_tree().create_timer(1.0, false).timeout
		Globals.is_saving = false
	
	if Globals.settings_quicksaves and Input.is_action_just_pressed("quickload") and not quickload_blocked:
		quickload_blocked = true
		load_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
		
		
		await get_tree().create_timer(1.0, false).timeout
		Globals.is_saving = false
	
	
	#HANDLE BACKGROUND MOVEMENT
	bg_move(delta)
	
	if Input.is_action_just_pressed("restart"):
		retry()
#MAIN END

var night_toggle = true
var bg_deleted = false

#HANDLE REDUCE PLAYER HP
func handle_player_death():
	Player.dead = true
	Player.sfx_death.play()
	if level_type == "levelSet":
		#if Globals.quicksaves_enabled:
			#retry_loadSave(true)
		if Globals.mode_scoreAttack:
			change_main_scene_levelSet()
		else:
			retry_checkpoint()
	else:
		retry_checkpoint()


# HANDLE LEVEL EXIT REACHED (unused?)
func _on_exitReached_next_level():
	#Globals.total_score = Globals.total_score + Globals.level_score
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	go_to_next_level()


func _on_exitReached_retry():
	retry()


func show_screen_levelFinished():
	
	if not Globals.mode_scoreAttack:
		screen_levelFinished.show()
		screen_levelFinished.retry_btn.grab_focus()
		%"Level Finished".exit_reached()
		
		get_tree().paused = true
	
	
	elif Globals.mode_scoreAttack:
		if scoreAttack_target_collectible_amount != -1:
			if Globals.collected_collectibles >= scoreAttack_target_collectible_amount:
				screen_levelFinished.show()
				screen_levelFinished.retry_btn.grab_focus()
				
				get_tree().paused = true
		
			else:
				Globals.infoSign_current_text = "You need at least 750 collectibles to finish the level!"
				Globals.infoSign_current_size = 2
				Globals.info_sign_touched.emit()
		
		
		else:
			screen_levelFinished.show()
			screen_levelFinished.retry_btn.grab_focus()
			%"Level Finished".exit_reached()
			
			get_tree().paused = true


func go_to_next_level(): #unused?
	
	if not next_level is PackedScene: return
	
	Overlay.animation("fade_black", true, 1.0, true)
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0


func retry():
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("collectibles", "queue_free")
	get_tree().call_group("bonusBox", "queue_free")
	get_tree().call_group("Persist", "queue_free")
	
	get_tree().paused = true
	Overlay.animation("fade_black", true, 1.0, true)
	get_tree().reload_current_scene()
	#get_tree().change_scene_to_file(scene_file_path)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.combo_streak = 0
	
	Globals.player_health = player_start_health


func retry_loadSave(afterDelay):
	await get_tree().create_timer(0.1, false).timeout
	Globals.player_health = player_start_health
	
	
	if afterDelay:
		Player.dead = true
		
		var star = Globals.scene_particle_star.instantiate()
		star.position = Globals.player_pos
		add_child(star)
		star = Globals.scene_particle_star.instantiate()
		star.position = Globals.player_pos
		add_child(star)
		star = Globals.scene_particle_star.instantiate()
		star.position = Globals.player_pos
		add_child(star)
		
		await get_tree().create_timer(2, false).timeout
	
	
	Player.dead = false
	
	Player.scale.x = 1
	Player.scale.y = 1
	
	load_game()


func bg_move(delta):
	if not bg_instant_transitions and bg_move_active and not bg_deleted:
		%bg_previous/CanvasLayer/bg_main.offset.x = move_toward(%bg_previous/CanvasLayer/bg_main.offset.x, Globals.bgOffset_target_x, delta)
		%bg_previous/CanvasLayer/bg_main.offset.y = move_toward(%bg_previous/CanvasLayer/bg_main.offset.y, Globals.bgOffset_target_y, delta)
		
		%bg_current/CanvasLayer/bg_main.offset.x = move_toward(%bg_previous/CanvasLayer/bg_main.offset.x, Globals.bgOffset_target_x, delta)
		%bg_current/CanvasLayer/bg_main.offset.y = move_toward(%bg_previous/CanvasLayer/bg_main.offset.y, Globals.bgOffset_target_y, delta)
		
		#bg_a
		
		%bg_previous/CanvasLayer/bg_a.offset.x = move_toward(%bg_previous/CanvasLayer/bg_a.offset.x, Globals.bg_a_Offset_target_x, delta)
		%bg_previous/CanvasLayer/bg_a.offset.y = move_toward(%bg_previous/CanvasLayer/bg_a.offset.y, Globals.bg_a_Offset_target_y, delta)
		
		%bg_current/CanvasLayer/bg_a.offset.x = move_toward(%bg_previous/CanvasLayer/bg_a.offset.x, Globals.bg_a_Offset_target_x, delta)
		%bg_current/CanvasLayer/bg_a.offset.y = move_toward(%bg_previous/CanvasLayer/bg_a.offset.y, Globals.bg_a_Offset_target_y, delta)
		
		#bg_b
		
		%bg_previous/CanvasLayer/bg_b.offset.x = move_toward(%bg_previous/CanvasLayer/bg_b.offset.x, Globals.bg_b_Offset_target_x, delta)
		%bg_previous/CanvasLayer/bg_b.offset.y = move_toward(%bg_previous/CanvasLayer/bg_b.offset.y, Globals.bg_b_Offset_target_y, delta)
		
		%bg_current/CanvasLayer/bg_b.offset.x = move_toward(%bg_previous/CanvasLayer/bg_b.offset.x, Globals.bg_b_Offset_target_x, delta)
		%bg_current/CanvasLayer/bg_b.offset.y = move_toward(%bg_previous/CanvasLayer/bg_b.offset.y, Globals.bg_b_Offset_target_y, delta)


# Background change.
var bg_free_to_change = true

func bg_change():
	await Globals.bg_transition_finished
	
	if bg_free_to_change:
		bg_free_to_change = false
		Globals.message_debug("Background textures began fading.")
		
		%bg_previous/bg_transition.play("bg_hide")
		%bg_previous/bg_a_transition.play("bg_a_hide")
		%bg_previous/bg_b_transition.play("bg_b_hide")
		
		%bg_current/CanvasLayer/bg_main/bg_main/TextureRect.texture = load(Globals.bg_file_current)
		%bg_current/CanvasLayer/bg_a/bg_a/TextureRect.texture = load(Globals.bg_a_file_current)
		%bg_current/CanvasLayer/bg_b/bg_b/TextureRect.texture = load(Globals.bg_b_file_current)
		
		%bg_current/bg_transition.play("bg_show")
		%bg_current/bg_a_transition.play("bg_a_show")
		%bg_current/bg_b_transition.play("bg_b_show")
		
		%bg_current.name = "bg_TEMP"
		%bg_previous.name = "bg_current"
		%bg_TEMP.name = "bg_previous"
		
		
		await Globals.bgTransition_finished
		bg_free_to_change = true


var bg_move_active = false
var bg_change_active = false

func bg_move_check():
	if %bg_previous/CanvasLayer/bg_main.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg_main.offset.y == Globals.bgOffset_target_y and %bg_previous/CanvasLayer/bg_a.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg_a.offset.y == Globals.bgOffset_target_y and %bg_previous/CanvasLayer/bg_b.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg_b.offset.y == Globals.bgOffset_target_y:
		bg_move_active = false
	else:
		bg_move_active = true

func bg_change_check():
	bg_change_active = false


var last_checkpoint_pos = Vector2(0, 0)

#Save state
func save_game():
	#if Globals.combo_score != 0:
		#await Globals.comboReset
	
	var save_gameFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("Persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("Persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_gameFile.store_line(json_string)
	
	
	await get_tree().create_timer(0.1, false).timeout
	
	if last_checkpoint_pos == Vector2(0, 0):
		SaveData.saved_position_x = Globals.player_position.x
		SaveData.saved_position_y = Globals.player_position.y
	else:
		SaveData.saved_position_x = last_checkpoint_pos[0]
		SaveData.saved_position_y = last_checkpoint_pos[1]
	
	Globals.levelState_saved.emit()


func load_game():
	if SaveData.never_saved:
		return
	
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		#if i.is_in_group(Globals.loadingZone_current) or i.is_in_group("loadingZone0"):
		i.queue_free()

	var save_gameFile = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_gameFile.get_position() < save_gameFile.get_length():
		var json_string = save_gameFile.get_line()

		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data = json.get_data()
		
		#if "loadingZone" in node_data and node_data["loadingZone"] == Globals.loadingZone_current or "loadingZone" in node_data and node_data["loadingZone"] == "loadingZone0":
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		
		#else:
			#continue
	
	
	#Player.position.x = Globals.saved_player_posX
	#Player.position.y = Globals.saved_player_posY
	#Globals.level_score = Globals.saved_level_score
	
	Globals.level_score = Globals.saved_level_score
	Player.position = Vector2(Globals.saved_player_posX, Globals.saved_player_posY)
	
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.saveState_loaded.emit()


func _on_quickload_limiter_timeout():
	quickload_blocked = false

func saved_from_outside():
	quickload_blocked = true
	$QuickloadLimiter.stop()
	await get_tree().create_timer(0.2, false).timeout
	save_game()
	$QuickloadLimiter.start()


func _on_debug_refresh_timeout():
	if get_node_or_null("HUD/Debug Screen"):
		$"HUD/Debug Screen".refresh_debugInfo()
	
	Globals.combo_streak = Globals.total_collectibles_in_currentLevel - get_tree().get_nodes_in_group("Collectibles").size() - (get_tree().get_nodes_in_group("bonusBox").size() * 10)
	#%TotalCollectibles_collected.text = str(Globals.collected_collectibles) + "/" + str(Globals.collectibles_in_this_level)


#NIGHT/DAY TIME
#func night_tileset_toggle():
	#if night_toggle:
		#night_toggle = false
		#%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night2.png")
		#%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night2.png")
		#for object in get_tree().get_nodes_in_group("Persist"):
			#object.modulate.r = 0.8
		#for object in get_tree().get_nodes_in_group("player"):
			#object.modulate.r = 0.8
		#for object in get_tree().get_nodes_in_group("button_block"):
			#object.modulate.r = 0.8
		#for object in get_tree().get_nodes_in_group("button"):
			#object.modulate.r = 0.8
		#for object in get_tree().get_nodes_in_group("bonusBox"):
			#object.modulate.r = 0.8
			#
	#else:
		#night_toggle = true
		#%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset.png")
		#%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations.png")
		#for object in get_tree().get_nodes_in_group("Persist"):
			#object.modulate.r = 1.0
		#for object in get_tree().get_nodes_in_group("player"):
			#object.modulate.r = 1.0
		#for object in get_tree().get_nodes_in_group("button_block"):
			#object.modulate.r = 1.0
		#for object in get_tree().get_nodes_in_group("button"):
			#object.modulate.r = 1.0
		#for object in get_tree().get_nodes_in_group("bonusBox"):
			#object.modulate.r = 1.0


func set_night():
	night_toggle = false
	%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night.png")
	%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 0.8


func set_night2():
	night_toggle = false
	%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night2.png")
	%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night2.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 0.8


func set_night3():
	night_toggle = false
	%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night3.png")
	%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night3.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 0.8


func set_day():
	pass
	#night_toggle = true
	#%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset.png")
	#%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations.png")
	#for object in get_tree().get_nodes_in_group("Persist"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("player"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("button_block"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("button"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("bonusBox"):
		#object.modulate.r = 1.0


func handle_night():
	pass
	#await get_tree().create_timer(0.1, false).timeout
	
	#for object in get_tree().get_nodes_in_group("Persist"):
		#object.modulate.r = 0.8
	#for object in get_tree().get_nodes_in_group("player"):
		#object.modulate.r = 0.8
	#for object in get_tree().get_nodes_in_group("button_block"):
		#object.modulate.r = 0.8
	#for object in get_tree().get_nodes_in_group("button"):
		#object.modulate.r = 0.8
	#for object in get_tree().get_nodes_in_group("bonusBox"):
		#object.modulate.r = 0.8
	#
	#
	#$ParallaxBackgroundGradient/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.modulate.r = 0.1
	#$ParallaxBackgroundGradient/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.modulate.a = 0.2
	#
	#
	#for object in get_tree().get_nodes_in_group("Persist"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("player"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("button_block"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("button"):
		#object.modulate.r = 1.0
	#for object in get_tree().get_nodes_in_group("bonusBox"):
		#object.modulate.r = 1.0


func teleporter_assign_ID():
	
	var teleporter_type = "blue"
	var teleporter_ID = 1
	
	for teleporter in get_tree().get_nodes_in_group(str(teleporter_type)):
		
		teleporter.add_to_group(str(str(teleporter_type), str(teleporter_ID)))
		teleporter_ID += 1
	
	
	teleporter_type = "red"
	teleporter_ID = 1
	
	for teleporter in get_tree().get_nodes_in_group(str(teleporter_type)):
		
		teleporter.add_to_group(str(str(teleporter_type), str(teleporter_ID)))
		teleporter_ID += 1
	
	
	teleporter_type = "green"
	teleporter_ID = 1
	
	for teleporter in get_tree().get_nodes_in_group(str(teleporter_type)):
		
		teleporter.add_to_group(str(str(teleporter_type), str(teleporter_ID)))
		teleporter_ID += 1


func change_main_scene_levelSet():
	effect_stars()
	await get_tree().create_timer(4, false).timeout
	Globals.change_main_scene(Globals.scene_levelSet_screen)

func change_main_scene_menu_start():
	effect_stars()
	await get_tree().create_timer(4, false).timeout
	Globals.change_main_scene(Globals.scene_menu_start)


func retry_checkpoint():
	Overlay.animation("fade_black", false, 1.0, true)
	retry_load_levelState()
	retry_load_playerData()
	Globals.player_health = player_start_health
	Player.dead = false


func retry_load_levelState():
	pass
	#SaveData.load_levelState()


func retry_load_playerData():
	pass


func effect_stars():
	var star = Globals.scene_particle_star.instantiate()
	star.position = Globals.player_pos
	add_child(star)
	star = Globals.scene_particle_star.instantiate()
	star.position = Globals.player_pos
	add_child(star)
	star = Globals.scene_particle_star.instantiate()
	star.position = Globals.player_pos
	add_child(star)


# Save progress loaded from the main menu screen.
func last_area_filePath_save():
	if level_type != "overworld":
		return
	
	SaveData.saved_last_area_filePath = level_filepath
	Globals.message("Changing last overworld level filepath to " + str(SaveData.level_filepath))


func reassign_player():
	Player = get_tree().get_first_node_in_group("player_root")
	camera = get_tree().get_first_node_in_group("player_camera")
	if level_type == "overworld":
		get_tree().get_first_node_in_group("quickselect_screen").reassign_player()


func _on_timer_timeout() -> void:
	if neon_fade_in:
		neon_fade_in = false
		$whiteBlocks_make_rainbow.play("fade_out")
		Globals.message("Neon blocks are fading out.")
	else:
		neon_fade_in = true
		$whiteBlocks_make_rainbow.play("fade_in")
		Globals.message("Neon blocks are fading in.")


func debug_screen_delete():
	debug_screen = $"HUD/Debug Screen"
	
	if not get_node_or_null("HUD/Debug Screen"):
		return
	
	debug_screen.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


@export var random_music = false

func play_music_random():
	Globals.play_music_random.emit()


var playing = false

func screen_shake():
	if playing : return
	playing = true
	
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	
	tween.tween_property(camera, "position", Vector2(randi_range(-150, 150), randi_range(-150, 150)), 0.05)
	tween.tween_property(camera, "position", Vector2(randi_range(-150, 150), randi_range(-150, 150)), 0.05)
	tween.tween_property(camera, "position", Vector2(0, 0), 1)
	tween2.tween_property(camera, "zoom", Vector2(1.1, 1.1), 0.1)
	tween2.tween_property(camera, "zoom", Vector2(1, 1), 0.25)
	tween2.tween_property(self, "playing", false, 0)


func _input(event):
	if get_node_or_null("HUD/touch_controls"):
		return
	
	if "Screen" in str(event):
		for present_touch_controls in get_tree().get_nodes_in_group("touch_controls"):
			present_touch_controls.queue_free()
		
		var touch_controls = preload("res://Other/Scenes/touch_controls.tscn").instantiate()
		#hud.add_child(touch_controls)
