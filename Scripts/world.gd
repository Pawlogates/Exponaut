extends Node2D

@onready var camera = %Player.camera

@export var next_level: PackedScene

@onready var player = %Player

@onready var hud = %HUD
var debug_screen: Control #Added and deleted on demand.

@onready var level_finished = %"Level Finished"

@onready var level_timeDisplay = %levelTime
@onready var healthDisplay = %health
@onready var keys_leftDisplay = %keysLeft

@export_file("*.tscn") var savedProgress_level_filePath: String
var savedProgress_nextTransition = Globals.next_transition

var levelTime = 0
var start_level_msec = 0.0
var levelTime_visible = 0

@onready var music = $"Music Controller"/music
@onready var ambience = $"Ambience Controller"/ambience
@onready var music_controller = $"Music Controller"
@onready var ambience_controller = $"Ambience Controller"

var material_hueShift_neonBlock_material = preload("res://Other/Materials/hueShift_neonBlock.tres")

@onready var tileset_main = $tileset_main
@onready var tileset_objects = $tileset_objects
@onready var tileset_objects_small = $tileset_objectsSmall

@export var cameraLimit_left = 0.0
@export var cameraLimit_right = 0.0
@export var cameraLimit_bottom = 0.0
@export var cameraLimit_top = 0.0

@export var regular_level = true
@export var shrine_level = false
@export var final_level = false

@export var playerStartHP = 3
var key_total = 50

@export var scoreAttack_collectibles = -1

var instant_background_transitions = true

@export var night = false
@export var night2 = false
@export var night3 = false

var rain_scene = preload("res://Other/Scenes/Weather/weather_rain.tscn")
var leaves_scene = preload("res://Other/Scenes/Weather/weather_leaves.tscn")

@export var rain = false
@export var leaves = false

@export var selected_episode = "none"
@export var level_ID = "none"
@export var level_number = -1

@export var meme_mode = false

@export var delete_background_layers = false

@export var whiteBlocks_make_rainbow = false
@export var whiteBlocks_toggleBetween = false
@export var whiteBlocks_toggleBetween_delay = 45.0

var whiteBlocks_toggle = false

@export var neonBlocks_hueShift = 0.0

