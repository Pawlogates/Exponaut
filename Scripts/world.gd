extends Node2D

@export var next_level: PackedScene

@onready var canvas_layer = %HUD


@onready var player = %Player


@onready var level_finished = %"Level Finished"
@onready var start_in_container = %StartInContainer
@onready var start_in = %StartIn
@onready var animation_player = %AnimationPlayer



@onready var level_timeDisplay = %levelTime
@onready var healthDisplay = %health
@onready var keys_leftDisplay = %keysLeft



var levelTime = 0
var start_level_msec = 0.0
var levelTime_visible = 0


@onready var start_pos = global_position


@onready var tileset_main = $tileset_main
@onready var tileset_objects = $tileset_objects
@onready var tileset_objects_small = $tileset_objectsSmall


var mode_scoreAttack_manager = preload("res://mode_score_attack.tscn").instantiate()

var rain_scene = preload("res://weather_rain.tscn")
var leaves_scene = preload("res://weather_leaves.tscn")


@export var playerStartHP = 3
var key_total = 50

@export var scoreAttack_collectibles = -1



@export var regular_level = false

@export var night = false
@export var night2 = false
@export var night3 = false

@export var rain = false
@export var leaves = false



# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.mode_scoreAttack:
		add_child(mode_scoreAttack_manager)
		%music.stream = preload("res://Assets/Sounds/music/mode_scoreAttack.mp3")
		%music.volume_db = -3
		%music.play()
	
	#%bg_current.queue_free()
	#%bg_previous.queue_free()
	#$tileset_objects.queue_free() #DEBUG
	#$tileset_objectsSmall.queue_free() #DEBUG
	
	
	
	
	get_tree().paused = false
	
	Globals.save.connect(saved_from_outside)
	
	Globals.level_score = 0
	
	%HUD.visible = true
	
	tileset_objects.set_layer_enabled(0, true)
	tileset_objects.set_layer_enabled(1, true)
	tileset_objects.set_layer_enabled(2, true)
	tileset_objects.set_layer_enabled(3, true)
	tileset_objects.set_layer_enabled(4, true)
	tileset_objects_small.set_layer_enabled(0, true)
	
	
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
	
	
	Globals.bgFile_previous = preload("res://Assets/Graphics/bg1.png")
	Globals.bgFile_current = preload("res://Assets/Graphics/bg1.png")
	
	Globals.bgChange_entered.connect(bg_change)
	Globals.bgMove_entered.connect(bg_move)
	
	if not regular_level:
		Globals.quicksaves_enabled = true
	
	
	#if not next_level is PackedScene:
		#level_finished.next_level_btn.text = "Results"
		#next_level = preload("res://VictoryScreen.tscn")
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	
	if Globals.quicksaves_enabled:
		quickLoad_blocked = true
		save_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
	
	
	
	#get_tree().paused = true
	
	#start_in_container.visible = true
	start_in_container.visible = false
	
	
	
	
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
	
	
	
	
	Globals.cheated_state = false
	
	
	#animation_player.play("StartInAnim")
	#await animation_player.animation_finished
	#get_tree().paused = false
	
	if regular_level:
		%bg_previous/bg_transition.speed_scale = 20
		%bg_previous/bg_a_transition.speed_scale = 20
		%bg_previous/bg_b_transition.speed_scale = 20
	
		%bg_current/bg_transition.speed_scale = 20
		%bg_current/bg_a_transition.speed_scale = 20
		%bg_current/bg_b_transition.speed_scale = 20
		
		bgMove_growthSpeed = 100
	
	
	
	
	
	
	
	await get_tree().create_timer(0.1, false).timeout
	
	if area_ID != "area0" and Globals.next_transition != 0:
		load_game_area()
	
	
	night_modifications()
	await LevelTransition.fade_from_black_slow()
	
	
	
	key_total = get_tree().get_nodes_in_group("key").size()
	keys_leftDisplay.text = str(key_total)
	
	teleporter_assign_ID()








@onready var fps = %fps
@onready var test = %test
@onready var test2 = %test2
@onready var test3 = %test3
@onready var test4 = %test4

var debugToggle = false




var scoreAttack_timeLeft
var quickLoad_blocked = true

#MAIN START