@export var background_color : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	material_hueShift_neonBlock_material.set_shader_parameter("Shift_Hue", neonBlocks_hueShift)
	
	Globals.gameplay_recorder_entered_level.emit()
	
	if random_music:
		play_random_music()
	
	LevelTransition.blackScreen.color.a = 1.0
	
	
	if area_ID != "overworld_factory":
		Globals.left_start_area = true
	
	if shrine_level or regular_level:
		Globals.selected_episode = selected_episode #normal/shrine_selected_episode
		Globals.current_level_ID = level_ID #normal/shrine_level_ID
		Globals.current_level_number = level_number #normal/shrine_level_number
	
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
	
	if cameraLimit_left != 0.0 or cameraLimit_right != 0.0 or cameraLimit_top != 0.0 or cameraLimit_bottom != 0.0:
		%Player/%Camera2D.limit_left = cameraLimit_left
		%Player/%Camera2D.limit_right = cameraLimit_right
		%Player/%Camera2D.limit_bottom = cameraLimit_bottom
		%Player/%Camera2D.limit_top = cameraLimit_top
	
	
	get_tree().paused = false
	
	Globals.save.connect(saved_from_outside)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.collected_in_cycle = 0
	Globals.combo_tier = 0
	
	%HUD.visible = true
	
	tileset_objects.set_layer_enabled(0, true)
	tileset_objects.set_layer_enabled(1, true)
	tileset_objects.set_layer_enabled(2, true)
	tileset_objects.set_layer_enabled(3, true)
	tileset_objects.set_layer_enabled(4, true)
	
	tileset_objects_small.set_layer_enabled(0, true)
	tileset_objects_small.set_layer_enabled(1, true)
	tileset_objects_small.set_layer_enabled(2, true)
	tileset_objects_small.set_layer_enabled(3, true)
	tileset_objects_small.set_layer_enabled(4, true)
	
	
	Globals.playerHP = playerStartHP
	healthDisplay.text = str("HP:", Globals.playerHP)
	
	if not player.scale.x == 1 or not player.scale.y == 1:
		player.scale.x = 1
		player.scale.y = 1
	
	
	start_level_msec = Time.get_ticks_msec()
	
	Globals.playerHit1.connect(reduceHp1)
	Globals.playerHit2.connect(reduceHp2)
	Globals.playerHit3.connect(reduceHp3)
	Globals.kill_player.connect(kill_player)
	Globals.increaseHp1.connect(increaseHp1)
	Globals.increaseHp2.connect(increaseHp2)
	
	Globals.exitReached.connect(exitReached_show_screen)
	
	
	Globals.bg_File_previous = "res://Assets/Graphics/backgrounds/bg_fields.png"
	Globals.bg_File_current = "res://Assets/Graphics/backgrounds/bg_fields.png"
	
	Globals.bgChange_entered.connect(bg_change)
	Globals.bgMove_entered.connect(bg_move)
	
	
	Globals.player_transformed.connect(reassign_player)
	
	#if not next_level is PackedScene:
		#level_finished.next_level_btn.text = "Results"
		#next_level = preload("res://VictoryScreen.tscn")
	
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	RenderingServer.set_default_clear_color(background_color)
	
	
	if Globals.debug_mode:
		Globals.playerHP = 250
	
	
	if night3 == true:
		%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night3.png")
		%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night3.png")
		
	elif night2 == true:
		%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night2.png")
		%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night2.png")
		
	elif night == true:
		%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night.png")
		%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night.png")
	
	else:
		%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset.png")
		%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations.png")
	
	
	if rain == true:
		player.camera.add_child(rain_scene.instantiate())
	if leaves == true:
		player.camera.add_child(leaves_scene.instantiate())
	
	#Globals.cheated_state = false
	
	if instant_background_transitions:
		%bg_previous/bg_transition.speed_scale = 20
		%bg_previous/bg_a_transition.speed_scale = 20
		%bg_previous/bg_b_transition.speed_scale = 20
	
		%bg_current/bg_transition.speed_scale = 20
		%bg_current/bg_a_transition.speed_scale = 20
		%bg_current/bg_b_transition.speed_scale = 20
		
		bgMove_growthSpeed = 100
	
	
	#REMEMBER TO GIVE EACH TRANSITION A UNIQUE NAME (%) AND HAVE ITS ID BE IN THE NAME AT THE END TOO (areaTransition1, areaTransition2, etc.)
	if not regular_level and Globals.transitioned and Globals.next_transition != 0:
		var areaTransition = get_node("%areaTransition" + str(Globals.next_transition))
		if areaTransition.spawn_position != Vector2(0, 0):
			print(areaTransition.spawn_position)
			player.position = areaTransition.spawn_position
		else:
			print(areaTransition.position)
			player.position = areaTransition.position
	
	
	if not regular_level and not Globals.just_started_new_game and Globals.load_saved_position: 
		load_saved_progress_overworld() #loads player related progress, doesn't conflict with load_game_area()
	
	
	player.camera.position_smoothing_enabled = false
	
	if meme_mode:
		$meme_mode_timer.start()
		$/root/World/HUD.visible = false
		
		var meme_spawner = preload("res://Meme Mode/memeMode_image_spawner.tscn").instantiate()
		meme_spawner.randomize_all = true
		meme_spawner.position = Vector2(player.position.x + randi_range(-800, 800), player.position.y + randi_range(-500, 500))
		add_child(meme_spawner)
	
	if whiteBlocks_make_rainbow:
		if whiteBlocks_toggleBetween:
			$whiteBlocks_make_rainbow.play("fade_out")
			$whiteBlocks_make_rainbow/Timer.wait_time = whiteBlocks_toggleBetween_delay
			$whiteBlocks_make_rainbow/Timer.start()
		else:
			$whiteBlocks_make_rainbow.play("fade_in")
	
	await get_tree().create_timer(0.2, false).timeout
	
	if not Globals.transitioned:
		save_game()
	
	Globals.transitioned = false
	Globals.load_saved_position = true
	
	if area_ID != "area0":
		load_game_area() # Loads states for all level objects, doesn't conflict with load_saved_progress_overworld().
	
	night_modifications()
	
	player.camera.position_smoothing_enabled = true
	
	if delete_background_layers:
		bg_deleted = true
		%bg_current.queue_free()
		%bg_previous.queue_free()
		$ParallaxBackgroundGradient.queue_free()
	
	await LevelTransition.fade_from_black_slow()
	
	key_total = get_tree().get_nodes_in_group("key").size()
	keys_leftDisplay.text = str(key_total)
	
	teleporter_assign_ID()
	
	
	instant_background_transitions = false
	
	if not bg_deleted:
		%bg_previous/bg_transition.speed_scale = 1
		%bg_previous/bg_a_transition.speed_scale = 1
		%bg_previous/bg_b_transition.speed_scale = 1
		
		%bg_current/bg_transition.speed_scale = 1
		%bg_current/bg_a_transition.speed_scale = 1
		%bg_current/bg_b_transition.speed_scale = 1
	
	#await get_tree().create_timer(0.2, false).timeout
	
	if not regular_level and not shrine_level:
		SavedData.savedData_save(true)
	
	quickLoad_blocked = false
	$QuickloadLimiter.start()
	Globals.is_saving = false
	
	Globals.just_started_new_game = false
	
	if area_ID != "overworld_factory":
		SavedData.never_saved = false