func _physics_process(delta):
	
	#LEVEL TIME
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
	
	
	
	#BACKGROUND MOVEMENT HANDLE
	
	if not bg_position_set:
		%bg_previous/CanvasLayer/bg.offset.x = move_toward(%bg_previous/CanvasLayer/bg.offset.x, Globals.bgOffset_target_x * 1, 100 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg.offset.y = move_toward(%bg_previous/CanvasLayer/bg.offset.y, Globals.bgOffset_target_y * 1, 250 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg.offset.x = move_toward(%bg_current/CanvasLayer/bg.offset.x, Globals.bgOffset_target_x * 1, 100 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg.offset.y = move_toward(%bg_current/CanvasLayer/bg.offset.y, Globals.bgOffset_target_y * 1, 250 * bgMove_growthSpeed * delta)
		
		#bg_a
		
		%bg_previous/CanvasLayer/bg/bg_a.motion_offset.x = move_toward(%bg_previous/CanvasLayer/bg/bg_a.motion_offset.x, Globals.bgOffset_target_x * -0.1, 250 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg/bg_a.motion_offset.y = move_toward(%bg_previous/CanvasLayer/bg/bg_a.motion_offset.y, Globals.bgOffset_target_y * -0.1, 450 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg/bg_a.motion_offset.x = move_toward(%bg_current/CanvasLayer/bg/bg_a.motion_offset.x, Globals.bgOffset_target_x * -0.1, 250 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg/bg_a.motion_offset.y = move_toward(%bg_current/CanvasLayer/bg/bg_a.motion_offset.y, Globals.bgOffset_target_y * -0.1, 450 * bgMove_growthSpeed * delta)
		
		#bg_b
		
		%bg_previous/CanvasLayer/bg/bg_b.motion_offset.x = move_toward(%bg_previous/CanvasLayer/bg/bg_b.motion_offset.x, Globals.bgOffset_target_x * -0.4, 200 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg/bg_b.motion_offset.y = move_toward(%bg_previous/CanvasLayer/bg/bg_b.motion_offset.y, Globals.bgOffset_target_y * -0.4, 350 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg/bg_b.motion_offset.x = move_toward(%bg_current/CanvasLayer/bg/bg_b.motion_offset.x, Globals.bgOffset_target_x * -0.4, 200 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg/bg_b.motion_offset.y = move_toward(%bg_current/CanvasLayer/bg/bg_b.motion_offset.y, Globals.bgOffset_target_y * -0.4, 350 * bgMove_growthSpeed * delta)
		
		
		
		if not regular_level:
			bgMove_growthSpeed *= 0.995
			bgMove_growthSpeed = clamp(bgMove_growthSpeed, 0.05, 1)
		
		
		if not regular_level and bgMove_started and %bg_previous/CanvasLayer/bg.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg.offset.y == Globals.bgOffset_target_y and %bg_previous/CanvasLayer/bg/bg_a.motion_offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg/bg_a.motion_offset.y == Globals.bgOffset_target_y and %bg_previous/CanvasLayer/bg/bg_b.motion_offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg/bg_b.motion_offset.y == Globals.bgOffset_target_y:
			bg_position_set = true
			bgMove_growthSpeed = 1
			bgMove_started = false
			
		else:
			bgMove_started = true
	
	
	
	if Input.is_action_just_pressed("restart"):
		retry()
	
	
	
	
	
	
	#DEBUG
	
	if Input.is_action_just_pressed("show_debugInfo"):
		if debugToggle:
			%fps.visible = false
			%test.visible = false
			%test2.visible = false
			%test3.visible = false
			%test4.visible = false
			debugToggle = false
			get_tree().set_debug_collisions_hint(false) 
		
		else:
			%fps.visible = true
			%test.visible = true
			%test2.visible = true
			%test3.visible = true
			%test4.visible = true
			debugToggle = true
			get_tree().set_debug_collisions_hint(true) 
	
	
	
	
	
	if Input.is_action_just_pressed("night_toggle"):
		night_tileset_toggle()
	
	




#MAIN END


var night_toggle = true











#HANDLE REDUCE PLAYER HP

func reduceHp1():
	Globals.playerHP -= 1
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		player.death.play()
		if Globals.quicksaves_enabled:
			retry_loadSave()
		else:
			retry_backToMap()
	

func reduceHp2():
	Globals.playerHP -= 2
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		player.death.play()
		if Globals.quicksaves_enabled:
			retry_loadSave()
		else:
			retry_backToMap()

func reduceHp3():
	Globals.playerHP -= 3
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		player.death.play()
		if Globals.quicksaves_enabled:
			retry_loadSave()
		else:
			retry_backToMap()

func kill_player():
	Globals.playerHP -= 100
	healthDisplay.text = str("HP:", Globals.playerHP)
	if Globals.playerHP <= 0 and not player.dead:
		player.death.play()
		if Globals.quicksaves_enabled:
			retry_loadSave()
		else:
			retry_backToMap()


func increaseHp1():
	Globals.playerHP += 1
	healthDisplay.text = str("HP:", Globals.playerHP)

func increaseHp2():
	Globals.playerHP += 2
	healthDisplay.text = str("HP:", Globals.playerHP)





#HANDLE LEVEL EXIT REACHED

func _on_exitReached_next_level():
	Globals.total_score = Globals.total_score + Globals.level_score
	
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
	







func go_to_next_level():
	
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 0
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






var starParticleScene = preload("res://particles_special_multiple.tscn")
var starParticle = starParticleScene.instantiate()

func retry_loadSave():
	await get_tree().create_timer(0.1, false).timeout
	Globals.playerHP = playerStartHP
	healthDisplay.text = str("HP:", Globals.playerHP)
	
	
	
	player.dead = true
	
	starParticle = starParticleScene.instantiate()
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
		#print("BG CHANGE STARTED")
		%bg_previous/bg_transition.play("bg_hide")
		%bg_previous/bg_a_transition.play("bg_a_hide")
		%bg_previous/bg_b_transition.play("bg_b_hide")
		
		%bg_current/CanvasLayer/bg/bg_main/TextureRect.texture = Globals.bgFile_current
		%bg_current/CanvasLayer/bg/bg_a/TextureRect.texture = Globals.bg_a_File_current
		%bg_current/CanvasLayer/bg/bg_b/TextureRect.texture = Globals.bg_b_File_current
		
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
	




#Save state

func save_game():
	print(%Player.is_on_floor())
	if not Globals.quicksaves_enabled or not %Player.is_on_floor():
		print("no")
		return
	
	
	if %Player.is_on_floor():
		Globals.is_saving = true
		
		print(%Player.is_on_floor())
		
		%Player.velocity = Vector2(0, 0)
		
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
			
		
		
		Globals.saved_level_score = Globals.level_score
		
		Globals.saved_player_posX = player.position.x
		Globals.saved_player_posY = player.position.y
		
		%quicksavedDisplay/Label/AnimationPlayer.play("on_justQuicksaved")
		
		Globals.saveState_saved.emit()
		
		
		await get_tree().create_timer(0.1, false).timeout
		Globals.is_saving = false
	
	




func load_game():
	if not Globals.quicksaves_enabled:
		return
	
	
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if i.is_in_group(Globals.loadingZone_current) or i.is_in_group("loadingZone0"):
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


		
		if "loadingZone" in node_data and node_data["loadingZone"] == Globals.loadingZone_current or "loadingZone" in node_data and node_data["loadingZone"] == "loadingZone0":
			var new_object = load(node_data["filename"]).instantiate()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "destroyed":
					continue
				new_object.set(i, node_data[i])
			
		else:
			continue
			
		
	player.position.x = Globals.saved_player_posX
	player.position.y = Globals.saved_player_posY
		
	Globals.level_score = Globals.saved_level_score
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
	fps.text = str("fps: ", Engine.get_frames_per_second())
	test.text = str("total persistent objects present: ", Globals.test)
	test2.text = str("total objects queued for next reload: ", Globals.test2)
	test3.text = str("total collectibles: ", Globals.test3)
	test4.text = str("current active loading zone: ", Globals.test4)
	
	%TotalCollectibles_collected.text = str(Globals.collected_collectibles) + "/" + str(Globals.test3)
	
	Globals.inventory_selectedItem = 1
	
	
	#for teleporter in get_tree().get_nodes_in_group("teleporter"):
		#print(teleporter.get_groups())
		




func key_collected():
	key_total -= 1
	keys_leftDisplay.text = str(key_total)
	
	if key_total <= 0:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "key_block", "key_block_destroy")
	
	await get_tree().create_timer(8, false).timeout
	
	keys_leftDisplay.text = str(get_tree().get_nodes_in_group("key").size())






#NIGHT/DAY TIME

func night_tileset_toggle():
	if night_toggle:
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
			
	else:
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





var mapScreen = load("res://map_screen.tscn")

func retry_backToMap():
	player.dead = true
	%"Player Died".visible = true
	
	starParticle = starParticleScene.instantiate()
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







#Save area state
@export var area_ID = "area0"

func save_game_area():
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
		
		Globals.saved_player_posX = player.position.x
		Globals.saved_player_posY = player.position.y
		
		%quicksavedDisplay/Label/AnimationPlayer.play("on_justQuicksaved")
		
		Globals.saveState_saved.emit()
		
		
		await get_tree().create_timer(0.1, false).timeout
		Globals.is_saving = false
	
	




func load_game_area():
	if not FileAccess.file_exists("user://savegame_" + area_ID + ".save"):
		return # Error! We don't have a save to load.

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if i.is_in_group(Globals.loadingZone_current) or i.is_in_group("loadingZone0"):
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


		
		if "loadingZone" in node_data and node_data["loadingZone"] == Globals.loadingZone_current or "loadingZone" in node_data and node_data["loadingZone"] == "loadingZone0":
			var new_object = load(node_data["filename"]).instantiate()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "destroyed":
					continue
				new_object.set(i, node_data[i])
			
		else:
			continue
	
	
	
	Globals.level_score = Globals.saved_level_score
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.saveState_loaded.emit()





func reassign_player():
	player = get_tree().get_first_node_in_group("player")