#Apply saved player properties in the overworld.
func load_saved_progress_overworld():
	if SavedData.never_saved:
		return
	
	#load position
	if not Globals.transitioned:
		player.position = Vector2(SavedData.saved_position_x, SavedData.saved_position_y)
		print("The 'transitioned' (Globals) property is false, so player position is NOT skipped on this game load." + str(Globals.transitioned))
	else:
		print("The 'transitioned' (Globals) property is true, so player position is skipped on this game load (and the player is teleported to the (hopefully) correct area transition object). " + str(Globals.transitioned))
	
	#load score
	Globals.level_score = SavedData.saved_score
	
	#load equipped weapons
	player.weaponType = SavedData.saved_weapon
	player.timer_attack_cooldown.wait_time = SavedData.saved_weapon_delay
	player.secondaryWeaponType = SavedData.saved_secondaryWeapon
	player.timer_secondary_attack_cooldown.wait_time = SavedData.saved_secondaryWeapon_delay
	
	
	#load last used background texture
	if not Globals.transitioned:
		Globals.bg_File_current = SavedData.saved_bg_File_current
		Globals.bg_a_File_current = SavedData.saved_bg_a_File_current
		Globals.bg_b_File_current = SavedData.saved_bg_b_File_current
		
		Globals.bgOffset_target_x = SavedData.saved_bgOffset_target_x
		Globals.bgOffset_target_y = SavedData.saved_bgOffset_target_y
		
		bg_free_to_change = true
		Globals.bgChange_entered.emit()
		Globals.bgMove_entered.emit()
		bg_change()
		bg_move()
		#Globals.bgTransition_finished.emit()
		
		#load last played music
		if SavedData.saved_music_file:
			%music.stream = load(SavedData.saved_music_file)
		if SavedData.saved_music_isPlaying:
			%music.play()
		
		#load last played ambience
		if SavedData.saved_ambience_file:
			%ambience.stream = load(SavedData.saved_ambience_file)
		if SavedData.saved_ambience_isPlaying:
			%ambience.play()


var scoreAttack_timeLeft
var quickLoad_blocked = true

#MAIN START
func _physics_process(delta):
	#Current level's playtime
	levelTime = Time.get_ticks_msec() - start_level_msec
	levelTime_visible = levelTime / 1000.0
	level_timeDisplay.text = str(levelTime_visible)
	
	if levelTime_visible > 10000:
		level_timeDisplay.visible_characters = 7
	elif levelTime_visible > 1000:
		level_timeDisplay.visible_characters = 6
	elif levelTime_visible > 100:
		level_timeDisplay.visible_characters = 5
	elif levelTime_visible > 10:
		level_timeDisplay.visible_characters = 4
	else:
		level_timeDisplay.visible_characters = 3
	
	
	if Globals.quicksaves_enabled and Input.is_action_just_pressed("quicksave") and not quickLoad_blocked:
		quickLoad_blocked = true
		save_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
		
		await get_tree().create_timer(1.0, false).timeout
		Globals.is_saving = false
	
	if Globals.quicksaves_enabled and Input.is_action_just_pressed("quickload") and not quickLoad_blocked:
		quickLoad_blocked = true
		load_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
		
		
		await get_tree().create_timer(1.0, false).timeout
		Globals.is_saving = false
	
	
	#HANDLE BACKGROUND MOVEMENT
	if not bg_position_set and not bg_deleted:
		%bg_previous/CanvasLayer/bg_main.offset.x = move_toward(%bg_previous/CanvasLayer/bg_main.offset.x, Globals.bgOffset_target_x, 250 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg_main.offset.y = move_toward(%bg_previous/CanvasLayer/bg_main.offset.y, Globals.bgOffset_target_y, 250 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg_main.offset.x = move_toward(%bg_previous/CanvasLayer/bg_main.offset.x, Globals.bgOffset_target_x, 250 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg_main.offset.y = move_toward(%bg_previous/CanvasLayer/bg_main.offset.y, Globals.bgOffset_target_y, 250 * bgMove_growthSpeed * delta)
		
		#bg_a
		
		%bg_previous/CanvasLayer/bg_a.offset.x = move_toward(%bg_previous/CanvasLayer/bg_a.offset.x, Globals.bg_a_Offset_target_x, 200 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg_a.offset.y = move_toward(%bg_previous/CanvasLayer/bg_a.offset.y, Globals.bg_a_Offset_target_y, 200 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg_a.offset.x = move_toward(%bg_previous/CanvasLayer/bg_a.offset.x, Globals.bg_a_Offset_target_x, 200 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg_a.offset.y = move_toward(%bg_previous/CanvasLayer/bg_a.offset.y, Globals.bg_a_Offset_target_y, 200 * bgMove_growthSpeed * delta)
		
		#bg_b
		
		%bg_previous/CanvasLayer/bg_b.offset.x = move_toward(%bg_previous/CanvasLayer/bg_b.offset.x, Globals.bg_b_Offset_target_x, 150 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg_b.offset.y = move_toward(%bg_previous/CanvasLayer/bg_b.offset.y, Globals.bg_b_Offset_target_y, 150 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg_b.offset.x = move_toward(%bg_previous/CanvasLayer/bg_b.offset.x, Globals.bg_b_Offset_target_x, 150 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg_b.offset.y = move_toward(%bg_previous/CanvasLayer/bg_b.offset.y, Globals.bg_b_Offset_target_y, 150 * bgMove_growthSpeed * delta)
		
		
		if not instant_background_transitions:
			bgMove_growthSpeed *= 0.995
			bgMove_growthSpeed = clamp(bgMove_growthSpeed, 0.1, 1)
		
		if not instant_background_transitions and bgMove_started and %bg_previous/CanvasLayer/bg_main.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg_main.offset.y == Globals.bgOffset_target_y and %bg_previous/CanvasLayer/bg_a.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg_a.offset.y == Globals.bgOffset_target_y and %bg_previous/CanvasLayer/bg_b.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg_b.offset.y == Globals.bgOffset_target_y:
			bg_position_set = true
			bgMove_growthSpeed = 1
			bgMove_started = false
			
		else:
			bgMove_started = true
	
	
	if Input.is_action_just_pressed("restart"):
		retry()
#MAIN END

var night_toggle = true
var bg_deleted = false

#HANDLE REDUCE PLAYER HP
func handle_player_death():
	player.dead = true
	player.sfx_death.play()
	if regular_level:
		#if Globals.quicksaves_enabled:
			#retry_loadSave(true)
		if Globals.mode_scoreAttack:
			retry_backToMap()
		else:
			retry_checkpoint()
	else:
		retry_checkpoint()

func reduceHp1():
	Globals.playerHP -= 1
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		handle_player_death()

func reduceHp2():
	Globals.playerHP -= 2
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		handle_player_death()

func reduceHp3():
	Globals.playerHP -= 3
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		handle_player_death()

func kill_player():
	Globals.playerHP = 0
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		handle_player_death()

func increaseHp1():
	Globals.playerHP += 1
	healthDisplay.text = str("HP:", Globals.playerHP)

func increaseHp2():
	Globals.playerHP += 2
	healthDisplay.text = str("HP:", Globals.playerHP)

func increaseHp3():
	Globals.playerHP += 3
	healthDisplay.text = str("HP:", Globals.playerHP)


#HANDLE LEVEL EXIT REACHED (unused?)

func _on_exitReached_next_level():
	#Globals.total_score = Globals.total_score + Globals.level_score
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	go_to_next_level()


func _on_exitReached_retry():
	retry()


func exitReached_show_screen():
	
	if not Globals.mode_scoreAttack:
		level_finished.show()
		level_finished.retry_btn.grab_focus()
		%"Level Finished".exit_reached()
		
		get_tree().paused = true
	
	
	elif Globals.mode_scoreAttack:
		if scoreAttack_collectibles != -1:
			if Globals.collected_collectibles >= scoreAttack_collectibles:
				level_finished.show()
				level_finished.retry_btn.grab_focus()
				
				get_tree().paused = true
		
			else:
				Globals.infoSign_current_text = "You need at least 750 collectibles to finish the level!"
				Globals.infoSign_current_size = 2
				Globals.info_sign_touched.emit()
		
		
		elif scoreAttack_collectibles == -1:
			level_finished.show()
			level_finished.retry_btn.grab_focus()
			%"Level Finished".exit_reached()
			
			get_tree().paused = true


func go_to_next_level(): #unused?
	
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
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
	await LevelTransition.fade_to_black()
	get_tree().reload_current_scene()
	#get_tree().change_scene_to_file(scene_file_path)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.playerHP = playerStartHP


var starParticleScene = preload("res://Particles/particles_special_multiple.tscn")

func retry_loadSave(afterDelay):
	await get_tree().create_timer(0.1, false).timeout
	Globals.playerHP = playerStartHP
	healthDisplay.text = str("HP:", Globals.playerHP)
	
	
	if afterDelay:
		player.dead = true
		
		var starParticle = starParticleScene.instantiate()
		starParticle.position = Globals.player_pos
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		starParticle.position = Globals.player_pos
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		starParticle.position = Globals.player_pos
		add_child(starParticle)
		
		await get_tree().create_timer(2, false).timeout
	
	
	player.dead = false
	
	player.scale.x = 1
	player.scale.y = 1
	
	load_game()



#Background change
var bg_free_to_change = true

func bg_change():
	await Globals.bgTransition_finished
	
	if bg_free_to_change:
		bg_free_to_change = false
		print("Background textures began fading.")
		
		%bg_previous/bg_transition.play("bg_hide")
		%bg_previous/bg_a_transition.play("bg_a_hide")
		%bg_previous/bg_b_transition.play("bg_b_hide")
		
		%bg_current/CanvasLayer/bg_main/bg_main/TextureRect.texture = load(Globals.bg_File_current)
		%bg_current/CanvasLayer/bg_a/bg_a/TextureRect.texture = load(Globals.bg_a_File_current)
		%bg_current/CanvasLayer/bg_b/bg_b/TextureRect.texture = load(Globals.bg_b_File_current)
		
		%bg_current/bg_transition.play("bg_show")
		%bg_current/bg_a_transition.play("bg_a_show")
		%bg_current/bg_b_transition.play("bg_b_show")
		
		%bg_current.name = "bg_TEMP"
		%bg_previous.name = "bg_current"
		%bg_TEMP.name = "bg_previous"
		
		
		await Globals.bgTransition_finished
		bg_free_to_change = true



var bg_position_set = true
var bgMove_growthSpeed = 1
var bgMove_started = false

func bg_move():
	bg_position_set = false


var last_checkpoint_pos = Vector2(0, 0)

#Save state
func save_game():
	if not Globals.is_saving:
		Globals.is_saving = true
		
		#if Globals.combo_score != 0:
			#await Globals.comboReset
		
		var save_gameFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
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
			save_gameFile.store_line(json_string)
		
		
		await get_tree().create_timer(0.1, false).timeout
		
		Globals.saved_level_score = Globals.level_score
		
		if last_checkpoint_pos == Vector2(0, 0):
			Globals.saved_player_posX = Globals.player_posX
			Globals.saved_player_posY = Globals.player_posY
		else:
			Globals.saved_player_posX = last_checkpoint_pos[0]
			Globals.saved_player_posY = last_checkpoint_pos[1]
		
		%quicksavedDisplay/Label/AnimationPlayer.play("on_justQuicksaved")
		
		Globals.saveState_saved.emit()
		Globals.is_saving = false


func load_game():
	if SavedData.never_saved:
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
	
	
	#player.position.x = Globals.saved_player_posX
	#player.position.y = Globals.saved_player_posY
	#Globals.level_score = Globals.saved_level_score
	
	Globals.level_score = Globals.saved_level_score
	player.position = Vector2(Globals.saved_player_posX, Globals.saved_player_posY)
	
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.saveState_loaded.emit()


func _on_quickload_limiter_timeout():
	quickLoad_blocked = false

func saved_from_outside():
	quickLoad_blocked = true
	$QuickloadLimiter.stop()
	await get_tree().create_timer(0.2, false).timeout
	save_game()
	$QuickloadLimiter.start()


func _on_debug_refresh_timeout():
	if get_node_or_null("HUD/Debug Screen"):
		$"HUD/Debug Screen".refresh_debugInfo()
	
	Globals.collected_collectibles = Globals.collectibles_in_this_level - get_tree().get_nodes_in_group("Collectibles").size() - (get_tree().get_nodes_in_group("bonusBox").size() * 10)
	%TotalCollectibles_collected.text = str(Globals.collected_collectibles) + "/" + str(Globals.collectibles_in_this_level)

func key_collected():
	key_total -= 1
	keys_leftDisplay.text = str(key_total)
	
	if key_total <= 0:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "key_block", "key_block_destroy")
	
	await get_tree().create_timer(8, false).timeout
	
	keys_leftDisplay.text = str(get_tree().get_nodes_in_group("key").size())


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
	night_toggle = true
	%tileset_main.tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset.png")
	%tileset_main.tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 1.0


func night_modifications():
	await get_tree().create_timer(0.1, false).timeout
	
	if night3 or night2 or night:
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
		
		
		$ParallaxBackgroundGradient/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.modulate.r = 0.1
		$ParallaxBackgroundGradient/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.modulate.a = 0.2
		
		
	else:
		for object in get_tree().get_nodes_in_group("Persist"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("player"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("button_block"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("button"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("bonusBox"):
			object.modulate.r = 1.0


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


var mapScreen = preload("res://Other/Scenes/Level Select/screen_levelSelect.tscn")

func retry_backToMap():
	player.dead = true
	%"Player Died".visible = true
	
	var starParticle = starParticleScene.instantiate()
	starParticle.position = Globals.player_pos
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	starParticle.position = Globals.player_pos
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	starParticle.position = Globals.player_pos
	add_child(starParticle)
	
	await get_tree().create_timer(4, false).timeout
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(mapScreen)
	await LevelTransition.fade_from_black_slow()



func retry_checkpoint():
	var starParticle = starParticleScene.instantiate()
	starParticle.position = Globals.player_pos
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	starParticle.position = Globals.player_pos
	add_child(starParticle)
	starParticle = starParticleScene.instantiate()
	starParticle.position = Globals.player_pos
	add_child(starParticle)
	
	await get_tree().create_timer(2, false).timeout
	await LevelTransition.fade_to_black_slow()
	retry_loadSave(false)
	player.dead = false
	Globals.playerHP = playerStartHP
	healthDisplay.text = str("HP:", Globals.playerHP)


func retry_scoreGate():
	await LevelTransition.fade_to_black_slow()
	retry_loadSave(false)
	player.dead = false
	Globals.playerHP = playerStartHP
	healthDisplay.text = str("HP:", Globals.playerHP)


#Save area state
@export var area_ID = "area0"

func save_game_area():
	if area_ID == "area0":
		return
	
	var save_gameFile = FileAccess.open("user://savegame_" + area_ID + ".save", FileAccess.WRITE)
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
		save_gameFile.store_line(json_string)
	
	
	Globals.saved_level_score = Globals.level_score
	
	reassign_player()
	
	if last_checkpoint_pos == Vector2(0, 0):
		Globals.saved_player_posX = player.position.x
		Globals.saved_player_posY = player.position.y
	else:
		Globals.saved_player_posX = last_checkpoint_pos[0]
		Globals.saved_player_posY = last_checkpoint_pos[1]
	
	
	%quicksavedDisplay/Label/AnimationPlayer.play("on_justQuicksaved")
	
	Globals.saveState_saved.emit()
	
	
	await get_tree().create_timer(0.1, false).timeout
	Globals.is_saving = false


func load_game_area():
	if SavedData.never_saved:
		return
	
	print("Loading area state for: " + str(area_ID))
	if not FileAccess.file_exists("user://savegame_" + area_ID + ".save"):
		print("Area state file not found for: " + str(area_ID))
		return # Error! We don't have a save to load.

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	var save_gameFile = FileAccess.open("user://savegame_" + area_ID + ".save", FileAccess.READ)
	while save_gameFile.get_position() < save_gameFile.get_length():
		var json_string = save_gameFile.get_line()

		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data = json.get_data()
		
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	
	
	#Globals.level_score = Globals.saved_level_score
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.saveState_loaded.emit()


#Save progress loaded from the main menu screen.
func last_area_filePath_save():
	if shrine_level or regular_level:
		return
	
	SavedData.saved_last_area_filePath = savedProgress_level_filePath
	print(SavedData.saved_last_area_filePath)


func reassign_player():
	player = get_tree().get_first_node_in_group("player_root")
	camera = get_tree().get_first_node_in_group("player_camera")
	if not regular_level and not shrine_level:
		get_tree().get_first_node_in_group("quickselect_screen").reassign_player()


func _on_meme_mode_timer_timeout():
	if meme_mode:
		var meme_spawner = preload("res://Meme Mode/memeMode_image_spawner.tscn").instantiate()
		meme_spawner.randomize_all = true
		meme_spawner.position = Vector2(player.position.x + randi_range(-800, 800), player.position.y + randi_range(-500, 500))
		add_child(meme_spawner)
		
		$meme_mode_timer.wait_time = randf_range(0.5, 6)
		$meme_mode_timer.start()


func _on_timer_timeout() -> void:
	if whiteBlocks_toggle:
		whiteBlocks_toggle = false
		$whiteBlocks_make_rainbow.play("fade_out")
		healthDisplay.text = "out"
	else:
		whiteBlocks_toggle = true
		$whiteBlocks_make_rainbow.play("fade_in")
		healthDisplay.text = "in"


func debug_screen_delete():
	debug_screen = $"HUD/Debug Screen"
	
	if not get_node_or_null("HUD/Debug Screen"):
		return
	
	debug_screen.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


@export var random_music = false

func play_random_music():
	var music_dir_path = "res://Assets/Sounds/music"
	var music_dir = DirAccess.open(music_dir_path)
	var music_list = []
	
	if music_dir != null:
		var filenames = music_dir.get_files()
		
		for filename in filenames:
			if filename.ends_with(".mp3"):
				music_list.append(filename)
	
	var rolled_music = music_list.pick_random()
	print(rolled_music)
	music.stream = load(music_dir_path + "/" + rolled_music)
	music.play()


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
